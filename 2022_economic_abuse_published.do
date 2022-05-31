*=======================================================================================
 * Date: March, 2022
 * Author: Bing-Jie Yen
 * PI: Larissa Jennings Mayo-Wilson 
 * Topic: In this file, I attach the complete codes, and tables I wrote for this publication.
 * https://pubmed.ncbi.nlm.nih.gov/35510547/
*=======================================================================================

clear all
capture log close

cd "J:/Dropbox/@IU 2020 Spring/RA job/Uganda/Stata code and data"

/*		1. Housekeeping */

set more off
log using Uganda_WESW_2021March_BJY, replace

use "NEW_KYATEREKERA ASSESSMENT MEASURE v1_Updated_4.8.2020_1_Merged_TTL23Feb21.dta", clear


/*		Data Figure */

sum ResponseId
duplicates report ResponseId

/*		NOTE:	The unique ID variable is 'ResponseId'. There are no duplicates. The total sample size is N=542, which is to be expected. 
				*/


*--------------------------------------------------------------
*     Table 1: Summary statistics for total participants
*--------------------------------------------------------------

/* Demographic for total*/

//* Age (coded as iA_2_w1)
describe iA_2_w1
gen age= iA_2_w1

* Age group: 18-29 as reference group
sum age
gen age_cat=0
replace age_cat = 1 if age<30
replace age_cat = 0 if age>=30 

label define youngage 1 "18-29" 0 ">30"
label values age_cat youngage
tab age_cat

//* current marital status(coded as iA_3_w1)
codebook iA_3_w1
gen marital_status=.
replace marital_status=1 if (iA_3_w1==1|iA_3_w1==2|iA_3_w1==6) 
replace marital_status=0 if (iA_3_w1==3|iA_3_w1==4|iA_3_w1==5|iA_3_w1==7) 
label define marry 1 "Married/Common law marriage/In a relationship" 0 "Divorced,  Separated, Widowed,  Single, never married"
label values marital_status marry
tab marital_status


//* Highest level of education you completed?
codebook iA_5_w1
gen highest_edu=.
replace highest_edu=0 if (iA_5_w1==1|iA_5_w1==2|iA_5_w1==3) 
replace highest_edu=1 if (iA_5_w1==4|iA_5_w1==5|iA_5_w1==6|iA_5_w1==7|iA_5_w1==8) 
label define education 1 "Primary school or more" 0 "Less than primary education (< 8yrs)"
label values highest_edu education
tab highest_edu

//* Religion affiliation
codebook iA_4a_w1
gen christian=.
replace christian=1 if(iA_4a_w1==1|iA_4a_w1==2|iA_4a_w1==4)
replace christian=0 if(iA_4a_w1==3|iA_4a_w1==6)
label define christian 1 "christian" 0 "others"
label values christian christian
tab christian

//* On average, how much is your total monthly income (money that you earn, not from
codebook vC_44_w1
sum vC_44_w1
gen individual_month_income_USD= vC_44_w1*0.00027
sum individual_month_income_USD
/*The mean of household income is 60.3USD*/
gen individual_month_income_USD_cat =cond(individual_month_income_USD<=60.3,0,1) 
label define income 1 "Above average income" 0 "Below or equal to average income"
label values individual_month_income_USD_cat income 
tab individual_month_income_USD_cat

//* District_name
codebook District_name_w1

//* Homelessness: iC_13_w1 "Have you been homeless or without a regular place to sleep in the past 30 days?"
codebook iC_13_w1
gen homelessness= iC_13_w1
replace homelessness=0 if iC_13_w1==2

//* financial distress: ADD PRIOR Financial distress in last 90 days (yesno) – Q30 (Section 5, pg 14) -  code as 1 if women says once, 2-3 times, or many for AT LEAST ONE of 5 financial distress variables (a-e).*/
describe vA_30*
codebook vA_30a_w1
gen financial_distress= 0
replace financial_distress=1 if (inrange(vA_30a_w1,2,4)|inrange(vA_30b_w1,2,4)|inrange(vA_30C_w1,2,4)|inrange(vA_30d_w1,2,4)|inrange(vA_30e_w1,2,4))
label variable financial_distress "Q30 (Section 5, pg 14) -  code as 1 if women says once, 2-3 times, or many for AT LEAST ONE of 5 financial distress variables (a-e)"

//* Adult household size
* Adult household size?  Q17, Section 1.C (pg 8) – make into 2 categories (above and below median)-but create new variable that excludes children from household size by substracting out Q18
codebook iC_17_w1
codebook iC_18_w1
gen adult_household_size_tmp=iC_17_w1-iC_18_w1
gen adult_household_size=.
replace adult_household_size=1 if (adult_household_size_tmp>1)
replace adult_household_size=0 if (adult_household_size_tmp==1)
label define householdsize 1 "Two or more adults" 0 "One adult(participant self)"
label values adult_household_size householdsize
tab adult_household_size


//* other non-sex work
/* Add ANY OTHER NON-SEX WORK in last 12 months (yes/no) – code as 1(yes) if women 
answers yes to Q40 (page 16) Section 5B AND in question’ what was your work’ for first, second, 
or third job – if she says something other than sex work. Code 0 (no) if she says no to Q40 OR if she says yes,
 but all of her work was sex work. i.e. more than 2 jobs and one of job is not sex work*/
 
codebook vB_40a_1_w1
tab vB_40a_1_w1
codebook vB_40b_1_w1
codebook vB_40c_1_w1

gen other_non_sex_work=0 
replace other_non_sex_work=1 if (vB_40a_1_w1=="Sex work"|vB_40a_1_w1=="Sex worker"|vB_40b_1_w1=="Sexual work"|vB_40b_1_w1=="Sexual worker"|vB_40c_1_w1=="Sex work")
label variable other_non_sex_work "Do you have any other non-sex related job?"

//* currently has savings
codebook viA_51a_w1
gen current_saving=viA_51a_w1
replace current_saving=0 if viA_51a_w1==2
label variable current_saving "currently has savings (yes/no) – Q51, page 20, Section 6A"
tab current_saving

//* currently has debt
codebook vC_47_w1
gen current_debt=vC_47_w1
replace current_debt=0 if vC_47_w1==2
label variable current_debt "currently has debt (yes/no) Q47, page 18"
tab current_debt



//* if has a boss/manager for sex work (yes/no) – Q67, Section 7, page 24
codebook viiA_67a_w1
tab viiA_67a_w1
gen has_boss_sexwork=viiA_67a_w1
replace has_boss_sexwork=1 if viiA_67a_w1==1
replace has_boss_sexwork=0 if viiA_67a_w1==2

label variable has_boss_sexwork "if has a boss/manager for sex work (yes/no) – Q67, Section 7, page 24"
tab has_boss_sexwork

//* number of paying customers in the past 30 days
codebook viiA_74_w1
summarize viiA_74_w1, detail // let's categorize the variable into five groups
gen number_partner = .
replace number_partner = 0 if viiA_74_w1==0  
replace number_partner = 1 if inrange(viiA_74_w1, 1, 5)   
replace number_partner = 2 if inrange(viiA_74_w1, 6, 15)   
replace number_partner = 3 if inrange(viiA_74_w1, 16, 30)
replace number_partner = 4 if viiA_74_w1>30
label variable number_partner "Number of paying customers in the past 30 days"
 
//* Self-efficacy to secure non-sex work employment
codebook viiA_80_w1
tab viiA_80_w1					
gen self_efficacy=.
replace self_efficacy=1 if viiA_80_w1==1
replace self_efficacy=0 if (viiA_80_w1==2|viiA_80_w1==888)
tab self_efficacy
label variable self_efficacy "Self-efficacy to secure non-sex work employment"

*--------------------------------------------------------------
*     Table 2: Prevalence of economic abuse items 
*--------------------------------------------------------------

* There are 24 variables regarding economic abuse
sum ixC_86*

