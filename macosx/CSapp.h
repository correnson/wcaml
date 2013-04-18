/* -------------------------------------------------------------------------- */
/* --- WCaml NSApplication Class                                          --- */
/* -------------------------------------------------------------------------- */

#import "CS.h"

@interface CSDelegate : NSObject
{ NSString * theAppName ; }
-(NSString *) appName;
@end

@interface CSApplication : NSApplication 
{ }
@end

