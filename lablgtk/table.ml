(* -------------------------------------------------------------------------- *)
(* --- Table Port                                                         --- *)
(* -------------------------------------------------------------------------- *)

open Event
open Widget
open Port

(* -------------------------------------------------------------------------- *)
(* --- Custom List Model                                                  --- *)
(* -------------------------------------------------------------------------- *)

class ['a] empty_list_model =
object
  method size = 0
  method index (_:'a):int = raise Not_found
  method get (_:int):'a = raise Not_found
end

class ['a] list_model (m0 : 'a Model.list option) =
  let m0 = match m0 with Some m0 -> m0 | None -> new empty_list_model in
object
  inherit ['a,'a,unit,unit] GTree.custom_tree_model (new GTree.column_list)
  val mutable model : 'a Model.list = m0
  method set_usermodel m = model <- m
  method! custom_flags = [`LIST_ONLY]
  method custom_decode_iter a () () = a
  method custom_encode_iter a = (a,(),())
  method custom_value (_:Gobject.g_type) (_:'a) ~column:_ = 
    failwith "GwList: empty columns"

  method custom_get_iter (path : Gtk.tree_path) : 'a option =
    let idx:int array = GtkTree.TreePath.get_indices path in
    match idx with 
      | [| |] -> None
      | [|i|] -> (try let e = model#get i in Some e with Not_found -> None)
      | _ -> failwith "Invalid path of depth>1 in a list"

  method custom_get_path (e : 'a) : Gtk.tree_path = 
    try GtkTree.TreePath.create [model#index e]
    with Not_found -> GtkTree.TreePath.create []
    
  method custom_iter_has_child (_:'a) = false
  
  method custom_iter_children = function
    | None when model#size > 0 -> Some(model#get 0)
    | _ -> None

  method custom_iter_n_children = function
    | Some _ -> failwith "GwList: no children"
    | None -> model#size

  method custom_iter_nth_child r k = match r with
    | Some _ -> failwith "GwList: no nth-child"
    | None -> if k < model#size then Some (model#get k) else None
	
  method custom_iter_parent (_:'a) = None

  method custom_iter_next e =
    try 
      let k = succ (model#index e) in
      if k < model#size then Some (model#get k) else None
    with Not_found -> None
end

(* -------------------------------------------------------------------------- *)
(* --- Custom Tree Model                                                  --- *)
(* -------------------------------------------------------------------------- *)

let rec get_iter m r idx k =
  if k >= Array.length idx then r else
    let a = m#child_at r idx.(k) in
    get_iter m (Some a) idx (succ k)
      
let rec get_path ks m a =
  let ks = m#index a :: ks in
  match m#parent a with
    | None -> ks 
    | Some b -> get_path ks m b

class ['a] empty_tree_model =
object
  method children (_:'a option) = 0
  method child_at (_:'a option) (_:int) : 'a = raise Not_found
  method parent (_:'a) : 'a option = raise Not_found
  method index (_:'a) : int = raise Not_found
end

class ['a] tree_model (m0 : 'a Model.tree option) =
  let m1 = match m0 with Some m0 -> m0 | None -> new empty_tree_model in
object
  inherit ['a,'a,unit,unit] GTree.custom_tree_model (new GTree.column_list)
  val mutable model : 'a Model.tree = m1
  method set_usermodel m = model <- m
  method custom_decode_iter a () () = a
  method custom_encode_iter a = (a,(),())
  method custom_value (_:Gobject.g_type) (_:'a) ~column:(_:int) : Gobject.basic 
    = Format.eprintf "Value ?@." ; assert false

  method custom_get_iter (path : Gtk.tree_path) : 'a option =
    let idx = GtkTree.TreePath.get_indices path in
    if Array.length idx = 0 then None else
      let a = model#child_at None idx.(0) in
      get_iter model (Some a) idx 1

  method custom_get_path (e : 'a) : Gtk.tree_path =
    let ks = try get_path [] model e with Not_found -> [] in
    GtkTree.TreePath.create ks
      
  method custom_iter_children r =
    let n = model#children r in
    if n > 0 then Some(model#child_at r 0) else None

  method custom_iter_has_child r = model#children (Some r) >= 0
  method custom_iter_parent = model#parent
  method custom_iter_n_children = model#children
  method custom_iter_nth_child r k = 
    if k < model#children r then Some (model#child_at r k) else None
  method custom_iter_next e =
    let p = model#parent e in
    let k = succ (model#index e) in
    if k < model#children p then Some (model#child_at p k) else None
      
end

(* -------------------------------------------------------------------------- *)
(* --- Click Handling Class                                               --- *)
(* -------------------------------------------------------------------------- *)

class type ['a] custom =
object
  method custom_get_iter : Gtk.tree_path -> 'a option
end

let is_column gcol ucol = match gcol , ucol with
  | _ , None -> true
  | None , Some _ -> false
  | Some c1 , Some c2 -> c1 == c2

class ['a] click_signals 
  (gtree : GTree.view) 
  (gcol : GTree.view_column option) 
  (model : 'a #custom)
  =
  let c1 : 'a signal = new Event.signal in
  let c2 : 'a signal = new Event.signal in
object(self)

  val mutable sid1 = None
  val mutable sid2 = None
  
  method private disconnect =
    begin
      Event.option gtree#misc#disconnect sid1 ;
      Event.option gtree#misc#disconnect sid1 ;
    end

  (* Simple click callback *)
  method private cb1 () =
    match gtree#get_cursor () with
      | Some path , ucol when is_column gcol ucol ->
	  begin match model#custom_get_iter path with
	    | None -> ()
	    | Some item -> c1#fire item
	  end
      | _ -> ()

  (* Simple click callback *)
  method private cb2 path col =
    if is_column gcol (Some col) then
      begin match model#custom_get_iter path with
	| None -> ()
	| Some item -> c2#fire item
      end

  method on_click f = 
    if sid1 = None then
      sid1 <- Some (gtree#connect#cursor_changed ~callback:self#cb1) ;
    c1#connect f

  method on_double_click f = 
    if sid2 = None then
      sid2 <- Some (gtree#connect#row_activated ~callback:self#cb2) ;
    c2#connect f
    
end

(* -------------------------------------------------------------------------- *)
(* --- Base Column Class                                                  --- *)
(* -------------------------------------------------------------------------- *)

class ['a] gcolumn 
  (gtree:GTree.view) 
  (gcol:GTree.view_column)
  (model:'a #custom)
  (id:string) =
  let s : Model.sorting selector = new Event.selector `Unsorted in
object(self)

  initializer 
    begin
      ignore id ;
      gcol#set_sizing `FIXED ;
      ignore (gtree#append_column gcol) ;
      gcol#set_clickable true ;
      ignore (gcol#connect#clicked ~callback:self#cbs) ;
      s#connect self#cbi ;
    end

  inherit ['a] click_signals gtree (Some gcol) model

  method gcol = gcol

  method remove : unit =
    self#disconnect ;
    ignore (gtree#remove_column gcol)

  method sorting = s
  method on_header = s#on_value `Unsorted
  method set_title = gcol#set_title 

  (* Sorting click *)
  method private cbs () = match s#get with
    | `Unsorted -> s#set `Unsorted
    | `Ascending -> s#set `Descending
    | `Descending -> s#set `Ascending

  (* Sorting feedback *)
  method private cbi = function
    | `Unsorted -> 
	gcol#set_sort_indicator false
    | `Ascending -> 
	gcol#set_sort_indicator true ;
	gcol#set_sort_order `ASCENDING
    | `Descending -> 
	gcol#set_sort_indicator true ;
	gcol#set_sort_order `DESCENDING

end

(* -------------------------------------------------------------------------- *)
(* --- Icon Cell                                                          --- *)
(* -------------------------------------------------------------------------- *)

let cache = Hashtbl.create 32
let tags_of_pixbuf resources f =  
  let path = Filename.concat !resources f in
  match Port.pixbuf path with None -> [] | Some p -> [`PIXBUF p]

let tags_of_icon (icn:Widget.icon) = match icn with
  | `NoIcon        -> []
  | `Warning       -> [`STOCK_SIZE `MENU;`STOCK_ID "gtk-dialog-warning"]
  | `Execute       -> [`STOCK_ID "gtk-execute"]
  | `Trash         -> [`STOCK_ID "gtk-delete"]
  | `Status_green  -> tags_of_pixbuf Config.wcaml_resources "status_green.png"
  | `Status_orange -> tags_of_pixbuf Config.wcaml_resources "status_orange.png"
  | `Status_red    -> tags_of_pixbuf Config.wcaml_resources "status_red.png"
  | `Status_none   -> tags_of_pixbuf Config.wcaml_resources "status_none.png"
  | `Image f       -> tags_of_pixbuf Config.app_resources f

(* -------------------------------------------------------------------------- *)
(* --- Icon Column                                                        --- *)
(* -------------------------------------------------------------------------- *)

class ['a] gicon_column 
  (gtree:GTree.view) (model:'a #custom)
  ~(id:string) ?title () =
  let gcol = GTree.view_column ?title () in
  let gcell = GTree.cell_renderer_pixbuf [] in
object(self)
  inherit ['a] gcolumn gtree gcol model id
  val mutable renderer : 'a -> Widget.icon = fun _ -> `NoIcon
  method private updated m i =
    gcol#clear_attributes gcell ;
    match model#custom_get_iter (m#get_path i) with
      | None -> ()
      | Some e -> gcell#set_properties (tags_of_icon (renderer e))
  method set_renderer f = renderer <- f
  initializer 
    begin
      gcol#set_alignment 0.5 ;
      gcol#set_sizing `AUTOSIZE ;
      gcol#set_resizable false ;
      gcol#pack ~expand:true gcell ;
      gcol#set_cell_data_func gcell self#updated
    end
end

(* -------------------------------------------------------------------------- *)
(* --- Text Cell                                                          --- *)
(* -------------------------------------------------------------------------- *)

let xalign = function `Left -> 0.0 | `Center -> 0.5 | `Right -> 1.0

let tags_of_style = function
  | `Label -> []
  | `Title -> [`WEIGHT `BOLD]
  | `Descr -> [`SIZE (-2)]
  | `Verbatim -> [`FONT "Monospace"]

let tags_of_fg = function
  | `Default -> []
  | c -> [`FOREGROUND (Port.fg c)]

let tags_of_bg = function
  | `Default -> []
  | c -> [`CELL_BACKGROUND (Port.bg c)]
      
class gtext_cell 
  (gcol : GTree.view_column) 
  (field : GTree.cell_renderer_text) =
object
  val mutable text = ""
  val mutable align : align = `Left
  val mutable style : style = `Label
  val mutable fg : color = `Default
  val mutable bg : color = `Default
  val mutable editable = false
  method clear a s e =
    begin
      text <- "" ;
      align <- a ;
      style <- s ;
      editable <- e ;
      fg <- `Default ;
      bg <- `Default ;
      gcol#clear_attributes field ;
    end
  method set_icon (_:Widget.icon) = ()
  method set_align a = align <- a
  method set_style s = style <- s
  method set_text s = text <- s
  method set_fg c = fg <- c
  method set_bg c = bg <- c
  method apply : unit = field#set_properties
    begin
      [`TEXT text;`XALIGN (xalign align);`EDITABLE editable]
      @ tags_of_style style
      @ tags_of_fg fg
      @ tags_of_bg bg
    end
end

(* -------------------------------------------------------------------------- *)
(* --- Icon & Text Cell                                                   --- *)
(* -------------------------------------------------------------------------- *)

class gitext_cell 
  (gcol : GTree.view_column)
  (image : GTree.cell_renderer_pixbuf)
  (field : GTree.cell_renderer_text) =
object
  inherit gtext_cell gcol field as gtext
  val mutable icon = `NoIcon
  method! set_icon icn = icon <- icn
  method! clear a s e = 
    begin
      gtext#clear a s e ; 
      icon <- `NoIcon ;
      gcol#clear_attributes image ;
    end
  method! apply : unit =
    begin
      image#set_properties (tags_of_icon icon) ;
      gtext#apply ;
    end
end

(* -------------------------------------------------------------------------- *)
(* --- Check Cell                                                         --- *)
(* -------------------------------------------------------------------------- *)

class gcheck_cell
  (gcol : GTree.view_column)
  (b : GTree.cell_renderer_toggle)
  (t : GTree.cell_renderer_text) =
object
  val mutable text = ""
  val mutable checked = false
  method checked = checked
  method set_text t = text <- t
  method set_check b = checked <- b
  method clear : unit =
    begin
      text <- "";
      checked <- false;
      gcol#clear_attributes b ;
      gcol#clear_attributes t ;
    end
  method apply : unit =
    begin
      b#set_properties [`ACTIVE checked] ;
      t#set_properties [`TEXT text;`XALIGN 0.0] ;
    end
end

(* -------------------------------------------------------------------------- *)
(* --- Text Signals                                                       --- *)
(* -------------------------------------------------------------------------- *)

class ['a] gtext_signals
  (gcol : GTree.view_column)
  (gcell : GTree.cell_renderer_text) 
  (gtext : #gtext_cell)
  (model : 'a #custom) =
object(self)
  val mutable align = `Left
  val mutable style = `Label
  val mutable render = fun (_:gtext_cell) (_:'a) -> ()
  val mutable editor = fun (_:'a) (_:string) -> ()
  val mutable editable = false
  val mutable connected = false
  method set_align a = align <- a
  method set_style s = style <- s
  method set_renderer f = render <- f
  method set_editable f = 
    begin
      editor <- f ;
      editable <- true ;
      if not connected then
	begin
	  connected <- true ;
	  ignore (gcell#connect#edited ~callback:self#edited) ;
	end
    end
  method private updated m i =
    let p = m#get_path i in
    gtext#clear align style editable ;
    match model#custom_get_iter p with
      | None -> ()
      | Some e -> render (gtext :> 'b) e ; gtext#apply
  method private edited p s =
    match model#custom_get_iter p with
      | None -> ()
      | Some e -> editor e s
  initializer
    begin
      gcol#set_alignment 0.0 ;
      gcol#set_sizing `AUTOSIZE ;
      gcol#set_resizable true ;
      gcol#pack ~expand:true gcell ;
      gcol#set_cell_data_func gcell self#updated ;
    end
end

(* -------------------------------------------------------------------------- *)
(* --- Text Column                                                        --- *)
(* -------------------------------------------------------------------------- *)

class ['a] gtext_column 
  (gtree:GTree.view) (model:'a #custom)
  ~(id:string) ?title () =
  let gcol = GTree.view_column ?title () in
  let gcell = GTree.cell_renderer_text [] in
  let gtext = new gtext_cell gcol gcell in
object
  inherit ['a] gcolumn gtree gcol model id
  inherit ['a] gtext_signals gcol gcell gtext model
end

(* -------------------------------------------------------------------------- *)
(* --- Icon & Text Column                                                 --- *)
(* -------------------------------------------------------------------------- *)

class ['a] gitext_column 
  (gtree:GTree.view) (model:'a #custom)
  ~(id:string) ?(expander=false) ?title () =
  let gcol = GTree.view_column ?title () in
  let gimage = GTree.cell_renderer_pixbuf [] in 
  let gfield = GTree.cell_renderer_text [] in
  let gtext = new gitext_cell gcol gimage gfield in
object
  inherit ['a] gcolumn gtree gcol model id
  initializer if expander then gtree#set_expander_column (Some gcol)
  initializer gcol#pack ~expand:false gimage
  inherit ['a] gtext_signals gcol gfield (gtext :> gtext_cell) model
end

(* -------------------------------------------------------------------------- *)
(* --- Check Column                                                       --- *)
(* -------------------------------------------------------------------------- *)

class ['a] gcheck_column 
  (gtree:GTree.view) (model:'a #custom)
  ~(id:string) ?title () =
  let gcol = GTree.view_column ?title () in
  let gtoggle = GTree.cell_renderer_toggle [] in
  let gtitle = GTree.cell_renderer_text [] in
  let gcheck = new gcheck_cell gcol gtoggle gtitle in
object(self)
  inherit ['a] gcolumn gtree gcol model id
  val mutable renderer : Model.check_cell -> 'a -> unit = fun _ _ -> ()
  val mutable callback : 'a -> bool -> unit = fun _ _ -> ()
  method private updated m i =
    gcheck#clear ;
    match model#custom_get_iter (m#get_path i) with
      | None -> ()
      | Some e -> renderer (gcheck :> Model.check_cell) e ; gcheck#apply
  method private toggled p =
    match model#custom_get_iter p with
      | None -> ()
      | Some e -> 
	  renderer (gcheck :> Model.check_cell) e ;
	  callback e gcheck#checked
	  
  method set_renderer f = renderer <- f
  method set_editable f = callback <- f

  initializer
    begin
      gcol#set_alignment 0.5 ;
      gcol#set_sizing `FIXED ;
      gcol#set_resizable false ;
      gcol#pack ~expand:false gtoggle ;
      gcol#pack ~expand:true gtitle ;
      gcol#set_cell_data_func gtoggle self#updated ;
      ignore (gtoggle#connect#toggled ~callback:self#toggled) ;
    end
end

(* -------------------------------------------------------------------------- *)
(* --- Base View Class                                                    --- *)
(* -------------------------------------------------------------------------- *)

class ['a,'b] gtable headers model =
  let gtree = GTree.view ~model
    ~fixed_height_mode:true 
    ~headers_visible:headers
    ~headers_clickable:headers
    ~reorderable:true
    ~rules_hint:true () in
object(self)

  method set_model (m : 'b) = 
    begin
      model#set_usermodel m ;
      gtree#set_model (Some model :> GTree.model option) ;
    end

  inherit Port.pane gtree
  inherit ['a] click_signals gtree None model

  val mutable scol = None
    
  method scroll e = match scol with
    | Some col -> gtree#scroll_to_cell (model#custom_get_path e) col
    | _ -> ()

  method reload = 
    begin
      gtree#set_model None ;
    end

  method reload_node e =
    try
      let p = model#custom_get_path e in
      model#custom_row_has_child_toggled p e
    with Not_found -> ()
	    
  method update_item e =
    try model#custom_row_changed (model#custom_get_path e) e
    with Not_found -> ()

  method update = 
    GtkBase.Widget.queue_draw gtree#as_tree_view

  method added (e : 'a) : unit = 
    try model#custom_row_inserted (model#custom_get_path e) e
    with Not_found -> ()

  method removed (e : 'a) : unit =
    try model#custom_row_deleted (model#custom_get_path e)
    with Not_found -> ()

  val mutable cid = 0
  method private cid = function
    | Some id -> id
    | None -> cid <- succ cid ; Printf.sprintf "c%d" cid

  method add_icon_column ?id ?title () =
    let id = self#cid id in
    let column = new gicon_column gtree model ~id ?title () in
    if scol = None then scol <- Some column#gcol ;
    ( column :> 'a Model.icon_column )

  method add_text_column ?id ?title () =
    let id = self#cid id in
    let column = new gtext_column gtree model ~id ?title () in
    if scol = None then scol <- Some column#gcol ;
    ( column :> 'a Model.text_column )

  method add_tree_column ?id ?title () =
    let id = self#cid id in
    let column = new gitext_column gtree model ~id ?title 
      ~expander:true () in
    scol <- Some column#gcol ;
    ( column :> 'a Model.itext_column )

  method add_itext_column ?id ?title () =
    let id = self#cid id in
    let column = new gitext_column gtree model ~id ?title () in
    if scol = None then scol <- Some column#gcol ;
    ( column :> 'a Model.itext_column )

  method add_check_column ?id ?title () =
    let id = self#cid id in
    let column = new gcheck_column gtree model ~id ?title () in
    if scol = None then scol <- Some column#gcol ;
    ( column :> 'a Model.check_column )

  method remove_colum (gcol : 'a Model.column) = gcol#remove

end

class ['a] list ~(id:string) ?model ?(headers=true) () =
object
  inherit ['a,'a Model.list] gtable headers (new list_model model)
  initializer ignore id
end

class ['a] tree ~(id:string) ?model ?(headers=true) () =
object
  inherit ['a,'a Model.tree] gtable headers (new tree_model model)
  initializer ignore id
end
