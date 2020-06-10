SELECT c.gisjoin AS trt_id, c.geometry, c.cbsafp AS met_id, c.intptlon, c.intptlat, c.aland,
       d.name AS place_name, d.namelsad AS place_namelsad, d.pcicbsa AS prin_city
FROM (SELECT a.gisjoin, a.geometry, b.cbsafp, a.intptlon, a.intptlat, a.aland
      FROM tract18 a
      JOIN county18 b ON a.statefp = b.statefp AND a.countyfp = b.countyfp
      WHERE b.cbsafp IS NOT NULL) c
LEFT JOIN place18 d ON st_within(st_centroid(c.geometry), d.geometry)