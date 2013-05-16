/* -------------------------------------------------------------------------- */
/* --- NSControl                                                          --- */
/* -------------------------------------------------------------------------- */

#import "CS.h"

@interface CSSignal : NSObject ;
- (void)fireSignal:(id)sender;
@end

void wcaml_callback_signal(id sender);
// Calls OCaml callback

CSSignal* wcaml_target_signal(void);
// Shared Target Nesponder Object 

value wcaml_nscontrol_set_emitter(value vcontrol);
// NSControl -> Portcontrol.emitter (self)

value wcaml_nsbutton_create(value vunit);
// unit -> NSButton
