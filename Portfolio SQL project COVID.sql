-- select Dtata that are we going to be using
select 
	location,
	date,
	total_cases,
	new_cases,
	total_deaths,
	population
from [Portfolio project]..CovidDeaths
order by 1,2


-- Looking at the total cases vs total deaths
select 
	location,
	date,
	total_cases,
	total_deaths,
	(total_deaths/total_cases)*100 as DeathPercentage
from [Portfolio project]..CovidDeaths
where location like 'Mexico'
order by 1,2

-- Looking at the total cases vs Population
select 
	location,
	date,
	population,
	total_cases,
	(total_cases/population)*100 as CasesPercentage
from [Portfolio project]..CovidDeaths
order by 1,2

-- Looking at countries with highest Infection Rate compared to Population
select 
	Location,
	population,
	max(total_cases) as HighestInfectionCount, 
	max((total_cases/population))*100 as PercentagePopulationInfected
from [Portfolio project]..CovidDeaths
group by 
	location,
	population
order by PercentagePopulationInfected desc

-- Showin the countries with the highest Deat Count per Population
select 
	Location,
	max(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio project]..CovidDeaths
where
	continent is not null
group by 
	location
order by TotalDeathCount desc

--Breaking things down
--Showing Continent with the highest Death Count
select 
	continent,
	max(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio project]..CovidDeaths
where
	continent is not null
group by 
	continent
order by TotalDeathCount desc


--Global Numbers
select 
	date,
	sum(new_cases) as TotalCases
	,sum(cast(new_deaths as int)) as TotalDeaths
	,(SUM(CAST(new_deaths as int)) / sum(new_cases)) * 100 as DeathPercentage
from [Portfolio project]..CovidDeaths
where continent is not null
Group by 
	date
order by 1,2

--In general
select 
	sum(new_cases) as TotalCases
	,sum(cast(new_deaths as int)) as TotalDeaths
	,(SUM(CAST(new_deaths as int)) / sum(new_cases)) * 100 as DeathPercentage
from [Portfolio project]..CovidDeaths
where continent is not null
order by 1,2

--Looking at total population vs Vaccinations

select 
	dea.continent
	,dea.location
	,dea.date
	,dea.population
	,vac.new_vaccinations
	,SUM(CONVERT(bigint, vac.new_vaccinations)) 
		OVER (partition by dea.location ORDER BY dea.location, dea.date) as RollingPepopleVaccinated
	--(RollingPepopleVaccinated / dea.population) * 100
from [Portfolio project]..CovidDeaths dea
join [Portfolio project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where
	dea.continent is not null
order by 2, 3


-- USE CTE
with PopvsVac 
	(Continent, Location, Date, Population, new_vaccinations, RollingPepopleVaccinated)
as
(
	select 
		dea.continent
		,dea.location
		,dea.date
		,dea.population
		,vac.new_vaccinations
		,SUM(CONVERT(bigint, vac.new_vaccinations)) 
			OVER (partition by dea.location ORDER BY dea.location, dea.date) as RollingPepopleVaccinated
	from [Portfolio project]..CovidDeaths dea
	join [Portfolio project]..CovidVaccinations vac
		on dea.location = vac.location
		and dea.date = vac.date
	where
		dea.continent is not null
	--order by 2, 3
)
select *
	, (RollingPepopleVaccinated / Population)*100
from PopvsVac


-- Create view to store data for later visualizations
Create view PercentPopulationVaccinate as
with PopvsVac 
	(Continent, Location, Date, Population, new_vaccinations, RollingPepopleVaccinated)
as
(
	select 
		dea.continent
		,dea.location
		,dea.date
		,dea.population
		,vac.new_vaccinations
		,SUM(CONVERT(bigint, vac.new_vaccinations)) 
			OVER (partition by dea.location ORDER BY dea.location, dea.date) as RollingPepopleVaccinated
	from [Portfolio project]..CovidDeaths dea
	join [Portfolio project]..CovidVaccinations vac
		on dea.location = vac.location
		and dea.date = vac.date
	where
		dea.continent is not null
	--order by 2, 3
)
select *
	, (RollingPepopleVaccinated / Population)*100 as PercentagePopulationVaccinated
from PopvsVac

select * from PercentPopulationVaccinated