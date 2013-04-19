/* -------------------------------------------------------------------------- */
/* --- WCaml NSApplication Class                                          --- */
/* -------------------------------------------------------------------------- */

#import "CS.h"

@interface CSDelegate : NSObject
{ NSString * theAppName ; }
-(NSString *) appName;
-(void) makeAppMenu:(NSMenu*)menu;
@end

@interface CSApplication : NSApplication 
{ }
@end

