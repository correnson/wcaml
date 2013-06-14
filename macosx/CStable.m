// --------------------------------------------------------------------------
// --- NSTable Bindings                                                   ---
// --------------------------------------------------------------------------

#import "CS.h"

// --------------------------------------------------------------------------
// --- Table DataSource & Delegate                                        ---
// --------------------------------------------------------------------------

@implementation CSTableModel

static CSTableModel * model = nil ;

+ (CSTableModel*)sharedModel
{
  if (!model) model = [[CSTableModel alloc] init];
  return model;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
  static value *service = NULL;
  if (!service) service = caml_named_value("nstable_list_size");
  if (service) {
    value r = caml_callback2( *service , (value) aTableView , Val_unit );
    return Int_val(r);
  }
  return 0;
}

- (id)             tableView:(NSTableView *)aTableView 
   objectValueForTableColumn:(NSTableColumn *)aTableColumn 
			 row:(NSInteger)rowIndex
{
  return (id) rowIndex;
}

@end

// --------------------------------------------------------------------------
// --- NSTableView                                                        ---
// --------------------------------------------------------------------------

value wcaml_nstable_create(value vid)
{
  NSTableView *table = [[NSTableView alloc] init];
  NSString *key = ID(NSString,vid);
  [table setDataSource:[CSTableModel sharedModel]];
  [table setAutosaveName:key];
  [table setAutosaveTableColumns:YES];
  return (value) table;
}

value wcaml_nstable_set_headers(value vtable)
{
  NSTableView *table = ID(NSTableView,vtable);
  NSTableHeaderView *header = [[NSTableHeaderView alloc] init];
  [table setHeaderView:header];
  return Val_unit;
}

value wcaml_nstable_set_rules(value vtable,value vrules)
{
  NSTableView *table = ID(NSTableView,vtable);
  [table setUsesAlternatingRowBackgroundColors:BOOL(vrules)];
}

// --------------------------------------------------------------------------
// --- NSTableColumn                                                      ---
// --------------------------------------------------------------------------

value wcaml_nstablecolumn_create(value vtable,value vid)
{
  NSTableView *table = ID(NSTableView,vtable);
  NSString *key = ID(NSString,vid);
  NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:key];
  return (value) column;
}

value wcaml_nstablecolumn_set_title(value vcolumn,value vtitle)
{
  NSTableColumn *column = ID(NSTableColumn,vcolumn);
  NSString *title = ID(NSString,vtitle);
  [[column headerCell] setString:title];
  return Val_unit;
}
  
