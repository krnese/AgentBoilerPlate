// Main application logic
let wines = [];
let filteredWines = [];

// Load wines data
async function loadWines() {
    try {
        const response = await fetch('data/wines.json');
        const data = await response.json();
        wines = data.wines;
        filteredWines = wines;
        
        // Populate country filter
        populateCountryFilter();
        
        // Display wines
        displayWines(filteredWines);
        
        console.log('Wines loaded successfully:', wines.length);
    } catch (error) {
        console.error('Error loading wines:', error);
        document.getElementById('wineGrid').innerHTML = `
            <div class="loading">
                <h3>Error loading wines</h3>
                <p>Please try refreshing the page.</p>
            </div>
        `;
    }
}

// Populate country filter with unique countries
function populateCountryFilter() {
    const countries = [...new Set(wines.map(wine => wine.country))].sort();
    const countryFilter = document.getElementById('countryFilter');
    
    countries.forEach(country => {
        const option = document.createElement('option');
        option.value = country;
        option.textContent = country;
        countryFilter.appendChild(option);
    });
}

// Display wines in grid
function displayWines(winesToDisplay) {
    const wineGrid = document.getElementById('wineGrid');
    
    if (winesToDisplay.length === 0) {
        wineGrid.innerHTML = `
            <div class="no-results">
                <h3>No wines found</h3>
                <p>Try adjusting your filters or search terms.</p>
            </div>
        `;
        return;
    }
    
    wineGrid.innerHTML = winesToDisplay.map(wine => `
        <div class="wine-card" data-wine-id="${wine.id}">
            <div class="wine-image">${getWineEmoji(wine.type)}</div>
            <div class="wine-info">
                <span class="wine-type">${wine.type}</span>
                <h3 class="wine-name">${wine.name}</h3>
                <p class="wine-region">${wine.region}, ${wine.country}</p>
                <div class="wine-rating">${getStars(wine.rating)} ${wine.rating.toFixed(1)}</div>
                <div class="wine-price">$${wine.price.toFixed(2)}</div>
                <div class="wine-actions">
                    <button class="btn btn-secondary view-details-btn" data-wine-id="${wine.id}">
                        Details
                    </button>
                    <button class="btn btn-primary add-to-cart-btn" data-wine-id="${wine.id}">
                        Add to Cart
                    </button>
                </div>
            </div>
        </div>
    `).join('');
    
    // Add event listeners
    addWineEventListeners();
}

// Get wine emoji based on type
function getWineEmoji(type) {
    const emojis = {
        'Red': '🍷',
        'White': '🥂',
        'Rosé': '🌸',
        'Sparkling': '🍾'
    };
    return emojis[type] || '🍷';
}

// Get star rating display
function getStars(rating) {
    const fullStars = Math.floor(rating);
    const halfStar = rating % 1 >= 0.5;
    let stars = '⭐'.repeat(fullStars);
    if (halfStar) stars += '✨';
    return stars;
}

// Add event listeners to wine cards
function addWineEventListeners() {
    // View details buttons
    document.querySelectorAll('.view-details-btn').forEach(btn => {
        btn.addEventListener('click', (e) => {
            e.stopPropagation();
            const wineId = parseInt(btn.dataset.wineId);
            showWineDetails(wineId);
        });
    });
    
    // Add to cart buttons
    document.querySelectorAll('.add-to-cart-btn').forEach(btn => {
        btn.addEventListener('click', (e) => {
            e.stopPropagation();
            const wineId = parseInt(btn.dataset.wineId);
            addToCart(wineId);
        });
    });
    
    // Wine card click (show details)
    document.querySelectorAll('.wine-card').forEach(card => {
        card.addEventListener('click', () => {
            const wineId = parseInt(card.dataset.wineId);
            showWineDetails(wineId);
        });
    });
}

// Show wine details modal
function showWineDetails(wineId) {
    const wine = wines.find(w => w.id === wineId);
    if (!wine) return;
    
    const modal = document.getElementById('wineModal');
    const modalName = document.getElementById('wineDetailName');
    const modalContent = document.getElementById('wineDetailContent');
    
    modalName.textContent = wine.name;
    
    modalContent.innerHTML = `
        <div class="wine-detail">
            <div class="wine-detail-image">${getWineEmoji(wine.type)}</div>
            <div class="wine-detail-info">
                <h3>Details</h3>
                <p><strong>Type:</strong> ${wine.type}</p>
                <p><strong>Country:</strong> ${wine.country}</p>
                <p><strong>Region:</strong> ${wine.region}</p>
                <p><strong>Vintage:</strong> ${wine.vintage || 'NV (Non-Vintage)'}</p>
                <p><strong>Alcohol:</strong> ${wine.alcohol}%</p>
                <p><strong>Rating:</strong> ${getStars(wine.rating)} ${wine.rating.toFixed(1)}/5.0</p>
                <p><strong>Price:</strong> $${wine.price.toFixed(2)}</p>
                
                <h3 style="margin-top: 1.5rem;">Description</h3>
                <p>${wine.description}</p>
                
                <h3 style="margin-top: 1.5rem;">Tasting Notes</h3>
                <p>${wine.tastingNotes}</p>
                
                <h3 style="margin-top: 1.5rem;">Grape Varieties</h3>
                <p>${wine.grapeVarieties.join(', ')}</p>
                
                <button class="btn btn-primary" style="width: 100%; margin-top: 1.5rem;" onclick="addToCart(${wine.id}); closeWineModal();">
                    Add to Cart - $${wine.price.toFixed(2)}
                </button>
            </div>
        </div>
    `;
    
    modal.classList.add('active');
}

// Close wine detail modal
function closeWineModal() {
    document.getElementById('wineModal').classList.remove('active');
}

// Smooth scrolling for navigation links
document.addEventListener('DOMContentLoaded', () => {
    // Load wines
    loadWines();
    
    // Navigation links
    document.querySelectorAll('.nav-link').forEach(link => {
        link.addEventListener('click', (e) => {
            e.preventDefault();
            const targetId = link.getAttribute('href').substring(1);
            const targetElement = document.getElementById(targetId);
            
            if (targetElement) {
                targetElement.scrollIntoView({ behavior: 'smooth' });
            }
            
            // Update active link
            document.querySelectorAll('.nav-link').forEach(l => l.classList.remove('active'));
            link.classList.add('active');
        });
    });
    
    // Close modals when clicking outside
    window.addEventListener('click', (e) => {
        if (e.target.classList.contains('modal')) {
            e.target.classList.remove('active');
        }
    });
    
    // Close wine modal button
    document.getElementById('closeWineModal').addEventListener('click', closeWineModal);
});
