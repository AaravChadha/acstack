// FIXTURE — crypto misuse and disabled TLS verification.
const crypto = require("crypto");
const cipher = crypto.createCipher("aes-128-ecb", key);   // no IV, ECB mode
process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0";           // TLS off
const opts = { rejectUnauthorized: false };
