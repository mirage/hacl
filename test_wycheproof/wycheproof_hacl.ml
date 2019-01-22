open Wycheproof

let check pp equal name expected got =
  if equal expected got then Format.printf "%s - ok\n" name
  else
    Format.printf "%s - error\nexpected:\n%a\ngot:\n%a\n" name pp expected pp
      got

let run_test {tcId; comment; private_; public; shared = expected; _} =
  let name = Printf.sprintf "%d - %s" tcId comment in
  let result =
    Hacl_x25519.scalarmult_alloc
      ~priv:(Cstruct.of_string private_)
      ~pub:(Cstruct.of_string public)
  in
  let got = Cstruct.to_string result in
  check Wycheproof.pp_hex Wycheproof.equal_hex name expected got

let () =
  List.iter (fun group -> List.iter run_test group.tests) x25519.testGroups
