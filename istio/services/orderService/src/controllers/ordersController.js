const {ordersService} = require("../services");
const {getHeadersToForward} = require("../utils/headersUtil");
const logger = require('pino')();

const getAllAsyncHandler = (async (req, res, next) => {
    try {
        logger.info(req.headers, `getAllAsyncHandler`);
        res.status(200).json({
            success: true, data: await ordersService.getAllAsync(getHeadersToForward(req))
        });
    } catch (err) {

        res.status(500).json({
            success: false, data: null, error: err.message
        });
    }
});

const getAllRawAsyncHandler = (async (req, res, next) => {
    try {
        logger.info(req.headers, `getAllRawAsyncHandler`);
        res.status(200).json({
            success: true, data: await ordersService.getAllRawAsync()
        });
    } catch (err) {

        res.status(500).json({
            success: false, data: null, error: err.message
        });
    }
});



module.exports = {getAllAsyncHandler, getAllRawAsyncHandler}