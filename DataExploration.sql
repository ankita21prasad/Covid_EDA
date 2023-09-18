select * from PortfolioProject_CovidAnalysis.CovidDeaths order by 3,4;

-- select * from PortfolioProject_CovidAnalysis.CovidVaccinations order by 3,4;

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject_CovidAnalysis.CovidDeaths
order by 1, 2;

-- Looking at total cases vs total deaths
-- Shows the likelyhood of dying if you contact covid
select location, date, total_cases, total_deaths, total_deaths/total_cases*100 as death_percentage
from PortfolioProject_CovidAnalysis.CovidDeaths
where location like 'india'
order by 1, 2;

-- Looking at total cases vs Population
-- Shows the percentage of population who got covid
select location, date, total_cases, population, total_cases/population*100 as percent_popelation_infected
from PortfolioProject_CovidAnalysis.CovidDeaths
-- where location like 'india'
order by 1, 2;

-- Looking at contries with highest infection rate to population
select location, population, max(total_cases) as highest_infection_count, max(total_cases/population)*100 as percent_popelation_infected
from PortfolioProject_CovidAnalysis.CovidDeaths
group by location, population
order by percent_popelation_infected desc;

-- Showing contries with highest death count per population
select location, max(cast(total_deaths as unsigned)) as highest_death_count
from PortfolioProject_CovidAnalysis.CovidDeaths
group by location
order by highest_death_count desc;

-- Breaking things down by continent
select continent, max(cast(total_deaths as unsigned)) as highest_death_count
from PortfolioProject_CovidAnalysis.CovidDeaths
where continent is not null
group by continent
order by highest_death_count desc;

-- Global numbers 
select  str_to_date(date, "%d/%m/%Y"), sum(total_cases), sum(total_deaths), sum(total_deaths)/sum(total_cases)*100 as death_percentage
from PortfolioProject_CovidAnalysis.CovidDeaths
group by date
order by 1 desc;

select sum(total_cases), sum(total_deaths), sum(total_deaths)/sum(total_cases)*100 as death_percentage
from PortfolioProject_CovidAnalysis.CovidDeaths
order by 1 desc;

update PortfolioProject_CovidAnalysis.CovidVaccinations 
set new_vaccinations = cast(new_vaccinations as unsigned);

-- Loooking at total populatin vs vaccinations
select dea.continent, dea.location, str_to_date(dea.date, "%d/%m/%Y"), dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from PortfolioProject_CovidAnalysis.CovidDeaths as dea
join PortfolioProject_CovidAnalysis.CovidVaccinations as vac
on dea.location = vac.location and dea.date = vac.date
where vac.new_vaccinations > 0
order by 2, 3;


-- Use CTE
with PopvsVac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as
(select dea.continent, dea.location, str_to_date(dea.date, "%d/%m/%Y"), dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from PortfolioProject_CovidAnalysis.CovidDeaths as dea
join PortfolioProject_CovidAnalysis.CovidVaccinations as vac
on dea.location = vac.location and dea.date = vac.date
order by 2, 3)
select *, rolling_people_vaccinated/population*100 from PopvsVac;


-- Temp table
Drop table if exists percentPopulationVaccinated;
create table percentPopulationVaccinated(
continent char(255),
location char(255),
dte date,
population bigint,
new_vaccinations bigint,
rollingPeopleVaccianted bigint
);


insert into percentPopulationVaccinated
select dea.continent, dea.location, str_to_date(dea.date, "%d/%m/%Y"), dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from PortfolioProject_CovidAnalysis.CovidDeaths as dea
join PortfolioProject_CovidAnalysis.CovidVaccinations as vac
on dea.location = vac.location and dea.date = vac.date
where vac.new_vaccinations != '';

-- Creating View to store data for later visualization
Create view PercentPopulatioVaccinated as
select dea.continent, dea.location, str_to_date(dea.date, "%d/%m/%Y"), dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from PortfolioProject_CovidAnalysis.CovidDeaths as dea
join PortfolioProject_CovidAnalysis.CovidVaccinations as vac
on dea.location = vac.location and dea.date = vac.date
order by 2, 3;

select * from PercentPopulatioVaccinated;
