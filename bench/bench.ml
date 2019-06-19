let crypto_random_bytes n =
  let ic = Pervasives.open_in_bin "/dev/urandom" in
  let s = Pervasives.really_input_string ic n in
  close_in ic; s

let of_ok = function
  | Error _ ->
      assert false
  | Ok x ->
      x

let random_private_key () =
  crypto_random_bytes 32
  |> Cstruct.of_string
  |> Hacl_x25519.priv_key_of_cstruct
  |> of_ok

let bench_dh () =
  let priv = random_private_key () in
  let pub = Hacl_x25519.public @@ random_private_key () in
  let run () : (Cstruct.t, _) result = Hacl_x25519.key_exchange priv pub in
  Benchmark.throughputN 1 [("X25519", run, ())]

let () =
  let open Benchmark.Tree in
  register @@ "Hacl" @>>> ["dh" @> lazy (bench_dh ())]

let () = Benchmark.Tree.run_global ()
