select *
from covidportfolio..covidDeaths
where continent is not null
order by 3,4

--Select *
--from covidportfolio..covidVaccinations

Select location, date, total_cases, new_cases, total_deaths, population
from covidportfolio..covidDeaths
where continent is not null
order by 1,2

--working total cases vs total death


Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercent
from covidportfolio..covidDeaths
where location like '%states%' and continent is not null
order by 1,2

--percentage of population has got covid
Select location, date, population,total_cases, (total_cases/population)*100 as covidPercent
from covidportfolio..covidDeaths
where location like '%states%' AND continent is not null
order by 1,2

-- percentage of people who got the highest covid rate
Select location, population,MAX(total_cases) as Infectioncount, MAX(total_cases/population)*100 as covidPercent
from covidportfolio..covidDeaths
GROUP by location, population
--where location like '%states%'
order by covidPercent desc

----countries with highest deathrate

Select location,MAX(total_deaths) as deathcount
from covidportfolio..covidDeaths
where continent is not null
GROUP by location
order by deathcount desc

---filtering by continent

Select continent,MAX(total_deaths) as deathcount
from covidportfolio..covidDeaths
where continent is not null
GROUP by continent
order by deathcount desc

--global numbers
select  SUM(new_cases) as newcases, SUM(new_deaths) as newdeaths,
sum(new_deaths)/sum(new_cases)*100 as Deathpercentage
from covidportfolio..covidDeaths
where continent is not null
order by 1,2


-- total population vs vaccination

select dea.continent, dea.location, dea.date, population,
vac.new_vaccinations, 
SUM(convert(bigint,new_vaccinations)) OVER (PARTITION by dea.location order by dea.location, dea.date) as Rolling
from covidportfolio..covidDeaths dea
join covidportfolio..covidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


----with CTE
with popvsvac(continent,location,date,population,new_vaccination, Rolling)
as
(
select dea.continent, dea.location, dea.date, population,
vac.new_vaccinations, 
SUM(convert(bigint,new_vaccinations)) OVER (PARTITION by dea.location order by dea.location, dea.date) as Rolling
from covidportfolio..covidDeaths dea
join covidportfolio..covidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3 can't use order by for cte
)
select *, (Rolling/population)*100
from popvsvac

---with temp tables
DROP TABLE if exists #tempvaccinatedrolling
create table #tempvaccinatedrolling
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population float,
new_vaccinations nvarchar(255),
Rolling numeric
)


insert into #tempvaccinatedrolling
select dea.continent, dea.location, dea.date, population,
vac.new_vaccinations, 
SUM(convert(bigint,new_vaccinations)) OVER (PARTITION by dea.location order by dea.location, dea.date) as Rolling
from covidportfolio..covidDeaths dea
join covidportfolio..covidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *, (Rolling/population)*100
from #tempvaccinatedrolling


--creating view to show data for visualization

create view populationpercentvaccinated as
select dea.continent, dea.location, dea.date, population,
vac.new_vaccinations, 
SUM(convert(bigint,new_vaccinations)) OVER (PARTITION by dea.location order by dea.location, dea.date) as Rolling
from covidportfolio..covidDeaths dea
join covidportfolio..covidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *
from populationpercentvaccinated


