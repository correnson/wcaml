/* -------------------------------------------------------------------------- */
/* --- Text Views Port                                                    --- */
/* -------------------------------------------------------------------------- */

#import "CS.h"

value wcaml_nstext_create(value vunit);
// unit -> NSTextView

value wcaml_nstext_set_editable(value vtext,value veditable);
// NSTextView -> bool -> unit

value wcaml_nstext_set_string(value vtext,value vstring);
// NSTextView -> NSString -> unit

