Select *
From PortfolioProject..CovidDeath$
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations$
--order by 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeath$
order by 1,2

-- Looking at Total Cases Vs Total Deaths
-- Shows likelihood of dying if infected by covid in Lebanon

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeath$
Where location like '%Lebanon%'
order by 1,2

-- Looking at the Total Cases Vs Population
-- Shows the percentage of population that got covid

Select Location, date, total_cases, population, (total_cases/population)*100 as CasesPerPopulationPercentage
From PortfolioProject..CovidDeath$
-- Where location like '%Lebanon%'
order by 1,2

-- Loking at Countries with Highest Infection Rate compared to Population

Select Location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentOfPopulationInfected
From PortfolioProject..CovidDeath$
-- Where location like '%Lebanon%'
Group by Location, Population
order by PercentOfPopulationInfected desc

-- Looking at the countries with the highest death count per population

Select Location, MAX(cast(total_deaths as int)) as HighestDeathCount
From PortfolioProject..CovidDeath$
-- Where location like '%Lebanon%'
Where continent is null
Group by Location
order by HighestDeathCount desc

--Showing Continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as HighestDeathCount
From PortfolioProject..CovidDeath$
-- Where location like '%Lebanon%'
Where continent is not null
Group by continent
order by HighestDeathCount desc


--Global Numbers

Select date, SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeath$
-- Where location like '%Lebanon%'
where continent is not null 
Group by date
order by 1,2

--Looking at Total Population Vs Vaccinations


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeath$ dea
join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

-- USE CTE

With PopvsVac ( continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeath$ dea
join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
-- order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac



-- Temp Table
-- Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeath$ dea
join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
-- order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


-- Creating View to Store Data for later Visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeath$ dea
join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
-- order by 2,3

