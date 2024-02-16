// @ts-ignore
import { Elm } from "../dist/elm.js";

const app = Elm.Main.init();

app.ports.log && app.ports.log.subscribe(console.log);
