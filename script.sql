-- Looking at Total Cases vs Total Deaths
Select Location, date, total_cases, total_deaths, CAST(total_deaths AS float) / CAST(total_cases AS float) * 100 as DeathPercentage
From CovidDeath
WHERE LOCATION LIKE "%states%"
order by 1,2;

-- Looking at Total Cases VS Population
Select Location, date, total_cases, population, CAST(total_cases AS float) / CAST(population AS float) * 100 as CovidPercentage
From CovidDeath
--WHERE LOCATION LIKE "%states%"
order by 1,2;


-- Looking at Countires with Highest Infection Rate compared to Popoluation
Select Location, MAX(total_cases) as HighestInfectionCount, population, Max(CAST(total_cases AS float) / CAST(population AS float)) * 100 as CovidPercentage
From CovidDeath
--WHERE LOCATION LIKE "%states%"
GROUP BY location, population
order by CovidPercentage DESC;

-- Showing Countries with Highest Death Count per Population
Select Location, MAX(total_deaths) as HighestDeathCount, population, Max(CAST(total_deaths AS float) / CAST(population AS float)) * 100 as DeathPercentage
From CovidDeath
--WHERE LOCATION LIKE "%states%"
WHERE continent IS  NOT NULL   
GROUP BY location
order by DeathPercentage DESC;

-- BY CONTINENT
Select continent, MAX(total_deaths) as HighestDeathCount
From CovidDeath
--WHERE LOCATION LIKE "%states%"
WHERE continent IS  NOT NULL   
GROUP BY continent
order by HighestDeathCount DESC;

-- Showing contintents with the higest Death Count per Population
Select continent, MAX(total_deaths) as HighestDeathCount, population, Max(CAST(total_deaths AS float) / CAST(population AS float)) * 100 as DeathPercentage
From CovidDeath
--WHERE LOCATION LIKE "%states%"
WHERE continent IS  NOT NULL   
GROUP BY continent
order by DeathPercentage DESC;


-- GLOBAL NUMBERS
Select SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, CAST(SUM(new_deaths) AS float) / CAST(SUM(new_cases) AS float) * 100 as DeathPercentage
From CovidDeath
--WHERE LOCATION LIKE "%states%"
WHERE continent IS  NOT NULL   
--GROUP By date
order by 1,2;


-- Looking at Total Populatio vs Vaccinations


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition BY dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM CovidDeath dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS  NOT NULL  
ORDER BY 2, 3


-- USE CTE
WITH PopvcVAC (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(vac.new_vaccinations) OVER (Partition BY dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
	FROM CovidDeath dea
	JOIN CovidVaccinations vac
		ON dea.location = vac.location
		and dea.date = vac.date
	WHERE dea.continent IS  NOT NULL  
	ORDER BY 2, 3
)
SELECT *, (cast(RollingPeopleVaccinated as Float)/cast(population as float))*100
FROM PopvcVAC;



--- TEMP TABLE 

DROP TABLE IF exists PercentPopulationVaccinated
CREATE TABLE PercentPopulationVaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,  
	Population numeric,
	Ne w_vaccinations numeric,
	RollingPeopleVaccinated numeric,
	VaccinatedPercentage numeric
);


INSERT INTO PercentPopulationVaccinated(Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition BY dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM CovidDeath dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
	WHERE dea.continent IS  NOT NULL  
ORDER BY 2, 3

SELECT *, (cast(RollingPeopleVaccinated as Float)/cast(population as float))*100 as PercentageVaccinated
FROM PercentPopulationVaccinated;



-- Creating View to store data for later
--DROP TABLE IF exists PercentPopulationVaccinated
Create View PercentPopulationVaccinated as  
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition BY dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM CovidDeath dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS  NOT NULL  
--ORDER BY 2, 3


SELECT * 
FROM PercentPopulationVaccinated
