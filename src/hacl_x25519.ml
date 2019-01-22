exception Invalid_size

let key_length_bytes = 32

(* pk -> sk -> basepoint -> unit *)
external scalarmult_raw :
  Cstruct.buffer -> Cstruct.buffer -> Cstruct.buffer -> unit
  = "ml_Hacl_Curve25519_crypto_scalarmult"
  [@@noalloc]

let checked_buffer cs =
  if Cstruct.len cs = key_length_bytes then Cstruct.to_bigarray cs
  else raise Invalid_size

let scalarmult_into ~result ~priv ~pub =
  scalarmult_raw (checked_buffer result) (checked_buffer priv)
    (checked_buffer pub)

let key_exchange ~priv ~pub =
  let result = Cstruct.create key_length_bytes in
  scalarmult_into ~result ~priv ~pub;
  result

let basepoint =
  let cs = Cstruct.create key_length_bytes in
  Cstruct.set_uint8 cs 0 9;
  cs

let public priv =
  key_exchange ~priv ~pub:basepoint
