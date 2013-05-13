/* -------------------------------------------------------------------------- */
/* --- NSCell Port                                                       --- */
/* -------------------------------------------------------------------------- */

#import "CScell.h"

value wcaml_nscell_set_enabled(value vcell,value venabled)
{
  [ID(NSCell,vcell) setEnabled:VBOOL(venabled)];
  return Val_unit ;
}
