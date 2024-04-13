// @ts-ignore
import { Elm } from "../dist/elm.js";
import net from "net";

const PORT = 5379;
const HOST = "0.0.0.0";

net
  // Create a TCP server
  .createServer((socket) => {
    console.log("Client connected:", socket.remoteAddress, socket.remotePort);

    // Define the Elm ports
    interface Ports {
      messageReceiver: PortToElm<string>;
      sendMessage: PortFromElm<string>;
    }

    // Create an Elm app
    const app: ElmApp<Ports> = Elm.Main.init({});

    // Subscribe to messages from Elm. Write them to the socket.
    app.ports.sendMessage &&
      app.ports.sendMessage.subscribe(function (message: string) {
        socket.write(message);
      });

    // Send incoming data to Elm
    socket.on("data", (data) => {
      app.ports.messageReceiver &&
        app.ports.messageReceiver.send(data.toString());
    });

    // Handle client disconnection
    socket.on("close", () => {
      console.log("Client disconnected");
    });
  })

  // Start listening for connections on the specified port and host
  .listen(PORT, HOST, () => {
    console.log(`TCP server listening on ${HOST}:${PORT}`);
  });
