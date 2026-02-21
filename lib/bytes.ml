include Stdlib.Bytes

let of_array arr =
  let bytes = create (Array.length arr) in
  Array.iteri (set_uint8 bytes) arr;
  bytes
