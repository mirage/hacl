#!/usr/bin/env ocaml

;;
#use "topfind"

;;
#require "unix"

let null = Unix.openfile "/dev/null" Unix.[ O_RDONLY ] 0o644

let kstrf k fmt = Format.kasprintf k fmt

let symbols obj =
  let fd, stdout = Unix.pipe () in
  let stderr = stdout in
  Unix.set_close_on_exec fd;
  let _pid =
    Unix.create_process "nm"
      [| "nm"; "--defined-only"; obj |]
      null stdout stderr
  in
  Format.eprintf "[!] nm %s\n%!" obj;
  Unix.clear_close_on_exec fd;
  Unix.close stdout;
  let ic = Unix.in_channel_of_descr fd in
  let rec go acc =
    match input_line ic with
    | line -> go (line :: acc)
    | exception End_of_file -> List.rev acc
  in
  let res = go [] in
  Unix.close fd;
  List.map (fun line -> String.sub line 19 (String.length line - 19)) res

let generate ~prefix symbols output =
  let oc = open_out output in
  let rec go = function
    | [] -> ()
    | symbol :: others ->
        kstrf (output_string oc) "%s %s%s\n" symbol prefix symbol;
        go others
  in
  go symbols;
  close_out oc

let () =
  match Sys.argv with
  | [| _; obj; output |] ->
      let symbols = symbols obj in
      generate ~prefix:"mirage__" symbols output
  | _ -> Format.eprintf "%s <filename.o> <symbols.txt>" Sys.argv.(0)