* Table 2, 3rd column: Recode economic abuse from partner(ixC_86$_1_w1): Never/Hardly ever=0, Sometimes, often,quite often=1
gen ixC_86a_1_w1_recoded=. 
replace ixC_86a_1_w1_recoded=0 if (ixC_86a_1_w1==1|ixC_86a_1_w1==2)
replace ixC_86a_1_w1_recoded=1 if (ixC_86a_1_w1>=3 & ixC_86a_1_w1<=5)
tab ixC_86a_1_w1_recoded

codebook ixC_86b_1_w1
gen ixC_86b_1_w1_recoded=. 
replace ixC_86b_1_w1_recoded=0 if (ixC_86b_1_w1==1|ixC_86b_1_w1==2)
replace ixC_86b_1_w1_recoded=1 if (ixC_86b_1_w1>=3 &ixC_86b_1_w1<=5)
tab ixC_86b_1_w1_recoded

codebook ixC_86c_1_w1
gen ixC_86c_1_w1_recoded=. 
replace ixC_86c_1_w1_recoded=0 if (ixC_86c_1_w1==1|ixC_86c_1_w1==2)
replace ixC_86c_1_w1_recoded=1 if (ixC_86c_1_w1>=3 &ixC_86c_1_w1<=5)
tab ixC_86c_1_w1_recoded

codebook ixC_86d_1_w1
gen ixC_86d_1_w1_recoded=. 
replace ixC_86d_1_w1_recoded=0 if (ixC_86d_1_w1==1|ixC_86d_1_w1==2)
replace ixC_86d_1_w1_recoded=1 if (ixC_86d_1_w1>=3 &ixC_86d_1_w1<=5)
tab ixC_86d_1_w1_recoded

codebook ixC_86e_1_w1
gen ixC_86e_1_w1_recoded=. 
replace ixC_86e_1_w1_recoded=0 if (ixC_86e_1_w1==1|ixC_86e_1_w1==2)
replace ixC_86e_1_w1_recoded=1 if (ixC_86e_1_w1>=3 &ixC_86e_1_w1<=5)
tab ixC_86e_1_w1_recoded

codebook ixC_86f_1_w1
gen ixC_86f_1_w1_recoded=. 
replace ixC_86f_1_w1_recoded=0 if (ixC_86f_1_w1==1|ixC_86f_1_w1==2)
replace ixC_86f_1_w1_recoded=1 if (ixC_86f_1_w1>=3 &ixC_86f_1_w1<=5)
tab ixC_86f_1_w1_recoded

codebook ixC_86g_1_w1
gen ixC_86g_1_w1_recoded=. 
replace ixC_86g_1_w1_recoded=0 if (ixC_86g_1_w1==1|ixC_86g_1_w1==2)
replace ixC_86g_1_w1_recoded=1 if (ixC_86g_1_w1>=3 &ixC_86g_1_w1<=5)
tab ixC_86g_1_w1_recoded

codebook ixC_86h_1_w1
gen ixC_86h_1_w1_recoded=. 
replace ixC_86h_1_w1_recoded=0 if (ixC_86h_1_w1==1|ixC_86h_1_w1==2)
replace ixC_86h_1_w1_recoded=1 if (ixC_86h_1_w1>=3 &ixC_86h_1_w1<=5)
tab ixC_86h_1_w1_recoded

codebook ixC_86i_1_w1
gen ixC_86i_1_w1_recoded=. 
replace ixC_86i_1_w1_recoded=0 if (ixC_86i_1_w1==1|ixC_86i_1_w1==2)
replace ixC_86i_1_w1_recoded=1 if (ixC_86i_1_w1>=3 &ixC_86i_1_w1<=5)
tab ixC_86i_1_w1_recoded

codebook ixC_86j_1_w1
gen ixC_86j_1_w1_recoded=. 
replace ixC_86j_1_w1_recoded=0 if (ixC_86j_1_w1==1|ixC_86j_1_w1==2)
replace ixC_86j_1_w1_recoded=1 if (ixC_86j_1_w1>=3 &ixC_86j_1_w1<=5)
tab ixC_86j_1_w1_recoded

codebook ixC_86k_1_w1
gen ixC_86k_1_w1_recoded=. 
replace ixC_86k_1_w1_recoded=0 if (ixC_86k_1_w1==1|ixC_86k_1_w1==2)
replace ixC_86k_1_w1_recoded=1 if (ixC_86k_1_w1>=3 &ixC_86k_1_w1<=5)
tab ixC_86k_1_w1_recoded

codebook ixC_86l_1_w1
gen ixC_86l_1_w1_recoded=. 
replace ixC_86l_1_w1_recoded=0 if (ixC_86l_1_w1==1|ixC_86l_1_w1==2)
replace ixC_86l_1_w1_recoded=1 if (ixC_86l_1_w1>=3 &ixC_86l_1_w1<=5)
tab ixC_86l_1_w1_recoded

* Table 2, 4th column: Recode economic abuse from family members(ixC_86$_2_w1): Never/Hardly ever=0, Sometimes, often,quite often=1
gen ixC_86a_2_w1_recoded=. 
replace ixC_86a_2_w1_recoded=0 if (ixC_86a_2_w1==1|ixC_86a_2_w1==2)
replace ixC_86a_2_w1_recoded=1 if (ixC_86a_2_w1>=3 & ixC_86a_2_w1<=5)
tab ixC_86a_2_w1_recoded

codebook ixC_86b_2_w1
gen ixC_86b_2_w1_recoded=. 
replace ixC_86b_2_w1_recoded=0 if (ixC_86b_2_w1==1|ixC_86b_2_w1==2)
replace ixC_86b_2_w1_recoded=1 if (ixC_86b_2_w1>=3 &ixC_86b_2_w1<=5)
tab ixC_86b_2_w1_recoded

codebook ixC_86c_2_w1
gen ixC_86c_2_w1_recoded=. 
replace ixC_86c_2_w1_recoded=0 if (ixC_86c_2_w1==1|ixC_86c_2_w1==2)
replace ixC_86c_2_w1_recoded=1 if (ixC_86c_2_w1>=3 &ixC_86c_2_w1<=5)
tab ixC_86c_2_w1_recoded

codebook ixC_86d_2_w1
gen ixC_86d_2_w1_recoded=. 
replace ixC_86d_2_w1_recoded=0 if (ixC_86d_2_w1==1|ixC_86d_2_w1==2)
replace ixC_86d_2_w1_recoded=1 if (ixC_86d_2_w1>=3 &ixC_86d_2_w1<=5)
tab ixC_86d_2_w1_recoded

codebook ixC_86e_2_w1
gen ixC_86e_2_w1_recoded=. 
replace ixC_86e_2_w1_recoded=0 if (ixC_86e_2_w1==1|ixC_86e_2_w1==2)
replace ixC_86e_2_w1_recoded=1 if (ixC_86e_2_w1>=3 &ixC_86e_2_w1<=5)
tab ixC_86e_2_w1_recoded

codebook ixC_86f_2_w1
gen ixC_86f_2_w1_recoded=. 
replace ixC_86f_2_w1_recoded=0 if (ixC_86f_2_w1==1|ixC_86f_2_w1==2)
replace ixC_86f_2_w1_recoded=1 if (ixC_86f_2_w1>=3 &ixC_86f_2_w1<=5)
tab ixC_86f_2_w1_recoded

codebook ixC_86g_2_w1
gen ixC_86g_2_w1_recoded=. 
replace ixC_86g_2_w1_recoded=0 if (ixC_86g_2_w1==1|ixC_86g_2_w1==2)
replace ixC_86g_2_w1_recoded=1 if (ixC_86g_2_w1>=3 &ixC_86g_2_w1<=5)
tab ixC_86g_2_w1_recoded

codebook ixC_86h_2_w1
gen ixC_86h_2_w1_recoded=. 
replace ixC_86h_2_w1_recoded=0 if (ixC_86h_2_w1==1|ixC_86h_2_w1==2)
replace ixC_86h_2_w1_recoded=1 if (ixC_86h_2_w1>=3 &ixC_86h_2_w1<=5)
tab ixC_86h_2_w1_recoded

