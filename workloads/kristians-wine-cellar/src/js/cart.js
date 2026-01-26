// Shopping cart management
let cart = [];

// Load cart from localStorage
function loadCart() {
    const savedCart = localStorage.getItem('wineCart');
    if (savedCart) {
        cart = JSON.parse(savedCart);
        updateCartDisplay();
    }
}

// Save cart to localStorage
function saveCart() {
    localStorage.setItem('wineCart', JSON.stringify(cart));
}

// Add item to cart
function addToCart(wineId) {
    const wine = wines.find(w => w.id === wineId);
    if (!wine) return;
    
    const existingItem = cart.find(item => item.id === wineId);
    
    if (existingItem) {
        existingItem.quantity += 1;
    } else {
        cart.push({
            id: wine.id,
            name: wine.name,
            price: wine.price,
            type: wine.type,
            quantity: 1
        });
    }
    
    saveCart();
    updateCartDisplay();
    
    // Show feedback
    showNotification(`${wine.name} added to cart!`);
}

// Remove item from cart
function removeFromCart(wineId) {
    cart = cart.filter(item => item.id !== wineId);
    saveCart();
    updateCartDisplay();
    displayCartItems();
}

// Update item quantity
function updateQuantity(wineId, change) {
    const item = cart.find(item => item.id === wineId);
    if (!item) return;
    
    item.quantity += change;
    
    if (item.quantity <= 0) {
        removeFromCart(wineId);
    } else {
        saveCart();
        updateCartDisplay();
        displayCartItems();
    }
}

// Update cart count in header
function updateCartDisplay() {
    const cartCount = cart.reduce((total, item) => total + item.quantity, 0);
    document.getElementById('cartCount').textContent = cartCount;
}

// Display cart items in modal
function displayCartItems() {
    const cartItemsContainer = document.getElementById('cartItems');
    const cartTotal = document.getElementById('cartTotal');
    
    if (cart.length === 0) {
        cartItemsContainer.innerHTML = '<div class="empty-cart">Your cart is empty</div>';
        cartTotal.textContent = '$0.00';
        return;
    }
    
    cartItemsContainer.innerHTML = cart.map(item => `
        <div class="cart-item">
            <div class="cart-item-info">
                <div class="cart-item-name">${item.name}</div>
                <div class="cart-item-price">$${item.price.toFixed(2)} each</div>
            </div>
            <div class="cart-item-controls">
                <div class="quantity-controls">
                    <button class="quantity-btn" onclick="updateQuantity(${item.id}, -1)">-</button>
                    <span class="quantity">${item.quantity}</span>
                    <button class="quantity-btn" onclick="updateQuantity(${item.id}, 1)">+</button>
                </div>
                <button class="remove-btn" onclick="removeFromCart(${item.id})">Remove</button>
            </div>
        </div>
    `).join('');
    
    const total = cart.reduce((sum, item) => sum + (item.price * item.quantity), 0);
    cartTotal.textContent = `$${total.toFixed(2)}`;
}

// Clear entire cart
function clearCart() {
    if (confirm('Are you sure you want to clear your cart?')) {
        cart = [];
        saveCart();
        updateCartDisplay();
        displayCartItems();
        showNotification('Cart cleared');
    }
}

// Mock checkout
function checkout() {
    if (cart.length === 0) {
        alert('Your cart is empty!');
        return;
    }
    
    const total = cart.reduce((sum, item) => sum + (item.price * item.quantity), 0);
    const itemCount = cart.reduce((total, item) => total + item.quantity, 0);
    
    alert(`Thank you for your order!\n\nItems: ${itemCount}\nTotal: $${total.toFixed(2)}\n\nThis is a demo store. No actual payment has been processed.`);
    
    // Clear cart after checkout
    cart = [];
    saveCart();
    updateCartDisplay();
    closeCart();
    
    showNotification('Order placed successfully! (Demo)');
}

// Show cart modal
function showCart() {
    displayCartItems();
    document.getElementById('cartModal').classList.add('active');
}

// Close cart modal
function closeCart() {
    document.getElementById('cartModal').classList.remove('active');
}

// Show notification
function showNotification(message) {
    // Create notification element if it doesn't exist
    let notification = document.getElementById('notification');
    if (!notification) {
        notification = document.createElement('div');
        notification.id = 'notification';
        notification.style.cssText = `
            position: fixed;
            top: 80px;
            right: 20px;
            background-color: #722F37;
            color: white;
            padding: 1rem 1.5rem;
            border-radius: 5px;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.3);
            z-index: 3000;
            opacity: 0;
            transition: opacity 0.3s ease;
        `;
        document.body.appendChild(notification);
    }
    
    notification.textContent = message;
    notification.style.opacity = '1';
    
    setTimeout(() => {
        notification.style.opacity = '0';
    }, 2000);
}

// Initialize cart on page load
document.addEventListener('DOMContentLoaded', () => {
    loadCart();
    
    // Cart icon click
    document.getElementById('cartIcon').addEventListener('click', showCart);
    
    // Close cart button
    document.getElementById('closeCart').addEventListener('click', closeCart);
    
    // Clear cart button
    document.getElementById('clearCart').addEventListener('click', clearCart);
    
    // Checkout button
    document.getElementById('checkoutBtn').addEventListener('click', checkout);
});
