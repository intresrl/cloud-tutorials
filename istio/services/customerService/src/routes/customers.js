const express = require("express");
const router = express.Router();

const {
    getAllAsyncHandler,
    getCustomerNameAsyncHandler,
    getCustomerSurnameAsyncHandler
} = require('../controllers/customersController')

router.get('/', getAllAsyncHandler);
router.get('/:customer_id/surname', getCustomerSurnameAsyncHandler);
router.get('/:customer_id/name', getCustomerNameAsyncHandler);


module.exports = router;