codebook ixC_86i_2_w1
gen ixC_86i_2_w1_recoded=. 
replace ixC_86i_2_w1_recoded=0 if (ixC_86i_2_w1==1|ixC_86i_2_w1==2)
replace ixC_86i_2_w1_recoded=1 if (ixC_86i_2_w1>=3 &ixC_86i_2_w1<=5)
tab ixC_86i_2_w1_recoded

codebook ixC_86j_2_w1
gen ixC_86j_2_w1_recoded=. 
replace ixC_86j_2_w1_recoded=0 if (ixC_86j_2_w1==1|ixC_86j_2_w1==2)
replace ixC_86j_2_w1_recoded=1 if (ixC_86j_2_w1>=3 &ixC_86j_2_w1<=5)
tab ixC_86j_2_w1_recoded

codebook ixC_86k_2_w1
gen ixC_86k_2_w1_recoded=. 
replace ixC_86k_2_w1_recoded=0 if (ixC_86k_2_w1==1|ixC_86k_2_w1==2)
replace ixC_86k_2_w1_recoded=1 if (ixC_86k_2_w1>=3 &ixC_86k_2_w1<=5)
tab ixC_86k_2_w1_recoded

codebook ixC_86l_2_w1
gen ixC_86l_2_w1_recoded=. 
replace ixC_86l_2_w1_recoded=0 if (ixC_86l_2_w1==1|ixC_86l_2_w1==2)
replace ixC_86l_2_w1_recoded=1 if (ixC_86l_2_w1>=3 &ixC_86l_2_w1<=5)
tab ixC_86l_2_w1_recoded

* Table 2, 2nd column: Frequency of reported economic abuse items regardless of the source of economic abuse

gen ixC_86a=.
replace ixC_86a=1 if (ixC_86a_1_w1_recoded==1|ixC_86a_2_w1_recoded==1)
replace ixC_86a=0 if !(ixC_86a_1_w1_recoded==1|ixC_86a_2_w1_recoded==1)
tab ixC_86a

gen ixC_86b=.
replace ixC_86b=1 if (ixC_86b_1_w1_recoded==1|ixC_86b_2_w1_recoded==1)
replace ixC_86b=0 if !(ixC_86b_1_w1_recoded==1|ixC_86b_2_w1_recoded==1)
tab ixC_86b

gen ixC_86c=.
replace ixC_86c=1 if (ixC_86c_1_w1_recoded==1|ixC_86c_2_w1_recoded==1)
replace ixC_86c=0 if !(ixC_86c_1_w1_recoded==1|ixC_86c_2_w1_recoded==1)
tab ixC_86c

gen ixC_86d=.
replace ixC_86d=1 if (ixC_86d_1_w1_recoded==1|ixC_86d_2_w1_recoded==1)
replace ixC_86d=0 if !(ixC_86d_1_w1_recoded==1|ixC_86d_2_w1_recoded==1)
tab ixC_86d

gen ixC_86e=.
replace ixC_86e=1 if (ixC_86e_1_w1_recoded==1|ixC_86e_2_w1_recoded==1)
replace ixC_86e=0 if !(ixC_86e_1_w1_recoded==1|ixC_86e_2_w1_recoded==1)
tab ixC_86e

gen ixC_86f=.
replace ixC_86f=1 if (ixC_86f_1_w1_recoded==1|ixC_86f_2_w1_recoded==1)
replace ixC_86f=0 if !(ixC_86f_1_w1_recoded==1|ixC_86f_2_w1_recoded==1)
tab ixC_86f

gen ixC_86g=.
replace ixC_86g=1 if (ixC_86g_1_w1_recoded==1|ixC_86g_2_w1_recoded==1)
replace ixC_86g=0 if !(ixC_86g_1_w1_recoded==1|ixC_86g_2_w1_recoded==1)
tab ixC_86g

gen ixC_86h=.
replace ixC_86h=1 if (ixC_86h_1_w1_recoded==1|ixC_86h_2_w1_recoded==1)
replace ixC_86h=0 if !(ixC_86h_1_w1_recoded==1|ixC_86h_2_w1_recoded==1)
tab ixC_86h

gen ixC_86i=.
replace ixC_86i=1 if (ixC_86i_1_w1_recoded==1|ixC_86i_2_w1_recoded==1)
replace ixC_86i=0 if !(ixC_86i_1_w1_recoded==1|ixC_86i_2_w1_recoded==1)
tab ixC_86i

gen ixC_86j=.
replace ixC_86j=1 if (ixC_86j_1_w1_recoded==1|ixC_86j_2_w1_recoded==1)
replace ixC_86j=0 if !(ixC_86j_1_w1_recoded==1|ixC_86j_2_w1_recoded==1)
tab ixC_86j

gen ixC_86k=.
replace ixC_86k=1 if (ixC_86k_1_w1_recoded==1|ixC_86k_2_w1_recoded==1)
replace ixC_86k=0 if !(ixC_86k_1_w1_recoded==1|ixC_86k_2_w1_recoded==1)
tab ixC_86k

gen ixC_86l=.
replace ixC_86l=1 if (ixC_86l_1_w1_recoded==1|ixC_86l_2_w1_recoded==1)
replace ixC_86l=0 if !(ixC_86l_1_w1_recoded==1|ixC_86l_2_w1_recoded==1)
tab ixC_86l


* Sum the economic abuse questions (range from 0 to 24)
egen EA_sum =rowtotal(*_recoded)
sum EA_sum

* Generate EA variables into 2 levels
gen ever_EA=.
replace ever_EA=1 if EA_sum>0
replace ever_EA=0 if EA_sum==0
* Generate EA variables into 3 levels
xtile tertile_EA = EA_sum, nquantiles(3)
tab tertile_EA EA_sum
label define tertile 1 "Low economic abuse (0 to 4)" 2 "Medium economic abuse(5 to 8)" 3 "High economic abuse(9 to 24)"
label values tertile_EA tertile 
label variable tertile_EA "The tertile levels of economic abuse reported from partners or family"

tab tertile_EA

* Mean value of EA among people with different levels of economic abuse
sum EA_sum if tertile_EA==1
sum EA_sum if tertile_EA==2
sum EA_sum if tertile_EA==3

* Sum of the economic questions reported from partners (range from 0 to 12)
egen EA_sum_partner =rowtotal(*_1_w1_recoded)
sum EA_sum_partner

* Generate EA variables reported from partners into 3 levels 
xtile tertile_EA_partner = EA_sum_partner, nquantiles(3)

tab tertile_EA_partner EA_sum_partner
label define tertile_partner 1 "Low economic abuse (0 to 3)" 2 "Medium economic abuse(4 to 6)" 3 "High economic abuse(7 to 12)"
label values tertile_EA_partner tertile_partner 
label variable tertile_EA_partner "The tertile levels of economic abuse reported from partners"

tab tertile_EA_partner

* Mean value of EA among people with different levels of economic abuse reported from partner
sum EA_sum_partner if tertile_EA_partner==1
sum EA_sum_partner if tertile_EA_partner==2
sum EA_sum_partner if tertile_EA_partner==3

* Sum of the economic questions reported from family (range from 0 to 12)
egen EA_sum_family =rowtotal(*_2_w1_recoded)
sum EA_sum_family

* Generate EA variables reported from family into 3 levels 
xtile tertile_EA_family = EA_sum_family, nquantiles(3)

tab tertile_EA_family EA_sum_family
label define tertile_family 1 "Low economic abuse (0 to 1)" 2 "Medium economic abuse(2 to 3)" 3 "High economic abuse(4 to 12)"
label values tertile_EA_family tertile_family 
label variable tertile_EA_family "The tertile levels of economic abuse reported from family"
tab tertile_EA_family

* Mean value of EA among people with different levels of economic abuse reported from family members
sum EA_sum_family if tertile_EA_family==1
sum EA_sum_family if tertile_EA_family==2
sum EA_sum_family if tertile_EA_family==3


