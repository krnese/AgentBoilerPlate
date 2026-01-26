# Kristian's Wine Cellar - Azure Static Web App Plan

## Project Overview
Create an attractive, e-commerce-styled wine cellar showcase web application for displaying wine inventory. The app will be static (HTML/CSS/JavaScript only) with no backend or database, deployed to **Azure Static Web Apps** in **Sweden Central** using the **Free tier** for cost optimization.

## Requirements Summary
- **Region**: Sweden Central
- **Technology**: Static HTML/CSS/JavaScript
- **Functionality**: Display-only wine catalog with e-commerce appearance
- **Data Storage**: Static JSON file (no database)
- **Pricing**: Free tier (Azure Static Web Apps)
- **Naming Convention**: Simple (e.g., `kristians-wine-cellar`)
- **Domain**: Default Azure domain (*.azurewebsites.net)

## Architecture Decision

### Selected Azure Service: **Azure Static Web Apps (Free Tier)**

**Why Azure Static Web Apps over App Service?**
1. **Cost**: 100% FREE tier available (no charges)
2. **Perfect for static content**: Optimized for HTML/CSS/JavaScript
3. **Global CDN included**: Automatic content distribution for fast loading
4. **SSL/HTTPS**: Free managed certificates included
5. **Custom domains**: Free (if needed in future)
6. **GitHub Actions CI/CD**: Built-in deployment automation
7. **No server management**: Fully managed, zero maintenance

**App Service F1 Alternative** would also be free but:
- Requires more configuration
- Less optimized for static content
- No built-in CDN in free tier
- Static Web Apps is the modern Azure-recommended approach for this use case

## Architecture Components

### 1. **Azure Static Web App**
- **SKU**: Free
- **Region**: Sweden Central
- **Name**: `kristians-wine-cellar`
- **Features**:
  - Hosts static HTML, CSS, JavaScript files
  - Serves JSON data file with wine inventory
  - Global CDN distribution included
  - Automatic HTTPS

### 2. **Web Application Structure**
```
/src
├── index.html              # Main landing page
├── products.html           # Wine catalog page
├── product-detail.html     # Individual wine details page
├── about.html              # About the cellar
├── contact.html            # Contact information
├── css/
│   ├── styles.css          # Custom styles
│   └── bootstrap.min.css   # Bootstrap framework (or CDN link)
├── js/
│   ├── app.js              # Main JavaScript logic
│   ├── products.js         # Wine catalog rendering
│   └── cart.js             # Mock shopping cart (display only)
├── data/
│   └── wines.json          # Wine inventory data
├── images/
│   └── wine-*.jpg          # Wine product images
└── staticwebapp.config.json # Azure Static Web Apps configuration
```

### 3. **Wine Data Model (JSON)**
```json
{
  "wines": [
    {
      "id": 1,
      "name": "Château Margaux 2015",
      "region": "Bordeaux, France",
      "type": "Red Wine",
      "vintage": 2015,
      "price": 850,
      "description": "...",
      "image": "images/wine-1.jpg",
      "inStock": true,
      "rating": 4.8
    }
  ]
}
```

## Design Requirements (Attractive E-commerce Appearance)

### Visual Design Elements
1. **Modern, Clean Layout**
   - Responsive design (mobile, tablet, desktop)
   - Grid-based product display
   - High-quality wine bottle images
   - Professional color scheme (burgundy, gold, dark gray, white)

2. **E-commerce Features (Display Only)**
   - Product grid with images and prices
   - "Add to Cart" buttons (visual only, shows notification)
   - Shopping cart icon with item counter (mock)
   - Product filters (type, region, price range)
   - Search functionality
   - Product detail pages with full descriptions
   - Customer reviews/ratings display (static)
   - "Featured Wines" section
   - Special offers banner

3. **Professional Elements**
   - Hero banner with compelling tagline
   - Navigation menu (Home, Wines, About, Contact)
   - Footer with social media icons
   - Newsletter signup form (visual only)
   - Trust badges (secure shopping, quality guarantee)
   - Smooth animations and transitions
   - Loading states for dynamic content

4. **UI Framework**
   - **Bootstrap 5** or **Tailwind CSS** for responsive design
   - Font Awesome icons for cart, search, filters
   - Google Fonts for elegant typography
   - CSS animations for interactivity

### User Experience Flow
1. **Landing Page**: Hero image, featured wines, call-to-action
2. **Wine Catalog**: Filterable grid of all wines with images and prices
3. **Product Detail**: Full wine information, mock "Add to Cart"
4. **Mock Cart**: Shows selected items (stored in localStorage)
5. **About**: Story of the wine cellar
6. **Contact**: Contact information (no form submission needed)

## Implementation Steps

### Phase 1: Infrastructure Setup (Bicep)
1. Create resource group: `rg-kristians-wine-cellar`
2. Deploy Azure Static Web App using Bicep:
   - Name: `kristians-wine-cellar`
   - Location: Sweden Central
   - SKU: Free
   - GitHub repository integration (optional for CI/CD)

