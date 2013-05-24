/* -------------------------------------------------------------------------- */
/* --- NSControl Signal Callback                                          --- */
/* -------------------------------------------------------------------------- */

#import "CScontrol.h"

@implementation CSSignal
- (void)fireSignal:(id)sender { wcaml_callback_signal(sender); }
@end

void wcaml_callback_signal(id sender)
{
  static value* service = NULL;
  if (!service) service = caml_named_value("nscontrol_signal");
  if (service) caml_callback2( *service , (value) sender , Val_unit );
  return;
}

CSSignal* wcaml_target_signal(void)
{
  static CSSignal* target = nil;
  if (!target) target = [[CSSignal alloc] init];
  return target;
}

value wcaml_nscontrol_set_enabled(value vcontrol)
{
  NSControl* control = ID(NSControl,vcontrol);
  [control setEnabled:BOOL(vcontrol)];
  return vcontrol ;
}

value wcaml_nscontrol_set_emitter(value vcontrol)
{
  NSControl* control = ID(NSControl,vcontrol);
  [control setAction:@selector(fireSignal:)];
  [control setTarget:wcaml_target_signal()];
  return vcontrol ;
}

value wcaml_nscontrol_set_string(value vcontrol,value vstring)
{
  NSControl* control = ID(NSControl,vcontrol);
  NSString* theText = ID(NSString,vstring);
  [control setStringValue:theText];
  return Val_unit;
}

value wcaml_nscontrol_get_string(value vcontrol)
{
  NSControl* control = ID(NSControl,vcontrol);
  return (value) [control stringValue];
}

/* -------------------------------------------------------------------------- */
/* --- NSButton                                                           --- */
/* -------------------------------------------------------------------------- */

value wcaml_nsbutton_create(value vcode)
{
  NSButton* button = [[NSButton alloc] init];
  [button setAutoresizingMask:NSViewMaxXMargin|NSViewMinYMargin];
  [button setTranslatesAutoresizingMaskIntoConstraints:NO];
  switch(Int_val(vcode)) {
  case 0: 
    // ---- Push Button
    [button setButtonType:NSMomentaryPushInButton];
    [button setBezelStyle:NSRoundedBezelStyle];
    break;
  case 1:
    // ---- Checkbox Button
    [button setButtonType:NSSwitchButton];
    break;
  case 2:
    // ---- Radio Button
    [button setButtonType:NSRadioButton];
    break;
  }
  return (value) button;
}

/* -------------------------------------------------------------------------- */
/* --- NSTextField                                                        --- */
/* -------------------------------------------------------------------------- */

value wcaml_nstextfield_create(value vunit)
{
  NSTextView * text = [[NSTextView alloc] init];
  [text setTranslatesAutoresizingMaskIntoConstraints:NO];
  return (value) text;
}

value wcaml_nstextfield_set_attribute(value vtextfield,value vattr)
{
  NSTextField* textField = ID(NSTextField,vtextfield);
  switch(Int_val(vattr)) {
  case 1: [textField setAlignment:NSLeftTextAlignment]; break;
  case 2: [textField setAlignment:NSRightTextAlignment]; break;
  case 3: [textField setAlignment:NSCenterTextAlignment]; break;
  case 4: [textField setFont:[NSFont labelFontOfSize:0]]; break;
  case 5: [textField setFont:[NSFont boldSystemFontOfSize:0]]; break;
  case 6: [textField setFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]]]; break;
  case 10: 
    [textField setBordered:NO];
    [textField setBezeled:NO];
    [textField setSelectable:NO];
    [textField setEditable:NO];
    [textField setBackgroundColor:[NSColor controlColor]];
    break;
  case 20:
    [textField setBordered:YES];
    [textField setBezeled:YES];
    [textField setSelectable:YES];
    [textField setEditable:YES];
    break;
  }
  return Val_unit;
}
