
**********************************************************************************************************************************;
*Statistician: Grisell Diaz-Ramirez                                                                                               ;
*Purpose:  Create dataset with cognitive variables dementia predicted probability and composite memory score for waves 1995-2020  ;
*          using Wu et. al, 2012                                                                                                  ;
*Background: Paper used the ADAMS subsample (age 70+, non-Hispanic, n=745) to develop prediction models for dementia predicted    ;
*            probability score and a composite continuous memory score on the basis of either proxy or direct assessments         ;
*            in HRS core interviews. Then, they used the prediction models (the beta coefficients) to estimate                    ;
*            dementia probability scores and memory score for each assessment among the oldest respondents in HRS cohort followed ;
*            biennially from 1995 through 2008. To provide evidence of the validity of their predicted scores, they estimated     ; 
*            average dementia probability and composite memory score (standardized using the 1995 mean and SD) at each interview  ;
*            wave from 1995 to 2008 for non-Hispanic HRS cohort members born 1923 or earlier (72 or older in 1995).               ;
*            The biggest pro of this method is being able to retain the people who use proxies since those people who do not      ;
*            participate in direct cognitive assessments may be those experiencing the greatest cognitive decline                 ;
*Completed: 2025.11.07                                                                                                            ;	
*Input datasets: cogimp9220a_r: HRS Cognition Imputations 1992-2020, May 2023 (Final V3.0)                                        ;
*                randhrs1992_2022v1: RAND HRS Longitudinal File 2022 (V1), May 2025                                               ;
*                trk2022tr_r: 2022 Tracker Early Version 2.0, November 2024                                                       ;
*                RAND Fat files: 1992-2020                                                                                        ;
*Output datasets: cogvars_gdr_20251107, cogvarsred_gdr_20251107                                                                   ;
*SAS programs from authors of paper: Jorm IQCode for proxy interviews                                                             ;
*                                    tics&cogcoding                                                                               ;
*                                    Memory and dementia probability score model_April 2013                                       ;
**********************************************************************************************************************************;


libname hrscog '***\HRS_data\HRSCogImp1992_2020Ver3final';
libname rand '***\HRS_data\rand\randhrs1992_2022v1_SAS';
libname fat '***HRS_data\rand\fatfiles';
proc format cntlin=rand.sasfmts;run;
libname trk '***\HRS_data\trk2022earlyv2';
libname cog '***\HRS_data\GlymourCogMeasures\sasdata';
options nofmterr nocenter nodate mlogic mprint;
options mergenoby=ERROR;



/******************************MACRO SECTION FROM IRENA CENZER*******************************/

/* 
MERGE2SETS PURPOSE: MERGES 2 DATASETS 
MERGE2SETS PARAMETERS:
1) DESTDATA = DESTINATION DATASET (INCLUDING LIBNAME AND IN= IF APPLICABLE)
2) SRCDATA1 = FIRST SOURCE DATASET
3) KEEPLIST1 = LIST OF VARIABLES TO KEEP FROM FIRST SOURCE DATASET (NOT INCLUDING
	THE "KEEP = " STATEMENT ITSELF, SEPARATE VARIABLES BY SPACES) (OPTIONAL)
4) SRCDATA2 = SECOND SOURCE DATASET
5) KEEPLIST2 = LIST OF VARIABLES TO KEEP FROM SECOND SOURCE DATASET (NOT INCLUDING
	THE "KEEP = " STATEMENT ITSELF, SEPARATE VARIABLES BY SPACES) (OPTIONAL)
6) BYVARS = LIST OF VARIABLES TO SORT AND MERGE BY
7) IFSTMT = IF STATEMENT TO SELECT CERTAIN OBSERVATIONS (NOT INCLUDING THE "IF"
	ITSELF, MUST BE INSIDE A STRING FUNCTION IF ANY OPERATORS ARE USED, FOR EG.
	%STR(AGE > 75))(OPTIONAL)
*/

%macro merge2sets(destdata, srcdata1, keeplist1, srcdata2, keeplist2, byvars, ifstmt);
proc sort data = &srcdata1;
	by &byvars;
run;
proc sort data = &srcdata2;
	by &byvars;
run;
%if %length(&keeplist1) > 0 %then %let srcdata1 = %str(&srcdata1%str((keep = &keeplist1)));
%if %length(&keeplist2) > 0 %then %let srcdata2 = %str(&srcdata2%str((keep = &keeplist2)));
data &destdata;
merge &srcdata1 &srcdata2;
	by &byvars;
	%if %length(&ifstmt) > 0 %then %do;
		if &ifstmt;
	%end;
run;
%mend merge2sets;


/*Get variables from RAND*/
/*Note: 
I included wave 16 variables even though the composite memory score and dementia probability are not derived for wave 16.
Composite memory score and dementia probability cannot be derived for wave 16 since the latest HRS Cognition Imputations goes up to 2020 as of 11/07/2025
*/
data cog.randvars;
 set rand.randhrs1992_2022v1 (keep=HHIDPN HACOHORT RACOHBYR 
                          R14COGMODE R15COGMODE /*1.Tel/FTF Interview, 2.WEB Interview*/
   		 				  R1IWSTAT R2IWSTAT R3IWSTAT R4IWSTAT R5IWSTAT R6IWSTAT R7IWSTAT R8IWSTAT R9IWSTAT R10IWSTAT R11IWSTAT R12IWSTAT R13IWSTAT R14IWSTAT R15IWSTAT R16IWSTAT
						 /*This variable gives the response and mortality status of the Respondent at each wave. Respondents are identified
							by code 1, non-Respondents by codes 0, 4-7 and 9:
						 	0.Inap., 1.Resp, alive , 4.NR, alive , 5.NR, died this wv , 6.NR, died prev wv , 7.NR, dropped from samp*/
						  R1WTRESP R2WTRESP R3WTRESP R4WTRESP R5WTRESP R6WTRESP R7WTRESP R8WTRESP R9WTRESP R10WTRESP R11WTRESP R12WTRESP R13WTRESP R14WTRESP R15WTRESP R16WTRESP /*Person-Level Analysis Weight*/
		   				  R1PROXY  R2PROXY  R3PROXY  R4PROXY  R5PROXY  R6PROXY  R7PROXY  R8PROXY  R9PROXY  R10PROXY  R11PROXY R12PROXY R13PROXY R14PROXY R15PROXY R16PROXY /*Whether Proxy Interview. 0.not proxy, 1.proxy: interview is by proxy in wave*/
						  );
proc sort; by hhidpn; run; 
/*45234 observations and 53 variables.*/

proc contents data= hrscog.cogimp9220a_r; run;


