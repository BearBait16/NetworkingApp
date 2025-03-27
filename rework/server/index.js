import { WebSocketServer } from "ws";

const wss = new WebSocketServer({ port: 8080 });

// A Map in javascript is very similar to a plain object, but
// Maps allow for the keys to be almost anything. As such we use
// a Map to store the players where they keys the player's socket
// and the value is their player information (id, position)
const players = new Map();

// Sends a message to all currently connected players
// if excludeSocket is included, it will not send the message
// to that socket. This is usually the case when you want to
// rebroadcast a message that a player sent and not send that message
// back to the player
function broadcastMessage(message, excludeSocket) {
  for (const socket of players.keys()) {
    // Skip the socket that is excludeSocket
    if (socket === excludeSocket) continue;

    socket.send(JSON.stringify(message));
  }
}

// Sends a message to a specific player using their socket directly
function sendMessage(ws, message) {
  ws.send(JSON.stringify(message));
}

// Every time a new player connects, this connection function will be called
// with a new ws (WebSocket) object that is used to send and receive messages
// to/from that specific player
wss.on("connection", function connection(ws) {
  ws.on("error", console.error);

  // This is the event you listen to in order to receive messages
  // that players send to the server
  ws.on("message", function message(message) {
    // The messages can be strings, or binary data. In our case they will
    // be strings, and we also know that they will always be JSON so we
    // can parse the message to get the data first thing
    const data = JSON.parse(message);

    // We've written our game to always send an `event` property in every
    // message to differentiate between different message types
    switch (data.event) {
      // When a player starts up the game, and connects to the websocket server,
      // the first thing the game does is create their own player and then send the
      // `join-game` message to the server with their player data
      case "join-game":
        console.log("A new player joined", data);

        // When a player joins, we need to inform them of all of the other
        // players who have already joined the game prior to their joining
        sendMessage(ws, {
          event: "existing-players",
          // We get all of the values from the players Map and send that as an
          // array back to the player
          players: Array.from(players.values()),
        });

        // after we've sent existing players to the new player, we need to capture
        // the new players websocket and their player information. We do this after
        // sending them the `existing-players` message to that we don't end up resending
        // them their own player information
        players.set(ws, {
          playerId: data.playerId,
          position: data.position,
        });

        // Then we need to let all of the other players know about this new player
        broadcastMessage(
          {
            event: "new-player",
            playerId: data.playerId,
            position: data.position,
          },
          ws
        );
        break;

      // Anytime a player moves they will send their new player information which
      // we need to capture and then rebroadcast to all of the other players
      case "player-moved":
        console.log("Player moved", data);
        // Capture the player's new position
        players.set(ws, {
          playerId: data.playerId,
          position: data.position,
        });

        // Send their information to all of the other players so they can
        // update their positions in the game
        broadcastMessage(
          {
            event: "player-moved",
            playerId: data.playerId,
            position: data.position,
          },
          ws
        );
        break;
    }
  });

  // When a player disconnects, we need to remove them from our players Map and
  // tell all of the other players that they have left
  ws.on("close", () => {
    // Grab a copy of the player information before we delete it
    const player = players.get(ws)
    // Remove the player from the players map
    players.delete(ws);

    // Tell all of the remaining players that the player is gone
    broadcastMessage({
      event: "player-left",
      playerId: player.playerId,
    });
  });
});
