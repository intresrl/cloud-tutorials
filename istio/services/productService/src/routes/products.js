const express = require("express");
const router = express.Router();

const { getAllAsyncHandler } = require('../controllers/productController')

router.get('/products', getAllAsyncHandler);

module.exports = router;