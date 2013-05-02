(** {1 Main Entry Points} *)

open Event

val init : unit -> unit (** To be called {i before} any call to the library. *)
val main : unit -> unit (** Runs the main event loop. *)
val quit : unit -> unit (** Quits the main event loop. *)

val on_init : unit callback
val on_main : unit callback
val on_quit : unit callback

val later : unit callback (** Runs the job during idle time. *)
