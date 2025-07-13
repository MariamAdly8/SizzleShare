# Recipe Management System - Admin Panel

This is a web application for recipe management with an admin panel for reviewing and approving recipe submissions.

## Features

### Admin Panel
- **Admin Registration & Login**: Secure authentication for admin users
- **Recipe Review Dashboard**: View all recipe submissions with their status
- **Recipe Approval System**: Accept or reject recipe submissions
- **Statistics Dashboard**: View counts of pending, approved, and rejected recipes
- **Modern UI**: Beautiful, responsive design with smooth animations

### Recipe Management
- Recipe submissions with ingredients, categories, and descriptions
- Approval workflow (pending → approved/rejected)
- User authentication and authorization
- Image upload support

## Setup Instructions

### Prerequisites
- Node.js (v14 or higher)
- MongoDB database
- npm or yarn package manager

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd endpoints
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Environment Configuration**
   Create a `.env` file in the root directory:
   ```env
   MONGODB_URI=your_mongodb_connection_string
   JWT_SECRET=your_jwt_secret_key
   PORT=3000
   ```

4. **Start the server**
   ```bash
   npm start
   ```

5. **Access the Admin Panel**
   Open your browser and navigate to:
   ```
   http://localhost:3000
   ```

## Admin Panel Usage

### First Time Setup
1. **Register an Admin Account**
   - Click "Register here" on the login page
   - Fill in your name, email, and password
   - Click "Register"

2. **Login to Admin Panel**
   - Use your registered email and password
   - Click "Login"

### Managing Recipes
1. **View Recipe Submissions**
   - All recipes are displayed on the dashboard
   - Recipes show their current status (pending, approved, rejected)
   - View recipe details including ingredients, categories, and author

2. **Approve/Reject Recipes**
   - For pending recipes, you'll see "Accept" and "Reject" buttons
   - Click "✅ Accept" to approve a recipe
   - Click "❌ Reject" to reject a recipe
   - The recipe status will update immediately

3. **Dashboard Statistics**
   - View counts of pending, approved, and rejected recipes
   - Statistics update automatically when you approve/reject recipes

## API Endpoints

### Admin Routes
- `POST /api/admin/register` - Register new admin
- `POST /api/admin/login` - Admin login
- `GET /api/admin/pending-recipes` - Get all recipes for review
- `PUT /api/admin/accept-recipe/:recipeId` - Approve a recipe
- `PUT /api/admin/reject-recipe/:recipeId` - Reject a recipe

### Recipe Routes
- `GET /api/recipes` - Get all recipes
- `POST /api/recipes` - Create new recipe (requires auth)
- `GET /api/recipes/:recipeId` - Get specific recipe
- `PUT /api/recipes/:recipeId` - Update recipe (requires auth)
- `DELETE /api/recipes/:recipeId` - Delete recipe (requires auth)

### User Routes
- `POST /api/users/signup` - User registration
- `POST /api/users/login` - User login
- `GET /api/users/me` - Get current user (requires auth)

## Security Features

- **JWT Authentication**: Secure token-based authentication
- **Password Hashing**: Passwords are hashed using bcrypt
- **Admin Authorization**: Admin-only routes are protected
- **Input Validation**: Server-side validation for all inputs
- **CORS Protection**: Cross-origin resource sharing protection

## File Structure

```
endpoints/
├── public/                 # Admin web app frontend
│   ├── index.html         # Main HTML file
│   ├── styles.css         # CSS styles
│   └── script.js          # JavaScript functionality
├── controllers/           # API controllers
│   ├── adminController.js # Admin-specific logic
│   ├── recipeController.js
│   └── userController.js
├── models/               # Database models
│   ├── recipeModel.js
│   └── userModel.js
├── routers/              # API routes
│   ├── adminRoutes.js
│   ├── recipeRoutes.js
│   └── userRoutes.js
├── middleware/           # Custom middleware
│   └── authMiddleware.js
├── app.js               # Express app configuration
├── server.js            # Server entry point
└── package.json         # Dependencies and scripts
```

## Technologies Used

- **Backend**: Node.js, Express.js, MongoDB, Mongoose
- **Frontend**: HTML5, CSS3, Vanilla JavaScript
- **Authentication**: JWT, bcrypt
- **File Upload**: Multer
- **Validation**: Express-validator

## Troubleshooting

### Common Issues

1. **MongoDB Connection Error**
   - Ensure MongoDB is running
   - Check your connection string in `.env`
   - Verify network connectivity

2. **Port Already in Use**
   - Change the PORT in `.env` file
   - Or kill the process using the current port

3. **Admin Registration Fails**
   - Check if admin with same email already exists
   - Ensure password meets requirements (8+ chars, uppercase, lowercase, number, special char)

4. **CORS Errors**
   - Ensure the frontend is served from the same origin
   - Check CORS configuration in `app.js`

### Support

For additional support or questions, please check the code comments or create an issue in the repository. 