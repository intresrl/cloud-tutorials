const getAllAsync = () => {
    return new Promise((resolve, reject) => {
        resolve([
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
        ]);
    });
};

module.exports = {getAllAsync};