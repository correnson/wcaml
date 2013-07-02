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

(* -------------------------------------------------------------------------- *)
(* --- Toolbar Layout                                                     --- *)
(* -------------------------------------------------------------------------- *)

let baseline box (chain : NSView.t list) =
  if chain <> [] then
    let line = 
      try List.find NSView.has_baseline chain 
      with Not_found -> List.hd chain in
    List.iter
      (fun ctrl -> if ctrl != line then
	 NSView.set_layout box kBaseline line ctrl 0)
      chain
      
let rec horizontal box = function
  | [] -> ()
  | [last] -> 
      NSView.set_layout box kHfill last box dHsep
  | a::((b::_) as trail) ->
      NSView.set_layout box kHsep a b dHsep ;
      horizontal box trail

let vertical box a c b =
  begin
    NSView.set_layout box kVsep a c dVsep ;
    NSView.set_layout box kVsep c b dVsep ;
  end

class toolbar (controls : Widget.widget list) (content : Widget.pane) =
  let box = NSView.create () in
  let ctrls = List.map NSView.get controls in
  let pane = NSView.get content in
object
  inherit NSView.pane box
  initializer
    begin
      NSView.add_subview box pane ;
      NSView.set_autolayout pane false ;
      NSView.set_layout box kHsep box pane 0 ;
      NSView.set_layout box kHsep pane box 0 ;
      NSView.set_layout box kVsep pane box 0 ;
      if ctrls = [] then 
	NSView.set_layout box kVsep box pane 0
      else
	begin
	  List.iter (NSView.add_subview box) ctrls ;
	  baseline box ctrls ;
	  horizontal box (box::ctrls) ;
	  List.iter (fun c -> vertical box box c pane) ctrls ;
	end ;
      Main.on_main (fun () -> NSView.debug pane)
    end
end

(* -------------------------------------------------------------------------- *)
(* --- Forms Layout                                                       --- *)
(* -------------------------------------------------------------------------- *)

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
	     
  method private baseline_layout chain = baseline box chain

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
	  NSView.set_autolayout view false ;
	  let row = [view] in
	  self#horizontal_layout row ;
	  self#vertical_layout row ;
	  lastrow <- row ;
	  ypadding <- dVsep

end

(* -------------------------------------------------------------------------- *)
(* --- Split Panes                                                        --- *)
(* -------------------------------------------------------------------------- *)

module NSSplit =
struct
  type t
  let as_view : t -> NSView.t = Obj.magic
  let kHsplit = 1
  let kVsplit = 2
  external create : int -> t = "wcaml_nssplit_create"
  external pack : t -> NSView.t -> unit = "wcaml_nssplit_pack"
  external side : t -> NSView.t -> unit = "wcaml_nssplit_side"
  external autosave : t -> NSString.t -> unit = "wcaml_nssplit_autosave"
end

class split kdir id side (a:Widget.pane) (b:Widget.pane) =
  let split = NSSplit.create kdir in
object
  inherit NSView.pane (NSSplit.as_view split)
  initializer
    begin
      if side then
	NSSplit.side split (NSView.get a)
      else
	NSSplit.pack split (NSView.get a) ;
      NSSplit.pack split (NSView.get b) ;
      NSSplit.autosave split (NSString.of_string id) ;
    end
end

class sidebar ~id ~side ~pane =
object
  inherit split NSSplit.kHsplit id true side pane
end

class hsplit ~id ~left ~right = 
object
  inherit split NSSplit.kHsplit id false left right
end

class vsplit ~id ~top ~bottom = 
object
  inherit split NSSplit.kVsplit id false top bottom
end

(* -------------------------------------------------------------------------- *)
