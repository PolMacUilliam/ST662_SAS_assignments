/*********************************************************************************************************/
/* ST662 Topics in Data Analytics
/* Student: Paul Williamson
/* Student ID: 18145469

/* Assignment Sheet 1:

/* There are 5 variables in the Toenail dataset as follows:
/* ID: a unique identifier for each patient.
/* Time: the time point at which the response was recorded. This was either 0, 1, 2, 3, 6, 9 or 12 months.
/* Treat: The treatments were coded 1 or 0.
/* Gender: Male or Female.
/* y: the response recorded was that the infection was present (1) or not (0).
/*********************************************************************************************************/

/* (a) Read the data into your ST662 SAS library.*/

PROC IMPORT OUT=ST662LIB.toenail1	/* permanent copy in ST662 library */
	DATAFILE="/home/polmacuilliam10/ST662/Datasets/Toenail.xlsx" 
	DBMS=XLSX REPLACE;
	GETNAMES=YES;
RUN;

/* (b) Create a variable in your dataset that is unique for each row of data. Do this using following code: */

data ST662LIB.toenail2; /* create copy of the original dataset to work with */
	set ST662LIB.toenail1; /* original dataset */
	Obs = _n_; /* New variable called 'Obs' */
run;

/* (c) Create SAS code to screen the data for any anomalies. */

/* (d) Create SAS code to deal with any anomalies that you have found. I.e. generate code to either */
/*     change the observation (if there is an obvious error) or to mark the observation as missing. */

/***************************************************************************************/
/**********************************    Variable: ID    *********************************/

/* Get frquency count of ID occurences in the dataset */
proc freq data=ST662LIB.toenail2;
	tables ID / nocum nopercent;
run;

/* FREQ function has revealed that the range of IDs in the dataset is from 1-294 with one exception - ID:722. */
/* ID:722 also has a frequency of occurance in the dataset of 1. Given that the range is otherwise contiguous, it's */
/* likely that this ID entry has been input incorrectly. Possible correct entries then are either 227 or 272. */

/* Let's take a closer look at rows with ID's 227, 272 and 722: */

DATA sample_subset; /* create a temp subset of dataset in the work library folder */
   SET ST662LIB.toenail2;
   IF (ID = 227 OR ID = 272 OR ID = 722) THEN OUTPUT; /* use only IDs 227, 272 & 722 */
RUN;

/* ID:722 occurs at Obs:1758. This is between Obs:1757 and Obs:1759, both of which has ID:272. */
/* Also the gender entries for IDs, 272  & 722 are both 'female' and 227 has an gender entry of 'male'. */
/* Both of these conditions would suggest that the correct entry for '772' should be '272'. */

data ST662LIB.toenail2;
	set ST662LIB.toenail2;
	if ID = 722 then ID = 272 ; /* make correction to invalid ID:722 */
run;

/* Running code @ lines 40-42 indicates that the correction has been made */
/* i.e. ID:722 no longer exists and ID:272 now has 7 entries in dataset */


/***************************************************************************************/
/**********************************    Variable: TIME    *******************************/

/* Get frquency count of TIME occurences in the dataset */
proc freq data=ST662LIB.toenail2;
	tables TIME / nocum nopercent;
run;

/* Returns freq of occurence of each TIME value in range 1-12 again with one exception - 13 with freq = 1 */
/* Given that TIME should have a value from set (0,1,2,3,6,9,12) then 13 is an invalid entry for this variable. */

/* Taking a closer look at obs with TIME=13 */
DATA sample_subset; /* create a temp subset of dataset in the work library folder */
   SET ST662LIB.toenail2;
   IF (TIME = 13) THEN OUTPUT; /* use TIME = 12 or 13 */
RUN;

/* From above, obs with TIME=13 occurs with ID = 55, so let's take a closer look at all obs with ID = 55 */
DATA sample_subset; /* create a temp subset of dataset */
   SET ST662LIB.toenail2;
   IF (ID = 55) THEN OUTPUT; /* use ID = 55 */
