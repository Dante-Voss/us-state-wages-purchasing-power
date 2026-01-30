U.S. State Wages and Purchasing Power Dashboard

This project analyzes U.S. state-level wages by adjusting nominal salaries for regional price parity (RPP) to estimate real purchasing power. The goal is to show how cost of living changes the interpretation of high nominal wages across states.

Multiple public datasets are combined using SQL to compute RPP-adjusted real wages and employment per 1,000 jobs. The results are visualized in an interactive Power BI dashboard that allows comparison across states and occupations.

Project structure
- data/ contains raw source datasets used in the analysis
- sql/ contains scripts used to create tables and compute real wages
- powerbi/ contains the Power BI dashboard file and a static screenshot

The final outputs are consumed directly in the Power BI dashboard rather than stored as a separate final CSV.
