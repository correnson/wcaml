/* -------------------------------------------------------------------------- */
/* --- Text Views Port                                                    --- */
/* -------------------------------------------------------------------------- */

#import "CStext.h"

value wcaml_nstext_create(value vunit)
{
  NSRect frame = NSMakeRect(0,0,60,20);
  NSTextView * text = [[NSTextView alloc] initWithFrame:frame];
  return (value) text;
}

value wcaml_nstext_set_editable(value vtext,value veditable)
{
  [ID(NSTextView,vtext) setEditable:BOOL(veditable)];
  return Val_unit;
}

value wcaml_nstext_set_string(value vtext,value vstring)
{
  [ID(NSTextView,vtext) setString:ID(NSString,vstring)];
  return Val_unit;
}

value wcaml_nstext_set_attribute(value vtext,value vcode)
{
  NSTextView* view = ID(NSTextView,vtext);
  switch(Int_val(vcode)) {
  case 1: [view setAlignment:NSLeftTextAlignment]; break;
  case 2: [view setAlignment:NSRightTextAlignment]; break;
  case 3: [view setAlignment:NSCenterTextAlignment]; break;
  case 4: [view setFont:[NSFont labelFontOfSize:0]]; break;
  case 5: [view setFont:[NSFont boldSystemFontOfSize:0]]; break;
  case 6: [view setFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]]]; break;
  }
  return Val_unit;
}
