/* -------------------------------------------------------------------------- */
/* --- NSCell Port                                                       --- */
/* -------------------------------------------------------------------------- */

#import "CS.h"

value wcaml_nscell_set_enabled(value vcell,value venabled)
{
  [ID(NSCell,vcell) setEnabled:BOOL(venabled)];
  return Val_unit ;
}

value wcaml_nscell_set_title(value vcell,value vtitle)
{
  [ID(NSCell,vcell) setTitle:ID(NSString,vtitle)];
  return Val_unit ;
}

value wcaml_nscell_set_state(value vcell,value vstate)
{
  [ID(NSCell,vcell) setState:(COND(vstate)?NSOnState:NSOffState)];
  return Val_unit ;
}

value wcaml_nscell_get_state(value vcell)
{
  NSInteger state = [ID(NSCell,vcell) state];
  return (state == NSOnState) ? Val_true : Val_false ;
}
