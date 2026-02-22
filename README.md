# burvar

The Bur(n)(A)VR is a utility for burning (i.e. upload) firmware to AVR MCU. Essentially, it is a reimplementation of the [AVRDUDE] utility, but written in [OCaml]. Currently supports protocols: STK500v1. 

## Installation 

Now, installation is available only from the source code via the [OPAM] package manager. To install (pin) the latest development version of the utility, open your terminal and paste the following:

```console
$ opam pin burvar.dev https://github.com/dx3mod/burvar.git
```

Otherwise, you can clone the repository and use the [Dune] build system to build the project without a package manager
for some reasons, such as native system distribution (`.ext`, `.dmg`, distro's packages).

## Usage

After successfully installing the `burvar`, you can upload your firmware by using the `burvar upload` command on a connected AVR board. For more details see `burvar upload --help`.

Example of burning firmware on an Arduino Uno board using the STK500 serial port protocol:
```
$ burvar upload -p stk500 -b 11520 -P /dev/cu.usbserial-11230 firmware.hex
```

```
[MAIN.DEBUG] Using firmware file as INTEL HEX source: /tmp/firmware.hex
[MAIN.DEBUG] Using stk500 programmer
[UPLOAD.STK500] Initialize stage. Entering to programming mode.
[UPLOAD.STK500] Reset the serial port (i.e. your board)
[UPLOAD.STK500] Send |GET_SYNC| command
[UPLOAD.STK500] Send |SET_DEVICE| command
[UPLOAD.STK500] Send |ENTER_PROG_MODE| command. Entering to programming mode.
[UPLOAD.STK500] Start firmware uploading cycle...
[UPLOAD.STK500]  Send |LOAD_ADDRESS 0x0000| command
[UPLOAD.STK500]  Send |LOAD_PAGE (0x78 bytes)| command
[UPLOAD.STK500]  Send |LOAD_ADDRESS 0x0078| command
[UPLOAD.STK500]  Send |LOAD_PAGE (0x38 bytes)| command
[UPLOAD.STK500] Finished firmware uploading cycle
[UPLOAD.STK500] Send |LEAVE_PROG_MODE| comm
```

## References

- [AVRDUDE] is a utility to program AVR microcontrollers;
- [avrman](https://docs.rs/avrman/latest/avrman/)  is a programmer for AVR microcontrollers written natively in Rust;


[AVRDUDE]: https://github.com/avrdudes/avrdude
[OCaml]: https://ocaml.org
[OPAM]: https://opam.ocaml.org
[Dune]: https://dune.build