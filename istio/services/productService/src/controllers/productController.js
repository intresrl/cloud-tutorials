const {productService} = require("../services");

const getAllAsyncHandler = (async (req, res, next) => {
    try {
        res.status(200).json({
            success: true,
            data: await productService.getAllAsync()
        });
    } catch (err) {
        next(err);
    }
});

module.exports = {getAllAsyncHandler}