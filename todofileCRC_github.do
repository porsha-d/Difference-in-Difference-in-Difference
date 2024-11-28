/*  Data was obtained from 1997-2012
 Primary Data Cleaning: The variables of interest for some years had different names:

The cleaned dataset got merged with the exel file of table of _states with their treatmentyear (1 to many merge) */


global dir "file location"
capture log close

log using "capture log", replace

capture log close

use "compiled+merged97-2012", clear


destring iyear, replace

replace iyear=1998 if iyear==98
replace iyear=1997 if iyear==97


sort _state

// Recode the 'educa' variable into a new categorical variable 'educacat'
recode educa (1/4=1 "Highschool graduate or less") (5=2 "Some College") (6=3 "College graduate or more") (9=.), generate (educacat)

// Assign a descriptive label to the new variable 'educacat'
label variable educacat "education categories"

//Create a frequency table showing the distribution of the new educacat variable
tab educacat

// Cross-tabulate 'educacat' with the original 'educa' variable to verify the recoding
tab educacat educa

// Recode the 'race' variable into a new categorical variable 'racecat'
recode race (1=1 "White Non-Hispanic") (2=2 "Black Non-Hispanic") (3/4=3 "Hispanic") (5/8=4 "Other races") (99=.) (9=.) , generate (racecat)

// Assign a descriptive label to the new variable 'racecat'
label variable racecat "race categories"

// Cross-tabulate 'racecat' with the original 'race' variable to verify the recoding
tab race racecat

/*Create a frequency table showing the distribution of the new racecat variable*/
tab racecat

// Recode the 'marital' variable into a new categorical variable 'maritalcat'
recode marital (1=1 "Married") (2/6=2 "Non-married") (9=.) , generate (maritalcat)

// Assign a descriptive label to the new variable 'maritalcat'
label variable maritalcat "marital categories"

//Create a frequency table showing the distribution of the new maritalcat variable
tab maritalcat

// Recode the 'income' variable into a new categorical variable 'incomecat'
recode income (1/4=1 "<$10k-$25k") (5/6=2 "$25k-$49.999") (7/8=3 ">$50k") (77=.) (99=.), generate (incomecat)

// Assign a descriptive label to the new variable 'incomecat'
label variable incomecat "income categories"

// Cross-tabulate 'incomecat' with the original 'income' variable to verify the recoding
tab income incomecat

//Create a frequency table showing the distribution of genhlth//
tab genhlth

// Recode the 'genhlth' variable into a new categorical variable 'genhlthcat'
recode genhlth (1/3=1 "Good") (4/5=2 "Poor") (7=.) (9=.), generate (genhlthcat)

// Assign a descriptive label to the new variable 'genhlthcat'
label variable genhlthcat "genhlth categories"

// Create a cross-tabulation of the original variable 'genhlth' and the recoded variable 'genhlthcat'
tab genhlth genhlthcat

//Create a frequency table showing the distribution of new variable genhlthcat/
tab genhlthcat

// Recode the 'sex' variable into a new categorical variable 'sexcat'
recode sex (1=1 "Male") (2=2 "Female") , generate (sexcat)

// Assign a descriptive label to the new variable 'sexcat'
label variable sexcat "sex categories"


//summary of covariates
sum i.incomecat i.genhlthcat i.racecat i.maritalcat i.educacat i.sexcat

/* analytic sample excludes the following: (1) individuals who did not respond to screening questions, (2) uninsured individuals, and (3) individuals age 65 at the time of the survey because the reference period for the retrospective screening questions will include months when ineligible for Medicare */

tab age

/*creating variables for DDD*/

gen age51_64= (age>=51 & age<65)
gen age66_75= (age>=66 & age<76)

tab age66_75

// Generate the'treat' variable and assign it a value of 1 if 'agegroups' equals 51-64//
gen treat=age51_64

tab treat age51_64

// Generate a 'post'  varable indicating if 'iyear' is greater than or equal to 'treatmentyear'//
gen post=(iyear>=treatmentyear)

tab post

// Generate a new variable 'post_x_treat' as the interaction of 'post' and 'treat'
gen post_x_treat=post*treat

