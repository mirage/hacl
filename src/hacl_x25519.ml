let key_length_bytes = 32

let ( >>| ) r f =
  match r with
  | Ok x ->
      Ok (f x)
  | Error _ as e ->
      e

type error = [`Invalid_length]

let pp_error ppf = function
  | `Invalid_length ->
      Format.fprintf ppf "Invalid key size"

type secret = [`Checked of Cstruct.t]

let of_cstruct cs =
  if Cstruct.len cs = key_length_bytes then Ok (`Checked cs)
  else Error `Invalid_length

let priv_key_of_cstruct = of_cstruct

let priv_key_to_cstruct (`Checked cs) = cs

(* pk -> sk -> basepoint -> unit *)
external scalarmult_raw :
  Cstruct.buffer -> Cstruct.buffer -> Cstruct.buffer -> unit
  = "ml_Hacl_Curve25519_crypto_scalarmult"
  [@@noalloc]

let checked_buffer (`Checked cs) = Cstruct.to_bigarray cs

let key_exchange_buffer ~priv ~checked_pub =
  let cs = Cstruct.create key_length_bytes in
  let result = `Checked cs in
  scalarmult_raw (checked_buffer result) (checked_buffer priv) checked_pub;
  cs

let key_exchange priv pub =
  of_cstruct pub
  >>| checked_buffer
  >>| fun checked_pub -> key_exchange_buffer ~priv ~checked_pub

let basepoint =
  let cs = Cstruct.create key_length_bytes in
  Cstruct.set_uint8 cs 0 9; Cstruct.to_bigarray cs

let public priv = key_exchange_buffer ~priv ~checked_pub:basepoint
