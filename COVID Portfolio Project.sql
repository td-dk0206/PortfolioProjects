select * 
from PortfolioProject..CovidDeaths
WHERE continent is not null
order by 3,4


--select * 
--from PortfolioProject..CovidVaccinations
--order by 3,4

-- Select Data that we are going to be using

select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
WHERE continent is not null
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likeihood of dying if you contract covid in your country

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
WHERE Location like '%states%'
and continent is not null
order by 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid in your country

SELECT Location, date, population, total_cases,(total_cases/population)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
WHERE Location like '%states%'
Order by 1,2


-- Looking at countries with highest infection rate compared to population
SELECT Location, population,
MAX(total_cases) as HighestInfectionCount,
MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--WHERE Location like '%states%'
Group by Location, population
Order by PercentPopulationInfected desc


-- Showing countries with Highest Death Count per Population
SELECT Location,
MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--WHERE Location like '%states%'
WHERE continent is not null
Group by Location
Order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count per population
SELECT Continent,
MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--WHERE Location like '%states%'
WHERE continent is not null
Group by Continent
Order by TotalDeathCount desc


-- Global Numbers
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--WHERE Location like '%states%'
WHERE continent is not null
--GROUP BY Date
order by 1,2


-- Total Population vs Vaccincations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location
Order by dea.location, dea.date ) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3



-- USE CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location
Order by dea.location, dea.date ) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac



-- USE TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location
Order by dea.location, dea.date ) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

Select *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location
Order by dea.location, dea.date ) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

Select * From PercentPopulationVaccinated