//Generate uninsured variable based on healthplan values in (2,7,9, or missing)
gen uninsured= (hlthpln==2 | hlthpln==7 | hlthpln==9 | hlthpln==.)

tab uninsured

// Generate the outcome variable 'blds_last12mo' based on the condition that 'bldst' equals 1 and Replace missing values in 'blds_last12mo' where 'bldst' is missing
gen  blds_last12mo=(bldst==1)
replace  blds_last12mo= . if bldst==7 | bldst==. | bldst==9

tab blds_last12mo

//Displays a frequency table of iyear for observations where blds_last12mo is missing.
tab iyear if blds_last12mo==.

//Displays a frequency table of iyear for observations where blds_last12mo is not missing.
tab iyear if blds_last12mo~=.


//flagging rows where the year (iyear) corresponds to one of the specified values
gen keep_yr=(iyear==1997 |iyear==1999 | iyear==2001 | iyear==2002 | iyear==2004 | iyear==2006 |iyear ==2008| iyear==2010 | iyear==2012)

tab keep_yr
sum keep_yr

//flag rows where treat variable is 1 or age is 66-75
gen keep_age=(treat==1|age66_75==1)

//A frequency table of iyear, but only for rows where: blds_last12m is not missing. keep_yr is 1 (indicating a flagged year). keep_age is 1 (indicating the row meets the conditions for age or treatment).
tab iyear if  blds_last12m~=. & keep_yr==1 & keep_age==1

//create a new variable (sig_last12mo) based on the conditions of lstsig, but exclude certain categories (7, 9, or missing values).
gen  sig_last12mo=(lstsig==1)
replace  sig_last12mo= . if lstsig==7 | lstsig==. | lstsig==9


//create a frequency table of iyear (likely representing years) under the following conditions: The value for sig_last12mo is not missing. The year is flagged as relevant (keep_yr == 1). The age/treatment conditions are met (keep_age == 1).

tab sig_last12mo
tab iyear if  sig_last12mo~=. & keep_yr==1 & keep_age==1

//Assign a global to include only observations where age is between 51 and 76 (inclusive).iyear <= 2008: Includes only observations from the year 2008 or earlier.only observations where the individual is insured. only observations where the individual is male.
global rep_if "if keep_yr==1 & age>=51 & age<=76 & iyear<=2008 & uninsured==0 & sex==1"

//Assign a global to include only observations where keep_yr is 1. Age is between 51 and 76 (inclusive). Only observations from the year 2008 or earlier. individual is insured. the individual is female
global rep_if2 "if keep_yr==1 & age>=51 & age<=76 & iyear<=2008 & uninsured==0 & sex==2"

describe

/* DDD 1997-2008*/ 

