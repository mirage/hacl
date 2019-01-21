let key_length_bytes = 32

(* pk -> sk -> basepoint -> unit *)
external scalarmult_raw :
  Cstruct.buffer -> Cstruct.buffer -> Cstruct.buffer -> unit
  = "ml_Hacl_Curve25519_crypto_scalarmult"
  [@@noalloc]

let checked_buffer cs =
  if Cstruct.len cs = key_length_bytes then Cstruct.to_bigarray cs
  else invalid_arg "wrong size"

let scalarmult_into ~result ~priv ~pub =
  scalarmult_raw (checked_buffer result) (checked_buffer priv)
    (checked_buffer pub)

let scalarmult_alloc ~priv ~pub =
  let result = Cstruct.create key_length_bytes in
  scalarmult_into ~result ~priv ~pub;
  result
