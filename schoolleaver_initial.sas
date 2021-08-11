/*********************
Bringing in names from hesasr directory
*********************/
PROC SORT DATA=hesasr18.names (KEEP=husid ukprn fnames surname)   
OUT=work.names_1819;   
BY ukprn husid ;  
RUN;

PROC SORT DATA=hindstu.ay1819cor
OUT=work.ay_1819;  
BY ukprn husid  ; 
RUN;
DATA HESA_merged_names_1819 ;
MERGE work.ay_1819 (IN=ay)work.names_1819;
BY ukprn husid; IF (ay); 
RUN;
/***************************
Preparing HESA and school leaver datasets for matching
**************************/
data uni_matching_1819;
set HESA_merged_names_1819;

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

data schoolleavers_tomerge_unis_1819;
set work.impw8118;
if academic_year = "2017/18";
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

proc sort data=uni_matching_1819 out = uni_matching_1819;
by identifier;
run;

proc sort data=schoolleavers_tomerge_unis_1819 out = schoolleavers_tomerge_unis_1819;
by identifier;
run;
/****************
Merging
****************/
data HESA_schoolleavers_1819;
merge uni_matching_1819 schoolleavers_tomerge_unis_1819;
by identifier;

if courseaim ne "";

if schoolleaver ne 1 then schoolleaver = 0;

if comdate >='01AUG2018'd;
if xdomhm01 = 2;
if xlev501 = 3;

drop Gender name initx identifier academic_year Forename;

ukprn_school = previnst;

run;
/********************
Bringing in Schoolz UKPRN data
********************/

proc sort data = work.hesa_schoolleavers_1819
out = work.hesa_schoolleavers_1819;
by ukprn_school;
run;

proc sort data = work.impw3715
out = ukprn_tomerge_1819;
by ukprn_school;

run;

data hesa_schoolleavers_FINAL_1819;
merge hesa_schoolleavers_1819 (in=a) ukprn_tomerge_1819 (in=b);
by ukprn_school;

if a;

if previnst = "4901" then school_type = "Local Authority";
else if previnst = "4911" then school_type = "Independent";
else if previnst = "4921" then school_type = "FE college";
else if previnst = "4931" then school_type = "Non-UK provider";
else if previnst = "4941" then school_type = "HE provider";
else if previnst = "4951" then school_type = "Other training provider";
else if previnst = "9999" then school_type = "Unknown";

