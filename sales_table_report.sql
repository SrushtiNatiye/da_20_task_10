
---------------------------Task_10------------------------

------------------------Reports of sales--------------------- 

select * from sales

CREATE TABLE sales_monthly_report (
    report_month DATE,
    total_sales NUMERIC(12,2),
    total_qty INT,
    total_discount NUMERIC(12,2),
    total_profit NUMERIC(12,2)
);
ALTER TABLE sales_monthly_report
ADD CONSTRAINT uq_report_month UNIQUE (report_month);

CREATE OR REPLACE PROCEDURE insert_sales_monthly_report()
LANGUAGE plpgsql
AS $$
BEGIN
    TRUNCATE TABLE sales_monthly_report;

    INSERT INTO sales_monthly_report (report_month, total_sales, total_qty, total_discount, total_profit)
    SELECT
        DATE_TRUNC('month', order_date)::DATE AS report_month,
        SUM(sales) AS total_sales,
        SUM(qty) AS total_qty,
        SUM(discount) AS total_discount,
        SUM(profit) AS total_profit
    FROM sales
    GROUP BY DATE_TRUNC('month', order_date)::DATE;
END;
$$;

CALL insert_sales_monthly_report();

select * from sales_monthly_report


------------------Report for yearly sales---------------------------------------------------------------


CREATE TABLE sales_yearly_report (
    report_year INT,
    total_sales NUMERIC(12,2),
    total_qty INT,
    total_discount NUMERIC(12,2),
    total_profit NUMERIC(12,2),
    PRIMARY KEY (report_year)
);

CREATE OR REPLACE PROCEDURE insert_sales_yearly_report()
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO sales_yearly_report (report_year, total_sales, total_qty, total_discount, total_profit)
    SELECT
        EXTRACT(YEAR FROM order_date)::INT AS report_year,
        SUM(sales) AS total_sales,
        SUM(qty) AS total_qty,
        SUM(discount) AS total_discount,
        SUM(profit) AS total_profit
    FROM sales
    GROUP BY EXTRACT(YEAR FROM order_date)
    ON CONFLICT (report_year) DO UPDATE
    SET
        total_sales = EXCLUDED.total_sales,
        total_qty = EXCLUDED.total_qty,
        total_discount = EXCLUDED.total_discount,
        total_profit = EXCLUDED.total_profit;
END;
$$;

CALL insert_sales_yearly_report();

select * from sales_yearly_report

select * from sales_yearly_report where
total_discount > 500

--------------------report for monthly profit generated---------------------


CREATE TABLE sales_monthly_profit_report (
    report_month DATE PRIMARY KEY,
    total_profit NUMERIC(12,2)
);

CREATE OR REPLACE PROCEDURE insert_sales_monthly_profit_report()
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO sales_monthly_profit_report (report_month, total_profit)
    SELECT
        DATE_TRUNC('month', order_date)::DATE AS report_month,
        SUM(profit) AS total_profit
    FROM sales
    GROUP BY DATE_TRUNC('month', order_date)
    ON CONFLICT (report_month) DO UPDATE
    SET total_profit = EXCLUDED.total_profit;
END;
$$;


CALL insert_sales_monthly_profit_report();

select * from sales_monthly_profit_report



------------------Report for monthly qty sold---------------------------------

CREATE TABLE sales_monthly_qty_report (
    report_month DATE PRIMARY KEY,
    total_qty BIGINT
);

CREATE OR REPLACE PROCEDURE insert_sales_monthly_qty_report()
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO sales_monthly_qty_report (report_month, total_qty)
    SELECT
        DATE_TRUNC('month', order_date)::DATE AS report_month,
        SUM(qty) AS total_qty
    FROM sales
    GROUP BY DATE_TRUNC('month', order_date)
    ON CONFLICT (report_month) DO UPDATE
    SET total_qty = EXCLUDED.total_qty;
END;
$$;

CALL insert_sales_monthly_qty_report();

select * from sales_monthly_qty_report;

