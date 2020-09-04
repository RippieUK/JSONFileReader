# JSONFileReader

Bug found in the GLib.JSON library:
https://gitlab.gnome.org/GNOME/json-glib/-/issues/39

We have considered these 2 ways of working with the JSON file
* https://valadoc.org/json-glib-1.0/Json.gobject_deserialize.html
* The other way is traversing the JSON "tree" manually by using get/set methods on JSON.Node objects to get child objects/properties

We have this issue because we need to make a custom "deserialize" function, which is caused by the fact that we want to deserialize an array

But in theory it could have been caused by any slightly "custom" data type
