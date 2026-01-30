This directory contains SQL scripts used to create tables and compute RPP-adjusted real wages.
01_create_tables.sql creates staging and reference tables from raw CSV inputs.
build_state_real_wages.sql joins wage, employment, RPP, and urban share data to compute state-level real wages.
Output is consumed directly by the Power BI dashboard.
