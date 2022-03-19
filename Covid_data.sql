-- Covid deaths data.
select * 
from projectportfolio..CovidDeaths 
where continent is not null
order by 3,4;

-- Covid vaccinations data.
select * 
from projectportfolio..CovidVaccinations 
order by 3,4;

-- Selecting the data using for further queries.
select location, date, total_cases, new_cases, total_deaths, population
from projectportfolio..CovidDeaths 
order by 1,2;

-- Total new cases vs total deaths to show likelihood of dying if afected with covid by country.
select location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 as death_percentage
from projectportfolio..CovidDeaths 
where continent is not null
order by 1,2;

-- Total cases vs populations. shows that percentage of population affected by covid.
select location, date, total_cases, population, (total_cases/population)* 100 as populationinfected
from projectportfolio..CovidDeaths 
where continent is not null
order by 1,2;

-- Countries with highest infection rate compared to population.
select location, population, max(total_cases) as highestinfectioncount, max((total_cases/population))* 100 as populationinfected
from projectportfolio..CovidDeaths 
where continent is not null
group by location, population
order by populationinfected desc;

-- Countries with highest death count per population
select location, max(cast(total_deaths as int)) as totaldeathcount
from projectportfolio..CovidDeaths 
where continent is not null
group by location
order by totaldeathcount desc;

-- Countries with highest death count per population by continent
select continent, max(cast(total_deaths as int)) as totaldeathcount
from projectportfolio..CovidDeaths 
where continent is not null
group by continent
order by totaldeathcount desc;

-- Global Numbers data.
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as totaldeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
from projectportfolio..CovidDeaths 
where continent is not null
group by date
order by death_percentage desc;

-- Total population vs vaccination
with popvsvac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinations)
as 
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location, dea.date) as rollingpeoplevaccinations
from projectportfolio..CovidDeaths dea
join projectportfolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null)
select *, (rollingpeoplevaccinations/population)*100 as percentagerollingpeoplevaccinations
from popvsvac
 
-- Temp table for visualisation

drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(continent nvarchar(255),
location nvarchar(225),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinations numeric)


insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location, dea.date) as rollingpeoplevaccinations
from projectportfolio..CovidDeaths dea
join projectportfolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
select *, (rollingpeoplevaccinations/population)*100 percentpopulationvaccinated
from #percentpopulationvaccinated

-- View for further visualisation.
create view Percentpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location, dea.date) as rollingpeoplevaccinations
from projectportfolio..CovidDeaths dea
join projectportfolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null;

-- Data for further visualisation.
select *
from Percentpopulationvaccinated


Tableau dashboard link- 
https://public.tableau.com/views/Covid_data_dashboard/Dashboard1?:language=en-US&publish=yes&:display_count=n&:origin=viz_share_link
