/* -------------------------------------------------------------------------- */
/* --- Text Views Port                                                    --- */
/* -------------------------------------------------------------------------- */

#import "CStext.h"

value wcaml_nstext_create(value vunit)
{
  NSTextView * text = [[NSTextView alloc] initWithFrame:nil];
  return (value) text;
}

value wcaml_nstext_set_editable(value vtext,value veditable)
{
  [ID(NSTextView,vtext) setEditable:BOOL(veditable)];
  return Val_unit;
}

value wcaml_nstext_set_string(value vtext,value vstring)
{
  [[ID(NSTextView,vtext) textStorage] setString:(NSString,vstring)];
  return Val_unit;
}
