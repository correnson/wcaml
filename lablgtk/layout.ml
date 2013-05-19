(* -------------------------------------------------------------------------- *)
(* --- Layouts                                                            --- *)
(* -------------------------------------------------------------------------- *)

open Widget

(* -------------------------------------------------------------------------- *)
(* --- Forms                                                              --- *)
(* -------------------------------------------------------------------------- *)

class form () =
  let table = GPack.table ~columns:2 ~homogeneous:false 
    ~col_spacings:16 ~row_spacings:6 ~border_width:0 ()
  in
object(self)
  inherit Port.pane table
  val mutable top = 0
  val mutable xpadding = 0
    
  method add_separation = if top > 0 then 
    begin
      let w = GMisc.label ~text:"" () in
      table#attach ~left:0 ~top ~ypadding:12 ~expand:`NONE w#coerce ;
      top <- succ top ;
    end

  method add_section title =
    begin
      let w = GMisc.label ~text:title ~xalign:0.0 ~yalign:1.0 () in 
      Port.title_font w ;
      xpadding <- 24 ;
      table#attach ~left:0 ~right:2 ~top 
	~xpadding:0 ~ypadding:12 ~expand:`Y w#coerce ;
      top <- succ top ;
    end

  method private add_label = function
    | None -> ()
    | Some text ->
	let w = GMisc.label ~text ~xalign:1.0 ~yalign:0.0 () in
	table#attach ~left:0 ~top ~xpadding ~expand:`NONE w#coerce

  method private add_widget layout widget = match layout with
    | Port.Fixed -> table#attach ~left:1 ~top ~expand:`X ~fill:`NONE widget
    | Port.Field -> table#attach ~left:1 ~top ~expand:`X ~fill:`X widget
    | Port.Boxed -> table#attach ~left:1 ~top ~expand:`BOTH widget
	  
  method add_control ?label (control : Widget.control) =
    begin
      self#add_label label ;
      let layout = Port.get_layout control in
      let widget = Port.get_widget control in
      self#add_widget layout widget ;
      top <- succ top ;
    end

  method add_hbox ?label = function
    | [] -> ()
    | [control] -> self#add_control ?label control
    | controls ->
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
	   in fill false false controls ;
	   top <- succ top ;
	 end

  method add_vbox ?label controls = if controls <> [] then
    begin
      self#add_label label ;
      List.iter self#add_control controls ;
    end
      
  method add_pane ?label (panel : Widget.pane) =
    self#add_label label ;
    let widget = Port.get_widget panel in
    if label = None then
      table#attach ~left:1 ~right:2 ~xpadding ~top ~expand:`BOTH widget
    else
      table#attach ~left:2 ~right:2 ~top ~expand:`BOTH widget ;
    top <- succ top

end
