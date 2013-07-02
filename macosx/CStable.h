// --------------------------------------------------------------------------
// --- NSTableView DataSource and Delegate
// --------------------------------------------------------------------------

@interface CSTableModel : 
  NSObject < NSTableViewDataSource,NSTableViewDelegate > ;

//--- Shared
+ (CSTableModel*)sharedModel;


//--- DataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView;
//--- Actions
- (void) simpleClick:(id)sender;
- (void) doubleClick:(id)sender;
- (void) editedTextField:(id)sender; // A TextField

//--- Delegate
- (NSView *)tableView:(NSTableView *)tableView 
   viewForTableColumn:(NSTableColumn *) tableColumn 
		  row:(NSInteger)row;

@end