/*Get all the direct assessment variables from cogimp9220a_r*/
data directvars (drop=HHID PN);
	set hrscog.cogimp9220a_r 
   (keep=HHID PN
		/*Immediate word recall.They are counts of the number of words from a 10 word list that were recalled correctly.
		  In waves 1 and 2H, the word list contained 20 nouns instead of 10 as in other waves. That's why I don't include wave 1 and 2H variables

          In Waves 14 forward, these tests were conducted differently depending on if the Respondent had a Face-to-Face/Telephone interview or
   		  a Web interview. To account for these differences, RwIMRC is separated into two variables: RwIMRCP for Respondents
   		  who performed the cognition measures during a Face-to-Face/Telephone interview and RwIMRCW for Respondents who performed
		  the cognition measures during a Web interview. 

         If I use RAND dataset I need to use R2AIMR10 instead of R2AIMRC10: 
		 Note that the variable names R2AIMR10 and R2HIMR20 have been shortened from R2AIMRC10 and R2HIMRC20
		 in the original HRS imputation file to conform to the current 8-character limit
        */
		 R2AIMRC10 R3IMRC R4IMRC R5IMRC R6IMRC R7IMRC R8IMRC R9IMRC R10IMRC R11IMRC R12IMRC R13IMRC R14IMRCP R14IMRCW R15IMRCP R15IMRCW

		 /*RwFIMRC indicates a flag for whether R1IMRC was imputed (1=Imputed, 0=Not Imputed, 2=Not Imputed-missing by design)
           In Waves 14 forward, RwIMRCP and RwFIMRCP are set to .W to indicate a Web interview and RwIMRCW and RwFIMRCW are set to .P 
		   to indicate a Face-to-Face/Telephone interview. In these cases, when RwIMRCP and RwFIMRCP are set to .W the the cognition values are in RwIMRCW and RwFIMRCW and
		   when RwIMRCW and RwFIMRCW are set to .P the cognition values are in RwIMRCP and RwFIMRCP.*/
         R2FIMRC R3FIMRC R4FIMRC R5FIMRC R6FIMRC R7FIMRC R8FIMRC R9FIMRC R10FIMRC R11FIMRC R12FIMRC R13FIMRC R14FIMRCP R14FIMRCW R15FIMRCP R15FIMRCW

		/*Delayed Word Recall. They are counts of the number of words from the 10 word immediate recall list that were recalled correctly after a delay of
          about 5 minutes spent answering other survey questions. In Waves 1 and 2H, the word list contained 20 nouns. instead of 10 as in other waves. 
		  That's why I don't include wave 1 and 2H variables.

		  In Waves 14 forward, these tests were conducted differently depending on if the Respondent had a Face-to-Face/Telephone
		  interview or a Web interview. To account for these differences, RwDLRC is separated into two variables: RwDLRCP for Respondents
          who performed the cognition measures during a Face-to-Face/Telephone interview and RwDLRCW for Respondents who performed
          the cognition measures during a Web interview.

		  If I use RAND dataset I need to use R2ADLR10 instead of R2ADLRC10: From RAND, note that the variable names R2ADLR10 and R2HDLR20
		  have been shortened from R2ADLRC10 and R2HDLRC20 in the original HRS imputation file to conform to the current 8-character limit.
		 */
		 R2ADLRC10 R3DLRC R4DLRC  R5DLRC  R6DLRC  R7DLRC  R8DLRC  R9DLRC  R10DLRC  R11DLRC  R12DLRC  R13DLRC  R14DLRCP  R14DLRCW  R15DLRCP  R15DLRCW

		 R2FDLRC  R3FDLRC R4FDLRC R5FDLRC R6FDLRC R7FDLRC R8FDLRC R9FDLRC R10FDLRC R11FDLRC R12FDLRC R13FDLRC R14FDLRCP R14FDLRCW R15FDLRCP R15FDLRCW

 		/*To create new TICS variable excluding 'naming scissors' and 'second attempt at counting backward from 20. I need the following variables
		  None of these questions were included in waves 1 and 2H:
		*/
   
        /*Serial 7’s: provides the number of correct subtractions in the serial 7s test. This test asks the individual to subtract
		  7 from the prior number, beginning with 100 for five trials. Correct subtractions are based on the prior number
		  given, so that even if one subtraction is incorrect subsequent trials are evaluated on the given (perhaps wrong)
		  answer. Valid scores are 0-5. This task was not given to anyone in Waves 1 and 2H
		 */
         R2SER7 R3SER7 R4SER7 R5SER7 R6SER7 R7SER7 R8SER7 R9SER7 R10SER7 R11SER7 R12SER7 R13SER7 R14SER7P R14SER7W R15SER7P R15SER7W

		 /*Object Naming: whether the Respondent was able to correctly name a cactus based on a verbal description. 
		   For RwCACT the question was, "What do you call the kind of prickly plant that grows in the desert?"
		   From Wave 14 forward, the questions are skipped for Web interviews
		   If the question was skipped because of a Web interview, then special missing value .W is assigned. 
		   The variable rename in Wave 14 forward, from RwCACT and RwSCIS to RwCACTP and RwSCISP, reinforces this change
		 */
         R2CACT R3CACT R4CACT R5CACT R6CACT R7CACT R8CACT R9CACT R10CACT R11CACT R12CACT R13CACT R14CACTP R15CACTP

	    /*Date Naming: whether the Respondent was able to report today’s date correctly, including the day of month, month, year, and day of week
		  From Wave 14 forward, the questions are skipped for Web interviews. If the question was skipped because of a Web interview,
		  then special missing value .W is assigned. The variable rename in Wave 14 forward, from
          RwDY, RwMO, RwYR, and RwDW to RwDYP, RwMOP, RwYRP, and RwDWP, reinforces this change
		 */
		 R2DY R3DY R4DY R5DY R6DY R7DY R8DY R9DY R10DY R11DY R12DY R13DY R14DYP R15DYP   /*Cognition Date naming-Day of the Month*/
		 R2MO R3MO R4MO R5MO R6MO R7MO R8MO R9MO R10MO R11MO R12MO R13MO R14MOP R15MOP   /*Cognition Date naming-Month*/
		 R2YR R3YR R4YR R5YR R6YR R7YR R8YR R9YR R10YR R11YR R12YR R13YR R14YRP R15YRP   /*Cognition Date naming-Year*/
		 R2DW R3DW R4DW R5DW R6DW R7DW R8DW R9DW R10DW R11DW R12DW R13DW R14DWP R15DWP   /*Cognition Date naming-Day of week*/

		 /*President/Vice-President Naming
		  From Wave 14 forward, the questions are skipped for Web interviews. If the question was skipped because of a Web interview,
		  then special missing value .W is assigned. The variable rename in Wave 14 forward, from
          RwPRES and RwVP to RwPRESP and RwVPP, reinforces this change
		 */
		 R2PRES R3PRES R4PRES R5PRES R6PRES R7PRES R8PRES R9PRES R10PRES R11PRES R12PRES R13PRES R14PRESP R15PRESP
		 R2VP R3VP R4VP R5VP R6VP R7VP R8VP R9VP R10VP R11VP R12VP R13VP R14VPP R15VPP

		 /*Backwards Counting: indicate whether the Respondent was able to successfully count backwards for 10 continuous numbers from 20.
		  Two points are given if successful on the first try, one if successful on the second, and zero if not successful on either try.
		  In Waves 14 forward, these tests were conducted differently depending on if the Respondent had a Face-to-Face/Telephone interview
          or a Web interview. To account for these differences, RwBWC20 is separated into two variables: RwBWC20P for Respondents who
          performed the cognition measures during a Face-to-Face/Telephone interview and RwBWC20W for Respondents who performed the
          cognition measures during a Web interview. RwFBWC20 is similarly separated into RwFBWC20P and RwFBWC20W for Waves 14 forward.
		 */
		  R2BWC20 R3BWC20 R4BWC20 R5BWC20 R6BWC20 R7BWC20 R8BWC20 R9BWC20 R10BWC20 R11BWC20 R12BWC20 R13BWC20 R14BWC20P R14BWC20W R15BWC20P R15BWC20W
		
		 /*TOTAL COGNITION SUMMARY SCORE for all waves. They have cont. values: 0-35. Not calculated for proxy respondents. Not available in Waves 1 and 2H
		  It adds up the total word recall (immediate and delayed=20) + mental status summary score (R2AMSTOT and RwMSTOT=TICS=0-15, instead of 0-13

		  If I use RAND dataset I need to use R2ACGTOT instead of R2ACOGTOT:
		  Note that the variable name R2ACGTOT has been shortened from R2ACOGTOT in the original HRS imputation file  to conform to the current 8-character limit.

		  The total cognition score sums the total word recall and mental status summary scores, resulting in a range of 0-35. For Wave
		  2A, R2ACOGTOT is the sum of R2ATR20 and R2AMSTOT. RwCOGTOT is the sum of RwTR20 and RwMSTOT for Waves 3-13.
		  RwCOGTOTP is the sum of RwTR20P and RwMSTOTP for Wave 14 forward and excludes Web interviewees. Web interviewees have
          a value of .W for RwCOGTOTP. RwCOGTOT is not available in Waves 1 and 2H.
		 */
		  R2ACOGTOT R3COGTOT R4COGTOT R5COGTOT R6COGTOT R7COGTOT R8COGTOT R9COGTOT R10COGTOT R11COGTOT R12COGTOT R13COGTOT R14COGTOTP R15COGTOTP);
  HHIDPN=HHID*1000 + PN;
proc sort; by hhidpn; run;
/* 41041 observations and 209 variables.*/


/*Merge directvars and cog.randvars*/
data directvars;
	merge directvars cog.randvars;
    by hhidpn;
proc sort; by hhidpn; run; 
/*45234 observations and 53+208=261 variables.*/


/*Combine responses from Face-to-Face/Telephone and Web interview into one variable, use R14COGMODE/R15COGMODE 1.Tel/FTF Interview, 2.WEB Interview*/
data directvars2 (drop=i);
 set directvars;

 array comb14[4]    R14BWC20  R14SER7   R14IMRC   R14DLRC   ;
 array phone14[4]   R14BWC20P R14SER7P  R14IMRCP  R14DLRCP  ;
 array web14[4]     R14BWC20W R14SER7W  R14IMRCW  R14DLRCW  ;

 array comb15[4]    R15BWC20   R15SER7  R15IMRC	 R15DLRC   ;
 array phone15[4]   R15BWC20P  R15SER7P	R15IMRCP R15DLRCP  ;
 array web15[4]     R15BWC20W  R15SER7W R15IMRCW R15DLRCW  ;


if      R14COGMODE=1 then do i=1 to 4;  comb14[i]=phone14[i]; end; 
else if R14COGMODE=2 then do i=1 to 4;  comb14[i]=web14[i]; end; 

if      R15COGMODE=1 then do i=1 to 4;  comb15[i]=phone15[i]; end; 
else if R15COGMODE=2 then do i=1 to 4;  comb15[i]=web15[i]; end; 

proc sort; by hhidpn; run; 
/*45234 observations and 261+8=269 variables.*/


