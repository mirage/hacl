#!/usr/bin/env ocaml

;;
#use "topfind"

;;
#require "unix"

let null = Unix.openfile "/dev/null" Unix.[ O_RDONLY ] 0o644

let kstrf k fmt = Format.kasprintf k fmt

let add_sub s ~start ~stop acc =
  if start = stop then acc else String.sub s start (stop - start) :: acc

let cuts ~sep s =
  let sep_len = String.length sep in
  let s_len = String.length s in
  let max_sep_idx = sep_len - 1 in
  let max_s_idx = s_len - sep_len in
  let rec check_sep start i k acc =
    if k > max_sep_idx then
      let new_start = i + sep_len in
      scan new_start new_start (add_sub s ~start ~stop:i acc)
    else if s.[i + k] = sep.[k] then check_sep start i (succ k) acc
    else scan start (succ i) acc
  and scan start i acc =
    if i > max_s_idx then
      if start = 0 then [] else List.rev (add_sub s ~start ~stop:s_len acc)
    else if s.[i] = sep.[0] then check_sep start i 1 acc
    else scan start (i + 1) acc
  in
  scan 0 0 []

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
  List.fold_left
    (fun acc line ->
      match List.rev (cuts ~sep:" " line) with v :: _ -> v :: acc | [] -> acc)
    [] res
  |> List.rev

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
  if Array.length Sys.argv < 3 then
    Format.eprintf "%s <filename.o>... <symbols.txt>" Sys.argv.(0)
  else
    let objs = Array.sub Sys.argv 1 (Array.length Sys.argv - 2) in
    let objs = Array.to_list objs in
    let output = Sys.argv.(Array.length Sys.argv - 1) in
    let symbols = List.concat (List.map symbols objs) in
    generate ~prefix:"mirage__" symbols output
