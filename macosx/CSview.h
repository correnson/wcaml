/* -------------------------------------------------------------------------- */
/* --- NSView Port                                                       --- */
/* -------------------------------------------------------------------------- */

#import "CS.h"

value wcaml_nsview_create(value vunit);
// unit -> NSView.t

value wcaml_nsview_set_tooltip(value vcell,value vtooltip);
// NSView -> NSString -> unit

value wcaml_nsview_add_subview(value vbox,value vitem);
// NSView.t(box) -> NSView.t(item) -> unit

value wcaml_nsview_has_baseline(value vitem);
// NSView.t -> bool

value wcaml_nsview_set_layout(value vbox,
			      value vlayout,
			      value vitem_a,
			      value vitem_b,
			      value vconstant);
/* NSView(container) -> 
   int(constraint code) -> 
   NSView(View A) ->
   NSView(View B) ->
   int(constant) -> 
   unit 
*/
