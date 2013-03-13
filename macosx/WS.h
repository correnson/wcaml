//------------------------------------
//--- Caml Interface
//------------------------------------
#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/alloc.h>
#include <caml/custom.h>
#include <caml/fail.h>
#include <caml/callback.h>
//------------------------------------
// Macro alloc in callback.h clashes with selector malloc in Objective-C
#undef alloc
// Previous definition of unit64 in Cocoa Frameworks
#define _UINT64
//------------------------------------
#include <Cocoa/Cocoa.h>
//------------------------------------
//--- Usefull Macros
//------------------------------------
#define CS_ID(CNAME,vid) ((CNAME*) (vid))
#define CS_BOOL(v) ( (v) == Val_true ? YES : NO )
//------------------------------------
