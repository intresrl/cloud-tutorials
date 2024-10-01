const express = require("express");
const router = express.Router();



// GET ALL

const productsRoutes = require("./products");
router.use("/v1", productsRoutes);

module.exports = router;