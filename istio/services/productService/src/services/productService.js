const getProductPriceAsync = async (productId) => {
    const product = await getProductById(productId);
    return product ? product.price : null;
}

const getProductNameAsync = async (productId) => {
    const product = await getProductById(productId);
    return product ? product.name : null;
}

const getAllAsync = () => {
    return new Promise((resolve, reject) => {
        resolve([{
            id: 1, name: 'Apple', price: 100
        }, {
            id: 2, name: 'Pear', price: 200
        }, {
            id: 3, name: 'Banana', price: 175
        }, {
            id: 4, name: 'Kiwi', price: 35
        }]);
    });
};

async function getProductById(productId) {
    const products = await getAllAsync();
    return products.find(p => p.id.toString() === productId);
}

module.exports = {getAllAsync, getProductNameAsync, getProductPriceAsync};