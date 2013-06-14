// --------------------------------------------------------------------------
// --- CSSignal Target
// --------------------------------------------------------------------------

@interface CSSignal : NSObject ;
+ (CSSignal*)sharedTarget;
- (void)fireSignal:(id)sender;
@end
