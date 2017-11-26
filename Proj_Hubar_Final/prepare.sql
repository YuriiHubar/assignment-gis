CREATE SEQUENCE supp_osm_id;

-- point	level
-------------------
-- actual	level0
-- 50m	level1
-- 100m	level2
-- 200m	level3

-- add actual points
INSERT INTO planet_support_point (osm_id, way, level)
(SELECT nextval('supp_osm_id'), way, 0 FROM planet_osm_point);

-- add level1 points
-- level2, level3 same way, but step = 100, 200 and level = 2, 3
DO 
$$
DECLARE
  x_min NUMERIC = 1889932.39;
  x_max NUMERIC = 1918891.80;
  y_min NUMERIC = 6123381.61;
  y_max NUMERIC = 6144368.78;
  step NUMERIC = 50;
  x_steps NUMERIC = (x_max-x_min)/step;
  y_steps NUMERIC = (y_max-y_min)/step;
BEGIN 
  FOR x IN 0..x_steps LOOP
    FOR y IN 0..y_steps LOOP
      INSERT INTO planet_support_point
      VALUES (nextval('supp_osm_id'), st_setsrid(st_makepoint(x_min + x * step, y_min + y * step), 900913), 1);
    END LOOP;
  END LOOP;
END $$;

-- set distances to nearest objects

-- food
WITH distanses AS (
  SELECT DISTINCT ON (s.osm_id) s.osm_id id, ST_distance(s.way, p.way) dist 
  FROM planet_support_point s
  JOIN planet_osm_point p
    ON st_dwithin(s.way, p.way, 2000)
  WHERE p.amenity in ('restaurant', 'fast_food', 'bar', 'pub', 'cafe')
  ORDER BY s.osm_id, dist
)
UPDATE planet_support_point s
SET dist_food = d.dist
from distanses d
WHERE d.id = s.osm_id;

-- supermarket
WITH distanses AS (
  SELECT DISTINCT ON (s.osm_id) s.osm_id id, ST_distance(s.way, p.way) dist 
  FROM planet_support_point s
  JOIN planet_osm_point p
    ON st_dwithin(s.way, p.way, 2000)
  WHERE p.shop = 'supermarket'
  ORDER BY s.osm_id, dist
)
UPDATE planet_support_point s
SET dist_supermarket = d.dist
from distanses d
WHERE d.id = s.osm_id;

-- pharmacy
WITH distanses AS (
  SELECT DISTINCT ON (s.osm_id) s.osm_id id, ST_distance(s.way, p.way) dist 
  FROM planet_support_point s
  JOIN planet_osm_point p
    ON st_dwithin(s.way, p.way, 2000)
  WHERE p.amenity = 'pharmacy'
  ORDER BY s.osm_id, dist
)
UPDATE planet_support_point s
SET dist_pharmacy = d.dist
from distanses d
WHERE d.id = s.osm_id;

-- bank
WITH distanses AS (
  SELECT DISTINCT ON (s.osm_id) s.osm_id id, ST_distance(s.way, p.way) dist 
  FROM planet_support_point s
  JOIN planet_osm_point p
    ON st_dwithin(s.way, p.way, 2000)
  WHERE p.amenity = 'bank'
  ORDER BY s.osm_id, dist
)
UPDATE planet_support_point s
SET dist_bank = d.dist
from distanses d
WHERE d.id = s.osm_id;

-- Bus stops 
WITH distanses AS (
  SELECT DISTINCT ON (s.osm_id) s.osm_id id, ST_distance(s.way, p.way) dist 
  FROM planet_support_point s
  JOIN planet_osm_point p
    ON st_dwithin(s.way, p.way, 2000)
  WHERE p.public_transport = 'stop_position'
  ORDER BY s.osm_id, dist
)
UPDATE planet_support_point s
SET dist_public_transport = d.dist
from distanses d
WHERE d.id = s.osm_id;

-- table planet_support_point now has all semi-analyzed points (with distances to nearest objects of needed types, but witout ratings)
-- now we can compute ratings of each point by distances, weigts and sensivity factor.
-- skeleton of script:
/*
WITH candidates as (
  SELECT DISTINCT ON (way) *
  FROM planet_support_point
  WHERE st_dwithin(st_makepoint('{0}', '{1}')::geography, st_transform(way, 4326), {2})
  AND dist_supermarket is not null
  AND dist_pharmacy is not null
  AND dist_bank is not null
  AND dist_public_transport is not null
)
SELECT c.osm_id, st_asgeojson(st_transform(c.way, 4326)),
round(cast(st_x(st_transform(way, 4236))as numeric), 5) || ', ' || round(cast(st_y(st_transform(way, 4236))as numeric), 5), 
round (1000 * {6}/(dist_food + {4}) + 
1000 * {7}/(dist_supermarket + {4}) + 
1000 * {8}/(dist_pharmacy + {4}) + 
1000 * {9}/(dist_bank + {4}) + 
1000 * {10}/(dist_public_transport + {4}), 4) points
FROM candidates c
WHERE 
  dist_food is not null
  AND level = {5}
ORDER BY points DESC
LIMIT {3};
*/
-- {0}, {1} - koordinates of central marker
-- {2} - radius of search
-- {3} - count of points
-- {4} - sensivity factor
-- {5} - level of analyzed points
-- {6}-{10} - weights