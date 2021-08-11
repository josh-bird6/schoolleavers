/*************************
REPLICATING UNI WRANGLING FOR COLLEGES
*****************************************************/

data schoolleavers_tomerge;
set work.impw6792;
if academic_year = "2017/18";
schoolleaver=1;


dateob = DateOfBirth;
format dateob ddmmyy10.;
Surname = UPCASE(Surname);
Forename = UPCASE(Forename);

name = soundex(surname);
initx=scan(Forename, 1, ' ');
fullname=trim(initx)||''||trim(name)||trim(Surname)||trim(Gender)||dateob;


drop DateOfBirth name initx;

run;


data postall1819;
set pmaupdat.postall1819;

length Gender $20.;
Gender = "N/A";
if genderx=10 then Gender = "Male";
if genderx=11 then Gender = "Female";
name = soundex(surname);
initx=scan(forenames, 1, ' ');
fullname=trim(initx)||''||trim(name)||trim(surname)||trim(Gender)||dateob;
run;
/*************************
mERGING FULLNAME
***************************************************************************************************************************************************/
proc sort data=schoolleavers_tomerge out = schoolleavers_tomerge_fullname;
by  fullname ;
run;
proc sort data=postall1819 nodupkey out = postall1819_fullname;
by  fullname ;
run;

data college_schoolleavers_FULLNAME;
merge postall1819_fullname (in=a) schoolleavers_tomerge_fullname ;
by  fullname ;
if a;
if schoolleaver=1;
/*if mode in (17 18);*/

match =1;

drop Forename Gender;

run;
/****************************************************************************************************************************************************************************
SCNO
*********************************************************************************************************************************************/
proc sort data=schoolleavers_tomerge out = schoolleavers_tomerge_SCNO;
by  scno ;
run;
proc sort data=postall1819 nodupkey out = postall1819_scno;
by  scno ;
run;
data college_schoolleavers_scno;
merge postall1819_scno (in=a) schoolleavers_tomerge_scno ;
by  scno ;
if a;
if schoolleaver=1;
/*if mode in (17 18);*/

match =1;

drop Forename Gender;

run;
/***********************************************************************************************************************
Concatenating the two datasets and removing duplicates
********************************************/
data college_schoolleavers_MERGED;
set college_schoolleavers_FULLNAME college_schoolleavers_scno;

if sclass1 IN  ('PC' 'HK' 'HL') Then subject_1 = 'Hairdressing, Beauty and Complementary Therapies';
 else if sclass1 in ('JA' 'JB'  'JC' 'JD' 'JE' 'JF' 'JG' 'JH' 'JK' 'JL' 'JR' 'KE' 'KH' 'TJ' 'WL') Then subject_1 = 'Art and design';
 else if sclass1 IN  ('AA' 'AB' 'AC' 'AD' 'AE' 'AF' 'AG' 'AJ' 'AK' 'AL' 'AY' 'AZ' 'BA' 'BB' 'BC' 'BD' 'BE' 'BF' 
						'CY' 'CZ' 'EB' 'EC' 'HE' 'VB' 'VC' 'VD' 'AM' 'VH' 'VJ' 'ZM' 'ZN' 'ZP' ) Then subject_1 = 'Business, management and administration';
 else if sclass1 IN ('HF' 'HH' 'PA' 'PH' 'PJ' 'PK' 'PL' 'PM' 'PN' 'PP' 'PQ' 'PR' 'PS' 'PT' 'PV') Then subject_1 = 'Care';
 else if sclass1 IN ('CA' 'CB' 'CC' 'CD' 'CE' 'CH' 'CX' ) Then subject_1 = 'Computing and ICT';
 else if sclass1 IN ('JP' 'QB' 'QD' 'RG' 'TA' 'TC' 'TD' 'TE' 'TF' 'TG' 'TH' 'TK' 'TL' 'TM' 'WK') Then subject_1 = 'Construction';
 else if sclass1 IN ('GA' 'GB' 'GC' 'GD' 'GE' 'GF' 'HC' ) Then subject_1 = 'Education and training';
 else if sclass1 in ('QH' 'QJ' 'VE' 'VF' 'VG' 'WA' 'WB' 'WC' 'WD' 'WE' 'WF' 'WG' 'WH' 'XA' 'XD' 'XE' 'XF' 'XH' 'XJ' 'XK'
						'XL' 'XM' 'XN' 'XP' 'XR' 'XS' 'XT' 'YA' 'YB' 'YC' 'YD' 'YE' 'ZA' 'ZD' 'ZG' 'ZH' 'ZJ' 'ZL' 'ZQ' 'ZR' 'ZT' 'ZV' 'ZX') Then subject_1 = 'Engineering';
 else if sclass1 in ('NA' 'NB' 'NC' 'ND' 'NE' 'NF' 'NG' 'NH' 'NK' 'QE' 'WM' 'ZE' ) Then subject_1 = 'Hospitality and tourism';
 else if sclass1 in ('QA' 'QC' 'QG' 'SA' 'SB' 'SC' 'SD' 'SE' 'SF' 'SG' 'SH' 'SJ' 'SK' 'SL' 'SM' 'SN' 'SP' 'SQ' 'WJ') Then subject_1 = 'Land-based industries';
 else if sclass1 IN  ('FJ' 'FK' 'FN' ) Then subject_1 = 'Languages and ESOL';
 else if sclass1 IN ( 'FC' 'KA' 'KB' 'KC' 'KD' 'KF' 'KG' 'KJ') Then subject_1 = 'Media';
 else if sclass1 IN ( 'XQ' 'ZF' 'ZS') Then subject_1 = 'Nautical studies';
 else if sclass1 IN ('LA' 'LB' 'LC' 'LD' 'LE' 'LF' 'LG' 'LH' 'LJ' 'LK') Then subject_1 = 'Performing arts';
 else if sclass1 IN ('PB' 'PD' 'PE' 'PF' 'PG' 'RA' 'RB' 'RC' 'RD' 'RE' 'RF' 'RH' 'RJ' 'RK') Then subject_1 = 'Science';
 else if sclass1 IN ( 'DA' 'DB' 'DC' 'DD' 'DE' 'DF' 'EA' 'ED' 'EE' 'FB' 'FL' 'FM') Then subject_1= 'Social subjects';
 else if sclass1 IN ('HB' 'HD' 'HG' ) Then subject_1 = 'Special Programmes';
 else if sclass1 IN  ('HJ' 'MA' 'MB' 'MC' 'MD' 'ME' 'MF' 'MG' 'MH' 'MJ' 'NL' 'NM' 'NN'  ) Then subject_1 = 'Sport and Leisure';

run;

proc sort data= college_schoolleavers_MERGED nodupkey out = college_schoolleavers_MERGED2;
by scno;
run;


/***********************************************************************************************************************
TRYING TO FIND STUDENTS FLAGGED AS FE IN SDS BUT NOT APPEARING ON FE COURSE AT COLLEGE for SFC
DO NOT FORGET NODUPKEY on PROC SORT AS ABOVE
********************************************/
proc sort data= college_schoolleavers_MERGED2  out = college_schoolleavers_MERGED2;
by fullname;
run;

data college_schoolleavers_NOMATCH;
merge  schoolleavers_tomerge_fullname(in=a) college_schoolleavers_MERGED2 ;
by  fullname ;
if a;

if match ne 1;



run;
