let () =
  let _, _ = Hacl_x25519.gen_key ~rng:Cstruct.create in
  Hacl_star.(
    EverCrypt.Curve25519.secret_to_public (Bytes.create 32) (Bytes.create 32))
