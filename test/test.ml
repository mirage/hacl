let print_result result_to_string ~name f x =
  match f x with
  | result ->
      Printf.printf "%s:\n%s\n" name (result_to_string result)
  | exception e ->
      Printf.printf "%s: raised %s\n" name (Printexc.to_string e)

let private_of_hex s = Hacl_x25519.private_of_cstruct (Cstruct.of_hex s)

let too_short = Cstruct.create 31

let too_long = Cstruct.create 33

let public_to_string public =
  Format.asprintf "%a" Cstruct.hexdump_pp
    (Hacl_x25519.public_to_cstruct public)

let private_to_string private_ =
  Format.asprintf "%a" Cstruct.hexdump_pp
    (Hacl_x25519.private_to_cstruct private_)

let test_public_of_cstruct () =
  let test = print_result public_to_string Hacl_x25519.public_of_cstruct in
  test ~name:"ok"
    (Cstruct.of_hex
       {| 9c647d9ae589b9f58fdc3ca4947efbc9
          15c4b2e08e744a0edf469dac59c8f85a |});
  test ~name:"public too short" too_short;
  test ~name:"public too long" too_long

let test_private_of_cstruct () =
  let test = print_result private_to_string Hacl_x25519.private_of_cstruct in
  test ~name:"ok"
    (Cstruct.of_hex
       {| 4852834d9d6b77dadeabaaf2e11dca66
          d19fe74993a7bec36c6e16a0983feaba |});
  test ~name:"private too short" too_short;
  test ~name:"private too long" too_long

(** Test private-to-public conversion.
    Data comes from RFC7748 6.1. *)
let test_to_public () =
  let alice_private =
    private_of_hex
      {| 77076d0a7318a57d3c16c17251b26645
         df4c2f87ebc0992ab177fba51db92c2a |}
  in
  let alice_public = Hacl_x25519.public alice_private in
  Printf.printf "alice_public:\n%s" (public_to_string alice_public);
  let bob_private =
    private_of_hex
      {| 5dab087e624a8a4b79e17f8b83800ee6
         6f3bb1292618b6fd1c2f8b27ff88e0eb |}
  in
  let bob_public = Hacl_x25519.public bob_private in
  Format.printf "bob_public:\n%s" (public_to_string bob_public);
  Format.printf "pub_a * priv_b =@,%a@," Cstruct.hexdump_pp
    (Hacl_x25519.key_exchange ~pub:alice_public ~priv:bob_private);
  Format.printf "pub_b * priv_a =@,%a@," Cstruct.hexdump_pp
    (Hacl_x25519.key_exchange ~pub:bob_public ~priv:alice_private)

let () =
  test_public_of_cstruct (); test_private_of_cstruct (); test_to_public ()
