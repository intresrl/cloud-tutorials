const express = require("express");
const router = express.Router();

const {getAllAsyncHandler, getAllRawAsyncHandler} = require('../controllers/ordersController')

router.get('/', getAllAsyncHandler);
router.get('/raw', getAllRawAsyncHandler);

module.exports = router;