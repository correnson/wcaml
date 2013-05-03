    
type utf8 =
| U1
| U2
| U3
| U4
| Un
| La

type state =
| Head
| U12
| U13
| U23
| U14
| U24
| U34

let utf8 c =
  let c = int_of_char c in
  if c land 0x80 = 0 then U1 else
    if c land 0xC0 = 0x80 then Un else
      if c land 0xE0 = 0xC0 then U2 else
	if c land 0xF0 = 0xE0 then U3 else
	  if c land 0xF8 = 0xF0 then U4 else
	    La

let overhead = function
| Head -> 0
| U12 -> 1
| U13 -> 1
| U23 -> 2
| U14 -> 1
| U24 -> 2
| U34 -> 3

type lexer = {
  buffer : string ;
  mutable head : int ;
  mutable state : state ;
  flush : (unit -> unit) ;
  output : (string -> int -> int -> unit) ;
}

let create ?(size=128) output flush = {
  buffer = String.create size ;
  head = 0 ; state = Head ;
  flush = flush ; output = output ;
}

let flush w () =
  if w.head > 0 then
    begin
      w.output w.buffer 0 w.head ;
      let n = overhead w.state in
      if n > 0 then String.blit w.buffer w.head w.buffer 0 n ;
      w.head <- 0 ;
    end ;
  w.flush ()

let emit w k c = 
  w.buffer.[w.head + k] <- c ; 
  w.head <- w.head + k + 1 ;
  w.state <- Head

let push w k c st =
  w.buffer.[w.head + k] <- c ;
  w.state <- st

let add w c = match w.state , utf8 c with
  | Head , U1 -> emit w 0 c ; if c = '\n' then flush w ()
  | Head , U2 -> push w 0 c U12
  | U12  , Un -> emit w 1 c
  | Head , U3 -> push w 0 c U13
  | U13  , Un -> push w 1 c U23
  | U23  , Un -> emit w 2 c
  | Head , U4 -> push w 0 c U14
  | U14  , Un -> push w 1 c U24
  | U24  , Un -> push w 2 c U34
  | U34  , Un -> emit w 3 c
  | _    , U1 -> emit w 0 '?' ; emit w 0 c
  |        _  -> emit w 0 '?'

let rec output w s p n =
  let m = String.length w.buffer - w.head - 4 in
  let r = max 0 (min n m) in
  for i = p to p + r - 1 do
    add w s.[i] ;
  done ;
  if n > r then ( flush w () ; output w s (p+r) (n-r) )

let clear w = w.head <- 0 ; w.state <- Head
