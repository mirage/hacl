(* Copyright 2018 Vincent Bernardoff, Marco Stronati.
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. *)

type secret

type public

module Box = struct
  type combined

  type _ key =
    | Sk : Bigstring.t -> secret key
    | Pk : Bigstring.t -> public key
    | Ck : Bigstring.t -> combined key

  let skbytes = 32

  let pkbytes = 32

  let ckbytes = 32

  let zerobytes = 32

  let boxzerobytes = 16

  let unsafe_to_bytes : type a. a key -> Bigstring.t = function
    | Pk buf ->
        buf
    | Sk buf ->
        buf
    | Ck buf ->
        buf

  let blit_to_bytes : type a. a key -> ?pos:int -> Bigstring.t -> unit =
   fun key ?(pos = 0) buf ->
    match key with
    | Pk pk ->
        Bigstring.blit pk 0 buf pos pkbytes
    | Sk sk ->
        Bigstring.blit sk 0 buf pos skbytes
    | Ck ck ->
        Bigstring.blit ck 0 buf pos ckbytes

  let equal : type a. a key -> a key -> bool =
   fun a b ->
    match (a, b) with
    | Pk a, Pk b ->
        Bigstring.equal a b
    | Sk a, Sk b ->
        Bigstring.equal a b
    | Ck a, Ck b ->
        Bigstring.equal a b

  let unsafe_sk_of_bytes buf =
    if Bigstring.length buf <> skbytes then
      invalid_arg
        (Printf.sprintf "Box.unsafe_sk_of_bytes: buffer must be %d bytes long"
           skbytes);
    Sk buf

  let unsafe_pk_of_bytes buf =
    if Bigstring.length buf <> pkbytes then
      invalid_arg
        (Printf.sprintf "Box.unsafe_pk_of_bytes: buffer must be %d bytes long"
           pkbytes);
    Pk buf

  let unsafe_ck_of_bytes buf =
    if Bigstring.length buf <> ckbytes then
      invalid_arg
        (Printf.sprintf "Box.unsafe_ck_of_bytes: buffer must be %d bytes long"
           ckbytes);
    Ck buf

  let of_seed ?(pos = 0) buf =
    let buflen = Bigstring.length buf in
    if pos < 0 || pos + skbytes > buflen then
      invalid_arg
        (Printf.sprintf "Box.of_seed: invalid pos (%d) or buffer size (%d)"
           pos buflen);
    let sk = Bigstring.create skbytes in
    Bigstring.blit buf pos sk 0 skbytes;
    Sk sk

  let basepoint =
    Bigstring.init 32 (function
      | 0 ->
          '\x09'
      | _ ->
          '\x00' )

  (* pk -> sk -> basepoint -> unit *)
  external scalarmult_raw :
    Bigstring.t -> Bigstring.t -> Bigstring.t -> unit
    = "ml_Hacl_Curve25519_crypto_scalarmult"
    [@@noalloc]

  let scalarmult result priv pub =
    let sizes_ok =
      Bigstring.length pub = pkbytes
      && Bigstring.length priv = skbytes
      && Bigstring.length result = ckbytes
    in
    if sizes_ok then scalarmult_raw result priv pub
    else invalid_arg "wrong size"

  let neuterize (Sk sk) =
    let pk = Bigstring.create pkbytes in
    scalarmult pk sk basepoint; Pk pk
end
