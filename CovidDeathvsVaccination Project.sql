----Select *
----From Select *
--From PortfolioProject.dbo.CovidDeaths
--order by 1,2

----Select *
----From PortfolioProject.dbo.CovidVaccination
----order by 1,2

--Total Cases vs Total Deaths

Select Location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
Where location like 'India'
order by 1,2

--Total Cases vs Population

Select Location,date,population, total_cases, (total_cases/population)*100 as InfectionPercentage
From PortfolioProject.dbo.CovidDeaths
--Where location like 'India'
order by 1,2

--Countries with Highest InfectionRate

Select Location, population, MAX(total_cases) as InfectionCount,MAX((total_cases/population))*100 as InfectionPercentage
From PortfolioProject.dbo.CovidDeaths
group by location, population
order by InfectionPercentage desc

--Countries with Highest Deathcount vs Population

Select Location, MAX(cast(total_deaths as int)) as DeathCount 
From PortfolioProject.dbo.CovidDeaths
where continent is not null
group by location
order by DeathCount desc

--BY Continent
--Continents with highest deathcount

Select continent, MAX(cast(total_deaths as int)) as DeathCount 
From PortfolioProject.dbo.CovidDeaths
where continent is not null
group by continent
order by DeathCount desc

--GlobalCount

Select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast (new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 1,2

-- Total Population vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVccinated 
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccination vac
on dea.date = vac.date
and dea.location = vac.location
where dea.continent is not null
order by 2,3

--Using CTE
 With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
 as
 (
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVccinated 
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccination vac
on dea.date = vac.date
and dea.location = vac.location
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100 as VaccinationPercentage
From PopvsVac

--TEMP TABLE

Drop Table if exists #PercentPeopleVaccinated 
Create Table #PercentPeopleVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPeopleVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVccinated 
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccination vac
on dea.date = vac.date
and dea.location = vac.location
--where dea.continent is not null 
Select *, (RollingPeopleVaccinated/Population)*100 as VaccinationPercentage 
From #PercentPeopleVaccinated

--Creating View

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVccinated 
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccination vac
on dea.date = vac.date
and dea.location = vac.location
--where dea.continent is not null

Select *
From PercentPopulationVaccinated 
