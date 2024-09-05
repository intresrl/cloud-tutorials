const getAllAsync = () => {
    return new Promise((resolve, reject) => {
        resolve([
            {
                id: 1,
                name: 'Apple',
                price: 100
            },
            {
                id: 2,
                name: 'Pear',
                price: 200
            },
            {
                id: 3,
                name: 'Banana',
                price: 175
            },
            {
                id: 4,
                name: 'Kiwi',
                price: 35
            }
        ]);
    });
};

module.exports = {getAllAsync};