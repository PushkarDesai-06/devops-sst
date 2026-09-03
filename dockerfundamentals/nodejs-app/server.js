const express = require("express");
const app = express();
app.get("/", (req, res) => res.send("<h1>Hello World from Node.js</h1>"));
app.listen(3000, "0.0.0.0", () => console.log("listening on 3000"));
