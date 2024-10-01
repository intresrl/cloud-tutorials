const getAllAsync = async () => {
    if(process.env.THROW_ERROR) {
        throw new Error('Error thrown by customerService');

    }
    if (process.env.MAX_DELAY_SECONDS) {
        const delayMs = Math.random() * process.env.MAX_DELAY_SECONDS * 1000;
        const MIN_DELAY_MS = (process.env.MIN_DELAY_SECONDS || 2) * 1000;
        const fixedDelayMs = Math.max(Math.floor(delayMs), MIN_DELAY_MS);
        await sleep(fixedDelayMs);
    }
    return [
        {
            id: 1,
            name: 'Mario',
            surname: 'Rossi',
        },
        {
            id: 2,
            name: 'Sergio',
            surname: 'Bianchi'
        },
        {
            id: 3,
            name: 'Giovanni',
            surname: 'Verdi'
        },
        {
            id: 4,
            name: 'Paperino',
            surname: 'Rossi'
        }
    ];
};

function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

getCustomerSurnameAsync = async (customerId) => {

    const customers = await getAllAsync();
    const customer = customers.find(c => c.id === customerId);

    return customer ? customer.surname : null;
};

getCustomerNameAsync = async (customerId) => {
    const customers = await getAllAsync();
    const customer = customers.find(c => c.id === customerId);

    return customer ? customer.name : null;
};

module.exports = {getAllAsync};