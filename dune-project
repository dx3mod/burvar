(lang dune 3.6)

(name burvar)

(generate_opam_files true)

(source
 (github dx3mod/stk500.ml))

(authors "Mikhail Lopatin <dx3mod@bk.ru>")

(maintainers "Mikhail Lopatin <dx3mod@bk.ru>")

(license MIT)

(package
 (name burvar)
 (synopsis "AVR MCU burner")
 (description "A tool for burning firmware to AVR MCU")
 (depends ocaml cmdliner serialport intel_hex stk500)
 (tags
  (avr embedded programmer)))
