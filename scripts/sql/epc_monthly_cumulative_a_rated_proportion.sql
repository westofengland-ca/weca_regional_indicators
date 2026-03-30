-- Monthly cumulative proportion of all properties with CURRENT_ENERGY_RATING A or A+
-- Uses the latest EPC per property (BUILDING_REFERENCE_NUMBER) as of each month
-- Requires: LOAD spatial;

WITH certs AS (
    SELECT
        BUILDING_REFERENCE_NUMBER AS prop_id,
        CURRENT_ENERGY_RATING,
        DATE_TRUNC('month', LODGEMENT_DATETIME)::DATE AS lodge_month,
        LEAD(DATE_TRUNC('month', LODGEMENT_DATETIME)::DATE) OVER (
            PARTITION BY BUILDING_REFERENCE_NUMBER ORDER BY LODGEMENT_DATETIME
        ) AS next_lodge_month
    FROM epc_domestic_lep_ods_vw
    WHERE BUILDING_REFERENCE_NUMBER IS NOT NULL
),
months AS (
    SELECT UNNEST(generate_series(DATE '2020-01-01', DATE '2026-02-01', INTERVAL 1 MONTH))::DATE AS month
)
SELECT
    m.month,
    COUNT(*) AS total_properties,
    COUNT(*) FILTER (c.CURRENT_ENERGY_RATING IN ('A', 'A+')) AS a_or_aplus,
    ROUND(100.0 * COUNT(*) FILTER (c.CURRENT_ENERGY_RATING IN ('A', 'A+')) / COUNT(*), 2) AS pct_a_or_aplus
FROM months m
JOIN certs c
    ON m.month >= c.lodge_month
    AND (c.next_lodge_month IS NULL OR m.month < c.next_lodge_month)
GROUP BY m.month
ORDER BY m.month;
