(* Generated by Mirage (Mon, 8 Dec 2014 18:44:34 GMT). *)

open Lwt

let _ = Printexc.record_backtrace true

module Console = Console_xen

let console1 () =
  Console.connect "0"

module M3 = Dispatch.Main(Console)

let t3 = console1

let static1 () =
  Static1.connect ()

module M2 = Dispatch.Main(Console)(Static1)

let t2 () =
  console1 () >>= function
  | `Error e -> fail (Failure "console1")
  | `Ok console1 ->
  static1 () >>= function
  | `Error e -> fail (Failure "static1")
  | `Ok static1 ->
  return (`Ok (console1, static1))

let clock () = return (`Ok ())

let net_tap0 () =
  Netif.connect "tap0"

let random () = return (`Ok ())

module Stackv41 = struct
  module E = Ethif.Make(Netif)
  module I = Ipv4.Make(E)
  module U = Udpv4.Make(I)
  module T = Tcpv4.Flow.Make(I)(OS.Time)(Clock)(Random)
  module S = Tcpip_stack_direct.Make(Console)(OS.Time)(Random)(Netif)(E)(I)(U)(T)
  include S
end

let stackv41 () =
  console1 () >>= function
  | `Error _    -> fail (Failure "console1")
  | `Ok console ->
  net_tap0 () >>= function
  | `Error _      -> fail (Failure "net_tap0")
  | `Ok interface ->
  let config = {
    V1_LWT.name = "stackv41";
    console; interface;
    mode = `DHCP;
  } in
  Stackv41.connect config

module Vchan1 = Conduit_localhost

let vchan1 = Vchan1.register "localhost"

module Conduit1 = Conduit_mirage.Make(Stackv41)(Vchan1)

let conduit1 () =
  stackv41 () >>= function
  | `Error _  -> fail (Failure "stackv41")
  | `Ok stackv41 ->
  vchan1 >>= fun vchan1 ->
  Conduit1.init ~peer:vchan1 ~stack:stackv41 () >>= fun conduit1 ->
  return (`Ok conduit1)

module Http1 = HTTP.Make(Conduit1)

let http1 () =
  conduit1 () >>= function
  | `Error _  -> fail (Failure "conduit1")
  | `Ok conduit1 ->
  let listen spec =
    let ctx = conduit1 in
    let mode = `TCP (`Port 80) in
    Conduit1.serve ~ctx ~mode (Http1.Server.listen spec)
  in
  return (`Ok listen)

module M1 = Dispatch.Main(Console)(Static1)(Http1.Server)

let t1 () =
  console1 () >>= function
  | `Error e -> fail (Failure "console1")
  | `Ok console1 ->
  http1 () >>= function
  | `Error e -> fail (Failure "http1")
  | `Ok http1 ->
  static1 () >>= function
  | `Error e -> fail (Failure "static1")
  | `Ok static1 ->
  M1.start console1 static1 http1

let () =
  OS.Main.run (join [t1 ()])
