data schoolleavers_tomerge201819;
set work.impw5952;
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
proc sort data=schoolleavers_tomerge201819 out = schoolleavers_tomerge_fn201819;
by  fullname ;
run;
proc sort data=postall1819 nodupkey out = postall1819_fullname;
by  fullname ;
run;

data college_schoolleavers_FN201819;
merge postall1819_fullname (in=a) schoolleavers_tomerge_fn201819 ;
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
proc sort data=schoolleavers_tomerge201819 out = schoolleavers_tomerge_SCNO201819;
by  scno ;
run;
proc sort data=postall1819 nodupkey out = postall1819_scno;
by  scno ;
run;
data college_schoolleavers_scno201819;
merge postall1819_scno (in=a) schoolleavers_tomerge_scno201819 ;
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
data college_schoolleavers_M201819;
set college_schoolleavers_FN201819 college_schoolleavers_scno201819;

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

 academic_year = "2018-19";

 keep adv college_name college_region cotitle credits credits_fte dateob enrol fordel fullname la_name mode outcome postcode pi_outcome qual sclass1 scno scqf_lev sg_quintile spvp_student stem_subject studcat target_groups academic_year schoolyear Initial_Reported_Destination ModernApprenticeship schoolleaver match subject_1;

run;

proc sort data= college_schoolleavers_M201819 nodupkey out = college_schoolleavers_201819;
by scno;
run;

/***********************************************************************************************************************
NOW MOVING TO PREVIOUS YEAR
********************************************/

data schoolleavers_tomerge201718;
set work.impw5952;
if academic_year = "2016/17";
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


data postall1718;
set pmaupdat.postall1718;

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
proc sort data=schoolleavers_tomerge201718 out = schoolleavers_tomerge_fn201718;
by  fullname ;
run;
proc sort data=postall1718 nodupkey out = postall1718_fullname;
by  fullname ;
run;

data college_schoolleavers_FN201718;
merge postall1718_fullname (in=a) schoolleavers_tomerge_fn201718 ;
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
proc sort data=schoolleavers_tomerge201718 out = schoolleavers_tomerge_SCNO201718;
by  scno ;
run;
proc sort data=postall1718 nodupkey out = postall1718_scno;
by  scno ;
run;
data college_schoolleavers_scno201718;
merge postall1718_scno (in=a) schoolleavers_tomerge_scno201718 ;
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
data college_schoolleavers_M201718;
set college_schoolleavers_FN201718 college_schoolleavers_scno201718;

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

 academic_year = "2017-18";

 keep adv college_name college_region cotitle credits credits_fte dateob enrol fordel la_name mode outcome postcode pi_outcome qual sclass1 scno scqf_lev sg_quintile spvp_student stem_subject studcat target_groups academic_year schoolyear Initial_Reported_Destination ModernApprenticeship schoolleaver match subject_1;

run;

proc sort data= college_schoolleavers_M201718 nodupkey out = college_schoolleavers_201718;
by scno;
run;

/***********************************************************************************************************************
FINALLY, CONCATENATING THE TIME SERIES
********************************************/

data college_schoolleavers_FIN;
set college_schoolleavers_201819 college_schoolleavers_201718;
run;

proc summary data = college_schoolleavers_FIN nway missing;
class academic_year sg_quintile la_name college_name;
var enrol;
output out = table1 (drop = _TYPE_ _FREQ_) sum=;
run;
