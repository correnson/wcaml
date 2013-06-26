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

//--- Actions
- (void) simpleClick:(id)sender;
- (void) doubleClick:(id)sender;
- (void) editedTextField:(id)sender; // A TextField

//--- Delegate
- (NSView *)tableView:(NSTableView *)tableView 
   viewForTableColumn:(NSTableColumn *) tableColumn 
		  row:(NSInteger)row;

@end
