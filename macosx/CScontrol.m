/* -------------------------------------------------------------------------- */
/* --- NSControl Signal Callback                                          --- */
/* -------------------------------------------------------------------------- */

#import "CS.h"
#import "CScontrol.h"

@implementation CSSignal
static CSSignal *target = nil;

+ (CSSignal*)sharedTarget
{
  if (!target) target = [[CSSignal alloc] init];
  return target;
}

- (void)fireSignal:(id)sender 
{ 
  static value *service = NULL;
  if (!service) service = caml_named_value("wcaml_nscontrol_signal");
  if (service) caml_callback2( *service , (value) sender , Val_unit );
  return;
}

@end

value wcaml_nscontrol_set_enabled(value vcontrol)
{
  NSControl *control = ID(NSControl,vcontrol);
  [control setEnabled:BOOL(vcontrol)];
  return vcontrol ;
}

value wcaml_nscontrol_set_emitter(value vcontrol)
{
  NSControl *control = ID(NSControl,vcontrol);
  [control setAction:@selector(fireSignal:)];
  [control setTarget:[CSSignal sharedTarget]];
  return vcontrol ;
}

value wcaml_nscontrol_set_string(value vcontrol,value vstring)
{
  NSControl *control = ID(NSControl,vcontrol);
  NSString *theText = ID(NSString,vstring);
  [control setStringValue:theText];
  return Val_unit;
}

value wcaml_nscontrol_get_string(value vcontrol)
{
  NSControl *control = ID(NSControl,vcontrol);
  return (value) [control stringValue];
}

/* -------------------------------------------------------------------------- */
/* --- NSButton                                                           --- */
/* -------------------------------------------------------------------------- */

value wcaml_nsbutton_create(value vcode)
{
  NSButton *button = [[NSButton alloc] init];
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
  NSTextField  *text = [[NSTextField alloc] init];
  [text setTranslatesAutoresizingMaskIntoConstraints:NO];
  return (value) text;
}

value wcaml_nstextfield_set_attribute(value vtextfield,value vattr)
{
  NSTextField *textField = ID(NSTextField,vtextfield);
  NSInteger attr = Int_val(vattr);
  switch(attr) {
  case 1: [textField setAlignment:NSLeftTextAlignment]; break;
  case 2: [textField setAlignment:NSRightTextAlignment]; break;
  case 3: [textField setAlignment:NSCenterTextAlignment]; break;
  case 4: [textField setFont:[NSFont controlContentFontOfSize:0]]; break;
  case 5: [textField setFont:[NSFont boldSystemFontOfSize:0]]; break;
  case 6: 
    [textField setFont:[NSFont controlContentFontOfSize:
				 [NSFont smallSystemFontSize]]];
    break;
  case 7:
    {
      NSFont *font = [NSFont fontWithName:@"Courier" size:12.0];
      if (font) [textField setFont:font];
    }
    break;
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
  default:
    NSLog(@"CScontrol: unknown text-attribute %d",attr);
  }
  return Val_unit;
}

/* -------------------------------------------------------------------------- */
/* --- NSImage                                                            --- */
/* -------------------------------------------------------------------------- */

value wcaml_nsimage_system(value vcode)
{
  NSString *ref = nil;
  switch(Int_val(vcode)) {
    //--- Status
  case 10: ref = NSImageNameStatusNone; break;
  case 11: ref = NSImageNameStatusAvailable; break;
  case 12: ref = NSImageNameStatusPartiallyAvailable; break;
  case 13: ref = NSImageNameStatusUnavailable; break;
    //--- Interaction
  case 21: ref = NSImageNameCaution; break;
  case 22: ref = NSImageNameActionTemplate; break;
  case 23: ref = NSImageNameTrashEmpty; break;
    //--- Default -> ref=nil
  }
  NSImage *img = ref ? [NSImage imageNamed:ref] : nil ;
  return (value) img;
}

value wcaml_nsimage_create(value vfile)
{
  NSString *file = ID(NSString,vfile);
  NSImage *img = [[NSImage alloc] initWithContentsOfFile:file];
  return (value) img;
}

/* -------------------------------------------------------------------------- */
/* --- NSImageView                                                        --- */
/* -------------------------------------------------------------------------- */

value wcaml_nsimage_set(value vcontrol,value vimage)
{
  NSImageView *control = ID(NSImageView,vcontrol);
  NSImage *image = ID(NSImage,vimage);
  [control setImage:image];
  return Val_unit;
}

/* -------------------------------------------------------------------------- */
