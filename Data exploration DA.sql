use world_layoffs;

select * from layoffs_staging;



with CTE_Top_countrLO as
(select country, industry,company, sum(percentage_laid_off), sum(total_laid_off) from layoffs_staging
group by country, industry, company
order by 5 DESC)

select country, count(*) from CTE_Top_countrLO
group by country
order by 2 desc;

 -- the country that has the most number of companies by sum of total_laid_off is USA



-- the total number of layoffs, and how does it vary across industries and countries when considering both the total layoffs and the percentage laid off?

select country, industry, count(company) as companies_per_country_industry_company,
sum(total_laid_off), avg(percentage_laid_off)
from layoffs_staging LS1
group by country, industry
order by Country;

select industry, variance(total_laid_off) as industry_variance from layoffs_staging
where industry is not null and total_laid_off is not null
group  by industry
order by industry_variance desc;

-- there is very high variance between the industries laying off


-- What is the total number of layoffs per industry?
select industry, sum(total_laid_off) from  layoffs_staging
group by industry;

-- Which company had the highest number of layoffs in the dataset?

select company, max(total_laid_off) from layoffs_staging
group by company
order by company asc;

-- What is the average number of layoffs per company within each industry?
select industry, company, avg(total_laid_off) from layoffs_staging
group by company,industry
order by industry, company;

-- How many layoffs occurred in each month, by industry?

select industry,monthname(date) as Month_name, sum(total_laid_off) from layoffs_staging
group by industry,Month_name
order by industry, month_name;


select company, sum(total_laid_off) as total_laid_off_by_company from layoffs_staging 
group by company
having total_laid_off_by_company is not null
order by total_laid_off_by_company asc
limit 5;

-- What is the trend of layoffs over the years?
select year(date) as laidOffPerYear, sum(total_laid_off), concat((100/sum(total_laid_off))- (100/LAG(sum(total_laid_off)) over (order by year(date))) ,'%') as trendByPercentage  from layoffs_staging 
group by laidOffPerYear
order by laidOffPerYear asc;

-- What is the average number of layoffs per company, and which companies exceed the average?

with CTE_SUPAVG_COMPANY as
(select company, avg(total_laid_off) as avg_totalLaidOff from layoffs_staging
group by company)
select CTE.company, LS1.total_laid_off, CTE.avg_totalLaidOff from CTE_SUPAVG_COMPANY CTE, layoffs_staging LS1
where LS1.company=CTE.company and LS1.total_laid_off>CTE.avg_totalLaidOff
order by LS1.company
