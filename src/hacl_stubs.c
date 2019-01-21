#include <caml/mlvalues.h>
#include <caml/bigarray.h>
#include "Hacl_Curve25519.h"

CAMLprim value ml_Hacl_Curve25519_crypto_scalarmult(value pk, value sk, value basepoint) {
    Hacl_Curve25519_crypto_scalarmult(Caml_ba_data_val(pk),
                                      Caml_ba_data_val(sk),
                                      Caml_ba_data_val(basepoint));
    return Val_unit;
}

