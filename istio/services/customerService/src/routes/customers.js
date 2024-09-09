const express = require("express");
const router = express.Router();

const {
    getAllAsyncHandler,
    getCustomerNameAsyncHandler,
    getCustomerSurnameAsyncHandler
} = require('../controllers/customersController')

router.get('/customers', getAllAsyncHandler);
router.get('/customer/:customer_id/surname', getCustomerSurnameAsyncHandler);
router.get('/customer/:customer_id/name', getCustomerNameAsyncHandler);


module.exports = router;