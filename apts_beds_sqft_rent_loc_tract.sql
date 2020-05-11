SELECT COUNT(*) AS apts_listing_count, 
       COUNT(CASE WHEN f.clean_beds = 0 THEN 1 END) AS apts_listing_count_0b, 
       COUNT(CASE WHEN f.clean_beds = 1 THEN 1 END) AS apts_listing_count_1b, 
       COUNT(CASE WHEN f.clean_beds = 2 THEN 1 END) AS apts_listing_count_2b, 
       COUNT(CASE WHEN f.clean_beds = 3 THEN 1 END) AS apts_listing_count_3b, 
       COUNT(CASE WHEN f.clean_beds >= 4 THEN 1 END) AS apts_listing_count_4bplus, 
	   
	   AVG(f.clean_rent) AS apts_avg_rent, 
       AVG(CASE WHEN f.clean_beds = 0 THEN f.clean_rent END) AS apts_avg_rent_0b,
       AVG(CASE WHEN f.clean_beds = 1 THEN f.clean_rent END) AS apts_avg_rent_1b,
       AVG(CASE WHEN f.clean_beds = 2 THEN f.clean_rent END) AS apts_avg_rent_2b,
       AVG(CASE WHEN f.clean_beds = 3 THEN f.clean_rent END) AS apts_avg_rent_3b,
       AVG(CASE WHEN f.clean_beds >= 4 THEN f.clean_rent END) AS apts_avg_rent_4bplus,
	   
       AVG(f.clean_beds) AS apts_avg_beds,
       AVG(f.clean_sqft) AS apts_avg_sqft,
      
       QUANTILE(f.clean_rent, .05) AS apts_q5_rent, 
       QUANTILE(CASE WHEN f.clean_beds = 0 THEN f.clean_rent END, .05) AS apts_q5_rent_0b,
       QUANTILE(CASE WHEN f.clean_beds = 1 THEN f.clean_rent END, .05) AS apts_q5_rent_1b,
       QUANTILE(CASE WHEN f.clean_beds = 2 THEN f.clean_rent END, .05) AS apts_q5_rent_2b,
       QUANTILE(CASE WHEN f.clean_beds = 3 THEN f.clean_rent END, .05) AS apts_q5_rent_3b,
       QUANTILE(CASE WHEN f.clean_beds >= 4 THEN f.clean_rent END, .05) AS apts_q5_rent_4bplus,
      
       QUANTILE(f.clean_rent, .25) AS apts_q25_rent, 
       QUANTILE(CASE WHEN f.clean_beds = 0 THEN f.clean_rent END, .25) AS apts_q25_rent_0b,
       QUANTILE(CASE WHEN f.clean_beds = 1 THEN f.clean_rent END, .25) AS apts_q25_rent_1b,
       QUANTILE(CASE WHEN f.clean_beds = 2 THEN f.clean_rent END, .25) AS apts_q25_rent_2b,
       QUANTILE(CASE WHEN f.clean_beds = 3 THEN f.clean_rent END, .25) AS apts_q25_rent_3b,
       QUANTILE(CASE WHEN f.clean_beds >= 4 THEN f.clean_rent END, .25) AS apts_q25_rent_4bplus,
      
       QUANTILE(f.clean_rent, .50) AS apts_med_rent, 
       QUANTILE(CASE WHEN f.clean_beds = 0 THEN f.clean_rent END, .50) AS apts_med_rent_0b,
       QUANTILE(CASE WHEN f.clean_beds = 1 THEN f.clean_rent END, .50) AS apts_med_rent_1b,
       QUANTILE(CASE WHEN f.clean_beds = 2 THEN f.clean_rent END, .50) AS apts_med_rent_2b,
       QUANTILE(CASE WHEN f.clean_beds = 3 THEN f.clean_rent END, .50) AS apts_med_rent_3b,
       QUANTILE(CASE WHEN f.clean_beds >= 4 THEN f.clean_rent END, .50) AS apts_med_rent_4bplus,
      
       QUANTILE(f.clean_rent, .75) AS apts_q75_rent,
       QUANTILE(CASE WHEN f.clean_beds = 0 THEN f.clean_rent END, .75) AS apts_q75_rent_0b,
       QUANTILE(CASE WHEN f.clean_beds = 1 THEN f.clean_rent END, .75) AS apts_q75_rent_1b,
       QUANTILE(CASE WHEN f.clean_beds = 2 THEN f.clean_rent END, .75) AS apts_q75_rent_2b,
       QUANTILE(CASE WHEN f.clean_beds = 3 THEN f.clean_rent END, .75) AS apts_q75_rent_3b,
       QUANTILE(CASE WHEN f.clean_beds >= 4 THEN f.clean_rent END, .75) AS apts_q75_rent_4bplus,
      
       QUANTILE(f.clean_rent, .95) AS apts_q95_rent, 
       QUANTILE(CASE WHEN f.clean_beds = 0 THEN f.clean_rent END, .95) AS apts_q95_rent_0b,
       QUANTILE(CASE WHEN f.clean_beds = 1 THEN f.clean_rent END, .95) AS apts_q95_rent_1b,
       QUANTILE(CASE WHEN f.clean_beds = 2 THEN f.clean_rent END, .95) AS apts_q95_rent_2b,
       QUANTILE(CASE WHEN f.clean_beds = 3 THEN f.clean_rent END, .95) AS apts_q95_rent_3b,
       QUANTILE(CASE WHEN f.clean_beds >= 4 THEN f.clean_rent END, .95) AS apts_q95_rent_4bplus,
      
       QUANTILE(f.clean_beds, .50) AS apts_med_beds,
       QUANTILE(f.clean_sqft, .50) AS apts_med_sqft
FROM (
      SELECT DISTINCT ON (e.trt_id, e.met_id, e.clean_beds, e.clean_sqft, e.clean_rent, e.lng, e.lat) 
             e.trt_id, e.met_id, e.clean_beds, e.clean_sqft, e.clean_rent, e.match_type, e.lng, e.lat
      FROM (
            SELECT c.trt_id, c.met_id, d.scraped_time, d.clean_beds, d.clean_sqft, d.clean_rent, d.match_type,
                   ROUND(CAST(ST_X(ST_TRANSFORM(d.geometry, 4326)) as numeric), 3) as lng, 
                   ROUND(CAST(ST_Y(ST_TRANSFORM(d.geometry, 4326)) as numeric), 3) as lat
            FROM (
                  SELECT a.gisjoin AS trt_id, a.geometry, b.cbsafp AS met_id
                  FROM tract17 a
                  JOIN county17 b ON a.statefp = b.statefp AND a.countyfp = b.countyfp
                  WHERE b.cbsafp IS NOT NULL
            ) c
            LEFT JOIN apts_clean d ON ST_Contains(c.geometry, d.geometry) 
            WHERE d.scraped_time BETWEEN '2019-01-01' AND ?end AND
                d.clean_beds IS NOT NULL AND d.clean_rent IS NOT NULL AND
                d.clean_sqft IS NOT NULL
            ORDER BY d.scraped_time DESC
          ) e
     ) f
GROUP BY f.trt_id, f.met_id
ORDER BY f.met_id
