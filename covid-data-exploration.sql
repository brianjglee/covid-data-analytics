SELECT *
FROM dbo.CovidDeaths;

----------------- DATA EXPLORATION -----------------

-- Looking at total_cases vs total_deaths
-- Shows the likelihood of dying if you contract covid in the United States at a specific date. 
SELECT location, date, total_cases, total_deaths, 100.0*total_deaths/total_cases AS death_perc
FROM dbo.CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2;

-- Looking at total_cases vs population
SELECT location, date, total_cases, population, 100.0*total_cases/population as covid_contraction
FROM dbo.CovidDeaths
ORDER BY 1,2;

-- Looking at the countries with the highest infection rate when compared to the population
SELECT location, MAX(100.0*total_cases/population) AS infection_rate
FROM dbo.CovidDeaths
GROUP BY location
ORDER BY 2 DESC;

-- Looking at the countries with the highest number of deaths
SELECT location, MAX(total_deaths)
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC;

-- BY CONTINENT
SELECT continent, MAX(total_deaths)
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC;

--------------------------------
-- GLOBAL NUMBERS

-- Looking at the number of cases in the world over time
SELECT date, SUM(total_cases) AS global_case_count
FROM dbo.CovidDeaths
GROUP BY date
ORDER BY date;

-- Join deaths and vaccinations tables
-- Looking at the total number of vaccinations over time
SELECT d.continent
    ,   d.location
    ,   d.date
    ,   d.population
    ,   v.new_vaccinations
    ,   SUM(v.new_vaccinations) OVER ( -- sum the number of vaccinations by location over time
            PARTITION BY d.location
            ORDER BY d.date) AS total_vaccinations_by_loc
FROM dbo.CovidDeaths AS d
JOIN dbo.CovidVaccinations AS v 
    ON d.location=v.location 
    AND d.date = v.date 
WHERE d.continent IS NOT NULL
ORDER BY 2, 3;

-- Looking at vaccination rate per country over time using a CTE. 
WITH cte AS (
    SELECT d.continent
    ,   d.location
    ,   d.date
    ,   d.population
    ,   v.new_vaccinations
    ,   SUM(v.new_vaccinations) OVER ( -- sum the number of vaccinations by location over time
            PARTITION BY d.location
            ORDER BY d.date) AS total_vaccinations_by_loc
    FROM dbo.CovidDeaths AS d
    JOIN dbo.CovidVaccinations AS v 
        ON d.location=v.location 
        AND d.date = v.date 
    WHERE d.continent IS NOT NULL)
SELECT *, 100.0*total_vaccinations_by_loc/population AS vaccination_rate
FROM cte
ORDER BY 2,3;

-- Viewing the data: 
Create View populationVaccinatedPerc AS (
    SELECT d.continent
    ,   d.location
    ,   d.date
    ,   d.population
    ,   v.new_vaccinations
    ,   SUM(v.new_vaccinations) OVER ( -- sum the number of vaccinations by location over time
            PARTITION BY d.location
            ORDER BY d.date) AS total_vaccinations_by_loc
    FROM dbo.CovidDeaths AS d
    JOIN dbo.CovidVaccinations AS v 
        ON d.location=v.location 
        AND d.date = v.date 
    WHERE d.continent IS NOT NULL
)


----------------- TABLE CREATION -----------------
-- queries to create table and load CSV

-- create table for CovidDeaths
CREATE TABLE CovidDeaths (
    iso_code VARCHAR(10)
    ,   continent VARCHAR(50)
    ,   location VARCHAR(50)
    ,   date DATE
    ,   population BIGINT
    ,   total_cases INT
    ,   new_cases INT
    ,   new_cases_smoothed FLOAT
    ,   total_deaths INT
    ,   new_deaths INT
    ,   new_deaths_smoothed FLOAT
    ,   total_cases_per_million FLOAT
    ,   new_cases_per_million FLOAT
    ,   new_cases_smoothed_per_million FLOAT
    ,   total_deaths_per_million FLOAT
    ,   new_deaths_per_million FLOAT
    ,   new_deaths_smoothed_per_million FLOAT
    ,   reproduction_rate FLOAT
    ,   icu_patients INT
    ,   icu_patients_per_million FLOAT
    ,   hosp_patients INT
    ,   hosp_patients_per_million FLOAT
    ,   weekly_icu_admissions FLOAT
    ,   weekly_icu_admissions_per_million FLOAT
    ,   weekly_hosp_admissions FLOAT
    ,   weekly_hosp_admissions_per_million FLOAT
);

-- create table for CovidVaccinations
CREATE TABLE CovidVaccinations (
    iso_code VARCHAR(10)
    ,   continent VARCHAR(50)
    ,   location VARCHAR(50)
    ,   date DATE
    ,   new_tests INT
    ,   total_tests INT
    ,   total_tests_per_thousand FLOAT
    ,   new_tests_per_thousand FLOAT
    ,   new_tests_smoothed INT
    ,   new_tests_smoothed_per_thousand FLOAT
    ,   positive_rate FLOAT
    ,   tests_per_case FLOAT
    ,   tests_units VARCHAR(50)
    ,   total_vaccinations INT
    ,   people_vaccinated INT
    ,   people_fully_vaccinated INT
    ,   new_vaccinations INT
    ,   new_vaccinations_smoothed INT
    ,   total_vaccinations_per_hundred FLOAT
    ,   people_vaccinated_per_hundred FLOAT
    ,   people_fully_vaccinated_per_hundred FLOAT
    ,   new_vaccinations_smoothed_per_million INT
    ,   stringency_index FLOAT
    ,   population_density FLOAT
    ,   median_age FLOAT
    ,   aged_65_older FLOAT
    ,   aged_70_older FLOAT
    ,   gdp_per_capita FLOAT
    ,   extreme_poverty FLOAT
    ,   cardiovasc_death_rate FLOAT
    ,   diabetes_prevalence FLOAT
    ,   female_smokers FLOAT
    ,   male_smokers FLOAT
    ,   handwashing_facilities FLOAT
    ,   hospital_beds_per_thousand FLOAT
    ,   life_expectancy FLOAT
    ,   human_development_index FLOAT
);

-- import csv files into respective tables
BULK INSERT dbo.CovidDeaths
FROM '/CovidDeaths.csv'
WITH (
    FORMAT='CSV',
    FIRSTROW=2
)
GO

BULK INSERT dbo.CovidVaccinations
FROM '/CovidVaccinations.csv'
WITH (
    FORMAT='CSV',
    FIRSTROW=2
)
GO