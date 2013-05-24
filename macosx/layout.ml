(* -------------------------------------------------------------------------- *)
(* --- Pane Layout                                                        --- *)
(* -------------------------------------------------------------------------- *)

open Event
open Widget
open Port
open Portcontrol
open NSView

let dHsep =  8 (* Horizontal Separation *)
let dVsep =  6 (* Vertical Separation *)
let dBorder = 12 (* Section Separation *)
let dSection = 24 (* Empty Line Separation *)

class form () =
  let box = NSView.create () in
object(self)
  inherit NSView.pane box

  val mutable xpadding = dBorder
  val mutable ypadding = dBorder
  val mutable lastrow : NSView.t list = [box]
  val mutable lastctr : NSView.t = Port.nil

  method private vertical_layout ctrls = 
    match lastrow , ctrls with
      | [] , _ | _ , [] -> ()
      | [last] , [ctrl] -> 
	  NSView.set_layout box kVsep last ctrl ypadding ;
	  NSView.set_layout box kVfill ctrl box dSection ;
      | _ ->
	  List.iter
	    (fun a ->
	       List.iter
		 (fun b ->
		    NSView.set_layout box kVfill a b ypadding
		 ) ctrls)
	    lastrow ;
	  List.iter
	    (fun b ->
	       NSView.set_layout box kVfill b box dSection)
	    ctrls
      
  method private column_layout = function
    | left::_ -> 
	NSView.set_layout box kLeftAlign lastctr left 0 ;
	lastctr <- left
    | _ -> ()

  method private baseline_layout (chain : NSView.t list) =
    let line = 
      try List.find NSView.has_baseline chain 
      with Not_found -> List.hd chain in
    List.iter
      (fun ctrl -> if ctrl != line then
	 NSView.set_layout box kBaseline line ctrl 0)
      chain

  method private horizontal_layout = function
    | [] -> ()
    | (first::_) as chain ->
	NSView.set_layout box kHfill box first xpadding ;
	let rec hbox = function
	  | [] -> ()
	  | [last] -> 
	      NSView.set_layout box kHfill box last dHsep
	  | a::((b::_) as others) ->
	      NSView.set_layout box kHsep a b dHsep ;
	      hbox others
	in hbox chain

  method private add_row label ctrls =
    if ctrls <> [] then
      match label with
	| None ->
	    List.iter (NSView.add_subview box) ctrls ;
	    self#vertical_layout ctrls ;
	    self#horizontal_layout ctrls ;
	    self#baseline_layout ctrls ;
	    self#column_layout ctrls ;
	    lastrow <- ctrls ; 
	    ypadding <- dVsep
	| Some text ->
	    let label = new Control.label ~text ~align:`Right () in
	    let lview = NSView.get label in
	    let chain = lview :: ctrls in
	    List.iter (NSView.add_subview box) chain ;
	    self#vertical_layout ctrls ;
	    self#horizontal_layout chain ;
	    self#baseline_layout chain ;
	    self#column_layout ctrls ;
	    lastrow <- ctrls ; 
	    ypadding <- dVsep
	      
  method add_separation = if ypadding <= dHsep then ypadding <- dSection
    
  method add_section text =
    begin
      let label = new Control.label ~text ~align:`Left ~style:`Title () in
      let lview = NSView.get label in
      NSView.add_subview box lview ;
      NSView.set_layout box kHsep box lview dHsep ;
      NSView.set_layout box kHfill lview box dHsep ;
      ypadding <- dSection ;
      let row = [lview] in 
      self#vertical_layout row ;
      lastrow <- row ; 
      ypadding <- dSection ; 
      xpadding <- dSection ;
    end
	  
  method add_control ?label (control : Widget.widget) = 
    self#add_row label [NSView.get control]

  method add_hbox ?label (ctrls : Widget.widget list) =
    self#add_row label (List.map NSView.get ctrls)
      
  method add_vbox ?label = function
    | [] -> ()
    | first::others ->
	self#add_control ?label first ;
	List.iter self#add_control others

  method add_pane ?label (pane : Widget.pane) =
    let view = NSView.get pane in
    match label with
      | Some _ -> self#add_row label [view]
      | None ->
	  NSView.add_subview box view ;
	  let row = [view] in
	  self#horizontal_layout row ;
	  self#vertical_layout row ;
	  lastrow <- row ;
	  ypadding <- dVsep

end
