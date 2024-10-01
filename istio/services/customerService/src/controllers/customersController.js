const {customersService} = require("../services");
const logger = require('pino')();

const getAllAsyncHandler = (async (req, res, next) => {
    logger.info(req.headers, `getAllAsyncHandler`)

    try {
        res.status(200).json({
            success: true,
            data: await customersService.getAllAsync()
        });
    } catch (err) {
        next(err);
    }
});

const getCustomerSurnameAsyncHandler = (async (req, res, next) => {
    logger.info(req.headers, `getCustomerSurnameAsyncHandler`)
    try {
        res.status(200).json({
            success: true,
            data: await customersService.getCustomerSurnameAsync(req.params.customerId)
        });
    } catch (err) {
        next(err);
    }
});

const getCustomerNameAsyncHandler = (async (req, res, next) => {
    logger.info(req.headers, `getCustomerNameAsyncHandler`)
    try {
        res.status(200).json({
            success: true,
            data: await customersService.getCustomerNameAsync(req.params.customerId)
        });
    } catch (err) {
        next(err);
    }
});

module.exports = {getAllAsyncHandler, getCustomerNameAsyncHandler, getCustomerSurnameAsyncHandler}