* Table 2, 5th colum: The difference of economic abuse from partners and family members
tabulate ixC_86a_1_w1_recoded ixC_86a_2_w1_recoded, chi2
tabulate ixC_86b_1_w1_recoded ixC_86b_2_w1_recoded, chi2
tabulate ixC_86c_1_w1_recoded ixC_86c_2_w1_recoded, chi2
tabulate ixC_86d_1_w1_recoded ixC_86d_2_w1_recoded, chi2
tabulate ixC_86e_1_w1_recoded ixC_86e_2_w1_recoded, chi2
tabulate ixC_86f_1_w1_recoded ixC_86f_2_w1_recoded, chi2
tabulate ixC_86g_1_w1_recoded ixC_86g_2_w1_recoded, chi2
tabulate ixC_86h_1_w1_recoded ixC_86h_2_w1_recoded, chi2
tabulate ixC_86i_1_w1_recoded ixC_86i_2_w1_recoded, chi2
tabulate ixC_86j_1_w1_recoded ixC_86j_2_w1_recoded, chi2
tabulate ixC_86k_1_w1_recoded ixC_86k_2_w1_recoded, chi2
tabulate ixC_86l_1_w1_recoded ixC_86l_2_w1_recoded, chi2


*-------------------------------------------------------------------------------
* 
* Table 3: Crude and adjusted odds ratios (OR) of selected demographic factors 
*          associated with reported economic abuse (EA) in women employed by sex 
*          work by total and by the level of exposure (n=542)
*-------------------------------------------------------------------------------

tab age_cat 
tab marital_status
tab highest_edu
tab christian
tab individual_month_income_USD_cat
tab District_name_w1
tab homelessness
tab financial_distress
tab adult_household_size
tab other_non_sex_work
tab current_saving
tab current_debt
tab has_boss_sexwork
tab self_efficacy

* row sum 
tab ever_EA if age_cat==0
tab ever_EA if marital_status==0
tab ever_EA if highest_edu==0
tab ever_EA if adult_household_size==0
tab ever_EA if christian==0
tab ever_EA if individual_month_income_USD_cat==0
tab ever_EA if homelessness==0
tab ever_EA if financial_distress==0
tab ever_EA if other_non_sex_work==0
tab ever_EA if self_efficacy==0
tab ever_EA if current_saving==0
tab ever_EA if current_debt==0
tab ever_EA if has_boss_sexwork==0



tab age_cat if ever_EA==1
tab marital_status if ever_EA==1
tab highest_edu if ever_EA==1
tab adult_household_size if ever_EA==1
tab christian if ever_EA==1
tab individual_month_income_USD_cat if ever_EA==1
tab homelessness if ever_EA==1
tab financial_distress if ever_EA==1
tab other_non_sex_work if ever_EA==1
tab self_efficacy if ever_EA==1
tab current_saving if ever_EA==1
tab current_debt if ever_EA==1
tab has_boss_sexwork if ever_EA==1

tab age_cat if ever_EA==0
tab marital_status if ever_EA==0
tab highest_edu if ever_EA==0
tab adult_household_size if ever_EA==0
tab christian if ever_EA==0
tab individual_month_income_USD_cat if ever_EA==0
tab homelessness if ever_EA==0
tab financial_distress if ever_EA==0
tab other_non_sex_work if ever_EA==0
tab self_efficacy if ever_EA==0
tab current_saving if ever_EA==0
tab current_debt if ever_EA==0
tab has_boss_sexwork if ever_EA==0


tab age_cat ever_EA, chi2
tab marital_status ever_EA, chi2
tab highest_edu ever_EA, chi2
tab adult_household_size ever_EA, chi2
tab christian ever_EA, chi2
tab individual_month_income_USD_cat ever_EA, chi2
tab homelessness ever_EA, chi2
tab financial_distress ever_EA, chi2
tab other_non_sex_work ever_EA, chi2
tab self_efficacy ever_EA, chi2
tab current_saving ever_EA, chi2
tab current_debt ever_EA, chi2
tab has_boss_sexwork ever_EA, chi2

// Crude odds ratio: ever economic abuse(yes/no) and other variables
logistic ever_EA age_cat
logistic ever_EA marital_status
logistic ever_EA highest_edu
logistic ever_EA adult_household_size
logistic ever_EA christian
logistic ever_EA individual_month_income_USD_cat
logistic ever_EA homelessness
logistic ever_EA financial_distress
logistic ever_EA other_non_sex_work
logistic ever_EA self_efficacy
logistic ever_EA current_saving
logistic ever_EA current_debt
logistic ever_EA has_boss_sexwork

// Tertile economic abuse 
gen EA_med_low=.
replace EA_med_low=1 if tertile_EA==2
replace EA_med_low=0 if tertile_EA==1

gen EA_high_low=.
replace EA_high_low=1 if tertile_EA==3
replace EA_high_low=0 if tertile_EA==1

* row sum 
tab tertile_EA if age_cat==0
tab tertile_EA if marital_status==0
tab tertile_EA if highest_edu==0
tab tertile_EA if adult_household_size==0
tab tertile_EA if christian==0
tab tertile_EA if individual_month_income_USD_cat==0
tab tertile_EA if homelessness==0
tab tertile_EA if financial_distress==0
tab tertile_EA if other_non_sex_work==0
tab tertile_EA if self_efficacy==0
tab tertile_EA if current_saving==0
tab tertile_EA if current_debt==0
tab tertile_EA if has_boss_sexwork==0


// Crude odds ratio: economic abuse(medium vs low, low as reference group) and other variables
logistic EA_med_low age_cat
logistic EA_med_low  marital_status
logistic EA_med_low highest_edu
logistic EA_med_low adult_household_size
logistic EA_med_low christian
logistic EA_med_low individual_month_income_USD_cat
logistic EA_med_low homelessness
logistic EA_med_low financial_distress
logistic EA_med_low other_non_sex_work
logistic EA_med_low self_efficacy
logistic EA_med_low current_saving
logistic EA_med_low current_debt
logistic EA_med_low has_boss_sexwork

// Crude odds ratio: economic abuse(high vs low, low as reference group) and other variables
logistic EA_high_low age_cat
logistic EA_high_low marital_status
logistic EA_high_low highest_edu
logistic EA_high_low adult_household_size
logistic EA_high_low individual_month_income_USD_cat
logistic EA_high_low homelessness
logistic EA_high_low financial_distress
logistic EA_high_low other_non_sex_work
logistic EA_high_low self_efficacy
logistic EA_high_low current_saving
logistic EA_high_low current_debt
logistic EA_high_low has_boss_sexwork

// 
/* Adjusted odds ratio: Association between experience of any economic abuse 
and selected demographic characteristics by controling age, education, and marital status*/

logistic ever_EA age_cat marital_status highest_edu 

logistic ever_EA adult_household_size age_cat highest_edu marital_status
logistic ever_EA christian age_cat highest_edu marital_status
logistic ever_EA individual_month_income_USD_cat age_cat highest_edu marital_status
logistic ever_EA homelessness age_cat highest_edu marital_status
logistic ever_EA financial_distress age_cat highest_edu marital_status
logistic ever_EA other_non_sex_work age_cat highest_edu marital_status
logistic ever_EA self_efficacy age_cat highest_edu marital_status
logistic ever_EA current_saving age_cat highest_edu marital_status
logistic ever_EA current_debt age_cat highest_edu marital_status
logistic ever_EA has_boss_sexwork age_cat highest_edu marital_status

// 
/* Adjusted odds ratio: Association between experience of medium level economic abuse vs low economic abuse
and selected demographic characteristics by controling age, education, and marital status*/

logistic EA_med_low age_cat marital_status highest_edu 

logistic EA_med_low adult_household_size age_cat highest_edu marital_status
logistic EA_med_low christian age_cat highest_edu marital_status
logistic EA_med_low individual_month_income_USD_cat age_cat highest_edu marital_status
logistic EA_med_low homelessness age_cat highest_edu marital_status
logistic EA_med_low financial_distress age_cat highest_edu marital_status
logistic EA_med_low other_non_sex_work age_cat highest_edu marital_status
logistic EA_med_low self_efficacy age_cat highest_edu marital_status
logistic EA_med_low current_saving age_cat highest_edu marital_status
logistic EA_med_low current_debt age_cat highest_edu marital_status
logistic EA_med_low has_boss_sexwork age_cat highest_edu marital_status

