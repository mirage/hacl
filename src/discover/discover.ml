let main c =
  let has_inttypes =
    Configurator.V1.c_test c
      {|
#include <inttypes.h>
int main(void){
      printf("%s\n", PRIu64);
}
|}
  in
  Printf.printf "has inttypes: %b\n" has_inttypes;
  let flags = if has_inttypes then [] else [ "-I." ] in
  Configurator.V1.Flags.write_sexp "cflags.sexp" flags

let () = Configurator.V1.main ~name:"hacl" main
