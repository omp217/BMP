const mongoose  = require('mongoose');
const csv = require('csv-parser');
const fs = require('fs');
const axios = require('axios');
const https = require('https');

let nextPageMen = 'https://api.pexels.com/v1/search/?page=1&per_page=50&query=men';
let nextPageWomen = 'https://api.pexels.com/v1/search/?page=1&per_page=50&query=women';

let queueMen = [];
let queueWomen = [];

async function getRandomImage(gender) {
    let url = gender ? nextPageMen : nextPageWomen;
    console.log('URL Assigned : ', url);
    let response = await fetch(url, {
        headers: {
            Authorization: 'sFLyghBm0tk8AvxR9JOuOMcRfmtwAM8M5BzcLqRbwci3R1PD7SU7ObAt'
        }
    });
    response = await response.json();
    gender ? nextPageMen = response.next_page : nextPageWomen = response.next_page;
    if(response?.photos?.length === 0) {
        gender ? nextPageMen = 'https://api.pexels.com/v1/search/?page=1&per_page=50&query=man' : nextPageWomen = 'https://api.pexels.com/v1/search/?page=1&per_page=50&query=woman';
        await getRandomImage(gender);
        return;
    }
    for(let photo of response.photos) {
        gender ? queueMen.push(photo.url) : queueWomen.push(photo.url);
    }
}

const Schema = mongoose.Schema;

const dbURL = "mongodb+srv://sherlock:sherlocked221b@cluster0.cfth3qm.mongodb.net/bmp"

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
        imageurl: {
            type: String,
        }
    });

    const Product = mongoose.model('Product', schema);

    let total = 0;

    let rows = [];

    fs.createReadStream('dataset.csv')
    .pipe(csv({ headers: false }))
    .on('data', (row) => {
        rows.push(row);
    })
    .on('end', async () => {
        console.log('CSV file successfully processed');
        for(let row of rows) {
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

                if(object.category === 'Men') {
                    if(queueMen.length===0) {
                        await getRandomImage(true);
                    }
                    object.imageurl = queueMen.shift();
                }
                else {
                    if(queueWomen.length===0) {
                        await getRandomImage(false);
                    }
                    object.imageurl = queueWomen.shift();
                }
                console.log(object.category, object.imageurl)
    
                const product = new Product(object);
                await product.save();
                console.log('Saved - ', ++total);
            }
        }
    });
}).catch((error) => {
    console.log('Error connecting to MongoDB', error.message);
});