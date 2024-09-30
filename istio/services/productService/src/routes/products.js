const express = require("express");
const router = express.Router();

const { getAllAsyncHandler, getProductNameAsyncHandler, getProductPriceAsyncHandler } = require('../controllers/productController')

router.get('/', getAllAsyncHandler);
router.get('/:productId/price', getProductPriceAsyncHandler);
router.get('/:productId/name', getProductNameAsyncHandler);

module.exports = router;