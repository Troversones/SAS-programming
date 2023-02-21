/* Adatgeneralas */

data SZAMLA (keep = LEJARAT_DATUM EGYENLEG_OSSZEG DEVIZANEM_KOD TORLESZTESEK_SZAMA TORLESZTES_OSSZEG
                            UGYFEL_KOD TIPUS ALTIPUS SZAMLASZAM THM SZERZODES_OSSZEG INDULAS_DATUM KAMAT
                     index=(SZAMLASZAM));

length SZAMLASZAM $26 UGYFEL_KOD $12 TIPUS $1 ALTIPUS $3 DEVIZANEM_KOD $3;
length INDULAS_DATUM LEJARAT_DATUM EGYENLEG_OSSZEG TORLESZTESEK_SZAMA TORLESZTES_OSSZEG THM KAMAT SZERZODES_OSSZEG 8.;
format LEJARAT_DATUM INDULAS_DATUM yymmdd10.;

do i=1 to 10000;

 INDULAS_DATUM=.; LEJARAT_DATUM=.; EGYENLEG_OSSZEG=.;
 TORLESZTESEK_SZAMA=.; TORLESZTES_OSSZEG=.; THM=.; KAMAT=.; SZERZODES_OSSZEG=.;

 SZAMLASZAM = "12345678-12345678-"||substr(trim(left(100000000+i)),2,8);

 RND=int(ranuni(1)*10000+6);
 UGYFEL_KOD = substr(trim(left(100000000+RND)),2,8);

 if int(i/3)=i/3 then TIPUS="H"; else TIPUS="B";
 if TIPUS="H" then do;
  RND=ranuni(1);
  select;
   when (RND GT 0.4) do; ALTIPUS="LAK"; end;
   when (RND GT 0.1) do; ALTIPUS="SZM"; end;
   when (RND GT 0)   do; ALTIPUS="ARU"; end;
  end;
 end;
 else do;
  RND=ranuni(1);
  select;
   when (RND GT 0.4) do; ALTIPUS="FSZ"; end;
   when (RND GT 0)   do; ALTIPUS="LKB"; end;
  end;
 end;
 
 RND=ranuni(1);
 select;
  when (RND GT 0.4) do; DEVIZANEM_KOD="HUF"; end;
  when (RND GT 0.1) do; DEVIZANEM_KOD="EUR"; end;
  when (RND GT 0)   do; DEVIZANEM_KOD="USD"; end;
 end;

 RND=ranuni(1)*1000;
 INDULAS_DATUM = date() - RND;

 if TIPUS="H" or ALTIPUS="LKB" then do;
  RND=ranuni(1)*1000+30;
  LEJARAT_DATUM = date() + RND;
  LEJARAT_DATUM=mdy(month(LEJARAT_DATUM),1,year(LEJARAT_DATUM));
  if ALTIPUS="LAK" then LEJARAT_DATUM=mdy(month(INDULAS_DATUM),1,year(INDULAS_DATUM)+20);
 end;
 
 if TIPUS="B" then do;
  RND=ranuni(1)*10000000;
  if ALTIPUS="LKB" then do;
   KAMAT=0.08;
   SZERZODES_OSSZEG=int(RND/10000)*10000;
   EGYENLEG_OSSZEG=SZERZODES_OSSZEG*((sum(1+KAMAT/12))**(int((date()-INDULAS_DATUM)/30)));
  end;
  else do;
   KAMAT=0.04;
   RND=ranuni(1)*10000000;
   EGYENLEG_OSSZEG = RND;
  end;
 end;

 if TIPUS="H" then do;
  RND=round((ranuni(1)*1000+500),100)*10000;
  select;
   when (ALTIPUS="LAK") do; THM=0.06; end;
   when (ALTIPUS="SZM") do; THM=0.2 ; RND=RND/10; end;
   when (ALTIPUS="ARU") do; THM=0.3;  RND=RND/100; end;
  end;
  SZERZODES_OSSZEG=RND;
  TORLESZTESEK_SZAMA=INT((LEJARAT_DATUM-INDULAS_DATUM)/30)+1;
  TORLESZTES_OSSZEG = (szerzodes_osszeg*(1/(1+thm/12)-1))/((1/(1+thm/12))**(torlesztesek_szama)-1);
 end;
 
 output;
end;

run;