### Phase 2: Web Application Development
1. **HTML Structure**
   - Create responsive HTML5 pages
   - Semantic HTML for SEO
   - Meta tags for social sharing

2. **CSS Styling**
   - Implement Bootstrap/Tailwind framework
   - Custom CSS for branding
   - Responsive breakpoints
   - Animations and transitions

3. **JavaScript Functionality**
   - Fetch and display wines from JSON
   - Implement product filtering and search
   - Mock shopping cart with localStorage
   - Dynamic product detail rendering
   - Image gallery/zoom functionality

4. **Content Creation**
   - Sample wine data (10-15 wines minimum)
   - Wine descriptions and pricing
   - Placeholder wine bottle images (or royalty-free images)

### Phase 3: Deployment Configuration
1. Create `staticwebapp.config.json`:
   - Route configuration
   - Custom 404 page
   - MIME types
   - Security headers

2. Deploy static files to Azure Static Web Apps:
   - Option A: Azure CLI deployment
   - Option B: GitHub Actions (automated)
   - Option C: Manual upload via Azure Portal

### Phase 4: Validation & Testing
1. **Functionality Testing**
   - All pages load correctly
   - Wine data displays properly
   - Filters and search work
   - Mock cart functionality
   - Responsive design on mobile/tablet/desktop

2. **Performance Testing**
   - Page load times < 2 seconds
   - Image optimization
   - CDN effectiveness

3. **Browser Compatibility**
   - Chrome, Firefox, Safari, Edge
   - Mobile browsers

4. **Accessibility**
   - WCAG 2.1 AA compliance
   - Keyboard navigation
   - Screen reader support

## Azure Resources & Costs

| Resource | SKU | Region | Monthly Cost |
|----------|-----|--------|--------------|
| Static Web App | Free | Sweden Central | **$0.00** |
| Bandwidth | First 100 GB free | Global | **$0.00** |
| **TOTAL** | | | **$0.00/month** |

### Free Tier Limits
- **Bandwidth**: 100 GB/month
- **Custom domains**: 2 included
- **SSL certificates**: Free, automatic
- **Build minutes**: 100 minutes/month (GitHub Actions)
- **Staging environments**: Not included (paid tiers only)

## Security & Compliance

### Security Measures
1. **HTTPS Only**: Enforced by default
2. **Content Security Policy**: Configured in staticwebapp.config.json
3. **CORS**: Not needed (static content only)
4. **No sensitive data**: All content is public

### Azure Policy Compliance
- ✅ Complies with ASC Default policies (audit only)
- ✅ No database policies apply
- ✅ No blocked configurations

## Deployment Commands

### Azure CLI Deployment
```bash
# Login to Azure
az login

# Set subscription
az account set --subscription "fcbf5e04-699b-436a-88ef-d72081f7ad52"

# Create resource group
az group create \
  --name rg-kristians-wine-cellar \
  --location swedencentral

# Deploy Bicep template
az deployment group create \
  --resource-group rg-kristians-wine-cellar \
  --template-file main.bicep

# Get deployment token
az staticwebapp secrets list \
  --name kristians-wine-cellar \
  --resource-group rg-kristians-wine-cellar

# Deploy static content
az staticwebapp deploy \
  --name kristians-wine-cellar \
  --resource-group rg-kristians-wine-cellar \
  --source ./src
```

## Success Criteria
- ✅ Azure Static Web App deployed to Sweden Central
- ✅ Website accessible via HTTPS
- ✅ Displays at least 10-15 wines with images and details
- ✅ Professional e-commerce appearance
- ✅ Responsive design works on all devices
- ✅ Mock shopping cart functionality
- ✅ Product filtering and search work
- ✅ Fast page load times (< 2 seconds)
- ✅ All pages navigable and functional
- ✅ Total monthly cost: $0.00

## Future Enhancements (Optional)
1. Add real e-commerce functionality (requires backend)
2. Integrate Azure Functions for contact form
3. Add user authentication with Azure AD B2C
4. Implement real shopping cart with payment processing
5. Connect to database for dynamic inventory
6. Add admin panel for wine management
7. Implement email notifications
8. Add blog section for wine articles

## File Deliverables
1. **main.bicep** - Infrastructure as Code
2. **src/** - Complete web application
3. **README.md** - Deployment and usage instructions
4. **staticwebapp.config.json** - Azure configuration
5. **wines.json** - Sample wine data
6. **Documentation** - Architecture and design decisions

## Notes for Developer
- Use modern JavaScript (ES6+)
- Ensure all images are optimized (<200KB each)
- Include sample wine data with realistic descriptions
- Make the site visually appealing with attention to typography and spacing
- Add subtle animations to enhance user experience
- Include clear call-to-action buttons
- Use professional color palette suitable for wine/luxury products
- Ensure accessibility best practices are followed
- Test on multiple devices and browsers before finalizing

---

**This plan is ready for implementation by the Developer agent.**
