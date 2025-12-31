-- =========================================================================================
-- Databricks ELT Pipeline Builder - Application Setup Script
-- Description: This script creates the necessary database schemas, tables, and sample data
--              required to run the Pipeline Builder application and its demo scenarios.
-- =========================================================================================

-- ==========================================
-- PART 1: APPLICATION METADATA SCHEMA
-- Stores configuration, pipelines, and state
-- ==========================================

CREATE SCHEMA IF NOT EXISTS pipeline_builder_app;

-- 1.1 Connections Table
-- Stores connection details for Sources and Targets
CREATE TABLE IF NOT EXISTS pipeline_builder_app.connections (
    connection_id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    type VARCHAR(50) NOT NULL, -- e.g., 'Databricks', 'Snowflake', 'S3'
    category VARCHAR(20) NOT NULL, -- 'SOURCE', 'TARGET', 'LAKE', 'COMPUTE'
    icon VARCHAR(50), -- FontAwesome class
    properties JSON, -- Flexible storage for connection-specific props (host, port, etc.)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 1.2 Pipelines Table
-- Stores the defined ETL pipelines
CREATE TABLE IF NOT EXISTS pipeline_builder_app.pipelines (
    pipeline_id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    source_connection_id VARCHAR(50) REFERENCES pipeline_builder_app.connections(connection_id),
    target_connection_id VARCHAR(50) REFERENCES pipeline_builder_app.connections(connection_id),
    schedule_interval VARCHAR(50), -- e.g., '0 0 * * *' (Cron)
    status VARCHAR(20) DEFAULT 'DRAFT', -- DRAFT, ACTIVE, PAUSED
    configuration JSON, -- Full JSON configuration of the mapping/transformations
    created_by VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 1.3 Execution Logs
-- Stores history of pipeline runs
CREATE TABLE IF NOT EXISTS pipeline_builder_app.execution_logs (
    log_id VARCHAR(50) PRIMARY KEY,
    pipeline_id VARCHAR(50) REFERENCES pipeline_builder_app.pipelines(pipeline_id),
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP,
    status VARCHAR(20), -- RUNNING, SUCCESS, FAILED
    records_processed INT DEFAULT 0,
    error_message TEXT,
    execution_metadata JSON -- Store detailed metrics
);

-- ==========================================
-- PART 2: SOURCE DATA SIMULATION (Mock DW)
-- Simulates the source database (e.g., 'main.dw')
-- ==========================================

CREATE SCHEMA IF NOT EXISTS source_dw;

-- 2.1 Customers Table
CREATE TABLE IF NOT EXISTS source_dw.customers (
    id INT PRIMARY KEY,
    full_name VARCHAR(100),
    email VARCHAR(100),
    country VARCHAR(50),
    segment VARCHAR(50),
    created_at TIMESTAMP
);

-- 2.2 Sales Orders Table
CREATE TABLE IF NOT EXISTS source_dw.sales_orders (
    order_id INT PRIMARY KEY,
    customer_id INT REFERENCES source_dw.customers(id),
    order_date TIMESTAMP,
    status VARCHAR(20),
    total_amount DECIMAL(10, 2),
    currency VARCHAR(3) DEFAULT 'USD'
);

-- 2.3 Products Table
CREATE TABLE IF NOT EXISTS source_dw.products (
    product_id INT PRIMARY KEY,
    name VARCHAR(200),
    category VARCHAR(50),
    unit_price DECIMAL(10, 2),
    in_stock BOOLEAN DEFAULT TRUE
);

-- ==========================================
-- PART 3: TARGET DATA SCHEMA (Databricks)
-- Simulates the destination schemas (e.g., 'main.dm')
-- ==========================================

CREATE SCHEMA IF NOT EXISTS target_dl_staging;
CREATE SCHEMA IF NOT EXISTS target_dl_mart;

-- 3.1 Staging Table (Raw)
CREATE TABLE IF NOT EXISTS target_dl_staging.raw_sales_ingest (
    ingest_id VARCHAR(50) PRIMARY KEY,
    payload JSON,
    ingested_at TIMESTAMP
);

-- 3.2 Data Mart: Monthly Sales Summary
CREATE TABLE IF NOT EXISTS target_dl_mart.report_monthly_sales (
    month_year VARCHAR(7) PRIMARY KEY, -- '2023-01'
    total_revenue DECIMAL(15, 2),
    order_count INT,
    unique_customers INT,
    last_refreshed TIMESTAMP
);

-- ==========================================
-- PART 4: SAMPLE DATA INSERTION
-- Populate tables with dummy data for Testing
-- ==========================================

-- 4.1 Seed Customers
INSERT INTO source_dw.customers (id, full_name, email, country, segment, created_at) VALUES
(101, 'Alice Johnson', 'alice@example.com', 'USA', 'Enterprise', '2023-01-15 08:30:00'),
(102, 'Bob Kumar', 'bob.k@example.com', 'India', 'SMB', '2023-02-10 14:20:00'),
(103, 'Charlie Dave', 'charlie@example.com', 'UK', 'Consumer', '2023-03-05 09:15:00');

-- 4.2 Seed Products
INSERT INTO source_dw.products (product_id, name, category, unit_price) VALUES
(1, 'Databricks Units (DBU)', 'Compute', 0.40),
(2, 'Cloud Storage TB', 'Storage', 20.00),
(3, 'Elite Support Plan', 'Service', 1000.00);

-- 4.3 Seed Orders
INSERT INTO source_dw.sales_orders (order_id, customer_id, order_date, status, total_amount) VALUES
(5001, 101, '2023-06-01 10:00:00', 'COMPLETED', 5000.00),
(5002, 101, '2023-06-05 11:30:00', 'COMPLETED', 2500.50),
(5003, 102, '2023-06-02 09:45:00', 'PENDING', 120.00),
(5004, 103, '2023-06-10 16:20:00', 'COMPLETED', 99.99);

-- 4.4 Seed Connections Metadata (App State)
INSERT INTO pipeline_builder_app.connections (connection_id, name, type, category, icon, properties) VALUES
('conn_001', 'Production DW (Snowflake)', 'Snowflake', 'SOURCE', 'far fa-snowflake', '{"warehouse": "COMPUTE_WH", "db": "MAIN"}'),
('conn_002', 'Marketing Data Lake (S3)', 'Amazon S3', 'LAKE', 'fab fa-aws', '{"bucket": "marketing-data-raw", "region": "us-east-1"}'),
('conn_003', 'Databricks Unity Catalog', 'Databricks', 'TARGET', 'fas fa-layer-group', '{"catalog": "main"}');
