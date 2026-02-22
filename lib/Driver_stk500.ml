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
  Printf.printf
    "[UPLOAD.STK500] Initialize stage. Entering to programming mode.\n";

  Printf.printf "[UPLOAD.STK500] Reset the serial port (i.e. your board)\n";
  Ser_port.reset serial_port;

  let ser_port = Serialport_unix.to_channels serial_port in

  Printf.printf "[UPLOAD.STK500] Send |GET_SYNC| command\n";
  Intf.sync ser_port;

  Printf.printf "[UPLOAD.STK500] Send |SET_DEVICE| command\n";
  Intf.set_options ser_port;

  Printf.printf
    "[UPLOAD.STK500] Send |ENTER_PROG_MODE| command. Entering to programming \
     mode.\n";
  Intf.start_programming_mode ser_port;

  Printf.printf "[UPLOAD.STK500] Start firmware uploading cycle...\n";
  Intf.iter_string_per_page
    begin fun (address, page) ->
      Printf.printf "[UPLOAD.STK500]\t Send |LOAD_ADDRESS 0x%04X| command\n"
        address;
      Intf.load_address ser_port address;

      Printf.printf "[UPLOAD.STK500]\t Send |LOAD_PAGE (0x%X bytes)| command\n"
        (String.length page);
      Intf.load_flash_page ser_port page
    end
    binary;

  Printf.printf "[UPLOAD.STK500] Finished firmware uploading cycle\n";

  Printf.printf
    "[UPLOAD.STK500] Send |LEAVE_PROG_MODE| command. Leave from programming \
     mode.\n";
  Intf.exit_programming_mode ser_port;

  Printf.printf "[UPLOAD.STK500] Successful uploading done.\n"
