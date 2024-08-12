Select *
from PortfolioProject..covid_deaths
where continent is not null
order by 3,4

--Select *
--from PortfolioProject..covid_vaccinations 
--order by 3,4

-- Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..covid_deaths
order by 1, 2

-- Looking at Total Cases vs Total Deaths
-- error: Divide by zero error encountered. =>  dividend / NULLIF(divisor,0)
-- From 2023/5/8 no more data colected as a whole country in Japan
-- Shows likelihood of dying if you contract Covid in Japan

Select location, date, total_cases, total_deaths, (total_deaths/NULLIF(total_cases,0))*100 as DeathPercentage
from PortfolioProject..covid_deaths
where location like 'Japan'
order by 1, 2

Select location, date, total_cases, total_deaths, (total_deaths/NULLIF(total_cases,0))*100 as DeathPercentage
from PortfolioProject..covid_deaths
where continent is not null
order by 1, 2

-- Looking at Total Cases ve Population
-- Shows what percentage of population got Covid

Select location, date, total_cases, population, (total_cases/population) * 100 as PercentagePopulationInfected
from PortfolioProject..covid_deaths
--where location like 'Japan'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

Select location,population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population) * 100 as HighestInfectionRate
from PortfolioProject..covid_deaths
--where location like 'Japan'
group by location, population
order by HighestInfectionRate desc

-- Showing Countires with Highest Death Count Per Population

Select location,population, MAX(total_deaths) as HighestDeathCount
from PortfolioProject..covid_deaths
--where location like 'Japan'
where continent is not null
group by location, population
order by HighestDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

Select location, MAX(total_deaths) as TotalDeathCount
from PortfolioProject..covid_deaths
where continent is null
group by location
order by TotalDeathCount desc


-- Showing continents with the highest death count per population

Select continent, MAX(total_deaths) as TotalDeathCount
from PortfolioProject..covid_deaths
where continent is not null
group by continent
order by TotalDeathCount desc

-- Global Numbers

Select Sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, (sum(new_deaths)/sum(NULLIF(new_cases,0)))*100 as DeathPercentage
from PortfolioProject..covid_deaths
where continent is not null
order by 1,2

-- Looking at Total Population vs Vaccinations

Select dea.continent,dea.location, dea.date,  dea.population, vac.new_vaccinations,
sum(convert(float, vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/dea.population)*100
From PortfolioProject..covid_deaths dea
Join PortfolioProject..covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null And dea.location = 'Japan'
Order by 2,3

-- USE CTE
With PopvsVac(continent,location,date,population,new_vaccination,RollingPeopleVaccinated) as (
	Select dea.continent,dea.location, dea.date,  dea.population, vac.new_vaccinations,
	sum(convert(float, vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
	From PortfolioProject..covid_deaths dea
	Join PortfolioProject..covid_vaccinations vac
		On dea.location = vac.location
		and dea.date = vac.date
	Where dea.continent is not null and dea.location ='Japan')
Select *, (RollingPeopleVaccinated/population)*100 as PercentagePeopleVaccinated
From PopvsVac

-- USE TEMP TABLE
Drop Table IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location, dea.date,  dea.population, vac.new_vaccinations,
 sum(convert(float, vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..covid_deaths dea
Join PortfolioProject..covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null and dea.location ='Japan'
Select *, (RollingPeopleVaccinated/population)*100 as PercentPeopleVaccinated
From #PercentPopulationVaccinated

-- Create View to store data for later visualization

USE PortfolioProject
Go
CREATE VIEW
PercentPeopleVaccinated
as
Select dea.continent,dea.location, dea.date,  dea.population, vac.new_vaccinations,
 sum(convert(float, vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..covid_deaths dea
Join PortfolioProject..covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null


Select *
From PercentPeopleVaccinated
Order by 2,3