// Filtering and sorting functionality

// Apply all filters
function applyFilters() {
    let filtered = [...wines];
    
    // Search filter
    const searchTerm = document.getElementById('searchInput').value.toLowerCase();
    if (searchTerm) {
        filtered = filtered.filter(wine => 
            wine.name.toLowerCase().includes(searchTerm) ||
            wine.description.toLowerCase().includes(searchTerm) ||
            wine.region.toLowerCase().includes(searchTerm) ||
            wine.country.toLowerCase().includes(searchTerm)
        );
    }
    
    // Type filter
    const typeFilter = document.getElementById('typeFilter').value;
    if (typeFilter) {
        filtered = filtered.filter(wine => wine.type === typeFilter);
    }
    
    // Country filter
    const countryFilter = document.getElementById('countryFilter').value;
    if (countryFilter) {
        filtered = filtered.filter(wine => wine.country === countryFilter);
    }
    
    // Price filter
    const priceFilter = document.getElementById('priceFilter').value;
    if (priceFilter) {
        const maxPrice = parseFloat(priceFilter);
        filtered = filtered.filter(wine => wine.price <= maxPrice);
    }
    
    // Sort
    const sortBy = document.getElementById('sortFilter').value;
    filtered = sortWines(filtered, sortBy);
    
    filteredWines = filtered;
    displayWines(filteredWines);
}

// Sort wines
function sortWines(winesToSort, sortBy) {
    const sorted = [...winesToSort];
    
    switch (sortBy) {
        case 'name':
            return sorted.sort((a, b) => a.name.localeCompare(b.name));
        case 'price-low':
            return sorted.sort((a, b) => a.price - b.price);
        case 'price-high':
            return sorted.sort((a, b) => b.price - a.price);
        case 'rating':
            return sorted.sort((a, b) => b.rating - a.rating);
        default:
            return sorted;
    }
}

// Debounce function for search
function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}

// Initialize filters
document.addEventListener('DOMContentLoaded', () => {
    // Search input with debounce
    const searchInput = document.getElementById('searchInput');
    const debouncedSearch = debounce(applyFilters, 300);
    searchInput.addEventListener('input', debouncedSearch);
    
    // Filter dropdowns
    document.getElementById('typeFilter').addEventListener('change', applyFilters);
    document.getElementById('countryFilter').addEventListener('change', applyFilters);
    document.getElementById('priceFilter').addEventListener('change', applyFilters);
    document.getElementById('sortFilter').addEventListener('change', applyFilters);
});
