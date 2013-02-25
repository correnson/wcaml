
(** {1 Main Entry Points} *)

val init : unit -> unit (** To be called {i before} any call to the library. *)
val run : unit -> unit (** Runs the main event loop. *)
val quit : unit -> unit (** Quits the main event loop. *)
