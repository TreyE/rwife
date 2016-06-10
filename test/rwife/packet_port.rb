require "JSON"

in_io = IO.new(0, "rb").binmode
out_io = IO.new(1, "wb").binmode
while (port_in = in_io.read(4)) do
  length = port_in.unpack("N").first
  # $stderr.puts length.inspect
  data = in_io.read(length)
  # $stderr.puts("\"" + data + "\"")
  response_data = data
  out_io.write [response_data.bytesize].pack("N")
  out_io.write response_data
  out_io.flush
end
