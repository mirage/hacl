val key_length_bytes : int
(** The length of public and private keys, in bytes. Equal to 32. *)

type pub

type priv

type _ key

type pub_key = pub key

type priv_key = priv key

val of_cstruct : Cstruct.t -> (_ key, string) result
(** Raises [Invalid_size] if input is not [key_length_bytes] bytes long. *)

val to_cstruct : _ key -> Cstruct.t

val public : priv_key -> pub_key
(** Compute the public part corresponding to a private key. *)

val key_exchange : priv:priv_key -> pub:pub_key -> Cstruct.t
(** Perform Diffie-Hellman key exchange between a private part and a public
    part.

    In DH terms, the private part corresponds to a scalar, and the public part
    corresponds to a point, and this computes the scalar multiplication.

    The following holds: [key_exchange ~pub:(public a) ~priv:b = key_exchange ~pub:(public
    b) ~priv:a].
*)
