Make a writable directory tree:
  $ cp -r --no-preserve=mode -L src out
  $ cd out

  $ dune build @ocaml-index
  $ find _build -name '*.ocaml-index'
  _build/default/lib/.test.objs/cctx.ocaml-index
  _build/default/bin/.main.eobjs/cctx.ocaml-index

  $ lwt-to-direct-style
  bin/main.ml: (41 occurrences)
    Lwt (line 39 column 6)
    Lwt.return (line 9 column 16)
    Lwt.return (line 16 column 46)
    Lwt.return (line 19 column 25)
    Lwt.return (line 20 column 15)
    Lwt.return (line 35 column 53)
    Lwt.return (line 36 column 5)
    Lwt.return (line 37 column 35)
    Lwt.return (line 45 column 3)
    Lwt.return (line 53 column 3)
    Lwt.return (line 57 column 3)
    Lwt.return_unit (line 19 column 49)
    Lwt.return_unit (line 49 column 3)
    Lwt.return_none (line 16 column 29)
    Lwt.return_none (line 23 column 9)
    Lwt.return_nil (line 24 column 9)
    Lwt.return_true (line 25 column 9)
    Lwt.return_true (line 41 column 29)
    Lwt.return_false (line 26 column 9)
    Lwt.return_false (line 41 column 52)
    Lwt.return_ok (line 27 column 9)
    Lwt.return_error (line 28 column 9)
    Lwt.reraise (line 12 column 16)
    Lwt.reraise (line 16 column 57)
    Lwt.reraise (line 37 column 55)
    Lwt.try_bind (line 4 column 3)
    Lwt.try_bind (line 16 column 5)
    Lwt.try_bind (line 18 column 3)
    Lwt.try_bind (line 34 column 3)
    Lwt.(>>=) (line 41 column 11)
    Lwt.let* (line 6 column 7)
    Lwt.let+ (line 7 column 7)
    Lwt.Syntax (line 1 column 6)
    Lwt_fmt.printf (line 6 column 17)
    Lwt_fmt.printf (line 11 column 24)
    Lwt_fmt.printf (line 29 column 9)
    Lwt_fmt.eprintf (line 30 column 9)
    Lwt_main.run (line 22 column 10)
    Lwt_unix.sleep (line 31 column 9)
    Lwt_unix.Timeout (line 37 column 15)
    Lwt_unix.with_timeout (line 35 column 16)
  lib/test.ml: (172 occurrences)
    Lwt (line 36 column 12)
    Lwt (line 55 column 18)
    Lwt (line 64 column 13)
    Lwt (line 161 column 9)
    Lwt (line 172 column 11)
    Lwt_fmt (line 37 column 12)
    Lwt_fmt (line 56 column 18)
    Lwt_fmt (line 65 column 13)
    Lwt.t (line 103 column 36)
    Lwt.t (line 155 column 14)
    Lwt.t (line 156 column 22)
    Lwt.t (line 157 column 14)
    Lwt.t (line 158 column 23)
    Lwt.t (line 158 column 38)
    Lwt.t (line 159 column 15)
    Lwt.new_key (line 150 column 11)
    Lwt.get (line 151 column 9)
    Lwt.with_value (line 152 column 9)
    Lwt.with_value (line 153 column 9)
    Lwt.wakeup (line 124 column 3)
    Lwt.wakeup_later (line 125 column 3)
    Lwt.return (line 9 column 58)
    Lwt.return (line 10 column 15)
    Lwt.return (line 28 column 3)
    Lwt.return (line 33 column 41)
    Lwt.return (line 40 column 46)
    Lwt.return (line 41 column 15)
    Lwt.return (line 48 column 16)
    Lwt.return (line 60 column 35)
    Lwt.return (line 70 column 46)
    Lwt.return (line 71 column 15)
    Lwt.return (line 88 column 7)
    Lwt.return (line 90 column 9)
    Lwt.return (line 94 column 23)
    Lwt.return (line 94 column 38)
    Lwt.return (line 95 column 26)
    Lwt.return (line 111 column 9)
    Lwt.return (line 117 column 20)
    Lwt.return (line 140 column 28)
    Lwt.return (line 161 column 14)
    Lwt.fail (line 109 column 9)
    Lwt.fail_with (line 110 column 9)
    Lwt.fail_invalid_arg (line 118 column 33)
    Lwt.wait (line 122 column 14)
    Lwt.task (line 142 column 9)
    Lwt.bind (line 7 column 7)
    Lwt.bind (line 9 column 17)
    Lwt.bind (line 13 column 3)
    Lwt.bind (line 39 column 16)
    Lwt.bind (line 40 column 17)
    Lwt.bind (line 45 column 11)
    Lwt.bind (line 69 column 16)
    Lwt.bind (line 70 column 17)
    Lwt.map (line 8 column 11)
    Lwt.map (line 14 column 25)
    Lwt.map (line 39 column 45)
    Lwt.map (line 69 column 45)
    Lwt.catch (line 101 column 12)
    Lwt.catch (line 102 column 12)
    Lwt.catch (line 103 column 12)
    Lwt.catch (line 104 column 12)
    Lwt.catch (line 105 column 12)
    Lwt.catch (line 106 column 12)
    Lwt.try_bind (line 5 column 3)
    Lwt.try_bind (line 38 column 3)
    Lwt.try_bind (line 44 column 12)
    Lwt.try_bind (line 68 column 3)
    Lwt.finalize (line 118 column 9)
    Lwt.async (line 119 column 9)
    Lwt.async (line 123 column 3)
    Lwt.async (line 157 column 39)
    Lwt.ignore_result (line 140 column 9)
    Lwt.ignore_result (line 141 column 9)
    Lwt.join (line 79 column 3)
    Lwt.join (line 116 column 9)
    Lwt.join (line 117 column 9)
    Lwt.both (line 75 column 3)
    Lwt.both (line 77 column 4)
    Lwt.choose (line 115 column 9)
    Lwt.pick (line 94 column 12)
    Lwt.pick (line 95 column 12)
    Lwt.pick (line 96 column 12)
    Lwt.Return (line 146 column 5)
    Lwt.Return (line 177 column 9)
    Lwt.Fail (line 147 column 5)
    Lwt.Fail (line 179 column 9)
    Lwt.Sleep (line 148 column 5)
    Lwt.Sleep (line 178 column 9)
    Lwt.state (line 145 column 9)
    Lwt.pause (line 114 column 9)
    Lwt.(>>=) (line 32 column 3)
    Lwt.(>>=) (line 33 column 27)
    Lwt.(>>=) (line 59 column 3)
    Lwt.(>>=) (line 60 column 21)
    Lwt.(>>=) (line 74 column 30)
    Lwt.(>>=) (line 75 column 53)
    Lwt.(>>=) (line 78 column 3)
    Lwt.(>>=) (line 88 column 3)
    Lwt.(>>=) (line 158 column 60)
    Lwt.(>>=) (line 162 column 20)
    Lwt.(=<<) (line 111 column 20)
    Lwt.(>|=) (line 32 column 37)
    Lwt.(>|=) (line 46 column 16)
    Lwt.(>|=) (line 59 column 31)
    Lwt.(=|<) (line 112 column 16)
    Lwt.(<&>) (line 33 column 3)
    Lwt.(<&>) (line 60 column 3)
    Lwt.(<?>) (line 113 column 11)
    Lwt.Infix (line 1 column 6)
    Lwt.Infix (line 57 column 12)
    Lwt.Infix (line 162 column 9)
    Lwt.Infix (line 173 column 11)
    Lwt.let* (line 17 column 3)
    Lwt.let* (line 18 column 5)
    Lwt.let* (line 22 column 3)
    Lwt.let* (line 23 column 5)
    Lwt.let* (line 94 column 3)
    Lwt.let* (line 95 column 3)
    Lwt.let* (line 96 column 3)
    Lwt.let* (line 101 column 3)
    Lwt.let* (line 102 column 3)
    Lwt.let* (line 103 column 3)
    Lwt.let* (line 104 column 3)
    Lwt.let* (line 105 column 3)
    Lwt.let* (line 106 column 3)
    Lwt.let* (line 163 column 21)
    Lwt.and* (line 21 column 3)
    Lwt.and* (line 26 column 3)
    Lwt.and* (line 27 column 3)
    Lwt.let+ (line 19 column 5)
    Lwt.let+ (line 24 column 5)
    Lwt.Syntax (line 2 column 6)
    Lwt.Syntax (line 163 column 9)
    Lwt.Syntax (line 167 column 13)
    Lwt.Syntax (line 174 column 11)
    Lwt_condition.create (line 131 column 9)
    Lwt_condition.wait (line 132 column 15)
    Lwt_condition.wait (line 133 column 21)
    Lwt_condition.wait (line 134 column 21)
    Lwt_fmt.printf (line 7 column 17)
    Lwt_fmt.printf (line 8 column 36)
    Lwt_fmt.printf (line 9 column 27)
    Lwt_fmt.printf (line 13 column 13)
    Lwt_fmt.printf (line 14 column 3)
    Lwt_fmt.printf (line 18 column 15)
    Lwt_fmt.printf (line 19 column 15)
    Lwt_fmt.printf (line 21 column 13)
    Lwt_fmt.printf (line 23 column 15)
    Lwt_fmt.printf (line 24 column 15)
    Lwt_fmt.printf (line 26 column 13)
    Lwt_fmt.printf (line 27 column 13)
    Lwt_fmt.printf (line 31 column 3)
    Lwt_fmt.printf (line 32 column 18)
    Lwt_fmt.printf (line 33 column 8)
    Lwt_fmt.printf (line 39 column 22)
    Lwt_fmt.printf (line 39 column 66)
    Lwt_fmt.printf (line 40 column 23)
    Lwt_fmt.printf (line 47 column 15)
    Lwt_fmt.printf (line 58 column 3)
    Lwt_fmt.printf (line 59 column 18)
    Lwt_fmt.printf (line 60 column 8)
    Lwt_fmt.printf (line 69 column 22)
    Lwt_fmt.printf (line 69 column 66)
    Lwt_fmt.printf (line 70 column 23)
    Lwt_fmt.printf (line 74 column 3)
    Lwt_list.iter_s (line 127 column 9)
    Lwt_list.iter_p (line 128 column 9)
    Lwt_list.iteri_p (line 129 column 9)
    Lwt_mutex.create (line 135 column 9)
    Lwt_mutex.lock (line 136 column 9)
    Lwt_mutex.unlock (line 137 column 9)
    Lwt_mutex.with_lock (line 138 column 9)
  lib/test_lwt_unix.ml: (24 occurrences)
    Lwt_io (line 7 column 8)
    Lwt.return (line 11 column 3)
    Lwt.let* (line 10 column 3)
    Lwt.Syntax (line 1 column 6)
    Lwt_io.Input (line 22 column 32)
    Lwt_io.Output (line 23 column 32)
    Lwt_io.input (line 7 column 28)
    Lwt_io.output (line 21 column 32)
    Lwt_io.output_channel (line 26 column 9)
    Lwt_io.of_fd (line 7 column 16)
    Lwt_io.of_fd (line 21 column 13)
    Lwt_io.of_fd (line 22 column 13)
    Lwt_io.of_fd (line 23 column 13)
    Lwt_io.read_into (line 10 column 19)
    Lwt_io.write (line 24 column 19)
    Lwt_io.stdout (line 26 column 33)
    Lwt_unix.Timeout (line 13 column 9)
    Lwt_unix.of_unix_file_descr (line 6 column 8)
    Lwt_unix.sockaddr (line 14 column 9)
    Lwt_unix.ADDR_UNIX (line 14 column 29)
    Lwt_unix.ADDR_UNIX (line 16 column 6)
    Lwt_unix.ADDR_INET (line 16 column 29)
    Lwt_unix.ADDR_INET (line 17 column 3)
    Lwt_unix.getaddrinfo (line 19 column 9)
  lib/test.mli: (17 occurrences)
    Lwt (line 12 column 26)
    Lwt.t (line 1 column 35)
    Lwt.t (line 2 column 54)
    Lwt.t (line 3 column 61)
    Lwt.t (line 4 column 14)
    Lwt.t (line 5 column 22)
    Lwt.t (line 6 column 14)
    Lwt.t (line 7 column 23)
    Lwt.t (line 7 column 38)
    Lwt.t (line 8 column 15)
    Lwt.t (line 9 column 25)
    Lwt.Infix (line 13 column 26)
    Lwt_condition.t (line 1 column 13)
    Lwt_condition.t (line 2 column 30)
    Lwt_condition.t (line 3 column 37)
    Lwt_mutex.t (line 2 column 10)
    Lwt_mutex.t (line 3 column 10)

  $ lwt-to-direct-style --migrate
  Formatted 4 files
  Warning: lib/test.ml: 8 occurrences have not been rewritten.
    Lwt (line 55 column 18)
    Lwt_fmt (line 56 column 18)
    Lwt.(<?>) (line 113 column 11)
    Lwt.choose (line 115 column 9)
    Lwt_list.iteri_p (line 129 column 9)
    Lwt.Fail (line 147 column 5)
    Lwt.let* (line 163 column 21)
    Lwt.Fail (line 179 column 9)
  Warning: lib/test_lwt_unix.ml: 1 occurrences have not been rewritten.
    Lwt_io.stdout (line 26 column 33)
  Warning: lib/test.mli: 2 occurrences have not been rewritten.
    Lwt_mutex.t (line 2 column 10)
    Lwt_mutex.t (line 3 column 10)

  $ cat bin/main.ml
  let _main () =
    match
      let () = Format.printf "Main.main" in
      let () = Test.test () in
      ()
    with
    | () -> ()
    | exception Failure msg -> Format.printf "Failure: %s\n%!" msg
  
  let main () =
    let main () = match None with v -> v in
    match main () with Some _ -> () | None -> () | exception _ -> ()
  
  let () =
    Eio_main.run (fun env ->
        (* TODO: lwt-to-direct-style: [Eio_main.run] argument used to be a [Lwt] promise and is now a [fun]. Make sure no asynchronous or IO calls are done outside of this [fun]. *)
        main ())
  
  let _ = None
  let _ = []
  let _ = true
  let _ = false
  let _ = Ok ()
  let _ = Error ()
  let _ = Format.printf ""
  let _ = Format.eprintf ""
  let _ = Eio_unix.sleep 1.0
  
  let x =
    match
      Eio.Time.with_timeout_exn env#mono_clock
        (* TODO: lwt-to-direct-style: [env] must be propagated from the main loop *)
        1.0 (fun () -> 42)
    with
    | v -> v
    | exception Eio.Time.Timeout -> 0
  
  let _ = match x with 0 -> true | _ -> false
  let _ = print_endline "Hello"
  let _ = print_endline "Hello"
  
  let _ =
    print_endline "Hello";
    1
  
  let _ =
    print_endline "Hello";
    () [@foo]

  $ cat lib/test.ml
  open Eio.Std
  
  let lwt_calls () =
    match
      Format.printf "1";
      Format.printf "2";
      `Ok
    with
    | `Ok -> Format.printf "3"
    | exception _ -> ()
  
  let lwt_calls_point_free () =
    Format.printf "1";
    Format.printf "2";
    ()
  
  let letops () =
    let (), `Ok =
      Fiber.pair (Format.printf "3")
        (let () = Format.printf "1" in
         let () = Format.printf "2" in
         `Ok)
    in
    let (), ((), `Ok) =
      Fiber.pair (Format.printf "6")
        (Fiber.pair (Format.printf "7")
           (let () = Format.printf "4" in
            let () = Format.printf "5" in
            `Ok))
    in
    ()
  
  let infix () =
    Fiber.pair
      (fun () ->
        Format.printf
          (* TODO: lwt-to-direct-style: This computation might not be suspended correctly. *)
          "1";
        Format.printf "2";
        ())
      (fun () ->
        Format.printf
          (* TODO: lwt-to-direct-style: This computation might not be suspended correctly. *)
          "3")
  
  let lwt_calls_open () =
    match
      Format.printf "1";
      Format.printf "2";
      `Ok
    with
    | `Ok -> Format.printf "3"
    | exception _ -> ()
  
  let lwt_calls_rebind () =
    let tr = fun x1 x2 x3 -> match x1 () with v -> x2 v | exception v -> x3 v in
    let b = fun x1 x2 -> x2 x1 in
    let ( >> ) = fun x1 x2 -> x2 x1 in
    let p fmt = Format.printf fmt in
    let ( ~@ ) = fun x1 -> x1 in
    tr
      (fun () -> b (p "1") (fun () -> p "2" >> fun () -> `Ok))
      (fun `Ok -> b (p "3") (fun () -> ~@()))
      (fun _ -> ~@())
  
  let lwt_calls_alias () =
    let module L = Lwt in
    let module F = Lwt_fmt in
    Fiber.pair
      (fun () ->
        Format.printf
          (* TODO: lwt-to-direct-style: This computation might not be suspended correctly. *)
          "1";
        Format.printf "2";
        ())
      (fun () ->
        Format.printf
          (* TODO: lwt-to-direct-style: This computation might not be suspended correctly. *)
          "3")
  
  let lwt_calls_include () =
    let module L = struct end in
    let open L in
    match
      Format.printf "1";
      Format.printf "2";
      `Ok
    with
    | `Ok -> Format.printf "3"
    | exception _ -> ()
  
  let test () =
    Format.printf "Test.test";
    let _ = Fiber.pair lwt_calls lwt_calls_point_free in
    let _ =
      let a = lwt_calls () and b = lwt_calls_point_free () in
      Fiber.pair
        (fun () ->
          a
          (* TODO: lwt-to-direct-style: This computation might not be suspended correctly. *))
        (fun () ->
          b
          (* TODO: lwt-to-direct-style: This computation might not be suspended correctly. *))
    in
    Fiber.all
      [
        letops;
        infix;
        lwt_calls_open;
        lwt_calls_rebind;
        lwt_calls_alias;
        lwt_calls_include;
      ]
  
  let x = ()
  
  let _ =
    let xs = [ x ] in
    let _ = Fiber.any [ (fun x1 -> x1); (fun x1 -> x1) ] in
    let _ =
      Fiber.any
        [
          (fun () ->
            x
            (* TODO: lwt-to-direct-style: This computation might not be suspended correctly. *));
          (fun x1 -> x1);
          (fun () ->
            x
            (* TODO: lwt-to-direct-style: This computation might not be suspended correctly. *));
        ]
    in
    let _ =
      Fiber.any xs
      (* TODO: lwt-to-direct-style: This expression is a ['a Lwt.t list] but a [(unit -> 'a) list] is expected. *)
    in
    x
  
  let _ =
    let handle _ = x in
    let _ = try x with _ -> x in
    let _ = try x with v -> handle v in
    let _ = try (fun _ : unit Promise.t -> x) () with v -> handle v in
    let _ = try (function () -> x) () with v -> handle v in
    let _ = try x with Not_found -> x | _ -> x in
    let _ = try handle () with v -> handle v in
    x
  
  let _ = raise Not_found
  let _ = failwith "not found"
  let _ = x
  let _ = Fun.id x
  
  let _ =
    x
    (* TODO: lwt-to-direct-style: [<?>] can't be automatically translated.Use Eio.Promise instead.  *)
    <?> x
  
  let _ = Fiber.yield ()
  
  let _ =
    Lwt.choose
      (* TODO: lwt-to-direct-style: [Lwt.choose] can't be automatically translated.Use Eio.Promise instead.  *)
      (* TODO: lwt-to-direct-style: [Lwt.choose] can't be automatically translated.Use Eio.Promise instead.  *)
      [ x; x ]
  
  let _ =
    Fiber.all
      [
        (fun () ->
          x
          (* TODO: lwt-to-direct-style: This computation might not be suspended correctly. *));
        (fun () ->
          x
          (* TODO: lwt-to-direct-style: This computation might not be suspended correctly. *));
      ]
  
  let _ = Fiber.all [ (fun x1 -> x1) ]
  let _ = Fun.protect ~finally:(fun () -> x) (fun () -> invalid_arg "")
  
  let _ =
    Fiber.fork ~sw
      (* TODO: lwt-to-direct-style: [sw] must be propagated here. *)
      (fun () -> x)
  
  let _ =
    let t, u
        (* TODO: lwt-to-direct-style: Translation is incomplete, [Promise.await] must be called on the promise when it's part of control-flow. *)
        =
      Promise.create ()
    in
    Fiber.fork ~sw
      (* TODO: lwt-to-direct-style: [sw] must be propagated here. *) (fun () -> t);
    Promise.resolve u ();
    Promise.resolve u ()
  
  let _ = List.iter (fun _ -> x) []
  let _ = Fiber.List.iter (fun _ -> x) []
  
  let _ =
    Lwt_list.iteri_p
      (* TODO: lwt-to-direct-style: [iteri] can't be translated automatically. See https://ocaml.org/p/eio/latest/doc/Eio/Fiber/List/index.html *)
      (* TODO: lwt-to-direct-style: [iteri] can't be translated automatically. See https://ocaml.org/p/eio/latest/doc/Eio/Fiber/List/index.html *)
      (fun _ _ -> x)
      []
  
  let _ = Eio.Condition.create ()
  
  let f1 cond =
    Eio.Condition.await
      (* TODO: lwt-to-direct-style: A mutex must be passed *)
      cond __mutex__
  
  let f2 mutex cond = Eio.Condition.await cond mutex
  
  let f3 mutex cond =
    Eio.Condition.await cond
      (Option.get
         (* TODO: lwt-to-direct-style: [mutex] shouldn't be an option. *)
         mutex)
  
  let m = Eio.Mutex.create ()
  let _ = Eio.Mutex.lock m
  let _ = Eio.Mutex.unlock m
  let _ = Eio.Mutex.use_rw ~protect:false m (fun () -> x)
  
  let _ (* TODO: lwt-to-direct-style: [sw] must be propagated here. *) =
    Fiber.fork ~sw (fun x1 -> x1)
  
  let _ =
    Fiber.fork ~sw (fun () ->
        (* TODO: lwt-to-direct-style: [sw] must be propagated here. *)
        x
        (* TODO: lwt-to-direct-style: This computation might not be suspended correctly. *))
  
  let _
      (* TODO: lwt-to-direct-style: Use [Switch] or [Cancel] for defining a cancellable context. *)
      (* TODO: lwt-to-direct-style: Translation is incomplete, [Promise.await] must be called on the promise when it's part of control-flow. *)
      =
    Promise.create ()
  
  let _ =
    match Promise.peek x with
    | Some x -> x
    | Fail (* TODO: lwt-to-direct-style: [Lwt.Fail] shouldn't be used *) _ ->
        failwith "fail"
    | None -> ()
  
  let key = Fiber.create_key ()
  let _ = Fiber.get key
  
  let _ =
    (Option.fold ~none:Fiber.without_binding
       ~some:(Fun.flip Fiber.with_binding)
       (Some 12)) key (fun () -> x)
  
  let _ =
    (Option.fold ~none:Fiber.without_binding
       ~some:(Fun.flip Fiber.with_binding)
       None) key (fun () -> x)
  
  let x : unit Promise.t = x
  let f : unit -> unit = fun () -> x
  
  let g : unit Promise.t -> unit =
   fun y ->
    Fiber.fork ~sw
      (* TODO: lwt-to-direct-style: [sw] must be propagated here. *)
      (fun () -> y)
  
  let h : (unit -> unit) -> unit =
   fun f ->
    f ();
    x
  
  let i : (unit Promise.t -> unit) -> unit = fun f -> f x
  let _ = ()
  let _ = fun x1 x2 -> x2 x1
  let _ = ( let* )
  
  let _ =
    let open struct end in
    ()
  
  module M = struct end
  
  let _ = Some ()
  let _ = None
  
  let _ =
    Lwt.Fail
      (* TODO: lwt-to-direct-style: [Lwt.Fail] shouldn't be used *)
      Not_found

  $ cat lib/test.mli
  open Eio.Std
  
  val f1 :
    Eio.Condition.t ->
    (* TODO: lwt-to-direct-style: Eio conditions don't carry a value. Use a mutable variable and a dedicated mutex. *)
    'a
  
  val f2 : Lwt_mutex.t -> Eio.Condition.t -> unit
  val f3 : Lwt_mutex.t option -> Eio.Condition.t -> unit
  val x : unit Promise.t
  val f : unit -> unit
  val g : unit Promise.t -> unit
  val h : (unit -> unit) -> unit
  val i : (unit Promise.t -> unit) -> unit
  val test : unit -> unit
  
  module M : sig end

  $ cat lib/test_lwt_unix.ml
  let _f fname =
    let inp =
      (fun ?blocking:x1 ?set_flags:x2 ->
        Eio_unix.Fd.of_unix ~sw ?blocking:x1 ~close_unix:true
          (Unix
           (* TODO: lwt-to-direct-style: [sw] must be propagated here. *)
           (* TODO: lwt-to-direct-style: Labelled argument ?set_flags was dropped. *).(
             openfile fname [ O_RDWR; O_NONBLOCK; O_APPEND ])
             0o660))
      |> fun x1 ->
      (Eio_unix.Net.import_socket_stream x1 : [ `R | `Flow | `Close ] Std.r)
    in
    let buf = Bytes.create 1024 in
    let _n : int =
      Eio.Flow.single_read
        (* TODO: lwt-to-direct-style: [buf] should be a [Cstruct.t]. *)
        (* TODO: lwt-to-direct-style: Dropped expression (buffer offset): [0]. *)
        (* TODO: lwt-to-direct-style: Dropped expression (buffer length): [1024]. *)
        inp buf
    in
    ()
  
  let _ = Eio.Time.Timeout
  let _ : Unix.sockaddr = Unix.ADDR_UNIX ""
  
  let (Unix.ADDR_UNIX _ | Unix.ADDR_INET _) =
    Unix.ADDR_INET (Unix.inet_addr_any, 0)
  
  let _
      (* TODO: lwt-to-direct-style: This call to [Unix.getaddrinfo] was [Lwt_unix.getaddrinfo] before the rewrite. *)
      =
    Unix.getaddrinfo
  
  let _f fd =
    (Eio_unix.Net.import_socket_stream
       (* TODO: lwt-to-direct-style: This creates a closeable [Flow.sink] resource but write operations are rewritten to calls to [Buf_write].
          You might want to use [Buf_write.with_flow sink (fun buf_write -> ...)]. *)
       fd
      : [ `W | `Flow | `Close ] Std.r)
  
  let _f fd =
    (Eio_unix.Net.import_socket_stream fd : [ `R | `Flow | `Close ] Std.r)
  
  let _f fd =
    (Eio_unix.Net.import_socket_stream
       (* TODO: lwt-to-direct-style: This creates a closeable [Flow.sink] resource but write operations are rewritten to calls to [Buf_write].
          You might want to use [Buf_write.with_flow sink (fun buf_write -> ...)]. *)
       fd
      : [ `W | `Flow | `Close ] Std.r)
  
  let _f out_chan = Eio.Buf_write.string out_chan "str"
  let _ : Eio.Buf_write.t = Lwt_io.stdout
