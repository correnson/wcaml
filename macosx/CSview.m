/* -------------------------------------------------------------------------- */
/* --- NSView Port                                                        --- */
/* -------------------------------------------------------------------------- */

#import "CS.h"

value wcaml_nsview_set_tooltip(value vcell,value vtooltip)
{
  [ID(NSView,vcell) setToolTip:ID(NSString,vtooltip)];
  return Val_unit ;
}
