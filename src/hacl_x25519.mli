exception Invalid_size

val key_length_bytes : int
(** The length of public and private keys, in bytes. Equal to 32. *)

val public : Cstruct.t -> Cstruct.t
(** Compute the public part corresponding to a private key. *)

val key_exchange : priv:Cstruct.t -> pub:Cstruct.t -> Cstruct.t
(** Perform Diffie-Hellman key exchange between a private part and a public
    part.

    In DH terms, the private part corresponds to a scalar, and the public part
    corresponds to a point, and this computes the scalar multiplication.

    The following holds: [key_exchange ~pub:(public a) ~priv:b = key_exchange ~pub:(public
    b) ~priv:a].

    Raises [Invalid_size] if [priv] or [pub] is not [key_length_bytes] bytes long.
*)
