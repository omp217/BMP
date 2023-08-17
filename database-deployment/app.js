const mongoose  = require('mongoose');
const csv = require('csv-parser');
const fs = require('fs');

const Schema = mongoose.Schema;

const dbURL = `mongodb+srv://202001262:devansh2292@cluster0.pbqmu9o.mongodb.net/?retryWrites=true&w=majority`


mongoose.connect(dbURL, {
    useNewUrlParser: true,
    useUnifiedTopology: true
}).then(async () => {
    console.log('Connected to MongoDB');

    const schema = new Schema({
        title: {
            type: String,
        },
        category: {
            type: String,
        },
        platform: {
            type: String,
        },
        price: {
            type: Number,
        },
        actual_price: {
            type: Number,
        },
        discount: {
            type: Number,
        },
        five_star: {
            type: Number,
        },
        four_star: {
            type: Number,
        },
        three_star: {
            type: Number,
        },
        two_star: {
            type: Number,
        },
        one_star: {
            type: Number,
        },
    });

    const Product = mongoose.model('Product', schema);

    let total = 0;

    fs.createReadStream('dataset.csv')
    .pipe(csv({ headers: false }))
    .on('data', async (row) => {
        let hasUnavailable = false;
        for (const key in row) {
            if (row[key] === '' || row[key] === undefined || row[key] === null) {
                hasUnavailable = true;
                break;
            }
        }
        if(!hasUnavailable) {
            const object = {
                title: row[0],
                category: row[1],
                platform: row[2],
                price: parseFloat(row[3]),
                actual_price: parseFloat(row[4]),
                discount: parseFloat(row[5].substring(0, row[5].length - 1)),
                five_star: parseInt(row[6]),
                four_star: parseInt(row[7]),
                three_star: parseInt(row[8]),
                two_star: parseInt(row[9]),
                one_star: parseInt(row[10]),
            };

            const platforms = ['Amazon', 'Flipkart', 'Snapdeal'];
            const randomIndex = Math.floor(Math.random() * platforms.length);
            object.platform = platforms[randomIndex];

            const product = new Product(object);
            await product.save();
            console.log('Saved - ', ++total);
        }
    })
}).catch((error) => {
    console.log('Error connecting to MongoDB', error.message);
});