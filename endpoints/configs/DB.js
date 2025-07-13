const mongoose = require('mongoose');

// Connection URL
const url = 'mongodb://127.0.0.1:27017/SizzleShare';

const connectDb = () => {
    mongoose.connect(url).then(() => {
        console.log('Connected successfully to MongoDB server');
    }).catch(err => {
        console.log('Failed to connect to MongoDB', err);
    });
}

module.exports = connectDb;
