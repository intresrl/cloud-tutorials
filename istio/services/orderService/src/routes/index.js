const express = require("express");
const router = express.Router();


// GET ALL ORDERS
// CREATE ORDER
// GET ALL

const ordersRoutes = require("./orders");
router.use("/v1", ordersRoutes);

module.exports = router;