let pp_result ppf = function
  | Ok result -> Cstruct.hexdump_pp ppf result
  | Error e -> Format.fprintf ppf "error: %a@." Hacl_x25519.pp_error e

let cstruct = Alcotest.testable Cstruct.hexdump_pp Cstruct.equal

let error = Alcotest.testable Hacl_x25519.pp_error ( = )

let hacl = Alcotest.(result cstruct error)

let test ~name ~pub ~priv expect =
  Alcotest.test_case name `Quick @@ fun () ->
  let result = Hacl_x25519.key_exchange priv pub in
  Alcotest.(check hacl) "result" result expect

let key_pair_of_cstruct data = Hacl_x25519.gen_key ~rng:(fun _ -> data)

let key_pair_of_priv_hex s = key_pair_of_cstruct (Cstruct.of_hex s)

let too_short = Cstruct.create 31

let too_long = Cstruct.create 33

(** Test private-to-public conversion and key exchange.
    Data comes from RFC7748 6.1 and Wycheproof. *)

let alice_private, alice_public =
  key_pair_of_priv_hex
    {| 77076d0a7318a57d3c16c17251b26645
       df4c2f87ebc0992ab177fba51db92c2a |}

let bob_private, bob_public =
  key_pair_of_priv_hex
    {| 5dab087e624a8a4b79e17f8b83800ee6
       6f3bb1292618b6fd1c2f8b27ff88e0eb |}

let test01 =
  test ~name:"too short" ~priv:alice_private ~pub:too_short
    (Error `Invalid_length)

let test02 =
  test ~name:"too long" ~priv:alice_private ~pub:too_long
    (Error `Invalid_length)

let test03 =
  test ~name:"pub_a * priv_b" ~pub:alice_public ~priv:bob_private
    (Ok
       (Cstruct.of_hex
          {|4a 5d 9d 5b a4 ce 2d e1  72 8e 3b f4 80 35 0f 25
                        e0 7e 21 c9 47 d1 9e 33  76 f0 9b 3c 1e 16 17 42|}))

let test04 =
  test ~name:"pub_b * priv_a" ~pub:bob_public ~priv:alice_private
    (Ok
       (Cstruct.of_hex
          {|4a 5d 9d 5b a4 ce 2d e1  72 8e 3b f4 80 35 0f 25
                        e0 7e 21 c9 47 d1 9e 33  76 f0 9b 3c 1e 16 17 42|}))

let zeroes = Cstruct.create 32

let test05 =
  test ~name:"pub = 0" ~pub:zeroes ~priv:alice_private (Error `Low_order)

let low_order_pub =
  Cstruct.of_hex
    {| e0eb7a7c3b41b8ae1656e3faf19fc46a
       da098deb9c32b1fd866205165f49b800 |}

let low_order_priv, _ =
  key_pair_of_priv_hex
    {| 10255c9230a97a30a458ca284a629669
       293a31890cda9d147febc7d1e22d6bb1 |}

let test06 =
  test ~name:"low order point" ~pub:low_order_pub ~priv:low_order_priv
    (Error `Low_order)

let () =
  Alcotest.run "hacl_x25519"
    [ ("RFC7748 6.1", [ test01; test02; test03; test04; test05; test06 ]) ]
