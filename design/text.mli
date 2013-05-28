(** Text Editor Widgets *)

open Event
open Widget

type 'a printf = ('a,Format.formatter,unit) format -> 'a

class textpane : ?editable:bool -> unit ->
object
  inherit Widget.pane
  method set_editable : bool -> unit
  method size : int
  method clear : unit -> unit
  method printf : 'a. ?at:int -> ?length:int -> 'a printf  
end