/*Derive variables of interest*/
data directvars3;
  set directvars2;

  /*In Wu et al., 2012 paper they omitted the second attemp at counting backward from 20 so we need to recode the RAND variables: RwBWC20
   	0.Incorrect 
	1.Correct, 2nd try: Maria Glymour email 1/19/2016: 'REGARDLESS OF WHETHER THEY WERE CORRECT OR INCORRECT ON THE SECOND ANSWER, THEY WERE CODED AS ZERO BECAUSE THE FIRST EFFORT WAS WRONG'
	2.Correct, 1st try
  */
  array count[14]    R2BWC20    R3BWC20    R4BWC20    R5BWC20    R6BWC20    R7BWC20    R8BWC20    R9BWC20    R10BWC20    R11BWC20    R12BWC20    R13BWC20    R14BWC20    R15BWC20    ; /*0-2*/
  array newcount[14] R2BWC20new R3BWC20new R4BWC20new R5BWC20new R6BWC20new R7BWC20new R8BWC20new R9BWC20new R10BWC20new R11BWC20new R12BWC20new R13BWC20new R14BWC20new R15BWC20new ; /*0-1*/

  do i=1 to 14;
  	if count[i]= 0 then newcount[i]=0; 
  	else if count[i]=1 then newcount[i]=0;
	else if count[i]=2 then newcount[i]=1;
  end; drop i;


  /*Code below is an adaptation of Maria Glymour's SAS code: See file 'tics&cogcoding*/
  array var93[8] R2CACT   R2DY   R2MO   R2YR   R2DW   R2PRES   R2VP   R2BWC20new;
  array var95[8] R3CACT   R3DY   R3MO   R3YR   R3DW   R3PRES   R3VP   R3BWC20new;
  array var98[8] R4CACT   R4DY   R4MO   R4YR   R4DW   R4PRES   R4VP   R4BWC20new;
  array var00[8] R5CACT   R5DY   R5MO   R5YR   R5DW   R5PRES   R5VP   R5BWC20new;
  array var02[8] R6CACT   R6DY   R6MO   R6YR   R6DW   R6PRES   R6VP   R6BWC20new;
  array var04[8] R7CACT   R7DY   R7MO   R7YR   R7DW   R7PRES   R7VP   R7BWC20new;
  array var06[8] R8CACT   R8DY   R8MO   R8YR   R8DW   R8PRES   R8VP   R8BWC20new;
  array var08[8] R9CACT   R9DY   R9MO   R9YR   R9DW   R9PRES   R9VP   R9BWC20new;
  array var10[8] R10CACT  R10DY  R10MO  R10YR  R10DW  R10PRES  R10VP  R10BWC20new;
  array var12[8] R11CACT  R11DY  R11MO  R11YR  R11DW  R11PRES  R11VP  R11BWC20new;
  array var14[8] R12CACT  R12DY  R12MO  R12YR  R12DW  R12PRES  R12VP  R12BWC20new;
  array var16[8] R13CACT  R13DY  R13MO  R13YR  R13DW  R13PRES  R13VP  R13BWC20new;
  array var18[8] R14CACTP R14DYP R14MOP R14YRP R14DWP R14PRESP R14VPP R14BWC20new;
  array var20[8] R15CACTP R15DYP R15MOP R15YRP R15DWP R15PRESP R15VPP R15BWC20new;

  TICSe93=0;TICSp93ms=0; TICSe95=0;TICSp95ms=0; TICSe98=0;TICSp98ms=0; TICSe00=0;TICSp00ms=0; TICSe02=0;TICSp02ms=0; TICSe04=0;TICSp04ms=0;
  TICSe06=0;TICSp06ms=0; TICSe08=0;TICSp08ms=0; TICSe10=0;TICSp10ms=0; TICSe12=0;TICSp12ms=0; TICSe14=0;TICSp14ms=0; TICSe16=0;TICSp16ms=0; 
  TICSe18=0;TICSp18ms=0; TICSe20=0;TICSp20ms=0;

  do i=1 to 8; *don't add serial 7s;
	if var93[i]=1 then ticse93=ticse93+1;
    if var95[i]=1 then ticse95=ticse95+1;
	if var98[i]=1 then ticse98=ticse98+1;
	if var00[i]=1 then ticse00=ticse00+1;
	if var02[i]=1 then ticse02=ticse02+1;
	if var04[i]=1 then ticse04=ticse04+1;
	if var06[i]=1 then ticse06=ticse06+1;
	if var08[i]=1 then ticse08=ticse08+1;
	if var10[i]=1 then ticse10=ticse10+1;
	if var12[i]=1 then ticse12=ticse12+1;
	if var14[i]=1 then ticse14=ticse14+1;
	if var16[i]=1 then ticse16=ticse16+1;
	if var18[i]=1 then ticse18=ticse18+1;
	if var20[i]=1 then ticse20=ticse20+1;

    /*GDR: count missing answers excluding missing answers for serial 7s*/
	if var93[i] not in(0,1) then ticsp93ms=ticsp93ms+1;
    if var95[i] not in(0,1) then ticsp95ms=ticsp95ms+1;
	if var98[i] not in(0,1) then ticsp98ms=ticsp98ms+1;
	if var00[i] not in(0,1) then ticsp00ms=ticsp00ms+1;
	if var02[i] not in(0,1) then ticsp02ms=ticsp02ms+1;
	if var04[i] not in(0,1) then ticsp04ms=ticsp04ms+1;
	if var06[i] not in(0,1) then ticsp06ms=ticsp06ms+1;
	if var08[i] not in(0,1) then ticsp08ms=ticsp08ms+1;
	if var10[i] not in(0,1) then ticsp10ms=ticsp10ms+1;
	if var12[i] not in(0,1) then ticsp12ms=ticsp12ms+1;
	if var14[i] not in(0,1) then ticsp14ms=ticsp14ms+1;
	if var16[i] not in(0,1) then ticsp16ms=ticsp16ms+1;
	if var18[i] not in(0,1) then ticsp18ms=ticsp18ms+1;
	if var20[i] not in(0,1) then ticsp20ms=ticsp20ms+1;
  end; drop i;

  array tice[14]  TICSe93   TICSe95    TICSe98     TICSe00    TICSe02    TICSe04    TICSe06    TICSe08    TICSe10    TICSe12 	TICSe14 	TICSe16		TICSe18		TICSe20; /*sum of all tics questions excluding serial 7s, range: 0-8*/
  array ticm[14]  TICSp93ms TICSp95ms  TICSp98ms   TICSp00ms  TICSp02ms  TICSp04ms  TICSp06ms  TICSp08ms  TICSp10ms  TICSp12ms 	TICSp14ms	TICSp16ms	TICSp18ms	TICSp20ms; /*number of missing questions*/
  array ser7[14]  R2SER7    R3SER7     R4SER7      R5SER7     R6SER7     R7SER7     R8SER7     R9SER7     R10SER7    R11SER7 	R12SER7		R13SER7		R14SER7		R15SER7;
  array tics[14]  tics2     tics3      tics4       tics5      tics6      tics7      tics8      tics9      tics10     tics11 	tics12		tics13		tics14		tics15; /*sum of all tics questions including serial 7s, range: 0-13*/

  do i=1 to 14;
  	if ser7[i] not in (0,1,2,3,4,5) then ticm[i]=ticm[i]+5; *extra missing if missing in serial 7s;
  	if ticm[i] le 3 then do; tics[i]=tice[i]+ser7[i]; tics[i]=(tics[i]*13)/(13-ticm[i]); end; 
  	else tics[i]=.;
  end; drop i;
proc sort; by hhidpn; run;
/*45234 observations and 269+14+14*3=325 variables.*/


/*Keep variables that will be used in prediction from waves 1995-2020*/
data cog.directvars (keep= R3IWSTAT R4IWSTAT R5IWSTAT R6IWSTAT R7IWSTAT R8IWSTAT R9IWSTAT R10IWSTAT R11IWSTAT R12IWSTAT R13IWSTAT R14IWSTAT R15IWSTAT R16IWSTAT
					       R3WTRESP R4WTRESP R5WTRESP R6WTRESP R7WTRESP R8WTRESP R9WTRESP R10WTRESP R11WTRESP R12WTRESP R13WTRESP R14WTRESP R15WTRESP R16WTRESP
						   R3PROXY  R4PROXY  R5PROXY  R6PROXY  R7PROXY  R8PROXY  R9PROXY  R10PROXY  R11PROXY  R12PROXY  R13PROXY  R14PROXY  R15PROXY  R16PROXY
						   R3IMRC   R4IMRC 	 R5IMRC   R6IMRC   R7IMRC   R8IMRC   R9IMRC   R10IMRC   R11IMRC   R12IMRC   R13IMRC	  R14IMRC   R15IMRC
						   R3FIMRC  R4FIMRC  R5FIMRC  R6FIMRC  R7FIMRC  R8FIMRC  R9FIMRC  R10FIMRC  R11FIMRC  R12FIMRC  R13FIMRC  R14FIMRCP R14FIMRCW R15FIMRCP R15FIMRCW
						   R3DLRC   R4DLRC   R5DLRC   R6DLRC   R7DLRC   R8DLRC   R9DLRC   R10DLRC   R11DLRC   R12DLRC   R13DLRC	  R14DLRC   R15DLRC
						   R3FDLRC  R4FDLRC  R5FDLRC  R6FDLRC  R7FDLRC  R8FDLRC  R9FDLRC  R10FDLRC  R11FDLRC  R12FDLRC  R13FDLRC  R14FDLRCP R14FDLRCW R15FDLRCP R15FDLRCW
						   tics3-tics15 HHIDPN HACOHORT RACOHBYR R14COGMODE R15COGMODE);
	set directvars3;
proc sort; by hhidpn; run;
/*45234 observations and  116 variables.*/



/*Get proxy variables from fat files:
  Proxy memory score and 48 variables per wave that I need to generate the IQCODE variable (the Jorm Informant Questionannaire for Cognitive Decline).
  See proxyvars excel file. These variables came from Table 3 on "HRS/AHEAD Documentation Report. Documentation of Cognitive Functioning Measures in the Health and Retirement Study. March 2005" 
*/

/*merge2sets(destdata, srcdata1, keeplist1, srcdata2, keeplist2, byvars, ifstmt);*/
%merge2sets(cog.fatvars,               fat.h22e3a,  hhidpn  SD501 SD506-SD508 SD509-SD511 SD512-SD514 SD515-SD517 SD518-SD520 SD521-SD523 SD524-SD526 SD527-SD529 SD530-SD532 SD533-SD535 SD536-SD538 SD539-SD541 SD542-SD544 SD545-SD547 SD548-SD550 SD551-SD553,  
                                       fat.h20f1b,  hhidpn  RD501 RD506-RD508 RD509-RD511 RD512-RD514 RD515-RD517 RD518-RD520 RD521-RD523 RD524-RD526 RD527-RD529 RD530-RD532 RD533-RD535 RD536-RD538 RD539-RD541 RD542-RD544 RD545-RD547 RD548-RD550 RD551-RD553, hhidpn,  );
