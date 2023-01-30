
SELECT *
FROM dbo.Covid_deaths$
WHERE continent is not NULL
ORDER BY 3, 4

--SELECT *
--FROM dbo.CovidVacc$
--ORDER BY 3, 4

-- Death percentage in the Philippines

SELECT
	location, 
	date,
	total_cases,
	total_deaths,
	FORMAT(total_deaths / total_cases, 'P') AS DeathPercentage
FROM dbo.Covid_deaths$
WHERE location = 'Philippines';

-- creating view to store data for visualization later :)
CREATE VIEW ph_death_perc AS
SELECT
	location, 
	date,
	total_cases,
	total_deaths,
	FORMAT(total_deaths / total_cases, 'P') AS DeathPercentage
FROM dbo.Covid_deaths$
WHERE location = 'Philippines';

-- Death total in the Philippines

SELECT
	location, 
	MAX(CAST(total_deaths AS int)) AS DeathTotal
FROM dbo.Covid_deaths$
WHERE continent IS NOT NULL AND location = 'Philippines'
GROUP BY location;

---- CREATE VIEW
CREATE VIEW total_ph_death AS 
SELECT
	location, 
	MAX(CAST(total_deaths AS int)) AS DeathTotal
FROM dbo.Covid_deaths$
WHERE continent IS NOT NULL AND location = 'Philippines'
GROUP BY location;


-- Infection Rate of Philippines
SELECT
	location,
	population,
	MAX(total_cases) AS Highest_total_case,
	FORMAT(MAX(total_cases /population), 'P') AS Infection_rate
FROM dbo.Covid_deaths$
WHERE continent IS NOT NULL AND location = 'Philippines'
GROUP BY location, population
-- Cant use ORDER BY CasePercByPop, need to use equation of percentage
ORDER BY MAX(total_cases /population) * 100 DESC;


-- CREATE VIEW
CREATE VIEW infect_rate_ph AS
SELECT
	location,
	population,
	MAX(total_cases) AS Highest_total_case,
	FORMAT(MAX(total_cases /population), 'P') AS Infection_rate
FROM dbo.Covid_deaths$
WHERE continent IS NOT NULL AND location = 'Philippines'
GROUP BY location, population;


-- Total cases Vs Population
-- Shows how many percent in the population got covid
SELECT
	location, 
	date,
	population,
	total_cases,
	FORMAT(total_cases / population, 'P') AS CasePercentage
FROM dbo.Covid_deaths$
WHERE continent is not NULL
--Cant use ORDER BY CasePercentage, need to use equation of percentage
ORDER BY (total_cases / population)*100 DESC;

--CREATE VIEW
CREATE VIEW totalCasesVsPop AS 
SELECT
	location, 
	date,
	population,
	total_cases,
	FORMAT(total_cases / population, 'P') AS CasePercentage
FROM dbo.Covid_deaths$
WHERE continent is not NULL;


-- Countries with highest infection rate
SELECT
	location,
	population,
	MAX(total_cases) AS Highest_total,
	FORMAT(MAX(total_cases /population), 'P') AS CasePercByPop
FROM dbo.Covid_deaths$
WHERE continent is not NULL
GROUP BY location, population
-- Cant use ORDER BY CasePercByPop, need to use equation of percentage
ORDER BY MAX(total_cases /population) * 100 DESC;

-- CREATE VIEW
CREATE VIEW country_infection_rate AS
SELECT
	location,
	population,
	MAX(total_cases) AS Highest_total,
	FORMAT(MAX(total_cases /population), 'P') AS CasePercByPop
FROM dbo.Covid_deaths$
WHERE continent is not NULL
GROUP BY location, population;

-- Countries with highest death count per Population
SELECT
	location,
	MAX(CAST(total_deaths AS bigint)) AS Total_death_count
FROM dbo.Covid_deaths$
WHERE continent is not NULL
GROUP BY location
ORDER BY MAX(total_deaths/population)*100 DESC;

