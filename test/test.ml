let bigstring_hex s = Bigstring.of_string (Hex.to_string (`Hex s))

let raised fmt f =
  let s =
    match f () with
    | _ ->
        "did not raise"
    | exception _ ->
        "raised"
  in
  Format.fprintf fmt "%s\n" s

let kx ~private_ ~public () =
  let got = Bigstring.create Hacl.Box.ckbytes in
  Hacl.Box.scalarmult got private_ public;
  got

let () =
  let public =
    bigstring_hex
      "9c647d9ae589b9f58fdc3ca4947efbc915c4b2e08e744a0edf469dac59c8f85a"
  in
  let private_ =
    bigstring_hex
      "4852834d9d6b77dadeabaaf2e11dca66d19fe74993a7bec36c6e16a0983feaba"
  in
  let expected =
    bigstring_hex
      "87b7f212b627f7a54ca5e0bcdaddd5389d9de6156cdbcf8ebe14ffbcfb436551"
  in
  let too_short = Bigstring.create 31 in
  let too_long = Bigstring.create 33 in
  let kx_into bs () = Hacl.Box.scalarmult bs private_ public in
  Printf.printf "ok: %b\n"
    (Bigstring.equal expected (kx ~private_ ~public ()));
  Format.printf "public too short: %a" raised (kx ~private_ ~public:too_short);
  Format.printf "public too long: %a" raised (kx ~private_ ~public:too_long);
  Format.printf "private too short: %a" raised
    (kx ~private_:too_short ~public);
  Format.printf "private too long: %a" raised (kx ~private_:too_long ~public);
  Format.printf "result too short: %a" raised (kx_into too_short);
  Format.printf "result too long: %a" raised (kx_into too_long)
