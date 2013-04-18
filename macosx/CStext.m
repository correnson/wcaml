#import "CStext.h"

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

NSString* wcaml_nsstring_create(value v_str)
{
  return [[NSString alloc]
	       initWithCString:(String_val(v_str))
		      encoding:NSUnicodeStringEncoding] ;
}
