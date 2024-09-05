const express = require("express");
const app = express();

const port = process.env.PORT || 5003;

app.use(express.json());

const indexRoutes = require("./routes/index");
app.use("/api", indexRoutes);


//Listening om the port
app.listen(port, () => {
    console.log(`Listening on port ${port}`);
});