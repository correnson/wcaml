(* -------------------------------------------------------------------------- *)
(* --- Layouts                                                            --- *)
(* -------------------------------------------------------------------------- *)

open Widget

(* -------------------------------------------------------------------------- *)
(* --- Forms                                                              --- *)
(* -------------------------------------------------------------------------- *)

class form () =
  let padding = 20,20,20,20 in
  let box = GBin.alignment ~padding ~xalign:0.5 ~yalign:0.0 () in
  let table = GPack.table ~columns:2 ~homogeneous:false 
    ~col_spacings:4 ~row_spacings:6 ~border_width:0 
    ~packing:box#add ()
  in
object(self)
  inherit Port.pane box
  val mutable top = 0
  val mutable xpadding = 0
  val mutable separated = true
    
  method add_separation = if not separated then
    begin
      let w = GMisc.label ~text:"" () in
      table#attach ~left:0 ~top ~expand:`NONE w#coerce ;
      top <- succ top ; separated <- true
    end
      
  method add_section title =
    begin
      self#add_separation ;
      let w = GMisc.label ~text:title ~xalign:0.0 ~yalign:1.0 () in 
      Port.title_font w ;
      table#attach ~left:0 ~right:2 ~top ~ypadding:2 ~expand:`Y w#coerce ;
      top <- succ top ; separated <- false ;
    end
      
  method private add_label = function
    | None -> ()
    | Some text ->
	let w = GMisc.label ~text ~xalign:1.0 ~yalign:0.5 () in
	table#attach ~left:0 ~top ~expand:`NONE w#coerce
	  
  method private add_widget layout widget = match layout with
    | Port.Fixed -> 
	let hbox = GPack.hbox ~homogeneous:false () in
	hbox#pack ~expand:false widget ;
	table#attach ~left:1 ~top ~expand:`NONE hbox#coerce
    | Port.Field -> 
	table#attach ~left:1 ~top ~expand:`X ~fill:`X widget
    | Port.Boxed -> 
	table#attach ~left:1 ~top ~expand:`BOTH widget
	  
  method add_control ?label (widget : Widget.widget) =
    begin
      self#add_label label ;
      let layout = Port.get_layout widget in
      let widget = Port.get_widget widget in
      self#add_widget layout widget ;
      top <- succ top ; separated <- false
    end

  method add_hbox ?label = function
    | [] -> ()
    | [widget] -> self#add_control ?label widget
    | widgets ->
	begin
	  self#add_label label ;
	  let hbox = GPack.hbox ~homogeneous:false ~spacing:8 () in
	   let rec fill x y = function
	     | [] ->
		 let layout = if y then Port.Boxed else 
		   if x then Port.Field else Port.Fixed 
		 in self#add_widget layout hbox#coerce
	     | ctrl::others ->
		 let layout = Port.get_layout ctrl in
		 let widget = Port.get_widget ctrl in
		 let expand = Port.hexpand layout in
		 hbox#pack ~expand widget ;
		 fill (x || expand) (y || Port.hexpand layout) others
	   in fill false false widgets ;
	   top <- succ top ; separated <- false
	 end

  method add_vbox ?label widgets = if widgets <> [] then
    begin
      self#add_label label ;
      List.iter self#add_control widgets ;
    end
      
  method add_pane ?label (panel : Widget.pane) =
    self#add_label label ;
    let widget = Port.get_widget panel in
    if label = None then
      table#attach ~left:1 ~right:2 ~xpadding ~top ~expand:`BOTH widget
    else
      table#attach ~left:2 ~right:2 ~top ~expand:`BOTH widget ;
    top <- succ top ; separated <- false

end

(* -------------------------------------------------------------------------- *)
(* --- Boxes                                                              --- *)
(* -------------------------------------------------------------------------- *)

(*
class hbox (controls : Widget.widget list) =
  let box = GPack.hbox ~homogeneous:false () in
object(self)
  inherit Port.pane box
  method private pack (ctrl : Widget.widget) =
    let layout = Port.get_layout ctrl in
    let widget = Port.get_widget ctrl in
    let expand = Port.hexpand layout in
    box#pack ~expand widget
  initializer List.iter self#pack controls
end

class vbox (controls : Widget.widget list) =
  let box = GPack.vbox ~homogeneous:false () in
object(self)
  inherit Port.pane box
  method private pack (ctrl : Widget.widget) =
    let layout = Port.get_layout ctrl in
    let widget = Port.get_widget ctrl in
    let expand = Port.vexpand layout in
    box#pack ~expand widget
  initializer List.iter self#pack controls
end
*)

class toolbar (controls : Widget.widget list) (main : Widget.pane) =
  let hbox = GPack.hbox ~homogeneous:false () in
  let vbox = GPack.vbox ~homogeneous:false () in
object(self)
  inherit Port.pane vbox
  method private pack (ctrl : Widget.widget) =
    let layout = Port.get_layout ctrl in
    let widget = Port.get_widget ctrl in
    let expand = Port.hexpand layout in
    hbox#pack ~expand widget
  initializer 
    begin
      hbox#set_border_width 3 ;
      hbox#set_spacing 6 ;
      List.iter self#pack controls ;
      vbox#pack ~expand:false hbox#coerce ;
      vbox#pack ~expand:true ~fill:true (Port.get_widget main) ;
    end
end

(* -------------------------------------------------------------------------- *)
(* --- Split Panes                                                        --- *)
(* -------------------------------------------------------------------------- *)

class sidebar ~id ~side ~pane =
  let paned = GPack.paned `HORIZONTAL () in
  let width = User.int ~id ~default:(-1) in
object(self)
  inherit Port.pane paned

  method private load () =
    let a = paned#min_position in
    let b = paned#max_position in
    let p = a + width#get in
    if p <= b then paned#set_position p
	
  method private save () = width#set paned#position
    
  initializer 
    begin
      paned#pack1 ~resize:false (Port.get_widget side) ;
      paned#pack2 ~resize:true (Port.get_widget pane) ;
      ignore (paned#misc#connect#realize ~callback:self#load) ;
      User.on_save self#save ;
    end
end

class split dir id a b =
  let paned = GPack.paned dir () in
  let ratio = User.float ~id ~default:(-1.0) in
object(self)
  inherit Port.pane paned

  method private load () =
    let r = ratio#get in
    if 0.0 <= r && r <= 1.0 then 
      let a = paned#min_position in
      let b = paned#max_position in
      let ofs = int_of_float (float (b-a) *. r) in
      paned#set_position (a+ofs)
	
  method private save () =
    let a = paned#min_position in
    let b = paned#max_position in
    let p = paned#position in
    let r = float (p-a) /. float (b-a) in
    ratio#set r
    
  initializer 
    begin
      paned#pack1 ~resize:true (Port.get_widget a) ;
      paned#pack2 ~resize:true (Port.get_widget b) ;
      ignore (paned#misc#connect#realize ~callback:self#load) ;
      User.on_save self#save ;
    end
end

class hsplit ~id ~left ~right = 
object
  inherit split `HORIZONTAL id left right
end

class vsplit ~id ~top ~bottom = 
object
  inherit split `VERTICAL id top bottom
end
