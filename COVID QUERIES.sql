SELECT * FROM PortfolioProject..CovidDeaths$
WHERE continent is NOT null

-- percent of deaths of total contracted cases
SELECT location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as percentofdeaths FROM PortfolioProject..CovidDeaths$
WHERE location like 'United States' AND continent is NOT null
order by 1,2

-- Looking at total cases vs population
SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentOfPopulationInfected FROM PortfolioProject..CovidDeaths$
WHERE location like 'United States' AND continent is NOT null
order by 1,2

-- Looking at countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)*100) as PercentOfPopulationInfected FROM PortfolioProject..CovidDeaths$
WHERE continent is NOT null
GROUP BY location, population 
order by PercentOfPopulationInfected desc

--Show countries with Highest Death Count per Population

SELECT location,  MAX(cast(total_deaths as int)) 
FROM PortfolioProject..CovidDeaths$
WHERE continent is NOT null
GROUP BY location 
order by 2 desc

SELECT location, MAX(((cast(total_deaths as int)) /population)*100) as PercentOfPopulationDeaths
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location 
order by PercentOfPopulationDeaths desc




--Breaking it down by continent

SELECT continent,  MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT null
GROUP BY continent 
order by 2 desc


--Global Numbers

SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) AS totalDeaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
--, total_deaths, (total_deaths/total_cases)*100 as PercentOfDeaths 
FROM PortfolioProject..CovidDeaths$
--WHERE location like 'United States' 

WHERE continent is NOT null
--GROUP BY date
order by 1,2


-- MOVING TO COVID VACCINATIONS


-- Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as INT)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS RollingVaxCount
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..[CovidVaccinations$] vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NUll
ORDER BY 2, 3


--Using CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingVaxCount)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as INT)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS RollingVaxCount
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..[CovidVaccinations$] vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NUll
--ORDER BY 2, 3
)

Select *, RollingVaxCount/population *100
from PopvsVac

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
--WHERE dea.continent IS NOT NUll
--ORDER BY 2, 3

Select *, RollingVaxCount/population *100
from #PercentPopVax


--Creating view to store for later

Create view PercentPopVax as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as INT)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS RollingVaxCount
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..[CovidVaccinations$] vac
	ON dea.location = vac.location AND dea.date = vac.date
--WHERE dea.continent IS NOT NUll
--ORDER BY 2, 3

Select * 
FROM PercentPopVax