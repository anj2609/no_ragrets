const mongoose = require("mongoose");
const playerSchema = require("./Player");

const gameSchema = new mongoose.Schema({
    words: [{ type: String }],
    isJoin: {
        type: Boolean,
        default: true,
    },
    players: [playerSchema],
    isOver: {
        type: Boolean,
        default: false,
    },
    startTime: {
        type: Number,
    },
});

const gameModel = mongoose.model("Game", gameSchema);
module.exports = gameModel;
