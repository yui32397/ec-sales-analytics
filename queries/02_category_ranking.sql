-- ==============================================================================
-- レベル2: カテゴリー別売上ランキングと構成比の抽出クエリ（商品・MD向け画面用）
-- 【ビジネス要求】Looker Studioの横向き棒グラフや円グラフにマウントするため、
--  商品カテゴリーごとの「売上高」「注文数」および「売上構成比（%）」を算出する
-- ==============================================================================

WITH category_summary AS (
    SELECT 
        -- 商品カテゴリー（トップス、ボトムス、アウター、小物など）
        product_category,
        
        -- 各カテゴリーの総売上高と総注文数を集計
        SUM(price_amount) AS category_revenue,
        COUNT(DISTINCT order_id) AS category_orders
    FROM 
        ec_order_logs
    WHERE 
        purchase_timestamp >= '2026-01-01'
    GROUP BY 
        product_category
),
total_summary AS (
    -- 構成比を計算するために、全体の総売上高をサブクエリで1行で取得
    SELECT 
        SUM(price_amount) AS grand_total_revenue 
    FROM 
        ec_order_logs
    WHERE 
        purchase_timestamp >= '2026-01-01'
)
SELECT 
    c.product_category,
    c.category_revenue,
    c.category_orders,
    -- 【構成比KPI】（カテゴリー売上 / 全体売上）× 100 で売上シェア（%）を算出
    ROUND((c.category_revenue * 100.0) / t.grand_total_revenue, 2) AS revenue_share_percentage
FROM 
    category_summary AS c
CROSS JOIN 
    total_summary AS t
ORDER BY 
    c.category_revenue DESC; -- 売上高が高い順（ランキング）にソート
