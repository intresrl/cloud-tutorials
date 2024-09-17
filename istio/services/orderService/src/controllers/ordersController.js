const {ordersService} = require("../services");

const getAllAsyncHandler = (async (req, res, next) => {
    try {

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

        res.status(200).json({
            success: true, data: await ordersService.getAllRawAsync()
        });
    } catch (err) {

        res.status(500).json({
            success: false, data: null, error: err.message
        });
    }
});


const getHeadersToForward = (req) => {
    const headers = {};
    const headersToPropagate = ['istio-demo', 'x-request-id'];

    headersToPropagate.forEach(header => {
        if (req.headers[header]) {
            headers[header] = req.headers[header] || null
        }
    });
    return headers;
}

module.exports = {getAllAsyncHandler, getAllRawAsyncHandler}