# 1 "userfile.mll"
 

  type token =
    | ID of string
    | TEXT of string
    | DEF
    | SEP
    | END
    | EOF
    | BLOB


# 15 "userfile.ml"
let __ocaml_lex_tables = {
  Lexing.lex_base = 
   "\000\000\247\255\248\255\078\000\250\255\251\255\252\255\253\255\
    \001\000\255\255\254\255\002\000\004\000\248\255\167\000\255\255\
    \177\000\250\255\251\255\252\255\253\255\254\255";
  Lexing.lex_backtrk = 
   "\255\255\255\255\255\255\006\000\255\255\255\255\255\255\255\255\
    \008\000\255\255\255\255\255\255\255\255\255\255\007\000\255\255\
    \006\000\255\255\255\255\255\255\255\255\255\255";
  Lexing.lex_default = 
   "\001\000\000\000\000\000\255\255\000\000\000\000\000\000\000\000\
    \011\000\000\000\000\000\011\000\013\000\000\000\255\255\000\000\
    \255\255\000\000\000\000\000\000\000\000\000\000";
  Lexing.lex_trans = 
   "\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\009\000\009\000\010\000\010\000\009\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \009\000\000\000\002\000\008\000\000\000\000\000\015\000\000\000\
    \000\000\000\000\000\000\000\000\006\000\003\000\003\000\003\000\
    \003\000\003\000\003\000\003\000\003\000\003\000\003\000\003\000\
    \003\000\003\000\003\000\005\000\000\000\007\000\000\000\000\000\
    \000\000\003\000\003\000\003\000\003\000\003\000\003\000\003\000\
    \003\000\003\000\003\000\003\000\003\000\003\000\003\000\003\000\
    \003\000\003\000\003\000\003\000\003\000\003\000\003\000\003\000\
    \003\000\003\000\003\000\000\000\003\000\000\000\000\000\003\000\
    \014\000\003\000\003\000\003\000\003\000\003\000\003\000\003\000\
    \003\000\003\000\003\000\003\000\003\000\003\000\003\000\003\000\
    \003\000\003\000\003\000\003\000\003\000\003\000\003\000\003\000\
    \003\000\003\000\003\000\003\000\003\000\003\000\003\000\003\000\
    \003\000\003\000\003\000\003\000\003\000\003\000\003\000\003\000\
    \003\000\000\000\000\000\000\000\000\000\000\000\000\000\003\000\
    \003\000\003\000\003\000\003\000\003\000\003\000\003\000\003\000\
    \003\000\003\000\003\000\003\000\003\000\003\000\003\000\003\000\
    \003\000\003\000\003\000\003\000\003\000\003\000\003\000\003\000\
    \003\000\000\000\003\000\000\000\000\000\003\000\000\000\003\000\
    \003\000\003\000\003\000\003\000\003\000\003\000\003\000\003\000\
    \003\000\003\000\003\000\003\000\003\000\003\000\003\000\003\000\
    \003\000\003\000\003\000\003\000\003\000\003\000\003\000\003\000\
    \003\000\018\000\000\000\000\000\000\000\000\000\017\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\016\000\
    \016\000\016\000\016\000\016\000\016\000\016\000\016\000\016\000\
    \016\000\016\000\016\000\016\000\016\000\016\000\016\000\016\000\
    \016\000\016\000\016\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \004\000\255\255\255\255\000\000\255\255\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\021\000\000\000\000\000\
    \000\000\020\000\000\000\019\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000";
  Lexing.lex_check = 
   "\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\000\000\000\000\008\000\011\000\000\000\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \000\000\255\255\000\000\000\000\255\255\255\255\012\000\255\255\
    \255\255\255\255\255\255\255\255\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\255\255\000\000\255\255\255\255\
    \255\255\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\255\255\000\000\255\255\255\255\000\000\
    \012\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\003\000\003\000\003\000\003\000\003\000\
    \003\000\003\000\003\000\003\000\003\000\003\000\003\000\003\000\
    \003\000\255\255\255\255\255\255\255\255\255\255\255\255\003\000\
    \003\000\003\000\003\000\003\000\003\000\003\000\003\000\003\000\
    \003\000\003\000\003\000\003\000\003\000\003\000\003\000\003\000\
    \003\000\003\000\003\000\003\000\003\000\003\000\003\000\003\000\
    \003\000\255\255\003\000\255\255\255\255\003\000\255\255\003\000\
    \003\000\003\000\003\000\003\000\003\000\003\000\003\000\003\000\
    \003\000\003\000\003\000\003\000\003\000\003\000\003\000\003\000\
    \003\000\003\000\003\000\003\000\003\000\003\000\003\000\003\000\
    \003\000\014\000\255\255\255\255\255\255\255\255\014\000\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\014\000\
    \014\000\014\000\014\000\014\000\014\000\014\000\014\000\014\000\
    \014\000\016\000\016\000\016\000\016\000\016\000\016\000\016\000\
    \016\000\016\000\016\000\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \000\000\008\000\011\000\255\255\012\000\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\014\000\255\255\255\255\
    \255\255\014\000\255\255\014\000\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255";
  Lexing.lex_base_code = 
   "";
  Lexing.lex_backtrk_code = 
   "";
  Lexing.lex_default_code = 
   "";
  Lexing.lex_trans_code = 
   "";
  Lexing.lex_check_code = 
   "";
  Lexing.lex_code = 
   "";
}

