let of_hex s = `Hex s |> Hex.to_cstruct |> Cstruct.to_bigarray

let pp_hex fmt x = Cstruct.of_bigarray x |> Hex.of_cstruct |> Hex.pp fmt

let result fmt f =
  match f () with
  | result ->
      Format.fprintf fmt "%a" pp_hex result
  | exception _ ->
      Format.fprintf fmt "raised"

let kx ~priv ~pub () = Hacl.scalarmult_alloc ~priv ~pub

let test ~name ~priv ~pub =
  Format.printf "%s: %a\n" name result (kx ~priv ~pub)

let () =
  let pub =
    of_hex "9c647d9ae589b9f58fdc3ca4947efbc915c4b2e08e744a0edf469dac59c8f85a"
  in
  let priv =
    of_hex "4852834d9d6b77dadeabaaf2e11dca66d19fe74993a7bec36c6e16a0983feaba"
  in
  let too_short = Bigstring.create 31 in
  let too_long = Bigstring.create 33 in
  test ~name:"ok" ~priv ~pub;
  test ~name:"public too short" ~priv ~pub:too_short;
  test ~name:"public too long" ~priv ~pub:too_long;
  test ~name:"private too short" ~priv:too_short ~pub;
  test ~name:"private too long" ~priv:too_long ~pub
