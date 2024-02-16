import net from "net";

const PORT = 5379;
const HOST = "0.0.0.0";

// Create a TCP server
const server = net.createServer((socket) => {
  console.log("Client connected:", socket.remoteAddress, socket.remotePort);

  // Echo incoming data
  socket.on("data", (data) => {
    socket.write(data.toString());
  });

  // Handle client disconnection
  socket.on("close", () => {
    console.log("Client disconnected");
  });
});

// Start listening
server.listen(PORT, HOST, () => {
  console.log(`TCP server listening on ${HOST}:${PORT}`);
});
