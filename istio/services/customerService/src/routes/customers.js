const express = require("express");
const router = express.Router();

const { getAllAsyncHandler } = require('../controllers/customersController')

router.get('/customers', getAllAsyncHandler);

module.exports = router;