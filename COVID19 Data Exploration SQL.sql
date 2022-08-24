SELECT * FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population FROM  PortfolioProject.dbo.CovidDeaths
ORDER BY 1,2

--Total cases vs total deaths

SELECT location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM  PortfolioProject.dbo.CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2

SELECT location, date, total_cases, population, (total_Cases/population)*100 AS DeathPercentage
FROM  PortfolioProject.dbo.CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2

--countries w/ highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopInfected
FROM  PortfolioProject.dbo.CovidDeaths
--WHERE location LIKE '%states%'
GROUP BY population, location
ORDER BY PercentPopInfected desc

--countries w/ highest death count per population

SELECT continent, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM  PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc 

--Global numbers

SELECT  SUM(new_cases) AS Total_Cases, SUM(cast(new_deaths AS int)) AS Total_Deaths, SUM(cast(new_deaths AS int))/(SUM(new_cases))*100 AS DeathPercentage
FROM  PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


--total population vs vaccinations

SELECT dea. continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM  PortfolioProject.dbo.CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3 

--CTE 

With PopvsVac (Continent,Location,Date, Population,new_vaccinations, RollingPeopleVaccinated)
as(
SELECT dea. continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM  PortfolioProject.dbo.CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/population)*100 FROM PopvsVac

--TEMP Table

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea. continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM  PortfolioProject.dbo.CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (RollingPeopleVaccinated/population)*100 FROM #PercentPopulationVaccinated

--View

Create View PercentPopulationVaccinated AS 
SELECT dea. continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM  PortfolioProject.dbo.CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null

SELECT * FROM PercentPopulationVaccinated