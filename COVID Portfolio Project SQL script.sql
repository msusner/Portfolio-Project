select * 
from CovidDeaths
where continent is not null
order by 3,4

----select * 
--from CovidVaccinations
----order by 3,4

-- Select Data that we are going to be using
--select location, date, total_cases, new_cases, total_deaths, population
--from CovidDeaths
--order by 1,2

-- Looking at Total Cases vs. Total Deaths
-- Shows the likelihood of dying if you contract COVID-19 in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as 'Death%'
from CovidDeaths
where location like '%states%'
order by 1,2

-- Looking at the Total Cases vs Population
-- Shows what percentage of population got COVID
select location, date, population, total_cases,  (total_cases/population)*100 as 'PercentPopulationInfected'
from CovidDeaths
--where location like '%states%'
order by 1,2


-- Countries with highest infection rate compared to population
select location, population, max(total_cases) as 'Highest Infection Count',  MAX((total_cases/population))*100 as PercentPopulationInfected
from CovidDeaths
--where location like '%states%'
group by location, population
order by PercentPopulationInfected desc


-- LET'S BREAK THINGS DOWN BY CONTINENTS


-- Countries with highest Death Rate per population
select location, max(cast(total_deaths as int)) as DeathCount
from CovidDeaths
--where location like '%states%'
where continent is null
group by location
order by DeathCount desc


-- Showing the continents with the highest death count per population
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc


-- Global Numbers
select date, sum(new_cases) as TotalNewCases, sum(cast(new_deaths as int)) as TotalNewDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage--, total_deaths, (total_deaths/total_cases)*100 as 'DeathPercentage'
from CovidDeaths
--where location like '%states%'
WHERE continent is not null
group by date
order by 1,2

-- Global Numbers so far
select sum(new_cases) as TotalNewCases, sum(cast(new_deaths as int)) as TotalNewDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage--, total_deaths, (total_deaths/total_cases)*100 as 'DeathPercentage'
from CovidDeaths
--where location like '%states%'
WHERE continent is not null
order by 1,2



--Total Population vs. Vaccination
select d.continent, d.location, d.date, d.population, v.new_vaccinations
, sum(CONVERT(int, new_vaccinations)) OVER (Partition BY d.location order by d.location, d.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from CovidDeaths as d
JOIN CovidVaccinations as v
ON d.location = v.location 
and d.date=v.date
where d.continent is not null
order by 2,3


-- USE CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
select d.continent, d.location, d.date, d.population, v.new_vaccinations
, sum(CONVERT(int, new_vaccinations)) OVER (Partition BY d.location order by d.location, d.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from CovidDeaths as d
JOIN CovidVaccinations as v
ON d.location = v.location 
and d.date=v.date
where d.continent is not null
--order by 2,3
)


select * , (RollingPeopleVaccinated/Population)*100
from PopvsVac




-- TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
select d.continent, d.location, d.date, d.population, v.new_vaccinations
, sum(CONVERT(int, new_vaccinations)) OVER (Partition BY d.location order by d.location, d.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from CovidDeaths as d
JOIN CovidVaccinations as v
ON d.location = v.location 
and d.date=v.date
where d.continent is not null
--order by 2,3

select * , (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated




-- Creating View to Store Data for later visualizations
Create View PercentPopulationVaccinated_v as
select d.continent, d.location, d.date, d.population, v.new_vaccinations
, sum(CONVERT(int, new_vaccinations)) OVER (Partition BY d.location order by d.location, d.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from CovidDeaths as d
JOIN CovidVaccinations as v
ON d.location = v.location 
and d.date=v.date
where d.continent is not null
--order by 2,3



-- Showing the continents with the highest death count per population
Create View TotalDeaths_v as
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
--order by TotalDeathCount desc

