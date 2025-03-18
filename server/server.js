import { WebSocketServer } from "ws";

const wss = new WebSocketServer({ port: 8081 });

const players = new Map();

function broadcastMessage(message, excludeSocket) {
    for (const socket of players.keys()) {
        if (socket !== excludeSocket) {
            socket.send(JSON.stringify(message));
        }
    }
}

function sendMessage(ws, message) {
    ws.send(JSON.stringify(message));
}

wss.on("connection", function connection(ws) {
    console.log("A new player has connected!");

    ws.on("message", function message(message) {
        const data = JSON.parse(message);
        console.log(`Received message: ${data.event}`);

        switch (data.event) {
            case "join-game":
                console.log("Player joined", data);
                players.set(ws, {
                    playerId: data.playerId,
                    position: data.position,
                });

                sendMessage(ws, {
                    event: "existing-players",
                    players: Array.from(players.values()),
                });

                // Broadcast the new player to other players
                broadcastMessage(
                    { event: "new-player", playerId: data.playerId, position: data.position },
                    ws
                );
                break;

            case "player-moved":
                console.log("Player moved", data);
                players.set(ws, { playerId: data.playerId, position: data.position });
                broadcastMessage(
                    { event: "player-moved", playerId: data.playerId, position: data.position },
                    ws
                );
                break;
        }
    });

});

console.log("WebSocket server is running on ws://localhost:8081");
