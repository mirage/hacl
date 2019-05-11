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

(** A cryptographic key (public or private).
    To generate a key pair:
    - generate a random cstruct of length [key_length_bytes].
    - call [of_cstruct] on it. This is the private key.
    - call [public] on the private key. This returns the corresponding public
    key.

    This uses phantom types to make [of_cstruct] and [to_cstruct] polymorphic in
    the key type.
*)
type _ key

type priv

(** A private key. In elliptic curve terms, a scalar. *)
type priv_key = priv key

type pub

(** A private key. In elliptic curve terms, a point. *)
type pub_key = pub key

val of_cstruct : Cstruct.t -> (_ key, string) result
(** Convert a [Cstruct.t] into a key. Internally, this only checks that its
    length is [key_length_bytes]. If that is not the case, returns an error
    message. *)

val to_cstruct : _ key -> Cstruct.t
(** Return the [Cstruct.t] corresponding to a key. It is always
    [key_length_bytes] bytes long. *)

val public : priv_key -> pub_key
(** Compute the public part corresponding to a private key. Internally, this
    multiplies the curve's base point by the supplied scalar. *)

val key_exchange : priv:priv_key -> pub:pub_key -> Cstruct.t
(** Perform Diffie-Hellman key exchange between a private part and a public
    part. It makes a fresh allocated result.

    In DH terms, the private part corresponds to a scalar, and the public part
    corresponds to a point, and this computes the scalar multiplication.

    The following holds: [key_exchange ~pub:(public a) ~priv:b] is equal to
    [key_exchange ~pub:(public b) ~priv:a]. That is to say, two parties can
    generate key pairs, transmit the public parts, and compute on a shared
    secret without transmitting any private information.

    As described in {{: https://tools.ietf.org/html/rfc7748#section-6.1} RFC
    7748, section 6.1}, if this function operates on an input corresponding to a
    point with small order, it will return an all-zero value.

    Whether this is an error case or not depends on the protocol. {{:
    https://tools.ietf.org/html/rfc8446#section-7.4.2} In the context of TLS
    1.3}, "implementations MUST check whether the computed Diffie-Hellman shared
    secret is the all-zero value and abort if so". This should be done in
    constant time, for example by using the {{: https://github.com/mirage/eqaf/}
    eqaf} library. *)

val key_exchange_inplace : shared:Cstruct.t -> priv:priv_key -> pub:pub_key -> unit
(** Same as {!key_exchange} but without allocation. It uses the [shared]
    [Cstruct.t] argument as the result of the computation of Diffie-Hellman key
    exchange. Length of [shared] must be equal to {!key_length_bytes}. Otherwise,
    it raises an [Invalid_argument]. *)
