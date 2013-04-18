(** Application Configuration *)

val app : string ref     (** Application Identifier *)
val name : string ref    (** Application Display Name *)
val version : string ref (** Application Version *)
val domain : string ref  (** Application Domain.
			     Typically: ["org.institute"], ["com.company"], etc. *)
