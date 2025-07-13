const app = require('./app');
const connectDb = require('./configs/DB');

// Connect to the database
connectDb();

// Start the server
app.listen(3000,'192.168.1.181', () => {
    console.log('Server is running on port 3000');
});
