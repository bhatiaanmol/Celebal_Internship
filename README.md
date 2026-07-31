# Celebal Technologies Internship

This repository contains the assignments completed during my internship at Celebal Technologies. 

## Repository Structure

### Assignment-1: Data Exploration and Cleaning using Pandas
- Data exploration
- Handling missing values
- Removing duplicate records
- Data cleaning and preprocessing

**Tools Used:** Python, Pandas, Jupyter Notebook

### Assignment-2: SQL Data Analysis
- Data exploration using SQL
- Filtering and sorting
- Aggregate functions
- Grouping and analysis
- Data validation

**Tools Used:** MySQL, MySQL Workbench

### Assignment-3: SQL Subqueries, CTEs, and Window Functions
- Subqueries for data analysis
- Common Table Expressions (CTEs)
- Window Functions (ROW_NUMBER, DENSE_RANK)
- JOIN operations
- Customer sales analysis and business queries

**Tools Used:** MySQL, MySQL Workbench

### Assignment-4: Azure Cloud Fundamentals and Data Pipeline Implementation
- Created and managed Azure Resource Group
- Configured Azure Storage Account and Blob Containers
- Uploaded and managed source CSV dataset
- Created Azure Data Factory and explored Author, Manage, and Monitor modules
- Configured Linked Services and Source/Destination Datasets
- Retrieved file metadata using Get Metadata activity
- Built an end-to-end data pipeline using Copy Data activity
- Executed and monitored pipeline using Debug and Trigger
- Configured IAM roles (Storage Blob Data Reader & Contributor)
- Implemented metadata validation and verified successful data transfer from Blob Storage to the destination container

**Tools Used:** Microsoft Azure, Azure Storage Account, Azure Blob Storage, Azure Data Factory (ADF)

### Assignment-5: Apache Spark Fundamentals and Data Processing
- Understood the limitations of MapReduce and advantages of Apache Spark
- Worked with Spark DataFrames and explored DataFrame immutability
- Performed data cleaning by removing duplicates and handling null values
- Applied filtering operations using multiple conditions
- Used aggregation functions such as COUNT, SUM, AVG, MIN, and MAX
- Grouped data using `groupBy()` and applied aggregations
- Learned about shuffle operations and wide transformations in Spark
- Modified DataFrame schema by casting data types and renaming columns
- Handled inconsistent and missing data during preprocessing
- Built a complete data processing pipeline combining cleaning, transformation, and aggregation

**Tools Used:** Python, PySpark, Apache Spark, Google Colab

### Assignment-6: Apache Spark Architecture and DataFrame Operations
- Explored Apache Spark Architecture including Driver, Cluster Manager, and Executors
- Understood Lazy Evaluation and the difference between Transformations and Actions
- Read and wrote CSV and Parquet files using Spark DataFrames
- Compared CSV and Parquet file formats for big data processing
- Applied filtering using single and multiple conditions
- Created new columns and modified existing DataFrame schemas
- Learned Predicate Pushdown and its impact on query performance
- Understood Spark fault tolerance using the Lineage Graph (DAG)
- Compared Client Mode and Cluster Mode in Spark
- Performed end-to-end DataFrame operations including reading, filtering, transforming, and writing data

**Tools Used:** Python, PySpark, Apache Spark, Google Colab


### Assignment-7: Delta Lake MERGE Implementation
- Loaded the Superstore dataset into a Spark DataFrame
- Performed data quality checks by validating null values and duplicate records
- Cleaned the dataset and renamed columns for Delta Lake compatibility
- Created and stored the dataset as a Delta table in Databricks
- Simulated incremental data by creating updated and new records
- Performed UPSERT operations using the Delta Lake `MERGE` command
- Validated the MERGE results by verifying updated and inserted records
- Checked the final row count and ensured no duplicate `Row_ID` values
- Demonstrated incremental data processing using Delta Lake

**Tools Used:** Databricks, Apache Spark (PySpark), Delta Lake, Python