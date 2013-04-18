
open Event

(** {1 Main Entry Points} *)

val init : appid:string -> unit (** To be called {i before} any call to the library. *)
val main : unit -> unit (** Runs the main event loop. *)
val quit : unit -> unit (** Quits the main event loop. *)

val on_init : unit signal
val on_main : unit signal
val on_quit : unit signal