let rec token lexbuf =
    __ocaml_lex_token_rec lexbuf 0
and __ocaml_lex_token_rec lexbuf __ocaml_lex_state =
  match Lexing.engine __ocaml_lex_tables __ocaml_lex_state lexbuf with
      | 0 ->
# 15 "userfile.mll"
                           ( token lexbuf )
# 162 "userfile.ml"

  | 1 ->
# 16 "userfile.mll"
                      ( token lexbuf )
# 167 "userfile.ml"

  | 2 ->
# 17 "userfile.mll"
        ( DEF )
# 172 "userfile.ml"

  | 3 ->
# 18 "userfile.mll"
        ( SEP )
# 177 "userfile.ml"

  | 4 ->
# 19 "userfile.mll"
        ( END )
# 182 "userfile.ml"

  | 5 ->
# 20 "userfile.mll"
        ( EOF )
# 187 "userfile.ml"

  | 6 ->
# 22 "userfile.mll"
      ( ID (Lexing.lexeme lexbuf) )
# 192 "userfile.ml"

  | 7 ->
# 23 "userfile.mll"
        (
      let buffer = Buffer.create 80 in
      text buffer lexbuf ; 
      TEXT (Buffer.contents buffer)
    )
# 201 "userfile.ml"

  | 8 ->
# 28 "userfile.mll"
      ( BLOB )
# 206 "userfile.ml"

  | __ocaml_lex_state -> lexbuf.Lexing.refill_buff lexbuf; __ocaml_lex_token_rec lexbuf __ocaml_lex_state

and text buffer lexbuf =
    __ocaml_lex_text_rec buffer lexbuf 12
and __ocaml_lex_text_rec buffer lexbuf __ocaml_lex_state =
  match Lexing.engine __ocaml_lex_tables __ocaml_lex_state lexbuf with
      | 0 ->
# 31 "userfile.mll"
        ( () )
# 217 "userfile.ml"

  | 1 ->
# 32 "userfile.mll"
           ( Buffer.add_char buffer '\n' ; text buffer lexbuf )
# 222 "userfile.ml"

  | 2 ->
# 33 "userfile.mll"
           ( Buffer.add_char buffer '\r' ; text buffer lexbuf )
# 227 "userfile.ml"

  | 3 ->
# 34 "userfile.mll"
           ( Buffer.add_char buffer '\t' ; text buffer lexbuf )
# 232 "userfile.ml"

  | 4 ->
# 35 "userfile.mll"
            ( Buffer.add_char buffer '"' ; text buffer lexbuf )
# 237 "userfile.ml"

  | 5 ->
# 36 "userfile.mll"
            ( Buffer.add_char buffer '\'' ; text buffer lexbuf )
# 242 "userfile.ml"

  | 6 ->
let
# 37 "userfile.mll"
                        d
# 248 "userfile.ml"
= Lexing.sub_lexeme lexbuf (lexbuf.Lexing.lex_start_pos + 1) lexbuf.Lexing.lex_curr_pos in
# 37 "userfile.mll"
                            (
      Buffer.add_char buffer 
	(try char_of_int (int_of_string d) 
	 with _ -> '?') ;
      text buffer lexbuf
    )
# 257 "userfile.ml"

  | 7 ->
# 43 "userfile.mll"
      ( Buffer.add_string buffer (Lexing.lexeme lexbuf) ; text buffer lexbuf )
# 262 "userfile.ml"

  | __ocaml_lex_state -> lexbuf.Lexing.refill_buff lexbuf; __ocaml_lex_text_rec buffer lexbuf __ocaml_lex_state

;;

# 45 "userfile.mll"
 

  let rec parse_prop f lex =
    match token lex with
      | EOF -> ()
      | ID a -> parse_entry f lex a []
      | _ -> parse_prop f lex

  and parse_entry f lex a xs =
    match token lex with
      | EOF -> f a (List.rev xs)
      | END -> f a (List.rev xs) ; parse_prop f lex
      | DEF | SEP | BLOB -> parse_entry f lex a xs
      | TEXT s | ID s -> parse_entry f lex a (s::xs)

  let parse f file =
    if Sys.file_exists file then
      let inc = open_in file in
      let lex = Lexing.from_channel inc in
      try parse_prop f lex ; close_in inc
      with e -> close_in inc ; raise e

  let output_value out a =
    try String.iter 
      (function
	 | '0' .. '9' | 'a' .. 'z' | 'A' .. 'Z' | '.' -> ()
	 | _ -> raise Exit) 
      a ; output_string out a
    with Exit ->
      begin
	output_char out '"' ;
	output_string out (String.escaped a) ;
	output_char out '"' ;
      end

  let dump iter file =
    let out = open_out file in
    try iter 
      begin fun a xs -> 
	match xs with
	  | [] -> ()
	  | x::xs ->
	      output_value out a ;
	      output_string out " = " ;
	      output_value out x ;
	      List.iter 
		(fun y -> 
		   output_string out ", " ; 
		   output_value out y ;
		) xs ;
	      output_string out " ;\n" ;
	      flush out ;
      end ;
      close_out out
    with e -> 
      close_out out ; raise e


# 327 "userfile.ml"