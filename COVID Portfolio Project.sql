Select *
FROM PortfolioProject..COVIDDeaths
Where continent is not null
order by 3,4

--Select *
--FROM PortfolioProject..COVIDVaccinations
--order by 3,4

--Select Data that we are going to be using

Select Location, Date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..COVIDDeaths
order by 1,2

-- Looking at Total Cases Vs Total Deaths

Select 
Location, 
Date, 
total_cases, 
total_deaths, 
CONVERT(DECIMAL(18, 2), (CONVERT(DECIMAL(18, 2), total_deaths) / CONVERT(DECIMAL(18, 2), total_cases)))*100 AS DeathPercentage
FROM PortfolioProject..COVIDDeaths
WHERE Location like '%states%'
order by 1,2

--Looking at total Cases vs Population
--Shows what percentage of population got COVID

Select 
Location, 
Date, 
total_cases, 
Population, 
CONVERT(DECIMAL(18, 2), (CONVERT(DECIMAL(18, 2), total_cases) / CONVERT(DECIMAL(18, 2), Population)))*100 AS CasePercentage
FROM PortfolioProject..COVIDDeaths
-- Where Location can be anything other than the US. Just use '% %' in whatever country you'd like to see the data in. 
WHERE Location like '%states%'
order by 1,2

-- Infection Rate Compared to Population

Select 
Location,   
Population, 
MAX(total_cases) as HighestInfectionCount,
CONVERT(DECIMAL(18, 2), (CONVERT(DECIMAL(18, 2), MAX(total_cases) / CONVERT(DECIMAL(18, 2), Population))))*100 AS InfectionRate
FROM PortfolioProject..COVIDDeaths
Group by Location, Population
order by InfectionRate DESC

-- Showing Countries with Highest Death Count per population
 
Select 
Location,   
MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..COVIDDeaths
-- Where Location can be anything other than the US. Just use '% %' in whatever country you'd like to see the data in.
Where continent is not null
Group by Location
order by TotalDeathCount DESC

--Let's break things down by continent

Select 
Continent,   
MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..COVIDDeaths
-- Where Location can be anything other than the US. Just use '% %' in whatever country you'd like to see the data in.
Where continent is not null
Group by Continent
order by TotalDeathCount DESC

--A more accurate way below but I commented it out because it seems to also have Income included in location

--Select 
--Location,   
--MAX(cast(total_deaths as int)) as TotalDeathCount
--FROM PortfolioProject..COVIDDeaths
---- Where Location can be anything other than the US. Just use '% %' in whatever country you'd like to see the data in.
--Where continent is null
--Group by Location
--order by TotalDeathCount DESC




-- Global numbers


SET ARITHABORT OFF;
SET ANSI_WARNINGS OFF;
Select
SUM(new_cases) as total_cases,
SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..COVIDDeaths
--WHERE Location like '%states%'
Where Continent is not null 
--Group by Date
order by 1,2


-- Looking at Total Population vs Vaccinations
-- I've commented an option to see the data without the Null new_vaccinations. This way you can get the data you wish.
-- This makes it easier to get to the RollingPeople Vaccinated Numbers. 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..COVIDDeaths dea
Join PortfolioProject..COVIDVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--and new_vaccinations is not null
order by 2,3

-- Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..COVIDDeaths dea
Join PortfolioProject..COVIDVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--and new_vaccinations is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

--Use Temp Table


Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT Into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..COVIDDeaths dea
Join PortfolioProject..COVIDVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--and new_vaccinations is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..COVIDDeaths dea
Join PortfolioProject..COVIDVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--and new_vaccinations is not null
--order by 2,3

Select *
FROM PercentPopulationVaccinated