// --------------------------------------------------------------------------
// --- NSTable Bindings                                                   ---
// --------------------------------------------------------------------------

#import "CS.h"
#import "CStable.h"

// --------------------------------------------------------------------------
// --- Cell Callbacks
// --------------------------------------------------------------------------

NSInteger wcaml_callback_cell(NSTableColumn *tableColumn)
{
  static value *service = NULL;
  if (!service) service = caml_named_value("nstable_cell");
  if (!service) return 0;
  value result = caml_callback( *service, (value) tableColumn );
  return Int_val(result);
}

void wcaml_callback_icon_cell
(NSTableColumn *tableColumn,NSImageView *cell,NSInteger row)
{
  static value *service = NULL;
  if (!service) service = caml_named_value("nstable_icon_cell");
  if (!service) return;
  //--- TODO
}

void wcaml_callback_text_cell
(NSTableColumn *tableColumn,NSTextField *cell,NSInteger row)
{
  static value *service = NULL;
  if (!service) service = caml_named_value("nstable_text_cell");
  if (!service) return;
  caml_callback3( *service, (value) tableColumn , (value) cell , Val_int(row) );
}

void wcaml_callback_itext_cell
(NSTableColumn *tableColumn,NSTableCellView *cell,NSInteger row)
{
  static value *service = NULL;
  if (!service) service = caml_named_value("nstable_itext_cell");
  if (!service) return;
  caml_callback3( *service, (value) tableColumn , (value) cell , Val_int(row) );
}

void wcaml_callback_check_cell
(NSTableColumn *tableColumn,NSButton *cell,NSInteger row)
{
  static value *service = NULL;
  if (!service) service = caml_named_value("nstable_check_cell");
  if (!service) return;
  caml_callback3( *service, (value) tableColumn , (value) cell , Val_int(row) );
}

// --------------------------------------------------------------------------
// --- Table DataSource & Delegate
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
  if (!service) service = caml_named_value("nstable_items");
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

//--- Delegate
- (NSView *)tableView:(NSTableView *)tableView 
   viewForTableColumn:(NSTableColumn *) tableColumn 
		  row:(NSInteger)row
{
  NSInteger cellKind = wcaml_callback_cell(tableColumn);
  switch(cellKind) {
  case 1: // Image Cell
    {
      NSImageView *cell = [tableView makeViewWithIdentifier:@"icon" owner:self] ;
      if (!cell) cell = [[[NSImageView alloc] init] autorelease];
      wcaml_callback_icon_cell(tableColumn,cell,row);
      return cell;
    }
  case 2: // Text Cell
    {
      NSTextField *cell = [tableView makeViewWithIdentifier:@"text" owner:self] ;
      if (!cell) cell = [[[NSTextField alloc] init] autorelease];
      wcaml_callback_text_cell(tableColumn,cell,row);
      return cell;
    }
  case 3: // IText Cell
    {
      NSTableCellView *cell = [tableView makeViewWithIdentifier:@"itext" owner:self] ;
      if (!cell) cell = [[[NSTableCellView alloc] init] autorelease];
      wcaml_callback_itext_cell(tableColumn,cell,row);
      return cell;
    }
  case 4: // Check Cell
    {
      NSButton *cell = [tableView makeViewWithIdentifier:@"check" owner:self] ;
      if (!cell) {
	cell = [[[NSButton alloc] init] autorelease];
	[cell setButtonType:NSSwitchButton];
      }
      wcaml_callback_check_cell(tableColumn,cell,row);
      return cell;
    }
  }
  return nil;
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
  
