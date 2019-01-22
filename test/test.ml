let result fmt f =
  match f () with
  | result ->
      Cstruct.hexdump_pp fmt result
  | exception e ->
      Format.fprintf fmt "raised %s" (Printexc.to_string e)

let kx ~priv ~pub () = Hacl_x25519.key_exchange ~priv ~pub

let test_key_exchange () =
  let test ~name ~priv ~pub =
    Format.printf "%s: %a\n" name result (kx ~priv ~pub)
  in
  let pub =
    Cstruct.of_hex
      {| 9c647d9ae589b9f58fdc3ca4947efbc9
         15c4b2e08e744a0edf469dac59c8f85a |}
  in
  let priv =
    Cstruct.of_hex
      {| 4852834d9d6b77dadeabaaf2e11dca66
         d19fe74993a7bec36c6e16a0983feaba |}
  in
  let too_short = Cstruct.create 31 in
  let too_long = Cstruct.create 33 in
  test ~name:"ok" ~priv ~pub;
  test ~name:"public too short" ~priv ~pub:too_short;
  test ~name:"public too long" ~priv ~pub:too_long;
  test ~name:"private too short" ~priv:too_short ~pub;
  test ~name:"private too long" ~priv:too_long ~pub

(** Test private-to-public conversion.
    Data comes from RFC7748 6.1. *)
let test_to_public () =
  let alice_private =
    Cstruct.of_hex
      {| 77076d0a7318a57d3c16c17251b26645
         df4c2f87ebc0992ab177fba51db92c2a |}
  in
  let alice_public = Hacl_x25519.public alice_private in
  Format.printf "alice_public:@,%a@," Cstruct.hexdump_pp alice_public;
  let bob_private =
    Cstruct.of_hex
      {| 5dab087e624a8a4b79e17f8b83800ee6
         6f3bb1292618b6fd1c2f8b27ff88e0eb |}
  in
  let bob_public = Hacl_x25519.public bob_private in
  Format.printf "bob_public:@,%a@," Cstruct.hexdump_pp bob_public;
  Format.printf "pub_a * priv_b =@,%a@," Cstruct.hexdump_pp
    (Hacl_x25519.key_exchange ~pub:alice_public ~priv:bob_private);
  Format.printf "pub_b * priv_a =@,%a@," Cstruct.hexdump_pp
    (Hacl_x25519.key_exchange ~pub:bob_public ~priv:alice_private)

let () = test_key_exchange (); test_to_public ()
