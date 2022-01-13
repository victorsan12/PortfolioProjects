-- Checking if data was imported correctly
SELECT *
FROM COVIDPortfolioProject..CovidVaccinations
ORDER BY 2

-- Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM COVIDPortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2


-- Looking at Total Cases vs Total Deaths as a percentage
-- Shows the percentage of death if you contract COVID in the United States

SELECT Location, date, total_cases, total_deaths,
Round((( total_deaths / total_cases)* 100),2) AS DeathPercentage
FROM COVIDPortfolioProject..CovidDeaths
WHERE location = 'United States' and continent is not null
ORDER BY 1,2


-- Looking at Total Cases vs Population
-- Shows percent of population that has contracted COVID

SELECT Location, date, population, total_cases,
Round((( total_cases / population)* 100),2) AS PopulationPercentage_of_TotalCases
FROM COVIDPortfolioProject..CovidDeaths
WHERE location = 'United States' and continent is not null
ORDER BY 1,2

-- Countries that have the highest infection rate
SELECT Location, population, MAX(total_cases) AS HighestInfectionCount,
MAX(ROUND((( total_cases / population)* 100),2)) AS PopulationPercentage_of_TotalCases
FROM COVIDPortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY PopulationPercentage_of_TotalCases desc

-- Countries that have the highest death rate per population
SELECT Location, population, MAX(total_deaths) AS HighestDeathCount,
MAX(ROUND((( total_deaths / population)* 100),2)) AS DeathPercentage_of_population
FROM COVIDPortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY DeathPercentage_of_population desc

-- Total_deaths is not in the correct data type, have to cast is as an integer.
SELECT Location, population, MAX(cast(total_deaths as int)) AS HighestDeathCount,
MAX(ROUND((( total_deaths / population)* 100),2)) AS DeathPercentage_of_population
FROM COVIDPortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY HighestDeathCount desc

-- Now let's check with continents instead of countries

-- Showing the continents with the highest death counts

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM COVIDPortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

-- Global Numbers to date

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, ROUND((SUM(cast(new_deaths as int))/SUM(new_cases))*100, 2) as DeathPercentage
FROM COVIDPortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Global Numbers per day

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, ROUND((SUM(cast(new_deaths as int))/SUM(new_cases))*100, 2) as DeathPercentage
FROM COVIDPortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

-- JOINING death and vaccination tables
SELECT *
FROM COVIDPortfolioProject..CovidDeaths AS CovidDeaths
JOIN COVIDPortfolioProject..CovidVaccinations AS CovidVaccination ON
	CovidDeaths.location = CovidVaccination.location
	and CovidDeaths.date = CovidVaccination.date

-- Looking at Total population vs vaccinations per day
SELECT CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccination.new_vaccinations
FROM COVIDPortfolioProject..CovidDeaths AS CovidDeaths
JOIN COVIDPortfolioProject..CovidVaccinations AS CovidVaccination ON
	CovidDeaths.location = CovidVaccination.location
	and CovidDeaths.date = CovidVaccination.date
WHERE CovidDeaths.continent is not null
ORDER BY 2,3

-- Looking at Total population vs vaccinations per day using common table expression (CTE) 
WITH POPvsVAC (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccination.new_vaccinations
, SUM(CONVERT(bigint, CovidVaccination.new_vaccinations)) OVER (Partition by CovidDeaths.Location ORDER 
BY CovidDeaths.location, CovidDeaths.date) AS RollingPeopleVaccinated
FROM COVIDPortfolioProject..CovidDeaths AS CovidDeaths
JOIN COVIDPortfolioProject..CovidVaccinations AS CovidVaccination ON
	CovidDeaths.location = CovidVaccination.location
	and CovidDeaths.date = CovidVaccination.date
WHERE CovidDeaths.continent is not null
)

SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentPopulationVaccinated
FROM POPvsVAC

-- Temp table
Drop Table if exists #PercentPopulationVaccinated -- add this query if you want to make changes to your table
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert into #PercentPopulationVaccinated
SELECT CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccination.new_vaccinations
, SUM(CONVERT(bigint, CovidVaccination.new_vaccinations)) OVER (Partition by CovidDeaths.Location ORDER 
BY CovidDeaths.location, CovidDeaths.date) AS RollingPeopleVaccinated
FROM COVIDPortfolioProject..CovidDeaths AS CovidDeaths
JOIN COVIDPortfolioProject..CovidVaccinations AS CovidVaccination ON
	CovidDeaths.location = CovidVaccination.location
	and CovidDeaths.date = CovidVaccination.date
WHERE CovidDeaths.continent is not null

SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentPopulationVaccinated
FROM #PercentPopulationVaccinated

-- Creating view to store data for later visualizations 
Create View PercentPopulationVaccinated AS
SELECT CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccination.new_vaccinations
, SUM(CONVERT(bigint, CovidVaccination.new_vaccinations)) OVER (Partition by CovidDeaths.Location ORDER 
BY CovidDeaths.location, CovidDeaths.date) AS RollingPeopleVaccinated
FROM COVIDPortfolioProject..CovidDeaths AS CovidDeaths
JOIN COVIDPortfolioProject..CovidVaccinations AS CovidVaccination ON
	CovidDeaths.location = CovidVaccination.location
	and CovidDeaths.date = CovidVaccination.date
WHERE CovidDeaths.continent is not null

Select *
FROM PercentPopulationVaccinated
