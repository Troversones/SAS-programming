/*A munkakönyvtár beállítása. */

libname sz23 "/home/u63247756/cs2023" ;

/** Import an XLSX file.  **/

PROC IMPORT DATAFILE="/home/u63247756/cs2023/keksz.xlsx"
		    OUT=sz23.kek
		    DBMS=XLSX
		    REPLACE;
RUN;

/** Print the results. **/

PROC PRINT DATA=sz23.kek; RUN;

proc contents DATA=sz23.kek; RUN;

data sz23.kekjo (keep = sorrend kateg
 Hajonev YS Befut futott korrig) ;
 rename b=kateg ;
 rename Befutasi_ido_oo_pp_ss=Befut ;
 rename Futott_ido_sec=futott ;
 rename Korrigalt_ido_sec=korrig ;
 set sz23.kek ;
 sorrend=_N_ ;
  if _N_ le 524 then output ;
 run ;
 proc means data=sz23.kekjo ;
 run ;
 proc univariate data=sz23.kekjo ;
 histogram ;
 run ;
 
 /*  Karakteres változók numerikussá konvertálása  */
 data sz23.kekjo ;
 set sz23.kekjo ;
 futottnum=input(futott,8.);
 korrignum=input(korrig,8.);
 run ;
 /* Gyakoriság tábla a YS változóra*/
 proc sort data=sz23.kekjo ;
 by ys ;
 run ;
 proc freq data=sz23.kekjo ;
 by ys ;
 run ;
 

title 'A hajók teljesítményeinek korrelációja';

proc corr data=sz23.kekjo ;
 run ;
 
 
 proc sort data=sz23.kekjo ;
 by futott ;
 run ;
 /* A kategória változó eloszlása táblázatosan*/
 proc sort data=sz23.kekjo out=rendezett;
 by kateg;
run;
proc freq data=rendezett;
 tables kateg / out=gy;
run;
/* Ugyanez grafikonon ábrázolva */
proc gchart data=gy;
   vbar kateg / sumvar=count ;
run;
quit; 
/* új változók képzése, függvények elágazások 
és aritmetikai utasítások*/
proc sort data=sz23.kekjo ;
by sorrend ;
run ;

data sz23.kek2 ;
set sz23.kekjo ;
ora=substr(Befut,1,2) ; kora=1*ora ;
perc=substr(Befut,4,2) ; 
mp=substr(Befut,7,2) ; 
if _N_ lt 5 then do ;
            ido= 3600*(ora-9)+60*perc+mp ;
            kora=kora-9 ;
            	 end ;
			else do ;
			ido= 15*3600 +3600*ora+60*perc+mp ;
			kora=kora+15 ;
				 end ;
korrigalt=ido*100/ys ;
run ;
/* A hajók szépválasztása sebességük szerint
külön adatállományokba*/
data sz23.gyors sz23.kozep sz23.lassu ;
set sz23.kek2 ;
select ;
 when  (ys < 91 ) output sz23.gyors ;
 when  ( ys < 110 ) output sz23.kozep ;
 otherwise output sz23.lassu ;
end ;
run ;
/* A sebességkategóriánkénti eloszlások*/
proc univariate data=sz23.gyors ;
histogram ys ;
run ;
proc univariate data=sz23.kozep ;
histogram ys ;
run ;
proc univariate data=sz23.lassu ;
histogram ys ;
run ;

/*Készítsünk statisztikai táblákat!*/
proc tabulate data=sz23.kek2 ;
class ys ;
var  ido ;
table ys ;
run ;
proc tabulate data=sz23.kek2 ;
class ys ;
var  kora ido ;
table ys, ido*n kora*mean ido*mean ;
run ;
/* Három dimenziós tábla */
proc tabulate data=sz23.kek2 ;
class ys kateg ;
var  kora ido ;
table kateg, ys, ido*n kora*mean ido*mean ;
run ;
/* vissza a két dimenzióba */
proc tabulate data=sz23.kek2 ;
class ys kateg ;
var  kora ido ;
table (kateg all = "összesen") * (ys all = "összesen"), ido*n kora*mean ido*mean ;
run ;