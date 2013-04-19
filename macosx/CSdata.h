#import "CS.h"

value wcaml_value_of_nsstring(NSString *theText);
NSString* wcaml_nsstring_of_value(value v_str);

value wcaml_nsarray_init(value vcapacity); // int -> arr
value wcaml_nsarray_count(value varray);   // arr -> int
value wcaml_nsarray_add(value varray,value velt); // arr,elt -> unit
value wcaml_nsarray_get(value varray,value vindex); // arr,int -> elt
value wcaml_nsarray_set(value varray,value vindex,value velt); // arr,int,elt -> unit
