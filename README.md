# Energy-Consumption-Analysis---MySql


### 📘 Project Overview
This project builds a **relational SQL database (`energydb9`)** to analyze global **energy production, consumption, emissions, GDP, and population trends**.  
It provides insights into how countries’ energy usage relates to their economic performance and environmental impact.

The project is designed to support **data-driven decision-making** for sustainability, energy policy, and economic forecasting.

---

### 🧱 Database Structure
The project creates **six interrelated tables** with proper **foreign key relationships** to ensure referential integrity.

| Table Name      | Description |
|-----------------|--------------|
| `COUNTRY_3`     | Master table containing country names and unique IDs |
| `emission_3`    | Records annual energy emissions by country and energy type |
| `consum_3`      | Stores yearly energy consumption data by country |
| `production_3`  | Tracks annual energy production by country |
| `gdp_3`         | Contains GDP (economic output) data for each country and year |
| `population_3`  | Stores population figures per country and year |


---

### 🧱 Database Design
The database has six connected tables:

- **COUNTRY_3** – Country master table  
- **emission_3** – Energy emissions data  
- **consum_3** – Energy consumption data  
- **production_3** – Energy production data  
- **gdp_3** – GDP by country and year  
- **population_3** – Population by country and year  

All tables are linked through **foreign keys** referencing `COUNTRY_3`.

---



### 📊 Sample Analyses
- Total emissions by country  
- Top 5 countries by GDP  
- Energy production vs. consumption  
- Emission-to-GDP ratio  
- Population impact on emissions  
- Year-over-year energy trends  


---
