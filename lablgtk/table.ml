(* -------------------------------------------------------------------------- *)
(* --- Table Port                                                         --- *)
(* -------------------------------------------------------------------------- *)

open Event
open Widget
open Port
open Model

(* -------------------------------------------------------------------------- *)
(* --- Custom List Model                                                  --- *)
(* -------------------------------------------------------------------------- *)

class ['a] list_model (m : 'a Model.list) =
object
  inherit ['a,'a,unit,unit] GTree.custom_tree_model (new GTree.column_list)
  method! custom_flags = [`LIST_ONLY]
  method custom_decode_iter a () () = a
  method custom_encode_iter a = (a,(),())
  method custom_value (_:Gobject.g_type) (_:'a) ~column:_ = 
    failwith "GwList: empty columns"

  method custom_get_iter (path : Gtk.tree_path) : 'a option =
    let idx:int array = GtkTree.TreePath.get_indices path in
    match idx with 
      | [| |] -> None
      | [|i|] -> (try let e = m#get i in Some e with Not_found -> None)
      | _ -> failwith "Invalid path of depth>1 in a list"

  method custom_get_path (e : 'a) : Gtk.tree_path = 
    try GtkTree.TreePath.create [m#index e]
    with Not_found -> GtkTree.TreePath.create []
    
  method custom_iter_has_child (_:'a) = false
  
  method custom_iter_children = function
    | None when m#size > 0 -> Some(m#get 0)
    | _ -> None

  method custom_iter_n_children = function
    | Some _ -> failwith "GwList: no children"
    | None -> m#size

  method custom_iter_nth_child r k = match r with
    | Some _ -> failwith "GwList: no nth-child"
    | None -> if k < m#size then Some (m#get k) else None
	
  method custom_iter_parent (_:'a) = None

  method custom_iter_next e =
    try 
      let k = succ (m#index e) in
      if k < m#size then Some (m#get k) else None
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
	
class ['a] tree_model (m : 'a Model.tree) =
object
  inherit ['a,'a,unit,unit] GTree.custom_tree_model (new GTree.column_list)
  method custom_decode_iter a () () = a
  method custom_encode_iter a = (a,(),())
  method custom_value (_:Gobject.g_type) (_:'a) ~column:(_:int) : Gobject.basic 
    = Format.eprintf "Value ?@." ; assert false

  method custom_get_iter (path : Gtk.tree_path) : 'a option =
    let idx = GtkTree.TreePath.get_indices path in
    if Array.length idx = 0 then None else
      let a = m#child_at None idx.(0) in
      get_iter m (Some a) idx 1

  method custom_get_path (e : 'a) : Gtk.tree_path =
    let ks = try get_path [] m e with Not_found -> [] in
    GtkTree.TreePath.create ks
      
  method custom_iter_children r =
    let n = m#children r in
    if n > 0 then Some(m#child_at r 0) else None

  method custom_iter_has_child r = m#children (Some r) >= 0
  method custom_iter_parent = m#parent
  method custom_iter_n_children = m#children
  method custom_iter_nth_child r k = 
    if k < m#children r then Some (m#child_at r k) else None
  method custom_iter_next e =
    let p = m#parent e in
    let k = succ (m#index e) in
    if k < m#children p then Some (m#child_at p k) else None
      
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

class type ['a] update = 
object
  method update : 'a -> unit
  method update_all : unit -> unit
end

class ['a] gcolumn 
  (gtree:GTree.view) 
  (gcol:GTree.view_column)
  (model:'a #custom)
  (cb:'a #update) 
  (id:string) =
  let s : sorting selector = new Event.selector `Unsorted in
object(self)

  initializer 
    begin
      ignore id ;
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

  method set_title = gcol#set_title 
  method update = cb#update
  method update_all = cb#update_all

  method sorting = s
  method on_header = s#on_value `Unsorted

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

let icon (icn:Widget.icon) = match icn with
  | `NoIcon       -> []
  | `Warning      -> [`STOCK_SIZE `MENU;`STOCK_ID "gtk-dialog-warning"]
  | `Execute      -> [`STOCK_ID "gtk-execute"]
  | `Trash        -> [`STOCK_ID "gtk-delete"]
  | `State_green  -> tags_of_pixbuf Config.wcaml_resources "status_green.png"
  | `State_orange -> tags_of_pixbuf Config.wcaml_resources "status_orange.png"
  | `State_red    -> tags_of_pixbuf Config.wcaml_resources "status_red.png"
  | `State_none   -> tags_of_pixbuf Config.wcaml_resources "status_none.png"
  | `Image f      -> tags_of_pixbuf Config.app_resources f

(* -------------------------------------------------------------------------- *)
(* --- Icon Column                                                        --- *)
(* -------------------------------------------------------------------------- *)

class ['a] gicon_column 
  (gtree:GTree.view) (model:'a #custom) (cb:'a #update) 
  ~(id:string) ?title () =
  let gcol = GTree.view_column ?title () in
  let gcell = GTree.cell_renderer_pixbuf [] in
object(self)
  inherit ['a] gcolumn gtree gcol model cb id
  val mutable renderer : 'a -> Widget.icon = fun _ -> `NoIcon
  method private updated m i =
    let tags = match model#custom_get_iter (m#get_path i) with
      | None -> []
      | Some e -> icon (renderer e)
    in gcell#set_properties tags
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

let xalign (a:align) = 
  match a with `Left -> 0.0 | `Center -> 0.5 | `Right -> 1.0

class gtext_cell (r : GTree.cell_renderer_text) =
object
  val mutable tags = []
  val mutable editable = false
  method set_icon (_:icon) = ()
  method set_editable e = editable <- e
  method set_align a = tags <- `XALIGN (xalign a) :: tags
  method set_style (s:style) = match s with
    | `Text -> tags <- `FONT "Helvetica" :: tags
    | `Code -> tags <- `FONT "Monospace" :: tags
    | `Bold -> tags <- `WEIGHT `BOLD :: tags
  method set_text s = tags <- `TEXT s :: tags
  method set_fg c = tags <- `FOREGROUND (Port.fg c) :: tags
  method set_bg c = tags <- `BACKGROUND (Port.bg c) :: tags
  method clear = r#set_properties [] ; tags <- []
  method apply =
    if editable then tags <- `EDITABLE true :: tags ;
    r#set_properties (List.rev tags) ; tags <- []
end

(* -------------------------------------------------------------------------- *)
(* --- Icon & Text Cell                                                   --- *)
(* -------------------------------------------------------------------------- *)

class gitext_cell 
  (i : GTree.cell_renderer_pixbuf) 
  (r : GTree.cell_renderer_text) =
object
  inherit gtext_cell r as gtext
  val mutable itags = []
  method! set_icon icn = itags <- icon icn
  method! clear = gtext#clear ; i#set_properties []
  method! apply = gtext#apply ; i#set_properties itags ; itags <- []
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
  val mutable style = None
  val mutable styler = fun (_:gtext_cell) (_:'a) -> ()
  val mutable editor = fun (_:'a) (_:string) -> ()
  val mutable connected = false
  method set_align a = gcol#set_alignment (xalign a)
  method set_style s = style <- Some s
  method set_renderer f = styler <- f
  method set_editable f = 
    begin
      editor <- f ;
      gtext#set_editable true ;
      if not connected then
	begin
	  connected <- true ;
	  ignore (gcell#connect#edited ~callback:self#edited) ;
	end
    end
  method private updated m i =
    match model#custom_get_iter (m#get_path i) with
      | None -> gtext#clear
      | Some e -> 
	  Event.option gtext#set_style style ;
	  styler (gtext :> 'b) e ; 
	  gtext#apply
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
  (gtree:GTree.view) (model:'a #custom) (cb:'a #update) 
  ~(id:string) ?title () =
  let gcol = GTree.view_column ?title () in
  let gcell = GTree.cell_renderer_text [] in
  let gtext = new gtext_cell gcell in
object
  inherit ['a] gcolumn gtree gcol model cb id
  inherit ['a] gtext_signals gcol gcell gtext model
end

(* -------------------------------------------------------------------------- *)
(* --- Icon & Text Column                                                 --- *)
(* -------------------------------------------------------------------------- *)

class ['a] gitext_column 
  (gtree:GTree.view) (model:'a #custom) (cb:'a #update) 
  ~(id:string) ?(expander=false) ?title () =
  let gcol = GTree.view_column ?title () in
  let gicon = GTree.cell_renderer_pixbuf [] in 
  let gcell = GTree.cell_renderer_text [] in
  let gtext = new gitext_cell gicon gcell in
object
  inherit ['a] gcolumn gtree gcol model cb id
  initializer if expander then gtree#set_expander_column (Some gcol)
  initializer gcol#pack ~expand:false gicon
  inherit ['a] gtext_signals gcol gcell gtext model
end

(* -------------------------------------------------------------------------- *)
(* --- Check Column                                                       --- *)
(* -------------------------------------------------------------------------- *)

class ['a] gcheck_column 
  (gtree:GTree.view) (model:'a #custom) (cb:'a #update) 
  ~(id:string) ?title () =
  let gcol = GTree.view_column ?title () in
  let gcell = GTree.cell_renderer_toggle [] in
object(self)
  inherit ['a] gcolumn gtree gcol model cb id
  val mutable renderer : 'a -> bool = fun _ -> false
  val mutable callback : 'a -> bool -> unit = fun _ _ -> ()
  val mutable editable = false
  method private updated m i =
    let tags = match model#custom_get_iter (m#get_path i) with
      | None -> [`ACTIVATABLE false;`ACTIVE false]
      | Some e -> [`ACTIVATABLE editable;`ACTIVE (renderer e)]
    in gcell#set_properties tags
  method private toggled p =
    match model#custom_get_iter p with
      | None -> ()
      | Some e -> callback e (not (renderer e))
  method set_renderer f = renderer <- f
  method set_editable f = 
    callback <- f ; 
    editable <- true ;
    ignore (gcell#connect#toggled ~callback:self#toggled)
  initializer
    begin
      gcol#set_alignment 0.5 ;
      gcol#set_sizing `FIXED ;
      gcol#set_resizable false ;
      gcol#pack ~expand:true gcell ;
      gcol#set_cell_data_func gcell self#updated
    end
end

(* -------------------------------------------------------------------------- *)
(* --- Base View Class                                                    --- *)
(* -------------------------------------------------------------------------- *)

class ['a] gtable headers model =
  let gtree = GTree.view ~model
    ~fixed_height_mode:true 
    ~headers_visible:headers
    ~headers_clickable:headers
    ~reorderable:true
    ~rules_hint:true () in
object(self)

  inherit Port.pane gtree
  inherit ['a] click_signals gtree None model

  val mutable scol = None
    
  method scroll e = match scol with
    | Some col -> gtree#scroll_to_cell (model#custom_get_path e) col
    | _ -> ()

  method reload (e : 'a option) : unit =
    match e with 
      | None -> 
	  gtree#set_model (Some (model :> GTree.model))
      | Some e -> 
	  let p = model#custom_get_path e in
	  model#custom_row_has_child_toggled p e
	    
  method update (e : 'a) : unit =
    model#custom_row_changed (model#custom_get_path e) e

  method update_all () = 
    GtkBase.Widget.queue_draw gtree#as_tree_view

  method added (e : 'a) : unit = 
    model#custom_row_inserted (model#custom_get_path e) e

  method removed (e : 'a) : unit =
    model#custom_row_deleted (model#custom_get_path e)

  method add_icon_column ~id ?title () =
    let column = new gicon_column gtree model self ~id ?title () in
    if scol = None then scol <- Some column#gcol ;
    ( column :> 'a Model.icon_column )

  method add_text_column ~id ?title () =
    let column = new gtext_column gtree model self ~id ?title () in
    if scol = None then scol <- Some column#gcol ;
    ( column :> 'a Model.text_column )

  method add_tree_column ~id ?title () =
    let column = new gitext_column gtree model self ~id ?title 
      ~expander:true () in
    scol <- Some column#gcol ;
    ( column :> 'a Model.itext_column )

  method add_itext_column ~id ?title () =
    let column = new gitext_column gtree model self ~id ?title () in
    if scol = None then scol <- Some column#gcol ;
    ( column :> 'a Model.itext_column )

  method add_check_column ~id ?title () =
    let column = new gcheck_column gtree model self ~id ?title () in
    if scol = None then scol <- Some column#gcol ;
    ( column :> 'a Model.check_column )

  method remove_colum (gcol : 'a column) = gcol#remove

end

class ['a] list ~(id:string) ~(model:'a Model.list) ?(headers=true) () =
object
  inherit ['a] gtable headers (new list_model model)
  initializer ignore id
end

class ['a] tree ~(id:string) ~(model:'a Model.tree) ?(headers=true) () =
object
  inherit ['a]  gtable headers (new tree_model model)
  initializer ignore id
end
