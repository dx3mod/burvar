module Intf = struct
  let expected_ok = Stk500.V1.Message.[| resp_stk_in_sync; resp_stk_ok |]

  let sync ser_port =
    Ser_port.send_command_with_expected ser_port Stk500.V1.Command.sync
      ~expected:expected_ok

  let set_options set_port =
    Ser_port.send_command_with_expected set_port Stk500.V1.Command.set_options
      ~expected:expected_ok

  let start_programming_mode ser_port =
    Ser_port.send_command_with_expected ser_port
      Stk500.V1.Command.enter_programming_mode ~expected:expected_ok

  let load_address ser_port address =
    Ser_port.send_command_with_expected ser_port
      Stk500.V1.Command.(load_address (address lsr 1))
      ~expected:expected_ok

  let load_flash_page ser_port page =
    Ser_port.send_command_with_expected ser_port
      Stk500.V1.Command.(load_page page)
      ~expected:expected_ok

  let exit_programming_mode ser_port =
    Ser_port.send_command_with_expected ser_port
      Stk500.V1.Command.exit_programming_mode ~expected:expected_ok

  let iter_string_per_page f str : unit =
    let rec aux (~address, ~mcu_page_size) =
      if address <= String.length str then begin
        let page =
          String.sub str address
            (min (String.length str - address) mcu_page_size)
        in

        if page <> String.empty then begin
          f (address, page);

          aux
            ( ~address:((address + String.length page) land 0xFFFF),
              ~mcu_page_size )
        end
      end
    in

    aux (~address:0x0000, ~mcu_page_size:120)
end

let upload serial_port binary =
  let module L = Dolog.Log in
  L.info "Initialize stage. Entering to programming mode.";

  L.info "Reset the board";
  Ser_port.reset serial_port;

  let ser_port = Serialport_unix.to_channels serial_port in

  L.info "Send [Sync] command";
  Intf.sync ser_port;

  L.info "Send [set_options] command";
  Intf.set_options ser_port;

  L.info "Start programming mode";
  Intf.start_programming_mode ser_port;

  L.info "Start uploading loop";
  Intf.iter_string_per_page
    begin fun (address, page) ->
      L.info "Send [load_address 0x%04x]" address;
      Intf.load_address ser_port address;
      L.info "Send [load_page %d size]" (String.length page);
      Intf.load_flash_page ser_port page
    end
    binary;
  L.info "Finish uploading loop";

  L.info "Exit programming mode";
  Intf.exit_programming_mode ser_port;

  L.info "Done."