data UGYFEL (keep= UGYFEL_KOD UGYFEL_SZEGMENS UGYFEL_NEV UGYFEL_LAKHELY UGYFEL_DEFAULT UGYFEL_JOVEDELEM NETTO_ARBEVETEL UGYFEL_MINOSITES);
length UGYFEL_KOD $12 UGYFEL_SZEGMENS $1 UGYFEL_NEV $50 UGYFEL_LAKHELY $15 UGYFEL_DEFAULT $1 UGYFEL_JOVEDELEM 8 NETTO_ARBEVETEL 8 UGYFEL_MINOSITES $1;
do i=1 to 100000;
 UGYFEL_JOVEDELEM=.;NETTO_ARBEVETEL=.;UGYFEL_MINOSITES="";

  UGYFEL_KOD = substr(trim(left(100000000+i)),2,8);
  RND=ranuni(1);
  select;
   when (i=1)        do; UGYFEL_SZEGMENS="A"; end;
   when (i LE 5)     do; UGYFEL_SZEGMENS="B"; end;
   when (RND GT 0.6) do; UGYFEL_SZEGMENS="L"; end;
   when (RND GT 0)   do; UGYFEL_SZEGMENS="V"; end;
  end;
  RND=ranuni(1);
  select;
   when (RND GT 0.6) do; UGYFEL_LAKHELY="Budapest"; end;
   when (RND GT 0.3) do; UGYFEL_LAKHELY="Megyeszekhely"; end;
   when (RND GT 0.2) do; UGYFEL_LAKHELY="Varos"; end;
   when (RND GT 0)   do; UGYFEL_LAKHELY="Egyeb"; end;
  end;
  if UGYFEL_SZEGMENS in ("A" "B") then UGYFEL_LAKHELY="Budapest";

  RND=ranuni(1);
  if UGYFEL_SZEGMENS in ("L" "V") then do;
   select;
    when (RND GT 0.6) do; UGYFEL_NEV="Kovacs"; if UGYFEL_SZEGMENS="V" then UGYFEL_NEV=trim(left(UGYFEL_NEV))||trim(left(i))||" Kft"; end;
    when (RND GT 0.3) do; UGYFEL_NEV="Szabo";  if UGYFEL_SZEGMENS="V" then UGYFEL_NEV=trim(left(UGYFEL_NEV))||trim(left(i))||" Kft"; end;
    when (RND GT 0.2) do; UGYFEL_NEV="Kiss";   if UGYFEL_SZEGMENS="V" then UGYFEL_NEV=trim(left(UGYFEL_NEV))||trim(left(i))||" Kft"; end;
    when (RND GT 0)   do; UGYFEL_NEV="Nagy";   if UGYFEL_SZEGMENS="V" then UGYFEL_NEV=trim(left(UGYFEL_NEV))||trim(left(i))||" Kft"; end;
   end;
  end;
  select;
   when (i=1) do; UGYFEL_NEV="Magyar Allam";   end;
   when (i=2) do; UGYFEL_NEV="OTP";   end;
   when (i=3) do; UGYFEL_NEV="ERSTE"; end;
   when (i=4) do; UGYFEL_NEV="BB";    end;
   when (i=5) do; UGYFEL_NEV="KH";    end;
   otherwise do; end;
  end;

  RND=ranuni(1);
  if UGYFEL_SZEGMENS="V" and RND<0.2 then UGYFEL_DEFAULT="Y"; else UGYFEL_DEFAULT="N";

  RND=round((ranuni(1)*1000+1000),100)*10000;
  if UGYFEL_SZEGMENS="V" then NETTO_ARBEVETEL=RND;
  if UGYFEL_SZEGMENS="L" then UGYFEL_JOVEDELEM=RND/10;

  UGYFEL_MINOSITES="1";
  if UGYFEL_SZEGMENS in ("V" "L") then do;
   RND=ranuni(1);
   select;
    when (RND GT 0.6) do; UGYFEL_MINOSITES="2"; end;
    when (RND GT 0.3) do; UGYFEL_MINOSITES="3"; end;
    when (RND GT 0.2) do; UGYFEL_MINOSITES="4"; end;
    when (RND GT 0)   do; UGYFEL_MINOSITES="5"; end;
   end;
  end;

  output;
end;
run;

data a;
run;

data FEDEZET (keep = FEDEZET_KOD UGYLET_SZAMLASZAM FEDEZET_TIPUS FEDEZET_OSSZEG FEDEZET_DEVIZANEM
                             KIBOCSATO_KOD FEDEZET_INDULAS_DATUM FEDEZET_LEJARAT_DATUM);

length FEDEZET_KOD $8 UGYLET_SZAMLASZAM $26 FEDEZET_TIPUS $8 FEDEZET_OSSZEG 8 FEDEZET_DEVIZANEM $3 KIBOCSATO_KOD $8
       FEDEZET_INDULAS_DATUM 8 FEDEZET_LEJARAT_DATUM 8;
