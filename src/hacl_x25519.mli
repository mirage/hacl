val key_length_bytes : int
(** The length of public and private keys, in bytes. Equal to 32. *)

type public

type private_

val public_of_cstruct : Cstruct.t -> (public, string) result
(** Raises [Invalid_size] if input is not [key_length_bytes] bytes long. *)

val public_to_cstruct : public -> Cstruct.t

val private_of_cstruct : Cstruct.t -> (private_, string) result
(** Raises [Invalid_size] if input is not [key_length_bytes] bytes long. *)

val private_to_cstruct : private_ -> Cstruct.t

val public : private_ -> public
(** Compute the public part corresponding to a private key. *)

val key_exchange : priv:private_ -> pub:public -> Cstruct.t
(** Perform Diffie-Hellman key exchange between a private part and a public
    part.

    In DH terms, the private part corresponds to a scalar, and the public part
    corresponds to a point, and this computes the scalar multiplication.

    The following holds: [key_exchange ~pub:(public a) ~priv:b = key_exchange ~pub:(public
    b) ~priv:a].
*)
