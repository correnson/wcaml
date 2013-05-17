(* -------------------------------------------------------------------------- *)
(* --- Basic Control Widgets                                              --- *)
(* -------------------------------------------------------------------------- *)

open Event
open Widget
open Port
open Portcontrol

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
  inherit NSView.view (NSText.as_view w)
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

(* -------------------------------------------------------------------------- *)
(* --- Button                                                             --- *)
(* -------------------------------------------------------------------------- *)

class button ?label ?tooltip ?callback () =
  let w = NSButton.create 0 in
object(self)
  inherit NSControl.control ?tooltip (NSButton.as_control w) as control
  inherit! [unit] Event.signal as signal
  method! set_enabled e = control#set_enabled e ; signal#set_enabled e
  method set_label s = 
    NSCell.set_title (NSButton.as_cell w) (NSString.of_string s)
  initializer 
    begin
      NSControl.bind (NSButton.as_control w) signal#fire ;
      Event.option signal#connect callback ;
      Event.option self#set_label label ;
    end
end

(* -------------------------------------------------------------------------- *)
(* --- Check Box                                                          --- *)
(* -------------------------------------------------------------------------- *)

class checkbox ?label ?tooltip ?(value=false) () =
  let w = NSButton.create 1 in
object(self)
  inherit NSControl.control ?tooltip (NSButton.as_control w) as control
  inherit! [bool] Event.selector value as state
  method! set_enabled e = control#set_enabled e ; state#set_enabled e
  method! set e = state#set e ; NSCell.set_state (NSButton.as_cell w) e
  method private updated () = state#set (NSCell.get_state (NSButton.as_cell w))
  method set_label s = 
    NSCell.set_title (NSButton.as_cell w) (NSString.of_string s)
  initializer 
    begin
      NSControl.bind (NSButton.as_control w) self#updated ;
      Event.option self#set_label label ;
    end
end

(* -------------------------------------------------------------------------- *)
(* --- Radio Groups                                                       --- *)
(* -------------------------------------------------------------------------- *)

class ['a] radio ?label ?tooltip ?group ?value () =
  let w = NSButton.create 2 in
object(self)
  inherit NSControl.control ?tooltip (NSButton.as_control w) as control
  method set_label s = 
    NSCell.set_title (NSButton.as_cell w) (NSString.of_string s)
  val mutable select : 'a selector option  = None
  val mutable option : 'a option = value

  method set_group g = select <- Some g ; self#update () ; g#on_event self#update
  method set_value v = option <- Some v ; self#update ()

  method private clicked () = match select , option with
    | Some g , Some v -> g#set v
    | _ -> ()

  method private update () =
    let st = match select , option with
      | Some g , Some v -> g#get = v
      | _ -> false
    in NSCell.set_state (NSButton.as_cell w) st

  initializer 
    begin
      NSControl.bind (NSButton.as_control w) self#clicked ;
      Event.option self#set_label label ;
      Event.option self#set_group group ;
    end
end

