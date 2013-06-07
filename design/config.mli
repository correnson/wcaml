(** Application Configuration *)

val app : string ref     (** Application Identifier *)
val name : string ref    (** Application Display Name *)
val version : string ref (** Application Version *)
val app_url : string ref  
  (** Application Domain in URL style.
      Typically: ["app.institute.org"]. *)

val app_file : string ref
  (** Application Domain in reversed URL style.
      Typically: ["org.institute.app"]. *)
