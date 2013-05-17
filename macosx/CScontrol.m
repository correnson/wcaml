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

value wcaml_nscontrol_set_emitter(value vcontrol)
{
  NSControl* control = ID(NSControl,vcontrol);
  [control setAction:@selector(fireSignal:)];
  [control setTarget:wcaml_target_signal()];
  return vcontrol ;
}

/* -------------------------------------------------------------------------- */
/* --- NSButton                                                           --- */
/* -------------------------------------------------------------------------- */

value wcaml_nsbutton_create(value vcode)
{
  NSButton* button = [[NSButton alloc] init];
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
