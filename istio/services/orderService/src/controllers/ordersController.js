const {ordersService} = require("../services");

const getAllAsyncHandler = (async (req, res, next) => {
    try {

        res.status(200).json({
            success: true, data: await ordersService.getAllAsync({'Istio-demo': req.headers['Istio-demo'] || null})
        });
    } catch (err) {

        res.status(500).json({
            success: false, data: null, error: err.message
        });
    }
});

const getAllRawAsyncHandler = (async (req, res, next) => {
    try {

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