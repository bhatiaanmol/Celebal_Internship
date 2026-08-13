# Ride-Sharing Analytics & Driver Performance Pipeline

## Project Overview

This project implements an end-to-end **data engineering pipeline** for analyzing ride-sharing operations and driver performance using **PySpark** and a **Medallion Architecture** consisting of Bronze, Silver, and Gold layers.

The pipeline processes driver details, trip information, and trip logs to generate cleaned analytical data and business-level KPIs such as driver performance, cancellation rates, delay analysis, high-demand pickup locations, revenue insights, and driver rankings.

## Architecture

The project follows the Medallion Architecture:

### Bronze Layer

The Bronze layer stores the raw datasets without applying business transformations.

Datasets:

* `drivers.csv`
* `trips.csv`
* `trip_logs.csv`

The CSV files are read using PySpark DataFrames and stored in **Parquet format**.

### Silver Layer

The Silver layer creates a cleaned and enriched trip-level dataset.

Processing includes:

* Joining drivers, trips, and trip logs
* Handling null values
* Removing invalid records
* Validating distance, fare, and timestamp values
* Checking duplicate trip records
* Creating derived columns

Derived columns:

* `trip_duration_minutes`
* `completion_flag`
* `cancelled_flag`
* `revenue_per_km`
* `is_delayed`

The processed Silver dataset is stored in Parquet format.

### Gold Layer

The Gold layer generates aggregated analytical datasets and business KPIs.

Gold datasets include:

#### Driver Performance

Provides driver-level metrics such as:

* Total trips
* Completed trips
* Cancelled trips
* Completion rate
* Cancellation rate
* Average delay
* Total fare amount
* Average revenue per kilometre

#### Pickup Demand Analysis

Identifies high-demand pickup locations using:

* Total rides
* Completed rides
* Cancelled rides
* Revenue generated

#### Revenue Analysis

Provides city-level revenue insights including:

* Total revenue
* Average fare
* Average revenue per kilometre
* Total trips

#### Delay Analysis

Evaluates driver delays using:

* Average delay
* Number of delayed trips
* Total trips
* Delay rate

#### Driver Ranking

Drivers are ranked using a PySpark **Window Function** based on:

1. Completion rate
2. Revenue
3. Driver rating

`dense_rank()` is used to generate driver rankings.

## Data Validation

Data quality checks are performed before generating the final analytical outputs.

Validation includes:

* Checking invalid or negative distances
* Checking negative fare values
* Checking missing start timestamps
* Checking duplicate trip IDs
* Validating trip status against cancellation flags
* Comparing record counts across pipeline layers

## Spark Optimization

The project applies basic Spark optimization techniques.

### Caching

The Silver DataFrame is cached because it is reused across multiple Gold-layer aggregations.

### Broadcast Join

The smaller driver dataset can be broadcast during joins to reduce shuffle operations and improve processing efficiency.

### Parquet Storage

Bronze, Silver, and Gold datasets are stored using Parquet for efficient columnar storage and Spark processing.

## Technology Stack

* Python
* PySpark
* Apache Spark
* Google Colab
* Google Drive
* Parquet
* Medallion Architecture

## Project Structure

```text
Ride-Sharing-Driver-Performance-Pipeline/
│
├── Ride_Sharing_Analytics_Driver_Performance_Pipeline.ipynb
├── README.md
└── requirements.txt
```

The working datasets are stored in Google Drive using the following structure:

```text
Ride_Sharing_Project/
│
├── Raw_Data/
│   ├── drivers.csv
│   ├── trips.csv
│   └── trip_logs.csv
│
├── Bronze_Data/
├── Silver_Data/
└── Gold_Data/
```

## Pipeline Flow

```text
Raw CSV Files
      ↓
Bronze Layer
Raw Data Storage
      ↓
Silver Layer
Cleaning + Validation + Joins + Enrichment
      ↓
Gold Layer
Aggregations + KPIs + Analytics + Rankings
```

## How to Run

1. Open the project notebook in Google Colab.
2. Mount Google Drive.
3. Place the raw datasets inside:

```text
MyDrive/Ride_Sharing_Project/Raw_Data/
```

4. Install the required Python dependency:

```bash
pip install pyspark
```

5. Run the notebook cells sequentially.
6. The pipeline will generate Bronze, Silver, and Gold datasets inside Google Drive.

## Key Outcomes

The completed pipeline enables analysis of:

* Driver performance
* Trip completion and cancellation behaviour
* Driver delays
* High-demand pickup locations
* Revenue generation
* Driver efficiency
* Driver rankings

The project demonstrates how PySpark and Medallion Architecture can transform raw ride-sharing operational data into structured and actionable business insights.
