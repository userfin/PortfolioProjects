--select *
--from Covid..CovidDeaths
--order by 3,4

--select *
--from Covid..CovidVaccinations
--order by 3,4

--Select data that will be used
select location, date, total_cases, new_cases, total_deaths, population
from Covid..CovidDeaths
order by 1,2

--Looking at total Cases vs Total Deaths
--Death percentage in country 
select location, date, total_cases, total_deaths, round((total_deaths/total_cases)*100, 3) as death_percent
from Covid..CovidDeaths
where location = 'Switzerland'
order by 1,2

--Total cases vs population
--What percentage got covid
select location, date, total_cases, population, round((total_cases/population)*100, 3) as covid_percent
from Covid..CovidDeaths
where location = 'United States'
order by 1,2

--Countries with highest infection rates
select location, population, max(total_cases) as highest_infected_count, max(round((total_cases/population)*100, 3)) as percent_infected
from Covid..CovidDeaths
where continent is not null
group by location, population
order by percent_infected desc

--Countries with highest death count
select location, max(total_deaths) as total_death_count
from Covid..CovidDeaths
where continent is not null
group by location
order by total_death_count desc


--Total death count by continent
select location, max(total_deaths) as total_death_count
from Covid..CovidDeaths
where continent is null and location not like '%income'
group by location
order by total_death_count desc


-- Total population vs Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(new_vaccinations) over (partition by dea.location order by dea.location, dea.date)
as rolling_vaccinations_count--, (rolling_vaccinations_count/dea.population)*100
from Covid..CovidDeaths dea
join Covid..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--CTE
with PopVsVac (continent, location, date, population, new_vaccinations, rolling_vaccinations_count)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(new_vaccinations) over (partition by dea.location order by dea.location, dea.date)
as rolling_vaccinations_count--, (rolling_vaccinations_count/dea.population)*100
from Covid..CovidDeaths dea
join Covid..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select *, round((rolling_vaccinations_count/population)*100, 3)
from PopVsVac

--TEMP TABLE
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population float,
new_vaccination float,
rolling_vaccinations_count float
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(new_vaccinations) over (partition by dea.location order by dea.location, dea.date)
as rolling_vaccinations_count--, (rolling_vaccinations_count/dea.population)*100
from Covid..CovidDeaths dea
join Covid..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, round((rolling_vaccinations_count/population)*100, 3)
from #PercentPopulationVaccinated



--creating a view to store data for later visualizations
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(new_vaccinations) over (partition by dea.location order by dea.location, dea.date)
as rolling_vaccinations_count--, (rolling_vaccinations_count/dea.population)*100
from Covid..CovidDeaths dea
join Covid..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated