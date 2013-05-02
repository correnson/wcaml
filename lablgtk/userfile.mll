{

  type token =
    | ID of string
    | TEXT of string
    | DEF
    | SEP
    | END
    | EOF
    | BLOB

}

rule token = parse
    [ ' ' '\t' '\n' '\r' ] { token lexbuf }
  | '#' [^'\n']* '\n' { token lexbuf }
  | '=' { DEF }
  | ',' { SEP }
  | ';' { END }
  | eof { EOF }
  | ['a'-'z' 'A'-'Z' '.' '0'-'9' '-' ':' '_' '/' '\\']+ 
      { ID (Lexing.lexeme lexbuf) }
  | '"' {
      let buffer = Buffer.create 80 in
      text buffer lexbuf ; 
      TEXT (Buffer.contents buffer)
    } 
  | _ { BLOB }

and text buffer = parse
    '"' { () }
  | "\\n"  { Buffer.add_char buffer '\n' ; text buffer lexbuf } 
  | "\\r"  { Buffer.add_char buffer '\r' ; text buffer lexbuf } 
  | "\\t"  { Buffer.add_char buffer '\t' ; text buffer lexbuf } 
  | "\\\""  { Buffer.add_char buffer '"' ; text buffer lexbuf } 
  | "\\\'"  { Buffer.add_char buffer '\'' ; text buffer lexbuf } 
  | "\\" (['0'-'9']+ as d)  {
      Buffer.add_char buffer 
	(try char_of_int (int_of_string d) 
	 with _ -> '?') ;
      text buffer lexbuf
    } 
  | _ { Buffer.add_string buffer (Lexing.lexeme lexbuf) ; text buffer lexbuf }

{

  let rec parse_prop f lex =
    match token lex with
      | EOF -> ()
      | ID a | TEXT a -> parse_entry f lex a []
      | BLOB | SEP | DEF | END -> parse_prop f lex

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

}