%merge2sets(cog.fatvars, cog.fatvars, ,fat.h18f2c,  hhidpn  QD501 QD506-QD508 QD509-QD511 QD512-QD514 QD515-QD517 QD518-QD520 QD521-QD523 QD524-QD526 QD527-QD529 QD530-QD532 QD533-QD535 QD536-QD538 QD539-QD541 QD542-QD544 QD545-QD547 QD548-QD550 QD551-QD553, hhidpn,  ); 
%merge2sets(cog.fatvars, cog.fatvars, ,fat.h16f2c,  hhidpn  PD501 PD506-PD508 PD509-PD511 PD512-PD514 PD515-PD517 PD518-PD520 PD521-PD523 PD524-PD526 PD527-PD529 PD530-PD532 PD533-PD535 PD536-PD538 PD539-PD541 PD542-PD544 PD545-PD547 PD548-PD550 PD551-PD553, hhidpn,  ); 
%merge2sets(cog.fatvars, cog.fatvars, ,fat.h14f2b,  hhidpn  OD501 OD506-OD508 OD509-OD511 OD512-OD514 OD515-OD517 OD518-OD520 OD521-OD523 OD524-OD526 OD527-OD529 OD530-OD532 OD533-OD535 OD536-OD538 OD539-OD541 OD542-OD544 OD545-OD547 OD548-OD550 OD551-OD553, hhidpn,  );
%merge2sets(cog.fatvars, cog.fatvars, ,fat.h12f3a,  hhidpn  ND501 ND506-ND508 ND509-ND511 ND512-ND514 ND515-ND517 ND518-ND520 ND521-ND523 ND524-ND526 ND527-ND529 ND530-ND532 ND533-ND535 ND536-ND538 ND539-ND541 ND542-ND544 ND545-ND547 ND548-ND550 ND551-ND553, hhidpn,  ); 
%merge2sets(cog.fatvars, cog.fatvars, ,fat.hd10f6b, hhidpn  MD501 MD506-MD508 MD509-MD511 MD512-MD514 MD515-MD517 MD518-MD520 MD521-MD523 MD524-MD526 MD527-MD529 MD530-MD532 MD533-MD535 MD536-MD538 MD539-MD541 MD542-MD544 MD545-MD547 MD548-MD550 MD551-MD553, hhidpn,  ); 
%merge2sets(cog.fatvars, cog.fatvars, ,fat.h08f3b,  hhidpn  LD501 LD506-LD508 LD509-LD511 LD512-LD514 LD515-LD517 LD518-LD520 LD521-LD523 LD524-LD526 LD527-LD529 LD530-LD532 LD533-LD535 LD536-LD538 LD539-LD541 LD542-LD544 LD545-LD547 LD548-LD550 LD551-LD553, hhidpn,  ); 
%merge2sets(cog.fatvars, cog.fatvars, ,fat.h06f4b,  hhidpn  KD501 KD506-KD508 KD509-KD511 KD512-KD514 KD515-KD517 KD518-KD520 KD521-KD523 KD524-KD526 KD527-KD529 KD530-KD532 KD533-KD535 KD536-KD538 KD539-KD541 KD542-KD544 KD545-KD547 KD548-KD550 KD551-KD553, hhidpn,  ); 
%merge2sets(cog.fatvars, cog.fatvars, ,fat.h04f1c,  hhidpn  JD501 JD506-JD508 JD509-JD511 JD512-JD514 JD515-JD517 JD518-JD520 JD521-JD523 JD524-JD526 JD527-JD529 JD530-JD532 JD533-JD535 JD536-JD538 JD539-JD541 JD542-JD544 JD545-JD547 JD548-JD550 JD551-JD553, hhidpn,  ); 
%merge2sets(cog.fatvars, cog.fatvars, ,fat.h02f2c,  hhidpn  HD501 HD506-HD508 HD509-HD511 HD512-HD514 HD515-HD517 HD518-HD520 HD521-HD523 HD524-HD526 HD527-HD529 HD530-HD532 HD533-HD535 HD536-HD538 HD539-HD541 HD542-HD544 HD545-HD547 HD548-HD550 HD551-HD553, hhidpn,  ); 
%merge2sets(cog.fatvars, cog.fatvars, ,fat.h00f1d,  hhidpn  G1527 G1543-G1545 G1548-G1550 G1553-G1555 G1558-G1560 G1563-G1565 G1568-G1570 G1573-G1575 G1578-G1580 G1583-G1585 G1588-G1590 G1593-G1595 G1598-G1600 G1602-G1604 G1605-G1607 G1608-G1610 G1611-G1613, hhidpn,  ); 
%merge2sets(cog.fatvars, cog.fatvars, ,fat.hd98f2c, hhidpn  F1373 F1389-F1391 F1394-F1396 F1399-F1401 F1404-F1406 F1409-F1411 F1414-F1416 F1419-F1421 F1424-F1426 F1429-F1431 F1434-F1436 F1439-F1441 F1444-F1446 F1448-F1450 F1451-F1453 F1454-F1456 F1457-F1459, hhidpn,  ); 
%merge2sets(cog.fatvars, cog.fatvars, ,fat.h96f4a,  hhidpn  E1056 E1072-E1074 E1077-E1079 E1082-E1084 E1087-E1089 E1092-E1094 E1097-E1099 E1102-E1104 E1107-E1109 E1112-E1114 E1117-E1119 E1122-E1124 E1127-E1129 E1132-E1134 E1135-E1137 E1138-E1140 E1141-E1143, hhidpn,  ); 
%merge2sets(cog.fatvars, cog.fatvars, ,fat.ad95f2b, hhidpn  D1056 D1072-D1074 D1077-D1079 D1082-D1084 D1087-D1089 D1092-D1094 D1097-D1099 D1102-D1104 D1107-D1109 D1112-D1114 D1117-D1119 D1122-D1124 D1127-D1129 D1132-D1134 D1135-D1137 D1138-D1140 D1141-D1143, hhidpn,  ); 

%merge2sets(cog.fatvars, cog.fatvars, ,cog.directvars,hhidpn R3IWSTAT R4IWSTAT R5IWSTAT R6IWSTAT R7IWSTAT R8IWSTAT R9IWSTAT R10IWSTAT R11IWSTAT R12IWSTAT R13IWSTAT R14IWSTAT R15IWSTAT R16IWSTAT
                                                             R3PROXY  R4PROXY  R5PROXY  R6PROXY  R7PROXY  R8PROXY  R9PROXY  R10PROXY  R11PROXY  R12PROXY  R13PROXY  R14PROXY  R15PROXY  R16PROXY, hhidpn,  ); 
/* 45234 observations and 49*15+14*2+1= 764 variables */


/*Derive IQCODE variable by wave 1995-2022 */
data proxyvars;
 set cog.fatvars;
run;
/* 45234 observations and 764  */


/*Code below is adapted from Maria Glymour: See file 'Jorm IQCode for proxy interviews'*/

%macro proxy (w=, year=, iqcodels=, iqcodeim=, iqcodede=) ;

data proxyvars (drop=tempsum);
	set proxyvars;

	/* Jorm IQCode for proxy interviews 
  	   treat item missings as 3 "unchanged" or if proxy has already indicated things have gotten better or worse, interpret as value closest to staying the same
	*/	

	if R&w.IWSTAT=1 and R&w.PROXY=1 then do; /*RwIWSTAT=1.Resp, alive RwPROXY=1.proxy */

	/* Question is:" Compared with two years ago, how is R at: Remembering things about family and friends, such as occupations, birthdays, and
          addresses. Has this 1.improved, 2.not much changed, 3.gotten worse, 4. R doesn't do this/ DOES NOT APPLY/R DOESN'T DO ACTIVITY, 7. other, 8.dk, 9.rf"
	*/
     array iqcodels [16] &iqcodels;

	 * If improved, then asked "Is it much improved or a bit improved?": 1.much improved, 2.a bit improved, 7. other, 8.dk, 9.rf;
     array iqcodeim [16] &iqcodeim;

	 * If gotten worse, then asked "Is it much worse or a bit worse?":  4.a bit worse,5.much worse 7. other, 8.dk, 9.rf;
     array iqcodede [16] &iqcodede;

	 IQcode&year=0;
     iqcode&year.ms=0;
	 do i=1 to 16;
	    tempsum=iqcodels[i];
		if iqcodeim[i] in (7,8,9) then iqcodeim[i]=2; /*GDR: 2.a bit improved: interpret as value closest to staying the same, i.e "a bit improved" instead of "much improved"*/
		if iqcodede[i] in (7,8,9) then iqcodede[i]=4; /*GDR:  4.a bit worse: interpret as value closest to staying the same, i.e. "a bit worse" instead of "much worse"*/
	    if iqcodels[i]=1 then tempsum=iqcodeim[i]; *improved; /*GDR:  1.much improved, 2.a bit improved*/
		else if iqcodels[i]=3 then tempsum=iqcodede[i]; *declined; /*GDR: 4.a bit worse,5.much worse*/
        else if iqcodels[i]=2 then tempsum=3;           *stayed same;
		if tempsum in (7,8,9) then do;
           iqcode&year.ms=iqcode&year.ms+1;
		   tempsum=0;
		end;
		iqcode&year=sum(iqcode&year,tempsum);
     end; drop i;

	 if iqcode&year.ms > 3 or iqcode&year=0 then iqcode&year=.; /*if the number of missing is >3 or the iqcode&year.=0 because every question was missing then iqcode&year.=.*/
     else iqcode&year=iqcode&year/(16-iqcode&year.ms);

	 if iqcode&year >= 3.5 then IQCodeD&year=1; /*GDR: IQCODE range:1.excellent to 5.poor. So >=3.5 means that participants had dementia=1*/
	 else if 0<=iqcode&year<3.5 then IQCodeD&year=0;
	 label iqcode&year="JORM IQCODE: AVERAGE SCORE - year &year: 1.much improved, 2. a bit improved, 3.not much changed, 4. a bit worse, 5.much worse";

  end;

