----------------- DATA VISUALIZATION -----------------

-- 1. Looking at total_cases vs total_deaths (death rate)
SELECT SUM(new_cases) AS total_cases
    ,   SUM(new_deaths) AS total_deaths
    ,   100.0*SUM(new_deaths)/SUM(new_cases) AS death_rate
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2;

-- 2. Looking at the number of deaths per country.
SELECT location
    ,   SUM(new_deaths) AS total_death_count
From dbo.CovidDeaths
WHERE continent IS NULL
    AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY total_death_count DESC;

-- 3. Looking at the highest infection count and rate
SELECT location
    ,   population
    ,   MAX(total_cases) AS highest_infection_count
    ,   MAX(100.0*total_cases/population) AS highest_infection_rate
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY 4 DESC;

-- 4. Looking at the highest infection count and rate over time
SELECT location
    ,   population
    ,   date 
    ,   MAX(total_cases) AS highest_infection_count
    ,   MAX(100.0*total_cases/population) AS highest_infection_rate
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location,population, date 
ORDER BY 5 DESC;
