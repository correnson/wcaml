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
  external set_attribute : t -> int -> unit = "wcaml_nstext_set_attribute"
  let attribute = function
    | `Left -> 1
    | `Right -> 2
    | `Center -> 3
    | `Label -> 4
    | `Title -> 5
    | `Descr -> 6
  let set_attribute w a = set_attribute w (attribute a)
end

(* -------------------------------------------------------------------------- *)
(* --- Labels                                                             --- *)
(* -------------------------------------------------------------------------- *)

type align = [ `Left | `Right | `Center ]
type style = [ `Label | `Title | `Descr ]

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
      NSText.set_attribute w align ;
      NSText.set_attribute w style ;
    end
end

