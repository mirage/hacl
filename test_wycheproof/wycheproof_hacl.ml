open Wycheproof

let hex = Alcotest.testable Wycheproof.pp_hex Wycheproof.equal_hex

let test ~private_ ~public ~expected () =
  let res = Bigstring.create Hacl.Box.ckbytes in
  Hacl.Box.scalarmult res
    (Bigstring.of_string private_)
    (Bigstring.of_string public);
  let got = Bigstring.to_string res in
  Alcotest.check hex "should be equal" expected got

let make_test {tcId; comment; private_; public; shared; _} =
  let name = Printf.sprintf "%d - %s" tcId comment in
  (name, `Quick, test ~private_ ~public ~expected:shared)

let tests =
  x25519.testGroups
  |> List.map (fun group -> List.map make_test group.tests)
  |> List.concat

let () = Alcotest.run "Wycheproof-hacl" [("test vectors", tests)]
