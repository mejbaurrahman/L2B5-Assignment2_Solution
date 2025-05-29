-- Active: 1747649431695@@127.0.0.1@5432@conservation_db
-- Active: 1747649431695@@127.0.0.1@5432@postgres
CREATE DATABASE conservation_db;

CREATE TABLE rangers(
    ranger_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    region VARCHAR(255) NOT NULL
)

CREATE TABLE species(
    species_id SERIAL PRIMARY KEY,
    common_name VARCHAR(255) NOT NULL,
    scientific_name VARCHAR(255) NOT NULL,
    discovery_date DATE,
    conservation_status VARCHAR(100)
)

CREATE TABLE sightings(
    sighting_id SERIAL PRIMARY KEY,
    ranger_id INT NOT NULL REFERENCES rangers(ranger_id),
    species_id INT NOT NULL REFERENCES species(species_id),
    sighting_time TIMESTAMP,
    location VARCHAR(255) NOT NULL,
    notes TEXT
)

INSERT INTO rangers ( name, region) VALUES
('Alice Green', 'Northern Hills'),
('Bob White', 'River Delta'),
('Carol King', 'Mountain Range');

INSERT INTO species (common_name, scientific_name, discovery_date, conservation_status) VALUES
('Snow Leopard', 'Panthera uncia', '1775-01-01', 'Endangered'),
('Bengal Tiger', 'Panthera tigris tigris', '1758-01-01', 'Endangered'),
('Red Panda', 'Ailurus fulgens', '1825-01-01', 'Vulnerable'),
('Asiatic Elephant', 'Elephas maximus indicus', '1758-01-01', 'Endangered');

INSERT INTO sightings (species_id, ranger_id, location, sighting_time, notes) VALUES
(1, 1, 'Peak Ridge',        '2024-05-10 07:45:00', 'Camera trap image captured'),
(2, 2, 'Bankwood Area',     '2024-05-12 16:20:00', 'Juvenile seen'),
(3, 3, 'Bamboo Grove East', '2024-05-15 09:10:00', 'Feeding observed'),
(1, 2, 'Snowfall Pass',     '2024-05-18 18:30:00', NULL);

--Problem -1

INSERT INTO rangers(name, region) VALUES('Derek Fox', 'Coastal Plains')

--Problem- 2

SELECT COUNT(DISTINCT species_id) as unique_species_count FROM sightings

--Problem -3

SELECT * from sightings WHERE location LIKE '%Pass%'

--Problem -4 

SELECT name, COUNT(sighting_id) as total_sightings FROM rangers JOIN sightings ON rangers.ranger_id= sightings.ranger_id GROUP BY rangers.ranger_id

--Problem -5

SELECT common_name FROM species
LEFT JOIN sightings ON species.species_id = sightings.species_id
WHERE sightings.species_id IS NULL;


--Problem --6 

SELECT 
    species.common_name, 
    sightings.sighting_time, 
    rangers.name
FROM sightings
JOIN species ON sightings.species_id = species.species_id
JOIN rangers  ON sightings.ranger_id = rangers.ranger_id
ORDER BY sightings.sighting_time DESC
LIMIT 2;

--Problem --7 

UPDATE species
SET conservation_status = 'Historic'
WHERE discovery_date < '1800-01-01';



--Problem -8
CREATE OR REPLACE FUNCTION time_of_day(sighting_time TIMESTAMP)
RETURNS VARCHAR AS $$
BEGIN
    IF EXTRACT(HOUR FROM sighting_time) < 12 THEN
        RETURN 'Morning';
    ELSIF EXTRACT(HOUR FROM sighting_time) BETWEEN 12 AND 17 THEN
        RETURN 'Afternoon';
    ELSE
        RETURN 'Evening';
    END IF;
END;
$$ LANGUAGE plpgsql;

SELECT sighting_id, time_of_day(sighting_time) as time_of_day from sightings;

--Problem -9
DELETE FROM rangers USING (SELECT rangers.ranger_id from rangers 
LEFT JOIN sightings 
ON rangers.ranger_id = sightings.ranger_id
WHERE sightings.ranger_id IS NULL
) AS sighting_nullable_rangers
WHERE rangers.ranger_id = sighting_nullable_rangers.ranger_id

