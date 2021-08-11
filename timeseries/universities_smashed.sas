PROC SORT DATA=hesasr17.names (KEEP=husid ukprn fnames surname)   
OUT=work.names_1718;   
BY ukprn husid ;  
RUN;

PROC SORT DATA=hindstu.ay1718cor
OUT=work.ay_1718;  
BY ukprn husid  ; 
RUN;
DATA HESA_merged_names_1718 ;
MERGE work.ay_1718 (IN=ay)work.names_1718;
BY ukprn husid; IF (ay); 
RUN;

/************
PREPARING FOR MERGE BY SCNO
*************/
data ay_201718_uni_scno;
set HESA_merged_names_1718;
scno = scn;
ukprn_school = previnst;

length Gender $10.;
if sexid = 1 then Gender = "Male";
else if sexid = 2 then Gender = "Female";
else Gender = "Other";

dateob = birthdte;
format dateob ddmmyy10.;

drop birthdte;

surname = upcase(surname);
fnames=upcase(fnames);

name = soundex(surname);
initx=scan(fnames, 1, ' ');
identifier = trim(initx)||''||trim(name)||trim(Gender)||dateob;

run;

proc sort data= ay_201718_uni_scno
out = ay_201718_uni_scno;
by scno;
run;

data schoolleaver_tomerge_scno1718;
set work.impw5833;
if academic_year="2016/17";
schoolleaver=1;

dateob = DateOfBirth;
format dateob ddmmyy10.;
drop DateOfBirth;

surname = upcase(surname);
Forename = upcase(Forename);

name = soundex(surname);
initx = scan(Forename, 1, ' ');
identifier = trim(initx)||''||trim(name)||trim(Gender)||dateob;
run;

proc sort data= schoolleaver_tomerge_scno1718
out =schoolleaver_tomerge_scno1718;
by  scno ;
run;
/*************
*************
*************
*************
*************/
data SCNO_MATCHES1718;
merge ay_201718_uni_scno(in=a) schoolleaver_tomerge_scno1718 (in=b);
by scno ;
if a ;
if schoolleaver =1;
run; 

/**END OF SCNO***********
*************
*************
*************
*************/
/*************
*************
*************
*************
*************/
/*************
*************
*************
*************
*************/

/************
PREPARING FOR MERGE BY IDENTIFIER
*************/

data ay_201718_uni_identifier;
set HESA_merged_names_1718;
scno = scn;
ukprn_school = previnst;

length Gender $10.;
if sexid = 1 then Gender = "Male";
else if sexid = 2 then Gender = "Female";
else Gender = "Other";

dateob = birthdte;
format dateob ddmmyy10.;

drop birthdte;

surname = upcase(surname);
fnames=upcase(fnames);

name = soundex(surname);
initx=scan(fnames, 1, ' ');
identifier = trim(initx)||''||trim(name)||trim(Gender)||dateob;

run;

proc sort data= ay_201718_uni_identifier
out = ay_201718_uni_identifier;
by identifier;
run;

data schoolleaver_tomerge_id1718;
set work.impw5833;
if academic_year="2016/17";
schoolleaver=1;

dateob = DateOfBirth;
format dateob ddmmyy10.;
drop DateOfBirth;

surname = upcase(surname);
Forename = upcase(Forename);

name = soundex(surname);
initx = scan(Forename, 1, ' ');
identifier = trim(initx)||''||trim(name)||trim(Gender)||dateob;
run;

proc sort data= schoolleaver_tomerge_id1718
out =schoolleaver_tomerge_id1718;
by  identifier ;
run;

data IDENTIFIER_MATCHES1718;
merge ay_201718_uni_identifier(in=a) schoolleaver_tomerge_id1718 (in=b);
by identifier ;
if a ;
if schoolleaver =1;
run; 

/************
SMASHING IT ALL TOGETHER
*************/
data merged1718;
set SCNO_matches1718 IDENTIFIER_matches1718;

head=1;


run;

proc sort data= merged1718 nodupkey out=merged21718;
by scno;
run;

/************
COMBINING WITH INDEPENDENT SCHOOLS - SEE CODE1
*************/
data merged_FINAL1718;
set work.hesa_schoolleavers_ind1718 work.merged21718;

/*keep shefcint studfte control_subj price_group_1_fte price_group_2_fte price_group_3_fte price_group_4_fte price_group_5_fte price_group_6_fte head;*/
match =1;
length pcode $8. ;
pcode = compress (postcode) ; 
run;
/************
BRINGING IN SIMD
*************/


data simd; 
set simd.gro19_publiclookup ; 
length pcode $8. ;
pcode = compress (postcode) ;
run; 

proc sort data=merged_FINAL1718 ; by pcode ; run; 
proc sort data=simd nodupkey; by pcode; run; 

data merged_FINAL_SIMD1718 ; 
merge merged_FINAL1718 (in=a) simd (in=b); 
by pcode ; 
if a ; *left join;  
if school_type ne "Independent" then school_type = "Local Authority";
run; 
