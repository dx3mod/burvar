let binary_of_channel ic =
  let records =
    Intel_hex.records_of_channel ic
    |> List.filter_map (function
      | Intel_hex.Record.Data data -> Some data
      | _ -> None)
  in

  let buffer = Buffer.create (List.length records * 100) in

  List.iter (fun (_, data) -> Buffer.add_string buffer data) records;

  Buffer.contents buffer
