/* -------------------------------------------------------------------------- */
/* --- Control Port                                                       --- */
/* -------------------------------------------------------------------------- */

#import "CS.h"

value wcaml_nscell_set_enabled(value vcell,value venabled);
// NSCell -> bool -> unit

value wcaml_nscell_set_title(value vcell,value vtitle);
// NSCell -> NSString -> unit

value wcaml_nscell_set_state(value vcell,value vstate);
// NSCell -> bool -> unit

value wcaml_nscell_get_state(value vcell);
// NSCell -> bool

