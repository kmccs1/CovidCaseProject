/*
Covid Data Exploration Project 

Skills Used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/


SELECT * FROM PortfolioProject..CovidDeaths$
WHERE continent is NOT null


-- Looking at Percent of Fatalities for Total Contracted Cases

SELECT location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as PercentFatalities 
FROM PortfolioProject..CovidDeaths$
WHERE location like 'United States' AND continent is NOT null
ORDER BY 1,2


-- Looking at Total Cases vs Population

SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected FROM PortfolioProject..CovidDeaths$
WHERE location LIKE 'United States' AND continent IS NOT null
ORDER BY 1,2


-- Looking at Countries with Highest Infection Rate Compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)*100) as PercentPopulationInfected 
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT null
GROUP BY location, population 
ORDER BY PercentPopulationInfected desc


-- Looking at Countries with Highest Fatality Count per Population

SELECT location, MAX(cast(total_deaths as int)) AS TotalFatalities, MAX(((cast(total_deaths as int)) /population)*100) as PercentPopulationFatalities
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location 
ORDER BY PercentPopulationFatalities desc


-- Looking at Countries with Highest Infection Count per Population

Select location, population, date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
Group BY Location, Population, date
ORDER BY PercentPopulationInfected desc


-- Breaking it down by continent

SELECT continent,  MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT null
GROUP BY continent 
ORDER BY 2 desc


-- Global Numbers

SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) AS TotalFatalities, 
	SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
--WHERE location like 'United States' 


-- Moving to Vaccinations

-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as INT)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS RollingVaxCount
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..[CovidVaccinations$] vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NUll
ORDER BY 2, 3


-- Using CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingVaxCount)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as INT)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS RollingVaxCount
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..[CovidVaccinations$] vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NUll
)

Select *, RollingVaxCount/population *100
FROM PopvsVac


--temp table

DROP TABLE if exists #PercentPopVax 
CREATE TABLE #PercentPopVax 
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingVaxCount numeric)

INSERT INTO #PercentPopVax
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as INT)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS RollingVaxCount
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..[CovidVaccinations$] vac
	ON dea.location = vac.location AND dea.date = vac.date

Select *, RollingVaxCount/population *100
FROM #PercentPopVax


-- Creating View to Store for Later

Create view PercentPopVax as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as INT)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS RollingVaxCount
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..[CovidVaccinations$] vac
	ON dea.location = vac.location AND dea.date = vac.date

Select * 
FROM [PortfolioProject].[dbo].[PercentPopVax]


