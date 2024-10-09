select * from layoffs;


-- 1. Remove duplicates

create table layoffs_staging LIKE layoffs;


insert into layoffs_staging
select * from layoffs;

select count(*) from layoffs_staging;
 
 
 CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

insert into layoffs_staging2
SELECT *, ROW_NUMBER() OVER( PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, 
country, funds_raised_millions) as row_num from layoffs_staging;

drop table layoffs_staging;
create table layoffs_staging like layoffs_staging2;
insert into layoffs_staging
select * from layoffs_staging2 where row_num=1;



-- 2. Standardize the data
Update  layoffs_staging
SET company= TRIM(company);

Update layoffs_staging
SET industry='Crypto'
where industry Like 'Crypto%';

Update layoffs_staging
SET country='United states'
where country Like 'United States%';

 select date, str_to_date(`date`, '%m/%d/%Y') from layoffs_staging;
 
 -- Updating the date text to meet the normal presentation of dates
 alter table layoffs_staging
 modify column `date` date;
 
 
 update layoffs_staging
 set `date`= str_to_date(`date`, '%m/%d/%Y');
 
 -- 3. Null values or blank values
 
 update layoffs_staging ls1, layoffs_staging ls2
 set ls1.industry= ls2.industry
where ls1.company like ls2.company and (ls1.industry is null) and ls2.industry is not null and ls2.industry not like '';
 
select * from layoffs_staging where company like 'Bally%'
select * from layoffs_staging
order by company
 
-- 4.  Remove any columns
 
DELETE from layoffs_staging where total_laid_off is null and percentage_laid_off is null

select * from layoffs_staging
Alter table layoffs_staging
drop column row_num

drop table layoffs_staging2