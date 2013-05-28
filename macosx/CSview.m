/* -------------------------------------------------------------------------- */
/* --- NSView Port                                                        --- */
/* -------------------------------------------------------------------------- */

#import "CS.h"

value wcaml_nsview_create(value vunit)
{
  NSView *box = [[NSView alloc] init];
  [box setTranslatesAutoresizingMaskIntoConstraints:YES];
  return (value) box;
}

value wcaml_nsview_set_tooltip(value vcell,value vtooltip)
{
  [ID(NSView,vcell) setToolTip:ID(NSString,vtooltip)];
  return Val_unit ;
}

value wcaml_nsview_add_subview(value vbox,value vitem)
{
  NSView *box = ID(NSView,vbox);
  NSView *item = ID(NSView,vitem);
  [box addSubview:item];
  return Val_unit;
}

value wcaml_nsview_has_baseline(value vitem)
{
  CGFloat baseline = [ID(NSView,vitem) baselineOffsetFromBottom];
  return VBOOL( baseline );
}

value wcaml_nsview_set_layout(value vbox,
			      value vlayout,
			      value vitem_a,
			      value vitem_b,
			      value vconstant)
{
  NSView *box = ID(NSView,vbox);
  NSView *view_a = ID(NSView,vitem_a);
  NSView *view_b = ID(NSView,vitem_b);
  //----------------------------------------------------------------------------
  int layout = Int_val(vlayout);
  NSView *item_1, *item_2;    // 2 is bigger than 1 
  NSInteger attr_1,attr_2;  // H:1-2 or V:1-2 in natural coordinates
  NSLayoutRelation relation ;
  NSLayoutPriority priority ;
  CGFloat constant = (CGFloat) Int_val(vconstant) ;
  //---- Dispatch for Layouts --------------------------------------------------

  //--- Relation  
  relation = (layout & 0x01) 
    ? NSLayoutRelationGreaterThanOrEqual 
    : NSLayoutRelationEqual ;

  //--- Priority
  priority = (layout & 0x01)
    ? NSLayoutPriorityDragThatCanResizeWindow
    : NSLayoutPriorityRequired ;

  //---- Attributes
  switch( layout & 0x0E ) { // 0b1110 Mask

  case 0x00: // 0b0000 --- Horizontal [a-b] in left-to-right order
    if (!view_a || !view_b) return Val_unit;
    item_1 = view_a ;
    attr_1 = (box == view_a) ? NSLayoutAttributeLeft : NSLayoutAttributeRight ;
    item_2 = view_b ;
    attr_2 = (box == view_b) ? NSLayoutAttributeRight : NSLayoutAttributeLeft ;
    break;

  case 0x02: // 0b0010 --- Vertical [a-b] in top-to-bottom order
    if (!view_a || !view_b) return Val_unit;
    item_1 = view_a ;
    attr_1 = (box == view_a) ? NSLayoutAttributeTop : NSLayoutAttributeBottom ;
    item_2 = view_b ;
    attr_2 = (box == view_b) ? NSLayoutAttributeBottom : NSLayoutAttributeTop ;
    break;

  case 0x04: // 0b0100 --- Left-Alignment
    if (!view_a || !view_b) return Val_unit;
    item_1 = view_a ; item_2 = view_b ;
    attr_1 = attr_2 = NSLayoutAttributeLeft ;
    break;

  case 0x06: // 0b0110 --- Baseline
    if (!view_a || !view_b) return Val_unit;
    item_1 = view_a ; item_2 = view_b ;
    attr_1 = attr_2 = NSLayoutAttributeBaseline ;
    break;

  case 0x08: // 0b1000 --- Width
    if (!view_a) return Val_unit;
    item_2 = view_a ;
    attr_2 = NSLayoutAttributeWidth ;
    item_1 = view_b ; 
    attr_1 = view_b ? NSLayoutAttributeWidth : NSLayoutAttributeNotAnAttribute ;
    break;
    
  default:
    return Val_unit;
  }
  
  //---- Register the Constraint -----------------------------------------------
  NSLayoutConstraint *constraint = 
    [NSLayoutConstraint constraintWithItem:item_2
				 attribute:attr_2
				 relatedBy:relation
				    toItem:item_1
				 attribute:attr_1
				multiplier:1.0
				  constant:constant];
  [box addConstraint:constraint];
  return Val_unit;
}

value wcaml_nsview_debug(value vitem)
{
  NSView *item = ID(NSView,vitem);
  NSArray *h = 
    [item constraintsAffectingLayoutForOrientation:
	    NSLayoutConstraintOrientationVertical];
  NSArray *v =
    [item constraintsAffectingLayoutForOrientation:
	    NSLayoutConstraintOrientationHorizontal];
  [[item window] visualizeConstraints:[h arrayByAddingObjectsFromArray:v]];
}

