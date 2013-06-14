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
end

module NSTableColumn =
struct
  type t
  external create : NSTable.t -> NSString.t -> t = "wcaml_nstablecolumn_create"
  external set_title : t -> NSString.t -> unit = "wcaml_nstablecolumn_set_title"
end

(* -------------------------------------------------------------------------- *)
(* --- Delegate                                                           --- *)
(* -------------------------------------------------------------------------- *)

module ListSize = Port.Service
  (struct
     let name = "nstable_list_size"
     type nsobject = NSTable.t
     type signature = unit -> int
     let default () = 0
   end)

(* -------------------------------------------------------------------------- *)
(* --- Columns Management                                                 --- *)
(* -------------------------------------------------------------------------- *)

class ['a] gcolumns (wtable:NSTable.t) (headers:bool) =
object
  inherit NSView.pane (NSView.scroll (NSTable.as_view wtable))
  initializer if headers then NSTable.set_headers wtable

  method reload (_ : 'a option) = ()    
  method update (_ : 'a) = ()
  method update_all () = ()
  method added (_ : 'a) = ()
  method removed (_ : 'a) = ()

  method scroll (_ : 'a) = ()
  method on_click : 'a callback = fun _ -> ()
  method on_double_click : 'a callback = fun _ -> ()

  method add_icon_column : 'a icon_column cview = assert false
  method add_text_column : 'a text_column cview = assert false
  method add_tree_column : 'a itext_column cview = assert false
  method add_itext_column : 'a itext_column cview = assert false
  method add_check_column : 'a check_column cview = assert false

  method remove_colum (_ : 'a column) = ()
end

(* -------------------------------------------------------------------------- *)
(* --- Views                                                              --- *)
(* -------------------------------------------------------------------------- *)

class ['a] list ~id ~(model : 'a Model.list) ?(headers=true) () =
  let wtable = NSTable.create (NSString.of_string id) in
object
  inherit ['a] gcolumns wtable headers 
  initializer ignore headers
  initializer 
    begin
      ListSize.bind wtable (fun () -> model#size) ;
    end
end

class ['a] tree ~id ~(model : 'a Model.tree) ?(headers=true) () =
  let wtable = NSTable.create (NSString.of_string id) in
object
  inherit ['a] gcolumns wtable headers
  initializer ignore headers
  initializer ignore model
end

