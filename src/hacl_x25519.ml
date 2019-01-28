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

let key_exchange ~priv ~pub =
  let cs = Cstruct.create key_length_bytes in
  let result = `Checked cs in
  scalarmult_raw (checked_buffer result) (checked_buffer priv)
    (checked_buffer pub);
  cs

let basepoint =
  let cs = Cstruct.create key_length_bytes in
  Cstruct.set_uint8 cs 0 9; `Checked cs

let public priv = `Checked (key_exchange ~priv ~pub:basepoint)
