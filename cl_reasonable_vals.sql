SELECT QUANTILE(f.clean_rent, .998) AS upper_rent_limit,
	   QUANTILE(f.clean_rent, .002) AS lower_rent_limit,
	   QUANTILE(f.clean_sqft, .998) AS upper_sqft_limit,
	   QUANTILE(f.clean_sqft, .002) AS lower_sqft_limit,
	   QUANTILE(f.clean_rent/f.clean_sqft, .998) AS upper_rent_per_sqft_limit,
	   QUANTILE(f.clean_rent/f.clean_sqft, .002) AS lower_rent_per_sqft_limit
FROM (
      SELECT DISTINCT ON (e.post_id) 
             e.clean_beds, e.clean_sqft, e.clean_rent, e.match_type, e.post_id, e.lng, e.lat
      FROM (
            SELECT c.trt_id, c.met_id, d.listing_date, d.clean_beds, d.clean_sqft, d.clean_rent, d.match_type, d.post_id,
                   ROUND(CAST(ST_X(ST_TRANSFORM(d.geometry, 4326)) as numeric), 3) as lng, 
                   ROUND(CAST(ST_Y(ST_TRANSFORM(d.geometry, 4326)) as numeric), 3) as lat
            FROM (
                  SELECT a.gisjoin AS trt_id, a.geometry, b.cbsafp AS met_id
                  FROM tract18 a
                  JOIN county18 b ON a.statefp = b.statefp AND a.countyfp = b.countyfp
                  WHERE b.cbsafp IS NOT NULL
            ) c
            LEFT JOIN clean d ON ST_Contains(c.geometry, d.geometry) 
            WHERE d.listing_date BETWEEN '2019-01-01' AND ?end  AND
			      d.match_type NOT IN ('No Address Found') AND
                  d.clean_beds IS NOT NULL AND d.clean_rent IS NOT NULL AND
                  d.clean_sqft IS NOT NULL
            ORDER BY d.listing_date DESC
           ) e
     ) f