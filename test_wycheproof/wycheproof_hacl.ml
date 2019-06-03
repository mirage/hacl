open Wycheproof

let check pp equal name expected got =
  if equal expected got then Format.printf "%s - ok\n" name
  else
    Format.printf "%s - error\nexpected:\n%a\ngot:\n%a\n" name pp expected pp
      got

let priv_of_string s =
  match Hacl_x25519.priv_key_of_cstruct (Cstruct.of_string s) with
  | Ok x ->
      x
  | Error _ ->
      assert false

let pub_of_string s =
  match Hacl_x25519.pub_key_of_cstruct (Cstruct.of_string s) with
  | Ok x ->
      x
  | Error _ ->
      assert false

let key_exchange ~priv ~pub =
  Cstruct.to_string
    (Hacl_x25519.key_exchange ~priv:(priv_of_string priv)
       ~pub:(pub_of_string pub))

let run_test {tcId; comment; private_; public; shared = expected; _} =
  let name = Printf.sprintf "%d - %s" tcId comment in
  let got = key_exchange ~priv:private_ ~pub:public in
  check Wycheproof.pp_hex Wycheproof.equal_hex name expected got

let () =
  List.iter (fun group -> List.iter run_test group.tests) x25519.testGroups