// 
/* Adjusted odds ratio: Association between experience of high level economic abuse vs low economic abuse
and selected demographic characteristics by controling age, education, and marital status*/

logistic EA_high_low age_cat marital_status highest_edu 

logistic EA_high_low adult_household_size age_cat highest_edu marital_status
logistic EA_high_low christian age_cat highest_edu marital_status
logistic EA_high_low individual_month_income_USD_cat age_cat highest_edu marital_status
logistic EA_high_low homelessness age_cat highest_edu marital_status
logistic EA_high_low financial_distress age_cat highest_edu marital_status
logistic EA_high_low other_non_sex_work age_cat highest_edu marital_status
logistic EA_high_low self_efficacy age_cat highest_edu marital_status
logistic EA_high_low current_saving age_cat highest_edu marital_status
logistic EA_high_low current_debt age_cat highest_edu marital_status
logistic EA_high_low has_boss_sexwork age_cat highest_edu marital_status




*-----------------------PART TWO = Sexual Behaviorial Outcomes -------------

*-------------------------------------------------------------------------------
* 
* Table 4: Baseline behavior characteristics of study participants (N=542)
*-------------------------------------------------------------------------------

// # 1.	Safe sex behaviors (Section 1A, Page 3)
// # a.	Sex under influence of alcohol/drugs - Question 8 and 9: Coded = 1 (yes) if # of times for most recent partner #1 is > 0 for either Q8 or Q9; Otherwise coded=0 (no)

codebook xA_94a_w1
codebook xA_95a_w1
gen sex_under_influence=.
replace sex_under_influence=1 if (xA_94a_w1>0|xA_95a_w1>0)
replace sex_under_influence=0 if (xA_94a_w1==0& xA_95a_w1==0)
label variable sex_under_influence "Sex under influence of alcohol/drugs - Question 8a and 9a: Coded = 1 (yes) if # of times for most recent partner #1 is > 0 for either Q8a or Q9a; Otherwise coded=0 (no)"
tab sex_under_influence


// b.	Sex with a condom – Question 10: Coded=1 (yes) if # of times for most recent partner #1 is > 0 for Q10; Otherwise coded=0 (no)
codebook xA_96a_w1
gen sex_with_condom=0
replace sex_with_condom=1 if xA_96a_w1>0
tab sex_with_condom

// # 2.	Care-seeking practices for HIV (Section 10D, Page 39)
// # a.	Ever tested for HIV – Question 92A: Coded=1 (yes) if said yes; coded=0 (no) if said no
codebook xivD_170a_w1
gen xD_92a_ever_HIV=0
replace xD_92a_ever_HIV=1 if xivD_170a_w1==1
label variable xD_92a_ever_HIV "Have you ever been tested for HIV/AIDS?"
tab xD_92a_ever_HIV

// # b.	Tested for HIV in last 90 days – Question 92B: Coded=1 (yes) if said Yes to Q92A AND gave when tested (month/year) of within 90 days of date of interview. Otherwise coded=0 (no).
codebook xivD_170b_month_w1
codebook xivD_170b_year_w1
tab xD_92a_ever_HIV xivD_170b_month_w1
tab xD_92a_ever_HIV xivD_170b_year_w1 // no missing year among people reported they have HIV


gen Tested_for_HIV_in_last_90_days=.
replace Tested_for_HIV_in_last_90_days=1 if (xD_92a_ever_HIV==1 & xivD_170b_month_w1!="777" & xivD_170b_month_w1!="888")
replace Tested_for_HIV_in_last_90_days=0 if Tested_for_HIV_in_last_90_days!=1
tab Tested_for_HIV_in_last_90_days

// # c.	Known HIV-positive status – Question 93A: Coded=1 (yes) if said Yes; coded=0 (no) if said no
codebook xivD_171a_w1
gen xD_93A=0 
replace xD_93A=1 if xivD_171a_w1==1
label variable xD_93A "Have you ever been told that you are HIV positive?"
tab xD_93A

/* # d.	Initiated ART – Question 93C: Coded=1 (yes) if said Yes to Q93A AND said YES to Q93C. Otherwise coded=0 (no) if said Yes to Q93A AND NO to Q93C. Denominator here includes only women who said yes to Q93A. (i.e., HIV-positive women)
 xivD_171c_w1 represents Section 10D Q93A*/

gen Initiated_ART=.
replace Initiated_ART=1 if (xD_93A==1 & xivD_171c_w1==1)
replace Initiated_ART=0 if (xD_93A==1 & xivD_171c_w1==2)
tab Initiated_ART

// #e.	Initiated PrEP – Question 99B: Coded=1 (yes) if said Yes to Q99B and No to Q93A. Otherwise coded=0 (no) if said NO to Q99B or if said DON’T KNOW to Q99B, and said No to Q93A.        Denominator here includes only women who said No to Q93A (i.e., HIV-negative women).
// ## xD_93A: Have you ever been told that you are HIV positive?
// ## xv_177b_w1	Prior to this study, have you ever received a prescription for HIV pre-exposure 


gen Initiated_PrEP=.
replace Initiated_PrEP=1 if (xD_93A==0 & xv_177b_w1==1)
replace Initiated_PrEP=0 if (xD_93A==0 & xv_177b_w1!=1)
tab Initiated_PrEP


// # 3.	Care-seeking for financial support (Section 5A, Page 15)
// # a.	Used text messaging to receive/request employment (Q33.C.2): Coded=1 (yes) if said yes to Q33.C.2, otherwise coded=0 (no)
// ## vA_33c_2_w1	Have you used text messaging to receive or request any of the following? - Employment

codebook vA_33c_2_w1
gen vA_33c_2_w1_recoded=0
replace vA_33c_2_w1_recoded=1 if vA_33c_2_w1==1
label variable vA_33c_2_w1_recoded "Have you used text messaging to receive or request any of the following? - Employment"
tab vA_33c_2_w1_recoded

// # b.	Used text message to receive/request money or cash (Q33.C.3): Coded=1 (yes) if said yes to Q33.C.3, otherwise coded=0 (no)ㄥ

codebook vA_33c_3_w1
gen vA_33c_3_w1_recoded=0
replace vA_33c_3_w1_recoded=1 if vA_33c_3_w1==1
label variable vA_33c_3_w1_recoded "Have you used text messaging to receive or request any of the following? - Money"
tab vA_33c_3_w1_recoded

// # c.	Non-debt financial assistance from parents or relatives (Q45A): Coded=1 (yes) if said yes (or listed) “sent money by parents or relatives” to Q45. Otherwise coded=0 (no).

codebook vC_45_1_w1
gen vC_45_1_w1_recoded=0
replace vC_45_1_w1_recoded=1 if vC_45_1_w1==1
label variable vC_45_1_w1_recoded "Non-debt financial assistance from parents or relatives (Q45A): Coded=1 (yes) if said yes (or listed) “sent money by parents or relatives” to Q45. Otherwise coded=0 (no)"
tab vC_45_1_w1_recoded


// # d.	Debt-based financial assistance from community members (Q47 & Q49): Coded=1 (yes) if said yes to Q47 AND YES to Q49A, 49B, 49C, 49D or 49H (Co-workers,Family members,Neighbors,Paying partner/client, Boss/Manager). Otherwise coded=0 (no) if said no to Q47; or if said yes to Q47 but NO to all of Q49A, 49B, 49C, 49D and 49H.
codebook vC_47_w1
codebook vC_49_w1
gen debt_community_members=0
replace debt_community_members=1 if (vC_47_w1==1 & inrange(vC_49_w1,1,4) | vC_49_w1==8)
tab debt_community_members

