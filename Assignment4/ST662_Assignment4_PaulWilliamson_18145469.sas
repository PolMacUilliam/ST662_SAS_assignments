/*********************************************************************************************************/
/* ST662 Topics in Data Analytics
/* Student: Paul Williamson
/* Student ID: 18145469

/* Assignment Sheet 4:
/*********************************************************************************************************/

/***************************************************************************************/
/* Question 1
/***************************************************************************************/

/* The dataset Dates.csv contains 3000 dates from years 2000 to 2015. Read it into SAS.*/
proc import OUT=ST662LIB.dates (replace=yes) /* permanent copy in ST662 library */
	datafile="/home/polmacuilliam10/ST662/Datasets/Dates.csv" 
	dbms=CSV replace;
	getnames=YES;
run;

/* (a) Create a new variable which contains the date in format DD/MM/YYYY.*/

data ST662LIB.dates; /* create new column full_date */
	set ST662LIB.dates;
	Full_date = mdy(Month, Day, Year);
	format Full_date ddmmyys10.;
run;

/* (b) Write code to screen the dataset. */

data ST662LIB.dates; /* screen for le or ge specific dates and non-date values */
	set ST662LIB.dates;
	if (full_date le '31dec1999'd) or (full_date ge '1jan2016'd) or (full_date = .)
	then error = 1; else error = 0; /* add error column */
run;

/* (c) List any errors identified. */

data ST662LIB.dates_errors; /* list all errors with full_date */
title "Q1c. All Errors in 'Dates' file detected";
	set ST662LIB.dates;
	where error = 1;
run;

proc print data = ST662LIB.dates_errors;
run;


/***************************************************************************************/
/* Question 2
/***************************************************************************************/

/* 2. The dataset Bricks.csv contains information on Australian quarterly clay brick production from
1956 to 1994. Read the data into SAS. */

proc import OUT=ST662LIB.bricks (replace=yes) /* permanent copy in ST662 library */
	datafile="/home/polmacuilliam10/ST662/Datasets/Bricks.csv" 
	dbms=CSV replace;
	getnames=YES;
run;

/* (a) Create a single date variable from the year and quarter variables, and format it so that it
       reads as quarterly data. Hint: explore the YYQ function and format 'yyqs8.'.*/

data ST662LIB.bricks_QTRLY; /* create new column full_date */
	set ST662LIB.bricks;
	YrQtr = yyq(Year, Quarter);
	format YrQtr yyqs8.;
	BricksT = Bricks; /* line used to 'move' Bricks var to right of new YrQtr var */
	keep YrQtr BricksT;
	rename BricksT=Bricks;
run;

/*******************************************************************************************/

/* (b) Create a time series plot of the data and comment (briefly - one to two sentences) on the
effects (or not) of season, cycle and trend. */

proc sgplot data=ST662LIB.bricks_QTRLY;
	title h=12pt 'Q2b. Time Series - Quarterly Bricks Production 1956-1994';
	series x=YrQtr y=Bricks / markers lineattrs = (thickness=0.2) transparency=0.1;
	keylegend / noborder valueattrs=(Size=14pt);
	xaxis labelattrs=(size=12pt) valueattrs=(Size=14pt) label = 'Year-Qtr';
	yaxis labelattrs=(size=12pt) valueattrs=(Size=14pt) label = 'No. Bricks';
run;

ods escapechar='^';
data _null_;
file print;
title "Q2b. Comment on the effects of season, cycle and trend";
put 'There appears to be a seasonal peak in production each year during the 
third quarter (Jul-Sept) which is perhaps expected since the demand probably 
also increases during that period. This accounts for the annual variability.';
put '^';
put 'The overall trend seems to have been upward from 1956 until a peak of about 
1981. Between 1980/1 and 1983/4 there was a sharp decline in production which 
reversed again around 1984/5. Production peaked again slightly during the third 
qtr of 1986 and again in 1990 & from 1991 onwards there appears to have been 
a steady increase in production.';
run;
title;

/*******************************************************************************************/

/* (c) Use an appropriate exponential smoothing method to forecast to the end of */
/* 1996. In your answer, state which type of exponential smoothing you used and why, */
/* provide a graph illustrating the forecasts, and give a table of the forecasts with */
/* confidence limits. */

/* Holt - for trend without seasonal

proc esm data= ST662LIB.bricks_QTRLY 
	out = ST662LIB.BricksNext2yrs print = forecasts plot = (forecasts)
	lead = 9 print = estimates;
	id YrQtr interval=qtr;
	forecast Bricks / model = linear transform = log;
run;
*/

/* HOLT-Winters - for trend AND seasonal */

proc esm data= ST662LIB.bricks_QTRLY 
	out = ST662LIB.BricksNext2yrs print = forecasts plot = (forecasts)
	lead = 9 print = estimates;
	id YrQtr interval=qtr;
	forecast Bricks / model = addwinters transform = log;
run;

ods escapechar='^';
data _null_;
file print;
title "Q2c. Exponential Smoothing";
put 'I used the Holt-Winters exponential smoothing model because this is suited to data that 
exhibits a trend and a seasonal component to it - both of which the bricks data has.';
run;

/***************************************************************************************/
/* Question 3
/***************************************************************************************/

/* 3. The dataset LakeHuron.csv contains annual depth measurements at a specifc site on Lake Huron
from 1875 to 1972. Read the data into SAS. */

proc import OUT=ST662LIB.lake_huron (replace=yes) /* permanent copy in ST662 library */
	datafile="/home/polmacuilliam10/ST662/Datasets/LakeHuron.csv" 
	dbms=CSV replace;
	getnames=YES;
run;

/* (a) Create four new variables that contain the time series depth measurements at lag 1 to 4. */

data work.lake_huron_lag1to4;
	set ST662LIB.lake_huron;
	depth_lag1 = lag1(Depth);
	depth_lag2 = lag2(Depth);
	depth_lag3 = lag3(Depth);
	depth_lag4 = lag4(Depth);
run;

/* (b) Generate scatterplots of depth versus each lag variable. */

/*
proc sgplot data=work.lake_huron_lag1to4;
	scatter x=Depth y=depth_lag1 / DATALABEL = depth_lag1
	markerattrs=(symbol=circlefilled size=2mm) datalabelattrs=(family='Times New Roman' size=12pt);	
	yaxis label = 'depth_lag1';
	xaxis label = 'Depth';
run;
*/

proc sgscatter data=work.lake_huron_lag1to4;
  title "Q3b. Scatterplot Matrix for lake_huron_lag1to4";
  matrix Depth depth_lag1 depth_lag2 depth_lag3 depth_lag4;
run;
title;

/* (c) Comment on autocorrelation in the data. */

ods escapechar='^';
data _null_;
   	file print;
   	title "Q3c. Autocorrelation - between depth and lagged depth values";
put 'There is some evidence of autocorrelation between the Depth variable and a number of its
lagged counterparts. From the scatterplots there is strong correlation between Depth and
Depth_lag1 variable - lagged by 1 observation. Moving to the next plot in the matrix, there
is still some signs of correlation between Depth and variable Depth_lag2 - lagged by 2 observations.
However, the correlation appears to be reduced from that of Depth_lag1.';
put '^';
put 'For variables Depth_lag3 and Depth_lag4, the correlation is very weak. In fact it is not clear from
either of the plots that there is any correlation at all between them and the original Depth var.';
put '^';
put 'The further away in the data from the original variable the less correlation is present.';
run;
title;