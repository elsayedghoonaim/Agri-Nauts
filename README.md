# Agri-nauts: Leveraging Earth Observation Data for Informed Agricultural Decision-Making

Welcome to the Agri-nauts project repository for NASA Space Apps 2024! Our team has developed an innovative mobile application that combines artificial intelligence and satellite data to revolutionize agricultural decision-making.


## Project Overview

Farmers worldwide face numerous water-related challenges due to unpredictable weather patterns, including droughts, floods, and soil moisture issues. These problems significantly impact crop health, farmer profits, and global food security. Our solution, the Agri-nauts app, addresses these challenges by leveraging Earth observation data and AI to provide informed agricultural decision-making tools.

## Key Features

1. **Weather and Environmental Predictions**
   - Soil moisture forecasting
   - Drought stage predictions
   - Air quality forecasts
   - Flood prediction model

2. **Plant Disease Detection**
   - Uses computer vision with 92% accuracy
   - Identifies plant diseases through smartphone camera
   - Suggests appropriate treatments

3. **AI-Powered Chatbot**
   - Provides quick solutions to common agricultural problems

4. **Community Hub**
   - Allows users to share experiences and problems
   - Features a Scientific Lab section with latest research and agricultural solutions

5. **Integrated Marketplace**
   - Enables users to buy and sell agricultural products, including fertilizers, pesticides, and equipment

## Technology Stack

- **Mobile App Development**: Flutter (Dart)
- **Backend**: Flask (python)
- **ML/Data**: Machine Learning, Deep Learning algorithms (RNN-LSTM), Computer Vision
  
## Data Source

