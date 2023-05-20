/*
Covid-19 data EDA

Skills used: CTE, Joins, Aggregate Functions, Creating Views

*/
SELECT *
FROM [Portfolio Projects]..[Covid-19 Deaths]
ORDER BY 3,
         4 
		 
-- Selecting Location, Date, Total_Casese, New_Cases, Total_Deaths, Population

SELECT location, date, new_cases,
                       total_cases_per_million,
                       total_deaths,
                       population
FROM [Covid-19 Deaths]
ORDER BY 1,
         2 
		 
-- Lets look at Total Cases and Deaths (The likelihood of dying from Covid in Nigeria)

SELECT location, date, total_cases_per_million,
                       total_deaths,
                       (total_deaths/total_cases_per_million)*100 AS DeathPercentage
FROM [Covid-19 Deaths]
WHERE location LIKE '%Nigeria%'
ORDER BY 1,
         2 
		 
-- Total Cases vs Population
-- This query shows what percentage of population has Covid

SELECT location, date, population,
                       total_cases_per_million,
                       (total_cases_per_million/population)*100 AS InfectionPercentage
FROM [Covid-19 Deaths]
ORDER BY 1,
         2 
		 
-- Next we will look at Countries with the Highest Infection Rate compared to the population size

SELECT location,
       population,
       MAX(total_cases_per_million) AS HighestInfectionCount,
       MAX((total_cases_per_million/population))*100 AS PercentPopulationInfected
FROM [Covid-19 Deaths]
GROUP BY LOCATION,
         population
ORDER BY PercentPopulationInfected DESC 

-- Countries with the Highest Death Count per Population

SELECT location,
       MAX(total_deaths) AS TotalDeathCount
FROM [Covid-19 Deaths]
WHERE continent IS NOT NULL
GROUP BY LOCATION
ORDER BY TotalDeathCount DESC 


-- WE WILL LOOK AT THINGS ON THE CONTINENT LEVEL


-- This query shows the continent with the Highest Death Count

SELECT continent,
       MAX(total_deaths) AS TotalDeathCount
FROM [Covid-19 Deaths]
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC 

-- Death Rates By Total Reported Cases (By Continent)

SELECT continent,
       MAX(total_cases_per_million) AS TotalCases,
       MAX((total_deaths/total_cases_per_million))*100 AS DeathsFromCases
FROM [Covid-19 Deaths]
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 3 DESC 

-- What is the likehood of dying from a Covid infection (by Continent)?

SELECT continent,
       MAX((total_deaths/total_cases_per_million))*100 AS DeathPercentage
FROM [Covid-19 Deaths]
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY DeathPercentage DESC 

-- Which Continent has the Highest Infection Rate?

SELECT continent,
       MAX(population) AS TotalPopulation,
       MAX(total_cases_per_million) AS HighestInfectionCount,
       MAX((total_cases_per_million/population))*100 AS PercentPopulationInfected
FROM [Covid-19 Deaths]
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY PercentPopulationInfected DESC 


--GLOBAL NUMBERS


-- This query shows Daily Total Global cases and Total Global Deaths, and the Death Rates

SELECT date, SUM(new_cases) AS TotalCases,
             SUM(new_deaths) AS TotalDeaths,
             (SUM(new_deaths)/SUM(new_cases))*100 AS GlobalDeathPercentage
FROM [Covid-19 Deaths]
WHERE continent IS NOT NULL
GROUP BY date
HAVING SUM(new_cases) > 0
AND SUM(new_deaths) > 0
ORDER BY 1 ASC,
         2 DESC 
		 
-- We are going to look at the total Population and Vaccination numbers

SELECT Dea.continent,
       Dea.location,
       Dea.date,
       Dea.population,
       Vac.new_vaccinations,
       SUM(new_vaccinations) OVER (PARTITION BY Dea.location
                                   ORDER BY Dea.location,
                                            Dea.date) AS RollingSumPeopleVaccinated
FROM [Covid-19 Deaths] Dea
JOIN [Covid-19 Vaccinations] Vac ON Dea.location = Vac.location
AND Dea.date = Vac.date
WHERE Dea.continent IS NOT NULL
ORDER BY 1,
         2,
         3 
		 
-- Ratio of Total Vaccinated People to the Total Population

 WITH PopulationVac_CTE (Continent, location, Date, Population, New_Vaccinations, RollingSumPeopleVaccinated) AS
  (SELECT Dea.continent,
          Dea.location,
          Dea.date,
          Dea.population,
          Vac.new_vaccinations,
          SUM(new_vaccinations) OVER (PARTITION BY Dea.location
                                      ORDER BY Dea.location,
                                               Dea.date) AS RollingSumPeopleVaccinated
   FROM [Covid-19 Deaths] Dea
   JOIN [Covid-19 Vaccinations] Vac ON Dea.location = Vac.location
   AND Dea.date = Vac.date
   WHERE Dea.continent IS NOT NULL 
   -- ORDER BY 1, 2, 3
)
SELECT *,
       (RollingSumPeopleVaccinated/Population)*100 AS PercentOfVaccinatedPopulation
FROM PopulationVac_CTE 

-- Creating View for later Visualization

CREATE VIEW PercentOfPopulationVaccinated AS
SELECT Dea.continent,
       Dea.location,
       Dea.date,
       Dea.population,
       Vac.new_vaccinations,
       SUM(new_vaccinations) OVER (PARTITION BY Dea.location
                                   ORDER BY Dea.location,
                                            Dea.date) AS RollingSumPeopleVaccinated
FROM [Covid-19 Deaths] Dea
JOIN [Covid-19 Vaccinations] Vac ON Dea.location = Vac.location
AND Dea.date = Vac.date
WHERE Dea.continent IS NOT NULL 
-- ORDER BY 1, 2, 3