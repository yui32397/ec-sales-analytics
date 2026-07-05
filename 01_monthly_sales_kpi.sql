-- ==============================================================================
# [Portfolio / Unofficial] ec-sales-analytics
-- レベル1: 月次売上高・購買KPIの抽出クエリ（経営陣向け画面用）
-- 【ビジネス要求】Looker Studioの時系列グラフにマウントするため、
--  月別の「総売上高」「総注文数」「平均客単価」「リピート率」を自動算出する
-- ==============================================================================

WITH monthly_summary AS (
    SELECT 
        -- 購入日時から「年月（YYYY-MM）」を抽出してグループ化のキーにする
        DATE_FORMAT(purchase_timestamp, '%Y-%m') AS purchase_month,
        
        -- 【売上高KPI】期間内の総売上高を合算（円単位）
        SUM(price_amount) AS total_revenue,
        
        -- 【客数KPI】ユニークな注文数をカウント（重複排除）
        COUNT(DISTINCT order_id) AS total_orders,
        
        -- 【客単価KPI】総売上高 / 総注文数 で1回あたりの平均客単価を算出
        ROUND(SUM(price_amount) / COUNT(DISTINCT order_id), 0) AS average_order_value,
        
        -- 【リピート分析】過去に購入履歴がある既存客（is_repeater = 1）の注文数をカウント
        COUNT(DISTINCT CASE WHEN is_repeater = 1 THEN order_id END) AS repeat_orders
    FROM 
        ec_order_logs
    WHERE 
        -- 2026年度のデータを対象にファクトチェック
        purchase_timestamp >= '2026-01-01'
    GROUP BY 
        1
)
SELECT 
    purchase_month,
    total_revenue,
    total_orders,
    average_order_value,
    -- 【リピート率KPI】既存客の注文数 / 全体の注文数 でリピート率（%）を計算
    ROUND((repeat_orders * 100.0) / total_orders, 2) AS repeat_rate_percentage
FROM 
    monthly_summary
ORDER BY 
    purchase_month ASC;
