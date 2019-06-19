(** {{:https://en.wikipedia.org/wiki/Diffie%E2%80%93Hellman_key_exchange}
    Diffie-Hellman key exchange} over
    {{:https://en.wikipedia.org/wiki/Curve25519} Curve25519} (also known as
    X25519).

    This implementation uses C code from {{:https://project-everest.github.io/}
    Project Everest}, an effort to build and deploy a verified HTTPS stack.

    @see <https://tools.ietf.org/html/rfc7748> RFC7748, "Elliptic Curves for
    Security" - where this algorithm is defined.

    @see <https://tools.ietf.org/html/rfc8446#section-7.4.2> RFC8446, "The
    Transport Layer Security (TLS) Protocol Version 1.3", section 7.4.2 - how to
    use this in the context of TLS 1.3.
*)

val key_length_bytes : int
(** The length of public and private keys, in bytes. Equal to 32. *)

(** A private key. In elliptic curve terms, a scalar.

    To generate a key pair:
    - generate a random cstruct of length [key_length_bytes].
    - call [priv_key_of_cstruct] on it. This is the private key.
    - call [public] on the private key. This returns the corresponding public
    key.
*)
type secret

(** Kind of errors. *)
type error = [`Invalid_length]

val pp_error : Format.formatter -> error -> unit
(** Pretty printer for errors *)

val priv_key_of_cstruct : Cstruct.t -> (secret, error) result
(** Convert a [Cstruct.t] into a private key. Internally, this only checks that
    its length is [key_length_bytes]. If that is not the case, returns an error
    message. *)

val priv_key_to_cstruct : secret -> Cstruct.t
(** Return the [Cstruct.t] corresponding to a private key. It is always
    [key_length_bytes] bytes long. *)

val public : secret -> Cstruct.t
(** Compute the public part corresponding to a private key. Internally, this
    multiplies the curve's base point by the supplied scalar. *)

val key_exchange : secret -> Cstruct.t -> (Cstruct.t, error) result
(** Perform Diffie-Hellman key exchange between a private part and a public
    part.

    It checks length of the [pub] key and returns an error if it has an
    incorrect length.

    In DH terms, the private part corresponds to a scalar, and the public part
    corresponds to a point, and this computes the scalar multiplication.

    The following holds: [key_exchange ~pub:(public a) ~priv:b] is equal to
    [key_exchange ~pub:(public b) ~priv:a]. That is to say, two parties can
    generate key pairs, transmit the public parts, and compute on a shared
    secret without transmitting any private information.

    As described in {{: https://tools.ietf.org/html/rfc7748#section-6.1} RFC
    7748, section 6.1}, if this function operates on an input corresponding to
    a point with small order, it will return an all-zero value.

    Whether this is an error case or not depends on the protocol. {{:
    https://tools.ietf.org/html/rfc8446#section-7.4.2} In the context of TLS
    1.3}, "implementations MUST check whether the computed Diffie-Hellman shared
    secret is the all-zero value and abort if so". This should be done in
    constant time, for example by using the {{: https://github.com/mirage/eqaf/}
    eqaf} library. *)
