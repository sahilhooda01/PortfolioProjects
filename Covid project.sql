






Select *
From [Portfolio Project]..Deaths
Where continent is not null
order by 3,4


--Select data that we are going to use.

Select Location,date,total_cases,new_cases,total_deaths,population
From [Portfolio Project]..Deaths
Where continent is not null
Order by 1,2


--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country.

Select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 As DeathPercentage 
From [Portfolio Project]..Deaths
Where location like '%states%'
and continent is not null
Order by 1,2


--Looking at Total Cases vs Population
--Shows what percentage of population got infected Covid.

Select Location,date,population,total_cases,(total_cases/population)*100 As PercentPopulationInfected
From [Portfolio Project]..Deaths
--Where location like '%states%'
Order by 1,2


--Looking at Countries with highest infection rate compared to Population

Select Location,population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected 
From [Portfolio Project]..Deaths
--Where location like '%states%'
Group By location,population
Order by PercentPopulationInfected desc


--Showing countries with highest death count per population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..Deaths
--Where location like '%states%'
Where continent is not null
Group By location
Order by TotalDeathCount desc



--LET'S BREAK THINGS DOWN BY CONTINENT

--Showing the continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..Deaths
--Where location like '%states%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc



--GLOBAL NUMBERS
--Global Death Percentage
Select sum(new_cases) as total_cases, sum(cast (new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage 
From [Portfolio Project]..Deaths
--Where location like '%states%'
where continent is not null
--Group By date
Order by 1,2



--Looking at Total Population vs Vaccinations
--Shows Percentage of Population that has received at least one COVID vaccine.

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from [Portfolio Project]..Deaths as dea
Join [Portfolio Project]..Vaccinations as vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
Order by 2,3


--USE CTE to perform calculation on partition by in previous query

With PopvsVac (Continent,Location,Date,Population,New_Vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from [Portfolio Project]..Deaths as dea
Join [Portfolio Project]..Vaccinations as vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--Order by 2,3
)
Select *,(RollingPeopleVaccinated/Population)*100
From PopvsVac



--Using TEMP Table to perform calculation on Partition by in previous query.

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated bigint
)

Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
,(RollingPeopleVaccinated/population)*100
from [Portfolio Project]..Deaths as dea
Join [Portfolio Project]..Vaccinations as vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--Order by 2,3

Select *,(RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
--,(CumulativePeopleVaccinated/population)*100
from [Portfolio Project]..Deaths as dea
Join [Portfolio Project]..Vaccinations as vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--Order by 2,3

Select *
From PercentPopulationVaccinated


