(* -------------------------------------------------------------------------- *)
(* --- Text Area Port                                                     --- *)
(* -------------------------------------------------------------------------- *)

open Event
open Widget
open Port

(* -------------------------------------------------------------------------- *)
(* --- Converting Style to Tags                                           --- *)
(* -------------------------------------------------------------------------- *)

type 'a printf = ('a,Format.formatter,unit) format -> 'a

type content = [ `Text | `Code ]

(*
let fg = function
  | `Black -> "Black"
  | `Grey  -> "Silver"
  | `Dark  -> "Gray"
  | `White -> "White"
  | `Green -> "Green"
  | `Orange -> "Orange"
  | `Red -> "Red"
  | `Blue -> "Blue"
  | `Yellow -> "Gold"
  | `Violet -> "BlueViolet"

let bg = function
  | `Black -> "Dark"
  | `Grey  -> "LightGrey"
  | `Dark  -> "DarkGray"
  | `White -> "White"
  | `Green -> "LightGreen"
  | `Orange -> "SandyBrown"
  | `Red -> "Red"
  | `Blue -> "SkyBlue"
  | `Yellow -> "Khaki"
  | `Violet -> "MediumOrchid"

let gstyle () = { gtext = [] ; gline = [] ; gfg = [] ; gbg = [] }

let apply g = function
  | `Text_rm -> g.gtext <- [`FONT "Cambria"]
  | `Text_tt -> g.gtext <- [`FONT "Monospace"]
  | `Text_sf -> g.gtext <- [`FONT "Helvetica"]
  | `Text_bd -> g.gtext <- [`WEIGHT `BOLD]
  | `Text_em -> g.gtext <- [`STYLE `ITALIC]
  | `Subscript -> g.gtext <- [`SCALE `SMALL ; `RISE (-2) ; `STYLE `ITALIC]
  | `Superscript -> g.gtext <- [`SCALE `SMALL ; `RISE 4]
  | `Underlined -> g.gline <- [`UNDERLINE `SINGLE]
  | `Warning -> g.gline <- [`UNDERLINE `DOUBLE] (* should be `ERROR *)
  | `Striked -> g.gline <- [`STRIKETHROUGH true]
  | `Fg color -> g.gfg <- [`FOREGROUND (fg color)]
  | `Bg color -> g.gbg <- [`BACKGROUND (bg color)]
  | `Link _ | `Mark _ -> ()
  | `Line _ -> ()
*)
	
(* -------------------------------------------------------------------------- *)
(* --- Text Pane                                                          --- *)
(* -------------------------------------------------------------------------- *)
  
class textpane ~content ?(editable=true) () =
  let scroll = GBin.scrolled_window 
    ~hpolicy:`AUTOMATIC
    ~vpolicy:`AUTOMATIC
    () in
  let buffer = GText.buffer () in
  let view = GText.view ~buffer
    ~editable ~cursor_visible:editable
    ~justification:`LEFT
    ~accepts_tab:false
    ~packing:scroll#add () in
object(self)
  inherit Port.pane scroll#coerce
    
  val mutable fmtref = None
  val mutable insert = buffer#end_iter
  val text = Buffer.create 80

  (* -------------------------------------------------------------------------- *)
  (* --- View Rendering                                                     --- *)
  (* -------------------------------------------------------------------------- *)
    
  initializer
    begin match content with
      | `Text ->
	  view#set_wrap_mode `WORD ;
	  view#misc#modify_font_by_name "Cambria"
      | `Code ->
	  view#set_wrap_mode `NONE ;
	  view#misc#modify_font_by_name "Monospace"
    end

  (* -------------------------------------------------------------------------- *)
  (* ---  Basics                                                            --- *)
  (* -------------------------------------------------------------------------- *)
    
  method set_editable = view#set_editable
  method size = buffer#char_count
  method clear () =
    let (start,stop) = buffer#bounds in
    buffer#delete ~start ~stop
  method printf 
    : 'a. ?at:int -> ?length:int -> 'a printf 
    = fun ?at ?length msg -> 
      Buffer.clear text ;
      self#set_insert at length ;
      Format.kfprintf 
	(fun fmt -> Format.pp_print_flush fmt ())
	self#fmt msg
	
  initializer 
    begin
      view#misc#modify_font_by_name "Monospace 10" ;
    end
      
  (* -------------------------------------------------------------------------- *)
  (* ---  Insertion Point Management                                        --- *)
  (* -------------------------------------------------------------------------- *)

  method private set_insert at length =
    begin
      match at with
	| None -> insert <- buffer#end_iter
	| Some p -> 
	    let start = buffer#get_iter (`OFFSET p) in
	    insert <- start ;
	    match at , length with
	      | Some p , Some n -> 
		  let stop = buffer#get_iter (`OFFSET (p+n-1)) in
		  buffer#delete ~start:insert ~stop
	      | _ -> ()
    end

  (* -------------------------------------------------------------------------- *)
  (* ---  Formatter                                                         --- *)
  (* -------------------------------------------------------------------------- *)

  method private fmt = match fmtref with Some fmt -> fmt | None ->
    let output_string s a b = if b > 0 then Buffer.add_substring text s a b in
    let output_flush () =
      if Buffer.length text > 0 then
	begin
	  let utf8 = 
	    let s = Buffer.contents text in
	    if Glib.Utf8.validate s then s else "<?utf8?>"
	  in
	  Buffer.clear text ;
	  buffer#insert ~tags:[] ~iter:insert utf8 ;
	end in
    let fmt = Format.make_formatter output_string output_flush in
    fmtref <- Some fmt ; fmt

  (* -------------------------------------------------------------------------- *)
  (* ---  Tags Management                                                   --- *)
  (* -------------------------------------------------------------------------- *)

end
