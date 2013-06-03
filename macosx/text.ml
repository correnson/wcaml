(* -------------------------------------------------------------------------- *)
(* --- Text Port                                                          --- *)
(* -------------------------------------------------------------------------- *)

open Event
open Widget
open Port
open Portcontrol

type 'a printf = ('a,Format.formatter,unit) format -> 'a

type content = [ `Text | `Code ]

(* -------------------------------------------------------------------------- *)
(* ---  NSTextView Port                                                   --- *)
(* -------------------------------------------------------------------------- *)

module NSTextView =
struct
  type t
  external create : unit -> t = "wcaml_nstextview_create"
  external text_content : t -> unit = "wcaml_nstextview_text_content"
  external code_content : t -> unit = "wcaml_nstextview_code_content"
  external scroll : t -> NSView.t = "wcaml_nstextview_scroll"
  external set_editable : t -> bool -> unit = "wcaml_nstextview_set_editable"
  external length : t -> int = "wcaml_nstextview_length"
  external clear : t -> unit = "wcaml_nstextview_clear"
  external replace : t -> int -> int -> NSString.t -> unit 
    = "wcaml_nstextview_replace"
end

(* -------------------------------------------------------------------------- *)
(* ---  WCaml Bindings                                                    --- *)
(* -------------------------------------------------------------------------- *)

class textpane ~content ?(editable=false) () =
  let text = NSTextView.create () in
  let scroll = NSTextView.scroll text in
object(self)
  inherit NSView.pane scroll

  val buffer = Buffer.create 80
  val mutable insert = 0
  val mutable delete = 0
  val mutable fmtref = None

  (* -------------------------------------------------------------------------- *)
  (* ---  Content                                                           --- *)
  (* -------------------------------------------------------------------------- *)

  initializer 
    begin match content with
      | `Text -> NSTextView.text_content text
      | `Code -> NSTextView.code_content text
    end

  (* -------------------------------------------------------------------------- *)
  (* ---  Basics                                                            --- *)
  (* -------------------------------------------------------------------------- *)
    
  method set_editable = NSTextView.set_editable text
  initializer NSTextView.set_editable text editable

  method size = NSTextView.length text
  method clear () = NSTextView.clear text
  method printf : 'a. ?at:int -> ?length:int -> 'a printf =
    fun ?(at=0) ?(length=0) msg -> 
      insert <- if at = 0 then NSTextView.length text else at ;
      delete <- length ;
      Format.kfprintf 
	(fun fmt -> Format.pp_print_flush fmt ())
	self#fmt msg
      
  (* -------------------------------------------------------------------------- *)
  (* ---  Formatter                                                         --- *)
  (* -------------------------------------------------------------------------- *)

  method private fmt = match fmtref with Some fmt -> fmt | None ->
    let output_string s a b = if b > 0 then Buffer.add_substring buffer s a b in
    let output_flush () =
      begin
	let str = NSString.of_string (Buffer.contents buffer) in
	NSTextView.replace text insert delete str ;
	Buffer.clear buffer ;
      end in
    let fmt = Format.make_formatter output_string output_flush in
    fmtref <- Some fmt ; fmt

end