run;

%mend proxy;

%proxy(w=3, year=95,
            iqcodels=D1072 D1077 D1082 D1087 D1092 D1097 D1102 D1107 D1112 D1117 D1122 D1127 D1132 D1135 D1138 D1141,
            iqcodeim=D1073 D1078 D1083 D1088 D1093 D1098 D1103 D1108 D1113 D1118 D1123 D1128 D1133 D1136 D1139 D1142,
            iqcodede=D1074 D1079 D1084 D1089 D1094 D1099 D1104 D1109 D1114 D1119 D1124 D1129 D1134 D1137 D1140 D1143)
proc means data=proxyvars; var IQCode95; run;
/* 45234 observations and 764+3=767 variables. */

%proxy(w=3, year=96,
            iqcodels=e1072 	e1077 	e1082 	e1087 	e1092 	e1097 	e1102 	e1107 	e1112 	e1117 	e1122 	e1127 	e1132 	e1135 	e1138 	e1141,
            iqcodeim=e1073 	e1078 	e1083 	e1088 	e1093 	e1098 	e1103 	e1108 	e1113 	e1118 	e1123 	e1128 	e1133 	e1136 	e1139 	e1142,
            iqcodede=e1074 	e1079 	e1084 	e1089 	e1094 	e1099 	e1104 	e1109 	e1114 	e1119  	e1124 	e1129 	e1134 	e1137 	e1140 	e1143)
proc means data=proxyvars; var IQCode96; run;
/* 45234 observations and 767+3=770 variables. */

%proxy(w=4, year=98,
            iqcodels=F1389 F1394 F1399 F1404 F1409 F1414 F1419 F1424 F1429 F1434 F1439 F1444 F1448 F1451 F1454 F1457,
            iqcodeim=F1390 F1395 F1400 F1405 F1410 F1415 F1420 F1425 F1430 F1435 F1440 F1445 F1449 F1452 F1455 F1458,
            iqcodede=F1391 F1396 F1401 F1406 F1411 F1416 F1421 F1426 F1431 F1436 F1441 F1446 F1450 F1453 F1456 F1459)
proc means data=proxyvars; var IQCode98; run;
/* 45234 observations and 770+3=773 variables. */

%proxy(w=5, year=00,
            iqcodels=G1543 G1548 G1553 G1558 G1563 G1568 G1573 G1578 G1583 G1588 G1593 G1598 G1602 G1605 G1608 G1611,
            iqcodeim=G1544 G1549 G1554 G1559 G1564 G1569 G1574 G1579 G1584 G1589 G1594 G1599 G1603 G1606 G1609 G1612,
            iqcodede=G1545 G1550 G1555 G1560 G1565 G1570 G1575 G1580 G1585 G1590 G1595 G1600 G1604 G1607 G1610 G1613)
proc means data=proxyvars; var IQCode00; run;
/* 45234 observations and 773+3=776  variables. */

%proxy(w=6, year=02,
            iqcodels=HD506 HD509 HD512 HD515 HD518 HD521 HD524 HD527 HD530 HD533 HD536 HD539 HD542 HD545 HD548 HD551,
            iqcodeim=HD507 HD510 HD513 HD516 HD519 HD522 HD525 HD528 HD531 HD534 HD537 HD540 HD543 HD546 HD549 HD552,
            iqcodede=HD508 HD511 HD514 HD517 HD520 HD523 HD526 HD529 HD532 HD535 HD538 HD541 HD544 HD547 HD550 HD553)
proc means data=proxyvars; var IQCode02; run;
/* 45234 observations and 776+3=779  variables. */


%proxy(w=7, year=04,
            iqcodels=JD506 JD509 JD512 JD515 JD518 JD521 JD524 JD527 JD530 JD533 JD536 JD539 JD542 JD545 JD548 JD551,
            iqcodeim=JD507 JD510 JD513 JD516 JD519 JD522 JD525 JD528 JD531 JD534 JD537 JD540 JD543 JD546 JD549 JD552,
            iqcodede=JD508 JD511 JD514 JD517 JD520 JD523 JD526 JD529 JD532 JD535 JD538 JD541 JD544 JD547 JD550 JD553)
proc means data=proxyvars; var IQCode04; run;
/* 45234 observations and 779+3=782  variables. */

%proxy(w=8, year=06,
            iqcodels=KD506 KD509 KD512 KD515 KD518 KD521 KD524 KD527 KD530 KD533 KD536 KD539 KD542 KD545 KD548 KD551,
            iqcodeim=KD507 KD510 KD513 KD516 KD519 KD522 KD525 KD528 KD531 KD534 KD537 KD540 KD543 KD546 KD549 KD552,
            iqcodede=KD508 KD511 KD514 KD517 KD520 KD523 KD526 KD529 KD532 KD535 KD538 KD541 KD544 KD547 KD550 KD553)
proc means data=proxyvars; var IQCode06; run;
/* 45234 observations and 782+3=785  variables. */


%proxy(w=9, year=08,
            iqcodels=LD506 LD509 LD512 LD515 LD518 LD521 LD524 LD527 LD530 LD533 LD536 LD539 LD542 LD545 LD548 LD551,
            iqcodeim=LD507 LD510 LD513 LD516 LD519 LD522 LD525 LD528 LD531 LD534 LD537 LD540 LD543 LD546 LD549 LD552,
            iqcodede=LD508 LD511 LD514 LD517 LD520 LD523 LD526 LD529 LD532 LD535 LD538 LD541 LD544 LD547 LD550 LD553)
proc means data=proxyvars; var IQCode08; run;
/* 45234 observations and 785+3=788  variables. */

%proxy(w=10, year=10,
            iqcodels=MD506 MD509 MD512 MD515 MD518 MD521 MD524 MD527 MD530 MD533 MD536 MD539 MD542 MD545 MD548 MD551,
            iqcodeim=MD507 MD510 MD513 MD516 MD519 MD522 MD525 MD528 MD531 MD534 MD537 MD540 MD543 MD546 MD549 MD552,
            iqcodede=MD508 MD511 MD514 MD517 MD520 MD523 MD526 MD529 MD532 MD535 MD538 MD541 MD544 MD547 MD550 MD553)
proc means data=proxyvars; var IQCode10; run;
/* 45234 observations and 788+3=791  variables. */


%proxy(w=11, year=12,
            iqcodels=ND506 ND509 ND512 ND515 ND518 ND521 ND524 ND527 ND530 ND533 ND536 ND539 ND542 ND545 ND548 ND551,
            iqcodeim=ND507 ND510 ND513 ND516 ND519 ND522 ND525 ND528 ND531 ND534 ND537 ND540 ND543 ND546 ND549 ND552,
            iqcodede=ND508 ND511 ND514 ND517 ND520 ND523 ND526 ND529 ND532 ND535 ND538 ND541 ND544 ND547 ND550 ND553)
proc means data=proxyvars; var IQCode12; run;
/* 45234 observations and 791+3=794 variables. */


%proxy(w=12, year=14,
            iqcodels=OD506 OD509 OD512 OD515 OD518 OD521 OD524 OD527 OD530 OD533 OD536 OD539 OD542 OD545 OD548 OD551,
            iqcodeim=OD507 OD510 OD513 OD516 OD519 OD522 OD525 OD528 OD531 OD534 OD537 OD540 OD543 OD546 OD549 OD552,
            iqcodede=OD508 OD511 OD514 OD517 OD520 OD523 OD526 OD529 OD532 OD535 OD538 OD541 OD544 OD547 OD550 OD553)
proc means data=proxyvars; var IQCode14; run;
/* 45234 observations and 794+3=797  variables. */


%proxy(w=13, year=16,
            iqcodels=PD506 PD509 PD512 PD515 PD518 PD521 PD524 PD527 PD530 PD533 PD536 PD539 PD542 PD545 PD548 PD551,
            iqcodeim=PD507 PD510 PD513 PD516 PD519 PD522 PD525 PD528 PD531 PD534 PD537 PD540 PD543 PD546 PD549 PD552,
            iqcodede=PD508 PD511 PD514 PD517 PD520 PD523 PD526 PD529 PD532 PD535 PD538 PD541 PD544 PD547 PD550 PD553)
proc means data=proxyvars; var IQCode16; run;
/* 45234 observations and 797+3=800  variables. */


%proxy(w=14, year=18,
            iqcodels=QD506 QD509 QD512 QD515 QD518 QD521 QD524 QD527 QD530 QD533 QD536 QD539 QD542 QD545 QD548 QD551,
            iqcodeim=QD507 QD510 QD513 QD516 QD519 QD522 QD525 QD528 QD531 QD534 QD537 QD540 QD543 QD546 QD549 QD552,
            iqcodede=QD508 QD511 QD514 QD517 QD520 QD523 QD526 QD529 QD532 QD535 QD538 QD541 QD544 QD547 QD550 QD553)
proc means data=proxyvars; var IQCode18; run;
/* 45234 observations and 800+3=803  variables. */

