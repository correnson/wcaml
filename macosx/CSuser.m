/* -------------------------------------------------------------------------- */
/* --- User Preferences                                                   --- */
/* -------------------------------------------------------------------------- */

#import "CSuser.h"

value wcaml_set_user_object(value nskey,value nsval)
{
  [[NSUserDefaults standardUserDefaults] 
    setObject:(id)nsval 
       forKey:ID(NSString,nskey)];
}

value wcaml_get_user_nsstring(value nskey)
{
  return (value) [[NSUserDefaults standardUserDefaults] 
		   stringForKey:ID(NSString,nskey)] ;
}

value wcaml_get_user_nsarray(value nskey)
{
  return (value) [[NSUserDefaults standardUserDefaults] 
		   arrayForKey:ID(NSString,nskey)] ;
}

