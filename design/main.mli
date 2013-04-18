
(** {1 Main Entry Points} *)

val init : appid:string -> unit (** To be called {i before} any call to the library. *)
val run  : unit signal (** Runs the main event loop. *)
val quit : unit signal (** Quits the main event loop. *)

