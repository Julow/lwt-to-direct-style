open Lwt.Infix
open Lwt.Syntax

let lwt_calls () =
  Lwt.try_bind
    (fun () ->
      Lwt.bind (Lwt_fmt.printf "1") (fun () ->
          Lwt.map (fun () -> `Ok) (Lwt_fmt.printf "2")))
    (fun `Ok -> Lwt.bind (Lwt_fmt.printf "3") (fun () -> Lwt.return ()))
    (fun _ -> Lwt.return ())

let lwt_calls_point_free () =
  Lwt.bind (Lwt_fmt.printf "1") @@ fun () ->
  Lwt_fmt.printf "2" |> Lwt.map @@ fun () -> ()

let letops () =
  let* `Ok =
    let* () = Lwt_fmt.printf "1" in
    let+ () = Lwt_fmt.printf "2" in
    `Ok
  and* () = Lwt_fmt.printf "3" in
  let* `Ok =
    let* () = Lwt_fmt.printf "4" in
    let+ () = Lwt_fmt.printf "5" in
    `Ok
  and* () = Lwt_fmt.printf "6"
  and* () = Lwt_fmt.printf "7" in
  Lwt.return ()

let infix () =
  Lwt_fmt.printf "1"
  >>= (fun () -> Lwt_fmt.printf "2" >|= fun () -> ())
  <&> (Lwt_fmt.printf "3" >>= fun () -> Lwt.return ())

let lwt_calls_open () =
  let open Lwt in
  let open Lwt_fmt in
  try_bind
    (fun () -> bind (printf "1") (fun () -> map (fun () -> `Ok) (printf "2")))
    (fun `Ok -> bind (printf "3") (fun () -> return ()))
    (fun _ -> return ())

let lwt_calls_rebind () =
  let tr = Lwt.try_bind in
  let b = Lwt.bind in
  let ( >> ) = Lwt.Infix.( >|= ) in
  let p fmt = Lwt_fmt.printf fmt in
  let ( ~@ ) = Lwt.return in
  tr
    (fun () -> b (p "1") (fun () -> p "2" >> fun () -> `Ok))
    (fun `Ok -> b (p "3") (fun () -> ~@()))
    (fun _ -> ~@())

let lwt_calls_alias () =
  let module L = Lwt in
  let module F = Lwt_fmt in
  let open L.Infix in
  F.printf "1"
  >>= (fun () -> F.printf "2" >|= fun () -> ())
  <&> (F.printf "3" >>= fun () -> L.return ())

let lwt_calls_include () =
  let module L = struct
    include Lwt
    include Lwt_fmt
  end in
  let open L in
  try_bind
    (fun () -> bind (printf "1") (fun () -> map (fun () -> `Ok) (printf "2")))
    (fun `Ok -> bind (printf "3") (fun () -> return ()))
    (fun _ -> return ())

let test () =
  Lwt_fmt.printf "Test.test" >>= fun () ->
  Lwt.both (lwt_calls ()) (lwt_calls_point_free ()) >>= fun _ ->
  (let a = lwt_calls () and b = lwt_calls_point_free () in
   Lwt.both a b)
  >>= fun _ ->
  Lwt.join
    [
      letops ();
      infix ();
      lwt_calls_open ();
      lwt_calls_rebind ();
      lwt_calls_alias ();
      lwt_calls_include ();
    ]
  >>= Lwt.return

let x = Lwt.return ()

let _ =
  let xs = [ x ] in
  let* _ = Lwt.pick [ Lwt.return (); Lwt.return () ] in
  let* _ = Lwt.pick [ x; Lwt.return (); x ] in
  let* _ = Lwt.pick xs in
  x

let _ =
  let handle _ = x in
  let* _ = Lwt.catch (fun () -> x) (fun _ -> x) in
  let* _ = Lwt.catch (fun _ -> x) handle in
  let* _ = Lwt.catch (fun _ : unit Lwt.t -> x) handle in
  let* _ = Lwt.catch (function () -> x) handle in
  let* _ = Lwt.catch (fun () -> x) (function Not_found -> x | _ -> x) in
  let* _ = Lwt.catch handle handle in
  x

let _ = Lwt.fail Not_found
let _ = Lwt.fail_with "not found"
let _ = Lwt.return =<< x
let _ = Fun.id =|< x
let _ = x <?> x
let _ = Lwt.pause ()
let _ = Lwt.choose [ x; x ]
let _ = Lwt.join [ x; x ]
let _ = Lwt.join [ Lwt.return () ]
let _ = Lwt.finalize (fun () -> Lwt.fail_invalid_arg "") (fun () -> x)
let _ = Lwt.async (fun () -> x)

let _ =
  let t, u = Lwt.wait () in
  Lwt.async (fun () -> t);
  Lwt.wakeup u ();
  Lwt.wakeup_later u ()

let _ = Lwt_list.iter_s (fun _ -> x) []
let _ = Lwt_list.iter_p (fun _ -> x) []
let _ = Lwt_list.iteri_p (fun _ _ -> x) []

let _ = Lwt_condition.create ()
let f1 cond = Lwt_condition.wait cond
let f2 mutex cond = Lwt_condition.wait ~mutex cond
let f3 mutex cond = Lwt_condition.wait ?mutex cond
let m = Lwt_mutex.create ()
let _ = Lwt_mutex.lock m
let _ = Lwt_mutex.unlock m
let _ = Lwt_mutex.with_lock m (fun () -> x)

let _ = Lwt.ignore_result (Lwt.return ())
let _ = Lwt.ignore_result x
let _ = Lwt.task ()

let _ =
  match Lwt.state x with
  | Return x -> x
  | Fail _ -> failwith "fail"
  | Sleep -> ()

let key = Lwt.new_key ()
let _ = Lwt.get key
let _ = Lwt.with_value key (Some 12) (fun () -> x)
let _ = Lwt.with_value key None (fun () -> x)

let x : unit Lwt.t = x
let f : unit -> unit Lwt.t = fun () -> x
let g : unit Lwt.t -> unit = fun y -> Lwt.async (fun () -> y)
let h : (unit -> unit Lwt.t) -> unit Lwt.t = fun f -> f () >>= fun () -> x
let i : (unit Lwt.t -> unit) -> unit = fun f -> f x

let _ = Lwt.(return ())
let _ = Lwt.Infix.(( >>= ))
let _ = Lwt.Syntax.(( let* ))

let _ =
  let open struct
    include Lwt.Syntax
  end in
  ()

module M = struct
  include Lwt
  include Lwt.Infix
  include Lwt.Syntax
end

let _ = Lwt.Return ()
let _ = Lwt.Sleep
let _ = Lwt.Fail Not_found
