// API Configuration
const API_BASE_URL = 'http://192.168.1.181:3000/api';

// State management
let currentUser = null;
let authToken = localStorage.getItem('adminToken');
let currentTab = 'recipes';

// DOM Elements
const authSection = document.getElementById('auth-section');
const dashboardSection = document.getElementById('dashboard-section');
const loginForm = document.getElementById('loginForm');
const logoutBtn = document.getElementById('logoutBtn');
const adminNameSpan = document.getElementById('adminName');
const recipesList = document.getElementById('recipesList');
const usersList = document.getElementById('usersList');
const banModal = document.getElementById('banModal');
const banUserForm = document.getElementById('banUserForm');
const userModal = document.getElementById('userModal');
const userModalContent = document.getElementById('userModalContent');

// Initialize app
document.addEventListener('DOMContentLoaded', function() {
    setupEventListeners();
    checkAuthStatus();
});

// Event Listeners
function setupEventListeners() {
    loginForm.addEventListener('submit', handleLogin);
    logoutBtn.addEventListener('click', handleLogout);
    
    // Tab navigation
    document.querySelectorAll('.tab-btn').forEach(btn => {
        btn.addEventListener('click', () => switchTab(btn.dataset.tab));
    });
    
    // Modal events
    document.querySelectorAll('.close').forEach(closeBtn => {
        closeBtn.addEventListener('click', () => {
            closeBanModal();
            closeUserModal();
        });
    });
    banUserForm.addEventListener('submit', handleBanUser);
    
    // Close modal when clicking outside
    window.addEventListener('click', (e) => {
        if (e.target === banModal) {
            closeBanModal();
        }
        if (e.target === userModal) {
            closeUserModal();
        }
    });
}

// Tab switching
function switchTab(tabName) {
    currentTab = tabName;
    
    // Update tab buttons
    document.querySelectorAll('.tab-btn').forEach(btn => {
        btn.classList.toggle('active', btn.dataset.tab === tabName);
    });
    
    // Update tab content
    document.querySelectorAll('.tab-content').forEach(content => {
        content.classList.toggle('active', content.id === `${tabName}-tab`);
    });
    
    // Load data for the selected tab
    if (tabName === 'recipes') {
        loadRecipes();
    } else if (tabName === 'users') {
        loadUsers();
    }
}

// Check authentication status
function checkAuthStatus() {
    if (authToken) {
        // Verify token is still valid
        fetch(`${API_BASE_URL}/admin/pending-recipes`, {
            headers: {
                'Authorization': `Bearer ${authToken}`
            }
        })
        .then(response => {
            if (response.ok) {
                showDashboard();
                loadDashboardData();
            } else {
                localStorage.removeItem('adminToken');
                showAuth();
            }
        })
        .catch(() => {
            localStorage.removeItem('adminToken');
            showAuth();
        });
    } else {
        showAuth();
    }
}

// Show authentication section
function showAuth() {
    authSection.style.display = 'flex';
    dashboardSection.style.display = 'none';
}

// Show dashboard section
function showDashboard() {
    authSection.style.display = 'none';
    dashboardSection.style.display = 'block';
}

// Handle login
async function handleLogin(e) {
    e.preventDefault();
    
    const email = document.getElementById('loginEmail').value;
    const password = document.getElementById('loginPassword').value;
    
    console.log('Attempting login with:', { email, password: password ? '***' : 'missing' });
    
    try {
        const response = await fetch(`${API_BASE_URL}/admin/login`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ email, password })
        });
        
        console.log('Login response status:', response.status);
        
        const data = await response.json();
        console.log('Login response data:', data);
        
        if (response.ok) {
            authToken = data.token;
            currentUser = data.admin;
            localStorage.setItem('adminToken', authToken);
            showDashboard();
            loadDashboardData();
            showMessage('Login successful!', 'success');
        } else {
            showMessage(data.message || 'Login failed', 'error');
        }
    } catch (error) {
        console.error('Login error:', error);
        showMessage('Network error. Please try again.', 'error');
    }
}

// Handle logout
function handleLogout() {
    localStorage.removeItem('adminToken');
    authToken = null;
    currentUser = null;
    showAuth();
    showMessage('Logged out successfully', 'success');
}

