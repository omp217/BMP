const express = require('express');
const mongoose = require('mongoose');
const _ = require('lodash');

const app = express();

const dbURL = "mongodb+srv://sherlock:sherlocked221b@cluster0.cfth3qm.mongodb.net/bmp";

const products = [];

mongoose.connect(dbURL, {
    useNewUrlParser: true,
    useUnifiedTopology: true
}).then(() => {
    console.log('Connected to MongoDB');

    const Schema = mongoose.Schema;

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

    Product.find({}).then((data) => {
        products.push(...data);
    }).catch((err) => {
        console.log(err);
    });

    app.listen(3000, () => {
        console.log('Server started');
    });
}).catch((err) => {
    console.log(err);
});

app.use(function(req, res, next) {
    console.log('Here in middleware.')
    res.header("Access-Control-Allow-Origin", "*");
    res.header("Access-Control-Allow-Methods", "GET,PUT,PATCH,POST,DELETE");
    res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
    next();
});

app.get('/', (req, res) => {
    res.json(products)
});

app.get('/:category/:platform', async (req, res) => {
    const categories = ['Men', 'Women'];
    const platforms = ['Amazon', 'Flipkart', 'Snapdeal'];

    let category = parseInt(req.params.category);
    let platform = parseInt(req.params.platform);

    let result = [];

    if(category === 0) category = 3;
    if(platform === 0) platform = 7;

    let categoryArr = [];
    for(let i = 0; i < 2; i++) {
        if(category & (1 << i)) categoryArr.push(categories[i]);
    }

    let platformArr = [];
    for(let i = 0; i < 3; i++) {
        if(platform & (1 << i)) platformArr.push(platforms[i]);
    }

    result = products.filter((product) => {
        return categoryArr.includes(product.category) && platformArr.includes(product.platform);
    });

    result = result.map((product) => {
        let rating = (5 * product.five_star + 4 * product.four_star + 3 * product.three_star + 2 * product.two_star + 1 * product.one_star) / (product.five_star + product.four_star + product.three_star + product.two_star + product.one_star);
        product.rating = rating.toFixed(1);
        return product;
    });

    result = _.map(result, result => _.pick(result, ['title', 'category', 'platform', 'price', 'discount', 'rating']));
    
    result = _.orderBy(result, ['price'], ['asc']);

    res.json(result);
});