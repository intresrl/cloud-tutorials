const fetch = (...args) => import('node-fetch').then(({default: fetch}) => fetch(...args));

const getAllAsync = async (headers) => {

    const [orders,
        customersMap,
        productsMap]
        = await Promise.all([getAllRawAsync(),
        GetCustomersMapAsync(headers),
        GetProductsMapAsync(headers)]);

    const propertyToRemoved = 'customerId';
    return orders.map(order => {
        return {
            ...order,
            customer: customersMap.get(order.customerId) || 'Unknown',
            products: order.products.map(p => ({
                ...p,
                name: productsMap.get(p.id) || 'Unknown'
            })),
        }
    });
};

async function GetCustomersMapAsync(headers) {
    const productHost = process.env.CUSTOMERS_SERVICE_HOST || 'http://localhost:5003';
    const response = await fetch(`${productHost}/api/v1/customers/`, {headers});
    const {data} = await response.json();
    return new Map(data.map(i => [i.id, {name: i.name, surname: i.surname}]));
}

async function GetProductsMapAsync(headers) {
    const productHost = process.env.PRODUCTS_SERVICE_HOST || 'http://localhost:5001';
    const response = await fetch(`${productHost}/api/v1/products/`, {headers});
    const {data} = await response.json();
    return new Map(data.map(i => [i.id, i.name]));
}

const getAllRawAsync = () => {
    return new Promise((resolve, reject) => {
        resolve([
            {
                id: 1,
                name: "Order 1",
                customerId: 1,
                products: [
                    {
                        id: 1,
                        price: 10
                    },
                    {
                        id: 2,
                        price: 15
                    }
                ]
            },
            {
                id: 2,
                name: "Order 2",
                customerId: 2,
                products: [
                    {
                        id: 3,
                        price: 21
                    },
                    {
                        id: 4,
                        price: 4
                    }
                ]
            },
            {
                id: 3,
                name: "Order 2",
                customerId: 3,
                products: [
                    {
                        id: 3,
                        price: 21
                    },
                    {
                        id: 4,
                        price: 15
                    }
                ]
            }
        ]);
    });
};


module.exports = {getAllAsync, getAllRawAsync};