#import "CSdata.h"

value wcaml_nil(value vunit)
{
  return (value) nil;
}

// --------------------------------------------------------------------------
// --- NSString                                                           ---
// --------------------------------------------------------------------------

value wcaml_value_of_nsstring(NSString *theText)
{
  CAMLparam0();
  const char * str = nil ;
  static char * nullstr = "" ;
  value result ;
  str = [theText UTF8String] ;
  if (str)
    { result = caml_copy_string(str); }
  else
    { result = caml_copy_string(nullstr); }
  CAMLreturn( result );
}

NSString* wcaml_nsstring_of_value(value v_str)
{
  return [[[NSString alloc] initWithUTF8String:String_val(v_str)] autorelease];
}

// --------------------------------------------------------------------------
// --- NSArray                                                           ---
// --------------------------------------------------------------------------

value wcaml_nsarray_init(value vcapacity)
{
  NSArray * array = [NSMutableArray arrayWithCapacity:Int_val(vcapacity)];
  return (value) [array autorelease];
}

value wcaml_nsarray_count(value varray)
{
  return Int_val([ID(NSMutableArray,varray) count]);
}

value wcaml_nsarray_add(value varray,value velt)
{
  [ID(NSMutableArray,varray) addObject:(id)velt];
  return Val_unit;
}

value wcaml_nsarray_get(value varray,value vindex)
{
  return (value) [ID(NSMutableArray,varray) objectAtIndex:Int_val(vindex)];
}

value wcaml_nsarray_set(value varray,value vindex,value velt)
{
  [ID(NSMutableArray,varray)
      replaceObjectAtIndex:Int_val(vindex) withObject:(id)velt];
  return Val_unit;
}
