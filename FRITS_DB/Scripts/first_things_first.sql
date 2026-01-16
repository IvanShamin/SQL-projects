-- Exploring the names of table
USE frity; -- Switch to your database
SHOW TABLES; -- Should show frity, oxidy, slozeni

-- Joinig operation of three separate table to have a chemical composition for each frit
select *
from frity f join slozeni s on f.id=s.id_pol 
join oxidy o on s.id_sur = o.id

-- Leaving only neccesarry information for the analysis: name of frit, formula and amount of oxides in composition (%)
select f.nazev as frit_name, 
o.chemvzorec as formula,
s.mnozstvi as amount
from frity f join slozeni s on f.id=s.id_pol 
join oxidy o on s.id_sur = o.id

-- Ranking all oxides in composition of different frits to find the highest amount of oxide in each formula, partitioned by oxide 
select f.nazev as frit_name, 
o.chemvzorec as formula,
s.mnozstvi as amount,
dense_rank()over(partition by o.chemvzorec order by s.mnozstvi desc) as oxide_rank
from frity f join slozeni s on f.id=s.id_pol 
join oxidy o on s.id_sur = o.id

-- Top 5 frits by content of selected oxides
with cte as(select f.nazev as frit_name,
o.chemvzorec as formula,
s.mnozstvi as amount,
rank()over(partition by o.chemvzorec order by s.mnozstvi desc) as oxide_rank
from frity f join slozeni s on f.id=s.id_pol
join oxidy o on s.id_sur = o.id)
select * from cte
where oxide_rank in (1,2,3,4,5)
