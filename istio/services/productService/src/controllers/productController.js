const {productService} = require("../services");
const logger = require('pino')();

const getAllAsyncHandler = (async (req, res, next) => {
    try {
        logger.info(req.headers, `getAllAsyncHandler`)
        res.status(200).json({
            success: true, data: await productService.getAllAsync()
        });
    } catch (err) {
        next(err);
    }
});

const getProductNameAsyncHandler = (async (req, res, next) => {
    try {
        logger.info(req.headers, `getProductNameAsyncHandler`)
        res.status(200).json({
            success: true, data: await productService.getProductNameAsync(req.params['productId'])
        });
    } catch (err) {
        next(err);
    }
});

const getProductPriceAsyncHandler = (async (req, res, next) => {
    try {
        logger.info(req.headers, `getProductPriceAsyncHandler`)
        res.status(200).json({
            success: true, data: await productService.getProductPriceAsync(req.params['productId'])
        });
    } catch (err) {
        next(err);
    }
});

module.exports = {getAllAsyncHandler, getProductNameAsyncHandler, getProductPriceAsyncHandler}