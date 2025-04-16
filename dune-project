(lang dune 3.17)

(name lwt_ppx_to_let_syntax)

(generate_opam_files true)

; (source
;  (github username/reponame))

(authors
 "Jules Aguillon <jules@j3s.fr>"
 "Nicolas Osborne <nicolas.osborne@tarides.com>")

(maintainers
 "Jules Aguillon <jules@j3s.fr>"
 "Nicolas Osborne <nicolas.osborne@tarides.com>")

; (license LICENSE)

; (documentation https://url/to/documentation)

(package
 (name lwt_ppx_to_let_syntax)
 (synopsis "A tool for migrating away from lwt_ppx")
 (depends ocaml cmdliner))

(package
 (name lwt_to_direct_style)
 (synopsis
  "A tool for migrating from Lwt to direct-style concurrency libraries")
 (depends
  ocaml
  cmdliner
  (lwt :with-test)
  (ocaml-index :with-test)))

(package
 (name lwt_lint)
 (synopsis "A linter for code that might cause implicit forking in Lwt.")
 (depends
  ocaml
  cmdliner
  base
  dune-build-info
  either
  fix
  (fpath
   (>= 0.7.3))
  (menhir
   (>= 20201216))
  (menhirLib
   (>= 20201216))
  (menhirSdk
   (>= 20201216))
  (ocaml-version
   (>= 3.5.0))
  stdio
  (uuseg
   (>= 10.0.0))
  (uutf
   (>= 1.0.1))
  (csexp
   (>= 1.4.0))
  astring
  camlp-streams))
