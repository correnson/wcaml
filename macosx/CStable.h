// --------------------------------------------------------------------------
// --- NSTableView DataSource and Delegate
// --------------------------------------------------------------------------

@interface CSTableModel : 
  NSObject < NSTableViewDataSource,NSTableViewDelegate > ;

//--- Shared
+ (CSTableModel*)sharedModel;


//--- DataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView;
- (id)            tableView:(NSTableView *)aTableView 
  objectValueForTableColumn:(NSTableColumn *)aTableColumn 
			row:(NSInteger)rowIndex;

//--- Delegate
- (NSView *)tableView:(NSTableView *)tableView 
   viewForTableColumn:(NSTableColumn *) tableColumn 
		  row:(NSInteger)row;

@end
