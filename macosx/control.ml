(* -------------------------------------------------------------------------- *)
(* --- Basic Control Widgets                                              --- *)
(* -------------------------------------------------------------------------- *)

open Event
open Widget
open Port

(* -------------------------------------------------------------------------- *)
(* --- Text Views                                                         --- *)
(* -------------------------------------------------------------------------- *)

module NSText =
struct
  type t
  let as_view : t -> NSView.t = Obj.magic
  external create : unit -> t = "wcaml_nstext_create"
  external set_editable : t -> bool -> unit = "wcaml_nstext_set_editable"
  external set_string : t -> NSString.t -> unit = "wcaml_nstext_set_string"
end

(* -------------------------------------------------------------------------- *)
(* --- Labels                                                             --- *)
(* -------------------------------------------------------------------------- *)

type align = [ `Left | `Right | `Center ]
type style = [ `Label | `Title | `Descr ]

let align = function `Left -> 0 | `Right -> 1 | `Center -> 2

class label ?text ?(align=`Left) ?(style=`Label) () =
  let w = NSText.create () in
object(self)
  inherit NSView.bundle (NSText.as_view w)
  method coerce = (self :> Widget.widget)
  method set_enabled (_:bool) = ()
  method set_text s = NSText.set_string w (NSString.of_string s)
  initializer 
    begin
      Event.option self#set_text text ;
      ignore align ;
      ignore style ;
    end
end

