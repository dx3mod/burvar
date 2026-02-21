let binary_of_channel ic =
  let records = Intel_hex.records_of_channel ic in

  let buffer = Buffer.create (List.length records * 100) in

  List.iter
    (function
      | Intel_hex.Record.Data (_, data) -> Buffer.add_string buffer data
      | _ ->
          (* just ignore it :< *)
          ())
    records;

  Buffer.contents buffer
