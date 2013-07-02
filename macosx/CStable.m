// --------------------------------------------------------------------------
// --- NSTable Bindings                                                   ---
// --------------------------------------------------------------------------

#import "CS.h"
#import "CStable.h"

// --------------------------------------------------------------------------
// --- Table Clicks
// --------------------------------------------------------------------------

void wcaml_callback_clicked_header( NSTableColumn *column, BOOL double_click )
{
  static value *service = NULL;
  if (!service) service = caml_named_value("wcaml_nstable_header");
  if (!service) return;
  caml_callback2( *service , (value) column , Val_BOOL(double_click) );
}

void wcaml_callback_clicked_cell( NSTableColumn *column, NSInteger row, 
				  BOOL double_click )
{
  static value *service = NULL;
  if (!service) service = caml_named_value("wcaml_nstable_clicked");
  if (!service) return;
  caml_callback3( *service , (value) column , Val_int(row), 
		 Val_BOOL(double_click) );
}

void wcaml_nstable_clicked( NSTableView *table , BOOL double_click )
{
  NSInteger col = [table clickedColumn]; 
  if (col<0) return;
  NSTableColumn *column = [[table tableColumns] objectAtIndex:col];
  NSInteger row = [table clickedRow];
  if (row<0) {
    wcaml_callback_clicked_header(column,double_click);
  } else {
    wcaml_callback_clicked_cell(column,row,double_click);
  }
}

// --------------------------------------------------------------------------
// --- Cell Rendering
// --------------------------------------------------------------------------

NSInteger wcaml_callback_cell(NSTableColumn *tableColumn)
{
  static value *service = NULL;
  if (!service) service = caml_named_value("wcaml_nstable_cell");
  if (!service) return 0;
  value result = caml_callback( *service, (value) tableColumn );
  return Int_val(result);
}

void wcaml_callback_icon_cell
(NSTableColumn *tableColumn,NSImageView *cell,NSInteger row)
{
  static value *service = NULL;
  if (!service) service = caml_named_value("wcaml_nstable_icon_cell");
  if (!service) return;
  value result = caml_callback2( *service, (value) tableColumn, Val_int(row) );
  NSImage *img = ID(NSImage,result);
  [cell setImage:img];
}

void wcaml_callback_text_cell
(NSTableColumn *tableColumn,NSTextField *cell,NSInteger row)
{
  static value *service = NULL;
  if (!service) service = caml_named_value("wcaml_nstable_text_cell");
  if (!service) return;
  caml_callback3( *service, (value) tableColumn , (value) cell , Val_int(row) );
}

void wcaml_callback_itext_cell
(NSTableColumn *tableColumn,NSTableCellView *cell,NSInteger row)
{
  static value *service = NULL;
  if (!service) service = caml_named_value("wcaml_nstable_itext_cell");
  if (!service) return;
  NSImageView *image = [cell imageView];
  NSTextField *field = [cell textField];
  value params[4] = {
    (value) tableColumn,
    (value) image,
    (value) field,
    Val_int(row)
  };
  caml_callbackN( *service, 4 , params);
}

void wcaml_callback_check_cell
(NSTableColumn *tableColumn,NSButton *cell,NSInteger row)
{
  static value *service = NULL;
  if (!service) service = caml_named_value("wcaml_nstable_check_cell");
  if (!service) return;
  caml_callback3( *service, (value) tableColumn , (value) cell , Val_int(row) );
}

// --------------------------------------------------------------------------
// --- Cell Editing
// --------------------------------------------------------------------------

void wcaml_nstable_edited(NSTextField *field)
{
  static value *service = NULL;
  if (!service) service = caml_named_value("wcaml_nstable_edited_field");
  if (!service) return;
  caml_callback2( *service, (value) [field identifier], (value) field );
}

void wcaml_nstable_checked(NSButton *field)
{
  static value *service = NULL;
  if (!service) service = caml_named_value("wcaml_nstable_clicked_check");
  if (!service) return;
  caml_callback2( *service, (value) [field identifier], (value) field );
}

// --------------------------------------------------------------------------
// --- Cell Creation
// --------------------------------------------------------------------------

NSView *wcaml_nstable_render(NSTableView *tableView,
			     NSTableColumn* tableColumn,
			     NSInteger row)
{
  NSString *ident = [tableColumn identifier];
  NSInteger cellKind = wcaml_callback_cell(tableColumn);
  switch(cellKind) {
  case 1: // Image Cell
    {
      NSImageView *cell = [tableView makeViewWithIdentifier:ident owner:nil] ;
      if (!cell) {
	cell = [[[NSImageView alloc] init] autorelease];
	[cell setIdentifier:ident];
	[cell setImageFrameStyle:NSImageFrameNone];
      }
      wcaml_callback_icon_cell(tableColumn,cell,row);
      return cell;
    }
  case 2: // Text Cell
    {
      NSTextField *cell = [tableView makeViewWithIdentifier:ident owner:nil] ;
      if (!cell) {
	cell = [[[NSTextField alloc] init] autorelease];
	[cell setIdentifier:ident];
	[cell setBordered:NO];
	[cell setDrawsBackground:NO];
	[cell setAction:@selector(editedTextField:)];
	[cell setTarget:[CSTableModel sharedModel]];
      }
      wcaml_callback_text_cell(tableColumn,cell,row);
      return cell;
    }
  case 3: // IText Cell
    {
      NSTableCellView *cell = [tableView makeViewWithIdentifier:ident owner:nil] ;
      if (!cell) {
	cell = [[[NSTableCellView alloc] init] autorelease];
	NSImageView *image = [[[NSImageView alloc] init] autorelease];
	NSTextField *field = [[[NSTextField alloc] init] autorelease];
	[image setImageFrameStyle:NSImageFrameNone];
	[field setBordered:NO];
	[field setDrawsBackground:NO];
	[field setAction:@selector(editedTextField:)];
	[field setTarget:[CSTableModel sharedModel]];
	[cell setIdentifier:ident];
	[cell setTextField:field];
	[cell setImageView:image];
      }
      wcaml_callback_itext_cell(tableColumn,cell,row);
      return cell;
    }
  case 4: // Check Cell
    {
      NSButton *cell = [tableView makeViewWithIdentifier:ident owner:nil] ;
      if (!cell) {
	cell = [[[NSButton alloc] init] autorelease];
	[cell setButtonType:NSSwitchButton];
	[cell setIdentifier:ident];
	[cell setAction:@selector(clickedCheck:)];
	[cell setTarget:[CSTableModel sharedModel]];
      }
      wcaml_callback_check_cell(tableColumn,cell,row);
      return cell;
    }
  }
  return nil;
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

//---- Data Source
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
  static value *service = NULL;
  if (!service) service = caml_named_value("wcaml_nstable_list_size");
  if (service) {
    value r = caml_callback2( *service , (value) aTableView , Val_unit );
    return Int_val(r);
  }
  return 0;
}
// --- Clicked 
- (void) simpleClick:(id)sender
{
  wcaml_nstable_clicked( sender , NO );
}

