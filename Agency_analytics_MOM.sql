-- ============================================================================
-- YOUTUBE AGENCY ANALYTICS: CREATOR FINANCES
-- ============================================================================
-- Description: A suite of advanced SQL queries to extract business intelligence
--              from the creator_finances table. Focuses on audience valuation, 
--              sponsor ROI, and month-over-month channel growth.
-- Dialect: PostgreSQL
-- ============================================================================


-- ----------------------------------------------------------------------------
-- MISSION 1: THE AUDIENCE VALUATION (RPM Calculation)
-- ----------------------------------------------------------------------------
-- Business Goal: Identify which geographic audiences generate the highest 
--                Revenue Per Mille (RPM) to guide future content targeting.

SELECT 
    audience_geography,
    SUM(views) AS total_views, 
    SUM(adsense_revenue_usd) AS total_revenue,
    
    -- Calculate RPM: (Revenue / Views) * 1000
    -- Cast Adsense Revenue to NUMERIC to prevent PostgreSQL integer division (which drops decimals)
    (SUM(adsense_revenue_usd)::NUMERIC / SUM(views)) * 1000 AS adsense_rpm
    
FROM creator_finances
GROUP BY audience_geography
ORDER BY adsense_rpm DESC;


-- ----------------------------------------------------------------------------
-- MISSION 2: THE SPONSOR ROI AUDIT (Filtering Grouped Data)
-- ----------------------------------------------------------------------------
-- Business Goal: Identify the highest-paying, recurring brand sponsors to 
--                establish baselines for future rate negotiations.

SELECT 
    sponsor_brand,
    
    -- Calculate the average payout per video and round to the nearest whole dollar
    ROUND(AVG(agency_earnings_usd)) AS avg_earnings_usd
    
FROM creator_finances
GROUP BY sponsor_brand

-- Filter out one-off deals to ensure we are only looking at recurring partners
HAVING COUNT(video_id) > 3 

ORDER BY avg_earnings_usd DESC; 


-- ----------------------------------------------------------------------------
-- MISSION 3: THE VIRAL MOMENTUM TRACKER (Window Functions & Date Math)
-- ----------------------------------------------------------------------------
-- Business Goal: Track month-over-month (MoM) revenue growth to ensure 
--                the agency's channels are not losing momentum.

-- PHASE 1: Pre-aggregate the total revenue by month
WITH monthly_metrics AS (
    SELECT 
        -- Extract the month (1-12) from the publish_date timestamp
        EXTRACT(MONTH FROM publish_date) AS video_month,
        
        -- Sum total revenue and cast to NUMERIC to avoid double precision rounding errors
        ROUND(SUM(total_video_revenue_usd)::NUMERIC) AS current_revenue
        
    FROM creator_finances
    GROUP BY video_month
)

-- PHASE 2: Compare current month to previous month and calculate % growth
SELECT 
    video_month, 
    current_revenue,
    
    -- Use LAG() to fetch the previous month's revenue chronologically
    LAG(current_revenue) OVER (ORDER BY video_month) AS previous_revenue,

    -- Calculate MoM % Growth: ((Current - Previous) / Previous) * 100
    ROUND(
        (
            (current_revenue - LAG(current_revenue) OVER (ORDER BY video_month)) 
            / 
            -- NULLIF prevents a "division by zero" fatal error if previous month revenue was exactly 0
            NULLIF(LAG(current_revenue) OVER (ORDER BY video_month), 0) 
            * 100
        )::NUMERIC
    , 2)::TEXT || '%' AS mom_growth_pct

FROM monthly_metrics;