//perform a fixed-effects regression using reghdfe with clustered standard error to account for auto correlation: Restrict the analysis to males with a specific age group (51 to 76 years old). Exclude uninsured individuals. .iyear <= 2008: Includes only observations from the year 2008 or earlier. The fixed effects specified in the absorb() option are designed to account for unobserved confounders.
//The coefficient for post_x_treat represents the DDD estimate
reghdfe blds_last12mo  post post_x_treat $rep_if , absorb (i.treat#i.iyear i.treat#i._state i._state#i.iyear i._state i.iyear)  vce(cluster treatmentyear)

//append the output to the existing file
outreg2 using DDD.xls, excel append 

//perform a fixed-effects regression using reghdfe with clustered standard error to account for auto correlation:  Restrict the analysis to uinsured females with a specific age group (51 to 76 years old).  keep_yr is 1. Only observations from the year 2008 or earlier. The fixed effects specified in the absorb() option are designed to account for unobserved confounders
//The coefficient for post_x_treat represents the DDD estimate
reghdfe blds_last12mo  post post_x_treat $rep_if2 , absorb (i.treat#i.iyear i.treat#i._state i._state#i.iyear i._state i.iyear)  vce(cluster treatmentyear)

outreg2 using DDD.xls, excel append 

//explicitly control for demographic factors that might influence the outcome with clustered standard error to account for auto correlation
//The coefficient for post_x_treat represents the DDD estimate
reghdfe blds_last12mo  post post_x_treat i.racecat i.incomecat i.educacat i.maritalcat i.genhlthcat  $rep_if , absorb (i.treat#i.iyear i.treat#i._state i._state#i.iyear i._state i.iyear i.age)  vce(cluster treatmentyear)
outreg2 using DDD.xls, excel append 

//perform a fixed-effects regression using reghdfe with clustered standard error to account for auto correlation: Restrict the analysis to males with a specific age group (51 to 76 years old). Exclude uninsured individuals. .iyear <= 2008: Includes only observations from the year 2008 or earlier
//The coefficient for post_x_treat represents the DDD estimate
reghdfe sig_last12mo  post post_x_treat $rep_if , absorb (i.treat#i.iyear i.treat#i._state i._state#i.iyear i._state i.iyear)  vce(cluster treatmentyear)
outreg2 using DDD.xls, excel append 


//perform a fixed-effects regression using reghdfe with clustered standard error to account for auto correlation:  Restrict the analysis to uinsured females with a specific age group (51 to 76 years old).  keep_yr is 1. Only observations from the year 2008 or earlier. 
//The coefficient for post_x_treat represents the DDD estimate
reghdfe sig_last12mo  post post_x_treat $rep_if2 , absorb (i.treat#i.iyear i.treat#i._state i._state#i.iyear i._state i.iyear)  vce(cluster treatmentyear)
outreg2 using DDD.xls, excel append 

//explicitly control for demographic factors that might influence the outcome with clustered standard error to account for auto correlation
//The coefficient for post_x_treat represents the DDD estimate
reghdfe sig_last12mo  post post_x_treat i.racecat i.incomecat i.educacat i.maritalcat i.genhlthcat  $rep_if , absorb (i.treat#i.iyear i.treat#i._state i._state#i.iyear i._state i.iyear i.age)  vce(cluster treatmentyear)


/*DD*/
//perform a fixed-effects regression using reghdfe: Restrict the analysis to males with a specific age group (51 to 76 years old). Exclude uninsured individuals. .iyear <= 2008: Includes only observations from the year 2008 or earlier
//The coefficient for post represents the DD estimate
reghdfe blds_last12mo post $rep_if, absorb (i._state i.iyear)
outreg2 using DD.xls, excel append 

//explicitly control for demographic factors that might influence the outcome 
//The coefficient for post represents the DD estimate
reghdfe blds_last12mo post i.racecat i.incomecat i.educacat i.maritalcat i.genhlthcat $rep_if, absorb ( i._state i.iyear i.age)

//perform a fixed-effects regression using reghdfe: Restrict the analysis to males with a specific age group (51 to 76 years old). Exclude uninsured individuals. .iyear <= 2008: Includes only observations from the year 2008 or earlier
//The coefficient for post represents the DD estimate
reghdfe sig_last12mo post $rep_if, absorb ( i._state i.iyear)
outreg2 using DD.xls, excel append 

//explicitly control for demographic factors that might influence the outcome 
//The coefficient for post represents the DD estimate
reghdfe sig_last12mo post i.racecat i.incomecat i.educacat i.maritalcat i.genhlthcat $rep_if, absorb ( i._state i.iyear i.age)


//perform a fixed-effects regression using reghdfe with clustered standard error to account for auto correlation:  Restrict the analysis to uinsured females with a specific age group (51 to 76 years old).  keep_yr is 1. Only observations from the year 2008 or earlier. 
//The coefficient for post represents the DD estimate
reghdfe blds_last12mo post $rep_if2, absorb (i._state i.iyear)
outreg2 using DD.xls, excel append 


//perform a fixed-effects regression using reghdfe with clustered standard error to account for auto correlation:  Restrict the analysis to uinsured females with a specific age group (51 to 76 years old).  keep_yr is 1. Only observations from the year 2008 or earlier. 
//The coefficient for post represents the DD estimate
reghdfe sig_last12mo post $rep_if2, absorb (i._state i.iyear)
outreg2 using DD.xls, excel append 

/* DDD 1997-2012*/ 
//Do the series of analysis above but for 1997-2012

global rep_if6 "if keep_yr==1 & age>=51 & age<=76 & iyear<=2012 & uninsured==0 & sex==1"
global rep_if7 "if keep_yr==1 & age>=51 & age<=76 & iyear<=2012 & uninsured==0 & sex==2"

reghdfe blds_last12mo  post post_x_treat $rep_if6 , absorb (i.treat#i.iyear i.treat#i._state i._state#i.iyear i._state i.iyear)  vce(cluster treatmentyear)
outreg2 using DDD97-2012.xls, excel append 

reghdfe blds_last12mo  post post_x_treat $rep_if7 , absorb (i.treat#i.iyear i.treat#i._state i._state#i.iyear i._state i.iyear)  vce(cluster treatmentyear)
outreg2 using DDD97-2012.xls, excel append 

reghdfe sig_last12mo  post post_x_treat $rep_if6 , absorb (i.treat#i.iyear i.treat#i._state i._state#i.iyear i._state i.iyear)  vce(cluster treatmentyear)
outreg2 using DDD97-2012.xls, excel append 

reghdfe sig_last12mo  post post_x_treat $rep_if7 , absorb (i.treat#i.iyear i.treat#i._state i._state#i.iyear i._state i.iyear)  vce(cluster treatmentyear)
outreg2 using DDD97-2012.xls, excel append 

/* DD 1997-2012*/
reghdfe blds_last12mo post $rep_if6, absorb (i._state i.iyear)
outreg2 using DD97-2012.xls, excel append 
  
reghdfe sig_last12mo post $rep_if6, absorb ( i._state i.iyear)
outreg2 using DD97-2012.xls, excel append 

reghdfe blds_last12mo post $rep_if7, absorb (i._state i.iyear)
outreg2 using DD97-2012.xls, excel append 

reghdfe sig_last12mo post $rep_if7, absorb (i._state i.iyear)
outreg2 using DD97-2012.xls, excel append 



/***sensitivity checks***/


*using the uninsured rather than the medicare enrollees as the control*/

global rep_if4 "if keep_yr==1 & age>=51 & age<=76 & iyear<=2008 & sex==1 & uninsured==1"

global rep_if5 "if keep_yr==1 & age>=51 & age<=76 & iyear<=2008 & sex==2 & uninsured==1"

reghdfe blds_last12mo  post post_x_treat $rep_if4 , absorb (i.treat#i.iyear i.treat#i._state i._state#i.iyear i._state i.iyear)  vce(cluster treatmentyear)
outreg2 using sensitivitycheck.xls, excel append 

reghdfe blds_last12mo  post post_x_treat $rep_if5 , absorb (i.treat#i.iyear i.treat#i._state i._state#i.iyear i._state i.iyear)  vce(cluster treatmentyear)
outreg2 using sensitivitycheck.xls, excel append 

reghdfe sig_last12mo  post post_x_treat $rep_if4 , absorb (i.treat#i.iyear i.treat#i._state i._state#i.iyear i._state i.iyear)  vce(cluster treatmentyear)
outreg2 using sensitivitycheck.xls, excel append 

reghdfe sig_last12mo  post post_x_treat $rep_if5 , absorb (i.treat#i.iyear i.treat#i._state i._state#i.iyear i._state i.iyear)  vce(cluster treatmentyear)
outreg2 using sensitivitycheck.xls, excel append 


/*robustness check; exploring different ways to define treatment time for the control states; giving the control states random years based on the treatmentyear of neighbors */

gen faketreat1=2007 if (_state==46 | _state==38)
replace faketreat1=2009 if (_state== 36 | _state==33)
replace faketreat1=2002 if (_state==45 | _state==12 | _state==4 )
replace faketreat1=2005 if (_state==49 | _state==28 | _state==26 | _state==25 | _state==20 | _state==19 | _state==16)



gen post1=(iyear>=treatmentyear)
replace post1=(iyear>=faketreat1) if treat==0

tab post post1

gen treatment= (treatmentyear!=.)
gen post1_x_treat=post1*treatment

global rep_if "if keep_yr==1 & age>=51 & age<=76 & iyear<=2008 & uninsured==0 & sex==1"
global rep_if2 "if keep_yr==1 & age>=51 & age<=76 & iyear<=2008 & uninsured==0 & sex==2"

reghdfe blds_last12mo  post1_x_treat $rep_if , absorb (i.treat#i.iyear i.treat#i._state i._state#i.iyear i._state i.iyear)  vce(cluster treatmentyear)
outreg2 using sensitivitycheck2.xls, excel append 

reghdfe blds_last12mo  post1_x_treat $rep_if2 , absorb (i.treat#i.iyear i.treat#i._state i._state#i.iyear i._state i.iyear)  vce(cluster treatmentyear)
outreg2 using sensitivitycheck2.xls, excel append 

reghdfe sig_last12mo  post1_x_treat $rep_if , absorb (i.treat#i.iyear i.treat#i._state i._state#i.iyear i._state i.iyear)  vce(cluster treatmentyear)
outreg2 using sensitivitycheck2.xls, excel append 

reghdfe sig_last12mo  post1_x_treat $rep_if2 , absorb (i.treat#i.iyear i.treat#i._state i._state#i.iyear i._state i.iyear)  vce(cluster treatmentyear)
outreg2 using sensitivitycheck2.xls, excel append 

/*Grouping the states based on the year of mandate to get the parallel trend graphs */
generate groupedstate=.
replace  groupedstate=2003 if (_state==1 | _state==32) 
replace groupedstate=2007 if (_state==2 | _state==27 | _state==35 | _state==31 | _state==53)
replace groupedstate=2005 if (_state==5 | _state==22 | _state==41)
replace groupedstate=2000 if (_state==6 | _state==18 | _state==44 | _state==51)
replace groupedstate=2010 if (_state==8 | _state==39 | _state==55)
replace groupedstate=2001 if (_state==9 | _state==10 | _state==24 | _state==48 | _state==56)
replace groupedstate=2002 if (_state==11 | _state==13 | _state==34 | _state==37 | _state==40 | _state==54)
replace groupedstate=2011 if (_state==15)
replace groupedstate=1999 if (_state==17 | _state==29)
replace groupedstate=2009 if (_state==21 | _state==30 | _state==50)
replace groupedstate=2008 if (_state==23 | _state==42)
replace groupedstate=2004 if (_state==47)

gen groupedstate2=1 if groupedstate==1999  | groupedstate==2000
replace groupedstate2=2 if groupedstate==2001  | groupedstate==2002 
replace groupedstate2=3 if groupedstate==2003  | groupedstate==2004 | groupedstate==2005
replace groupedstate2=4 if groupedstate==2007  | groupedstate==2008
replace groupedstate2=5 if groupedstate==2010  | groupedstate==2011 
 
collapse  sig_last12mo blds_last12mo (max) groupedstate, by (groupedstate2  iyear)
 
replace sig_last12mo=. if sig_last12mo==0

twoway line sig_last12mo iyear if groupedstate2==. || line sig_last12mo iyear if groupedstate2==1 

twoway line sig_last12mo iyear if groupedstate2==. || line sig_last12mo iyear if groupedstate2==2 

twoway line sig_last12mo iyear if groupedstate2==. || line sig_last12mo iyear if groupedstate2==3 

twoway line sig_last12mo iyear if groupedstate2==. || line sig_last12mo iyear if groupedstate2==4

twoway line sig_last12mo iyear if groupedstate2==. || line sig_last12mo iyear if groupedstate2==5 

 
replace blds_last12mo=. if blds_last12mo==0

twoway line blds_last12mo iyear if groupedstate2==. || line blds_last12mo iyear if groupedstate2==1 

twoway line blds_last12mo iyear if groupedstate2==. || line blds_last12mo iyear if groupedstate2==2 

twoway line blds_last12mo iyear if groupedstate2==. || line blds_last12mo iyear if groupedstate2==3

twoway line blds_last12mo iyear if groupedstate2==. || line blds_last12mo iyear if groupedstate2==4 

twoway line blds_last12mo iyear if groupedstate2==. || line blds_last12mo iyear if groupedstate2==5 