//# e.	Debt-based financial assistance from lending institution or money lender/shop (Q47 & Q49): Coded=1 (yes) if said yes to Q47 AND YES to Q49E, 49F, or 49G. Otherwise coded=0 (no) if said no to Q47; or if said yes to Q47 but NO to all of Q49E, 49F, and 49G.
gen debt_institution=0
replace debt_institution=1 if (vC_47_w1==1 & inrange(vC_49_w1,5,7))
label variable debt_institution "Debt-based financial assistance from lending institution or money lender/shop (Q47 & Q49): Coded=1 (yes) if said yes to Q47 AND YES to Q49E, 49F, or 49G. Otherwise coded=0 (no) if said no to Q47; or if said yes to Q47 but NO to all of Q49E, 49F, and 49G."
tab debt_institution
 

 
*-------------------------------------------------------------------------------
* 
* Table 5: Baseline behavior characteristics of EA population 
*-------------------------------------------------------------------------------
* row sum
tabulate  ever_EA if sex_under_influence==0
tabulate  ever_EA if sex_under_influence==1
tabulate  ever_EA if Initiated_ART==0
tabulate  ever_EA if Initiated_ART==1
tabulate  ever_EA if Initiated_PrEP==0
tabulate  ever_EA if Initiated_PrEP==1
tabulate  ever_EA if xD_92a_ever_HIV==0
tabulate  ever_EA if xD_92a_ever_HIV==1
* ask family member for non-debt financial assistance
tabulate  ever_EA if vC_45_1_w1_recoded==0
tabulate  ever_EA if vC_45_1_w1_recoded==1

tabulate ever_EA if debt_institution==0
tabulate ever_EA if debt_institution==1


tabulate  ever_EA if Tested_for_HIV_in_last_90_days==0
tabulate  ever_EA if xD_93A==0


tabulate vA_33c_2_w1_recoded if ever_EA==1
tabulate vC_45_1_w1 if ever_EA==1
tabulate debt_community_members if ever_EA==1

* column sum
tabulate sex_under_influence if ever_EA==1
tabulate sex_with_condom if ever_EA==1
tabulate xD_92a_ever_HIV if ever_EA==1
tabulate Tested_for_HIV_in_last_90_days if ever_EA==1
tabulate xD_93A if ever_EA==1
tabulate Initiated_ART if ever_EA==1
tabulate Initiated_PrEP if ever_EA==1
tabulate vA_33c_2_w1_recoded if ever_EA==1
tabulate vC_45_1_w1 if ever_EA==1
tabulate debt_community_members if ever_EA==1
tabulate debt_institution if ever_EA==1

tabulate sex_under_influence if ever_EA==0
tabulate sex_with_condom if ever_EA==0
tabulate xD_92a_ever_HIV if ever_EA==0
tabulate Tested_for_HIV_in_last_90_days if ever_EA==0
tabulate xD_93A if ever_EA==0
tabulate Initiated_ART if ever_EA==0
tabulate Initiated_PrEP if ever_EA==0
tabulate vA_33c_2_w1_recoded if ever_EA==0
tabulate vC_45_1_w1 if ever_EA==0
tabulate debt_community_members if ever_EA==0
tabulate debt_institution if ever_EA==0
// Low tertile of EA
tabulate sex_under_influence if tertile_EA==1
tabulate sex_with_condom if tertile_EA==1
tabulate xD_92a_ever_HIV if tertile_EA==1
tabulate Tested_for_HIV_in_last_90_days if tertile_EA==1
tabulate xD_93A if tertile_EA==1
tabulate Initiated_ART if tertile_EA==1
tabulate Initiated_PrEP if tertile_EA==1
tabulate vA_33c_2_w1_recoded if tertile_EA==1
tabulate vC_45_1_w1 if tertile_EA==1
tabulate debt_community_members if tertile_EA==1
tabulate debt_institution if tertile_EA==1

// Middle tertile of EA
tabulate sex_under_influence if tertile_EA==2
tabulate sex_with_condom if tertile_EA==2
tabulate xD_92a_ever_HIV if tertile_EA==2
tabulate Tested_for_HIV_in_last_90_days if tertile_EA==2
tabulate xD_93A if tertile_EA==2
tabulate Initiated_ART if tertile_EA==2
tabulate Initiated_PrEP if tertile_EA==2
tabulate vA_33c_2_w1_recoded if tertile_EA==2
tabulate vC_45_1_w1 if tertile_EA==2
tabulate debt_community_members if tertile_EA==2
tabulate debt_institution if tertile_EA==2

// High tertile of EA
tabulate sex_under_influence if tertile_EA==3
tabulate sex_with_condom if tertile_EA==3
tabulate xD_92a_ever_HIV if tertile_EA==3
tabulate Tested_for_HIV_in_last_90_days if tertile_EA==3
tabulate xD_93A if tertile_EA==3
tabulate Initiated_ART if tertile_EA==3
tabulate Initiated_PrEP if tertile_EA==3
tabulate vA_33c_2_w1_recoded if tertile_EA==3
tabulate vC_45_1_w1 if tertile_EA==3
tabulate debt_community_members if tertile_EA==3
tabulate debt_institution if tertile_EA==3



 
tabulate ever_EA sex_under_influence, chi2
tabulate ever_EA sex_with_condom, chi2
tabulate ever_EA xD_92a_ever_HIV, chi2
tabulate ever_EA Tested_for_HIV_in_last_90_days, chi2
tabulate ever_EA xD_93A, chi2
tabulate ever_EA Initiated_ART, chi2
tabulate ever_EA Initiated_PrEP, chi2
tabulate ever_EA vA_33c_2_w1_recoded, chi2
tabulate ever_EA vC_45_1_w1, chi2
tabulate ever_EA debt_community_members, chi2
tabulate ever_EA debt_institution, chi2

*-------------------------------------------------------------------------------
* Table 5: Crude odds ratio between any EA and behavior variables
*-------------------------------------------------------------------------------

logistic ever_EA sex_under_influence
logistic ever_EA sex_with_condom
logistic ever_EA xD_92a_ever_HIV
logistic ever_EA Tested_for_HIV_in_last_90_days
logistic ever_EA xD_93A
logistic ever_EA Initiated_ART
logistic ever_EA Initiated_PrEP
logistic ever_EA vA_33c_2_w1_recoded
logistic ever_EA vC_45_1_w1
logistic ever_EA debt_community_members
logistic ever_EA debt_institution


// Crude odds ratio: economic abuse(medium vs low) and other variables
logistic EA_med_low sex_under_influence
logistic EA_med_low  sex_with_condom
logistic EA_med_low xD_92a_ever_HIV
logistic EA_med_low Tested_for_HIV_in_last_90_days
logistic EA_med_low xD_93A
logistic EA_med_low Initiated_ART
logistic EA_med_low Initiated_PrEP
logistic EA_med_low vA_33c_2_w1_recoded
logistic EA_med_low vC_45_1_w1
logistic EA_med_low debt_community_members
logistic EA_med_low debt_institution

// Crude odds ratio: economic abuse(high vs low) and other variables
logistic EA_high_low sex_under_influence
logistic EA_high_low sex_with_condom
logistic EA_high_low xD_92a_ever_HIV
logistic EA_high_low Tested_for_HIV_in_last_90_days
logistic EA_high_low xD_93A
logistic EA_high_low Initiated_ART
logistic EA_high_low Initiated_PrEP
logistic EA_high_low vA_33c_2_w1_recoded
logistic EA_high_low vC_45_1_w1
logistic EA_high_low debt_community_members
logistic EA_high_low debt_institution

*-------------------------------------------------------------------------------
* Table 5: Adjusted odds ratio between any EA and behavior variables by controlling age, education, and marital status
*-------------------------------------------------------------------------------
// Adjusted odds ratio: economic abuse(yes vs no) and other variables

logistic ever_EA sex_under_influence age_cat marital_status highest_edu
logistic ever_EA sex_with_condom age_cat marital_status highest_edu
logistic ever_EA xD_92a_ever_HIV age_cat marital_status highest_edu
logistic ever_EA Tested_for_HIV_in_last_90_days age_cat marital_status highest_edu
logistic ever_EA xD_93A age_cat marital_status highest_edu
logistic ever_EA Initiated_ART age_cat marital_status highest_edu
logistic ever_EA Initiated_PrEP age_cat marital_status highest_edu
logistic ever_EA vA_33c_2_w1_recoded age_cat marital_status highest_edu
logistic ever_EA vC_45_1_w1 age_cat marital_status highest_edu
logistic ever_EA debt_community_members age_cat marital_status highest_edu
logistic ever_EA debt_institution age_cat marital_status highest_edu

