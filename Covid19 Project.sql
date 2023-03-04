--Exploring data
Select *
From CovidDeaths;

Select *
From CovidVaccinations;


--Select data to work with
Select location, date , total_cases, new_cases, population 
From CovidDeaths


--Looking at total cases vs total deaths to find the percentage
--Show the likelihood you'll get Covid in the United States (Your country)
Select location, date, total_cases, total_deaths , population, (total_deaths*1.0/total_cases)*100 AS DeathPercentage
From CovidDeaths
Where location like '%States%'

--Looking at countries with the highest infection rate
Select location, population, MAX(total_cases*1.0) AS HighestCase,
MAX((total_cases*1.0/population))*100 as PopulationInfected
From CovidDeaths
GROUP BY location, population
Order by PopulationInfected desc;


--Showing countries with highest death
Select location, MAX(total_deaths*1.0) AS DeathCount
From CovidDeaths
Where continent != ''
Group by location
Order by DeathCount desc;


--Looking at continent death count
Select location, MAX(total_deaths*1.0) AS DeathCount
From CovidDeaths
Where continent = ''
Group by continent,location
Order by DeathCount desc;


--Join tables
Select *
From CovidDeaths cd 
Join CovidVaccinations cv 
	On cd.location = cv.location
	and cd.date = cv.date
	
--Looking at when vaccinations is started and where
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations 
From CovidDeaths cd 
Join CovidVaccinations cv 
	On cd.location = cv.location
	and cd.date = cv.date
Where cv.new_vaccinations != '' and cv.new_vaccinations != 0 and cd.continent != ''
Order By cd.date

--Looking at new vaccination in each location over time
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
SUM(cv.new_vaccinations) OVER (Partition By cd.location Order By cd.location, cd.date) AS UpdateVaccinations
From CovidDeaths cd 
Join CovidVaccinations cv 
	On cd.location = cv.location
	and cd.date = cv.date
Where cd.continent != ''
Order By 2,3

--Looking at the percentage of people got vaccinated 
--Create CTE
With VacPer (continent, location, date, population, new_vaccinations, peoplevaccinated)
as
(Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
SUM(cv.new_vaccinations) OVER (Partition By cd.location Order By cd.location, cd.date) AS UpdateVaccinations
From CovidDeaths cd 
Join CovidVaccinations cv 
	On cd.location = cv.location
	and cd.date = cv.date
Where cd.continent != ''
)

Select *, (peoplevaccinated*1.0/population)*100 AS VaccinatedPercentage
From Vacper

--Create Temp Table
Drop Table if exists PercentPopulationVac

Create Table PercentPopulationVac
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population int,
New_vaccinations int,
People_vaccinated numeric
)

Insert into PercentPopulationVac
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(cv.new_vaccinations) OVER (Partition By cd.location Order By cd.location, cd.date) AS UpdateVaccinations
From CovidDeaths cd 
Join CovidVaccinations cv 
	On cd.location = cv.location
	and cd.date = cv.date
Where cd.continent != ''

Select *
From PercentPopulationVac

--Create views for visualizations
Create View PercentPopulationVac1 as
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(cv.new_vaccinations) OVER (Partition By cd.location Order By cd.location, cd.date) AS UpdateVaccinations
From CovidDeaths cd 
Join CovidVaccinations cv 
	On cd.location = cv.location
	and cd.date = cv.date
Where cd.continent != ''

--Vaccinated Percentage View
Create View VaccinatedPercentage as
With VacPer (continent, location, date, population, new_vaccinations, peoplevaccinated)
as
(Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
SUM(cv.new_vaccinations) OVER (Partition By cd.location Order By cd.location, cd.date) AS UpdateVaccinations
From CovidDeaths cd 
Join CovidVaccinations cv 
	On cd.location = cv.location
	and cd.date = cv.date
Where cd.continent != ''
)

Select *, (peoplevaccinated*1.0/population)*100 AS VaccinatedPercentage
From Vacper

---Vaccinations in each location
Create View VaccinationLocation as 
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
SUM(cv.new_vaccinations) OVER (Partition By cd.location Order By cd.location, cd.date) AS UpdateVaccinations
From CovidDeaths cd 
Join CovidVaccinations cv 
	On cd.location = cv.location
	and cd.date = cv.date
Where cd.continent != ''
Order By 2,3

--Countries with highest death view
Create View Highestdeath as
Select location, MAX(total_deaths*1.0) AS DeathCount
From CovidDeaths
Where continent != ''
Group by location
Order by DeathCount desc;

--When vaccinations started and Where
Create View VaccinationsStarted as 
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations 
From CovidDeaths cd 
Join CovidVaccinations cv 
	On cd.location = cv.location
	and cd.date = cv.date
Where cv.new_vaccinations != '' and cv.new_vaccinations != 0 and cd.continent != ''
Order By cd.date

--Highest infection rate
Create View HighestInfection as
Select location, population, MAX(total_cases*1.0) AS HighestCase,
MAX((total_cases*1.0/population))*100 as PopulationInfected
From CovidDeaths
GROUP BY location, population
Order by PopulationInfected desc;