format FEDEZET_LEJARAT_DATUM FEDEZET_INDULAS_DATUM yymmdd10.;

do i = 1 to 10000;
 if int(i/3)=i/3 or (i in (2, 4, 8, 10)) then do;
  UGYLET_SZAMLASZAM = "12345678-12345678-"||substr(trim(left(100000000+i)),2,8);

  szamlaszam=ugylet_szamlaszam;
  set SZAMLA (keep=szamlaszam altipus szerzodes_osszeg devizanem_kod indulas_datum lejarat_datum) key=szamlaszam/unique;
  if _error_ then do; _error_=0; altipus=""; szerzodes_osszeg=.; devizanem_kod=""; indulas_datum=.; lejarat_datum=.; end;

  RND=int(ranuni(1)*5);
  if altipus="LAK" then RND=RND+2;

  do j = 1 to RND;
   KIBOCSATO_KOD="";
   FEDEZET_DEVIZANEM="";
   FEDEZET_TIPUS="";
   FEDEZET_OSSZEG=.;
   FEDEZET_INDULAS_DATUM=.;
   FEDEZET_LEJARAT_DATUM=.;
   FEDEZET_KOD="";

   if altipus="LAK" and j LE 2 then do;
    if j=1 then do;
     FEDEZET_TIPUS="INGATLAN";
     FEDEZET_OSSZEG=SZERZODES_OSSZEG*1.2;
    end;
    if j=2 then do;
     FEDEZET_TIPUS="ALL_GAR";
     FEDEZET_OSSZEG=SZERZODES_OSSZEG*0.1;
     KIBOCSATO_KOD="00000001";
    end;
   end;
   else do;
    RND2=ranuni(1);
    RND3=max(int(ranuni(1)*100000-5),0)+6;
    RND4=max(int(ranuni(1)*5),4)+1;
    select;
     when (RND2 GT 0.6) do; FEDEZET_TIPUS="KEZESSEG"; KIBOCSATO_KOD=substr(trim(left(100000000+RND3)),2,8); end;
     when (RND2 GT 0.3) do; FEDEZET_TIPUS="BANK_GAR"; KIBOCSATO_KOD=substr(trim(left(100000000+RND4)),2,8); end;
     when (RND2 GT 0) do;   FEDEZET_TIPUS="LETET"; end;
    end;
    RND2=ranuni(1);
    FEDEZET_OSSZEG=round(SZERZODES_OSSZEG*RND2,10000);
   end;

   RND2=ranuni(1);
   if RND2 GT 0.20 then do; FEDEZET_DEVIZANEM=DEVIZANEM_KOD; end;
                   else do;
                     RND3=ranuni(1);
                    select;
                     when (RND3 GT 0.4) do; DEVIZANEM_KOD="HUF"; end;
                     when (RND3 GT 0.1) do; DEVIZANEM_KOD="EUR"; end;
                     when (RND3 GT 0)   do; DEVIZANEM_KOD="USD"; end;
                    end;
                   end;
                   if FEDEZET_DEVIZANEM="" then FEDEZET_DEVIZANEM="HUF";

   FEDEZET_INDULAS_DATUM=INDULAS_DATUM;

   if FEDEZET_TIPUS = "ALL_GAR" then do; DEVIZANEM_KOD="HUF"; FEDEZET_LEJARAT_DATUM=LEJARAT_DATUM; end;
   if FEDEZET_TIPUS = "LETET"  then do; RND2=ranuni(1)*1000; FEDEZET_LEJARAT_DATUM = date() + RND2; end;

   if FEDEZET_OSSZEG GT 0 then do;
    k=sum(k,1);
    FEDEZET_KOD=substr(trim(left(100000000+k)),2,8);
    if int(i/90)^=i/90 then output;
   end;
  end;
 end;
end;
run;


data HITEL (drop=i havi);
set SZAMLA (where=(tipus="H"));
 hatralevo_torlesztes=INT((LEJARAT_DATUM - Date())/30)+1 ;
 do i = 1 to hatralevo_torlesztes;
 havi = torlesztes_osszeg/((1+THM/12)**((i-1)));
 EGYENLEG_OSSZEG= sum(egyenleg_osszeg,havi);
 end;
 output;
run;

data ARFOLYAM;
 devizanem_kod = "HUF"; arfolyam = 1; output;
 devizanem_kod = "EUR"; arfolyam = 305; output;
 devizanem_kod = "USD"; arfolyam = 280; output;
run;