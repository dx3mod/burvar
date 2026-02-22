let main ser_port_path programmer baud_rate firmware_path =
  let firmware_binary_data =
    In_channel.with_open_text firmware_path @@ fun ic ->
    if Filename.extension firmware_path = ".hex" then
      Burvar.Ihex_loader.binary_of_channel ic
    else In_channel.input_all ic
  in

  Out_channel.set_buffered stdout false;

  Serialport_unix.with_open_communication ser_port_path
    ~opts:(Serialport.Port_options.make ~baud_rate ())
  @@ fun serial_port ->
  match programmer with
  | Some ("stk500" | "stk500v1" | "arduino") ->
      Burvar.Driver_stk500.upload serial_port firmware_binary_data
  | _ -> raise (Invalid_argument "programmer invalid value")

let () =
  Dolog.Log.color_on ();
  Dolog.Log.(set_log_level INFO);

  Cli.run main
