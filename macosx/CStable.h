// --------------------------------------------------------------------------
// --- NSTableView DataSource and Delegate
// --------------------------------------------------------------------------

@interface CSTableModel : NSObject < NSTableViewDataSource > ;
+ (CSTableModel*)sharedModel;
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView;
- (id)             tableView:(NSTableView *)aTableView 
   objectValueForTableColumn:(NSTableColumn *)aTableColumn 
			 row:(NSInteger)rowIndex;
@end
