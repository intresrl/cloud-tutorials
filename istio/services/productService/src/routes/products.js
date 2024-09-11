const express = require("express");
const router = express.Router();

const { getAllAsyncHandler, getProductNameAsyncHandler, getProductPriceAsyncHandler } = require('../controllers/productController')

router.get('/products', getAllAsyncHandler);
router.get('/products/:productId/price', getProductPriceAsyncHandler);
router.get('/products/:productId/name', getProductNameAsyncHandler);

module.exports = router;