// Load dashboard data
async function loadDashboardData() {
    adminNameSpan.textContent = currentUser.name;
    if (currentTab === 'recipes') {
        await loadRecipes();
    } else if (currentTab === 'users') {
        await loadUsers();
    }
}

// Load recipes
async function loadRecipes() {
    try {
        const response = await fetch(`${API_BASE_URL}/admin/pending-recipes`, {
            headers: {
                'Authorization': `Bearer ${authToken}`
            }
        });
        
        if (response.ok) {
            const recipes = await response.json();
            displayRecipes(recipes);
            updateRecipeStats(recipes);
        } else {
            showMessage('Failed to load recipes', 'error');
        }
    } catch (error) {
        showMessage('Network error. Please try again.', 'error');
    }
}

// Load users
async function loadUsers() {
    try {
        const response = await fetch(`${API_BASE_URL}/admin/users`, {
            headers: {
                'Authorization': `Bearer ${authToken}`
            }
        });
        
        if (response.ok) {
            const users = await response.json();
            displayUsers(users);
            updateUserStats(users);
        } else {
            showMessage('Failed to load users', 'error');
        }
    } catch (error) {
        showMessage('Network error. Please try again.', 'error');
    }
}

// Display recipes
function displayRecipes(recipes) {
    if (recipes.length === 0) {
        recipesList.innerHTML = '<div class="loading">No recipes found</div>';
        return;
    }
    
    recipesList.innerHTML = recipes.map(recipe => {
        // Check if imageURL is a URL or base64 data
        const isUrl = recipe.imageURL && recipe.imageURL.startsWith('http');
        const isBase64 = recipe.imageURL && 
                        recipe.imageURL.length > 100 && 
                        recipe.imageURL.match(/^[A-Za-z0-9+/]*={0,2}$/);
        
        return `
        <div class="recipe-card">
            <div class="recipe-header">
                <div>
                    <div class="recipe-title">${recipe.recipeName}</div>
                    <div class="recipe-author">
                        by <span class="user-link" onclick="openUserModal('${recipe.userId?._id || recipe.userId}', '${recipe.userId?.name || 'Unknown'}')">${recipe.userId?.name || 'Unknown'}</span>
                    </div>
                </div>
                <span class="recipe-status status-${recipe.status || 'pending'}">
                    ${recipe.status || 'pending'}
                </span>
            </div>
            
            <div class="recipe-details">
                <div class="recipe-description">${recipe.description}</div>
                
                ${recipe.imageURL ? `
                    <div class="recipe-image-section">
                        <h4>Recipe Image:</h4>
                        <div class="image-container">
                            ${isUrl ? `
                                <img src="${recipe.imageURL}" 
                                     alt="${recipe.recipeName}" 
                                     class="recipe-image" 
                                     onerror="handleImageError(this, '${recipe._id}')"
                                     onload="handleImageLoad(this, '${recipe._id}')">
                                <div class="image-error" id="error-${recipe._id}" style="display: none;">
                                    <p>Failed to load image from URL.</p>
                                    <p class="image-data-info">URL: ${recipe.imageURL}</p>
                                </div>
                                <div class="image-info" id="info-${recipe._id}">
                                    <span class="image-size">External Image URL</span>
                                    <button class="btn btn-small" onclick="window.open('${recipe.imageURL}', '_blank')">
                                        🔗 Open Image
                                    </button>
                                </div>
                            ` : isBase64 ? `
                                <img src="data:image/jpeg;base64,${recipe.imageURL}" 
                                     alt="${recipe.recipeName}" 
                                     class="recipe-image" 
                                     onerror="handleImageError(this, '${recipe._id}')"
                                     onload="handleImageLoad(this, '${recipe._id}')">
                                <div class="image-error" id="error-${recipe._id}" style="display: none;">
                                    <p>Failed to load image. Image data may be corrupted or incomplete.</p>
                                    <p class="image-data-info">Data length: ${recipe.imageURL.length} characters</p>
                                </div>
                                <div class="image-info" id="info-${recipe._id}">
                                    <span class="image-size">Image Size: ${Math.round(recipe.imageURL.length * 0.75 / 1024)} KB</span>
                                    <button class="btn btn-small" onclick="downloadImage('${recipe.recipeName}', '${recipe.imageURL}')">
                                        💾 Download Image
                                    </button>
                                </div>
                            ` : `
                                <div class="no-image">
                                    <p>No image provided</p>
                                </div>
                            `}
                        </div>
                    </div>
                ` : ''}
                
                <div class="recipe-meta">
                    <span>⏱️ ${recipe.totalTime} minutes</span>
                    <span>🍽️ ${recipe.cuisine || 'Not specified'}</span>
                    <span>📅 ${new Date(recipe.createdAt).toLocaleDateString()}</span>
                </div>
                
                ${recipe.ingredients && recipe.ingredients.length > 0 ? `
                    <div class="recipe-ingredients">
                        <h4>Ingredients:</h4>
                        <div class="ingredients-list">
                            ${recipe.ingredients.map(ingredient => 
                                `<span class="ingredient-tag">${ingredient.name} - ${ingredient.quantity}</span>`
                            ).join('')}
                        </div>
                    </div>
                ` : ''}
            </div>
            
            ${recipe.status === 'pending' ? `
                <div class="recipe-actions">
                    <button class="btn btn-success" onclick="acceptRecipe('${recipe._id}')">
                        ✅ Accept
                    </button>
                    <button class="btn btn-danger" onclick="rejectRecipe('${recipe._id}')">
                        ❌ Reject
                    </button>
                </div>
            ` : ''}
        </div>
        `;
    }).join('');
}

