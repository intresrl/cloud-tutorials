const express = require("express");
const router = express.Router();



// GET ALL

const customersRoutes = require("./customers");
router.use("/v1", customersRoutes);

module.exports = router;