// IMPORTS - Local version without MongoDB
const express = require("express");
const http = require("http");
const getSentence = require("./api/getSentence");

// create a server
const app = express();
const port = process.env.PORT || 3000;
var server = http.createServer(app);
var io = require("socket.io")(server);

// middle ware
app.use(express.json());

// In-memory game storage
const games = new Map();

// Helper to generate unique ID
const generateId = () => {
    return Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15);
};

// Helper to create a game object
const createGameObject = () => {
    return {
        _id: generateId(),
        words: [],
        isJoin: true,
        players: [],
        isOver: false,
        startTime: null,
    };
};

// Helper to create a player object
const createPlayerObject = (socketID, nickname, isPartyLeader = false) => {
    return {
        _id: generateId(),
        socketID,
        nickname,
        isPartyLeader,
        currentWordIndex: 0,
        WPM: -1,
    };
};

console.log("Starting server with in-memory storage (no MongoDB required)...");

// listening to socket io events from the client (flutter code)
io.on("connection", (socket) => {
    console.log(`Client connected: ${socket.id}`);

    socket.on("create-game", async ({ nickname }) => {
        try {
            console.log(`Creating game for ${nickname}`);
            let game = createGameObject();
            const sentence = await getSentence();
            game.words = sentence;
            let player = createPlayerObject(socket.id, nickname, true);
            game.players.push(player);

            // Store game in memory
            games.set(game._id, game);

            const gameId = game._id;
            socket.join(gameId);
            console.log(`Game created with ID: ${gameId}`);
            io.to(gameId).emit("updateGame", game);
        } catch (e) {
            console.log("Error creating game:", e);
        }
    });

    socket.on("join-game", async ({ nickname, gameId }) => {
        try {
            console.log(`${nickname} trying to join game ${gameId}`);

            if (!games.has(gameId)) {
                socket.emit("notCorrectGame", "Please enter a valid game ID");
                return;
            }

            let game = games.get(gameId);

            if (game.isJoin) {
                let player = createPlayerObject(socket.id, nickname, false);
                socket.join(gameId);
                game.players.push(player);
                games.set(gameId, game);
                console.log(`${nickname} joined game ${gameId}`);
                io.to(gameId).emit("updateGame", game);
            } else {
                socket.emit(
                    "notCorrectGame",
                    "The game is in progress, please try again later!"
                );
            }
        } catch (e) {
            console.log("Error joining game:", e);
        }
    });

    socket.on("userInput", async ({ userInput, gameID }) => {
        try {
            let game = games.get(gameID);
            if (!game) return;

            if (!game.isJoin && !game.isOver) {
                let player = game.players.find(
                    (playerr) => playerr.socketID === socket.id
                );

                if (player && game.words[player.currentWordIndex] === userInput.trim()) {
                    player.currentWordIndex = player.currentWordIndex + 1;
                    if (player.currentWordIndex !== game.words.length) {
                        games.set(gameID, game);
                        io.to(gameID).emit("updateGame", game);
                    } else {
                        let endTime = new Date().getTime();
                        let { startTime } = game;
                        player.WPM = calculateWPM(endTime, startTime, player);
                        games.set(gameID, game);
                        socket.emit("done");
                        io.to(gameID).emit("updateGame", game);
                    }
                }
            }
        } catch (e) {
            console.log("Error processing user input:", e);
        }
    });

    // timer listener
    socket.on("timer", async ({ playerId, gameID }) => {
        try {
            let countDown = 5;
            let game = games.get(gameID);
            if (!game) return;

            let player = game.players.find(p => p._id === playerId);

            if (player && player.isPartyLeader) {
                let timerId = setInterval(() => {
                    if (countDown >= 0) {
                        io.to(gameID).emit("timer", {
                            countDown,
                            msg: "Game Starting",
                        });
                        console.log(countDown);
                        countDown--;
                    } else {
                        game.isJoin = false;
                        games.set(gameID, game);
                        io.to(gameID).emit("updateGame", game);
                        startGameClock(gameID);
                        clearInterval(timerId);
                    }
                }, 1000);
            }
        } catch (e) {
            console.log("Error starting timer:", e);
        }
    });

    socket.on("disconnect", () => {
        console.log(`Client disconnected: ${socket.id}`);
    });
});

const startGameClock = (gameID) => {
    let game = games.get(gameID);
    if (!game) return;

    game.startTime = new Date().getTime();
    games.set(gameID, game);

    let time = 120;

    let timerId = setInterval(
        (function gameIntervalFunc() {
            if (time >= 0) {
                const timeFormat = calculateTime(time);
                io.to(gameID).emit("timer", {
                    countDown: timeFormat,
                    msg: "Time Remaining",
                });
                console.log(time);
                time--;
            } else {
                try {
                    let endTime = new Date().getTime();
                    let game = games.get(gameID);
                    if (!game) {
                        clearInterval(timerId);
                        return;
                    }
                    let { startTime } = game;
                    game.isOver = true;
                    game.players.forEach((player, index) => {
                        if (player.WPM === -1) {
                            game.players[index].WPM = calculateWPM(
                                endTime,
                                startTime,
                                player
                            );
                        }
                    });
                    games.set(gameID, game);
                    io.to(gameID).emit("updateGame", game);
                    clearInterval(timerId);
                } catch (e) {
                    console.log(e);
                }
            }
            return gameIntervalFunc;
        })(),
        1000
    );
};

const calculateTime = (time) => {
    let min = Math.floor(time / 60);
    let sec = time % 60;
    return `${min}:${sec < 10 ? "0" + sec : sec}`;
};

const calculateWPM = (endTime, startTime, player) => {
    const timeTakenInSec = (endTime - startTime) / 1000;
    const timeTaken = timeTakenInSec / 60;
    let wordsTyped = player.currentWordIndex;
    const WPM = Math.floor(wordsTyped / timeTaken);
    return WPM;
};

// listen to server
server.listen(port, "0.0.0.0", () => {
    console.log(`Server started and running on port ${port}`);
    console.log(`No MongoDB required - using in-memory storage`);
});