RUN;

/* From above, the group of obs with ID = 55, seems to be missing a TIME value of 12. Instead 13 is entered. */
/* This could be an obvious entry error (i.e. 13 instead of 12). The correction is similar to code @ lines 56-59. */

data ST662LIB.toenail2;
	set ST662LIB.toenail2;
	if (ID = 55 AND TIME = 13) then TIME = 12; /* make correction to invalid TIME:13 entry at ID=55 */
run;

/* Running code @ lines 72-74 indicates that the correction has been made */
/* i.e. TIME value 13 has been replaced with value 12 @ ID = 55 */


/***************************************************************************************/
/**********************************    Variable: TREAT    ******************************/

/* Get frquency count of TREAT occurences in the dataset */
proc freq data=ST662LIB.toenail2;
	tables TREAT / nocum nopercent;
run;

/* Yields freq of occurence of each TREAT value in range 0-1 again with one exception - A with freq = 1 */
/* Given that TREAT should have a value from set (0,1) then 'A' is an invalid entry for this variable. */

/* Taking a closer look at obs with TREAT='A' */
DATA sample_subset; /* create a temp subset of dataset in the work library folder */
   SET ST662LIB.toenail2;
   IF (TREAT = 'A') THEN OUTPUT; /* use TREAT = 'A' */
RUN;

/* From above, obs with TREAT = 'A' occurs with ID:163, so let's take a closer look at all obs with ID:163 */
/* Lets also include ID:162 and ID:164 to see if it helps with context */
DATA sample_subset; /* create a temp subset of dataset */
   SET ST662LIB.toenail2;
   IF (ID = 162 OR ID = 163 OR ID = 164) THEN OUTPUT; /* use ID = 162, 163 or 164 */
RUN;

/* Having looked closer at the data with IDs 162, 163 and 164, it can be seen that the TREAT value would seem to be */
/* consistent for each individual ID i.e. either it is ALL 0's or ALL 1's. Given that, this suggests that it should */
/* be appropriate to correct the invalid entry - changing it to the same value as the rest of the TREAT entries for that */
/* ID:163 = 0 */

data ST662LIB.toenail2;
	set ST662LIB.toenail2;
	if (ID = 163 AND TREAT = 'A') then TREAT = 0; /* make correction to invalid TREAT = 'A' entry at ID=163 */
run;

/* Running code @ lines 107-109 indicates that the correction has been made */
/* i.e. TREAT = 'A' has been replaced with value 0 @ ID = 163 */


/***************************************************************************************/
/**********************************    Variable: GENDER    *****************************/

/* Get frquency count of TREAT occurences in the dataset */
proc freq data=ST662LIB.toenail2;
	tables GENDER / nocum nopercent;
run;

/* Yields freq of occurence of each GENDER value either 'Female' or 'Male' again with one exception - A with freq = 8 */
/* Given that GENDER should have a value 'Female' or 'Male' then 'A' is an invalid entry for this variable. */

/* Taking a closer look at obs with GENDER='A' */
DATA sample_subset; /* create a temp subset of dataset */
   SET ST662LIB.toenail2;
   IF (GENDER = 'A') THEN OUTPUT; /* use GENDER = 'A' */
RUN;

/* Having looked closer at all the obs with gender = 'A', there are two IDs involved - ID:174 and ID:252. */

/* Looking at ID:174 first: */
DATA sample_subset; /* create a temp subset of dataset */
   SET ST662LIB.toenail2;
   IF (ID = 174) THEN OUTPUT; /* use ID = 174 */
RUN;

/* Having looked at ID:174 above, because all gender entries (bar one) are 'Female, this is an easy fix...*/
/* replace gender='A' with gender='Female' for ID:174 */
data ST662LIB.toenail2;
	set ST662LIB.toenail2;
	if (ID = 174 AND GENDER = 'A') then GENDER = 'Female'; /* make correction to invalid GENDER = 'A' entry at ID=174 */
