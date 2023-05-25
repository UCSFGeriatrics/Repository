# Derived ADL and IADL
Writer: Grisell Diaz-Ramirez, MS

Language: SAS

Last Edited: 2023-05-10

This dataset contains derived ADL and IADL variables from 1992-2020 HRS waves:


The code is indicated below or you may also download it [here](https://github.com/UCSFGeriatrics/Repository/blob/master/derived_adl_iadl_gdr_20230510)
_______________________________________________________________________________________________________________
```
***********************************************************************************************************************;
*Title: Derivation of ADL and IADL variables                                                                           ;
*Purpose: Derive variables from 1992-2020 HRS waves:                                                                   ;
*         ADLs core:                                                                                                   ;
*         - any ADL diff (5 ADLs): bath, bed, dress, eat, toilet                                                       ;
*         - any ADL diff (6 ADLs): bath, bed, dress, eat, toilet, walk                                                 ;
*         - ADL diff sum (max 5 ADLs and max 6 ADLs)                                                                   ;
*         - ADL diff number of missing in sum (max 5 ADLs and max 6 ADLs)                                              ;
*         - ADL dependence: bath, bed, dress, eat, toilet, walk                                                        ;
*         - any ADL dep (5 ADLs) , any ADL dep (6 ADLs)                                                                ;
*         - ADL dep sum (max 5 ADLs and max 6 ADLs)                                                                    ;
*         - ADL dep number of missing in sum (max 5 ADLs and max 6 ADLs)                                               ;
*         IADLs core:                                                                                                  ;
*         - any IADL diff (5 IADLs): telephone, money, medicine, shopping, meals                                       ;
*         - IADL diff sum  (max 5 IADLs)                                                                               ;
*         - IADL diff number of missing in sum  (max 5 IADLs)                                                          ;
*         - IADL help (5 IADLs) : telephone, money, medicine, shopping, meals                                          ;
*         - IADL dependence (5 IADLs) : telephone, money, medicine, shopping, meals                                    ;
*         - any IADL dep (5 IADLs)                                                                                     ;
*         - IADL dep sum (max 5 ADLs)                                                                                  ;
*         - IADL dep number of missing in sum (max 5 ADLs)                                                             ;
*         Any ADLs dep Exit (5 ADLs, 6 ADLs)                                                                           ;
*         ADL dep sum Exit (max 5 ADLs and max 6 ADLs)                                                                 ;
*         ADL dep number of missing in sum Exit (max 5 ADLs and max 6 ADLs)                                            ;
*         Maximum time help Exit (5 ADLs, 6 ADLs)                                                                      ;
*         Any IADLs dep Exit (5 IADLs)                                                                                 ;
*         IADL dep sum exit (max 5 ADLs)                                                                               ;
*         IADL dep number of missing in sum exit (max 5 ADLs)                                                          ;
*         Maximum time help Exit (4 IADLs: meal,shop,phone,meds)                                                       ;
*Statistician: Grisell Diaz-Ramirez																					   ;
*Finished: 2023.05.10																								   ;
***********************************************************************************************************************;

***********************************************************************************************************************;
* Other Notes:                                                                                                         ;
*-ADL diff for toilet not asked in wave 1 and 2H                                                                       ;
*-ADL Help variables not present in wave 1 and 2H. So:                                                                 ;
*	-We can only know if the participant didn't have ADL dependence by looking at the ADL difficulty variables         ;
*-Core ADLs with special  missing value:".X=don't do" recoded to "1.yes has limitation"                                ;
*-Exit ADLs with special values: 2.Couldn't do, 9.Didn't do recoded to "1.yes has dependence"                          ;
*-IADL difficulties not asked in wave 1                                                                                ;
*-In wave 2H only IADLs: phone, medicine, and money                                                                    ;
*-IADL help variables not present in waves 1 and 2. So:                                                                ;
*	-We can only know if the participant didn't have IADL dependence by looking at the IADL difficulty variables       ;
*-IADLs with special  missing value:".X=don't do" recoded to "0.no limitation"                                         ;
*  Rebecca Brown 2015:                                                                                                 ;
*  "My clinical perspective is that if the participant says that they don’t do a certain IADL                          ;
*   (e.g., an older man whose wife has always cooked for him) then it doesn’t matter if they would have difficulty     ;
*   if they did do that activity, because they never do that activity."                                                ;
*-For IADL taking medication, change special  missing value:".Z=Don't do/No if did" to "0.no limitation"               ;
*-Exit IADLs with special value: 2.Couldn't do recoded to "1.yes has dependence"                                       ;
*-Exit IADLs with special value: 9.Didn't do recoded to "0.no dependence"                                              ;
***********************************************************************************************************************;

options mergenoby=ERROR;

libname rand 'path\randhrs1992_2020v1_SAS';
proc format cntlin=rand.sasfmts;run;
libname fat 'path\fatfiles';
libname savedata 'path\adl_iadl';
libname olddata 'path\HRS_dataOLD\derived\20210319_adl_iadl';

/******************************MACRO FROM IRENA *******************************/

/* 
MERGE2SETS PURPOSE: MERGES 2 DATASETS 
MERGE2SETS PARAMETERS:
1) DESTDATA = DESTINATION DATASET (INCLUDING LIBNAME AND IN= if APPLICABLE)
2) SRCDATA1 = FIRST SOURCE DATASET
3) KEEPLIST1 = LIST OF VARIABLES TO KEEP FROM FIRST SOURCE DATASET (NOT INCLUDING
	THE "KEEP = " STATEMENT ITSELF, SEPARATE VARIABLES BY SPACES) (OPTIONAL)
4) SRCDATA2 = SECOND SOURCE DATASET
5) KEEPLIST2 = LIST OF VARIABLES TO KEEP FROM SECOND SOURCE DATASET (NOT INCLUDING
	THE "KEEP = " STATEMENT ITSELF, SEPARATE VARIABLES BY SPACES) (OPTIONAL)
6) BYVARS = LIST OF VARIABLES TO SORT AND MERGE BY
7) IFSTMT = if STATEMENT TO SELECT CERTAIN OBSERVATIONS (NOT INCLUDING THE "if"
	ITSELF, MUST BE INSIDE A STRING FUNCTION if ANY OPERATORS ARE USED, FOR EG.
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


/******************************MACRO FOR LABELING MANY VARIABLES *******************************/

/* Adapted Macro from NESUG 2009 proceedings paper: Techniques for Labeling Variables
VarStart: Common beginning stem for variable names
Var: Common stem for variable names
Start: Number of first variable in series
NVars: Count of variables to be labeled
Label: Common text for variable labels
*/

%macro VarLabels(VarStart= , Var= , Start= ,NVars= , Label= );
 %local i;
 %let label=%sysfunc(dequote(&label)); /*sysfunc: execute SAS functions or user-written functions, and it’s a macro function. I used it to redefine macro variables &label without quotes*/
 %do i = &start %to &start + &NVars - 1;
 &varstart&i&var = "W&i &label"
 %end;
%mend VarLabels;


proc contents data=fat.h18f2b; run;

/*Get IADL help variables from fat files from 1995-2020: meal, shop, phone, meds, money*/
%merge2sets(savedata.fatvarsIADLhelp, 				 fat.h20e2a,        hhidpn RG043 RG046 RG049 RG053 RG061, 
							  					 	 fat.h18f2b,        hhidpn QG043 QG046 QG049 QG053 QG061, hhidpn, ); 
%merge2sets(savedata.fatvarsIADLhelp, savedata.fatvarsIADLhelp, , fat.h16f2c,   hhidpn PG043 PG046 PG049 PG053 PG061 , hhidpn, ); 
%merge2sets(savedata.fatvarsIADLhelp, savedata.fatvarsIADLhelp, , fat.h14f2b,   hhidpn OG043 OG046 OG049 OG053 OG061 , hhidpn, ); 
%merge2sets(savedata.fatvarsIADLhelp, savedata.fatvarsIADLhelp, , fat.h12f3a,   hhidpn NG043 NG046 NG049 NG053 NG061 , hhidpn, ); 
%merge2sets(savedata.fatvarsIADLhelp, savedata.fatvarsIADLhelp, , fat.hd10f6a,  hhidpn MG043 MG046 MG049 MG053 MG061 , hhidpn, ); 
%merge2sets(savedata.fatvarsIADLhelp, savedata.fatvarsIADLhelp, , fat.h08f3a,   hhidpn LG043 LG046 LG049 LG053 LG061 , hhidpn, ); 
%merge2sets(savedata.fatvarsIADLhelp, savedata.fatvarsIADLhelp, , fat.h06f4a,   hhidpn KG043 KG046 KG049 KG053 KG061 , hhidpn, ); 
%merge2sets(savedata.fatvarsIADLhelp, savedata.fatvarsIADLhelp, , fat.h04f1c,   hhidpn JG043 JG046 JG049 JG053 JG061 , hhidpn, ); 
%merge2sets(savedata.fatvarsIADLhelp, savedata.fatvarsIADLhelp, , fat.h02f2c,   hhidpn HG043 HG046 HG049 HG053 HG061 , hhidpn, ); 
%merge2sets(savedata.fatvarsIADLhelp, savedata.fatvarsIADLhelp, , fat.h00f1d,   hhidpn G2863 G2868 G2873 G2878 G2918 , hhidpn, ); 
%merge2sets(savedata.fatvarsIADLhelp, savedata.fatvarsIADLhelp, , fat.hd98f2c,  hhidpn F2565 F2570 F2575 F2580 F2620 , hhidpn, ); 
%merge2sets(savedata.fatvarsIADLhelp, savedata.fatvarsIADLhelp, , fat.h96f4a,   hhidpn E2039 E2044 E2049 E2054 E2096 , hhidpn, ); 
%merge2sets(savedata.fatvarsIADLhelp, savedata.fatvarsIADLhelp, , fat.ad95f2b,  hhidpn D2024 D2029 D2034 D2039 D2102 , hhidpn, ); 
/*40131 observations and 71 variables.*/

proc contents data=savedata.fatvarsIADLhelp; run;
proc freq data=savedata.fatvarsIADLhelp; tables QG043 QG046 QG049 QG053 QG061 / missing; run;

/*Get ADL and IADL variables from RAND HRS dataset*/
data savedata.randvars_adl_iadl;
	set rand.randhrs1992_2020v1 (keep=hhidpn HACOHORT RACOHBYR
	/*ADL difficulty: ADL diff for toilet not asked in wave 1*/
		R1BATHW  R2BATHA   R3BATHA   R4BATHA   R5BATHA   R6BATHA   R7BATHA   R8BATHA   R9BATHA   R10BATHA   R11BATHA  R12BATHA	R13BATHA  R14BATHA  R15BATHA
		R1BEDW   R2BEDA    R3BEDA    R4BEDA    R5BEDA    R6BEDA    R7BEDA    R8BEDA    R9BEDA    R10BEDA    R11BEDA	  R12BEDA	R13BEDA   R14BEDA   R15BEDA	
		R1DRESSW R2DRESSA  R3DRESSA  R4DRESSA  R5DRESSA  R6DRESSA  R7DRESSA  R8DRESSA  R9DRESSA  R10DRESSA  R11DRESSA R12DRESSA	R13DRESSA R14DRESSA R15DRESSA
		R1EATW   R2EATA    R3EATA    R4EATA    R5EATA    R6EATA    R7EATA    R8EATA    R9EATA    R10EATA    R11EATA	  R12EATA	R13EATA	  R14EATA	R15EATA
		 		 R2TOILTA  R3TOILTA  R4TOILTA  R5TOILTA  R6TOILTA  R7TOILTA  R8TOILTA  R9TOILTA  R10TOILTA  R11TOILTA R12TOILTA R13TOILTA R14TOILTA	R15TOILTA
		R1WALKRW R2WALKRA  R3WALKRA  R4WALKRA  R5WALKRA  R6WALKRA  R7WALKRA  R8WALKRA  R9WALKRA  R10WALKRA  R11WALKRA R12WALKRA	R13WALKRA R14WALKRA	R15WALKRA

	/*ADL Help variables: not present in wave 1*/
				 R2BATHH   R3BATHH   R4BATHH   R5BATHH   R6BATHH   R7BATHH   R8BATHH   R9BATHH   R10BATHH   R11BATHH	R12BATHH R13BATHH  R14BATHH	  R15BATHH
				 R2BEDH    R3BEDH    R4BEDH    R5BEDH    R6BEDH    R7BEDH    R8BEDH    R9BEDH    R10BEDH    R11BEDH		R12BEDH	 R13BEDH   R14BEDH	  R15BEDH
				 R2DRESSH  R3DRESSH  R4DRESSH  R5DRESSH  R6DRESSH  R7DRESSH  R8DRESSH  R9DRESSH  R10DRESSH  R11DRESSH	R12DRESSH R13DRESSH R14DRESSH R15DRESSH
				 R2EATH    R3EATH    R4EATH    R5EATH    R6EATH    R7EATH    R8EATH    R9EATH    R10EATH    R11EATH		R12EATH	  R13EATH   R14EATH	  R15EATH
				 R2TOILTH  R3TOILTH  R4TOILTH  R5TOILTH  R6TOILTH  R7TOILTH  R8TOILTH  R9TOILTH  R10TOILTH  R11TOILTH	R12TOILTH R13TOILTH R14TOILTH R15TOILTH
				 R2WALKRH  R3WALKRH  R4WALKRH  R5WALKRH  R6WALKRH  R7WALKRH  R8WALKRH  R9WALKRH  R10WALKRH  R11WALKRH	R12WALKRH R13WALKRH R14WALKRH R15WALKRH

	/*IADL difficulty: IADL difficulties not asked in wave 1. In wave 2H only IADLs: using the phone, taking medications, and managing money*/
				R2PHONEA 	R3PHONEA 	R4PHONEA 	R5PHONEA 	R6PHONEA 	R7PHONEA 	R8PHONEA 	R9PHONEA 	R10PHONEA 	R11PHONEA 	R12PHONEA	R13PHONEA	R14PHONEA	R15PHONEA
				R2MONEYA 	R3MONEYA 	R4MONEYA 	R5MONEYA 	R6MONEYA 	R7MONEYA 	R8MONEYA 	R9MONEYA 	R10MONEYA 	R11MONEYA 	R12MONEYA	R13MONEYA	R14MONEYA	R15MONEYA
				R2MEDSA  	R3MEDSA  	R4MEDSA  	R5MEDSA  	R6MEDSA  	R7MEDSA  	R8MEDSA  	R9MEDSA  	R10MEDSA 	R11MEDSA 	R12MEDSA	R13MEDSA	R14MEDSA    R15MEDSA
				R2SHOPA  	R3SHOPA  	R4SHOPA  	R5SHOPA  	R6SHOPA  	R7SHOPA  	R8SHOPA  	R9SHOPA  	R10SHOPA 	R11SHOPA 	R12SHOPA	R13SHOPA	R14SHOPA    R15SHOPA
				R2MEALSA 	R3MEALSA 	R4MEALSA 	R5MEALSA 	R6MEALSA 	R7MEALSA 	R8MEALSA 	R9MEALSA 	R10MEALSA 	R11MEALSA 	R12MEALSA	R13MEALSA	R14MEALSA   R15MEALSA 

/*Exit interview variables*/
    R2PEXIT R3PEXIT R4PEXIT R5PEXIT R6PEXIT R7PEXIT R8PEXIT R9PEXIT R10PEXIT R11PEXIT R12PEXIT R13PEXIT R14PEXIT R15PEXIT
    REXITWV REPEXITWV1 REPEXITWV2 REPEXITWV3
    REWALKRH REDRESSH REBATHH REEATH REBEDH RETOILTH
    REWALKRT REDRESST REBATHT REEATT REBEDT RETOILTT

	REMEALSH RESHOPH REPHONEH REMEDSH REMONEYH
    REMEALST RESHOPT REPHONET REMEDST

);
proc sort; by hhidpn; run;	
/*42406 observations and 285 variables*/

/*Merge fatvarsIADLhelp and randvars_adl_iadl*/
data randfat;
	merge savedata.randvars_adl_iadl (in=A) savedata.fatvarsIADLhelp;
	by hhidpn;
	if A;
proc sort; by hhidpn; run;	
/*42406 observations and 285+70=355 variables.*/ 

proc freq data=randfat; tables HACOHORT RACOHBYR; run;
proc contents data=randfat; run; 

/*Derive any ADL difficulty, ADLsum (5 and 6 ADLs), missing in sum ADL (5 and 6 ADLs)*/
data randfat2;
	set randfat;

	R1TOILTW=.; /*set the ADL difficulty for using the toilet equal to missing since this question was not asked in wave 1*/

	array BADIF[15] R1BATHW 	R2BATHA 	R3BATHA 	R4BATHA 	R5BATHA 	R6BATHA 	R7BATHA 	R8BATHA 	R9BATHA 	R10BATHA 	R11BATHA 	R12BATHA	R13BATHA	R14BATHA	R15BATHA;
	array BEDIF[15] R1BEDW  	R2BEDA  	R3BEDA  	R4BEDA  	R5BEDA  	R6BEDA  	R7BEDA  	R8BEDA  	R9BEDA  	R10BEDA  	R11BEDA  	R12BEDA		R13BEDA		R14BEDA		R15BEDA;
	array DRDIF[15] R1DRESSW 	R2DRESSA 	R3DRESSA 	R4DRESSA 	R5DRESSA 	R6DRESSA 	R7DRESSA 	R8DRESSA 	R9DRESSA 	R10DRESSA 	R11DRESSA 	R12DRESSA	R13DRESSA	R14DRESSA	R15DRESSA;
	array EADIF[15] R1EATW 		R2EATA 		R3EATA 		R4EATA 		R5EATA 		R6EATA 		R7EATA 		R8EATA 		R9EATA 		R10EATA 	R11EATA   	R12EATA		R13EATA		R14EATA		R15EATA;
	array TODIF[15] R1TOILTW 	R2TOILTA 	R3TOILTA 	R4TOILTA 	R5TOILTA 	R6TOILTA 	R7TOILTA 	R8TOILTA 	R9TOILTA 	R10TOILTA 	R11TOILTA 	R12TOILTA	R13TOILTA	R14TOILTA	R15TOILTA;
	array WADIF[15]	R1WALKRW   	R2WALKRA  	R3WALKRA  	R4WALKRA  	R5WALKRA  	R6WALKRA 	R7WALKRA  	R8WALKRA  	R9WALKRA  	R10WALKRA  	R11WALKRA 	R12WALKRA	R13WALKRA	R14WALKRA	R15WALKRA;
	
	array ADLYN[15] 	R1ADLDIF 	 R2ADLDIF 	  R3ADLDIF 	   R4ADLDIF 	R5ADLDIF 	 R6ADLDIF 	  R7ADLDIF 	   R8ADLDIF 	R9ADLDIF 	 R10ADLDIF 	   R11ADLDIF 		R12ADLDIF		R13ADLDIF		R14ADLDIF		R15ADLDIF;
	array ADLSM[15] 	R1ADLDIFSUM  R2ADLDIFSUM  R3ADLDIFSUM  R4ADLDIFSUM  R5ADLDIFSUM  R6ADLDIFSUM  R7ADLDIFSUM  R8ADLDIFSUM  R9ADLDIFSUM  R10ADLDIFSUM  R11ADLDIFSUM 	R12ADLDIFSUM	R13ADLDIFSUM	R14ADLDIFSUM	R15ADLDIFSUM;
	array ADLSMMIS[15] 	R1ADLDIFMISS R2ADLDIFMISS R3ADLDIFMISS R4ADLDIFMISS R5ADLDIFMISS R6ADLDIFMISS R7ADLDIFMISS R8ADLDIFMISS R9ADLDIFMISS R10ADLDIFMISS R11ADLDIFMISS 	R12ADLDIFMISS	R13ADLDIFMISS	R14ADLDIFMISS	R15ADLDIFMISS;

	array ADLYN6[15] 	R1ADLDIF6 		R2ADLDIF6 		R3ADLDIF6 		R4ADLDIF6 		R5ADLDIF6 		R6ADLDIF6 		R7ADLDIF6 		R8ADLDIF6 		R9ADLDIF6 		R10ADLDIF6 		R11ADLDIF6 		R12ADLDIF6		R13ADLDIF6		R14ADLDIF6		R15ADLDIF6;
	array ADLSM6[15] 	R1ADLDIFSUM6 	R2ADLDIFSUM6 	R3ADLDIFSUM6 	R4ADLDIFSUM6 	R5ADLDIFSUM6 	R6ADLDIFSUM6 	R7ADLDIFSUM6 	R8ADLDIFSUM6 	R9ADLDIFSUM6 	R10ADLDIFSUM6 	R11ADLDIFSUM6 	R12ADLDIFSUM6	R13ADLDIFSUM6	R14ADLDIFSUM6	R15ADLDIFSUM6;
    array ADLSMMI6[15] 	R1ADLDIFMISS6 	R2ADLDIFMISS6   R3ADLDIFMISS6   R4ADLDIFMISS6   R5ADLDIFMISS6   R6ADLDIFMISS6   R7ADLDIFMISS6   R8ADLDIFMISS6   R9ADLDIFMISS6   R10ADLDIFMISS6  R11ADLDIFMISS6 	R12ADLDIFMISS6	R13ADLDIFMISS6	R14ADLDIFMISS6	R15ADLDIFMISS6;

	do i=1 to 15;

	  /*Change special  missing value:.X 'don't do' to 1.yes has limitation*/
		if BADIF[i]=.X then BADIF[i]=1;
		if BEDIF[i]=.X then BEDIF[i]=1;
		if DRDIF[i]=.X then DRDIF[i]=1;
		if EADIF[i]=.X then EADIF[i]=1;
		if TODIF[i]=.X then TODIF[i]=1;
		if WADIF[i]=.X then WADIF[i]=1;


		if i=1 or (i=2 and HACOHORT=3) then do;
		/*This doesn't include the ADL for toilet because it was asked for wave 2A and from wave 3 forward, so the ADLdiff in wave 1 and wave 2H (HACOHORT=3.Hrs) is based on 4 ADLs rather than 5 ADLs*/
		   if BADIF[i]=1 or BEDIF[i]=1 or DRDIF[i]=1 or EADIF[i]=1 then ADLYN[i]=1;
		   else if BADIF[i]=0 and BEDIF[i]=0 and DRDIF[i]=0 and EADIF[i]=0 then ADLYN[i]=0;

		   if ADLYN[i]=1 then do; ADLSM[i]=sum(of BADIF[i] BEDIF[i] DRDIF[i] EADIF[i]); ADLSMMIS[i]=nmiss(of BADIF[i] BEDIF[i] DRDIF[i] EADIF[i]); end; 
   		   else if ADLYN[i]=0 then do; ADLSM[i]=0; ADLSMMIS[i]=0; end;

		  /*This any ADL diff and sum variables considered 5 ADLs instead of 4 since they include walking across-room*/
		   if BADIF[i]=1 or BEDIF[i]=1 or DRDIF[i]=1 or EADIF[i]=1 or WADIF[i]=1 then ADLYN6[i]=1;
		   else if BADIF[i]=0 and BEDIF[i]=0 and DRDIF[i]=0 and EADIF[i]=0 and WADIF[i]=0 then ADLYN6[i]=0;

		   if ADLYN6[i]=1 then do; ADLSM6[i]=sum(of BADIF[i] BEDIF[i] DRDIF[i] EADIF[i] WADIF[i]); ADLSMMI6[i]=nmiss(of BADIF[i] BEDIF[i] DRDIF[i] EADIF[i] WADIF[i]); end;
   		   else if ADLYN6[i]=0 then do; ADLSM6[i]=0; ADLSMMI6[i]=0; end;
 		end;

		else if (i=2 and HACOHORT ne 3) or i in (3,4,5,6,7,8,9,10,11,12,13,14,15) then do;
		/*This includes the ADL for toilet  because it was asked for wave 2A and from wave 3 forward*/
		   if BADIF[i]=1 or BEDIF[i]=1 or DRDIF[i]=1 or EADIF[i]=1 or TODIF[i]=1 then ADLYN[i]=1;
		   else if BADIF[i]=0 and BEDIF[i]=0 and DRDIF[i]=0 and EADIF[i]=0 and TODIF[i]=0 then ADLYN[i]=0;

		   if ADLYN[i]=1 then do; ADLSM[i]=sum(OF BADIF[i] BEDIF[i] DRDIF[i] EADIF[i] TODIF[i]); ADLSMMIS[i]=nmiss(OF BADIF[i] BEDIF[i] DRDIF[i] EADIF[i] TODIF[i]); end;
   		   else if ADLYN[i]=0 then do; ADLSM[i]=0; ADLSMMIS[i]=0; end;

		  /*This any ADL diff and sum variables considered 6 ADLs instead of 5 since they include walking across-room*/
		   if BADIF[i]=1 or BEDIF[i]=1 or DRDIF[i]=1 or EADIF[i]=1 or TODIF[i]=1 or WADIF[i]=1 then ADLYN6[i]=1;
		   else if BADIF[i]=0 and BEDIF[i]=0 and DRDIF[i]=0 and EADIF[i]=0 and TODIF[i]=0 and WADIF[i]=0 then ADLYN6[i]=0;

		   if ADLYN6[i]=1 then do; ADLSM6[i]=sum(of BADIF[i] BEDIF[i] DRDIF[i] EADIF[i] TODIF[i] WADIF[i]);  ADLSMMI6[i]=nmiss(of BADIF[i] BEDIF[i] DRDIF[i] EADIF[i] TODIF[i] WADIF[i]); end;
   		   else if ADLYN6[i]=0 then do; ADLSM6[i]=0; ADLSMMI6[i]=0; end;
 		end;

	end; drop i;

 label %VarLabels( VarStart=R , Var=ADLDIF, Start=1, NVars=15, Label= 'Whether any of 5 ADL diff (bath,bed,dress,eat,toil). 0.no, 1.yes' ) ;
 label %VarLabels( VarStart=R , Var=ADLDIFSUM, Start=1, NVars=15, Label= 'Sum of 5 ADL diff (bath,bed,dress,eat,toil), range:0-5' ) ;
 label %VarLabels( VarStart=R , Var=ADLDIFMISS, Start=1, NVars=15, Label= 'Number of ADL diff missing in sum (bath,bed,dress,eat,toil), range:0-5' ) ;
 label %VarLabels( VarStart=R , Var=ADLDIF6, Start=1, NVars=15, Label= 'Whether any of 6 ADL diff (bath,bed,dress,eat,toil,walk). 0.no, 1.yes' ) ;
 label %VarLabels( VarStart=R , Var=ADLDIFSUM6, Start=1, NVars=15, Label= 'Sum of 6 ADL diff (bath,bed,dress,eat,toil,walk), range:0-6' ) ;
 label %VarLabels( VarStart=R , Var=ADLDIFMISS6, Start=1, NVars=15, Label= 'Number of ADL diff missing in sum (bath,bed,dress,eat,toil,walk), range:0-6' ) ;

*Relabel W1 variables since they don't include toilet;
 label R1ADLDIF="W1 Whether any of 4 ADL diff (bath,bed,dress,eat). 0.no, 1.yes"
       R1ADLDIFSUM="W1 Sum of 4 ADL diff (bath,bed,dress,eat), range:0-4"
       R1ADLDIFMISS="W1 Number of ADL diff missing in sum (bath,bed,dress,eat), range:0-4"
	   R1ADLDIF6="W1 Whether any of 5 ADL diff (bath,bed,dress,eat,walk). 0.no, 1.yes"
       R1ADLDIFSUM6="W1 Sum of 5 ADL diff (bath,bed,dress,eat,walk), range:0-5"
       R1ADLDIFMISS6="W1 Number of ADL diff missing in sum (bath,bed,dress,eat,walk), range:0-5";
proc sort; by hhidpn;run;
/*42406 observations and 355+1(R1TOILTW)+15*6=446 variables.*/

/*QC*/
proc contents data=randfat2 position; run;
proc means data=randfat2 n nmiss min max mean; var R1ADLDIF 	R2ADLDIF 	R3ADLDIF 	R4ADLDIF 	R5ADLDIF 	R6ADLDIF 	R7ADLDIF 	R8ADLDIF 	R9ADLDIF 	R10ADLDIF
                                              R11ADLDIF 	R12ADLDIF	R13ADLDIF	R14ADLDIF R15ADLDIF; run;
*Compare with previous version of data;
proc means data=olddata.derived_adl_iadl_gdr_20210319 n nmiss min max mean; var R1ADLDIF 	R2ADLDIF 	R3ADLDIF 	R4ADLDIF 	R5ADLDIF 	R6ADLDIF 	R7ADLDIF 	R8ADLDIF 	R9ADLDIF 	R10ADLDIF
                                              R11ADLDIF 	R12ADLDIF	R13ADLDIF	R14ADLDIF ; run;

proc means data=randfat2 n nmiss min max mean; var R1ADLDIFSUM 	R2ADLDIFSUM 	R3ADLDIFSUM 	R4ADLDIFSUM 	R5ADLDIFSUM 	R6ADLDIFSUM 	R7ADLDIFSUM 	R8ADLDIFSUM 	R9ADLDIFSUM 	R10ADLDIFSUM
                                              R11ADLDIFSUM 	R12ADLDIFSUM	R13ADLDIFSUM	R14ADLDIFSUM R15ADLDIFSUM; run;
*Compare with previous version of data;
proc means data=olddata.derived_adl_iadl_gdr_20210319 n nmiss min max mean; var R1ADLDIFSUM 	R2ADLDIFSUM 	R3ADLDIFSUM 	R4ADLDIFSUM 	R5ADLDIFSUM 	R6ADLDIFSUM 	R7ADLDIFSUM 	R8ADLDIFSUM 	R9ADLDIFSUM 	R10ADLDIFSUM
                                              R11ADLDIFSUM 	R12ADLDIFSUM	R13ADLDIFSUM	R14ADLDIFSUM ; run;


proc means data=randfat2 n nmiss min max; var R1ADLDIFMISS 	R2ADLDIFMISS 	R3ADLDIFMISS 	R4ADLDIFMISS 	R5ADLDIFMISS 	R6ADLDIFMISS 	R7ADLDIFMISS 	R8ADLDIFMISS 	R9ADLDIFMISS 	R10ADLDIFMISS
                                              R11ADLDIFMISS 	R12ADLDIFMISS	R13ADLDIFMISS	R14ADLDIFMISS R15ADLDIFMISS; run;


proc means data=randfat2 n nmiss min max mean; var R1ADLDIF6 	R2ADLDIF6 	R3ADLDIF6 	R4ADLDIF6 	R5ADLDIF6 	R6ADLDIF6 	R7ADLDIF6 	R8ADLDIF6 	R9ADLDIF6 	R10ADLDIF6
                                              R11ADLDIF6 	R12ADLDIF6	R13ADLDIF6	R14ADLDIF6 R15ADLDIF6; run;
*Compare with previous version of data;
proc means data=olddata.derived_adl_iadl_gdr_20210319 n nmiss min max mean; var R1ADLDIF6 	R2ADLDIF6 	R3ADLDIF6 	R4ADLDIF6 	R5ADLDIF6 	R6ADLDIF6 	R7ADLDIF6 	R8ADLDIF6 	R9ADLDIF6 	R10ADLDIF6
                                              R11ADLDIF6 	R12ADLDIF6	R13ADLDIF6	R14ADLDIF6; run;

proc means data=randfat2 n nmiss min max mean; var R1ADLDIFSUM6 	R2ADLDIFSUM6 	R3ADLDIFSUM6 	R4ADLDIFSUM6 	R5ADLDIFSUM6 	R6ADLDIFSUM6 	R7ADLDIFSUM6 	R8ADLDIFSUM6 	R9ADLDIFSUM6 	R10ADLDIFSUM6
                                              R11ADLDIFSUM6 	R12ADLDIFSUM6	R13ADLDIFSUM6	R14ADLDIFSUM6 R15ADLDIFSUM6; run;
*Compare with previous version of data;
proc means data=olddata.derived_adl_iadl_gdr_20210319 n nmiss min max mean; var R1ADLDIFSUM6 	R2ADLDIFSUM6 	R3ADLDIFSUM6 	R4ADLDIFSUM6 	R5ADLDIFSUM6 	R6ADLDIFSUM6 	R7ADLDIFSUM6 	R8ADLDIFSUM6 	R9ADLDIFSUM6 	R10ADLDIFSUM6
                                              R11ADLDIFSUM6 	R12ADLDIFSUM6	R13ADLDIFSUM6	R14ADLDIFSUM6; run; 


proc means data=randfat2 n nmiss min max; var R1ADLDIFMISS6 	R2ADLDIFMISS6 	R3ADLDIFMISS6 	R4ADLDIFMISS6 	R5ADLDIFMISS6 	R6ADLDIFMISS6 	R7ADLDIFMISS6 	R8ADLDIFMISS6 	R9ADLDIFMISS6 	R10ADLDIFMISS6
                                              R11ADLDIFMISS6 	R12ADLDIFMISS6	R13ADLDIFMISS6	R14ADLDIFMISS6 R15ADLDIFMISS6; run;

*wave1;
proc freq data=randfat2; tables R1BATHW*R1BEDW*R1DRESSW*R1EATW*R1TOILTW*R1ADLDIF*R1ADLDIFSUM*R1ADLDIFMISS /list missing; run;
proc freq data=randfat2; tables R1BATHW*R1BEDW*R1DRESSW*R1EATW*R1TOILTW*R1WALKRW*R1ADLDIF6*R1ADLDIFSUM6*R1ADLDIFMISS6 /list missing; run;

*wave2 and HACOHORT=3;
proc freq data=randfat2; tables R2BATHA*R2BEDA*R2DRESSA*R2EATA*R2TOILTA*R2ADLDIF*R2ADLDIFSUM*R2ADLDIFMISS /list missing; where HACOHORT=3; run;
proc freq data=randfat2; tables R2BATHA*R2BEDA*R2DRESSA*R2EATA*R2TOILTA*R2WALKRA*R2ADLDIF6*R2ADLDIFSUM6*R2ADLDIFMISS6 /list missing; where HACOHORT=3; run;

*wave2 and HACOHORT ne 3;
proc freq data=randfat2; tables R2BATHA*R2BEDA*R2DRESSA*R2EATA*R2TOILTA*R2ADLDIF*R2ADLDIFSUM*R2ADLDIFMISS /list missing; where HACOHORT ne 3; run;
proc freq data=randfat2; tables R2BATHA*R2BEDA*R2DRESSA*R2EATA*R2TOILTA*R2WALKRA*R2ADLDIF6*R2ADLDIFSUM6*R2ADLDIFMISS6 /list missing; where HACOHORT ne 3; run;

*wave>2;
proc freq data=randfat2; tables R7BATHA*R7BEDA*R7DRESSA*R7EATA*R7TOILTA*R7ADLDIF*R7ADLDIFSUM*R7ADLDIFMISS /list missing; run;
proc freq data=randfat2; tables R7BATHA*R7BEDA*R7DRESSA*R7EATA*R7TOILTA*R7WALKRA*R7ADLDIF6*R7ADLDIFSUM6*R7ADLDIFMISS6 /list missing; run;


/*Derive: individual ADL dependence, any ADL dependence (5 adl) , any ADLdep (6 adl), sum ADL dep (5 and 6 ADLs), missing in sum ADL dep (5 and 6 ADLs) */
data randfat3;
	set randfat2;

	array BADIF[15] R1BATHW 	R2BATHA 	R3BATHA 	R4BATHA 	R5BATHA 	R6BATHA 	R7BATHA 	R8BATHA 	R9BATHA 	R10BATHA 	R11BATHA 	R12BATHA	R13BATHA	R14BATHA	R15BATHA;
	array BEDIF[15] R1BEDW  	R2BEDA  	R3BEDA  	R4BEDA  	R5BEDA  	R6BEDA  	R7BEDA  	R8BEDA  	R9BEDA  	R10BEDA  	R11BEDA  	R12BEDA		R13BEDA		R14BEDA		R15BEDA;
	array DRDIF[15] R1DRESSW 	R2DRESSA 	R3DRESSA 	R4DRESSA 	R5DRESSA 	R6DRESSA 	R7DRESSA 	R8DRESSA 	R9DRESSA 	R10DRESSA 	R11DRESSA 	R12DRESSA	R13DRESSA	R14DRESSA	R15DRESSA;
	array EADIF[15] R1EATW 		R2EATA 		R3EATA 		R4EATA 		R5EATA 		R6EATA 		R7EATA 		R8EATA 		R9EATA 		R10EATA 	R11EATA   	R12EATA		R13EATA		R14EATA		R15EATA;
	array TODIF[15] R1TOILTW 	R2TOILTA 	R3TOILTA 	R4TOILTA 	R5TOILTA 	R6TOILTA 	R7TOILTA 	R8TOILTA 	R9TOILTA 	R10TOILTA 	R11TOILTA 	R12TOILTA	R13TOILTA	R14TOILTA	R15TOILTA;
	array WADIF[15]	R1WALKRW   	R2WALKRA  	R3WALKRA  	R4WALKRA  	R5WALKRA  	R6WALKRA 	R7WALKRA  	R8WALKRA  	R9WALKRA  	R10WALKRA  	R11WALKRA 	R12WALKRA	R13WALKRA	R14WALKRA	R15WALKRA;


	/*Because in wave 1 questions about help are not asked I set those values for help in wave 1 as missing
	For HRS Respondents in Wave 2H, the R2[adl]H variables are already set to .Q.*/
	R1BATHH=.; R1BEDH=.; R1DRESSH=.; R1EATH=.; R1TOILTH=.; R1WALKRH=.;

	array BAH [15] R1BATHH    R2BATHH   R3BATHH   R4BATHH   R5BATHH   R6BATHH   R7BATHH   R8BATHH   R9BATHH   R10BATHH   R11BATHH	R12BATHH	R13BATHH	R14BATHH	R15BATHH;
	array BEH [15] R1BEDH     R2BEDH    R3BEDH    R4BEDH    R5BEDH    R6BEDH    R7BEDH    R8BEDH    R9BEDH    R10BEDH    R11BEDH	R12BEDH		R13BEDH		R14BEDH		R15BEDH;
	array DRH [15] R1DRESSH   R2DRESSH  R3DRESSH  R4DRESSH  R5DRESSH  R6DRESSH  R7DRESSH  R8DRESSH  R9DRESSH  R10DRESSH  R11DRESSH	R12DRESSH	R13DRESSH	R14DRESSH	R15DRESSH;
	array EAH [15] R1EATH     R2EATH    R3EATH    R4EATH    R5EATH    R6EATH    R7EATH    R8EATH    R9EATH    R10EATH    R11EATH	R12EATH		R13EATH		R14EATH		R15EATH;
	array TOH [15] R1TOILTH   R2TOILTH  R3TOILTH  R4TOILTH  R5TOILTH  R6TOILTH  R7TOILTH  R8TOILTH  R9TOILTH  R10TOILTH  R11TOILTH	R12TOILTH	R13TOILTH	R14TOILTH	R15TOILTH;
	array WAH [15] R1WALKRH   R2WALKRH  R3WALKRH  R4WALKRH  R5WALKRH  R6WALKRH  R7WALKRH  R8WALKRH  R9WALKRH  R10WALKRH  R11WALKRH	R12WALKRH	R13WALKRH	R14WALKRH	R15WALKRH;

	/*Dependence variables: these variables are derived below*/
	array BAD [15] R1BATHDE   R2BATHDE  R3BATHDE  R4BATHDE  R5BATHDE  R6BATHDE  R7BATHDE  R8BATHDE  R9BATHDE  R10BATHDE  R11BATHDE		R12BATHDE	R13BATHDE	R14BATHDE	R15BATHDE;
	array BED [15] R1BEDDE    R2BEDDE   R3BEDDE   R4BEDDE   R5BEDDE   R6BEDDE   R7BEDDE   R8BEDDE   R9BEDDE   R10BEDDE   R11BEDDE		R12BEDDE	R13BEDDE	R14BEDDE	R15BEDDE;
	array DRD [15] R1DRESSDE  R2DRESSDE R3DRESSDE R4DRESSDE R5DRESSDE R6DRESSDE R7DRESSDE R8DRESSDE R9DRESSDE R10DRESSDE R11DRESSDE		R12DRESSDE	R13DRESSDE	R14DRESSDE	R15DRESSDE;
	array EAD [15] R1EATDE    R2EATDE   R3EATDE   R4EATDE   R5EATDE   R6EATDE   R7EATDE   R8EATDE   R9EATDE   R10EATDE   R11EATDE		R12EATDE	R13EATDE	R14EATDE	R15EATDE;
	array TOD [15] R1TOILTDE  R2TOILTDE R3TOILTDE R4TOILTDE R5TOILTDE R6TOILTDE R7TOILTDE R8TOILTDE R9TOILTDE R10TOILTDE R11TOILTDE		R12TOILTDE	R13TOILTDE	R14TOILTDE	R15TOILTDE;
	array WAD [15] R1WALKRDE  R2WALKRDE R3WALKRDE R4WALKRDE R5WALKRDE R6WALKRDE R7WALKRDE R8WALKRDE R9WALKRDE R10WALKRDE R11WALKRDE		R12WALKRDE	R13WALKRDE	R14WALKRDE	R15WALKRDE;

	array ADLDEY[15] 	R1ADLDE  	R2ADLDE   	R3ADLDE     R4ADLDE     R5ADLDE     R6ADLDE     R7ADLDE     R8ADLDE     R9ADLDE     R10ADLDE     R11ADLDE      R12ADLDE		R13ADLDE 	 R14ADLDE		R15ADLDE;
	array ADLSM[15]  	R1ADLDESUM  R2ADLDESUM  R3ADLDESUM  R4ADLDESUM  R5ADLDESUM  R6ADLDESUM  R7ADLDESUM  R8ADLDESUM  R9ADLDESUM  R10ADLDESUM  R11ADLDESUM   R12ADLDESUM	R13ADLDESUM	 R14ADLDESUM	R15ADLDESUM;
	array ADLSMMIS[15]  R1ADLDEMISS R2ADLDEMISS R3ADLDEMISS R4ADLDEMISS R5ADLDEMISS R6ADLDEMISS R7ADLDEMISS R8ADLDEMISS R9ADLDEMISS R10ADLDEMISS R11ADLDEMISS  R12ADLDEMISS	R13ADLDEMISS R14ADLDEMISS	R15ADLDEMISS;

	array ADLDEY6[15] 	R1ADLDE6 	 R2ADLDE6      R3ADLDE6     R4ADLDE6     R5ADLDE6     R6ADLDE6     R7ADLDE6     R8ADLDE6     R9ADLDE6     R10ADLDE6     R11ADLDE6     R12ADLDE6	    R13ADLDE6	    R14ADLDE6	  R15ADLDE6;
	array ADLSM6[15]  	R1ADLDESUM6  R2ADLDESUM6   R3ADLDESUM6  R4ADLDESUM6  R5ADLDESUM6  R6ADLDESUM6  R7ADLDESUM6  R8ADLDESUM6  R9ADLDESUM6  R10ADLDESUM6  R11ADLDESUM6  R12ADLDESUM6	R13ADLDESUM6	R14ADLDESUM6  R15ADLDESUM6;
	array ADLSMMI6[15]  R1ADLDEMISS6 R2ADLDEMISS6  R3ADLDEMISS6 R4ADLDEMISS6 R5ADLDEMISS6 R6ADLDEMISS6 R7ADLDEMISS6 R8ADLDEMISS6 R9ADLDEMISS6 R10ADLDEMISS6 R11ADLDEMISS6 R12ADLDEMISS6	R13ADLDEMISS6	R14ADLDEMISS6 R15ADLDEMISS6;

	/*Derive dependence variables: if ADLdiff=1 and ADLhelp=(1,2,3,9,.X) then ADLdependence=1
	   							   if ADLdiff=1 and ADLhelp=0 then ADLdependence=0
	   							   if ADLdiff=1 and ADLhelp=. then ADLdependence=.
	   							   if ADLdiff=0 				then ADLdependence=0*/

	/*For wave 1 because we don't have help variables for this wave, we can only know if the participant didn't have ADL dependence by looking at the ADL difficulty variables*/
	do i=1 to 15;
	   if BADIF[i]=1 then do;
			if BAH[i] in (1,2,3,9,.X) then BAD[i]=1; /*1.Yes,occasionally , 2.Yes,some of the time, 3.Yes,most of the time: These 3 categories are only for wave 2A. 9.Don't do, .X.Don't do*/
			else if BAH[i]=0 then BAD[i]=0;
			else BAD[i]=.;
		end;
		else if BADIF[i]=0 then BAD[i]=0;

		if BEDIF[i]=1 then do;
			if BEH[i] in (1,2,3,9,.X) then BED[i]=1;
			else if BEH[i]=0 then BED[i]=0;
			else BED[i]=.;
		end;
		else if BEDIF[i]=0 then BED[i]=0;

		if DRDIF[i]=1 then do;
			if DRH[i] in (1,2,3,9,.X) then DRD[i]=1;
			else if DRH[i]=0 then DRD[i]=0;
			else DRD[i]=.;
		end;
		else if DRDIF[i]=0 then DRD[i]=0;

		if EADIF[i]=1 then do;
			if EAH[i] in (1,2,3,9,.X) then EAD[i]=1;
			else if EAH[i]=0 then EAD[i]=0;
			else EAD[i]=.;
		end;
		else if EADIF[i]=0 then EAD[i]=0;

		if TODIF[i]=1 then do;
			if TOH[i] in (1,2,3,9,.X) then TOD[i]=1;
			else if TOH[i]=0 then TOD[i]=0;
			else TOD[i]=.;
		end;
		else if TODIF[i]=0 then TOD[i]=0;

		if WADIF[i]=1 then do;
			if WAH[i] in (1,2,3,9,.X) then WAD[i]=1;
			else if WAH[i]=0 then WAD[i]=0;
			else WAD[i]=.;
		end;
		else if WADIF[i]=0 then WAD[i]=0;

		if i=1 or (i=2 and HACOHORT=3) then do;
	  	/*This doesn't include the ADL for toilet because it was asked for wave 2A and from wave 3 forward, so the ADLdep in wave 1 and wave 2H is based on 4 ADLs rather than 5 ADLs*/
	  		if BAD[i]=1 or BED[i]=1 or DRD[i]=1 or EAD[i]=1 then ADLDEY[i]=1;
	    	else if BAD[i]=0 and BED[i]=0 and DRD[i]=0 and EAD[i]=0 then ADLDEY[i]=0;

		   if ADLDEY[i]=1 then do; ADLSM[i]=sum(of BAD[i] BED[i] DRD[i] EAD[i]); ADLSMMIS[i]=nmiss(of BAD[i] BED[i] DRD[i] EAD[i]); end;
   		   else if ADLDEY[i]=0 then do; ADLSM[i]=0; ADLSMMIS[i]=0; end;

			/*This any ADL dep variable considers 5 ADLs instead of 4*/
		   if BAD[i]=1 or BED[i]=1 or DRD[i]=1 or EAD[i]=1 or WAD[i]=1 then ADLDEY6[i]=1;
		   else if BAD[i]=0 and BED[i]=0 and DRD[i]=0 and EAD[i]=0 and WAD[i]=0 then ADLDEY6[i]=0;

		   if ADLDEY6[i]=1 then do; ADLSM6[i]=sum(of BAD[i] BED[i] DRD[i] EAD[i] WAD[i]); ADLSMMI6[i]=nmiss(of BAD[i] BED[i] DRD[i] EAD[i] WAD[i]); end;
   		   else if ADLDEY6[i]=0 then do; ADLSM6[i]=0; ADLSMMI6[i]=0; end;

	    end;

	    else if (i=2 and HACOHORT ne 3) or i in (3,4,5,6,7,8,9,10,11,12,13,14,15)  then do;
	   		if BAD[i]=1 or BED[i]=1 or DRD[i]=1 or EAD[i]=1 or TOD[i]=1 then ADLDEY[i]=1;
	   		else if BAD[i]=0 and BED[i]=0 and DRD[i]=0 and EAD[i]=0 and TOD[i]=0 then ADLDEY[i]=0;

		   if ADLDEY[i]=1 then do; ADLSM[i]=sum(of BAD[i] BED[i] DRD[i] EAD[i] TOD[i]); ADLSMMIS[i]=nmiss(of BAD[i] BED[i] DRD[i] EAD[i] TOD[i]); end;
   		   else if ADLDEY[i]=0 then do; ADLSM[i]=0; ADLSMMIS[i]=0; end;

			/*This any ADL dep variable considers 6 ADLs instead of 5*/
			if BAD[i]=1 or BED[i]=1 or DRD[i]=1 or EAD[i]=1 or TOD[i]=1 or WAD[i]=1 then ADLDEY6[i]=1;
	   		else if BAD[i]=0 and BED[i]=0 and DRD[i]=0 and EAD[i]=0 and TOD[i]=0 and WAD[i]=0 then ADLDEY6[i]=0;

		   if ADLDEY6[i]=1 then do; ADLSM6[i]=sum(of BAD[i] BED[i] DRD[i] EAD[i] TOD[i] WAD[i]); ADLSMMI6[i]=nmiss(of BAD[i] BED[i] DRD[i] EAD[i] TOD[i] WAD[i]); end;
   		   else if ADLDEY6[i]=0 then do; ADLSM6[i]=0; ADLSMMI6[i]=0; end;
	   end;

	end; drop i;

 label %VarLabels( VarStart=R , Var=BATHDE, Start=1, NVars=15, Label= 'R Some Dep-Bathing, shower. 0.no, 1.yes' ) ;
 label %VarLabels( VarStart=R , Var=BEDDE, Start=1, NVars=15, Label= 'R Some Dep-Get in/out bed. 0.no, 1.yes' ) ;
 label %VarLabels( VarStart=R , Var=DRESSDE, Start=1, NVars=15, Label= 'R Some Dep-Dressing. 0.no, 1.yes' ) ;
 label %VarLabels( VarStart=R , Var=EATDE, Start=1, NVars=15, Label= 'R Some Dep-Eating. 0.no, 1.yes' ) ;
 label %VarLabels( VarStart=R , Var=TOILTDE, Start=1, NVars=15, Label= 'R Some Dep-Using the toilet. 0.no, 1.yes' ) ;
 label %VarLabels( VarStart=R , Var=WALKRDE, Start=1, NVars=15, Label= 'R Some Dep-Walk across room. 0.no, 1.yes' ) ;

 label %VarLabels( VarStart=R , Var=ADLDE, Start=1, NVars=15, Label= 'Whether any of 5 ADL dep (bath,bed,dress,eat,toil). 0.no, 1.yes' ) ;
 label %VarLabels( VarStart=R , Var=ADLDESUM, Start=1, NVars=15, Label= 'Sum of 5 ADL dep (bath,bed,dress,eat,toil), range:0-5' ) ;
 label %VarLabels( VarStart=R , Var=ADLDEMISS, Start=1, NVars=15, Label= 'Number of ADL dep missing in sum (bath,bed,dress,eat,toil), range:0-5' ) ;
 label %VarLabels( VarStart=R , Var=ADLDE6, Start=1, NVars=15, Label= 'Whether any of 6 ADL dep (bath,bed,dress,eat,toil,walk). 0.no, 1.yes' ) ;
 label %VarLabels( VarStart=R , Var=ADLDESUM6, Start=1, NVars=15, Label= 'Sum of 6 ADL dep (bath,bed,dress,eat,toil,walk), range:0-6' ) ;
 label %VarLabels( VarStart=R , Var=ADLDEMISS6, Start=1, NVars=15, Label= 'Number of ADL dep missing in sum (bath,bed,dress,eat,toil,walk), range:0-6' ) ;

*Relabel W1 variables since they don't include toilet;
 label R1ADLDE="W1 Whether any of 4 ADL dep (bath,bed,dress,eat). 0.no, 1.yes"
       R1ADLDESUM="W1 Sum of 4 ADL dep (bath,bed,dress,eat), range:0-4"
       R1ADLDEMISS="W1 Number of ADL dep missing in sum (bath,bed,dress,eat), range:0-4"
	   R1ADLDE6="W1 Whether any of 5 ADL dep (bath,bed,dress,eat,walk). 0.no, 1.yes"
       R1ADLDESUM6="W1 Sum of 5 ADL dep (bath,bed,dress,eat,walk), range:0-5"
       R1ADLDEMISS6="W1 Number of ADL dep missing in sum (bath,bed,dress,eat,walk), range:0-5";
proc sort; by hhidpn; run; 
/*42406 observations and 446+6(help wave 1)+15*12=632 variables.*/


/*QC*/
proc contents data=randfat3 position; run;
proc means data=randfat3 n nmiss min max mean; var R1ADLDE 	R2ADLDE 	R3ADLDE 	R4ADLDE 	R5ADLDE 	R6ADLDE 	R7ADLDE 	R8ADLDE 	R9ADLDE 	R10ADLDE
                                              R11ADLDE 	R12ADLDE	R13ADLDE	R14ADLDE R15ADLDE; run;
*Compare with previous version of data;
proc means data=olddata.derived_adl_iadl_gdr_20210319 n nmiss min max mean; var R1ADLDE 	R2ADLDE 	R3ADLDE 	R4ADLDE 	R5ADLDE 	R6ADLDE 	R7ADLDE 	R8ADLDE 	R9ADLDE 	R10ADLDE
                                              R11ADLDE 	R12ADLDE	R13ADLDE	R14ADLDE; run;

proc means data=randfat3 n nmiss min max mean; var R1ADLDESUM 	R2ADLDESUM 	R3ADLDESUM 	R4ADLDESUM 	R5ADLDESUM 	R6ADLDESUM 	R7ADLDESUM 	R8ADLDESUM 	R9ADLDESUM 	R10ADLDESUM
                                              R11ADLDESUM 	R12ADLDESUM	R13ADLDESUM	R14ADLDESUM R15ADLDESUM; run;
*Compare with previous version of data;
proc means data=olddata.derived_adl_iadl_gdr_20210319 n nmiss min max mean; var R1ADLDESUM 	R2ADLDESUM 	R3ADLDESUM 	R4ADLDESUM 	R5ADLDESUM 	R6ADLDESUM 	R7ADLDESUM 	R8ADLDESUM 	R9ADLDESUM 	R10ADLDESUM
                                              R11ADLDESUM 	R12ADLDESUM	R13ADLDESUM	R14ADLDESUM; run;

proc means data=randfat3 n nmiss min max; var R1ADLDEMISS 	R2ADLDEMISS 	R3ADLDEMISS 	R4ADLDEMISS 	R5ADLDEMISS 	R6ADLDEMISS 	R7ADLDEMISS 	R8ADLDEMISS 	R9ADLDEMISS 	R10ADLDEMISS
                                              R11ADLDEMISS 	R12ADLDEMISS	R13ADLDEMISS	R14ADLDEMISS R15ADLDEMISS; run;

proc means data=randfat3 n nmiss min max mean; var R1ADLDE6 	R2ADLDE6 	R3ADLDE6 	R4ADLDE6 	R5ADLDE6 	R6ADLDE6 	R7ADLDE6 	R8ADLDE6 	R9ADLDE6 	R10ADLDE6
                                              R11ADLDE6 	R12ADLDE6	R13ADLDE6	R14ADLDE6 R15ADLDE6; run;
*Compare with previous version of data;
proc means data=olddata.derived_adl_iadl_gdr_20210319 n nmiss min max mean; var R1ADLDE6 	R2ADLDE6 	R3ADLDE6 	R4ADLDE6 	R5ADLDE6 	R6ADLDE6 	R7ADLDE6 	R8ADLDE6 	R9ADLDE6 	R10ADLDE6
                                              R11ADLDE6 	R12ADLDE6	R13ADLDE6	R14ADLDE6; run;


proc means data=randfat3 n nmiss min max mean; var R1ADLDESUM6 	R2ADLDESUM6 	R3ADLDESUM6 	R4ADLDESUM6 	R5ADLDESUM6 	R6ADLDESUM6 	R7ADLDESUM6 	R8ADLDESUM6 	R9ADLDESUM6 	R10ADLDESUM6
                                              R11ADLDESUM6 	R12ADLDESUM6	R13ADLDESUM6	R14ADLDESUM6 R15ADLDESUM6; run;
*Compare with previous version of data;
proc means data=olddata.derived_adl_iadl_gdr_20210319 n nmiss min max mean; var R1ADLDESUM6 	R2ADLDESUM6 	R3ADLDESUM6 	R4ADLDESUM6 	R5ADLDESUM6 	R6ADLDESUM6 	R7ADLDESUM6 	R8ADLDESUM6 	R9ADLDESUM6 	R10ADLDESUM6
                                              R11ADLDESUM6 	R12ADLDESUM6	R13ADLDESUM6	R14ADLDESUM6 ; run;


proc means data=randfat3 n nmiss min max; var R1ADLDEMISS6 	R2ADLDEMISS6 	R3ADLDEMISS6 	R4ADLDEMISS6 	R5ADLDEMISS6 	R6ADLDEMISS6 	R7ADLDEMISS6 	R8ADLDEMISS6 	R9ADLDEMISS6 	R10ADLDEMISS6
                                              R11ADLDEMISS6 	R12ADLDEMISS6	R13ADLDEMISS6	R14ADLDEMISS6 R15ADLDEMISS6; run;


proc means data=randfat3 n nmiss min max; var R1BATHDE 	R2BATHDE 	R3BATHDE 	R4BATHDE 	R5BATHDE 	R6BATHDE 	R7BATHDE 	R8BATHDE 	R9BATHDE 	R10BATHDE
                                              R11BATHDE 	R12BATHDE	R13BATHDE	R14BATHDE R15BATHDE; run;
proc means data=randfat3 n nmiss min max; var R1BEDDE 	R2BEDDE 	R3BEDDE 	R4BEDDE 	R5BEDDE 	R6BEDDE 	R7BEDDE 	R8BEDDE 	R9BEDDE 	R10BEDDE
                                              R11BEDDE 	R12BEDDE	R13BEDDE	R14BEDDE R15BEDDE; run;
proc means data=randfat3 n nmiss min max; var R1DRESSDE 	R2DRESSDE 	R3DRESSDE 	R4DRESSDE 	R5DRESSDE 	R6DRESSDE 	R7DRESSDE 	R8DRESSDE 	R9DRESSDE 	R10DRESSDE
                                              R11DRESSDE 	R12DRESSDE	R13DRESSDE	R14DRESSDE R15DRESSDE; run;
proc means data=randfat3 n nmiss min max; var R1EATDE 	R2EATDE 	R3EATDE 	R4EATDE 	R5EATDE 	R6EATDE 	R7EATDE 	R8EATDE 	R9EATDE 	R10EATDE
                                              R11EATDE 	R12EATDE	R13EATDE	R14EATDE R15EATDE; run;
proc means data=randfat3 n nmiss min max; var R1TOILTDE 	R2TOILTDE 	R3TOILTDE 	R4TOILTDE 	R5TOILTDE 	R6TOILTDE 	R7TOILTDE 	R8TOILTDE 	R9TOILTDE 	R10TOILTDE
                                              R11TOILTDE 	R12TOILTDE	R13TOILTDE	R14TOILTDE R15TOILTDE; run;
proc means data=randfat3 n nmiss min max; var R1WALKRDE 	R2WALKRDE 	R3WALKRDE 	R4WALKRDE 	R5WALKRDE 	R6WALKRDE 	R7WALKRDE 	R8WALKRDE 	R9WALKRDE 	R10WALKRDE
                                              R11WALKRDE 	R12WALKRDE	R13WALKRDE	R14WALKRDE R15WALKRDE; run;


*wave1;
proc freq data=randfat3; tables R1BATHDE*R1BEDDE*R1DRESSDE*R1EATDE*R1TOILTDE*R1ADLDE*R1ADLDESUM*R1ADLDEMISS /list missing; run;
proc freq data=randfat3; tables R1BATHDE*R1BEDDE*R1DRESSDE*R1EATDE*R1TOILTDE*R1WALKRDE*R1ADLDE6*R1ADLDESUM6*R1ADLDEMISS6 /list missing; run;

*wave2 and HACOHORT=3;
proc freq data=randfat3; tables R2BATHDE*R2BEDDE*R2DRESSDE*R2EATDE*R2TOILTDE*R2ADLDE*R2ADLDESUM*R2ADLDEMISS /list missing; where HACOHORT=3; run;
proc freq data=randfat3; tables R2BATHDE*R2BEDDE*R2DRESSDE*R2EATDE*R2TOILTDE*R2WALKRDE*R2ADLDE6*R2ADLDESUM6*R2ADLDEMISS6 /list missing; where HACOHORT=3; run;

*wave2 and HACOHORT ne 3;
proc freq data=randfat3; tables R2BATHDE*R2BEDDE*R2DRESSDE*R2EATDE*R2TOILTDE*R2ADLDE*R2ADLDESUM*R2ADLDEMISS /list missing; where HACOHORT ne 3; run;
proc freq data=randfat3; tables R2BATHDE*R2BEDDE*R2DRESSDE*R2EATDE*R2TOILTDE*R2WALKRDE*R2ADLDE6*R2ADLDESUM6*R2ADLDEMISS6 /list missing; where HACOHORT ne 3; run;

*wave>2;
proc freq data=randfat3; tables R15BATHDE*R15BEDDE*R15DRESSDE*R15EATDE*R15TOILTDE*R15ADLDE*R15ADLDESUM*R15ADLDEMISS /list missing; run;
proc freq data=randfat3; tables R15BATHDE*R15BEDDE*R15DRESSDE*R15EATDE*R15TOILTDE*R15WALKRDE*R15ADLDE6*R15ADLDESUM6*R15ADLDEMISS6 /list missing; run;



/*Derive any IADL difficulty, IADLsum, missing in sum IADL*/
/*Note: We start in wave 2 because in wave 1 they didn't ask about any of the activities normally considered IADL: preparing meals, shopping for groceries, using the phone, taking medications, or managing money*/
/*Note: Shopping and preparing meals were not asked in wave 2H*/

data randfat4;
	set randfat3;

	array PHDIF[14]  	R2PHONEA 		R3PHONEA 		R4PHONEA 		R5PHONEA 		R6PHONEA 		R7PHONEA 		R8PHONEA 		R9PHONEA 		R10PHONEA 		R11PHONEA 		R12PHONEA		R13PHONEA		R14PHONEA		R15PHONEA;
	array MODIF[14]  	R2MONEYA 		R3MONEYA 		R4MONEYA 		R5MONEYA 		R6MONEYA 		R7MONEYA 		R8MONEYA 		R9MONEYA 		R10MONEYA 		R11MONEYA 		R12MONEYA		R13MONEYA		R14MONEYA		R15MONEYA;
	array MEDIF[14]  	R2MEDSA  		R3MEDSA  		R4MEDSA  		R5MEDSA  		R6MEDSA  		R7MEDSA  		R8MEDSA  		R9MEDSA  		R10MEDSA 		R11MEDSA 		R12MEDSA		R13MEDSA		R14MEDSA		R15MEDSA;
	array SHDIF[14]  	R2SHOPA  		R3SHOPA  		R4SHOPA  		R5SHOPA  		R6SHOPA  		R7SHOPA  		R8SHOPA  		R9SHOPA  		R10SHOPA 		R11SHOPA 		R12SHOPA		R13SHOPA		R14SHOPA		R15SHOPA;
	array MLDIF[14]  	R2MEALSA 		R3MEALSA 		R4MEALSA 		R5MEALSA 		R6MEALSA 		R7MEALSA 		R8MEALSA 		R9MEALSA 		R10MEALSA 		R11MEALSA 		R12MEALSA		R13MEALSA		R14MEALSA		R15MEALSA;
	array IADLYN[14] 	R2IADLDIF 		R3IADLDIF 		R4IADLDIF 		R5IADLDIF 		R6IADLDIF 		R7IADLDIF 		R8IADLDIF 		R9IADLDIF 		R10IADLDIF 		R11IADLDIF 		R12IADLDIF		R13IADLDIF		R14IADLDIF		R15IADLDIF;
	array IADLSM[14] 	R2IADLDIFSUM 	R3IADLDIFSUM 	R4IADLDIFSUM 	R5IADLDIFSUM 	R6IADLDIFSUM 	R7IADLDIFSUM 	R8IADLDIFSUM 	R9IADLDIFSUM 	R10IADLDIFSUM 	R11IADLDIFSUM 	R12IADLDIFSUM	R13IADLDIFSUM	R14IADLDIFSUM	R15IADLDIFSUM;
	array IADLMIS[14] 	R2IADLDIFMISS 	R3IADLDIFMISS 	R4IADLDIFMISS 	R5IADLDIFMISS 	R6IADLDIFMISS 	R7IADLDIFMISS 	R8IADLDIFMISS 	R9IADLDIFMISS 	R10IADLDIFMISS 	R11IADLDIFMISS 	R12IADLDIFMISS	R13IADLDIFMISS	R14IADLDIFMISS	R15IADLDIFMISS;

	/*Change special  missing value:.Z to zero
	'.Z=Dont do/No if did'*: Respondent doesn't need to take medicines, but if she/he did she wouldn't have any difficulty, so we can safely recode these values as zeroes*/
	do i =1 to 14;
		if MEDIF[i]=.Z then MEDIF[i]=0;

		 /*Change special  missing value:.X 'don't do' to 0.no limitation*/
		if PHDIF[i]=.X then PHDIF[i]=0;
		if MODIF[i]=.X then MODIF[i]=0;
		if MEDIF[i]=.X then MEDIF[i]=0;
		if SHDIF[i]=.X then SHDIF[i]=0;
		if MLDIF[i]=.X then MLDIF[i]=0;

	   	if i=1 and HACOHORT=3  then do; /*i=1: wave 2H*/
		/*The IADL diffs for HRS respondents in wave 2H is based on 3 IADLs: using phone, taking medications, and managing money since shopping and preparing meals were not asked in wave 2H.
		In Wave 2A and from Wave 3 forward, the questions about shopping for groceries and preparing meals are added.
		*/
	     if PHDIF[i]=1 or MODIF[i]=1 or MEDIF[i]=1 then IADLYN[i]=1;
	     else if PHDIF[i]=0 and MODIF[i]=0 and MEDIF[i]=0 then IADLYN[i]=0; 
		 /*In email from Rebecca on 12/18/2015 Re: Question derivation ADL/IADL
		 My clinical perspective is that if the participant says that they don’t do a certain IADL (e.g., an older man whose wife has always cooked for him – lucky guy!)
		 then it doesn’t matter if they would have difficulty if they did do that activity, because they never do that activity. Kind of existential to think about it that way,
		 but clinically it makes sense. So from that perspective, I think that if the IADL data is missing because they “don’t do,” then I would not consider that to be missing.
		 However if the IADL data is missing for other reasons (e.g., question skipped, or other reason), I would use the new coding you propose.*/
		 if IADLYN[i]=1 then do; IADLSM[i]=sum(OF PHDIF[i] MODIF[i] MEDIF[i]); IADLMIS[i]=nmiss(OF PHDIF[i] MODIF[i] MEDIF[i]); end;
		 else if IADLYN[i]=0 then do; IADLSM[i]=0; IADLMIS[i]=0; end;
	   end;

	    else if (i=1 and HACOHORT ne 3) or i in (2,3,4,5,6,7,8,9,10,11,12,13,14) then do; /*for wave 2A and from wave 3 forward there are 5 IADLs*/
	    if PHDIF[i]=1 or MODIF[i]=1 or MEDIF[i]=1 or SHDIF[i]=1 or MLDIF[i]=1 then IADLYN[i]=1;
	    else if PHDIF[i]=0 and MODIF[i]=0 and MEDIF[i]=0 and SHDIF[i]=0 and MLDIF[i]=0 then IADLYN[i]=0;

		if IADLYN[i]=1 then do; IADLSM[i]=sum(OF PHDIF[i] MODIF[i] MEDIF[i] SHDIF[i] MLDIF[i]); IADLMIS[i]=nmiss(OF PHDIF[i] MODIF[i] MEDIF[i] SHDIF[i] MLDIF[i]); end;
		else if IADLYN[i]=0 then do; IADLSM[i]=0; IADLMIS[i]=0; end;
	   end;

	end; drop i;

 label %VarLabels( VarStart=R , Var=IADLDIF, Start=2, NVars=14, Label= 'Whether any of 5 IADL diff (phone,money,meds,shop,meal). 0.no, 1.yes' ) ;
 label %VarLabels( VarStart=R , Var=IADLDIFSUM, Start=2, NVars=14, Label= 'Sum of 5 IADL diff (phone,money,meds,shop,meal), range:0-5' ) ;
 label %VarLabels( VarStart=R , Var=IADLDIFMISS, Start=2, NVars=14, Label= 'Number of IADL diff missing in sum (phone,money,meds,shop,meal), range:0-5' ) ;
proc sort; by hhidpn; run;
/*42406 observations and 632+14*3=674 variables.*/


/*QC*/
proc contents data=randfat4 position; run;
proc means data=randfat4 n nmiss min max mean; var R2IADLDIF 	R3IADLDIF 	R4IADLDIF 	R5IADLDIF 	R6IADLDIF 	R7IADLDIF 	R8IADLDIF 	R9IADLDIF 	R10IADLDIF
                                              R11IADLDIF 	R12IADLDIF	R13IADLDIF	R14IADLDIF R15IADLDIF; run;
*Compare with previous version of data;
proc means data=olddata.derived_adl_iadl_gdr_20210319 n nmiss min max mean; var R2IADLDIF 	R3IADLDIF 	R4IADLDIF 	R5IADLDIF 	R6IADLDIF 	R7IADLDIF 	R8IADLDIF 	R9IADLDIF 	R10IADLDIF
                                              R11IADLDIF 	R12IADLDIF	R13IADLDIF	R14IADLDIF; run;

proc means data=randfat4 n nmiss min max mean; var R2IADLDIFSUM 	R3IADLDIFSUM 	R4IADLDIFSUM 	R5IADLDIFSUM 	R6IADLDIFSUM 	R7IADLDIFSUM 	R8IADLDIFSUM 	R9IADLDIFSUM 	R10IADLDIFSUM
                                              R11IADLDIFSUM 	R12IADLDIFSUM	R13IADLDIFSUM	R14IADLDIFSUM R15IADLDIFSUM; run;
*Compare with previous version of data;
proc means data=olddata.derived_adl_iadl_gdr_20210319 n nmiss min max mean; var R2IADLDIFSUM 	R3IADLDIFSUM 	R4IADLDIFSUM 	R5IADLDIFSUM 	R6IADLDIFSUM 	R7IADLDIFSUM 	R8IADLDIFSUM 	R9IADLDIFSUM 	R10IADLDIFSUM
                                              R11IADLDIFSUM 	R12IADLDIFSUM	R13IADLDIFSUM	R14IADLDIFSUM; run;

proc means data=randfat4 n nmiss min max mean; var R2IADLDIFMISS 	R3IADLDIFMISS 	R4IADLDIFMISS 	R5IADLDIFMISS 	R6IADLDIFMISS 	R7IADLDIFMISS 	R8IADLDIFMISS 	R9IADLDIFMISS 	R10IADLDIFMISS
                                              R11IADLDIFMISS 	R12IADLDIFMISS	R13IADLDIFMISS	R14IADLDIFMISS R15IADLDIFMISS; run;


*wave2 and HACOHORT=3;
proc freq data=randfat4; tables R2PHONEA*R2MONEYA*R2MEDSA*R2MEALSA*R2SHOPA*R2IADLDIF*R2IADLDIFSUM*R2IADLDIFMISS /list missing; where HACOHORT=3; run;

*wave2 and HACOHORT ne 3;
proc freq data=randfat4; tables R2PHONEA*R2MONEYA*R2MEDSA*R2MEALSA*R2SHOPA*R2IADLDIF*R2IADLDIFSUM*R2IADLDIFMISS /list missing; where HACOHORT ne 3; run;

*wave>2;
proc freq data=randfat4; tables R15PHONEA*R15MONEYA*R15MEDSA*R15MEALSA*R15SHOPA*R15IADLDIF*R15IADLDIFSUM*R15IADLDIFMISS /list missing; run;

proc freq data=randfat4; tables RG049 RG061 RG053 RG046 RG043; run;
proc freq data=randfat4; tables E2049 E2096 E2054 E2044 E2039; run;
proc freq data=randfat4; tables D2034 D2102 D2039 D2029 D2024; run;

/*Derive IADL help for five tasks: telephone, money, medicine, shopping, meals, IADL dependence, any IADL dependence, sum IADL dep, missing in sum IADLdep */
data randfat5 (drop=filler);
	set randfat4;

	filler = .;

	/*IADL difficulty*/
	array PHDIF[14]  	R2PHONEA 		R3PHONEA 		R4PHONEA 		R5PHONEA 		R6PHONEA 		R7PHONEA 		R8PHONEA 		R9PHONEA 		R10PHONEA 		R11PHONEA 		R12PHONEA		R13PHONEA		R14PHONEA	R15PHONEA;
	array MODIF[14]  	R2MONEYA 		R3MONEYA 		R4MONEYA 		R5MONEYA 		R6MONEYA 		R7MONEYA 		R8MONEYA 		R9MONEYA 		R10MONEYA 		R11MONEYA 		R12MONEYA		R13MONEYA		R14MONEYA	R15MONEYA;
	array MEDIF[14]  	R2MEDSA  		R3MEDSA  		R4MEDSA  		R5MEDSA  		R6MEDSA  		R7MEDSA  		R8MEDSA  		R9MEDSA  		R10MEDSA 		R11MEDSA 		R12MEDSA		R13MEDSA		R14MEDSA	R15MEDSA;
	array SHDIF[14]  	R2SHOPA  		R3SHOPA  		R4SHOPA  		R5SHOPA  		R6SHOPA  		R7SHOPA  		R8SHOPA  		R9SHOPA  		R10SHOPA 		R11SHOPA 		R12SHOPA		R13SHOPA		R14SHOPA	R15SHOPA;
	array MLDIF[14]  	R2MEALSA 		R3MEALSA 		R4MEALSA 		R5MEALSA 		R6MEALSA 		R7MEALSA 		R8MEALSA 		R9MEALSA 		R10MEALSA 		R11MEALSA 		R12MEALSA		R13MEALSA		R14MEALSA	R15MEALSA;
	array IADLYN[14] 	R2IADLDIF 		R3IADLDIF 		R4IADLDIF 		R5IADLDIF 		R6IADLDIF 		R7IADLDIF 		R8IADLDIF 		R9IADLDIF 		R10IADLDIF 		R11IADLDIF 		R12IADLDIF		R13IADLDIF		R14IADLDIF	R15IADLDIF;

    if HACOHORT=3 then do; phonehelp=E2049; moneyhelp=E2096; medicinehelp=E2054; shophelp=E2044; mealhelp= E2039; end; /*3.Hrs*/
    else if HACOHORT in (0,1) then do; phonehelp=D2034; moneyhelp=D2102; medicinehelp=D2039; shophelp=D2029; mealhelp= D2024; end; /*0.Hrs/Ahead ovrlap, 1.Ahead*/ 

	/*IADL help arrays*/
	array phhelp[14]  filler 	phonehelp 		F2575 		G2873 		HG049 		JG049 		KG049 		LG049 		MG049 		NG049 		OG049	PG049		QG049	RG049;
	array mohelp[14]  filler 	moneyhelp 		F2620 		G2918 		HG061 		JG061 		KG061 		LG061 		MG061 		NG061 		OG061	PG061		QG061	RG061;
	array medhelp[14] filler 	medicinehelp 	F2580 		G2878 		HG053 		JG053 		KG053 		LG053 		MG053 		NG053 		OG053	PG053		QG053	RG053;
	array shhelp[14]  filler 	shophelp 		F2570 		G2868 		HG046 		JG046 		KG046 		LG046 		MG046 		NG046 		OG046	PG046   	QG046	RG046;
	array mlhelp[14]  filler 	mealhelp 		F2565 		G2863 		HG043 		JG043 		KG043 		LG043 		MG043  		NG043 		OG043	PG043		QG043	RG043;

	array phhelp2[14] R2PHONEH  R3PHONEH 		R4PHONEH 	R5PHONEH 	R6PHONEH 	R7PHONEH 	R8PHONEH 	R9PHONEH 	R10PHONEH	R11PHONEH R12PHONEH	R13PHONEH 	R14PHONEH	R15PHONEH;
	array mohelp2[14] R2MONEYH  R3MONEYH 		R4MONEYH 	R5MONEYH 	R6MONEYH 	R7MONEYH 	R8MONEYH 	R9MONEYH 	R10MONEYH 	R11MONEYH R12MONEYH	R13MONEYH 	R14MONEYH	R15MONEYH;
	array medhelp2[14]R2MEDSH   R3MEDSH  		R4MEDSH  	R5MEDSH  	R6MEDSH  	R7MEDSH  	R8MEDSH  	R9MEDSH  	R10MEDSH 	R11MEDSH  R12MEDSH	R13MEDSH  	R14MEDSH	R15MEDSH;
	array shhelp2[14] R2SHOPH  	R3SHOPH  		R4SHOPH  	R5SHOPH  	R6SHOPH  	R7SHOPH  	R8SHOPH  	R9SHOPH  	R10SHOPH 	R11SHOPH  R12SHOPH	R13SHOPH  	R14SHOPH	R15SHOPH;
	array mlhelp2[14] R2MEALSH 	R3MEALSH 		R4MEALSH 	R5MEALSH 	R6MEALSH	R7MEALSH 	R8MEALSH 	R9MEALSH 	R10MEALSH 	R11MEALSH R12MEALSH	R13MEALSH 	R14MEALSH	R15MEALSH;

	do i=1 to 14;
		if i in (1,2,3,4,5,7,8,9,10,11,12,13,14) then do; 
			if phhelp[i]=1 then phhelp2[i]=1; else if phhelp[i]=5 then phhelp2[i]=0; else phhelp2[i]=.;
			if mohelp[i]=1 then mohelp2[i]=1; else if mohelp[i]=5 then mohelp2[i]=0; else mohelp2[i]=.;
			if medhelp[i]=1 then medhelp2[i]=1; else if medhelp[i]=5 then medhelp2[i]=0; else medhelp2[i]=.;
			if shhelp[i]=1 then shhelp2[i]=1; else if shhelp[i]=5 then shhelp2[i]=0; else shhelp2[i]=.;
			if mlhelp[i]=1 then mlhelp2[i]=1; else if mlhelp[i]=5 then mlhelp2[i]=0; else mlhelp2[i]=.;
		end;

		/*Note: From RAND codebook
		"In Wave 7.2004 (i=6), a mistake in the Spanish instrument allowed "6.can’t do" and "7.don’t do" responses for the help questions,
		and a few of these responses are given for all of the IADLs except help with medications and money."
		Rebecca and I decided to recode: "7.don’t do" as '0.no need help' and "6.can’t do" as '1.yes need help'
		*/
		else if i=6 then do;
			if phhelp[i] in (1,6) then phhelp2[i]=1; else if phhelp[i] in (5,7) then phhelp2[i]=0; else phhelp2[i]=.;
			if mohelp[i]=1 then mohelp2[i]=1; else if mohelp[i]=5 then mohelp2[i]=0; else mohelp2[i]=.;
			if medhelp[i]=1 then medhelp2[i]=1; else if medhelp[i]=5 then medhelp2[i]=0; else medhelp2[i]=.;
			if shhelp[i] in (1,6) then shhelp2[i]=1; else if shhelp[i] in (5,7) then shhelp2[i]=0; else shhelp2[i]=.;
			if mlhelp[i] in (1,6) then mlhelp2[i]=1; else if mlhelp[i] in (5,7) then mlhelp2[i]=0; else mlhelp2[i]=.;
		end;
	end;

	/*Create array with Dependence variables computed below*/
	array PHD[14] 		R2PHONEDE 		R3PHONEDE 		R4PHONEDE 		R5PHONEDE 		R6PHONEDE 		R7PHONEDE 		R8PHONEDE 		R9PHONEDE 		R10PHONEDE 		R11PHONEDE  	R12PHONEDE		R13PHONEDE		R14PHONEDE		R15PHONEDE;
	array MOD[14] 		R2MONEYDE 		R3MONEYDE 		R4MONEYDE 		R5MONEYDE 		R6MONEYDE 		R7MONEYDE 		R8MONEYDE 		R9MONEYDE 		R10MONEYDE 		R11MONEYDE  	R12MONEYDE		R13MONEYDE		R14MONEYDE		R15MONEYDE;
	array MED[14] 		R2MEDSDE 		R3MEDSDE  		R4MEDSDE  		R5MEDSDE  		R6MEDSDE  		R7MEDSDE  		R8MEDSDE  		R9MEDSDE  		R10MEDSDE  		R11MEDSDE   	R12MEDSDE		R13MEDSDE		R14MEDSDE		R15MEDSDE;
	array SHD[14] 		R2SHOPDE  		R3SHOPDE  		R4SHOPDE  		R5SHOPDE  		R6SHOPDE  		R7SHOPDE  		R8SHOPDE  		R9SHOPDE  		R10SHOPDE  		R11SHOPDE   	R12SHOPDE		R13SHOPDE		R14SHOPDE		R15SHOPDE;
	array MLD[14] 		R2MEALSDE 		R3MEALSDE 		R4MEALSDE 		R5MEALSDE 		R6MEALSDE 		R7MEALSDE 		R8MEALSDE 		R9MEALSDE 		R10MEALSDE 		R11MEALSDE  	R12MEALSDE		R13MEALSDE		R14MEALSDE		R15MEALSDE;
	array IADLDE[14] 	R2IADLDE  		R3IADLDE  		R4IADLDE  		R5IADLDE  		R6IADLDE  		R7IADLDE  		R8IADLDE  		R9IADLDE  		R10IADLDE  		R11IADLDE   	R12IADLDE		R13IADLDE		R14IADLDE		R15IADLDE;
	array IADLSM[14] 	R2IADLDESUM 	R3IADLDESUM 	R4IADLDESUM 	R5IADLDESUM 	R6IADLDESUM 	R7IADLDESUM 	R8IADLDESUM 	R9IADLDESUM 	R10IADLDESUM 	R11IADLDESUM 	R12IADLDESUM	R13IADLDESUM	R14IADLDESUM	R15IADLDESUM;
	array IADLMIS[14] 	R2IADLDEMISS 	R3IADLDEMISS 	R4IADLDEMISS 	R5IADLDEMISS 	R6IADLDEMISS 	R7IADLDEMISS 	R8IADLDEMISS 	R9IADLDEMISS 	R10IADLDEMISS 	R11IADLDEMISS 	R12IADLDEMISS	R13IADLDEMISS	R14IADLDEMISS	R15IADLDEMISS;

	do i=1 to 14;
		if PHDIF[i]=1 then do;
			if phhelp2[i]=1 then PHD[i]=1;
			else if phhelp2[i]=0 then PHD[i]=0;
			else if phhelp2[i]=. then PHD[i]=.;
		end;
		else if PHDIF[i] in (0,.X) then PHD[i]=0; /*if the IADL data is missing because they “X.don’t do” then IADLdiff=0: see Rebecca's comment above*/ 

		if MODIF[i]=1 then do;
			if mohelp2[i]=1 then MOD[i]=1;
			else if mohelp2[i]=0 then MOD[i]=0;
			else if mohelp2[i]=. then MOD[i]=.;
		end;
		else if MODIF[i] in (0,.X) then MOD[i]=0;

		if MEDIF[i]=1 then do;
			if medhelp2[i]=1 then MED[i]=1;
			else if medhelp2[i]=0 then MED[i]=0;
			else if medhelp2[i]=. then MED[i]=.;
		end;
		else if MEDIF[i] in (0,.X) then MED[i]=0;

		if SHDIF[i]=1 then do;
			if shhelp2[i]=1 then SHD[i]=1;
			else if shhelp2[i]=0 then SHD[i]=0;
			else if shhelp2[i]=. then SHD[i]=.;
		end;
		else if SHDIF[i] in (0,.X) then SHD[i]=0;
	
		if MLDIF[i]=1 then do;
			if mlhelp2[i]=1 then MLD[i]=1;
			else if mlhelp2[i]=0 then MLD[i]=0;
			else if mlhelp2[i]=. then MLD[i]=.;
		end;
		else if MLDIF[i] in (0,.X) then MLD[i]=0;

	  if i=1 and HACOHORT=3  then do; /*i=1: wave 2H*/
	/*The IADL diffs for HRS respondents in wave 2 is based on 3 IADLs: using phone, taking medications, and managing money since shopping and preparing meals were not asked in wave 2H*/
	/*In wave 1 and 2, there are no IADL help variables, so we cannot tell whether Dependence=1*/
	     if PHD[i]=0 and MOD[i]=0 and MED[i]=0 then IADLDE[i]=0; /*This will be true when IADLs diff=0, we do have 3 IADLs for wave 2H*/
		 if IADLDE[i]=0 then do; IADLSM[i]=0; IADLMIS[i]=0; end;
	  end;

   	  else if (i=1 and HACOHORT ne 3) or i in (2,3,4,5,6,7,8,9,10,11,12,13,14) then do; /*from wave 2A and 3 forward there are 5 IADLs*/
	    if PHD[i]=1 or MOD[i]=1 or MED[i]=1 or SHD[i]=1 or MLD[i]=1 then IADLDE[i]=1; /* In wave 2A, there are no IADL help variables, so we cannot tell whether Dependence=1*/
	    else if PHD[i]=0 and MOD[i]=0 and MED[i]=0 and SHD[i]=0 and MLD[i]=0 then IADLDE[i]=0;

		if IADLDE[i]=1 then do; IADLSM[i]=sum(of PHD[i] MOD[i] MED[i] SHD[i] MLD[i]); IADLMIS[i]=nmiss(of PHD[i] MOD[i] MED[i] SHD[i] MLD[i]); end;
   		else if IADLDE[i]=0 then do; IADLSM[i]=0; IADLMIS[i]=0; end;

   	  end;

	end; drop i;

 label %VarLabels( VarStart=R , Var=IADLDE, Start=2, NVars=14, Label= 'Whether any of 5 IADL dep (phone,money,meds,shop,meal). 0.no, 1.yes' ) ;
 label %VarLabels( VarStart=R , Var=IADLDESUM, Start=2, NVars=14, Label= 'Sum of 5 IADL dep (phone,money,meds,shop,meal), range:0-5' ) ;
  label %VarLabels( VarStart=R , Var=IADLDEMISS, Start=2, NVars=14, Label= 'Number of IADL dep missing in sum (phone,money,meds,shop,meal), range:0-5' ) ;

 label %VarLabels( VarStart=R , Var=PHONEDE, Start=2, NVars=14, Label= 'R Some Dep-Use telephone. 0.no, 1.yes' ) ;
 label %VarLabels( VarStart=R , Var=MONEYDE, Start=2, NVars=14, Label= 'R Some Dep-Managing money. 0.no, 1.yes' ) ;
 label %VarLabels( VarStart=R , Var=MEDSDE, Start=2, NVars=14, Label= 'R Some Dep-Take medications. 0.no, 1.yes' ) ;
 label %VarLabels( VarStart=R , Var=SHOPDE, Start=2, NVars=14, Label= 'R Some Dep-Shop for grocery. 0.no, 1.yes' ) ;
 label %VarLabels( VarStart=R , Var=MEALSDE, Start=2, NVars=14, Label= 'R Some Dep-Prepare hot meal. 0.no, 1.yes' ) ;

 label %VarLabels( VarStart=R , Var=PHONEH, Start=2, NVars=14, Label= 'R Gets Help-Use telephone. 0.no, 1.yes' ) ;
 label %VarLabels( VarStart=R , Var=MONEYH, Start=2, NVars=14, Label= 'R Gets Help-Managing money. 0.no, 1.yes' ) ;
 label %VarLabels( VarStart=R , Var=MEDSH, Start=2, NVars=14, Label= 'R Gets Help-Take medications. 0.no, 1.yes' ) ;
 label %VarLabels( VarStart=R , Var=SHOPH, Start=2, NVars=14, Label= 'R Gets Help-Shop for grocery. 0.no, 1.yes' ) ;
 label %VarLabels( VarStart=R , Var=MEALSH, Start=2, NVars=14, Label= 'R Gets Help-Prepare hot meal. 0.no, 1.yes' ) ;
proc sort; by hhidpn; run;
/*42406 observations and 674+5(phonehelp, moneyhelp, etc)+14*13=861 variables.*/


/*QC*/
proc contents data=randfat5 position; run;
proc means data=randfat5 n nmiss min max mean; var R2IADLDE 	R3IADLDE 	R4IADLDE 	R5IADLDE 	R6IADLDE 	R7IADLDE 	R8IADLDE 	R9IADLDE 	R10IADLDE
                                              R11IADLDE 	R12IADLDE	R13IADLDE	R14IADLDE R15IADLDE; run;
*Compare with previous version of data;
proc means data=olddata.derived_adl_iadl_gdr_20210319 n nmiss min max mean; var R2IADLDE 	R3IADLDE 	R4IADLDE 	R5IADLDE 	R6IADLDE 	R7IADLDE 	R8IADLDE 	R9IADLDE 	R10IADLDE
                                              R11IADLDE 	R12IADLDE	R13IADLDE	R14IADLDE; run;

proc means data=randfat5 n nmiss min max mean; var R2IADLDESUM 	R3IADLDESUM 	R4IADLDESUM 	R5IADLDESUM 	R6IADLDESUM 	R7IADLDESUM 	R8IADLDESUM 	R9IADLDESUM 	R10IADLDESUM
                                              R11IADLDESUM 	R12IADLDESUM	R13IADLDESUM	R14IADLDESUM R15IADLDESUM; run;
*Compare with previous version of data;
proc means data=olddata.derived_adl_iadl_gdr_20210319 n nmiss min max mean; var R2IADLDESUM 	R3IADLDESUM 	R4IADLDESUM 	R5IADLDESUM 	R6IADLDESUM 	R7IADLDESUM 	R8IADLDESUM 	R9IADLDESUM 	R10IADLDESUM
                                              R11IADLDESUM 	R12IADLDESUM	R13IADLDESUM	R14IADLDESUM; run;

proc means data=randfat5 n nmiss min max mean; var R2IADLDEMISS 	R3IADLDEMISS 	R4IADLDEMISS 	R5IADLDEMISS 	R6IADLDEMISS 	R7IADLDEMISS 	R8IADLDEMISS 	R9IADLDEMISS 	R10IADLDEMISS
                                              R11IADLDEMISS 	R12IADLDEMISS	R13IADLDEMISS	R14IADLDEMISS R15IADLDEMISS; run;


proc means data=randfat5 n nmiss min max; var R2PHONEDE 	R3PHONEDE 	R4PHONEDE 	R5PHONEDE 	R6PHONEDE 	R7PHONEDE 	R8PHONEDE 	R9PHONEDE 	R10PHONEDE
                                              R11PHONEDE 	R12PHONEDE	R13PHONEDE	R14PHONEDE R15PHONEDE; run;
proc means data=randfat5 n nmiss min max; var R2MONEYDE 	R3MONEYDE 	R4MONEYDE 	R5MONEYDE 	R6MONEYDE 	R7MONEYDE 	R8MONEYDE 	R9MONEYDE 	R10MONEYDE
                                              R11MONEYDE 	R12MONEYDE	R13MONEYDE	R14MONEYDE R15MONEYDE; run;
proc means data=randfat5 n nmiss min max; var R2MEDSDE 	R3MEDSDE 	R4MEDSDE 	R5MEDSDE 	R6MEDSDE 	R7MEDSDE 	R8MEDSDE 	R9MEDSDE 	R10MEDSDE
                                              R11MEDSDE 	R12MEDSDE	R13MEDSDE	R14MEDSDE R15MEDSDE; run;
proc means data=randfat5 n nmiss min max; var R2SHOPDE 	R3SHOPDE 	R4SHOPDE 	R5SHOPDE 	R6SHOPDE 	R7SHOPDE 	R8SHOPDE 	R9SHOPDE 	R10SHOPDE
                                              R11SHOPDE 	R12SHOPDE	R13SHOPDE	R14SHOPDE R15SHOPDE; run;
proc means data=randfat5 n nmiss min max; var R2MEALSDE 	R3MEALSDE 	R4MEALSDE 	R5MEALSDE 	R6MEALSDE 	R7MEALSDE 	R8MEALSDE 	R9MEALSDE 	R10MEALSDE
                                              R11MEALSDE 	R12MEALSDE	R13MEALSDE	R14MEALSDE R15MEALSDE; run;

proc means data=randfat5 n nmiss min max; var R2PHONEH 	R3PHONEH 	R4PHONEH 	R5PHONEH 	R6PHONEH 	R7PHONEH 	R8PHONEH 	R9PHONEH 	R10PHONEH
                                              R11PHONEH 	R12PHONEH	R13PHONEH	R14PHONEH R15PHONEH; run;
proc means data=randfat5 n nmiss min max; var R2MONEYH 	R3MONEYH 	R4MONEYH 	R5MONEYH 	R6MONEYH 	R7MONEYH 	R8MONEYH 	R9MONEYH 	R10MONEYH
                                              R11MONEYH 	R12MONEYH	R13MONEYH	R14MONEYH R15MONEYH; run;
proc means data=randfat5 n nmiss min max; var R2MEDSH 	R3MEDSH 	R4MEDSH 	R5MEDSH 	R6MEDSH 	R7MEDSH 	R8MEDSH 	R9MEDSH 	R10MEDSH
                                              R11MEDSH 	R12MEDSH	R13MEDSH	R14MEDSH R15MEDSH; run;
proc means data=randfat5 n nmiss min max; var R2SHOPH 	R3SHOPH 	R4SHOPH 	R5SHOPH 	R6SHOPH 	R7SHOPH 	R8SHOPH 	R9SHOPH 	R10SHOPH
                                              R11SHOPH 	R12SHOPH	R13SHOPH	R14SHOPH R15SHOPH; run;
proc means data=randfat5 n nmiss min max; var R2MEALSH 	R3MEALSH 	R4MEALSH 	R5MEALSH 	R6MEALSH 	R7MEALSH 	R8MEALSH 	R9MEALSH 	R10MEALSH
                                              R11MEALSH 	R12MEALSH	R13MEALSH	R14MEALSH R15MEALSH; run;



*wave2 and HACOHORT=3;
proc freq data=randfat5; tables R2PHONEDE*R2MONEYDE*R2MEDSDE*R2SHOPDE*R2MEALSDE*R2IADLDE*R2IADLDESUM*R2IADLDEMISS /list missing; where HACOHORT=3; run;

*wave2 and HACOHORT ne 3;
proc freq data=randfat5; tables R2PHONEDE*R2MONEYDE*R2MEDSDE*R2SHOPDE*R2MEALSDE*R2IADLDE*R2IADLDESUM*R2IADLDEMISS /list missing; where HACOHORT ne 3; run;

*wave>2;
proc freq data=randfat5; tables R15PHONEDE*R15MONEYDE*R15MEDSDE*R15SHOPDE*R15MEALSDE*R15IADLDE*R15IADLDESUM*R15IADLDEMISS /list missing; run;



/*Derive any ADLs dep exit (5 and 6 ADLs),  sum ADLdep (5 and 6 ADLs), missing in sum ADLdep (5 and 6 ADLs), maximum time help (5 and 6 ADLs), 
         any IADLs dep exit, sum IADLdep (5 IADLs), missing in sum IADLdep (5 IADLs) maximum time help (5 IADLs)
*/
data randfat6 (drop=i);
 set randfat5;

 array adl [6] REWALKRH REDRESSH REBATHH REEATH REBEDH RETOILTH;
 do i=1 to 6;
  if adl[i] in (2,9) then adl[i]=1; /*2.Couldn't do , 9.Didn't do*/
 end;

 /*5 ADLs*/
 if REDRESSH=1 or REBATHH=1 or REEATH=1 or REBEDH=1 or RETOILTH=1 then READLDE=1;
 else if REDRESSH=0 and REBATHH=0 and REEATH=0 and REBEDH=0 and RETOILTH=0 then READLDE=0;

 if READLDE=1 then do; READLDESUM=sum(of REDRESSH REBATHH REEATH REBEDH RETOILTH); READLDEMISS=nmiss(of REDRESSH REBATHH REEATH REBEDH RETOILTH); end; 
 else if READLDE=0 then do; READLDESUM=0; READLDEMISS=0; end;

 if READLDE=1 then timehelpmaxADL=max(REDRESST,REBATHT, REEATT, REBEDT,RETOILTT); 

  /*6 ADLs*/
 if REDRESSH=1 or REBATHH=1 or REEATH=1 or REBEDH=1 or RETOILTH=1 or REWALKRH=1 then READLDE6=1;
 else if REDRESSH=0 and REBATHH=0 and REEATH=0 and REBEDH=0 and RETOILTH=0 and REWALKRH=0 then READLDE6=0;

 if READLDE6=1 then do; READLDESUM6=sum(of REDRESSH REBATHH REEATH REBEDH RETOILTH REWALKRH); READLDEMISS6=nmiss(of REDRESSH REBATHH REEATH REBEDH RETOILTH REWALKRH); end;
 else if READLDE6=0 then do; READLDESUM6=0; READLDEMISS6=0; end;

 if READLDE6=1 then timehelpmaxADL6=max(REDRESST,REBATHT, REEATT, REBEDT,RETOILTT,REWALKRT); 

 array iadl [5] REMEALSH RESHOPH REPHONEH REMEDSH REMONEYH;
 do i=1 to 5;
  if iadl[i]=9 then iadl[i]=0; /*9.Didn't do*/
  else if iadl[i]=2 then iadl[i]=1; /*2.Couldn't do*/
 end;

 if REMEALSH=1 or RESHOPH=1 or REPHONEH=1 or REMEDSH=1 or REMONEYH=1 then REIADLDE=1;
 else if REMEALSH=0 and RESHOPH=0 and REPHONEH=0 and REMEDSH=0 and REMONEYH=0 then REIADLDE=0;

 if REIADLDE=1 then do; REIADLDESUM=sum(of REMEALSH RESHOPH REPHONEH REMEDSH REMONEYH); REIADLDEMISS=nmiss(of REMEALSH RESHOPH REPHONEH REMEDSH REMONEYH); end;
 else if REIADLDE=0 then do; REIADLDESUM=0; REIADLDEMISS=0; end;

 if REIADLDE=1 then timehelpmaxIADL=max(REMEALST, RESHOPT, REPHONET, REMEDST);

 label READLDE="Exit Whether any of 5 ADL dep (bath,bed,dress,eat,toil). 0.no, 1.yes"
       READLDESUM="Exit Sum of 5 ADL dep (bath,bed,dress,eat,toil), range:0-5"
       READLDEMISS="Exit Number of ADL dep missing in sum (bath,bed,dress,eat,toil), range:0-5"

       READLDE6="Exit Whether any of 6 ADL dep (bath,bed,dress,eat,toil,walk). 0.no, 1.yes"
       READLDESUM6="Exit Sum of 6 ADL dep (bath,bed,dress,eat,toil.walk), range:0-6"
       READLDEMISS6="Exit Number of ADL dep missing in sum (bath,bed,dress,eat,toil.walk), range:0-6"

	   REIADLDE="Exit Whether any of 5 IADL dep (phone,money,meds,shop,meal). 0.no, 1.yes"
       REIADLDESUM="Exit Sum of 5 IADL dep (phone,money,meds,shop,meal), range:0-5"
       REIADLDEMISS="Exit Number of IADL dep missing in sum phone,money,meds,shop,meal), range:0-5"

	   timehelpmaxADL="Maximum Time(months) R got help with any 5 ADL (bath,bed,dress,eat,toil) in exit iw"
	   timehelpmaxADL6="Maximum Time(months) R got help with any 6 ADL (bath,bed,dress,eat,toil,walk) in exit iw"
	   timehelpmaxIADL="Maximum Time(months) R got help with any 4 IADL (meal,shop,phone,meds) in exit iw";
proc sort; by hhidpn; run;
/*42406 observations and 861+12=873 variables.*/

/*QC*/
proc contents data=randfat6 position; run;
proc means data=randfat6 n nmiss min max; var READLDE READLDESUM READLDEMISS READLDE6 READLDESUM6 READLDEMISS6 REIADLDE REIADLDESUM REIADLDEMISS timehelpmaxADL timehelpmaxADL6 timehelpmaxIADL; run;
*Note:  timehelpmaxIADL can have a negative value, since RAND variables:  REMEALST, RESHOPT, REPHONET, and REMEDST can have negative values;

proc freq data=randfat6; tables READLDE*REDRESSH*REBATHH*REEATH*REBEDH*RETOILTH /list missing; run;
proc freq data=randfat6; tables READLDESUM*REDRESSH*REBATHH*REEATH*REBEDH*RETOILTH*READLDEMISS /list missing ; run;

proc freq data=randfat6; tables READLDE6*REDRESSH*REBATHH*REEATH*REBEDH*RETOILTH*REWALKRH /list missing; run;
proc freq data=randfat6; tables READLDESUM6*REDRESSH*REBATHH*REEATH*REBEDH*RETOILTH*REWALKRH*READLDEMISS6  /list missing ; run;

proc freq data=randfat6; tables REIADLDE*REMEALSH*RESHOPH*REPHONEH*REMEDSH*REMONEYH /list missing; run;
proc freq data=randfat6; tables REIADLDESUM*REMEALSH*RESHOPH*REPHONEH*REMEDSH*REMONEYH*REIADLDEMISS /list missing; run;

proc freq data=randfat6; tables timehelpmaxADL*REDRESST*REBATHT*REEATT*REBEDT*RETOILTT /list; run;
proc freq data=randfat6; tables timehelpmaxADL6*REDRESST*REBATHT*REEATT*REBEDT*RETOILTT*REWALKRT /list; run;
proc freq data=randfat6; tables timehelpmaxIADL*REMEALST*RESHOPT*REPHONET*REMEDST / list; run;

proc freq data=randfat6; tables timehelpmaxIADL*REMEALST*RESHOPT*REPHONET*REMEDST / list missing; where REIADLDE=1; run;
proc print data=randfat6 (obs=10); var hhidpn timehelpmaxIADL REMEALST RESHOPT REPHONET REMEDST ; where timehelpmaxIADL ne . and timehelpmaxIADL<0 and REIADLDE=1; run;

/*QC IADL*/
proc freq data=randfat6; tables R2IADLDE R3IADLDE R4IADLDE R5IADLDE R6IADLDE R7IADLDE R8IADLDE R9IADLDE R10IADLDE R11IADLDE R12IADLDE R13IADLDE R14IADLDE R15IADLDE /missing; run;
/* Note:
% of IADLDE similar across waves except for wave 2 where R2IADLDE=0:
-IADL help variables not present in waves 1 and 2. So:
	-We can only know if the participant didn't have IADL dependence by looking at the IADL difficulty variables
*/ 

proc freq data=randfat6; tables HACOHORT*R2IADLDE*R2IADLDIF*R2PHONEDE*R2MONEYDE*R2MEDSDE*R2SHOPDE*R2MEALSDE /list missing; run; 
/* Note:
a lot of missing because even when they had R2IADLDIF=1, they have missing answers for individual IADL Dep variables.
That is, in order to have R2IADLDE=0, you need to have all 5 individual IADL Dep variables with non missing values, and 
in order to have R2IADLDE=1 you need to have at least 1 individual IADL Dep variable=1 
*/



/*Create permanent dataset*/

data savedata.derived_adl_iadl_gdr_20230510;
 set randfat6 (keep=hhidpn 
                          R1ADLDIF 	R2ADLDIF R3ADLDIF R4ADLDIF R5ADLDIF R6ADLDIF R7ADLDIF R8ADLDIF 	R9ADLDIF R10ADLDIF 	R11ADLDIF R12ADLDIF	R13ADLDIF R14ADLDIF R15ADLDIF
						  R1ADLDIFSUM R2ADLDIFSUM R3ADLDIFSUM R4ADLDIFSUM R5ADLDIFSUM R6ADLDIFSUM R7ADLDIFSUM R8ADLDIFSUM R9ADLDIFSUM R10ADLDIFSUM R11ADLDIFSUM R12ADLDIFSUM R13ADLDIFSUM R14ADLDIFSUM R15ADLDIFSUM
						  R1ADLDIFMISS R2ADLDIFMISS R3ADLDIFMISS R4ADLDIFMISS R5ADLDIFMISS R6ADLDIFMISS R7ADLDIFMISS R8ADLDIFMISS R9ADLDIFMISS R10ADLDIFMISS R11ADLDIFMISS R12ADLDIFMISS R13ADLDIFMISS R14ADLDIFMISS R15ADLDIFMISS
						  R1ADLDIF6   R2ADLDIF6	R3ADLDIF6 R4ADLDIF6 R5ADLDIF6 R6ADLDIF6 R7ADLDIF6 R8ADLDIF6 R9ADLDIF6 R10ADLDIF6 R11ADLDIF6 R12ADLDIF6 R13ADLDIF6 R14ADLDIF6 R15ADLDIF6
						  R1ADLDIFSUM6 	R2ADLDIFSUM6 R3ADLDIFSUM6 R4ADLDIFSUM6 	R5ADLDIFSUM6 R6ADLDIFSUM6 R7ADLDIFSUM6 	R8ADLDIFSUM6 R9ADLDIFSUM6 R10ADLDIFSUM6 R11ADLDIFSUM6 R12ADLDIFSUM6	R13ADLDIFSUM6 R14ADLDIFSUM6 R15ADLDIFSUM6
						  R1ADLDIFMISS6 	R2ADLDIFMISS6 R3ADLDIFMISS6 R4ADLDIFMISS6 	R5ADLDIFMISS6 R6ADLDIFMISS6 R7ADLDIFMISS6 	R8ADLDIFMISS6 R9ADLDIFMISS6 R10ADLDIFMISS6 R11ADLDIFMISS6 R12ADLDIFMISS6	R13ADLDIFMISS6 R14ADLDIFMISS6 R15ADLDIFMISS6
						  R1ADLDE  R2ADLDE R3ADLDE R4ADLDE R5ADLDE R6ADLDE R7ADLDE  R8ADLDE R9ADLDE R10ADLDE R11ADLDE R12ADLDE R13ADLDE R14ADLDE R15ADLDE
						  R1ADLDESUM R2ADLDESUM  R3ADLDESUM R4ADLDESUM R5ADLDESUM R6ADLDESUM R7ADLDESUM R8ADLDESUM R9ADLDESUM R10ADLDESUM R11ADLDESUM R12ADLDESUM R13ADLDESUM R14ADLDESUM R15ADLDESUM
						  R1ADLDEMISS R2ADLDEMISS  R3ADLDEMISS R4ADLDEMISS R5ADLDEMISS R6ADLDEMISS R7ADLDEMISS R8ADLDEMISS R9ADLDEMISS R10ADLDEMISS R11ADLDEMISS R12ADLDEMISS R13ADLDEMISS R14ADLDEMISS R15ADLDEMISS
						  R1ADLDE6 R2ADLDE6 R3ADLDE6 R4ADLDE6 R5ADLDE6 R6ADLDE6 R7ADLDE6 R8ADLDE6 R9ADLDE6 R10ADLDE6 R11ADLDE6 R12ADLDE6	R13ADLDE6 R14ADLDE6 R15ADLDE6
						  R1ADLDESUM6 R2ADLDESUM6  R3ADLDESUM6 R4ADLDESUM6 R5ADLDESUM6 R6ADLDESUM6 R7ADLDESUM6 R8ADLDESUM6 R9ADLDESUM6 R10ADLDESUM6 R11ADLDESUM6  R12ADLDESUM6	R13ADLDESUM6 R14ADLDESUM6 R15ADLDESUM6
						  R1ADLDEMISS6 R2ADLDEMISS6  R3ADLDEMISS6 R4ADLDEMISS6 R5ADLDEMISS6 R6ADLDEMISS6 R7ADLDEMISS6 R8ADLDEMISS6 R9ADLDEMISS6 R10ADLDEMISS6 R11ADLDEMISS6  R12ADLDEMISS6	R13ADLDEMISS6 R14ADLDEMISS6 R15ADLDEMISS6
						  R1BATHDE   R2BATHDE  R3BATHDE  R4BATHDE  R5BATHDE  R6BATHDE  R7BATHDE  R8BATHDE  R9BATHDE  R10BATHDE  R11BATHDE R12BATHDE	R13BATHDE R14BATHDE R15BATHDE
						  R1BEDDE    R2BEDDE   R3BEDDE   R4BEDDE   R5BEDDE   R6BEDDE   R7BEDDE   R8BEDDE   R9BEDDE   R10BEDDE   R11BEDDE	R12BEDDE R13BEDDE R14BEDDE R15BEDDE
						  R1DRESSDE  R2DRESSDE R3DRESSDE R4DRESSDE R5DRESSDE R6DRESSDE R7DRESSDE R8DRESSDE R9DRESSDE R10DRESSDE R11DRESSDE	R12DRESSDE R13DRESSDE R14DRESSDE R15DRESSDE
						  R1EATDE    R2EATDE   R3EATDE   R4EATDE   R5EATDE   R6EATDE   R7EATDE   R8EATDE   R9EATDE   R10EATDE   R11EATDE	R12EATDE   R13EATDE	R14EATDE R15EATDE
						  R1TOILTDE  R2TOILTDE R3TOILTDE R4TOILTDE R5TOILTDE R6TOILTDE R7TOILTDE R8TOILTDE R9TOILTDE R10TOILTDE R11TOILTDE	R12TOILTDE	R13TOILTDE	R14TOILTDE R15TOILTDE
						  R1WALKRDE  R2WALKRDE R3WALKRDE R4WALKRDE R5WALKRDE R6WALKRDE R7WALKRDE R8WALKRDE R9WALKRDE R10WALKRDE R11WALKRDE	R12WALKRDE	R13WALKRDE	R14WALKRDE R15WALKRDE
						  			 R2IADLDIF  R3IADLDIF R4IADLDIF R5IADLDIF R6IADLDIF R7IADLDIF R8IADLDIF R9IADLDIF R10IADLDIF R11IADLDIF R12IADLDIF R13IADLDIF	R14IADLDIF R15IADLDIF
									 R2IADLDIFSUM 	R3IADLDIFSUM 	R4IADLDIFSUM 	R5IADLDIFSUM 	R6IADLDIFSUM 	R7IADLDIFSUM 	R8IADLDIFSUM 	R9IADLDIFSUM 	R10IADLDIFSUM 	R11IADLDIFSUM 	R12IADLDIFSUM	R13IADLDIFSUM	R14IADLDIFSUM R15IADLDIFSUM
									 R2IADLDIFMISS 	R3IADLDIFMISS 	R4IADLDIFMISS 	R5IADLDIFMISS 	R6IADLDIFMISS 	R7IADLDIFMISS 	R8IADLDIFMISS 	R9IADLDIFMISS 	R10IADLDIFMISS 	R11IADLDIFMISS 	R12IADLDIFMISS	R13IADLDIFMISS	R14IADLDIFMISS R15IADLDIFMISS
									 R2PHONEH  R3PHONEH R4PHONEH 	R5PHONEH 	R6PHONEH 	R7PHONEH 	R8PHONEH 	R9PHONEH 	R10PHONEH	R11PHONEH R12PHONEH	R13PHONEH R14PHONEH R15PHONEH
									 R2MONEYH  R3MONEYH R4MONEYH 	R5MONEYH 	R6MONEYH 	R7MONEYH 	R8MONEYH 	R9MONEYH 	R10MONEYH 	R11MONEYH R12MONEYH	R13MONEYH R14MONEYH R15MONEYH
									 R2MEDSH   R3MEDSH  R4MEDSH  	R5MEDSH  	R6MEDSH  	R7MEDSH  	R8MEDSH  	R9MEDSH  	R10MEDSH 	R11MEDSH  R12MEDSH	R13MEDSH  R14MEDSH R15MEDSH
									 R2SHOPH  R3SHOPH  	R4SHOPH  	R5SHOPH  	R6SHOPH  	R7SHOPH  	R8SHOPH  	R9SHOPH  	R10SHOPH 	R11SHOPH  R12SHOPH	R13SHOPH  R14SHOPH R15SHOPH
									R2MEALSH R3MEALSH 	R4MEALSH 	R5MEALSH 	R6MEALSH	R7MEALSH 	R8MEALSH 	R9MEALSH 	R10MEALSH 	R11MEALSH R12MEALSH	R13MEALSH R14MEALSH R15MEALSH
									R2PHONEDE 		R3PHONEDE 		R4PHONEDE 		R5PHONEDE 		R6PHONEDE 		R7PHONEDE 		R8PHONEDE 		R9PHONEDE 		R10PHONEDE 		R11PHONEDE  	R12PHONEDE		R13PHONEDE		R14PHONEDE 		R15PHONEDE
									R2MONEYDE 		R3MONEYDE 		R4MONEYDE 		R5MONEYDE 		R6MONEYDE 		R7MONEYDE 		R8MONEYDE 		R9MONEYDE 		R10MONEYDE 		R11MONEYDE  	R12MONEYDE		R13MONEYDE		R14MONEYDE 		R15MONEYDE
									R2MEDSDE 		R3MEDSDE  		R4MEDSDE  		R5MEDSDE  		R6MEDSDE  		R7MEDSDE  		R8MEDSDE  		R9MEDSDE  		R10MEDSDE  		R11MEDSDE   	R12MEDSDE		R13MEDSDE		R14MEDSDE 		R15MEDSDE
									R2SHOPDE  		R3SHOPDE  		R4SHOPDE  		R5SHOPDE  		R6SHOPDE  		R7SHOPDE  		R8SHOPDE  		R9SHOPDE  		R10SHOPDE  		R11SHOPDE   	R12SHOPDE		R13SHOPDE		R14SHOPDE 		R15SHOPDE
									R2MEALSDE 		R3MEALSDE 		R4MEALSDE 		R5MEALSDE 		R6MEALSDE 		R7MEALSDE 		R8MEALSDE 		R9MEALSDE 		R10MEALSDE 		R11MEALSDE  	R12MEALSDE		R13MEALSDE		R14MEALSDE 		R15MEALSDE
									R2IADLDE  		R3IADLDE  		R4IADLDE  		R5IADLDE  		R6IADLDE  		R7IADLDE  		R8IADLDE  		R9IADLDE  		R10IADLDE  		R11IADLDE   	R12IADLDE		R13IADLDE		R14IADLDE 		R15IADLDE
									R2IADLDESUM 	R3IADLDESUM 	R4IADLDESUM 	R5IADLDESUM 	R6IADLDESUM 	R7IADLDESUM 	R8IADLDESUM 	R9IADLDESUM 	R10IADLDESUM 	R11IADLDESUM 	R12IADLDESUM	R13IADLDESUM	R14IADLDESUM 	R15IADLDESUM
									R2IADLDEMISS 	R3IADLDEMISS 	R4IADLDEMISS 	R5IADLDEMISS 	R6IADLDEMISS 	R7IADLDEMISS 	R8IADLDEMISS 	R9IADLDEMISS 	R10IADLDEMISS 	R11IADLDEMISS 	R12IADLDEMISS	R13IADLDEMISS	R14IADLDEMISS 	R15IADLDEMISS

                        READLDE READLDESUM READLDEMISS READLDE6 READLDESUM6 READLDEMISS6 REIADLDE REIADLDESUM REIADLDEMISS
                        timehelpmaxADL timehelpmaxADL6 timehelpmaxIADL);
proc sort; by hhidpn; run;
/*42406 observations and 18*15 + 16*14 + 12 + 1 (hhidpn)= 507 variables*/

ods csv file='path\adl_iadl\DataDictionary_DerivedADLsIADLs_gdr_20230510.csv';
proc contents data=savedata.derived_adl_iadl_gdr_20230510; run;
ods csv close;

















	
