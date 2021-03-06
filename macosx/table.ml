(* -------------------------------------------------------------------------- *)
(* --- Table Cocoa Port                                                   --- *)
(* -------------------------------------------------------------------------- *)

open Widget
open Event
open Model
open Port
open Portcontrol

(* -------------------------------------------------------------------------- *)
(* --- NSTable View                                                       --- *)
(* -------------------------------------------------------------------------- *)

module NSTable =
struct
  type t
  let as_view : t -> NSView.t = Obj.magic
  external create : NSString.t -> t = "wcaml_nstable_create"
  external set_rules : t -> bool -> unit = "wcaml_nstable_set_rules"
  external set_headers : t -> unit = "wcaml_nstable_set_headers"
  external selected_row : t -> int = "wcaml_nstable_selected_row"
  external reload : t -> unit = "wcaml_nstable_reload"
  external update_all : t -> unit = "wcaml_nstable_update_all"
  external update_row : t -> int -> unit = "wcaml_nstable_update_row"
  external added_row : t -> int -> unit = "wcaml_nstable_added_row"
  external removed_row : t -> int -> unit = "wcaml_nstable_removed_row"
  external scroll : t -> int -> unit = "wcaml_nstable_scroll"
end

module NSTableColumn =
struct
  type t
  external create : NSTable.t -> NSString.t -> t = "wcaml_nstablecolumn_create"
  external remove : NSTable.t -> t -> unit = "wcaml_nstablecolumn_remove"
  external set_title : t -> NSString.t -> unit = "wcaml_nstablecolumn_set_title"
  external set_align : t -> int -> unit = "wcaml_nstablecolumn_set_align"
  let set_align col = function
    | `Left -> set_align col 1
    | `Center -> set_align col 2
    | `Right -> set_align col 3
end

(* -------------------------------------------------------------------------- *)
(* --- Model Services                                                     --- *)
(* -------------------------------------------------------------------------- *)

module ListSize = NSCallback
  (struct
     let name = "wcaml_nstable_list_size"
     type nsobject = NSTable.t
     type signature = unit -> int
     let default () = 0
   end)

(* -------------------------------------------------------------------------- *)
(* --- Cell Services                                                      --- *)
(* -------------------------------------------------------------------------- *)

let kIconCell = 1
let kTextCell = 2
let kITextCell = 3
let kCheckCell = 4

module CellKind = NSCallback
  (struct
     let name = "wcaml_nstable_cell"
     type nsobject = NSTableColumn.t
     type signature = int
     let default = 0
   end)

module IconCell = NSCallback
  (struct
     let name = "wcaml_nstable_icon_cell"
     type nsobject = NSTableColumn.t
     type signature = int -> NSImage.t
     let default (_:int) = Port.nil
   end)

module TextCell = NSCallback
  (struct
     let name = "wcaml_nstable_text_cell"
     type nsobject = NSTableColumn.t
     type signature = NSTextField.t -> int -> unit
     let default : signature = fun _ _ -> ()
   end)

module ITextCell = NSCallback
  (struct
     let name = "wcaml_nstable_itext_cell"
     type nsobject = NSTableColumn.t
     type signature = NSImageView.t -> NSTextField.t -> int -> unit
     let default : signature = fun _ _ _ -> ()
   end)

module CheckCell = NSCallback
  (struct
     let name = "wcaml_nstable_check_cell"
     type nsobject = NSTableColumn.t
     type signature = NSCell.t -> int -> unit
     let default : signature = fun _ _ -> ()
   end)

module EditedField = IDCallback
  (struct
     let name = "wcaml_nstable_edited_field"
     type signature = NSTextField.t -> unit
     let default : signature = fun _ -> ()
   end)

module ClickedCheck = IDCallback
  (struct
     let name = "wcaml_nstable_clicked_check"
     type signature = NSCell.t -> unit
     let default : signature = fun _ -> ()
   end)

(* -------------------------------------------------------------------------- *)
(* --- Columns                                                            --- *)
(* -------------------------------------------------------------------------- *)

class type ['a] custom =
object
  method get : int -> 'a
  method index : 'a -> int
end

class ['a] gcolumn wtable kind ~tid ~cid ?title () =
  let id = Printf.sprintf "%s.%s" tid cid in
  let wcol = NSTableColumn.create wtable (NSString.of_string id) in
  let s = new Event.selector `Unsorted in
