// @ts-ignore
import { Elm } from "../dist/elm.js";
import net from "net";
import { v4 as uuidv4 } from "uuid";

const PORT = 5379;
const HOST = "0.0.0.0";

// Define Elm ports
interface Ports {
  messageReceiver: PortToElm<{ clientId: string; message: string }>;
  sendMessage: PortFromElm<{ clientId: string; message: string }>;
}

// Create Elm app
const app: ElmApp<Ports> = Elm.Main.init({});

// Store sockets with their unique ids
const sockets: {
  [id: string]: {
    socket: net.Socket;
    remoteAddress?: string;
    remotePort?: number;
  };
} = {};

// Subscribe to messages from Elm. Write them to the socket.
app.ports.sendMessage &&
  app.ports.sendMessage.subscribe(function ({ clientId, message }) {
    sockets[clientId]?.socket.write(message);
  });

net
  // Create a TCP server
  .createServer((socket) => {
    // Generate a unique id and store the socket
    const clientId = uuidv4();
    sockets[clientId] = {
      socket,
      remoteAddress: socket.remoteAddress,
      remotePort: socket.remotePort,
    };

    console.log(
      `Client connected: ${socket.remoteAddress}:${socket.remotePort}`
    );

    // Send incoming data to Elm
    socket.on("data", (data) => {
      app.ports.messageReceiver &&
        app.ports.messageReceiver.send({
          clientId,
          message: data.toString(),
        });
    });

    // Handle client disconnection
    socket.on("close", () => {
      const { remoteAddress, remotePort } = sockets[clientId];
      console.log(`Client disconnected: ${remoteAddress}:${remotePort}`);

      delete sockets[clientId];
    });
  })

  // Start listening for connections on the specified port and host
  .listen(PORT, HOST, () => {
    console.log(`TCP server listening on ${HOST}:${PORT}`);
  });
