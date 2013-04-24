/* -------------------------------------------------------------------------- */
/* --- Window Port                                                        --- */
/* -------------------------------------------------------------------------- */

#import "CS.h"

value wcaml_nswindow_cascading(value unit);
// unit -> unit

value wcaml_nswindow_create(value vkey);
// NSString -> NSWindow

value wcaml_nswindow_set_title(value vwindow,value vtitle);
// NSWindow -> NSString -> unit

value wcaml_nswindow_set_edited(value vwindow,value vedited);
// NSWindow -> BOOL -> unit
