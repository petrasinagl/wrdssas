%let path = C:\Users\andrlikova\Dropbox\Test\SAS\;   /* change this to reflect your directory */

libname data "&path.Data";
libname out "&path.Out";

%let wrds = wrds.wharton.upenn.edu 4016;
signon wrds username = _prompt_;

/* Download Compustat Data */
rsubmit;
data comp_data_test;
    set compd.secd(obs=1000);
    where  exchg in (11,12,14) and tpci eq "0" and year(datadate) eq 2020 and month(datadate) eq 5;
run;
proc download data=comp_data_test out=data.comp_data_test; run;
endrsubmit;

rsubmit;
data names;
    set comp.names;
    where year2 in (.,2019,2020);  /* select only firms active in 2019 and 2020 */
run;
proc download data=names out=data.names; run;
endrsubmit;

/* Upload Your Data to WRDS Cloud */
rsubmit; 
proc upload data=data.test out=test; run;
endrsubmit;

/* When finished -> Sign off WRDS */
signoff;

/* Export Data in CSV Format */
proc export data= out.comp_data_test
	outfile= "&path.Out\comp_data_test.csv" replace
	dbms=CSV replace;
run;

/* Run Python Code */

/* This code downloads Treasury Bill data from the US Department of Treasury (real-time) */
data _null_;
    infile "python &path.Script\scrape.py &path.Data\rf_new.csv" pipe;
    input;
    put _infile_;
run;

PROC IMPORT OUT= data.rf
    DATAFILE= "&path.Data\rf_new.csv"
    DBMS=csv REPLACE ;
GETNAMES=YES;
RUN;

data data.rf;
    set data.rf ;
    format date YYMMDD8. ;
run;