// Display users
function displayUsers(users) {
    if (users.length === 0) {
        usersList.innerHTML = '<div class="loading">No users found</div>';
        return;
    }
    
    usersList.innerHTML = users.map(user => {
        const isCurrentUser = user._id === currentUser.id;
        const canBan = !isCurrentUser && user.type !== 'admin';
        
        return `
        <div class="user-card">
            <div class="user-header">
                <div>
                    <div class="user-name">${user.name}</div>
                    <div class="user-email">${user.email}</div>
                </div>
                <span class="user-status ${user.banned ? 'user-banned' : 'user-active'}">
                    ${user.banned ? 'Banned' : user.type === 'admin' ? 'Admin' : 'Active'}
                </span>
            </div>
            
            <div class="user-details">
                <div class="user-info-details">
                    <strong>Type:</strong> ${user.type}<br>
                    <strong>Joined:</strong> ${new Date(user.createdAt).toLocaleDateString()}<br>
                    ${user.lastLogin ? `<strong>Last Login:</strong> ${new Date(user.lastLogin).toLocaleDateString()}<br>` : ''}
                    ${user.banned && user.bannedAt ? `<strong>Banned At:</strong> ${new Date(user.bannedAt).toLocaleDateString()}` : ''}
                </div>
                
                <div class="user-meta">
                    <span>👤 ${user.type}</span>
                    <span>📅 ${new Date(user.createdAt).toLocaleDateString()}</span>
                    ${user.lastLogin ? `<span>🕒 ${new Date(user.lastLogin).toLocaleDateString()}</span>` : ''}
                    ${user.banned && user.bannedAt ? `<span>🚫 ${new Date(user.bannedAt).toLocaleDateString()}</span>` : ''}
                </div>
            </div>
            
            <div class="user-actions">
                ${user.banned ? `
                    <button class="btn btn-warning" onclick="unbanUser('${user._id}')">
                        🔓 Unban User
                    </button>
                ` : canBan ? `
                    <button class="btn btn-danger" onclick="openBanModal('${user._id}', '${user.name}')">
                        🚫 Ban User
                    </button>
                ` : ''}
                ${isCurrentUser ? `
                    <span class="btn btn-secondary" style="cursor: default;">Current User</span>
                ` : ''}
            </div>
        </div>
        `;
    }).join('');
}

// Update recipe statistics
function updateRecipeStats(recipes) {
    const pendingCount = recipes.filter(r => r.status === 'pending').length;
    const approvedCount = recipes.filter(r => r.status === 'approved').length;
    const rejectedCount = recipes.filter(r => r.status === 'rejected').length;
    
    document.getElementById('pendingCount').textContent = pendingCount;
    document.getElementById('approvedCount').textContent = approvedCount;
    document.getElementById('rejectedCount').textContent = rejectedCount;
}