if previnst = "10000050"  then do; school_name = "ABERDEEN SKILLS AND ENTERPRISE TRAINING LTD"; school_type = "FE college"; end;
else if previnst = "10000517"  then do; school_name = "North East Scotland College"; school_type = "FE college"; end;
else if previnst = "10001163"  then do; school_name = "CARDINAL NEWMAN CATHOLIC SCHOOL"; school_type = "Independent"; end;
else if previnst = "10002451"  then do; school_name = "Fife College"; school_type = "FE college"; end;
else if previnst = "10003896"  then do; school_name = "Lews Castle College"; school_type = "FE college"; end;
else if previnst = "10005337"  then do; school_name = "QMU "; school_type = "HE provider"; end;
else if previnst = "10005561"  then do; school_name = "Royal Conservetoire"; school_type = "HE provider"; end;
else if previnst = "10005700"  then do; school_name = "SRUC"; school_type = "HE provider"; end;
else if previnst = "10006207"  then do; school_name = "ST JOSEPH'S COLLEGE"; school_type = "Independent"; end;
else if previnst = "10007114"  then do; school_name = "UHI"; school_type = "HE provider"; end;
else if previnst = "10007762"  then do; school_name = "GCU"; school_type = "HE provider"; end;
else if previnst = "10007772"  then do; school_name = "Napier"; school_type = "HE provider"; end;
else if previnst = "10007773"  then do; school_name = "Open University"; school_type = "HE provider"; end;
else if previnst = "10007794"  then do; school_name = "Glagow Uni"; school_type = "HE provider"; end;
else if previnst = "10007800"  then do; school_name = "UWS"; school_type = "HE provider"; end;
else if previnst = "10007803"  then do; school_name = "St Andrews Uni"; school_type = "HE provider"; end;
else if previnst = "10007804"  then do; school_name = "Stirling Uni"; school_type = "HE provider"; end;
else if previnst = "10007852"  then do; school_name = "Dundee Uni"; school_type = "HE provider"; end;
else if previnst = "10008702"  then do; school_name = "Perth College"; school_type = "FE college"; end;
else if previnst = "10008741"  then do; school_name = "South Lanarkshire College"; school_type = "FE college"; end;
else if previnst = "10009159"  then do; school_name = "NESCol"; school_type = "FE college"; end;
else if previnst = "10009165"  then do; school_name = "Angus College"; school_type = "FE college"; end;
else if previnst = "10009166"  then do; school_name = "GCC"; school_type = "FE college"; end;
else if previnst = "10009170"  then do; school_name = "Ayrshire College"; school_type = "FE college"; end;
else if previnst = "10009177"  then do; school_name = "Borders College"; school_type = "FE college"; end;
else if previnst = "10009186"  then do; school_name = "GCC"; school_type = "FE college"; end;
else if previnst = "10009193"  then do; school_name = "West College Scotland"; school_type = "FE college"; end;
else if previnst = "10009194"  then do; school_name = "New College Lanarkshire"; school_type = "FE college"; end;
else if previnst = "10009205"  then do; school_name = "Dundee and Angus College"; school_type = "FE college"; end;
else if previnst = "10009217"  then do; school_name = "Forth Valley College"; school_type = "FE college"; end;
else if previnst = "10009230"  then do; school_name = "Inverness College"; school_type = "FE college"; end;
else if previnst = "10009237"  then do; school_name = "GCC"; school_type = "FE college"; end;
else if previnst = "10009238"  then do; school_name = "Fife College"; school_type = "FE college"; end;
else if previnst = "10009249"  then do; school_name = "Moray College"; school_type = "FE college"; end;
else if previnst = "10009251"  then do; school_name = "NCL"; school_type = "FE college"; end;
else if previnst = "10009256"  then do; school_name = "GKC"; school_type = "FE college"; end;
else if previnst = "10009281"  then do; school_name = "Edinburgh College"; school_type = "FE college"; end;
else if previnst = "10009291"  then do; school_name = "North Highland College"; school_type = "FE college"; end;
else if previnst = "10009295"  then do; school_name = "West Lothian College"; school_type = "FE college"; end;
else if previnst = "10009991"  then do; school_name = "Opito Ltd"; school_type = "Other training"; end;
else if previnst = "10010115"  then do; school_name = "Ayrshire College"; school_type = "FE college"; end;
else if previnst = "10010151"  then do; school_name = "Wider Access to School Project"; school_type = "Other training"; end;
else if previnst = "10010390"  then do; school_name = "Shetland College"; school_type = "FE college"; end;
else if previnst = "10010606"  then do; school_name = "Edinburgh College"; school_type = "FE college"; end;
else if previnst = "10013132"  then do; school_name = "Argyll College"; school_type = "FE college"; end;
else if previnst = "10013192"  then do; school_name = "City of Glasgow College"; school_type = "FE college"; end;
else if previnst = "10032188"  then do; school_name = "John Taylor High School"; school_type = "Local Authority"; end;
else if previnst = "10037587"  then do; school_name = "Notre Dame High School"; school_type = "Independent"; end;
else if previnst = "10041231"  then do; school_name = "West Highland College"; school_type = "FE college"; end;
else if previnst = "10050208"  then do; school_name = "Buchanan High School"; school_type = "Local Authority"; end;
else if previnst = "10050665"  then do; school_name = "Farr Primary School"; school_type = "Local Authority"; end;
else if previnst = "10052312"  then do; school_name = "St Johns Primary School"; school_type = "Local Authority"; end;


run;
/*****************************************
*****************************************
*************NOW TRYING TO FIND IND. SCHOOL KIDS
*****************************************
*****************************************
*****************************************
*****************************************/

data hesa_schoolleavers_ind_1819;
set hesa_schoolleavers_FINAL_1819;

if schoolleaver = 0;
if school_type = "Independent";
if yearprg = 1;
if dateob >='01AUG1999'd;

schoolleaver = 1;

run;

data schoolleavers_tomerge_1819;
set hesa_schoolleavers_FINAL_1819;
if schoolleaver = 1;
run;

/**************
MERGING THE CONFIRMED SCHOOL LEAVERS WITH IND SCHOOL KIDS
****************/

data schoolleavers_FINALDATASET_1819;
set hesa_schoolleavers_ind_1819 schoolleavers_tomerge_1819;
run;

data schoolleavers_FINALDATASET_1819 ; 
set schoolleavers_FINALDATASET_1819 ; 
length pcode $8. ;

postcode=upcase(postcode);

pcode = compress (postcode) ; 
run; 

data simd; 
set simd.gro19_publiclookup ; 
length pcode $8. ;
pcode = compress (postcode) ;

keep postcode pcode simd16_decile simd16_quintile;

run; 

proc sort data=schoolleavers_FINALDATASET_1819 ; by pcode ; run; 
proc sort data=simd nodupkey; by pcode; run; 

*41918 rows; 

data schoolleavers_FINALDATASETS_1819 ; 
merge schoolleavers_FINALDATASET_1819 (in=a) simd (in=b); 
by pcode ; 
if a ; *left join;  

run; 
