open Wycheproof

let hex = Alcotest.testable Wycheproof.pp_hex Wycheproof.equal_hex

let test ~private_ ~public ~expected () =
  let result =
    Hacl_x25519.scalarmult_alloc
      ~priv:(Cstruct.of_string private_)
      ~pub:(Cstruct.of_string public)
  in
  let got = Cstruct.to_string result in
  Alcotest.check hex "should be equal" expected got

let make_test {tcId; comment; private_; public; shared; _} =
  let name = Printf.sprintf "%d - %s" tcId comment in
  (name, `Quick, test ~private_ ~public ~expected:shared)

let tests =
  x25519.testGroups
  |> List.map (fun group -> List.map make_test group.tests)
  |> List.concat

let () = Alcotest.run "Wycheproof-hacl-x25519" [("test vectors", tests)]
