
(** Signals and Handlers *)

type 'a action = 'a -> unit (** Actioner *)
type 'a callback = 'a action -> unit (** Handler *)

val apply  : 'a action list -> 'a action   (** Send value to all actions *)
val option : 'a action -> 'a option action (** Option.map *)
val list   : 'a action -> 'a list action   (** List.map *)
val array  : 'a action -> 'a array action  (** Array.map *)

(** Signal Handler *)
class virtual ['a] handler :
object
  method virtual connect : 'a callback
  method on_event : unit callback        (** Called on each signal *)
  method on_check : 'a -> bool callback  (** Compare each signal to the value *)
  method on_value : 'a -> unit callback  (** Called only when the value is signaled *)
end

(** Generic Signal *)
class ['a] signal :
object
  inherit ['a] handler
  method connect : 'a callback
  method remove : 'a callback (** Use physical equality [==] *)
  method set_enabled : bool action
  method fire : 'a action
  method emit : 'a -> unit action (** An action that sends the value *)
  method transmit_to : 
    'b. ((<fire : 'a action ; ..> as 'b) -> unit)
    (** Transmit changes to signal *)
end

(** Generic Selector *)
class ['a] selector : 'a ->
object
  inherit ['a] signal
  method set : 'a -> unit
  method get : 'a
  method send_to : 'a action -> unit action 
    (** Action that transmits the current value on demand. *)
  method mirror_to : 
    'b. ((<fire : 'a action ; ..> as 'b) -> unit)
    (** Transmit the current value and connect changes to signal. *)
end

(** Selector listening to changes only. Default comparator is [(=)]. *)
class ['a] state : ?equal:('a -> 'a -> bool) -> 'a -> ['a] selector

val mirror_values : master:'a #selector -> client:'a #selector -> unit
  (** Bi-directional connection. The initial value is taken from [master] *)

val mirror_signals : 'a #signal -> 'a #signal -> unit
  (** Bi-directional connection *)
