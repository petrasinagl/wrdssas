%let path = C:\Users\andrlikova\Dropbox\Test Project\SAS\;

libname data "&path.Data";
libname out "&path.Out";

%let wrds = wrds.wharton.upenn.edu 4016;
signon wrds username = _prompt_;

/* Download Compustat Data */

rsubmit;
data comp_data_test;
set compd.secd;
where  exchg in (11,12,14) and tpci eq "0" year(datadate) ge 2020 and and month(datadate) eq 5;
run;
proc download data=comp_data_test out=data.comp_data_test; run;
endrsubmit;

rsubmit;
data names;
set comp.names;
where year2 in (.,2019,2020);
run;
proc download data=names out=data.names; run;
endrsubmit;

/* Upload Your Data to WRDS Cloud */

