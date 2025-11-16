const mongoose = require("mongoose");

const playerSchema = new mongoose.Schema({
    nickname: {
        type: String,
        trim: true,
    },
    socketID: {
        type: String,
    },
    isPartyLeader: {
        type: Boolean,
        default: false,
    },
    currentWordIndex: {
        type: Number,
        default: 0,
    },
    WPM: {
        type: Number,
        default: -1,
    },
});

module.exports = playerSchema;
