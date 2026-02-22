let main ser_port_path programmer baud_rate firmware_path =
  let firmware_binary_data =
    In_channel.with_open_text firmware_path @@ fun ic ->
    if Filename.extension firmware_path = ".hex" then (
      Printf.printf "[MAIN.DEBUG] Using firmware file as INTEL HEX source: %s\n"
        firmware_path;
      Burvar.Ihex_loader.binary_of_channel ic)
    else (
      Printf.printf
        "[MAIN.DEBUG] Using firmware file as raw BINARY source: %s\n"
        firmware_path;
      In_channel.input_all ic)
  in

  Out_channel.set_buffered stdout false;

  Serialport_unix.with_open_communication ser_port_path
    ~opts:(Serialport.Port_options.make ~baud_rate ())
  @@ fun serial_port ->
  match programmer with
  | Some ("stk500" | "stk500v1" | "arduino") ->
      Printf.printf "[MAIN.DEBUG] Using %s programmer\n" (Option.get programmer);
      Burvar.Driver_stk500.upload serial_port firmware_binary_data
  | _ -> raise (Invalid_argument "programmer invalid value")

let () = Cli.run main
