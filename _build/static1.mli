(* Generated by: ocaml-crunch 
  Creation date: Mon, 8 Dec 2014 18:44:34 GMT *)


include V1.KV_RO
  with type id = unit
   and type 'a io = 'a Lwt.t
   and type page_aligned_buffer = Cstruct.t
   and type id = unit