- (void) doubleClick:(id)sender
{
  wcaml_nstable_clicked( sender , YES );
}

- (void) editedTextField:(id)sender
{
  wcaml_nstable_edited( sender );
}

- (void) clickedCheck:(id)sender
{
  wcaml_nstable_checked( sender );
}

//--- Delegate
- (NSView *)tableView:(NSTableView *)tableView 
   viewForTableColumn:(NSTableColumn *)tableColumn 
		  row:(NSInteger)row
{
  return wcaml_nstable_render(tableView,tableColumn,row);
}

@end

// --------------------------------------------------------------------------
// --- NSTableView                                                        ---
// --------------------------------------------------------------------------

value wcaml_nstable_create(value vid)
{
  NSTableView *table = [[NSTableView alloc] init];
  NSString *key = ID(NSString,vid);
  CSTableModel *model = [CSTableModel sharedModel];
  [table setDataSource:model];
  [table setDelegate:model];
  [table setAutosaveName:key];
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

value wcaml_nstable_selected_row(value vtable)
{
  NSTableView *table = ID(NSTableView,vtable);
  return Val_int([table selectedRow]);
}

value wcaml_nstable_reload(value vtable)
{
  NSTableView *table = ID(NSTableView,vtable);
  [table reloadData];
  return Val_unit;

}

value wcaml_nstable_update_all(value vtable)
{
  NSTableView *table = ID(NSTableView,vtable);
  [table setNeedsDisplay];
  return Val_unit;
}

value wcaml_nstable_update_row(value vtable,value vrow)
{
  NSTableView *table = ID(NSTableView,vtable);
  [table setNeedsDisplayInRect:[table rectOfRow:Int_val(vrow)]];
  return Val_unit;
}

value wcaml_nstable_added_row(value vtable,value vrow)
{
  NSTableView *table = ID(NSTableView,vtable);
  NSIndexSet *range = [NSIndexSet indexSetWithIndex:Int_val(vrow)];
  [table insertRowsAtIndexes:range withAnimation:NSTableViewAnimationSlideDown];
  return Val_unit;
}

value wcaml_nstable_removed_row(value vtable,value vrow)
{
  NSTableView *table = ID(NSTableView,vtable);
  NSIndexSet *range = [NSIndexSet indexSetWithIndex:Int_val(vrow)];
  [table removeRowsAtIndexes:range withAnimation:NSTableViewAnimationSlideUp];
  return Val_unit;
}

value wcaml_nstable_scroll(value vtable,value vrow)
{
  NSTableView *table = ID(NSTableView,vtable);
  [table scrollRowToVisible:Int_val(vrow)];
  return Val_unit;
}

// --------------------------------------------------------------------------
// --- NSTableColumn                                                      ---
// --------------------------------------------------------------------------

value wcaml_nstablecolumn_create(value vtable,value vid)
{
  NSTableView *table = ID(NSTableView,vtable);
  NSString *key = ID(NSString,vid);
  NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:key];
  [table setAutosaveTableColumns:NO];
  [table addTableColumn:column];
  [table setAutosaveTableColumns:YES];
  return (value) column;
}

value wcaml_nstablecolumn_remove(value vtable,value vcolumn)
{
  NSTableView *table = ID(NSTableView,vtable);
  NSTableColumn *column = ID(NSTableColumn,vcolumn);
  [table removeTableColumn:column];
  return Val_unit;
}

value wcaml_nstablecolumn_set_title(value vcolumn,value vtitle)
{
  NSTableColumn *column = ID(NSTableColumn,vcolumn);
  NSString *title = ID(NSString,vtitle);
  [[column headerCell] setStringValue:title];
  return Val_unit;
}

value wcaml_nstablecolumn_set_align(value vcolumn,value valign)
{
  NSTableColumn *column = ID(NSTableColumn,vcolumn);
  NSCell *cell = [column headerCell];
  switch(Int_val(valign)) {
  case 1: [cell setAlignment:NSLeftTextAlignment]; break;
  case 2: [cell setAlignment:NSCenterTextAlignment]; break;
  case 3: [cell setAlignment:NSRightTextAlignment]; break;
  }
  return Val_unit;
}
  
