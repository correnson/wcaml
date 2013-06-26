
(** Table Models *)

open Event
open Widget

(** {3 Cell Models} *)

class type text_cell =
object
  method set_text : string -> unit
  method set_style : Widget.style -> unit
  method set_align : Widget.align -> unit
  method set_fg : Widget.color -> unit
  method set_bg : Widget.color -> unit
end

class type itext_cell =
object
  method set_icon : icon -> unit
  inherit text_cell
end

class type check_cell =
object
  method set_check : bool -> unit
  method set_text : string -> unit
end

(** {3 Column Models} *)

type sorting = [ `Unsorted | `Ascending | `Descending ]

class type ['a] column =
object
  method remove : unit
  method set_title : string -> unit
  method update : 'a -> unit
  method update_all : unit -> unit
  method sorting : sorting Event.selector
  method on_header : unit callback
  method on_click : 'a callback
  method on_double_click : 'a callback
end

class type ['a] text_column = 
object
  inherit ['a] column
  method set_align : Widget.align -> unit
  method set_style : Widget.style -> unit
  method set_renderer : (text_cell -> 'a -> unit) -> unit
  method set_editable : ('a -> string -> unit) -> unit
end

class type ['a] itext_column = 
object
  inherit ['a] column
  method set_align : Widget.align -> unit
  method set_style : Widget.style -> unit
  method set_renderer : (itext_cell -> 'a -> unit) -> unit
  method set_editable : ('a -> string -> unit) -> unit
end

class type ['a] icon_column = 
object
  inherit ['a] column
  method set_renderer : ('a -> icon) -> unit
end

class type ['a] check_column = 
object
  inherit ['a] column
  method set_renderer : (check_cell -> 'a -> unit) -> unit
  method set_editable : ('a -> bool -> unit) -> unit
end

(** {3 Table Models} *)

(** List Model *)
class type ['a] list =
object
  method size : int (** Number of items. *)
  method get : int -> 'a (** Array-index. *)
  method index : 'a -> int (** May return [Not_found]. *)
end

(** Tree Model *)
class type ['a] tree =
object
  method children : 'a option -> int 
    (** Number of children. [None] means root.
	Should be {i strictly} negative for non-nodes (leaves), 
	and [0] for nodes with no-children. *)
  method child_at : 'a option -> int -> 'a
    (** Only invoked whith array-index less than [children]. *)
  method parent : 'a -> 'a option 
    (** None for root. May return [Not_found]. *)
  method index : 'a -> int 
    (** Among parent's children. May return [Not_found]. *)
end

(** {3 View Model} *)

(** Column View Constructor *)
type 'a cview = id:string -> ?title:string -> unit -> 'a

(** Table View Interface *)
class type ['a] view =
object
  inherit Widget.pane

  (** {2 Model Change Notifications} 
      These methods {i must} be invoked whenever the model changed. *)

  method reload : 'a option -> unit
  method update : 'a -> unit
  method update_all : unit -> unit
  method added : 'a -> unit
  method removed : 'a -> unit

  (** {2 Column Views} *)

  method add_icon_column : 'a icon_column cview
  method add_text_column : 'a text_column cview
  method add_tree_column : 'a itext_column cview
  method add_itext_column : 'a itext_column cview
  method add_check_column : 'a check_column cview

  method remove_colum : 'a column -> unit

  (** {2 User Interaction} *)

  method scroll : 'a -> unit
  method on_click : 'a callback
  method on_double_click : 'a callback

end