%proxy(w=15, year=20,
            iqcodels=RD506 RD509 RD512 RD515 RD518 RD521 RD524 RD527 RD530 RD533 RD536 RD539 RD542 RD545 RD548 RD551,
            iqcodeim=RD507 RD510 RD513 RD516 RD519 RD522 RD525 RD528 RD531 RD534 RD537 RD540 RD543 RD546 RD549 RD552,
            iqcodede=RD508 RD511 RD514 RD517 RD520 RD523 RD526 RD529 RD532 RD535 RD538 RD541 RD544 RD547 RD550 RD553)
proc means data=proxyvars; var IQCode20; run;
/* 45234 observations and 803+3=806  variables. */


%proxy(w=16, year=22,
            iqcodels=SD506 SD509 SD512 SD515 SD518 SD521 SD524 SD527 SD530 SD533 SD536 SD539 SD542 SD545 SD548 SD551,
            iqcodeim=SD507 SD510 SD513 SD516 SD519 SD522 SD525 SD528 SD531 SD534 SD537 SD540 SD543 SD546 SD549 SD552,
            iqcodede=SD508 SD511 SD514 SD517 SD520 SD523 SD526 SD529 SD532 SD535 SD538 SD541 SD544 SD547 SD550 SD553)
proc means data=proxyvars; var IQCode22; run;
/* 45234 observations and 806+3=809  variables. */


/*** QC ***/
*The number of proxy respondents is lower in more recent waves, for example R14PROXY=1.proxy: N=663, so the non-missing N for IQCode variables is lower too;
proc freq data=proxyvars; tables  R3PROXY  R4PROXY  R5PROXY  R6PROXY  R7PROXY  R8PROXY  R9PROXY  R10PROXY  R11PROXY R12PROXY R13PROXY R14PROXY R15PROXY R16PROXY; run;
proc contents data=proxyvars position; run;



/*Keep only hhidpn, memory rating, and the IQCode for all the waves*/
data cog.proxyvars (keep=hhidpn 
                      memrate95 memrate96  memrate98	memrate00	memrate02	memrate04	memrate06	memrate08	memrate10	memrate12 memrate14 memrate16 memrate18 memrate20 memrate22
                      IQCode95 	IQCode96   IQCode98    	IQCode00    IQCode02    IQCode04    IQCode06    IQCode08    IQCode10    IQCode12  IQCode14  IQCode16  IQCode18  IQCode20  IQCode22);
	set proxyvars;
	array mem[15] 	 E1056     D1056 		F1373 		G1527 		HD501 		JD501 		KD501 		LD501 		MD501 		ND501 		OD501		PD501	  QD501		 RD501		SD501;
	array newmem[15] memrate96 memrate95    memrate98	memrate00	memrate02	memrate04	memrate06	memrate08	memrate10	memrate12 	memrate14	memrate16 memrate18	 memrate20	memrate22;
	do i=1 to 15;
		if mem[i] in (7,8,9,.D,.R) then newmem[i]=.; /*Memory rating: 1. EXCELLENT, 2. VERY GOOD,  3. GOOD, 4. FAIR,  5. POOR, 7. Other,  8. DK  or .D (don't know), 9. RF (refused) or .R*/
		else newmem[i]=mem[i];
	end; drop i;
proc sort; by hhidpn; run;
/* 45234 observations and 31 variables */



/*Get demographic variables: Male, Age, and Black from tracker*/
data trk2022; 
  set trk.trk2022tr_r (keep=hhid pn race hispanic gender STUDY BIRTHYR
                          AAGE BAGE CAGE DAGE EAGE FAGE GAGE HAGE JAGE KAGE LAGE MAGE NAGE OAGE PAGE QAGE RAGE SAGE);
  HHIDPN=HHID*1000 + PN;
proc sort; by hhidpn; run;
/*  46850 observations and 26 variables */


/*Get new variables age3-age15 depending on HRS cohort. Get new variables for gender and race*/
data cog.trk (drop= AAGE BAGE CAGE DAGE EAGE FAGE GAGE HAGE JAGE KAGE LAGE MAGE NAGE OAGE PAGE QAGE RAGE SAGE gender race hispanic);
	set trk2022;
	array  age[13]    FAGE GAGE HAGE JAGE KAGE  LAGE MAGE  NAGE	 OAGE	PAGE  QAGE	RAGE	SAGE;
  	array  agenew[13] age4 age5 age6 age7 age8  age9 age10 age11 age12	age13 age14	age15	age16;

	do i=1 to 13;
  		agenew[i]=age[i];
		if age[i]>150 then agenew[i]=.; /*change XAGE=999 values to missing*/
  	end; drop i;

  	if STUDY=1 then age3=EAGE; /*STUDY=1.HRS*/
  	else if STUDY in (11,12,13) then age3=DAGE; /*STUDY in (11,12,13)=AHEAD, or HRS/AHEAD Overlap case*/ 
	if age3>150 then age3=.;

	if HISPANIC=0 then race4g=.; /*Hispanic=0: not obtained*/
	else if HISPANIC in (1,2,3) then race4g=2; /*Hispanic=1 (Hispanic, Mexican), 2: Hispanc, Other,  3.  Hispanic, type unknown*/
	else if HISPANIC=5 then do; /*Hispanic=5: Non-Hispanic*/
  		if RACE=1 then race4g=0; /*RACE=1: White/Caucasian */
  		else if RACE=2 then race4g=1; /*RACE=2: Black or African American */
  		else if RACE=7 then race4g=3; /*RACE=7: Other*/
  	end;
	label race4g='Race/Ethnicity. 0.White, 1.Black, 2.Hispanic, 3.Other';

	if race4g in (0,2,3) then race2g=0; else if race4g=1 then race2g=1;
	label race2g='Race/Ethnicity 2 groups. 0.non-black (white,hispanic,other), 1.black';

	if GENDER=1 then gender2=1;	else if GENDER=2 then gender2=0;
	label gender2='Gender. 0.female, 1.male';
proc sort; by hhidpn; run;
/*46850 observations and 26-21+13+4=22 variables.*/



/*Merge directvars, proxyvars, and tracker datasets. Compute dementia probability and composite core memory score using the regression coefficients in Wu et al., 2012 paper*/

/*Note: Apply missing-method described in Wu et al., 2012 paper: 
    "To retain participants, regardless of whether they participated directly or by proxy in HRS core interviews, we adopted the missing-indicator method and
     included a binary indicator variable for whether the interview was by proxy. For individuals who completed direct cognitive assessments, the proxy
	 variables were set to 0. For individuals with proxy assessments, their direct assessment scores were set to 0."
*/

/*Note2: Code below is an adaptation from Joan Wu SAS's code 'Memory and dementia probability score model_April 2013'--Part 2*/


%let iwwaves=13; /* GDR: number of interview waves included in the imputations*/

