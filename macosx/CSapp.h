/* -------------------------------------------------------------------------- */
/* --- WCaml NSApplication Class                                          --- */
/* -------------------------------------------------------------------------- */

#import "CS.h"

@interface CSAppDelegate : NSObject
{ NSString * theAppName ; }
-(NSString *) appName;
-(void) makeAppMenu:(NSMenu*)menu;
@end

