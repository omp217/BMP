const express = require('express');
const mongoose = require('mongoose');
const _ = require('lodash');

const app = express();

const dbURL = "mongodb+srv://202001262:devansh2292@cluster0.pbqmu9o.mongodb.net/?retryWrites=true&w=majority";

const products = [];

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

const product = mongoose.model('product', schema);


mongoose.connect(dbURL, {
    useNewUrlParser: true,
    useUnifiedTopology: true
}).then(() => {
    console.log('Connected to MongoDB');
}).catch((error) => {
    console.error('Error connecting to MongoDB:', error);
});

app.listen(3000, () => {
    console.log('Server started');
});

app.get('/', async (req, res) => {
    try {
        const products = await product.find();
        res.json(products);
    } catch (error) {
        console.error('Error fetching products:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});


app.get('/:category/:platform', async (req, res) => {
    try {

    let { category, platform } = req.params;

        let categoryFound = category.split('&');
        let platformFound = platform.split('&');

        for(let i = 0; i < categoryFound.length; i++) {
            categoryFound[i] = categoryFound[i].charAt(0).toUpperCase() + categoryFound[i].slice(1);
        }

        for(let i = 0; i < platformFound.length; i++) {
            platformFound[i] = platformFound[i].charAt(0).toUpperCase() + platformFound[i].slice(1);
        }


        console.log(categoryFound, platformFound);
        let result = await product.find({
            category: { $in: categoryFound },
            platform: { $in: platformFound }
    });

        // Add rating to each product
        result = result.map((product) => {
            const rating = (5 * product.five_star + 4 * product.four_star + 3 * product.three_star + 2 * product.two_star + 1 * product.one_star) / (product.five_star + product.four_star + product.three_star + product.two_star + product.one_star);
            product.rating = rating.toFixed(1);
            return product;
        });

        // Sort products by discount
        result = _.map(result, result => _.pick(result, ['title', 'category', 'platform', 'price', 'discount', 'rating']));
        result = _.orderBy(result, ['discount'], ['desc']);
        res.json(result);
    } catch (error) {
        console.error('Error fetching products:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});