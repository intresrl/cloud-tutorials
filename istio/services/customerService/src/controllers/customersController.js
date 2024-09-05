const {customersService} = require("../services");

const getAllAsyncHandler = (async (req, res, next) => {
    try {
        res.status(200).json({
            success: true,
            data: await customersService.getAllAsync()
        });
    } catch (err) {
        next(err);
    }
});

module.exports = {getAllAsyncHandler}