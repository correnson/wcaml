(** Table Layout *)

open Event
open Widget
open Model

(** List Table Layout *)

class ['a] list : id:string -> model:'a Model.list -> ?headers:bool -> 
  unit -> ['a] Model.view

(** Tree Table Layout *)

class ['a] tree : id:string -> model:'a Model.tree -> ?headers:bool -> 
  unit -> ['a] Model.view