// Update user statistics
function updateUserStats(users) {
    const totalUsers = users.length;
    const activeUsers = users.filter(u => !u.banned).length;
    const bannedUsers = users.filter(u => u.banned).length;
    
    document.getElementById('totalUsersCount').textContent = totalUsers;
    document.getElementById('activeUsersCount').textContent = activeUsers;
    document.getElementById('bannedUsersCount').textContent = bannedUsers;
}

// Accept recipe
async function acceptRecipe(recipeId) {
    try {
        const response = await fetch(`${API_BASE_URL}/admin/accept-recipe/${recipeId}`, {
            method: 'PUT',
            headers: {
                'Authorization': `Bearer ${authToken}`
            }
        });
        
        if (response.ok) {
            showMessage('Recipe accepted successfully!', 'success');
            loadRecipes();
        } else {
            const data = await response.json();
            showMessage(data.message || 'Failed to accept recipe', 'error');
        }
    } catch (error) {
        showMessage('Network error. Please try again.', 'error');
    }
}

// Reject recipe
async function rejectRecipe(recipeId) {
    try {
        const response = await fetch(`${API_BASE_URL}/admin/reject-recipe/${recipeId}`, {
            method: 'PUT',
            headers: {
                'Authorization': `Bearer ${authToken}`
            }
        });
        
        if (response.ok) {
            showMessage('Recipe rejected successfully!', 'success');
            loadRecipes();
        } else {
            const data = await response.json();
            showMessage(data.message || 'Failed to reject recipe', 'error');
        }
    } catch (error) {
        showMessage('Network error. Please try again.', 'error');
    }
}

// Ban user functions
let userToBan = null;

function openBanModal(userId, userName) {
    userToBan = userId;
    document.querySelector('#banModal h2').textContent = `Ban User: ${userName}`;
    banModal.style.display = 'flex';
}

function closeBanModal() {
    banModal.style.display = 'none';
    userToBan = null;
}

