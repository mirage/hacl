let key_length_bytes = 32

(* pk -> sk -> basepoint -> unit *)
external scalarmult_raw :
  Bigstring.t -> Bigstring.t -> Bigstring.t -> unit
  = "ml_Hacl_Curve25519_crypto_scalarmult"
  [@@noalloc]

let scalarmult_into ~result ~priv ~pub =
  let sizes_ok =
    Bigstring.length pub = key_length_bytes
    && Bigstring.length priv = key_length_bytes
    && Bigstring.length result = key_length_bytes
  in
  if sizes_ok then scalarmult_raw result priv pub
  else invalid_arg "wrong size"

let scalarmult_alloc ~priv ~pub =
  let result = Bigstring.create key_length_bytes in
  scalarmult_into ~result ~priv ~pub;
  result
