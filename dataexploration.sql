SELECT * FROM ProjectPortfolio..CovidDeaths
WHERE continent is NOT NULL --To avoid continent names in location and just keep it in continent
ORDER BY 3,4

--SELECT * FROM CovidVaccinations
--ORDER BY 3,4

-- Select data which i will use

SELECT continent, location, date, total_cases, new_cases, total_deaths, population
FROM ProjectPortfolio..CovidDeaths
WHERE continent is NOT NULL
ORDER BY 2,3

--looking at total cases vs total deaths
-- shows likelihood of dying if a person has covid in a particular country

SELECT continent, location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS deathpercentagepercase
FROM ProjectPortfolio..CovidDeaths
WHERE location LIKE '%states%' AND continent is NOT NULL
ORDER BY 2,3

-- looking at total cases vs population
-- shows how many people got covid in a population

SELECT continent, location, date, population, total_cases, (total_cases/population)*100 AS covidpercentage
FROM ProjectPortfolio..CovidDeaths
WHERE location LIKE '%states' AND continent is NOT NULL
ORDER BY 2,3

-- looking at  countries with higest infected rate compared to population

SELECT continent,location,population, MAX(total_cases) AS HighesInfectedcount, MAX((total_cases/population))*100 AS covidpercentage
FROM ProjectPortfolio..CovidDeaths
WHERE continent is NOT NULL
GROUP BY continent,location,population
ORDER BY covidpercentage DESC

-- Showing countries/continents with highest death count per population

SELECT continent, location, MAX(cast(total_deaths as int)) AS Highesdeathcount
FROM ProjectPortfolio..CovidDeaths
WHERE continent is NOT NULL
GROUP BY continent, location
ORDER BY Highesdeathcount DESC


--SELECT location, MAX(total_deaths) FROM ProjectPortfolio..CovidDeaths
--WHERE location LIKE '%states'
--GROUP BY location

--SELECT location, cast(total_deaths as int) FROM ProjectPortfolio..CovidDeaths
--WHERE location LIKE '%states'
--ORDER BY 2 DESC

--Global no

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS deathpercent
FROM ProjectPortfolio..CovidDeaths
WHERE continent is NOT NULL
--GROUP BY date
--ORDER BY date

--SELECT SUM(total_cases), SUM(cast(total_deaths as int)), SUM(cast(total_deaths as int))/SUM(total_cases)*100 AS deathpercent
--FROM ProjectPortfolio..CovidDeaths
--WHERE continent is NOT NULL

-- total people vaccinated in a population

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS Rollingpeoplevaccinated
--, (Rollingpeoplevaccinated/dea,population)*100 AS Rollingpeoplevaccinatedpercent [use cte]
FROM ProjectPortfolio..CovidDeaths dea
JOIN ProjectPortfolio..CovidVaccinations vac
ON dea.location=vac.location AND dea.date=vac.date
WHERE dea.continent is NOT NULL
ORDER BY 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS Rollingpeoplevaccinated
--, (Rollingpeoplevaccinated/dea,population)*100 AS Rollingpeoplevaccinatedpercent [use cte]
FROM ProjectPortfolio..CovidDeaths dea
JOIN ProjectPortfolio..CovidVaccinations vac
ON dea.location=vac.location AND dea.date=vac.date
WHERE dea.continent is NOT NULL
--ORDER BY 2,3
)

SELECT *, (Rollingpeoplevaccinated/population)*100 AS Rollingpeoplevaccinatedpercent
FROM PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
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
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS Rollingpeoplevaccinated
--, (Rollingpeoplevaccinated/dea,population)*100 AS Rollingpeoplevaccinatedpercent 
FROM ProjectPortfolio..CovidDeaths dea
JOIN ProjectPortfolio..CovidVaccinations vac
ON dea.location=vac.location AND dea.date=vac.date
--WHERE dea.continent is NOT NULL
--ORDER BY 2,3


Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- creating view for visualization

CREATE VIEW Percentpopulationvaccinated AS
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS Rollingpeoplevaccinated
--, (Rollingpeoplevaccinated/dea,population)*100 AS Rollingpeoplevaccinatedpercent 
FROM ProjectPortfolio..CovidDeaths dea
JOIN ProjectPortfolio..CovidVaccinations vac
ON dea.location=vac.location AND dea.date=vac.date
WHERE dea.continent is NOT NULL
--ORDER BY 2,3


Select *
From PercentPopulationVaccinated














































































































































































































































































































































































--GROUP BY location