async function handleBanUser(e) {
    e.preventDefault();
    
    if (!userToBan) return;
    
    try {
        const response = await fetch(`${API_BASE_URL}/admin/ban-user/${userToBan}`, {
            method: 'PUT',
            headers: {
                'Authorization': `Bearer ${authToken}`,
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({})
        });
        
        if (response.ok) {
            showMessage('User banned successfully!', 'success');
            closeBanModal();
            loadUsers();
        } else {
            const data = await response.json();
            showMessage(data.message || 'Failed to ban user', 'error');
        }
    } catch (error) {
        showMessage('Network error. Please try again.', 'error');
    }
}

async function unbanUser(userId) {
    if (!confirm('Are you sure you want to unban this user?')) return;
    
    try {
        const response = await fetch(`${API_BASE_URL}/admin/unban-user/${userId}`, {
            method: 'PUT',
            headers: {
                'Authorization': `Bearer ${authToken}`
            }
        });
        
        if (response.ok) {
            showMessage('User unbanned successfully!', 'success');
            loadUsers();
        } else {
            const data = await response.json();
            showMessage(data.message || 'Failed to unban user', 'error');
        }
    } catch (error) {
        showMessage('Network error. Please try again.', 'error');
    }
}

// Utility functions
function showMessage(message, type) {
    // Remove existing messages
    const existingMessages = document.querySelectorAll('.message');
    existingMessages.forEach(msg => msg.remove());
    
    const messageDiv = document.createElement('div');
    messageDiv.className = `message ${type}`;
    messageDiv.textContent = message;
    
    // Insert at the top of the dashboard main
    const dashboardMain = document.querySelector('.dashboard-main');
    dashboardMain.insertBefore(messageDiv, dashboardMain.firstChild);
    
    // Auto remove after 5 seconds
    setTimeout(() => {
        if (messageDiv.parentNode) {
            messageDiv.remove();
        }
    }, 5000);
}

async function copyImageUrl(imageUrl) {
    try {
        await navigator.clipboard.writeText(imageUrl);
        showMessage('Image URL copied to clipboard!', 'success');
    } catch (err) {
        showMessage('Failed to copy URL', 'error');
    }
}

function handleImageError(imgElement, recipeId) {
    imgElement.style.display = 'none';
    const errorDiv = document.getElementById(`error-${recipeId}`);
    const infoDiv = document.getElementById(`info-${recipeId}`);
    if (errorDiv) errorDiv.style.display = 'block';
    if (infoDiv) infoDiv.style.display = 'none';
}

function handleImageLoad(imgElement, recipeId) {
    const errorDiv = document.getElementById(`error-${recipeId}`);
    const infoDiv = document.getElementById(`info-${recipeId}`);
    if (errorDiv) errorDiv.style.display = 'none';
    if (infoDiv) infoDiv.style.display = 'block';
}

function downloadImage(recipeName, imageData) {
    const link = document.createElement('a');
    link.href = `data:image/jpeg;base64,${imageData}`;
    link.download = `${recipeName.replace(/[^a-z0-9]/gi, '_').toLowerCase()}.jpg`;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
}

// User management modal functions
let currentUserInModal = null;

async function openUserModal(userId, userName) {
    try {
        const response = await fetch(`${API_BASE_URL}/admin/users/${userId}`, {
            headers: {
                'Authorization': `Bearer ${authToken}`
            }
        });
        
        if (response.ok) {
            const user = await response.json();
            currentUserInModal = user;
            displayUserInModal(user);
            userModal.style.display = 'flex';
        } else {
            showMessage('Failed to load user information', 'error');
        }
    } catch (error) {
        showMessage('Network error. Please try again.', 'error');
    }
}

function displayUserInModal(user) {
    const isCurrentUser = user._id === currentUser.id;
    const canBan = !isCurrentUser && user.type !== 'admin';
    
    userModalContent.innerHTML = `
        <div class="user-info-details">
            <h3>${user.name}</h3>
            <p><strong>Email:</strong> ${user.email}</p>
            <p><strong>Type:</strong> ${user.type}</p>
            <p><strong>Joined:</strong> ${new Date(user.createdAt).toLocaleDateString()}</p>
            ${user.lastLogin ? `<p><strong>Last Login:</strong> ${new Date(user.lastLogin).toLocaleDateString()}</p>` : ''}
            ${user.banned && user.bannedAt ? `<p><strong>Banned At:</strong> ${new Date(user.bannedAt).toLocaleDateString()}</p>` : ''}
        </div>
        
        <div class="user-actions" style="margin-top: 20px;">
            ${user.banned ? `
                <button class="btn btn-warning" onclick="unbanUserFromModal('${user._id}')">
                    🔓 Unban User
                </button>
            ` : canBan ? `
                <button class="btn btn-danger" onclick="banUserFromModal('${user._id}', '${user.name}')">
                    🚫 Ban User
                </button>
            ` : ''}
            ${isCurrentUser ? `
                <span class="btn btn-secondary" style="cursor: default;">Current User</span>
            ` : ''}
        </div>
    `;
}

function closeUserModal() {
    userModal.style.display = 'none';
    currentUserInModal = null;
}

async function banUserFromModal(userId, userName) {
    userToBan = userId;
    document.querySelector('#banModal h2').textContent = `Ban User: ${userName}`;
    banModal.style.display = 'flex';
    closeUserModal();
}

async function unbanUserFromModal(userId) {
    if (!confirm('Are you sure you want to unban this user?')) return;
    
    try {
        const response = await fetch(`${API_BASE_URL}/admin/unban-user/${userId}`, {
            method: 'PUT',
            headers: {
                'Authorization': `Bearer ${authToken}`
            }
        });
        
        if (response.ok) {
            showMessage('User unbanned successfully!', 'success');
            closeUserModal();
            // Refresh both recipes and users lists
            if (currentTab === 'recipes') {
                loadRecipes();
            } else if (currentTab === 'users') {
                loadUsers();
            }
        } else {
            const data = await response.json();
            showMessage(data.message || 'Failed to unban user', 'error');
        }
    } catch (error) {
        showMessage('Network error. Please try again.', 'error');
    }
} 