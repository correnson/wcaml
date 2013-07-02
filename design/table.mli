(** Table Layout *)

open Event
open Widget
open Model

(** List Table Layout *)

class ['a] list : id:string -> ?model:'a Model.list -> ?headers:bool -> 
  unit -> ['a,'a Model.list] Model.view
  (** Headers are visible by default. Model can be bound later. *)


(** Tree Table Layout *)

class ['a] tree : id:string -> ?model:'a Model.tree -> ?headers:bool -> 
  unit -> ['a,'a Model.tree] Model.view
  (** Headers are visible by default. Model can be bound later. *)

