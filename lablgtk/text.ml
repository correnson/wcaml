(* -------------------------------------------------------------------------- *)
(* --- Text Area Port                                                     --- *)
(* -------------------------------------------------------------------------- *)

open Event
open Widget
open Port

type 'a printf = ('a,Format.formatter,unit) format -> 'a
  
class textpane ?(editable=true) () =
  let scroll = GBin.scrolled_window () in
  let buffer = GText.buffer () in
  let view = GText.view ~buffer
    ~editable ~cursor_visible:editable
    ~justification:`LEFT
    ~wrap_mode:`NONE
    ~accepts_tab:false
    ~packing:scroll#add () in
object(self)
  inherit Port.pane scroll#coerce
    
  val mutable fmtref = None
  val mutable insert = buffer#end_iter
  val text = Buffer.create 80
    
  (* -------------------------------------------------------------------------- *)
  (* ---  Basics                                                            --- *)
  (* -------------------------------------------------------------------------- *)
    
  method set_editable = view#set_editable
  method size = buffer#char_count
  method clear () =
    let (start,stop) = buffer#bounds in
    buffer#delete ~start ~stop
  method printf : 'a. ?at:int -> ?length:int -> 'a printf =
    fun ?at ?length msg -> 
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

end
