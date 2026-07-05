-- ==============================================================================
-- レベル3: 顧客属性（年代×性別）および地域別売上の抽出クエリ（マーケター向け画面用）
-- 【ビジネス要求】Looker Studioの積み上げ棒グラフや日本地図（ジオチャート）にマウントするため、
--  購入者の「年代」「性別」「都道府県」ごとの売上高とユニーク会員数を抽出する
-- ==============================================================================

SELECT 
    -- 会員マスターから年代と性別を、購買ログから都道府県を抽出
    usr.age_group,
    usr.gender,
    log.delivery_prefecture,
    
    -- 【属性別売上KPI】セグメントごとの総売上高を計算
    SUM(log.price_amount) AS revenue_by_segment,
    
    -- 【属性別客数KPI】セグメントごとのユニークな購入会員数をカウント
    COUNT(DISTINCT log.user_id) AS unique_customers
FROM 
    ec_order_logs AS log
-- 【データのがっちゃんこ】購買ログに会員マスターを左結合（LEFT JOIN）
LEFT JOIN 
    ec_user_master AS usr
ON 
    log.user_id = usr.user_id
WHERE 
    log.purchase_timestamp >= '2026-01-01'
GROUP BY 
    usr.age_group,
    usr.gender,
    log.delivery_prefecture
ORDER BY 
    revenue_by_segment DESC; -- 売上の高いセグメント順にソート
