// --------------------------------------------------------------------------
// --- CSWinDelegate
// --------------------------------------------------------------------------

@interface CSWinDelegate : NSObject < NSWindowDelegate > ;
- (void)windowDidBecomeMain:(NSNotification *)notification;
- (void)windowDidResignMain:(NSNotification *)notification;
- (BOOL)windowShouldClose:(id)sender;
@end
