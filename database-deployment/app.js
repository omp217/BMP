const mongoose  = require('mongoose');
const csv = require('csv-parser');
const fs = require('fs');

const Schema = mongoose.Schema;

const dbURL = "mongodb+srv://sherlock:sherlocked221b@cluster0.cfth3qm.mongodb.net/bmp"

mongoose.connect(dbURL, {
    useNewUrlParser: true,
    useUnifiedTopology: true
}).then(async () => {
    console.log('Connected to MongoDB');

    const schema = new Schema({
        city: {
            type: String,
        },
        country: {
            type: String,
        },
        population: {
            type: Number,
        },
        area: {
            type: Number,
        },
        density: {
            type: Number,
        },
        gdp: {
            type: Number,
        },
        climate: {
            type: String,
        },
        language: {
            type: [String],
        }
    });

    const City = mongoose.model('City', schema);

    fs.createReadStream('dataset.csv')
    .pipe(csv({ headers: false }))
    .on('data', async (row) => {
        const object = {
            city: row[0],
            country: row[1],
            population: parseInt(row[2]),
            area: parseFloat(row[3]),
            density: parseFloat(row[4]),
            gdp: parseInt(row[5]),
            climate: row[6],
            language: row[7].split(','),
        }
        const city = new City(object);
        await city.save();
    })
    .on('end', () => {
        console.log('CSV file has been processed.');
    });
}).catch((error) => {
    console.log('Error connecting to MongoDB', error.message);
});

console.log('End of script');