const express = require("express");
const router = express.Router();

const {getAllAsyncHandler, getAllRawAsyncHandler} = require('../controllers/ordersController')

router.get('/orders', getAllAsyncHandler);
router.get('/raw-orders', getAllRawAsyncHandler);

module.exports = router;