-- CREATE VIEW
CREATE VIEW totalDeathCountPerCountry AS 
SELECT
	location,
	MAX(CAST(total_deaths AS bigint)) AS Total_death_count
FROM dbo.Covid_deaths$
WHERE continent is not NULL
GROUP BY location;

--- Countries with highest death count percentage per Population percentage
SELECT
	location,
	MAX(CAST(total_deaths AS INT)) AS Total_death_count,
	FORMAT(MAX(total_deaths/population), 'P') AS DeathPercentage
FROM dbo.Covid_deaths$
WHERE continent is not NULL
GROUP BY location
ORDER BY MAX(total_deaths/population)*100 DESC;

-- Death Count Percentage By Continent

SELECT
	location,
	MAX(CAST(total_deaths AS bigint)) AS Total_death_count,
	FORMAT(MAX(total_deaths/population), 'P') AS DeathPercByPop
FROM dbo.Covid_deaths$
WHERE continent is NULL AND location IN('North America', 'South America', 'Asia', 'Europe', 'Oceania', 'Africa')
GROUP BY location
ORDER BY 2 DESC;

--Total cases per Continent

SELECT
	location, 
	MAX(CAST(total_cases AS int)) AS Total_case
FROM dbo.Covid_deaths$
WHERE continent is NULL AND location IN('North America', 'South America', 'Asia', 'Europe', 'Oceania', 'Africa')
GROUP BY location
ORDER BY 2 DESC;

--Total cases VS population per Continent

SELECT
	location,
	MAX(CAST(total_cases AS int)) AS Total_case,
	FORMAT(MAX(total_cases/population), 'P') AS CasePercentageByPop
FROM dbo.Covid_deaths$
WHERE continent is NULL AND location IN('North America', 'South America', 'Asia', 'Europe', 'Oceania', 'Africa')
GROUP BY location
ORDER BY MAX(total_cases/population)*100 DESC;


-- Continent with highest infection rate
SELECT
	location,
	population,
	MAX(total_cases) AS Highest_total,
	FORMAT(MAX(total_cases /population), 'P') AS highest_infection_rate
FROM dbo.Covid_deaths$
WHERE continent is NULL AND location IN('North America', 'South America', 'Asia', 'Europe', 'Oceania', 'Africa')
GROUP BY location, population
-- Cant use ORDER BY highest_infection_rate, need to use equation of percentage
ORDER BY MAX(total_cases /population) * 100 DESC;


-- GLOBAL NUMBERS

SELECT
	--date,
	SUM(new_cases) TotalCases,
	SUM(CAST(new_deaths AS INT)) TotalDeaths,
	FORMAT(SUM(CAST(new_deaths AS INT))/SUM(new_cases), 'P') GlobalDeathPercentage
FROM dbo.Covid_deaths$
WHERE continent IS NOT NULL;
--GROUP BY date
--ORDER BY date

-- Rolling count for Vaccination per location
SELECT 
	cd.continent,
	cd.location,
	cd.date,
	cd.population,
	cv.new_vaccinations,
	SUM(CONVERT(BIGINT, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS Total_Vacc,
	FORMAT(SUM(CONVERT(BIGINT, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date)/population, 'P') AS Vaccinated_percentage 
FROM dbo.Covid_deaths$ cd
JOIN dbo.CovidVacc$ cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY 2,3;


-- creating view to store data for visualization later :)

CREATE VIEW Vacc_Percentage_pop AS
SELECT 
	cd.continent,
	cd.location,
	cd.date,
	cd.population,
	cv.new_vaccinations,
	SUM(CONVERT(BIGINT, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS Total_Vacc,
	FORMAT(SUM(CONVERT(BIGINT, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date)/population, 'P') AS Vaccinated_percentage 
FROM dbo.Covid_deaths$ cd
JOIN dbo.CovidVacc$ cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL;


