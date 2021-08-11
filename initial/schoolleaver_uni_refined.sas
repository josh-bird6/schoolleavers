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
/*********************
Preparing for merge
*********************/
data ay_201819_uni;
set HESA_merged_names_1819;
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

proc sort data= ay_201819_uni
out = ay_201819_uni;
by scno identifier;
run;

data schoolleaver_tomerge;
set work.impw971;
if academic_year="2017/18";
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

proc sort data= schoolleaver_tomerge
out =schoolleaver_tomerge;
by  scno identifier;
run;
/*************
*************
*************
*************
*************/
data schoolleaver_unimerged;
merge ay_201819_uni(in=a) schoolleaver_tomerge (in=b);
by scno identifier;
if a ;
if schoolleaver ne 1 then schoolleaver = 0;
run; 

/*************
*************
*************
*************
*************/
proc sort data = schoolleaver_unimerged
out = schoolleaver_unimerged;
by ukprn_school;
run;

proc sort data = work.impw7425
out = ukprn_tomerge_1819;
by ukprn_school;

run;

data hesa_schoolleavers;
merge schoolleaver_unimerged (in=a) ukprn_tomerge_1819(in=b);
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
/*********************88
FILTERING FOR LA SCHOOL LEAVERS*/
data hesa_schoolleavers_LA;
set hesa_schoolleavers;
if schoolleaver=1;
run;
/*********INDEPENDENTS************************/
data hesa_schoolleavers_ind;
set hesa_schoolleavers;

if schoolleaver = 0;
if dateob >='01OCT1999'd;
if xdomhm01 =2;

if yearprg = 1;
if school_type = "Independent";

schoolleaver = 1;

drop school_name;

head=1;

run;
/*OLD DO NOT USE*/
data schoolleavers_FINALDATASET_1819;
set hesa_schoolleavers_LA hesa_schoolleavers_ind;
run;
/*OLD DO NOT USE*/


/*************
*************
*************
*************
************
data proc sort data= pmaupdat.postall1819_scno 
out = ay_201819_college;
by scno;
run;

data schoolleaver_collegemerged;
merge ay_201819_college(in=a) schoolleaver_tomerge (in=b);
by scno;
if a;
run; 

proc sort data = schoolleaver_collegemerged nodupkey 
out = schoolleaver_college_NODUP;
by scno;
run;*/

data youngsters;
set hindstu.ay1819cor;
if yearprg = 1;
cutoff = '01AUG2018'd;
days = cutoff - birthdte;
age=floor(days/365);
if age<19;
if xdomhm01=2;
ukprn_school = previnst;

run;



proc sort data= youngsters out = youngsters;
by ukprn_school;
run;

proc sort data = work.impw7425
out = ukprn_tomerge_1819;
by ukprn_school;

run;

data youngsters_MERGED;
merge youngsters (in=a) ukprn_tomerge_1819;
by ukprn_school ;
if a;

if previnst = "4901" then school_type_v2 = "Local Authority";
else if previnst = "4911" then school_type_v2 = "Independent";
else if previnst = "4921" then school_type_v2 = "FE college";
else if previnst = "4931" then school_type_v2 = "Non-UK provider";
else if previnst = "4941" then school_type_v2 = "HE provider";
else if previnst = "4951" then school_type_v2 = "Other training provider";
else if previnst = "9999" then school_type_v2 = "Unknown";

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