// Adjusted odds ratio: economic abuse(medium vs low) and other variables

logistic EA_med_low sex_under_influence age_cat marital_status highest_edu
logistic EA_med_low sex_with_condom age_cat marital_status highest_edu
logistic EA_med_low xD_92a_ever_HIV age_cat marital_status highest_edu
logistic EA_med_low Tested_for_HIV_in_last_90_days age_cat marital_status highest_edu
logistic EA_med_low xD_93A age_cat marital_status highest_edu
logistic EA_med_low Initiated_ART age_cat marital_status highest_edu
logistic EA_med_low Initiated_PrEP age_cat marital_status highest_edu
logistic EA_med_low vA_33c_2_w1_recoded age_cat marital_status highest_edu
logistic EA_med_low vC_45_1_w1 age_cat marital_status highest_edu
logistic EA_med_low debt_community_members age_cat marital_status highest_edu
logistic EA_med_low debt_institution age_cat marital_status highest_edu


// Adjusted odds ratio: economic abuse(high vs low) and other variables

logistic EA_high_low sex_under_influence age_cat marital_status highest_edu
logistic EA_high_low sex_with_condom age_cat marital_status highest_edu
logistic EA_high_low xD_92a_ever_HIV age_cat marital_status highest_edu
logistic EA_high_low Tested_for_HIV_in_last_90_days age_cat marital_status highest_edu
logistic EA_high_low xD_93A age_cat marital_status highest_edu
logistic EA_high_low Initiated_ART age_cat marital_status highest_edu
logistic EA_high_low Initiated_PrEP age_cat marital_status highest_edu
logistic EA_high_low vA_33c_2_w1_recoded age_cat marital_status highest_edu
logistic EA_high_low vC_45_1_w1 age_cat marital_status highest_edu
logistic EA_high_low debt_community_members age_cat marital_status highest_edu
logistic EA_high_low debt_institution age_cat marital_status highest_edu


**********  Larissa's Additional Analyses *************

*********************** NOTE: Adding in site variable as cluster variable for multilevel models *************
gen site=.
tab Site_ID__w1
replace site=1 if Site_ID__w1=="KYT01"
replace site=2 if Site_ID__w1=="KYT02"
replace site=3 if Site_ID__w1=="KYT03"
replace site=4 if Site_ID__w1=="KYT04"
replace site=5 if Site_ID__w1=="KYT05"
replace site=6 if Site_ID__w1=="KYT06"
replace site=7 if Site_ID__w1=="KYT07"
replace site=8 if Site_ID__w1=="KYT08"
replace site=9 if Site_ID__w1=="KYT09"
replace site=10 if Site_ID__w1=="KYT10"
replace site=11 if Site_ID__w1=="KYT11"
replace site=12 if Site_ID__w1=="KYT12"
replace site=13 if Site_ID__w1=="KYT13"
replace site=14 if Site_ID__w1=="KYT14"
replace site=15 if Site_ID__w1=="KYT15"
replace site=16 if Site_ID__w1=="KYT16"
replace site=17 if Site_ID__w1=="KYT17"
replace site=18 if Site_ID__w1=="KYT18"
replace site=19 if Site_ID__w1=="KYT19"
tab site, missing


**********   NOTE: Showing example how to get percentages correct for Table 3 ************

tab age_cat ever_EA
tab age_cat ever_EA, row missing

*** Note: Creating EA_tertile high, med, low with all 3 groups in one variable
gen eatertile_allthree=0 if EA_med_low==0
replace eatertile_allthree=1 if EA_med_low==1
replace eatertile_allthree=2 if EA_high_low==1

tab eatertile_allthree, missing
tab age_cat eatertile_allthree, row missing

************* NOTE: Above command was row percentages with all-three EA variable *************
tab age_cat eatertile_allthree, row missing chi2





***************** NOTE: Bing-Jie calculated condomless sex with most recent partner only. I want to include two most recent partners. ******
***************** NOTE: Use these two sex variables for the manuscript ******************************


********* Variable for Condomlesssex (Continuous - Mean Number of Times) ------- TABLE 5 --------     ************

* xA_93a_w1: number of times with most recent partner
* xA_93b_w1: number of times with intimate partner
gen numberofsexepisodesinlast30days=.
replace numberofsexepisodesinlast30days= xA_93a_w1+ xA_93b_w1
label variable numberofsexepisodesinlast30days "In the past 30 day, number of time having sex with most recent #1 and  most recent partner #2"

* generate number of times without condom with most recent patner # 1 and most recent patner # 2
* xA_96a_w1: number of times the condoms are used with partner #1
* xA_96b_w1: number of times the condoms are used with partner #2

gen numbercondomONsexinlast30days= xA_96a_w1+ xA_96b_w1

gen numbercondomlesssexinlast30days=.
replace numbercondomlesssexinlast30days=numberofsexepisodesinlast30days - numbercondomONsexinlast30days
label variable numbercondomlesssexinlast30days "In the past 30 day, number of time having sex not using condoms with most recent #1 and  most recent partner #2"
tab numbercondomlesssexinlast30days, missing

sum numbercondomlesssexinlast30days if numbercondomlesssexinlast30days>0

sum numbercondomlesssexinlast30days if ever_EA==0 & numbercondomlesssexinlast30days>0
sum numbercondomlesssexinlast30days if ever_EA==1 & numbercondomlesssexinlast30days>0

sum numbercondomlesssexinlast30days if eatertile_allthree==0 & numbercondomlesssexinlast30days>0
sum numbercondomlesssexinlast30days if eatertile_allthree==1 & numbercondomlesssexinlast30days>0
sum numbercondomlesssexinlast30days if eatertile_allthree==2 & numbercondomlesssexinlast30days>0

ttest numbercondomlesssexinlast30days if numbercondomlesssexinlast30days>0, by(ever_EA)
regress numbercondomlesssexinlast30days ever_EA if numbercondomlesssexinlast30days>0

** NOTE: Above commands to get mean number of condomless sex acts **




*********  Mean # of condomless sex acts for Table 5 (Crude and Adjusted) **********

regress numbercondomlesssexinlast30days ever_EA if numbercondomlesssexinlast30days>0
mixed numbercondomlesssexinlast30days ever_EA if numbercondomlesssexinlast30days>0 || site:
mixed numbercondomlesssexinlast30days ever_EA if numbercondomlesssexinlast30days>0 || site:

mixed numbercondomlesssexinlast30days i.eatertile_allthree if numbercondomlesssexinlast30days>0 || site:

** The above command is what I used in Table 5 for mean number of condomless sex acts (crude) across the three EA groups
mixed numbercondomlesssexinlast30days i.eatertile_allthree age_cat marital_status highest_edu if numbercondomlesssexinlast30days>0 || site:
** The above command is what I used in Table 5 for mean number of condomless sex acts (adjusted) across the three EA groups


********* Variable for Condomlesssex (Binary) ************

gen condomlesssexinlast30days=1 if numbercondomlesssexinlast30days>0
replace condomlesssexinlast30days=0 if numbercondomlesssexinlast30days==0
replace condomlesssexinlast30days=1 if numbercondomlesssexinlast30days>0

*replace condomlesssexinlast30days=1 if numbercondomlesssexinlast30days<0
tab condomlesssexinlast30days, missing
tab  ever_EA if condomlesssexinlast30days==0
tab  ever_EA if condomlesssexinlast30days==1

melogit condomlesssexinlast30days ever_EA || site:

***************** For Table 4
tab condomlesssexinlast30days, missing







*** NOTE: Now doing same things for mean number of sex while high/drunk acts using last two partners



********* Variable for Sex While Drunk/High (Continuous - Mean Number of Times) ************

gen numbersexwithdrugsalchol= xA_95a_w1+ xA_95b_w1
tab numbersexwithdrugsalchol
replace numbersexwithdrugsalchol= . if numbersexwithdrugsalchol>=777

*replace numbersexwithdrugsalchol= numbersexwithdrugsalchol-770 if numbersexwithdrugsalchol>100
tab numbersexwithdrugsalchol, missing
sum numbersexwithdrugsalchol

