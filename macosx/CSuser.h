/* -------------------------------------------------------------------------- */
/* --- User Preferences                                                   --- */
/* -------------------------------------------------------------------------- */

#import "CSdata.h"

value wcaml_set_user_object(value nskey,value nsval);
// NSString,id -> unit

value wcaml_get_user_string(value nskey);
// NSString -> NSString

