/* -------------------------------------------------------------------------- */
/* --- Text Views Port                                                    --- */
/* -------------------------------------------------------------------------- */

#import "CStext.h"

value wcaml_nstextview_create(value vunit)
{
  NSTextView *textView = [[NSTextView alloc] 
			   initWithFrame:NSMakeRect(0,0,200,500)];

  [textView setMinSize:NSMakeSize(32.0,64.0)];
  [textView setMaxSize:NSMakeSize(FLT_MAX, FLT_MAX)];
  [textView setVerticallyResizable:YES];
  [textView setHorizontallyResizable:YES];
  [textView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
  [textView setRichText:YES];
  [textView setImportsGraphics:NO];
  [[textView textContainer] setContainerSize:NSMakeSize(FLT_MAX, FLT_MAX)];
  [[textView textContainer] setHeightTracksTextView:NO];
  return (value) textView;
}

value wcaml_nstextview_scroll(value vtext)
{
  NSTextView *textView = ID(NSTextView,vtext);
  NSScrollView *scrollView = [[NSScrollView alloc] init];
  [scrollView setBorderType:NSNoBorder];
  [scrollView setHasVerticalScroller:YES];
  [scrollView setHasHorizontalScroller:YES];
  [scrollView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
  [scrollView setDocumentView:textView];
  return (value) (NSView *) scrollView;
}

value wcaml_nstextview_text_content(value vtext)
{
  NSTextView *textView = ID(NSTextView,vtext);
  [textView setFont:[NSFont fontWithName:@"Cambria" size:10.0]];
  [[textView textContainer] setWidthTracksTextView:YES];
  return Val_unit;
}

value wcaml_nstextview_code_content(value vtext)
{
  NSTextView *textView = ID(NSTextView,vtext);
  [textView setFont:[NSFont fontWithName:@"Monospace" size:10.0]];
  [[textView textContainer] setContainerSize:NSMakeSize(FLT_MAX, FLT_MAX)];
  [[textView textContainer] setWidthTracksTextView:NO];
  return Val_unit;
}

value wcaml_nstextview_set_editable(value vtext,value vedit)
{
  [ID(NSTextView,vtext) setEditable:BOOL(vedit)];
  return Val_unit;
}

value wcaml_nstextview_length(value vtext)
{
  NSTextView *textView = ID(NSTextView,vtext);
  NSInteger n = [[textView textStorage] length];
  return Val_int(n);
}

value wcaml_nstextview_clear(value vtext)
{
  NSTextView *textView = ID(NSTextView,vtext);
  NSTextStorage *textStorage = [textView textStorage];
  [textStorage deleteCharactersInRange:NSMakeRange(0,[textStorage length])];
  return Val_unit;
}

value wcaml_nstextview_replace
(value vtext,value vinsert,value vdelete,value vstring)
{
  NSTextView *textView = ID(NSTextView,vtext);
  NSString *string = ID(NSString,vstring);
  NSRange range = NSMakeRange(Int_val(vinsert),Int_val(vdelete));
  [[textView textStorage] replaceCharactersInRange:range withString:string];
  return Val_unit;
}
