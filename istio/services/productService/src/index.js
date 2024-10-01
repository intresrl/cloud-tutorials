const express = require("express");
const app = express();
const logger = require('pino')();

const port = process.env.PORT || 5001;

//Using Express.JSON
app.use(express.json());

const indexRoutes = require("./routes/index");
app.use("/api", indexRoutes);


//Listening om the port
app.listen(port, () => {
    logger.info(`Listening on port ${port}`);
});