run;

/* Looking at ID:252 next: */
DATA sample_subset; /* create a temp subset of dataset */
   SET ST662LIB.toenail2;
   IF (ID = 252) THEN OUTPUT; /* use ID = 252 */
RUN;

/* Having looked at all obs for ID:252, this is a more difficult correction to make as all gender entries for this ID */
/* have been entered incorrectly. Without further information it's not possible to discern from the dataset what is the */
/* correct value to input. From the instructions the only option left is to mark the gender variable for all the */
/* observations with ID:252 as 'missing' or blank '' */
data ST662LIB.toenail2;
	set ST662LIB.toenail2;
	if (ID = 252 AND GENDER = 'A') then GENDER = ''; /* mark invalid GENDER missing for entry at ID=252 */
run;

/* Running code @ lines 174-177 indicates that the obs with ID:252 have had gender variable marked blank ' ' */
/* i.e. GENDER = 'A' has been replaced with value '' @ ID = 252 */


/***************************************************************************************/
/**********************************    Variable: y    **********************************/

/* Get frquency count of TREAT occurences in the dataset */
proc freq data=ST662LIB.toenail2;
	tables y / nocum nopercent;
run;

/* Returns freq of each y value either 0 or 1 this time with two exceptions: there's two entries 4 & 5 w/freq = 1 each */
/* Given that y should have a value 0 or 1 then 4 and 5 are invalid entries for variable y */

/* Taking a closer look at obs with y = 4 or y = 5 */
DATA sample_subset; /* create a temp subset of dataset */
   SET ST662LIB.toenail2;
   IF (y = 4 OR y = 5) THEN OUTPUT; /* use y = 4 or 5 */
RUN;

/* Above indicates that there are two IDs involved - ID:67 and ID123 */

/* Looking at those IDs */
DATA sample_subset; /* create a temp subset of dataset */
   SET ST662LIB.toenail2;
   IF (ID = 67 OR ID = 123) THEN OUTPUT; /* use ID = 67 or 123 */
RUN;

/* At first glance both of these entries would seem to be easy fixes. However, because of the nature of the variable, */
/* making assumptions about the data and correctly interpreting it this time may be more difficult. This variable */
/* indicates the presence of infection. */

/* With ID:67, a male with 7/7 entries for TIME (response records), only the last 'y' entry is incorrect i.e. 'y' = 5 */
/* This could be easily replaced with a 0, which is consistent with all other y values (presense of infection) for this */
/* ID:67. However note the TREAT entry for this ID is 0. Without more information this might mean that this patient */ 
/* received no treatment. In which case with a common infection such as TDO it's entirely possible that the 'y' value */
/* would be 1 (infection present). It's not possible to accurately discern a correct 'y' value 0 or 1 for Obs:412 */

/* With ID:123, also a male with 7/7 entries for TIME (response records), Obs:784 at TIME:2 is incorrect i.e. 'y' = 4 */
/* However, at the start of the experiment it seems this patient presented already with a TDO infection ('y' = 1) */
/* The 'y' response value changed between TIME:1 & TIME:3 but it's not possible to discern from the dataset whether the */
/* response at TIME:2 should be 1 (infected) or 0 (not infected). */

/* In light of both situations above, the only option left is to mark both entries as missing data i.e. ' . ' */
data ST662LIB.toenail2;
	set ST662LIB.toenail2;
	if (ID = 67 AND y = 5) OR (ID = 123 AND y = 4) then y = .; /* mark invalid as missing*/
run;

/* Running code @ lines 212-215 indicates that the obs with ID:67 & ID:123 have had 'y' variable marked as missing '.' */
/* i.e. y = 4 or y = 5 has been replaced with y value = '.' @ ID:67 and ID:123 */