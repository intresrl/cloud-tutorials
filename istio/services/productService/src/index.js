const express = require("express");
const app = express();

const port = process.env.PORT || 5001;

/*app.use(
    "/api/public/images",
    express.static(path.join(__dirname, "/public/images"))
);
app.use("/v1/logs", express.static(path.join(__dirname, "/logs")));
*/

//Using Express.JSON
app.use(express.json());

const indexRoutes = require("./routes/index");
app.use("/api", indexRoutes);


//Listening om the port
app.listen(port, () => {
    console.log(`Listening on port ${port}`);
});