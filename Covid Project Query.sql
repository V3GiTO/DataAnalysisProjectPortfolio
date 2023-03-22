select *
From CovidProject..CovidDeaths$
where continent is not null
order by 3, 4

--select *
--From CovidProject..CovidVaccinations$
--order by 3, 4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
FROM CovidProject..CovidDeaths$
order by 1, 2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (CAST(total_deaths as float)/CAST(total_cases as float))*100 as DeathPercentage
FROM CovidProject..CovidDeaths$
Where location = 'india'
order by 1, 2

-- Looking at Total Cases  vs Population

Select Location, date, population, total_cases, Round((total_cases/population)*100,3) as PercentPopulationInfected
FROM CovidProject..CovidDeaths$
--Where location = 'india'
order by 1, 2

-- Looking at countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HightestInfectionCount, (MAX(total_cases)/MAX(population))*100 as PercentPopulationInfected
FROM CovidProject..CovidDeaths$
--Where location = 'india'
Group by location, population
order by PercentPopulationInfected desc
--order by population desc

-- Showing Countries with Highest Death Count per Population

Select Location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM CovidProject..CovidDeaths$
--Where location = 'india'
where continent is not null
Group by location
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing Continents with the highest death count per Population

Select continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM CovidProject..CovidDeaths$
--Where location = 'india'
where continent is not null
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select --date,
SUM(new_cases) as TotalCases,
SUM(CAST(new_deaths as int)) as TotalDeaths, 
CASE 
    WHEN SUM(new_cases) = 0 THEN NULL 
    ELSE SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 
END AS DeathPercentage
FROM CovidProject..CovidDeaths$
--Where location = 'india'
where continent is not null
--Group By date
order by 1, 2

-- Looking at Total Population vs Vaccinations


-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select death.continent, death.location, death.date, death.population, vaccination.new_vaccinations, 
SUM(CONVERT(bigint, vaccination.new_vaccinations)) OVER (Partition by death.location order by death.location, death.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/death.population)
From CovidProject..CovidDeaths$ death
Join CovidProject..CovidVaccinations$ vaccination
	ON death.location = vaccination.location
	and death.date = vaccination.date
Where death.continent is not null
--order by 2, 3
)
Select *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac




-- TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
    Continent nvarchar(255),
    Location nvarchar(255),
    Date datetime,
    Population numeric,
    RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT death.continent, death.location, death.date, death.population,
       SUM(CONVERT(bigint, vaccination.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS RollingPeopleVaccinated
FROM CovidProject..CovidDeaths$ death
JOIN CovidProject..CovidVaccinations$ vaccination
    ON death.location = vaccination.location
    AND death.date = vaccination.date
WHERE death.continent IS NOT NULL
--ORDER BY 2, 3

Select *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT death.continent, death.location, death.date, death.population,
       SUM(CONVERT(bigint, vaccination.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS RollingPeopleVaccinated
FROM CovidProject..CovidDeaths$ death
JOIN CovidProject..CovidVaccinations$ vaccination
    ON death.location = vaccination.location
    AND death.date = vaccination.date
WHERE death.continent IS NOT NULL
--ORDER BY 2, 3

Select *
From PercentPopulationVaccinated