object(self)
  method set_title t = NSTableColumn.set_title wcol (NSString.of_string t)
  method set_align a = NSTableColumn.set_align wcol (a : align)

  method update (_:'a) = ()
  method update_all () = ()
  method sorting : sorting selector = s
  method on_header : unit callback = s#on_value `Unsorted
  method on_click : 'a callback = fun _ -> ()
  method on_double_click : 'a callback = fun _ -> ()
    
  initializer 
    begin
      Event.option self#set_title title ;
      CellKind.bind wcol kind ;
    end

  method remove =
    begin
      CellKind.remove wcol ;
      NSTableColumn.remove wtable wcol ;
    end

  method wcolumn = wcol
  method id = id

end

(* -------------------------------------------------------------------------- *)
(* --- Icon Columns                                                       --- *)
(* -------------------------------------------------------------------------- *)

class ['a] gicon_column ~wtable ~(custom : 'a #custom) ~tid ~cid ?title () =
object(self)
  inherit ['a] gcolumn wtable kIconCell ~tid ~cid ?title () as super

  val mutable renderer : ('a -> Widget.icon) = fun _ -> `NoIcon
  method set_renderer f = renderer <- f

  initializer 
    IconCell.bind super#wcolumn self#render
    
  method! remove = 
    begin 
      super#remove ; 
      IconCell.remove super#wcolumn ;
    end
    
  method render row = 
    let icon = try renderer (custom#get row) with Not_found -> `NoIcon in
    NSImage.icon icon
end

(* -------------------------------------------------------------------------- *)
(* --- Text Cells                                                         --- *)
(* -------------------------------------------------------------------------- *)

class gtext_cell ~field ~editable ~style ~align = 
object
  val mutable vtext = ""
  val mutable valign : Widget.align = align
  val mutable vstyle : Widget.style = style
    (*TODO: Color *)
  method set_text txt = vtext <- txt
  method set_style sty = vstyle <- sty
  method set_align aln = valign <- aln
  method set_fg (_ : Widget.color) = ()
  method set_bg (_ : Widget.color) = ()
  method apply =
    begin
      NSTextField.set_attribute field (valign :> NSTextField.attr) ;
      NSTextField.set_attribute field (vstyle :> NSTextField.attr) ;
      NSTextField.set_attribute field (if editable then `Editable else `Static) ;
      NSTextField.set_text field (NSString.of_string vtext) ;
    end
end

(* -------------------------------------------------------------------------- *)
(* --- Text Columns                                                       --- *)
(* -------------------------------------------------------------------------- *)

class ['a] gtext_column ~wtable ~(custom : 'a #custom) ~tid ~cid ?title () =
object(self)
  inherit ['a] gcolumn wtable kTextCell ~tid ~cid ?title () as super

  val mutable renderer : Model.text_cell -> 'a -> unit = fun _ _ -> ()
  val mutable listener : 'a -> string -> unit = fun _ _ -> ()
  val mutable editable = false
  method set_renderer f = renderer <- f
  method set_editable f = 
    begin
      listener <- f ;
      editable <- true ;
    end

  initializer 
    begin
      TextCell.bind super#wcolumn self#render ;
      EditedField.bind super#id self#edited ;
    end

  method! remove = 
    begin
      super#remove ;
      TextCell.remove super#wcolumn ;
      EditedField.remove super#id ;
    end

  val mutable style : Widget.style = `Label
  val mutable align : Widget.align = `Left
    
  method set_style sty = style <- sty
  method! set_align aln = align <- aln ; super#set_align aln

  method edited field =
    try
      let row = NSTable.selected_row wtable in
      let item = custom#get row in
      listener item (NSString.to_string (NSTextField.get_text field))
    with Not_found -> ()

  method render field row = 
    try 
      let item = custom#get row in
      let cell = new gtext_cell ~field ~editable ~style ~align in
      renderer (cell :> Model.text_cell) item ;
      cell#apply
    with Not_found -> ()

end

(* -------------------------------------------------------------------------- *)
(* --- Icon & Text Cells                                                  --- *)
(* -------------------------------------------------------------------------- *)

class gitext_cell ~field ~image ~editable ~style ~align = 
object
  inherit gtext_cell ~editable ~style ~align ~field as super
  val mutable vicon : Widget.icon = `NoIcon
  method set_icon icn = vicon <- icn
  method! apply = 
    begin
      NSImageView.set_image image (NSImage.icon vicon) ;
      super#apply ;
    end
end

(* -------------------------------------------------------------------------- *)
(* --- IText Columns                                                      --- *)
(* -------------------------------------------------------------------------- *)

class ['a] gitext_column ~wtable ~(custom : 'a #custom) ~tid ~cid ?title () =
object(self)
  inherit ['a] gcolumn wtable kITextCell ~tid ~cid ?title () as super

  val mutable renderer : Model.itext_cell -> 'a -> unit = fun _ _ -> ()
  val mutable listener : 'a -> string -> unit = fun _ _ -> ()
  val mutable editable = false
  method set_renderer f = renderer <- f
  method set_editable f = 
    begin
      listener <- f ;
      editable <- true ;
    end

  initializer 
    begin
      ITextCell.bind super#wcolumn self#render ;
      EditedField.bind super#id self#edited ;
    end

  method! remove = 
    begin
      super#remove ;
      ITextCell.remove super#wcolumn ;
      EditedField.remove super#id ;
    end

  val mutable style : Widget.style = `Label
  val mutable align : Widget.align = `Left
    
  method set_style sty = style <- sty
  method! set_align aln = align <- aln ; super#set_align aln

  method edited field =
    try
      let row = NSTable.selected_row wtable in
      let item = custom#get row in
      listener item (NSString.to_string (NSTextField.get_text field))
    with Not_found -> ()

  method render image field row = 
    try 
      let item = custom#get row in
      let cell = new gitext_cell ~field ~image ~editable ~style ~align in
      renderer (cell :> Model.itext_cell) item ;
      cell#apply
    with Not_found -> ()

end

(* -------------------------------------------------------------------------- *)
(* --- Check Cells                                                        --- *)
(* -------------------------------------------------------------------------- *)

class gcheck_cell ~cell = 
object
  val mutable vtext = ""
  val mutable vcheck = false
  method set_text txt = vtext <- txt
  method set_check chk = vcheck <- chk
  method apply =
    begin
      NSCell.set_title cell (NSString.of_string vtext) ;
      NSCell.set_state cell vcheck ;
    end
end

(* -------------------------------------------------------------------------- *)
(* --- Check Columns                                                      --- *)
(* -------------------------------------------------------------------------- *)

class ['a] gcheck_column ~wtable ~(custom : 'a #custom) ~tid ~cid ?title () =
object(self)
  inherit ['a] gcolumn wtable kCheckCell ~tid ~cid ?title () as super
    
  val mutable renderer : Model.check_cell -> 'a -> unit = fun _ _ -> ()
  val mutable listener : 'a -> bool -> unit = fun _ _ -> ()
  method set_renderer f = renderer <- f
  method set_editable f = listener <- f

  initializer 
    begin
      CheckCell.bind super#wcolumn self#render ;
      ClickedCheck.bind super#id self#clicked ;
    end

  method! remove = 
    begin
      super#remove ;
      CheckCell.remove super#wcolumn ;
    end

  method clicked cell =
    try
      let row = NSTable.selected_row wtable in
      let item = custom#get row in
      listener item (NSCell.get_state cell) ;
    with Not_found -> ()
    
  method render cell row = 
    try 
      let item = custom#get row in
      let cell = new gcheck_cell ~cell in
      renderer (cell :> Model.check_cell) item ;
      cell#apply
    with Not_found -> ()

end

(* -------------------------------------------------------------------------- *)
(* --- Columns Management                                                 --- *)
(* -------------------------------------------------------------------------- *)

class ['a] gcolumns 
  ~(wtable:NSTable.t) 
  ~(headers:bool) 
  ~(custom:'a #custom) 
  ~tid =
object(self)
  inherit NSView.pane (NSView.scroll (NSTable.as_view wtable))
  initializer if headers then NSTable.set_headers wtable

  method reload = NSTable.reload wtable
  method update = NSTable.update_all wtable
  method reload_node = self#update_item
  method update_item e = NSTable.update_row wtable (custom#index e)
  method added e = NSTable.added_row wtable (custom#index e)
  method removed e = NSTable.removed_row wtable (custom#index e)

  method scroll e = NSTable.scroll wtable (custom#index e)
  method on_click : 'a callback = fun _ -> ()
  method on_double_click : 'a callback = fun _ -> ()

  val mutable cid = 0
  method private cid = function Some c -> c 
    | None -> cid <- succ cid ; Printf.sprintf "_%d" cid

  method add_icon_column ?id ?title () = 
    let cid = self#cid id in
    ( new gicon_column ~wtable ~custom ~tid ~cid ?title () :> 'a Model.icon_column )

  method add_text_column ?id ?title () = 
    let cid = self#cid id in
    ( new gtext_column ~wtable ~custom ~tid ~cid ?title () :> 'a Model.text_column )

  method add_tree_column ?id ?title () =
    let cid = self#cid id in
    ( new gitext_column ~wtable ~custom ~tid ~cid ?title () :> 'a Model.itext_column )

  method add_itext_column ?id ?title () =
    let cid = self#cid id in
    ( new gitext_column ~wtable ~custom ~tid ~cid ?title () :> 'a Model.itext_column )

  method add_check_column ?id ?title () =
    let cid = self#cid id in
    ( new gcheck_column ~wtable ~custom ~tid ~cid ?title () :> 'a Model.check_column )

  method remove_colum (col : 'a column) = col#remove
end

(* -------------------------------------------------------------------------- *)
(* --- List Views                                                         --- *)
(* -------------------------------------------------------------------------- *)

class ['a] empty_list_model =
object
  method size = 0
  method index (_:'a):int = raise Not_found
  method get (_:int):'a = raise Not_found
end

class ['a] custom_list m =
object
  val mutable model : 'a Model.list =
    (match m with Some m -> m | None -> new empty_list_model)
  method get = model#get
  method index = model#index
  method size () = model#size
  method set_model m = model <- m
end

class ['a] list ~id ?model ?(headers=true) () =
  let wtable = NSTable.create (NSString.of_string id) in
  let custom = new custom_list model in
object(self)
  inherit ['a] gcolumns ~wtable ~headers ~custom ~tid:id
  method set_model m = custom#set_model m ; self#reload
  initializer 
    begin
      NSTable.set_rules wtable true ;
      ListSize.bind wtable custom#size ;
    end
end

(* -------------------------------------------------------------------------- *)
(* --- Tree Views                                                         --- *)
(* -------------------------------------------------------------------------- *)

class ['a] empty_tree_model =
object
  method children (_:'a option) = 0
  method child_at (_:'a option) (_:int) : 'a = raise Not_found
  method parent (_:'a) : 'a option = raise Not_found
  method index (_:'a) : int = raise Not_found
end

class ['a] custom_tree m =
object
  val mutable model : 'a Model.tree =
    (match m with Some m -> m | None -> new empty_tree_model)
  method set_model m = model <- m
  method get (_:int):'a = raise Not_found
  method index (_:'a):int = raise Not_found
end

class ['a] tree ~id ?model ?(headers=true) () =
  let wtable = NSTable.create (NSString.of_string id) in
  let custom = new custom_tree model in
object(self)
  inherit ['a] gcolumns ~wtable ~headers ~custom ~tid:id
  method set_model m = custom#set_model m ; self#reload
end


