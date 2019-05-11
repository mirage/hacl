let key_length_bytes = 32

type pub

type priv

type _ key = [`Checked of Cstruct.t]

type pub_key = pub key

type priv_key = priv key

let of_cstruct cs =
  if Cstruct.len cs = key_length_bytes then Ok (`Checked cs)
  else Error "Invalid key size"

let to_cstruct (`Checked cs) = cs

(* pk -> sk -> basepoint -> unit *)
external scalarmult_raw :
  Cstruct.buffer -> Cstruct.buffer -> Cstruct.buffer -> unit
  = "ml_Hacl_Curve25519_crypto_scalarmult"
  [@@noalloc]

let checked_buffer (`Checked cs) = Cstruct.to_bigarray cs

let key_exchange_inplace ~shared:result ~priv ~pub =
  match of_cstruct result with
  | Ok result ->
    scalarmult_raw (checked_buffer result) (checked_buffer priv) (checked_buffer pub)
  | Error err -> invalid_arg err

let key_exchange ~priv ~pub =
  let shared = Cstruct.create key_length_bytes in
  key_exchange_inplace ~shared ~priv ~pub ;
  shared

let basepoint =
  let cs = Cstruct.create key_length_bytes in
  Cstruct.set_uint8 cs 0 9; `Checked cs

let public priv = `Checked (key_exchange ~priv ~pub:basepoint)
