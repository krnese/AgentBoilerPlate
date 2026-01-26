# Kristian's Wine Cellar

A professional e-commerce web application for browsing and purchasing premium wines from around the world.

## Overview

Kristian's Wine Cellar is a static web application built with HTML, CSS, and JavaScript, designed to showcase a curated collection of fine wines. The application features a modern, responsive design with full e-commerce functionality including product browsing, filtering, searching, and a mock shopping cart.

## Features

- **Product Catalog**: Browse 12 premium wines from around the world
- **Advanced Filtering**: Filter by wine type, country, price range
- **Search Functionality**: Search wines by name, description, or region
- **Sorting Options**: Sort by name, price (low/high), or rating
- **Shopping Cart**: Add wines to cart, adjust quantities, view totals
- **Product Details**: View detailed information including tasting notes and grape varieties
- **Responsive Design**: Mobile-first design that works on all devices
- **Modern UI**: Clean, professional interface with wine-themed color scheme

## Technology Stack

- **Frontend**: HTML5, CSS3, Vanilla JavaScript
- **Infrastructure**: Azure Static Web App (Free tier)
- **Region**: Sweden Central
- **Deployment**: Azure CLI with Bicep templates

## Project Structure

```
kristians-wine-cellar/
├── infra/
│   ├── main.bicep              # Main Bicep template (subscription scope)
│   └── staticwebapp.bicep      # Static Web App module
├── src/
│   ├── index.html              # Main HTML file
│   ├── css/
│   │   └── styles.css          # Application styles
│   ├── js/
│   │   ├── app.js              # Main application logic
│   │   ├── cart.js             # Shopping cart functionality
│   │   └── filters.js          # Filtering and sorting
│   ├── data/
│   │   └── wines.json          # Wine catalog data
│   └── images/
│       └── README.md           # Image documentation
├── plan.md                     # Project plan
└── README.md                   # This file
```

## Wine Collection

The application features 12 premium wines:
- **Red Wines**: Château Margaux, Barolo Riserva, Opus One, Penfolds Grange, Rioja Gran Reserva
- **White Wines**: Cloudy Bay Sauvignon Blanc, Chablis Grand Cru, Riesling Spätlese
- **Rosé Wines**: Whispering Angel, Miraval
- **Sparkling Wines**: Moët & Chandon, Dom Pérignon

## Deployment Instructions

### Prerequisites

- Azure CLI installed
- Azure subscription with appropriate permissions
- Authenticated Azure CLI session

### Deploy Infrastructure

1. **Login to Azure**:
   ```bash
   az login
   ```

2. **Deploy the Bicep template**:
   ```bash
   cd infra
   az deployment sub create \
     --name kristians-wine-cellar-deployment \
     --location swedencentral \
     --template-file main.bicep
   ```

3. **Capture deployment outputs**:
   ```bash
   DEPLOYMENT_TOKEN=$(az deployment sub show \
     --name kristians-wine-cellar-deployment \
     --query properties.outputs.staticWebAppId.value -o tsv | \
     xargs -I {} az staticwebapp secrets list --ids {} --query properties.apiKey -o tsv)
   
   APP_URL=$(az deployment sub show \
     --name kristians-wine-cellar-deployment \
     --query properties.outputs.staticWebAppUrl.value -o tsv)
   ```

### Deploy Application

1. **Install Static Web Apps CLI** (if not already installed):
   ```bash
   npm install -g @azure/static-web-apps-cli
   ```

2. **Deploy the static content**:
   ```bash
   cd ../src
   swa deploy . \
     --deployment-token $DEPLOYMENT_TOKEN \
     --app-location . \
     --output-location .
   ```

3. **Access the application**:
   ```bash
   echo "Application URL: $APP_URL"
   ```

### Alternative Deployment with Azure CLI

You can also use Azure CLI to deploy directly:

```bash
cd src
zip -r ../app.zip .
cd ..

az staticwebapp browse \
  --name swa-kristians-wine-cellar \
  --resource-group rg-kristians-wine-cellar-swc
```

## Local Development

To run the application locally:

1. **Start a local web server**:
   ```bash
   cd src
   python3 -m http.server 8080
   # or
   npx http-server -p 8080
   ```

2. **Open in browser**:
   ```
   http://localhost:8080
   ```

## Usage

### Browsing Wines

1. Navigate to the "Wines" section
2. Browse the wine collection displayed in a grid layout
3. Use the search bar to find specific wines
4. Apply filters to narrow down results by type, country, or price
5. Sort wines by name, price, or rating

### Shopping Cart

1. Click "Add to Cart" on any wine card
2. Click the cart icon in the header to view your cart
3. Adjust quantities using +/- buttons
4. Remove items with the "Remove" button
5. Click "Checkout" for a mock checkout experience

### Wine Details

1. Click on any wine card or the "Details" button
2. View comprehensive information including:
   - Grape varieties
   - Tasting notes
   - Vintage and region
   - Alcohol content
3. Add directly to cart from the detail view

## Configuration

### Customizing the Wine Collection

Edit `src/data/wines.json` to add, remove, or modify wines. Each wine should have:

```json
{
  "id": 1,
  "name": "Wine Name",
  "type": "Red|White|Rosé|Sparkling",
  "country": "Country",
  "region": "Region",
  "vintage": 2020,
  "price": 99.99,
  "rating": 4.5,
  "image": "images/wine.jpg",
  "description": "Wine description",
  "tastingNotes": "Tasting notes",
  "alcohol": 13.5,
  "grapeVarieties": ["Grape1", "Grape2"]
}
```

### Styling

Modify `src/css/styles.css` to customize:
- Color scheme (CSS variables in `:root`)
- Layout and spacing
- Typography
- Responsive breakpoints

## Browser Support

- Chrome (latest)
- Firefox (latest)
- Safari (latest)
- Edge (latest)
- Mobile browsers (iOS Safari, Chrome Mobile)

## Performance

The application is optimized for:
- Fast initial load (no external dependencies)
- Efficient filtering and sorting
- Smooth animations and transitions
- Responsive images with CSS
- Local storage for cart persistence

## Security

- No sensitive data storage
- Client-side only (no server-side code)
- HTTPS enforced via Azure Static Web Apps
- No external API calls or third-party scripts

## Future Enhancements

Potential improvements for production:
- Real product images
- Integration with payment gateway
- User accounts and authentication
- Order history
- Inventory management
- Wine recommendations
- Reviews and ratings system
- Advanced search with Elasticsearch
- Multiple languages support

## License

This is a demo application created for educational purposes.

## Support

For issues or questions, please contact:
- Email: info@kristianswinecellar.com
- Location: Stockholm, Sweden

---

**Note**: This is a demonstration application with mock checkout functionality. No actual payment processing is implemented.