data all;
	merge cog.directvars(in=A) cog.proxyvars (in=B) cog.trk;
	by hhidpn;
	if A=1 or B=1; 

	/*Create new IQCODE and proxy memory scores var depending on the cohort*/
	array mem[13]    memrate98	memrate00	memrate02	memrate04	memrate06	memrate08	memrate10	memrate12 	memrate14	memrate16	memrate18	memrate20  memrate22;
	array newmem[13] memrate_4	memrate_5	memrate_6	memrate_7	memrate_8	memrate_9	memrate_10	memrate_11	memrate_12	memrate_13	memrate_14	memrate_15 memrate_16;

	array iq[13]     IQCode98    IQCode00    IQCode02    IQCode04    IQCode06    IQCode08    IQCode10    IQCode12	IQCode14	IQCode16	IQCode18	IQCode20  IQCode22;
	array newiq[13]  AVGIQ_4     AVGIQ_5     AVGIQ_6     AVGIQ_7   	 AVGIQ_8     AVGIQ_9     AVGIQ_10    AVGIQ_11	AVGIQ_12	AVGIQ_13	AVGIQ_14	AVGIQ_15  AVGIQ_16;

    do i=1 to 13;
		newmem[i]=mem[i];
		newiq[i]=iq[i];
	end; drop i;
	if HACOHORT=3 then do; memrate_3=memrate96; AVGIQ_3=IQCode96; end; /*HACOHORT=3.HRS*/
    else if  HACOHORT in (0,1) then do; memrate_3=memrate95; AVGIQ_3=IQCode95; end; /*HACOHORT in (0,1): 0.HRS/AHEAD, 1. AHEAD*/

	/* Note: Update these arrays once the direct repondents variables are available for 2022 */
	array wordis[&iwwaves] 			R3IMRC 		R4IMRC 	  	R5IMRC 		R6IMRC 	 	R7IMRC   	R8IMRC   	R9IMRC   	R10IMRC   		R11IMRC			R12IMRC			R13IMRC			R14IMRC			R15IMRC;
	array wordi_cs[&iwwaves]   		wordi_c3    wordi_c4    wordi_c5    wordi_c6    wordi_c7    wordi_c8    wordi_c9    wordi_c10   	wordi_c11		wordi_c12		wordi_c13		wordi_c14		wordi_c15;
	array wordds[&iwwaves]     		R3DLRC 		R4DLRC 	  	R5DLRC 		R6DLRC   	R7DLRC   	R8DLRC   	R9DLRC   	R10DLRC   		R11DLRC			R12DLRC			R13DLRC			R14DLRC			R15DLRC;
	array wordd_cs[&iwwaves]   		wordd_c3    wordd_c4    wordd_c5    wordd_c6    wordd_c7    wordd_c8    wordd_c9    wordd_c10   	wordd_c11		wordd_c12		wordd_c13		wordd_c14		wordd_c15;
	array iqcodels[&iwwaves]   		AVGIQ_3    	AVGIQ_4     AVGIQ_5     AVGIQ_6     AVGIQ_7   	AVGIQ_8     AVGIQ_9     AVGIQ_10    	AVGIQ_11		AVGIQ_12		AVGIQ_13		AVGIQ_14		AVGIQ_15;
	array iqcode_cls[&iwwaves] 		iqcode_c3   iqcode_c4   iqcode_c5   iqcode_c6   iqcode_c7   iqcode_c8   iqcode_c9   iqcode_c10  	iqcode_c11		iqcode_c12		iqcode_c13		iqcode_c14		iqcode_c15;
	array prxmemls[&iwwaves]   		memrate_3	memrate_4	memrate_5	memrate_6   memrate_7   memrate_8	memrate_9	memrate_10		memrate_11		memrate_12		memrate_13		memrate_14		memrate_15;
	array prxmem_cls[&iwwaves] 		prxmem_c3   prxmem_c4   prxmem_c5   prxmem_c6   prxmem_c7   prxmem_c8   prxmem_c9   prxmem_c10 		prxmem_c11		prxmem_c12		prxmem_c13		prxmem_c14		prxmem_c15;
	array ticss[&iwwaves]   		tics3 		tics4     	tics5  		tics6  	 	tics7    	tics8    	tics9    	tics10    		tics11			tics12			tics13			tics14			tics15;
	array tics_cs[&iwwaves]   		tics_c3     tics_c4     tics_c5     tics_c6     tics_c7     tics_c8     tics_c9     tics_c10    	tics_c11		tics_c12		tics_c13		tics_c14		tics_c15;
	array memimpls[&iwwaves]  		memimp3     memimp4     memimp5     memimp6     memimp7     memimp8     memimp9     memimp10    	memimp11		memimp12		memimp13		memimp14		memimp15;
	array dementpimpls[&iwwaves] 	dementpimp3 dementpimp4 dementpimp5 dementpimp6 dementpimp7 dementpimp8 dementpimp9 dementpimp10 	dementpimp11	dementpimp12 	dementpimp13	dementpimp14	dementpimp15;

	array alives[&iwwaves]      	R3IWSTAT 	R4IWSTAT 	R5IWSTAT 	R6IWSTAT 	R7IWSTAT 	R8IWSTAT 	R9IWSTAT 	R10IWSTAT 	R11IWSTAT	R12IWSTAT 	R13IWSTAT	R14IWSTAT	R15IWSTAT;
	array iwtypes[&iwwaves]  		R3PROXY  	R4PROXY  	R5PROXY  	R6PROXY  	R7PROXY  	R8PROXY  	R9PROXY  	R10PROXY  	R11PROXY	R12PROXY	R13PROXY	R14PROXY	R15PROXY;
	array agels[&iwwaves]    		age3		age4 		age5 		age6 		age7 		age8 		age9 		age10 		age11		age12		age13		age14		age15;
  
 *prepare cognitive scores to be used in score imputation;
	do i=1 to &iwwaves;
	    dpeligible=1;
		memeligible=1;

		age_c=agels[i]-70;

		wordscorei=wordis[i];
		wordscorei_c=wordscorei;
		wordscored=wordds[i];
		wordscored_c=wordscored;
		ticscore=ticss[i];
		ticscore_c=ticscore;
		iqcode=iqcodels[i];
	    iqcode_c=iqcode-5;
		prxmem=prxmemls[i];
	    prxmem_c=prxmem-5; 
		
	    
		*scores from previous wave.;
		/*GDR: modified Joan Wu's code: instead of i>3, I used i>1.
		In Joan Wu's code, i>3 correspond with 2000 wave forward, and then she has an additional DO loop where she has i=3 so that she can specify whether the respondent
		belongs to the AHEAD or the HRS cohort. That way, respondent can take the values from the previous wave to be that from 1995 wave or 1996 wave respectively.
		In my code, I don't need to do this since I already have a unique variable for wave 3 that includes responses from 1995 or 1996 depending on the cohort
		*/

		if i>1 then do; 
		    wordscoreilag=wordis[i-1];
		    wordscoredlag=wordds[i-1];
		    ticscorelag=ticss[i-1];
			iqcodelag=iqcodels[i-1];
			prxmemlag=prxmemls[i-1];
   		end;

		else if i=1 then do;
			wordscoreilag=.;
			wordscoredlag=.;
			ticscorelag=.;
			iqcodelag=.;
			prxmemlag=.;
		end;

	*scores from the following wave;
		/*GDR: modified Joan Wu's code for the same reason as before*/
		if i<&iwwaves then do;
			wordscoreifor=wordis[i+1];
			wordscoredfor=wordds[i+1];
			ticscorefor=ticss[i+1];
			iqcodefor=iqcodels[i+1];
			prxmemfor=prxmemls[i+1];
		end;
		else if i=&iwwaves then do;
			wordscoreifor=.;
			wordscoredfor=.;
			ticscorefor=.;
			iqcodefor=.;
			prxmemfor=.;
		end;

		/*GDR: I don't need IF statement belong because I already recode those with proxy mem score 7,8,9 to missing:
		if mem[i] in (7,8,9,.D,.R) then newmem[i]=.; *Memory rating: 1. EXCELLENT, 2. VERY GOOD,  3. GOOD, 4. FAIR,  5. POOR, 7. Other,  8. DK  or .D (don't know), 9. RF (refused) or .R
		Joan Wu needed this statement because if proxy mem score=8 after she centered it she would have had: 8-5=3
		if prxmem_c>2 then prxmem_c=.;
		*/
	if iwtypes[i]=1 then proxy=1; else if iwtypes[i]=0 then proxy=0;

	*for self respondents, define their proxy cog scores as zero;
	if proxy=0 then do;
		* iqcode: 1=much improved 3=about same 5=much worse;
		iqcode_c=0; 
		prxmem_c=0; 
	end;

	*for proxy respondents, define their direct cog scores as zero;
	if proxy=1 then do;
		** immediate and delayed as separate vars;
		wordscorei_c=0; 
		wordscored_c=0; 
		ticscore_c=0;
	end;

	*self respondent must have valid direct cog scores, otherwise eligibility=0;
	if proxy=0 then do;
	scorems=0;
		if wordscorei=. then do;
			if wordscoreilag^=. then wordscorei_c=wordscoreilag;
			else if wordscoreifor^=. then wordscorei_c=wordscoreifor;
			else do; dpeligible=-1; memeligible=-1; end; /*GDR:they were both =1 at the beginning of the do loop*/
			scorems=scorems+1;
		end;

		if wordscored=. then do;
			if wordscoredlag^=. then wordscored_c=wordscoredlag;
			else if wordscoredfor^=. then wordscored_c=wordscoredfor; 
			else do; dpeligible=-1; memeligible=-1; end;
			scorems=scorems+1;
		end;

		if scorems=2 then memeligible=-2; /*GDR: for composite memory score it doesn't matter the value that tics take since tics is not included in the prediction model*/

		if ticscore=. then do;
			if ticscorelag^=. then ticscore_c=ticscorelag;
			else if ticscorefor^=. then ticscore_c=ticscorefor;
			else dpeligible=-1;
			scorems=scorems+1;
		end;
		if scorems=3 then dpeligible=-2;
	end;

	*proxy respondents must have valid proxy cog scores, otherwise eligibility=0;
	if proxy=1 then do;
	scorems=0;
		if prxmem=. then do;
			if prxmemlag^=. then prxmem_c=prxmemlag-5;
			else if prxmemfor^=. then prxmem_c=prxmemfor-5;
			else do; dpeligible=-1; memeligible=-1; end;
			scorems=scorems+1;
		end;

		if iqcode=. then do;
			if iqcodelag^=. then iqcode_c=iqcodelag-5;
			else if iqcodefor^=. then iqcode_c=iqcodefor-5;
			else do; dpeligible=-1; memeligible=-1; end;
			scorems=scorems+1;
		end;
		if scorems=2 then do; dpeligible=-3; memeligible=-3; end;
	end;

	*impute memory score and dementia probability score;
	if memeligible=1 then do;
		memimp=.4221+.1155*wordscorei_c+.0245*wordscored_c-.0678*iqcode_c-0.2100*prxmem_c-1.3880*proxy-.0669*age_c-.1317*gender2-.3982*race2g
	   +.0102*wordscored_c*age_c+.0392*proxy*age_c-.4459*iqcode_c*gender2;
	end;
	else memimp=.;

	if dpeligible=1 then do;
		etemp=4.6077+.9330*wordscorei_c-.7974*wordscored_c-1.0752*ticscore_c+2.2203*iqcode_c
	   +1.0963*prxmem_c+1.8887*proxy+.0948*age_c-.8536*gender2-.6948*race2g
	   -.2660*wordscorei_c*wordscorei_c+.0427*ticscore_c*ticscore_c+.5428*wordscored_c*gender2+1.5508*iqcode_c*gender2;

		dpimp=1/(1+EXP(-etemp));
	end;
	else dpimp=.; 

	if alives[i] in (5,6,7) then do; memimp=.; dpimp=.; end;
	/*RwIWSTAT: 5.non-respondents, died this wave, 6.non-respondents, died prev wave, 7. non-respondent, dropped from sample*/

	memimpls[i]=memimp;
	dementpimpls[i]=dpimp;
    wordi_cs[i]=wordscorei_c;
	wordd_cs[i]=wordscored_c;
    iqcode_cls[i]=iqcode_c;
	prxmem_cls[i]=prxmem_c;
	tics_cs[i]=ticscore_c;

 end;

run;
proc sort; by hhidpn; run;
/*  45234 observations and 314 variables. */


