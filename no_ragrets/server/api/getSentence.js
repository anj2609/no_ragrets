const axios = require("axios");

// Fallback sentences if API fails
const fallbackSentences = [
    "The quick brown fox jumps over the lazy dog near the riverbank",
    "Programming is the art of telling another human what one wants the computer to do",
    "Success is not final failure is not fatal it is the courage to continue that counts",
    "The only way to do great work is to love what you do and never give up",
    "In the middle of difficulty lies opportunity waiting to be discovered",
    "Life is what happens when you are busy making other plans for tomorrow",
    "The best time to plant a tree was twenty years ago the second best time is now",
    "It does not matter how slowly you go as long as you do not stop moving forward",
    "The future belongs to those who believe in the beauty of their dreams today",
    "You miss one hundred percent of the shots you do not take in life"
];

const getSentence = async () => {
    try {
        // Try to fetch from a working API
        const response = await axios.get("https://api.quotable.io/random", {
            timeout: 5000
        });
        return response.data.content.split(" ");
    } catch (error) {
        console.log("API failed, using fallback sentence:", error.message);
        // Use a random fallback sentence
        const randomIndex = Math.floor(Math.random() * fallbackSentences.length);
        return fallbackSentences[randomIndex].split(" ");
    }
};

module.exports = getSentence;