const express = require("express");
const app = express();
const http = require("http");
const server = http.createServer(app);
const { Server } = require("socket.io");

const io = new Server(server, {
  cors: {
    origin: "*",
  },
});

// Keep track of the number of connected clients
let clientCounter = 1;
const clients = {};


app.get("/", (req, res) => {
  res.sendFile(__dirname + `/index.html`);
});


io.on("connection", (socket) => {
  
  socket.on("user message", (msg) => {
    clients[socket.id] = clientCounter++;
    const clientNumber = clients[socket.id];
  
    console.log(`Client ${clientNumber} connected (Socket ID: ${socket.id})`);
    console.log("user connected", socket.id)
    console.log("message: " + msg);
    io.emit("user message", `client ${clientCounter}: ` + msg);
  });
});
// connection to the server
server.listen(4000, '0.0.0.0', () => {
  console.log("server running on http://10.244.199.226:4000");
});