** Note: Fixed data entry error of removing preceding '7' ***

sum numbersexwithdrugsalchol if numbersexwithdrugsalchol<100
sum numbersexwithdrugsalchol if ever_EA==0 & numbersexwithdrugsalchol<100
sum numbersexwithdrugsalchol if ever_EA==1 & numbersexwithdrugsalchol<100


regress numbersexwithdrugsalchol ever_EA if numbersexwithdrugsalchol<100
mixed numbersexwithdrugsalchol ever_EA if numbersexwithdrugsalchol<100 || site:
***The above is correct command for crude


mixed numbersexwithdrugsalchol i.eatertile_allthree if numbersexwithdrugsalchol<100 || site:
** The above command is what I used in Table 5 for mean number of sex acts while high/drunk across the three EA groups
mixed numbersexwithdrugsalchol i.eatertile_allthree age_cat marital_status highest_edu if numbersexwithdrugsalchol<100 || site:


********* Variable for Sex While Drunk/High (Binary) ************

gen sexwithdrugsalchol=1 if numbersexwithdrugsalchol>=1
replace sexwithdrugsalchol=0 if numbersexwithdrugsalchol==0


*** For Table 4

tab sexwithdrugsalchol, missing
tab condomlesssexinlast30days, missing
*** Below are commands for new condomlesssex variable and new sexwhile drunk/high variable


*---------------------------------------------------------------------------------------------------------------------
* FOR TABLE 5 (Crude & Adjusted) --- Larissa's New Condomless Sex Binary Variable + Sex While Drunk/High Binary Variable 
*---------------------------------------------------------------------------------------------------------------------

* Condomless sex 
tab ever_EA if condomlesssexinlast30days==0, missing
tab ever_EA if condomlesssexinlast30days==1, missing

tab eatertile_allthree if condomlesssexinlast30days==0, missing
tab eatertile_allthree if condomlesssexinlast30days==1, missing


melogit ever_EA condomlesssexinlast30days || site: , or
melogit ever_EA condomlesssexinlast30days age_cat highest_edu marital_status || site: , or



melogit EA_med_low condomlesssexinlast30days || site: , or
melogit EA_high_low condomlesssexinlast30days || site: , or

melogit EA_med_low condomlesssexinlast30days age_cat highest_edu marital_status || site: , or
melogit EA_high_low condomlesssexinlast30days age_cat highest_edu marital_status || site: , or

* Mean number of condomless sex
** WHAT ARE WE LOOKING FOR HERE? 
melogit ever_EA numbercondomlesssexinlast30days || site: , or
mixed numbercondomlesssexinlast30days ever_EA if numbercondomlesssexinlast30days>0 || site:


melogit ever_EA condomlesssexinlast30days age_cat highest_edu marital_status || site: , or
mixed numbercondomlesssexinlast30days ever_EA age_cat highest_edu marital_status if numbercondomlesssexinlast30days>0 || site:

* Sex while high with drugs or alcohol
tab sexwithdrugsalchol  ever_EA, row missing
tab sexwithdrugsalchol  eatertile_allthree, row missing

melogit ever_EA sexwithdrugsalchol || site: , or
melogit ever_EA sexwithdrugsalchol age_cat highest_edu marital_status || site: , or

melogit EA_med_low sexwithdrugsalchol || site: , or
melogit EA_high_low sexwithdrugsalchol || site: , or

melogit EA_med_low sexwithdrugsalchol age_cat highest_edu marital_status || site: , or
melogit EA_high_low sexwithdrugsalchol age_cat highest_edu marital_status || site: , or

* Mean # of times having sex while high with drugs or alcohol
** WHAT ARE WE LOOKING FOR HERE? 
*melogit ever_EA numbersexwithdrugsalchol || site: , or
mixed numbersexwithdrugsalchol ever_EA if numbersexwithdrugsalchol<100 || site:
mixed numbersexwithdrugsalchol ever_EA age_cat highest_edu marital_status if numbersexwithdrugsalchol<100 || site:

mixed numbersexwithdrugsalchol i.eatertile_allthree if numbersexwithdrugsalchol<100 || site:
mixed numbersexwithdrugsalchol i.eatertile_allthree age_cat highest_edu marital_status if numbersexwithdrugsalchol<100 || site:

* Initiate ART
melogit ever_EA Initiated_ART || site: , or
melogit ever_EA Initiated_ART age_cat highest_edu marital_status|| site: , or

* Initiate PrEP
melogit ever_EA Initiated_PrEP || site: , or
melogit ever_EA Initiated_PrEP age_cat highest_edu marital_status|| site: , or


*** Now working on fixing had HIV test variable
codebook xivD_171a_w1
gen hivpositive=1 if xivD_171a_w1==1
tab xivD_170a_w1
codebook xivD_170a_w1 
tab xivD_170a_w1 if hivpositive==1
drop hivpositive
gen hivpositive=1 if xivD_171a_w1==1
replace hivpositive=0 if hivpositive==.
tab xivD_170a_w1 if hivpositive==0
**The above command is ever HIV tested for HIV negstive people. But we need to look at within last 90 days.

tab Tested_for_HIV_in_last_90_days
tab Tested_for_HIV_in_last_90_days if hivpositive==1
tab Tested_for_HIV_in_last_90_days if hivpositive==0
** Ok, last command is correct
tab ever_EA if Tested_for_HIV_in_last_90_days==0 & hivpositive==0
tab ever_EA if Tested_for_HIV_in_last_90_days==1 & hivpositive==0

tab eatertile_allthree if Tested_for_HIV_in_last_90_days==0 & hivpositive==0, missing
tab eatertile_allthree if Tested_for_HIV_in_last_90_days==1 & hivpositive==0, missing


melogit ever_EA Tested_for_HIV_in_last_90_days if hivpositive==0|| site: , or
melogit ever_EA Tested_for_HIV_in_last_90_days age_cat highest_edu marital_status if hivpositive==0|| site: , or

melogit EA_med_low Tested_for_HIV_in_last_90_days if hivpositive==0|| site: , or
melogit EA_high_low Tested_for_HIV_in_last_90_days if hivpositive==0|| site: , or

melogit EA_med_low Tested_for_HIV_in_last_90_days age_cat highest_edu marital_status if hivpositive==0|| site: , or
melogit EA_high_low Tested_for_HIV_in_last_90_days age_cat highest_edu marital_status if hivpositive==0|| site: , or

* Non-finantial debt from parents or relatives 
tab ever_EA if vC_45_1_w1_recoded==0
tab ever_EA if vC_45_1_w1_recoded==1

tab eatertile_allthree if vC_45_1_w1_recoded==0, missing
tab eatertile_allthree if vC_45_1_w1_recoded==1, missing


melogit ever_EA vC_45_1_w1_recoded || site: , or
melogit ever_EA vC_45_1_w1_recoded age_cat highest_edu marital_status|| site: , or

melogit EA_med_low vC_45_1_w1_recoded || site: , or
melogit EA_high_low vC_45_1_w1_recoded || site: , or

melogit EA_med_low vC_45_1_w1_recoded age_cat highest_edu marital_status || site: , or
melogit EA_high_low vC_45_1_w1_recoded age_cat highest_edu marital_status || site: , or


* debt from lending institution
tab ever_EA if debt_institution==0
tab ever_EA if debt_institution==1

tab eatertile_allthree if debt_institution==0, missing
tab eatertile_allthree if debt_institution==1, missing


melogit ever_EA debt_institution || site: , or
melogit ever_EA debt_institution age_cat highest_edu marital_status|| site: , or

melogit EA_med_low debt_institution || site: , or
melogit EA_high_low debt_institution || site: , or

melogit EA_med_low debt_institution age_cat highest_edu marital_status || site: , or
melogit EA_high_low debt_institution age_cat highest_edu marital_status || site: , or

*** This is the right command to use for HIV test in last 90 days among HIV-negative individuals only.
tab xviiB_206a_w1
melogit EA_high_low xviiB_206a_w1 age_cat highest_edu marital_status || site: , or

capture log close


































	
capture log close
