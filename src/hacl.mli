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

module Box : sig
  type combined

  type _ key

  val skbytes : int

  val pkbytes : int

  val ckbytes : int

  val zerobytes : int

  val boxzerobytes : int

  val equal : 'a key -> 'a key -> bool

  val unsafe_to_bytes : _ key -> Bigstring.t
  (** [unsafe_to_bytes k] is the internal [Bigstring.t] where the key
      is stored. DO NOT MODIFY. *)

  val blit_to_bytes : _ key -> ?pos:int -> Bigstring.t -> unit

  val unsafe_sk_of_bytes : Bigstring.t -> secret key
  (** @raise Invalid_argument if argument is not [skbytes] bytes long *)

  val unsafe_pk_of_bytes : Bigstring.t -> public key
  (** @raise Invalid_argument if argument is not [pkbytes] bytes long *)

  val unsafe_ck_of_bytes : Bigstring.t -> combined key
  (** @raise Invalid_argument if argument is not [ckbytes] bytes long *)

  val of_seed : ?pos:int -> Bigstring.t -> secret key
  (** @raise Invalid_argument if [pos] is outside the buffer or the buffer
      is less than [skbytes] bytes long *)

  val neuterize : secret key -> public key

  val scalarmult : Bigstring.t -> Bigstring.t -> Bigstring.t -> unit
end