1. [U.S. Drought Monitor](https://droughtmonitor.unl.edu/DmData/DataDownload/ComprehensiveStatistics.aspx)
2. [NASA Earthdata Search](https://search.earthdata.nasa.gov/search/granules?p=C2531308461-NSIDC_ECS&pg[0][v]=f&pg[0][gsk]=-start_date&q=smap%20l4&tl=1728093676.543!3!!)
3. [ORNL DAAC for Biogeochemical Dynamics](https://daac.ornl.gov/cgi-bin/theme_dataset_lister.pl?theme_id=3)
4. [MODIS Web Service](https://modis.ornl.gov/data/modis_webservice.html)
5. [NASA POWER](https://power.larc.nasa.gov/data-access-viewer/)
6. [Google Earth Engine](https://code.earthengine.google.com/bf6837445a46bdb5af73592f9e99aa23?noload=1)
7. [NASA Air Quality Data Pathfinder](https://www.earthdata.nasa.gov/learn/pathfinders/air-quality-data-pathfinder)
8. [NASA-USDA SMAP Global Soil Moisture Data](https://developers.google.com/earth-engine/datasets/catalog/NASA_USDA_HSL_SMAP10KM_soil_moisture)
9. [SERVIR's ClimateSERV](https://climateserv.servirglobal.net/help)
10. [NASA Earthdata Agricultural and Water Resources Data Pathfinder](https://www.earthdata.nasa.gov/learn/pathfinders/agricultural-and-water-resources-data-pathfinder/find-data#water)
11. [AppEEARS](https://appeears.earthdatacloud.nasa.gov/products)
12. [NASA Earthdata Dashboard](https://www.earthdata.nasa.gov/dashboard/exploration?datasets=%5B%5D&taxonomy=%7B%22Topics%22%3A%5B%22agriculture%22%5D%7D&search=)
13. [NASA Earthdata Soil Moisture Dashboard](https://www.earthdata.nasa.gov/dashboard/exploration?datasets=%5B%7B%22id%22%3A%22SoilMoi00_10cm_tavg%22%2C%22settings%22%3A%7B%22isVisible%22%3Atrue%2C%22opacity%22%3A100%2C%22analysisMetrics%22%3A%5B%7B%22id%22%3A%22mean%22%2C%22label%22%3A%22Average%22%2C%22chartLabel%22%3A%22Average%22%2C%22themeColor%22%3A%22infographicB%22%7D%2C%7B%22id%22%3A%22std%22%2C%22label%22%3A%22St+Deviation%22%2C%22chartLabel%22%3A%22St+Deviation%22%2C%22themeColor%22%3A%22infographicD%22%7D%5D%7D%7D%5D&taxonomy=%7B%7D&search=&date=2023-06-30T21%3A00%3A00.000Z)
14. [NASS Crop Condition and Soil Moisture Analytics (Crop-CASMA)](https://nassgeo.csiss.gmu.edu/CropCASMA/)
    
## Prerequisites

To ensure that the code runs smoothly, the following Python libraries and packages should be installed. Below is a list of required libraries along with instructions on how to install them.

## Required Libraries

1. **time** - A built-in Python library for time-related functions.
2. **pickle** - A built-in Python library for serializing and deserializing Python objects.
3. **numpy** - A fundamental package for scientific computing with Python.
4. **pandas** - A library for data manipulation and analysis.
5. **matplotlib** - A plotting library for creating static, animated, and interactive visualizations.
6. **seaborn** - A Python data visualization library based on `matplotlib`.
7. **plotly.express** - A high-level interface to Plotly for creating figures.
8. **statsmodels** - A module that provides tools for estimating and testing statistical models.
   - `arima` - For ARIMA modeling.
   - `seasonal_decompose` - For time series decomposition.
   - `plot_acf`, `plot_pacf` - For autocorrelation and partial autocorrelation plots.
9. **sklearn (scikit-learn)** - A machine learning library for Python, especially for metrics like `mean_squared_error` and `mean_absolute_error`.
9. **scikit-learn (sklearn)** - A machine learning library for Python, especially for metrics like `mean_squared_error` and `mean_absolute_error`.
10. **opencv (cv2)** - An open-source computer vision library.
11. **PIL (Pillow)** - A Python Imaging Library for opening, manipulating, and saving images.
12. **joblib** - A library for efficient serialization and parallel computing.
13. **rasterio** - A library for reading and writing geospatial raster data.
14. **datetime** - A built-in Python library for manipulating dates and times.

### Installation

You can install these libraries using `pip`. Run the following commands in your terminal or command prompt:

```bash
pip install numpy pandas matplotlib seaborn plotly statsmodels scikit-learn opencv-python pillow joblib rasterio
```


## App Screenshots

<table>
  <tr>
    <td><img src="assets/screenshots/home_screen.jpg" alt="Home Screen" width="300"/></td>
    <td><img src="assets/screenshots/add_friend.jpg" alt="Add Friend" width="300"/></td>
  </tr>
  <tr>
    <td>Home Screen</td>
    <td>Add Friend</td>
  </tr>
  <tr>
    <td><img src="assets/screenshots/chat_bot.jpg" alt="Chat Bot" width="300"/></td>
    <td><img src="assets/screenshots/plant_disease_detection.jpg" alt="Plant Disease Detection" width="300"/></td>
  </tr>
  <tr>
    <td>Chat Bot</td>
    <td>Plant Disease Detection</td>
  </tr>
  <tr>
    <td><img src="assets/screenshots/explore_your_map.jpg" alt="Explore The Map" width="300"/></td>
    <td><img src="assets/screenshots/Drought.jpg" alt="Drought Forecasting" width="300"/></td>
    <td></td>
  </tr>
   <tr>
    <td>Explore The Map</td>
    <td>Drought Forecasting</td>
  </tr>
  <tr>
    <td><img src="assets/screenshots/soil_moisture.jpg" alt="Soil Moisture Predction" width="300"/></td>
    <td><img src="assets/screenshots/air-quality.jpg" alt="Air Quality Predction" width="300"/></td>
    <td></td>
  </tr>
  <tr>
    <td>Soil Moisture Predction</td>
    <td>Air Quality Predction</td>
  </tr>
</table>

## Future Enhancements

- Integration of additional data sources
- Improvement of AI models for more accurate predictions
- Expansion of plant disease detection capabilities
- User interface enhancements based on farmer feedback

## Our Team

Our diverse team consists of 6 talented individuals. For more information about our team, please see our [Team Members](assets/our_team.md) page.

## Acknowledgments

- NASA Space Apps Challenge for the opportunity
- NASA EARTH DATA for providing crucial Earth observation data

## Feedback and Support

We value your feedback! If you have any questions, suggestions, or encounter any issues while using the Agri-nauts application, please don't hesitate to reach out to us [Team Members](assets/our_team.md). Your input is crucial in helping us improve the app and provide a better experience for farmers and agricultural professionals worldwide.

Thank you for joining us on this important mission to leverage space technology for sustainable agriculture and global food security. Together, we can make a real difference in how we manage our planet's precious resources!
