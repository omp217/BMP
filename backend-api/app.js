const express = require('express');
const mongoose = require('mongoose');
const _ = require('lodash');

const app = express();

const dbURL = "mongodb+srv://sherlock:sherlocked221b@cluster0.cfth3qm.mongodb.net/bmp";

const cities = [];

mongoose.connect(dbURL, {
    useNewUrlParser: true,
    useUnifiedTopology: true
}).then(() => {
    console.log('Connected to MongoDB');

    const Schema = mongoose.Schema;

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

    City.find({}).then((data) => {
        cities.push(...data);
    }).catch((err) => {
        console.log(err);
    });

    app.listen(3000, () => {
        console.log('Server started');
    });
}).catch((err) => {
    console.log(err);
});

app.get('/', (req, res) => {
    res.send({cities});
});

app.get('/:country', async (req, res) => {
    let country = req.params.country;
    country = country.split(',').map((country) => {
        let ret = country.trim();
        if(ret === 'usa') ret = 'USA';
        if(ret === 'india') ret = 'India';
        if(ret === 'china') ret = 'China';
        return ret;
    });
    let result = [];
    result = cities.filter((city) => {
        return country.includes(city.country);
    });
    result = _.map(result, result => _.pick(result, ['city', 'country', 'population', 'climate']));
    result = _.sortBy(result, ['population']);
    res.send({cities: result});
});