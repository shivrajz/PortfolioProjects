
SELECT *
FROM PortfolioProject..CovidDeaths
where continent is not null
Order by 3, 4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--Order by 3, 4

Select Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
Order by 1, 2



-- Total Cases vs Total Deaths : 
-- percentage of population death.

Select Location, date, total_cases, total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
Where location like '%india%'
Order by 1, 2




-- Total cases vs Population :
-- percentage of population got COVID.

Select location, date, total_cases, population, (Total_cases/population)*100 as CasePercentage
FROM PortfolioProject..CovidDeaths
Where location like '%india%'
Order by 1, 2




-- Looking at Countries with Highest Infection Rate to population :

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as InfectedPercentage
FROM PortfolioProject..CovidDeaths
--Where location like '%india%'
Group by Location, Population
Order by InfectedPercentage DESC




-- Countires with Highest Death Count per Population :

Select location, MAX(cast(Total_Deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like '%india%'
where continent is not null
Group by Location
Order by TotalDeathCount desc




-- Showing the continents with Highest Death Count :

Select continent, MAX(cast(Total_Deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like '%india%'
where continent is not null
Group by continent
Order by TotalDeathCount desc




-- Global Numbers :

Select SUM(total_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--Where location like '%india%'
where continent is not null
--Group by date
Order by 1, 2




-- Vaccination.

Select *
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date




-- Total Population vs Vaccination :

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER(Partition by dea.location Order by dea.location, dea.date) as TotalVacc
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3



-- Using CTE :

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, TotalVacc)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER(Partition by dea.location Order by dea.location, dea.date) as TotalVacc
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
SELECT *, (TotalVacc/Population)*100 as VaccPercentage
From PopvsVac



-- TEMP TABLE :

DROP Table if exists #PercentPopulationVacc
Create Table #PercentPopulationVacc
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
TotalVacc numeric,
)

INSERT into #PercentPopulationVacc
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER(Partition by dea.location Order by dea.location, dea.date) as TotalVacc
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

SELECT *, (TotalVacc/Population)*100 as VaccPercentage
From #PercentPopulationVacc




-- Creating view to store data for lter vizualization

Create view PercentPopulationVacc as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER(Partition by dea.location Order by dea.location, dea.date) as TotalVacc
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

Select *
from PercentPopulationVacc