/*Create final dataset with variables of interest*/
data cog.cogvars_gdr_20251107 (keep=hhidpn HACOHORT RACOHBYR BIRTHYR memimp3-memimp15 dementpimp3-dementpimp15 
                                    memrate_3-memrate_16 AVGIQ_3- AVGIQ_16
									tics3-tics15 age3-age16);
	set all;
	label 	memimp3='Imputed Memory Score for 1995/1996'
			memimp4='Imputed Memory Score for 1998'
			memimp5='Imputed Memory Score for 2000'
			memimp6='Imputed Memory Score for 2002'
			memimp7='Imputed Memory Score for 2004'
			memimp8='Imputed Memory Score for 2006'
			memimp9='Imputed Memory Score for 2008'
			memimp10='Imputed Memory Score for 2010'
			memimp11='Imputed Memory Score for 2012'
			memimp12='Imputed Memory Score for 2014'
			memimp13='Imputed Memory Score for 2016'
			memimp14='Imputed Memory Score for 2018'
			memimp15='Imputed Memory Score for 2020'

			dementpimp3='Imputed Dementia Probability for 1995/1996'
			dementpimp4='Imputed Dementia Probability for 1998'
			dementpimp5='Imputed Dementia Probability for 2000'
			dementpimp6='Imputed Dementia Probability for 2002'
			dementpimp7='Imputed Dementia Probability for 2004'
			dementpimp8='Imputed Dementia Probability for 2006'
			dementpimp9='Imputed Dementia Probability for 2008'
			dementpimp10='Imputed Dementia Probability for 2010'
			dementpimp11='Imputed Dementia Probability for 2012'
			dementpimp12='Imputed Dementia Probability for 2014'
			dementpimp13='Imputed Dementia Probability for 2016'
			dementpimp14='Imputed Dementia Probability for 2018'
			dementpimp15='Imputed Dementia Probability for 2020'


			AVGIQ_3='Average iqcode score for 1995/1996. 1.much improved, 2. a bit improved, 3.not much changed, 4. a bit worse, 5.much worse'
			AVGIQ_4='Average iqcode score for 1998. 1.much improved, 2. a bit improved, 3.not much changed, 4. a bit worse, 5.much worse'
			AVGIQ_5='Average iqcode score for 2000. 1.much improved, 2. a bit improved, 3.not much changed, 4. a bit worse, 5.much worse'
			AVGIQ_6='Average iqcode score for 2002. 1.much improved, 2. a bit improved, 3.not much changed, 4. a bit worse, 5.much worse'
			AVGIQ_7='Average iqcode score for 2004. 1.much improved, 2. a bit improved, 3.not much changed, 4. a bit worse, 5.much worse'
			AVGIQ_8='Average iqcode score for 2006. 1.much improved, 2. a bit improved, 3.not much changed, 4. a bit worse, 5.much worse'
			AVGIQ_9='Average iqcode score for 2008. 1.much improved, 2. a bit improved, 3.not much changed, 4. a bit worse, 5.much worse'
			AVGIQ_10='Average iqcode score for 2010. 1.much improved, 2. a bit improved, 3.not much changed, 4. a bit worse, 5.much worse'
			AVGIQ_11='Average iqcode score for 2012. 1.much improved, 2. a bit improved, 3.not much changed, 4. a bit worse, 5.much worse'
			AVGIQ_12='Average iqcode score for 2014. 1.much improved, 2. a bit improved, 3.not much changed, 4. a bit worse, 5.much worse'
			AVGIQ_13='Average iqcode score for 2016. 1.much improved, 2. a bit improved, 3.not much changed, 4. a bit worse, 5.much worse'
			AVGIQ_14='Average iqcode score for 2018. 1.much improved, 2. a bit improved, 3.not much changed, 4. a bit worse, 5.much worse'
			AVGIQ_15='Average iqcode score for 2020. 1.much improved, 2. a bit improved, 3.not much changed, 4. a bit worse, 5.much worse'
			AVGIQ_16='Average iqcode score for 2022. 1.much improved, 2. a bit improved, 3.not much changed, 4. a bit worse, 5.much worse'

			memrate_3 ='Proxy rated memory score for 1995/1996. 1.Excellent, 2. Very good, 3. Good, 4. Fair, 5. Poor '
			memrate_4 ='Proxy rated memory score for 1998. 1.Excellent, 2. Very good, 3. Good, 4. Fair, 5. Poor '
			memrate_5 ='Proxy rated memory score for 2000. 1.Excellent, 2. Very good, 3. Good, 4. Fair, 5. Poor '
			memrate_6 ='Proxy rated memory score for 2002. 1.Excellent, 2. Very good, 3. Good, 4. Fair, 5. Poor '
			memrate_7 ='Proxy rated memory score for 2004. 1.Excellent, 2. Very good, 3. Good, 4. Fair, 5. Poor '
			memrate_8 ='Proxy rated memory score for 2006. 1.Excellent, 2. Very good, 3. Good, 4. Fair, 5. Poor '
			memrate_9 ='Proxy rated memory score for 2008. 1.Excellent, 2. Very good, 3. Good, 4. Fair, 5. Poor '
			memrate_10 ='Proxy rated memory score for 2010. 1.Excellent, 2. Very good, 3. Good, 4. Fair, 5. Poor '
			memrate_11='Proxy rated memory score for 2012. 1.Excellent, 2. Very good, 3. Good, 4. Fair, 5. Poor '
			memrate_12='Proxy rated memory score for 2014. 1.Excellent, 2. Very good, 3. Good, 4. Fair, 5. Poor '
			memrate_13='Proxy rated memory score for 2016. 1.Excellent, 2. Very good, 3. Good, 4. Fair, 5. Poor '
			memrate_14='Proxy rated memory score for 2018. 1.Excellent, 2. Very good, 3. Good, 4. Fair, 5. Poor '
			memrate_15='Proxy rated memory score for 2020. 1.Excellent, 2. Very good, 3. Good, 4. Fair, 5. Poor '
			memrate_16='Proxy rated memory score for 2022. 1.Excellent, 2. Very good, 3. Good, 4. Fair, 5. Poor '

			/*sum of all tics questions including serial 7s, range: 0-13:
			serial 7s: 0-5
			Object Naming (cactus): 0-1
			Date naming-Day of the Month: 0-1
			Date naming-Month: 0-1
			Date naming-Year: 0-1
			Date naming-Day of week: 0-1
			President/Vice-President Naming: 0-1 and 0-1
			Backwards Counting: 0-1
			*/
			tics3='Total summary score of all tics questions including serial 7s for 1995/1996, range: 0-13'
			tics4='Total summary score of all tics questions including serial 7s for 1998, range: 0-13'
			tics5='Total summary score of all tics questions including serial 7s for 2000, range: 0-13'
			tics6='Total summary score of all tics questions including serial 7s for 2002, range: 0-13'
			tics7='Total summary score of all tics questions including serial 7s for 2004, range: 0-13'
			tics8='Total summary score of all tics questions including serial 7s for 2006, range: 0-13'
			tics9='Total summary score of all tics questions including serial 7s for 2008, range: 0-13'
			tics10='Total summary score of all tics questions including serial 7s for 2010, range: 0-13'
			tics11='Total summary score of all tics questions including serial 7s for 2012, range: 0-13'
			tics12='Total summary score of all tics questions including serial 7s for 2014, range: 0-13'
			tics13='Total summary score of all tics questions including serial 7s for 2016, range: 0-13'
			tics14='Total summary score of all tics questions including serial 7s for 2018, range: 0-13'
			tics15='Total summary score of all tics questions including serial 7s for 2020, range: 0-13'

			age3='R age at 1995/1996 interview'
			age4='R age at 1998 interview'
			age5='R age at 2000 interview'
			age6='R age at 2002 interview'
			age7='R age at 2004 interview'
			age8='R age at 2006 interview'
			age9='R age at 2008 interview'
			age10='R age at 2010 interview'
			age11='R age at 2012 interview'
			age12='R age at 2014 interview'
			age13='R age at 2016 interview'
			age14='R age at 2018 interview'
			age15='R age at 2020 interview'
			age16='R age at 2022 interview'

;
proc sort; by hhidpn; run;
/* 45234 observations and 85 variables. */


/**************************************************************************************************************************************************************************************************************************/

ods csv file='***\HRS_data\GlymourCogMeasures\files\DataDictionary_gdr_20251107.csv';
proc contents data=cog.cogvars_gdr_20251107; run;
ods csv close;

/*Export dataset above to Stata*/
PROC EXPORT DATA= cog.cogvars_gdr_20251107
            OUTFILE= "***\HRS_data\GlymourCogMeasures\statadata\cogvars_gdr_20251107.dta" 
            DBMS=STATA REPLACE;
RUN;
/*The export data set has 45234 observations and 85 variables*/


/*Create reduced dataset: dataset with only hhidpn, dementia probabilities, and composite memory scores from orginal cogvars_gdr_20251107 dataset*/
data cog.cogvarsred_gdr_20251107;
	set cog.cogvars_gdr_20251107 (keep=hhidpn dementpimp3-dementpimp15 memimp3-memimp15);
proc sort; by hhidpn; run;
proc contents data=cog.cogvarsred_gdr_20251107; run;
/* 45234 observations and 27 variables */

/*Export dataset above to Stata*/
PROC EXPORT DATA= cog.cogvarsred_gdr_20251107
            OUTFILE= "***\HRS_data\GlymourCogMeasures\statadata\cogvarsred_gdr_20251107.dta" 
            DBMS=STATA REPLACE;
RUN;
/*The export data set has 45234 observations and 27 variables */


