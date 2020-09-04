// valac --pkg json-glib-1.0 --pkg gee-0.8 JSONFileReader.vala

public class KeyValuePair : Object {
    public string Name { get; set; }
    public string Value { get; set; }
}

public class Host : Object, Json.Serializable {
    // Setting these properties as construct instead of set works around https://gitlab.gnome.org/GNOME/json-glib/-/issues/39
    // But is obviously inconvenient

    public string DisplayName { get; construct; }
    public string Hostname_IP { get; construct; }
    public string Description { get; construct; }
    public string Protocol { get; construct; }
    public string UserName { get; construct; }

    public Gee.HashMap<string, string> Protocol_Options { get; set; }

    public string to_string () {
        StringBuilder builder = new StringBuilder ();
        builder.append_printf ("DisplayName = %s\n", DisplayName);
        builder.append_printf ("Hostname_IP = %s\n", Hostname_IP);
        builder.append_printf ("Description = %s\n", Description);
        builder.append_printf ("Protocol = %s\n", Protocol);

        foreach (var option in Protocol_Options) {
            builder.append_printf ("    %s = %s\n", option.key, option.value);
        }

        builder.append_printf ("UserName = %s\n", UserName);
        return (owned) builder.str;
    }

    public virtual bool deserialize_property (string property_name, out Value @value, ParamSpec pspec, Json.Node property_node) {
        if (property_name == "Protocol-Options") {
            var node = property_node.get_array ();
            if (node != null) {
                var map = new Gee.HashMap<string, string> ();
                node.foreach_element ((arr, i, kv) => {
                    var kv_pair = Json.gobject_deserialize (typeof (KeyValuePair), kv) as KeyValuePair;
                    map.@set (kv_pair.Name, kv_pair.Value);
                });

                @value = Value (typeof (Gee.HashMap));
                @value.set_object (map);

                return true;
            } else {
                return false;
            }
        }

        return default_deserialize_property (property_name, out @value, pspec, property_node);
    }
}

public class JSONConfig : Object, Json.Serializable {
    public Gee.ArrayList<Host> Hosts { get; set; }

    public bool deserialize_property (string property_name, out Value @value, ParamSpec pspec, Json.Node property_node) {
        if (property_name == "Hosts") {
            var node = property_node.get_array ();
            if (node != null) {
                var arraylist = new Gee.ArrayList<Object> ();
                node.foreach_element ((arr, i, host) => {
                    var new_host = Json.gobject_deserialize (typeof (Host), host);
                    arraylist.add (new_host);
                });

                @value = Value (typeof (Gee.ArrayList));
                @value.set_object (arraylist);

                return true;
            } else {
                return false;
            }
        }

        return default_deserialize_property (property_name, out @value, pspec, property_node);
    }
}

public static int main (string[] args) {
    if (args.length < 2) {
        print ("Usage: test <filename.json>\n");
        return -1;
    }
    // Load a file:
    Json.Parser parser = new Json.Parser ();
    try {
        parser.load_from_file (args[1]);
    } catch (Error e) {
        print ("Unable to parse `%s': %s\n", args[1], e.message);
        return -1;
    }

    // Get the root node:
    Json.Node node = parser.get_root ();
    var hosts = Json.gobject_deserialize (typeof (JSONConfig), node) as JSONConfig;
    foreach (var host in hosts.Hosts) {
        print (host.to_string ());
        print ("\n");
    }

    return 0;
}
