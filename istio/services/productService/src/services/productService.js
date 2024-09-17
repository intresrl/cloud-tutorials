const getProductPriceAsync = async (productId) => {
    const product = await getProductById(productId);
    return product ? product.price : null;
}

const getProductNameAsync = async (productId) => {
    const product = await getProductById(productId);
    return product ? product.name : null;
}

const getAllAsync = () => {

    const isVip= process.env.VIP_MODE === 'true';
    const suffix = isVip ? '(VIP)' : '';
    return new Promise((resolve, reject) => {
        resolve([{
            id: 1, name: `Apple ${suffix}`, price: 100
        }, {
            id: 2, name: `Pear ${suffix}`, price: 200
        }, {
            id: 3, name: `Banana ${suffix}`, price: 175
        }, {
            id: 4, name: `Kiwi ${suffix}`, price: 35
        }]);
    });
};

async function getProductById(productId) {
    const products = await getAllAsync();
    return products.find(p => p.id.toString() === productId);
}

module.exports = {getAllAsync, getProductNameAsync, getProductPriceAsync};