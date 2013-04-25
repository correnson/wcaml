/* -------------------------------------------------------------------------- */
/* --- Window Port                                                        --- */
/* -------------------------------------------------------------------------- */

#import "CS.h"

value wcaml_nswindow_cascading(value unit);
// unit -> unit

@interface CSWinDelegate : NSObject < NSWindowDelegate > ;
- (void)windowDidBecomeMain:(NSNotification *)notification;
- (void)windowDidResignMain:(NSNotification *)notification;
- (BOOL)windowShouldClose:(id)sender;
@end

value wcaml_nswindow_create(value vkey);
// NSString -> NSWindow

value wcaml_nswindow_set_title(value vwindow,value vtitle);
// NSWindow -> NSString -> unit

value wcaml_nswindow_set_edited(value vwindow,value vedited);
// NSWindow -> BOOL -> unit

value wcaml_nswindow_set_content(value vwindow,value vwidget);
// NSWindow -> NSView -> unit

value wcaml_nswindow_show(value vwindow);
// NSWindow -> unit

value wcaml_nswindow_hide(value vwindow);
// NSWindow -> unit
