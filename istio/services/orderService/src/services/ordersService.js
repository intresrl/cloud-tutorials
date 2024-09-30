const fetch = (...args) => import('node-fetch').then(({default: fetch}) => fetch(...args));

const getAllAsync = async (headers) => {

    const [rawOrders, customersMap] = await Promise.all([getAllRawAsync(), GetCustomersMapAsync(headers), GetProductsMapAsync(headers)]);

    return await Promise.all(rawOrders.map(o => enrichOrderDataAsync(o, customersMap, headers)));

};

async function enrichOrderDataAsync(order, customersMap, headers) {
    const products = await Promise.all(order.products.map(p => enrichProductDataAsync(p, customersMap, headers)));
    return {
        ...order, customer: customersMap.get(order.customerId) || 'Unknown', products
    };
}

async function enrichProductDataAsync(product, customersMap, headers) {
    const [name, currentPrice] = await Promise.all([GetProductNameAsync(product.id, headers), GetProductPriceAsync(product.id, headers)]);

    return {
        ...product, name, currentPrice
    };
}

async function GetCustomersMapAsync(headers) {
    const productHost = process.env.CUSTOMERS_SERVICE_HOST || 'http://localhost:5003';
    const response = await fetch(`${productHost}/api/v1/`, {headers});
    const {data} = await response.json();
    return new Map(data.map(i => [i.id, {name: i.name, surname: i.surname}]));
}

async function GetProductsMapAsync(headers) {
    const productHost = process.env.PRODUCTS_SERVICE_HOST || 'http://localhost:5001';
    const response = await fetch(`${productHost}/api/v1/`, {headers});
    const {data} = await response.json();
    return new Map(data.map(i => [i.id, i.name]));
}

async function GetProductNameAsync(productId, headers) {
    const productHost = process.env.PRODUCTS_SERVICE_HOST || 'http://localhost:5001';
    const response = await fetch(`${productHost}/api/v1/${productId}/name`, {headers});
    const {data} = await response.json();
    return data;
}

async function GetProductPriceAsync(productId, headers) {
    const productHost = process.env.PRODUCTS_SERVICE_HOST || 'http://localhost:5001';
    const response = await fetch(`${productHost}/api/v1/${productId}/price`, {headers});
    const {data} = await response.json();
    return data;
}

const getAllRawAsync = () => {
    return new Promise((resolve, reject) => {
        resolve([{
            id: 1, name: "Order 1", customerId: 1, products: [{
                id: 1, price: 10
            }, {
                id: 2, price: 15
            }]
        }, {
            id: 2, name: "Order 2", customerId: 2, products: [{
                id: 3, price: 21
            }, {
                id: 4, price: 4
            }]
        }, {
            id: 3, name: "Order 2", customerId: 3, products: [{
                id: 3, price: 21
            }, {
                id: 4, price: 15
            }]
        }]);
    });
};


module.exports = {getAllAsync, getAllRawAsync};