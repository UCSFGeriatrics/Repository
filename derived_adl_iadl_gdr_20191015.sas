/*********** Title: Derivation of ADL and IADL variables ***********/
/*********** Purpose: Derive variables from 1992-2016 HRS waves:
						- any ADLdiff (5 adl): bath, bed, dress, eat, toilet
  						- any ADLdiff (6 adl): bath, bed, dress, eat, toilet, walk
						- ADLsum (5 adl), ADLsum (6 adl)
						- ADL dependence 
						- any ADL dependence (5 adl) , any ADLdep (6 adl)

						- any IADLdiff
						- IADLsum
						- IADL help for five task: telephone, money, medicine, shopping, meals
						- IADL dependence
						- any IADL dependence
*********** /
/*********** Date completed: 2019.07.02   ***********/

libname rand 'path\randhrs1992_2016v1';
proc format cntlin=rand.sasfmts;run;
libname fat 'path\fatfiles';
options nofmterr nocenter nodate mlogic mprint;

/******************************MACRO SECTION *******************************/

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


/*Get IADL help variables from fat files from 1995-2016*/
%merge2sets(rand.fatvarsIADLhelp, 					 fat.h16e2a,          hhidpn PG043 PG046 PG049 PG053 PG061 , 
							  					 	 fat.h14f2a,          hhidpn OG043 OG046 OG049 OG053 OG061 , hhidpn, ); 
%merge2sets(rand.fatvarsIADLhelp, rand.fatvarsIADLhelp, , fat.h12f2a,   hhidpn NG043 NG046 NG049 NG053 NG061 , hhidpn, ); 
%merge2sets(rand.fatvarsIADLhelp, rand.fatvarsIADLhelp, , fat.hd10f5e,  hhidpn MG043 MG046 MG049 MG053 MG061 , hhidpn, ); 
%merge2sets(rand.fatvarsIADLhelp, rand.fatvarsIADLhelp, , fat.h08f3a,   hhidpn LG043 LG046 LG049 LG053 LG061 , hhidpn, ); 
%merge2sets(rand.fatvarsIADLhelp, rand.fatvarsIADLhelp, , fat.h06f3a,   hhidpn KG043 KG046 KG049 KG053 KG061 , hhidpn, ); 
%merge2sets(rand.fatvarsIADLhelp, rand.fatvarsIADLhelp, , fat.h04f1b,   hhidpn JG043 JG046 JG049 JG053 JG061 , hhidpn, ); 
%merge2sets(rand.fatvarsIADLhelp, rand.fatvarsIADLhelp, , fat.h02f2c,   hhidpn HG043 HG046 HG049 HG053 HG061 , hhidpn, ); 
%merge2sets(rand.fatvarsIADLhelp, rand.fatvarsIADLhelp, , fat.h00f1c,   hhidpn G2863 G2868 G2873 G2878 G2918 , hhidpn, ); 
%merge2sets(rand.fatvarsIADLhelp, rand.fatvarsIADLhelp, , fat.hd98f2c,  hhidpn F2565 F2570 F2575 F2580 F2620 , hhidpn, ); 
%merge2sets(rand.fatvarsIADLhelp, rand.fatvarsIADLhelp, , fat.h96f4a,   hhidpn E2039 E2044 E2049 E2054 E2096 , hhidpn, ); 
%merge2sets(rand.fatvarsIADLhelp, rand.fatvarsIADLhelp, , fat.ad95f2b,   hhidpn D2024 D2029 D2034 D2039 D2102 , hhidpn, ); 
/*39778 observations and 61 variable*/
proc contents data=rand.fatvarsIADLhelp; run;

/*Get ADL and IADL difficulty variables from RAND HRS dataset*/
data rand.randvars_adl_iadl;
	set rand.randhrs1992_2016v1 (keep=hhidpn HACOHORT
	/*ADL difficulty: ADL diff for toilet not asked in wave 1*/
		R1BATHW  R2BATHA   R3BATHA   R4BATHA   R5BATHA   R6BATHA   R7BATHA   R8BATHA   R9BATHA   R10BATHA   R11BATHA  R12BATHA	R13BATHA
		R1BEDW   R2BEDA    R3BEDA    R4BEDA    R5BEDA    R6BEDA    R7BEDA    R8BEDA    R9BEDA    R10BEDA    R11BEDA	  R12BEDA	R13BEDA
		R1DRESSW R2DRESSA  R3DRESSA  R4DRESSA  R5DRESSA  R6DRESSA  R7DRESSA  R8DRESSA  R9DRESSA  R10DRESSA  R11DRESSA R12DRESSA	R13DRESSA
		R1EATW   R2EATA    R3EATA    R4EATA    R5EATA    R6EATA    R7EATA    R8EATA    R9EATA    R10EATA    R11EATA	  R12EATA	R13EATA	
		 		 R2TOILTA  R3TOILTA  R4TOILTA  R5TOILTA  R6TOILTA  R7TOILTA  R8TOILTA  R9TOILTA  R10TOILTA  R11TOILTA R12TOILTA R13TOILTA
		R1WALKRW R2WALKRA  R3WALKRA  R4WALKRA  R5WALKRA  R6WALKRA  R7WALKRA  R8WALKRA  R9WALKRA  R10WALKRA  R11WALKRA R12WALKRA	R13WALKRA	

	/*ADL Help variables: not present in wave 1*/
				 R2BATHH   R3BATHH   R4BATHH   R5BATHH   R6BATHH   R7BATHH   R8BATHH   R9BATHH   R10BATHH   R11BATHH	R12BATHH R13BATHH	
				 R2BEDH    R3BEDH    R4BEDH    R5BEDH    R6BEDH    R7BEDH    R8BEDH    R9BEDH    R10BEDH    R11BEDH		R12BEDH	 R13BEDH
				 R2DRESSH  R3DRESSH  R4DRESSH  R5DRESSH  R6DRESSH  R7DRESSH  R8DRESSH  R9DRESSH  R10DRESSH  R11DRESSH	R12DRESSH R13DRESSH
				 R2EATH    R3EATH    R4EATH    R5EATH    R6EATH    R7EATH    R8EATH    R9EATH    R10EATH    R11EATH		R12EATH	  R13EATH
				 R2TOILTH  R3TOILTH  R4TOILTH  R5TOILTH  R6TOILTH  R7TOILTH  R8TOILTH  R9TOILTH  R10TOILTH  R11TOILTH	R12TOILTH R13TOILTH
				 R2WALKRH  R3WALKRH  R4WALKRH  R5WALKRH  R6WALKRH  R7WALKRH  R8WALKRH  R9WALKRH  R10WALKRH  R11WALKRH	R12WALKRH R13WALKRH

	/*IADL difficulty: IADL difficulties not asked in wave 1. In wave 2H only IADLs: using the phone, taking medications, and managing money*/
	    		 R2PHONEA R2MONEYA R2MEDSA R2SHOPA R2MEALSA
	             R3PHONEA R3MONEYA R3MEDSA R3SHOPA R3MEALSA
				 R4PHONEA R4MONEYA R4MEDSA R4SHOPA R4MEALSA
				 R5PHONEA R5MONEYA R5MEDSA R5SHOPA R5MEALSA
				 R6PHONEA R6MONEYA R6MEDSA R6SHOPA R6MEALSA
				 R7PHONEA R7MONEYA R7MEDSA R7SHOPA R7MEALSA
				 R8PHONEA R8MONEYA R8MEDSA R8SHOPA R8MEALSA
				 R9PHONEA R9MONEYA R9MEDSA R9SHOPA R9MEALSA
				 R10PHONEA R10MONEYA R10MEDSA R10SHOPA R10MEALSA
	             R11PHONEA R11MONEYA R11MEDSA R11SHOPA R11MEALSA	
	             R12PHONEA R12MONEYA R12MEDSA R12SHOPA R12MEALSA
				 R13PHONEA R13MONEYA R13MEDSA R13SHOPA R13MEALSA);
proc sort; by hhidpn; run;	
/*42053 observations and 211 variables.*/

/*Merge fatvarsIADLhelp and randvars_adl_iadl*/
data randfat;
	merge rand.randvars_adl_iadl (in=A) rand.fatvarsIADLhelp;
	by hhidpn;
	if A;
proc sort; by hhidpn; run;	
/*42053 observations and 271 variables.*/ 

/*Derive any ADL difficulty and ADLsum*/
data randfat2;
	set randfat;

	R1TOILTW=.; /*set the ADL difficulty for using the toilet equal to missing since this question was not asked in wave 1*/

	array BADIF[13] R1BATHW 	R2BATHA 	R3BATHA 	R4BATHA 	R5BATHA 	R6BATHA 	R7BATHA 	R8BATHA 	R9BATHA 	R10BATHA 	R11BATHA 	R12BATHA	R13BATHA;
	array BEDIF[13] R1BEDW  	R2BEDA  	R3BEDA  	R4BEDA  	R5BEDA  	R6BEDA  	R7BEDA  	R8BEDA  	R9BEDA  	R10BEDA  	R11BEDA  	R12BEDA		R13BEDA;
	array DRDIF[13] R1DRESSW 	R2DRESSA 	R3DRESSA 	R4DRESSA 	R5DRESSA 	R6DRESSA 	R7DRESSA 	R8DRESSA 	R9DRESSA 	R10DRESSA 	R11DRESSA 	R12DRESSA	R13DRESSA;
	array EADIF[13] R1EATW 		R2EATA 		R3EATA 		R4EATA 		R5EATA 		R6EATA 		R7EATA 		R8EATA 		R9EATA 		R10EATA 	R11EATA   	R12EATA		R13EATA;
	array TODIF[13] R1TOILTW 	R2TOILTA 	R3TOILTA 	R4TOILTA 	R5TOILTA 	R6TOILTA 	R7TOILTA 	R8TOILTA 	R9TOILTA 	R10TOILTA 	R11TOILTA 	R12TOILTA	R13TOILTA;
	array WADIF[13]	R1WALKRW   	R2WALKRA  	R3WALKRA  	R4WALKRA  	R5WALKRA  	R6WALKRA 	R7WALKRA  	R8WALKRA  	R9WALKRA  	R10WALKRA  	R11WALKRA 	R12WALKRA	R13WALKRA;
	
	array ADLYN[13] R1ADLDIF 	R2ADLDIF 	R3ADLDIF 	R4ADLDIF 	R5ADLDIF 	R6ADLDIF 	R7ADLDIF 	R8ADLDIF 	R9ADLDIF 	R10ADLDIF 	R11ADLDIF 	R12ADLDIF	R13ADLDIF;
	array ADLSM[13] R1ADLSUM 	R2ADLSUM 	R3ADLSUM 	R4ADLSUM 	R5ADLSUM 	R6ADLSUM 	R7ADLSUM 	R8ADLSUM 	R9ADLSUM 	R10ADLSUM 	R11ADLSUM 	R12ADLSUM	R13ADLSUM;

	array ADLYN6[13] R1ADLDIF6 	R2ADLDIF6 	R3ADLDIF6 	R4ADLDIF6 	R5ADLDIF6 	R6ADLDIF6 	R7ADLDIF6 	R8ADLDIF6 	R9ADLDIF6 	R10ADLDIF6 	R11ADLDIF6 	R12ADLDIF6	R13ADLDIF6;
	array ADLSM6[13] R1ADLSUM6 	R2ADLSUM6 	R3ADLSUM6 	R4ADLSUM6 	R5ADLSUM6 	R6ADLSUM6 	R7ADLSUM6 	R8ADLSUM6 	R9ADLSUM6 	R10ADLSUM6 	R11ADLSUM6 	R12ADLSUM6	R13ADLSUM6;

	do i=1 to 13;

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

		   if ADLYN[i]=1 then ADLSM[I]=SUM(OF BADIF[I] BEDIF[I] DRDIF[I] EADIF[I]);
   		   else if ADLYN[i]=0 then ADLSM[I]=0;

		  /*This any ADL diff and sum are considering 5 ADLs instead of 4*/
		   if BADIF[i]=1 or BEDIF[i]=1 or DRDIF[i]=1 or EADIF[i]=1 or WADIF[i]=1 then ADLYN6[i]=1;
		   else if BADIF[i]=0 and BEDIF[i]=0 and DRDIF[i]=0 and EADIF[i]=0 and WADIF[i]=0 then ADLYN6[i]=0;

		   if ADLYN6[i]=1 then ADLSM6[I]=SUM(OF BADIF[I] BEDIF[I] DRDIF[I] EADIF[I] WADIF[i]);
   		   else if ADLYN6[i]=0 then ADLSM6[I]=0;
 		end;

		else if (i=2 and HACOHORT ne 3) or i in (3,4,5,6,7,8,9,10,11,12,13) then do;
		/*This includes the ADL for toilet  because it was asked for wave 2A and from wave 3 forward*/
		   if BADIF[i]=1 or BEDIF[i]=1 or DRDIF[i]=1 or EADIF[i]=1 or TODIF[i]=1 then ADLYN[i]=1;
		   else if BADIF[i]=0 and BEDIF[i]=0 and DRDIF[i]=0 and EADIF[i]=0 and TODIF[i]=0 then ADLYN[i]=0;

		   if ADLYN[i]=1 then ADLSM[I]=SUM(OF BADIF[I] BEDIF[I] DRDIF[I] EADIF[I] TODIF[I]);
   		   else if ADLYN[i]=0 then ADLSM[I]=0;

			/*This any ADL diff and sum are considering 6 ADLs instead of 5*/
		   if BADIF[i]=1 or BEDIF[i]=1 or DRDIF[i]=1 or EADIF[i]=1 or TODIF[i]=1 or WADIF[i]=1 then ADLYN6[i]=1;
		   else if BADIF[i]=0 and BEDIF[i]=0 and DRDIF[i]=0 and EADIF[i]=0 and TODIF[i]=0 and WADIF[i]=0 then ADLYN6[i]=0;

		   if ADLYN6[i]=1 then ADLSM6[I]=SUM(OF BADIF[I] BEDIF[I] DRDIF[I] EADIF[I] TODIF[i] WADIF[i]);
   		   else if ADLYN6[i]=0 then ADLSM6[I]=0;
 		end;

	end; drop i;
proc sort; by hhidpn;run;
/*42053 observations and 324 variables.*/

/*Derive: ADL dependence, any ADL dependence (5 adl) , any ADLdep (6 adl)*/
data randfat3;
	set randfat2;

	/*Difficulty variables*/
	R1TOILTW=.; /*GDR: set the ADL difficulty for using the toilet equal to missing since this question was not asked in wave 1*/

	array BADIF[13] R1BATHW 	R2BATHA 	R3BATHA 	R4BATHA 	R5BATHA 	R6BATHA 	R7BATHA 	R8BATHA 	R9BATHA 	R10BATHA 	R11BATHA 	R12BATHA	R13BATHA;
	array BEDIF[13] R1BEDW  	R2BEDA  	R3BEDA  	R4BEDA  	R5BEDA  	R6BEDA  	R7BEDA  	R8BEDA  	R9BEDA  	R10BEDA  	R11BEDA  	R12BEDA		R13BEDA;
	array DRDIF[13] R1DRESSW 	R2DRESSA 	R3DRESSA 	R4DRESSA 	R5DRESSA 	R6DRESSA 	R7DRESSA 	R8DRESSA 	R9DRESSA 	R10DRESSA 	R11DRESSA 	R12DRESSA	R13DRESSA;
	array EADIF[13] R1EATW 		R2EATA 		R3EATA 		R4EATA 		R5EATA 		R6EATA 		R7EATA 		R8EATA 		R9EATA 		R10EATA 	R11EATA   	R12EATA		R13EATA;
	array TODIF[13] R1TOILTW 	R2TOILTA 	R3TOILTA 	R4TOILTA 	R5TOILTA 	R6TOILTA 	R7TOILTA 	R8TOILTA 	R9TOILTA 	R10TOILTA 	R11TOILTA 	R12TOILTA	R13TOILTA;
	array WADIF[13]	R1WALKRW   	R2WALKRA  	R3WALKRA  	R4WALKRA  	R5WALKRA  	R6WALKRA 	R7WALKRA  	R8WALKRA  	R9WALKRA  	R10WALKRA  	R11WALKRA 	R12WALKRA	R13WALKRA;


	/*Because in wave 1 questions about help are not asked I set those values for help in wave 1 as missing
	For HRS Respondents in Wave 2H, the R2[adl]H variables are already set to .Q.*/
	R1BATHH=.; R1BEDH=.; R1DRESSH=.; R1EATH=.; R1TOILTH=.; R1WALKRH=.;

	array BAH [13] R1BATHH    R2BATHH   R3BATHH   R4BATHH   R5BATHH   R6BATHH   R7BATHH   R8BATHH   R9BATHH   R10BATHH   R11BATHH	R12BATHH	R13BATHH;
	array BEH [13] R1BEDH     R2BEDH    R3BEDH    R4BEDH    R5BEDH    R6BEDH    R7BEDH    R8BEDH    R9BEDH    R10BEDH    R11BEDH	R12BEDH		R13BEDH;
	array DRH [13] R1DRESSH   R2DRESSH  R3DRESSH  R4DRESSH  R5DRESSH  R6DRESSH  R7DRESSH  R8DRESSH  R9DRESSH  R10DRESSH  R11DRESSH	R12DRESSH	R13DRESSH;
	array EAH [13] R1EATH     R2EATH    R3EATH    R4EATH    R5EATH    R6EATH    R7EATH    R8EATH    R9EATH    R10EATH    R11EATH	R12EATH		R13EATH;
	array TOH [13] R1TOILTH   R2TOILTH  R3TOILTH  R4TOILTH  R5TOILTH  R6TOILTH  R7TOILTH  R8TOILTH  R9TOILTH  R10TOILTH  R11TOILTH	R12TOILTH	R13TOILTH;
	array WAH [13] R1WALKRH   R2WALKRH  R3WALKRH  R4WALKRH  R5WALKRH  R6WALKRH  R7WALKRH  R8WALKRH  R9WALKRH  R10WALKRH  R11WALKRH	R12WALKRH	R13WALKRH;

	/*Dependence variables: these variables are derived below*/
	array BAD [13] R1BATDE    R2BATDE   R3BATDE   R4BATDE   R5BATDE   R6BATDE   R7BATDE   R8BATDE   R9BATDE   R10BATDE   R11BATDE		R12BATDE	R13BATDE;
	array BED [13] R1BEDDE    R2BEDDE   R3BEDDE   R4BEDDE   R5BEDDE   R6BEDDE   R7BEDDE   R8BEDDE   R9BEDDE   R10BEDDE   R11BEDDE		R12BEDDE	R13BEDDE;
	array DRD [13] R1DRESSDE  R2DRESSDE R3DRESSDE R4DRESSDE R5DRESSDE R6DRESSDE R7DRESSDE R8DRESSDE R9DRESSDE R10DRESSDE R11DRESSDE		R12DRESSDE	R13DRESSDE;
	array EAD [13] R1EATDE    R2EATDE   R3EATDE   R4EATDE   R5EATDE   R6EATDE   R7EATDE   R8EATDE   R9EATDE   R10EATDE   R11EATDE		R12EATDE	R13EATDE;
	array TOD [13] R1TOILTDE  R2TOILTDE R3TOILTDE R4TOILTDE R5TOILTDE R6TOILTDE R7TOILTDE R8TOILTDE R9TOILTDE R10TOILTDE R11TOILTDE		R12TOILTDE	R13TOILTDE;
	array WAD [13] R1WALKRDE  R2WALKRDE R3WALKRDE R4WALKRDE R5WALKRDE R6WALKRDE R7WALKRDE R8WALKRDE R9WALKRDE R10WALKRDE R11WALKRDE		R12WALKRDE	R13WALKRDE;


	array ADLDEY[13]  	R1ADLDE  R2ADLDE   R3ADLDE   R4ADLDE   R5ADLDE   R6ADLDE   R7ADLDE   R8ADLDE   R9ADLDE   R10ADLDE    R11ADLDE      R12ADLDE		R13ADLDE;
	array ADLDEY6[13] 	R1ADLDE6 R2ADLDE6  R3ADLDE6  R4ADLDE6  R5ADLDE6  R6ADLDE6  R7ADLDE6  R8ADLDE6  R9ADLDE6  R10ADLDE6   R11ADLDE6     R12ADLDE6	R13ADLDE6;

	/*Derive dependence variables: if ADLdiff=1 and ADLhelp=(1,2,3,9,.X) then ADLdependence=1
	   							   if ADLdiff=1 and ADLhelp=0 then ADLdependence=0
	   							   if ADLdiff=1 and ADLhelp=. then ADLdependence=.
	   							   if ADLdiff=0 				then ADLdependence=0*/

	/*For wave 1 because we don't have help variables for this wave, we can only know if the participant didn't have ADL dependence by looking at the ADL difficulty variables*/
	do i=1 to 13;
	   if BADIF[I]=1 then do;
			if BAH[I] in (1,2,3,9,.X) then BAD[I]=1; /*1.Yes,occasionally , 2.Yes,some of the time, 3.Yes,most of the time: These 3 categories are only for wave 2A. 9.Don't do, .X.Don't do*/
			else if BAH[I]=0 then BAD[I]=0;
			else BAD[I]=.;
		end;
		else if BADIF[I]=0 then BAD[I]=0;

		if BEDIF[I]=1 then do;
			if BEH[I] in (1,2,3,9,.X) then BED[I]=1;
			else if BEH[I]=0 then BED[I]=0;
			else BED[I]=.;
		end;
		else if BEDIF[I]=0 then BED[I]=0;

		if DRDIF[I]=1 then do;
			if DRH[I] in (1,2,3,9,.X) then DRD[I]=1;
			else if DRH[I]=0 then DRD[I]=0;
			else DRD[I]=.;
		end;
		else if DRDIF[I]=0 then DRD[I]=0;

		if EADIF[I]=1 then do;
			if EAH[I] in (1,2,3,9,.X) then EAD[I]=1;
			else if EAH[I]=0 then EAD[I]=0;
			else EAD[I]=.;
		end;
		else if EADIF[I]=0 then EAD[I]=0;

		if TODIF[I]=1 then do;
			if TOH[I] in (1,2,3,9,.X) then TOD[I]=1;
			else if TOH[I]=0 then TOD[I]=0;
			else TOD[I]=.;
		end;
		else if TODIF[I]=0 then TOD[I]=0;

		if WADIF[I]=1 then do;
			if WAH[I] in (1,2,3,9,.X) then WAD[I]=1;
			else if WAH[I]=0 then WAD[I]=0;
			else WAD[I]=.;
		end;
		else if WADIF[I]=0 then WAD[I]=0;

		if i=1 or (i=2 and HACOHORT=3) then do;
	  	/*This doesn't include the ADL for toilet because it was asked for wave 2A and from wave 3 forward, so the ADLdep in wave 1 and wave 2H is based on 4 ADLs rather than 5 ADLs*/
	  		if BAD[i]=1 or BED[i]=1 or DRD[i]=1 or EAD[i]=1 then ADLDEY[i]=1;
	    	else if BAD[i]=0 and BED[i]=0 and DRD[i]=0 and EAD[i]=0 then ADLDEY[i]=0;

			/*This any ADL dep is considering 5 ADLs instead of 4*/
		   if BAD[i]=1 or BED[i]=1 or DRD[i]=1 or EAD[i]=1 or WAD[i]=1 then ADLDEY6[i]=1;
		   else if BAD[i]=0 and BED[i]=0 and DRD[i]=0 and EAD[i]=0 and WAD[i]=0 then ADLDEY6[i]=0;
	    end;

	    else if (i=2 and HACOHORT ne 3) or i in (3,4,5,6,7,8,9,10,11,12,13)  then do;
	   		if BAD[i]=1 or BED[i]=1 or DRD[i]=1 or EAD[i]=1 or TOD[i]=1 then ADLDEY[i]=1;
	   		else if BAD[i]=0 and BED[i]=0 and DRD[i]=0 and EAD[i]=0 and TOD[i]=0 then ADLDEY[i]=0;

			/*This any ADL dep is considering 6 ADLs instead of 5*/
			if BAD[i]=1 or BED[i]=1 or DRD[i]=1 or EAD[i]=1 or TOD[i]=1 or WAD[i]=1 then ADLDEY6[i]=1;
	   		else if BAD[i]=0 and BED[i]=0 and DRD[i]=0 and EAD[i]=0 and TOD[i]=0 and WAD[i]=0 then ADLDEY6[i]=0;
	   end;
	end; drop i;
proc sort; by hhidpn; run; 
/*42053 observations and 434 variables*/

/*Derive any IADL difficulty and IADLsum*/
/*Note: We start in wave 2 because in wave 1 they didn't ask about any of the activities normally considered IADL: preparing meals, shopping for groceries, using the phone, taking medications, or managing money*/
/*Note: Shopping and preparing meals were not asked in wave 2H*/

data randfat4;
	set randfat3;

	array PHDIF[12]  R2PHONEA 	R3PHONEA 	R4PHONEA 	R5PHONEA 	R6PHONEA 	R7PHONEA 	R8PHONEA 	R9PHONEA 	R10PHONEA 	R11PHONEA 	R12PHONEA	R13PHONEA;
	array MODIF[12]  R2MONEYA 	R3MONEYA 	R4MONEYA 	R5MONEYA 	R6MONEYA 	R7MONEYA 	R8MONEYA 	R9MONEYA 	R10MONEYA 	R11MONEYA 	R12MONEYA	R13MONEYA;
	array MEDIF[12]  R2MEDSA  	R3MEDSA  	R4MEDSA  	R5MEDSA  	R6MEDSA  	R7MEDSA  	R8MEDSA  	R9MEDSA  	R10MEDSA 	R11MEDSA 	R12MEDSA	R13MEDSA;
	array SHDIF[12]  R2SHOPA  	R3SHOPA  	R4SHOPA  	R5SHOPA  	R6SHOPA  	R7SHOPA  	R8SHOPA  	R9SHOPA  	R10SHOPA 	R11SHOPA 	R12SHOPA	R13SHOPA;
	array MLDIF[12]  R2MEALSA 	R3MEALSA 	R4MEALSA 	R5MEALSA 	R6MEALSA 	R7MEALSA 	R8MEALSA 	R9MEALSA 	R10MEALSA 	R11MEALSA 	R12MEALSA	R13MEALSA;
	array IADLYN[12] R2IADLDIF 	R3IADLDIF 	R4IADLDIF 	R5IADLDIF 	R6IADLDIF 	R7IADLDIF 	R8IADLDIF 	R9IADLDIF 	R10IADLDIF 	R11IADLDIF 	R12IADLDIF	R13IADLDIF;
	array IADLSM[12] R2IADLSUM 	R3IADLSUM 	R4IADLSUM 	R5IADLSUM 	R6IADLSUM 	R7IADLSUM 	R8IADLSUM 	R9IADLSUM 	R10IADLSUM 	R11IADLSUM 	R12IADLSUM	R13IADLSUM;

	/*Change special  missing value:.Z to zero
	'.Z=Dont do/No if did'*: Respondent doesn't need to take medicines, but if she/he did she wouldn't have any difficulty, so we can safely recode these values as zeroes*/
	do i =1 to 12;
		if MEDIF[i]=.Z then MEDIF[i]=0;

	   	if i=1 and HACOHORT=3  then do; /*i=1 wave 2H*/
		/*The IADL diffs for HRS respondents in wave 2H is based on 3 IADLs: using phone, taking medications, and managing money since shopping and preparing meals were not asked in wave 2H.
		In Wave 2A and from Wave 3 forward, the questions about shopping for groceries and preparing meals are added.
		*/
	     if PHDIF[i]=1 or MODIF[i]=1 or MEDIF[i]=1 then IADLYN[i]=1;
	     else if PHDIF[i] in (0,.X) and MODIF[i] in (0,.X) and MEDIF[i] in (0,.X) then IADLYN[i]=0; 

		 if IADLYN[i]=1 then IADLSM[I]=SUM(OF PHDIF[I] MODIF[I] MEDIF[I]);
		else if IADLYN[i]=0 then IADLSM[I]=0;
	   end;

	    else if (i=1 and HACOHORT ne 3) or i in (2,3,4,5,6,7,8,9,10,11,12) then do; /*for wave 2A and from wave 3 forward there are 5 IADLs*/
	    if PHDIF[i]=1 or MODIF[i]=1 or MEDIF[i]=1 or SHDIF[i]=1 or MLDIF[i]=1 then IADLYN[i]=1;
	    else if PHDIF[i] in (0,.X) and MODIF[i] in (0,.X) and MEDIF[i] in (0,.X) and SHDIF[i] in (0,.X) and MLDIF[i] in (0,.X) then IADLYN[i]=0;

		if IADLYN[i]=1 then IADLSM[I]=SUM(OF PHDIF[I] MODIF[I] MEDIF[I] SHDIF[I] MLDIF[I]);
		else if IADLYN[i]=0 then IADLSM[I]=0;
	   end;

	end; drop i;
proc sort; by hhidpn; run;
/*42053 observations and 458 variables*/

/*Derive IADL help for five tasks: telephone, money, medicine, shopping, meals, IADL dependence, any IADL dependence */
data rand.derived_adl_iadl_gdr_20190702;
	set randfat4;

	filler = .;

	/*IADL difficulty*/
	array PHDIF[12]  R2PHONEA 	R3PHONEA 	R4PHONEA 	R5PHONEA 	R6PHONEA 	R7PHONEA 	R8PHONEA 	R9PHONEA 	R10PHONEA 	R11PHONEA	R12PHONEA	R13PHONEA;
	array MODIF[12]  R2MONEYA 	R3MONEYA 	R4MONEYA 	R5MONEYA 	R6MONEYA 	R7MONEYA 	R8MONEYA 	R9MONEYA 	R10MONEYA 	R11MONEYA	R12MONEYA	R13MONEYA;
	array MEDIF[12]  R2MEDSA  	R3MEDSA  	R4MEDSA  	R5MEDSA  	R6MEDSA  	R7MEDSA  	R8MEDSA  	R9MEDSA  	R10MEDSA 	R11MEDSA	R12MEDSA	R13MEDSA;
	array SHDIF[12]  R2SHOPA  	R3SHOPA  	R4SHOPA  	R5SHOPA  	R6SHOPA  	R7SHOPA  	R8SHOPA  	R9SHOPA  	R10SHOPA 	R11SHOPA	R12SHOPA	R13SHOPA;
	array MLDIF[12]  R2MEALSA 	R3MEALSA 	R4MEALSA 	R5MEALSA 	R6MEALSA 	R7MEALSA 	R8MEALSA 	R9MEALSA 	R10MEALSA 	R11MEALSA	R12MEALSA	R13MEALSA;

	/*Change special  missing value:.Z to zero
		'.Z=Dont do/No if did'*: Respondent doesn't need to take medicines, but if she/he did she wouldn't have any difficulty, so we can safely recode these values as zeroes*/
	do i =1 to 12;
		if MEDIF[i]=.Z then MEDIF[i]=0;
	end; drop i;

    if HACOHORT=3 then do; phonehelp=E2049; moneyhelp=E2096; medicinehelp=E2054; shophelp=E2044; mealhelp= E2039; end; /*3.Hrs*/
    else if HACOHORT in (0,1) then do; phonehelp=D2034; moneyhelp=D2102; medicinehelp=D2039; shophelp=D2029; mealhelp= D2024; end; /*0.Hrs/Ahead ovrlap, 1.Ahead*/ 

	/*IADL help arrays*/
	array phhelp[12] filler 	phonehelp 		F2575 		G2873 		HG049 		JG049 		KG049 		LG049 		MG049 		NG049 		OG049	PG049;
	array mohelp[12] filler 	moneyhelp 		F2620 		G2918 		HG061 		JG061 		KG061 		LG061 		MG061 		NG061 		OG061	PG061;
	array medhelp[12]filler 	medicinehelp 	F2580 		G2878 		HG053 		JG053 		KG053 		LG053 		MG053 		NG053 		OG053	PG053;
	array shhelp[12] filler 	shophelp 		F2570 		G2868 		HG046 		JG046 		KG046 		LG046 		MG046 		NG046 		OG046	PG046;
	array mlhelp[12]filler 		mealhelp 		F2565 		G2863 		HG043 		JG043 		KG043 		LG043 		MG043  		NG043 		OG043	PG043;

	array phhelp2[12] R2PHONEH  R3PHONEH 		R4PHONEH 	R5PHONEH 	R6PHONEH 	R7PHONEH 	R8PHONEH 	R9PHONEH 	R10PHONEH	R11PHONEH R12PHONEH	R13PHONEH;
	array mohelp2[12] R2MONEYH  R3MONEYH 		R4MONEYH 	R5MONEYH 	R6MONEYH 	R7MONEYH 	R8MONEYH 	R9MONEYH 	R10MONEYH 	R11MONEYH R12MONEYH	R13MONEYH;
	array medhelp2[12]R2MEDSH   R3MEDSH  		R4MEDSH  	R5MEDSH  	R6MEDSH  	R7MEDSH  	R8MEDSH  	R9MEDSH  	R10MEDSH 	R11MEDSH  R12MEDSH	R13MEDSH;
	array shhelp2[12] R2SHOPH  	R3SHOPH  		R4SHOPH  	R5SHOPH  	R6SHOPH  	R7SHOPH  	R8SHOPH  	R9SHOPH  	R10SHOPH 	R11SHOPH  R12SHOPH	R13SHOPH;
	array mlhelp2[12] R2MEALSH 	R3MEALSH 		R4MEALSH 	R5MEALSH 	R6MEALSH	R7MEALSH 	R8MEALSH 	R9MEALSH 	R10MEALSH 	R11MEALSH R12MEALSH	R13MEALSH;

	do i=1 to 12;
		if i in (1,2,3,4,5,7,8,9,10,11,12) then do; 
			if phhelp[i]=1 then phhelp2[i]=1; else if phhelp[i]=5 then phhelp2[i]=0; else phhelp2[i]=.;
			if mohelp[i]=1 then mohelp2[i]=1; else if mohelp[i]=5 then mohelp2[i]=0; else mohelp2[i]=.;
			if medhelp[i]=1 then medhelp2[i]=1; else if medhelp[i]=5 then medhelp2[i]=0; else medhelp2[i]=.;
			if shhelp[i]=1 then shhelp2[i]=1; else if shhelp[i]=5 then shhelp2[i]=0; else shhelp2[i]=.;
			if mlhelp[i]=1 then mlhelp2[i]=1; else if mlhelp[i]=5 then mlhelp2[i]=0; else mlhelp2[i]=.;
		end;

		/*Note: From RAND codebook
		"In Wave 7.2004 (i=6), a mistake in the Spanish instrument allowed "6.can’t do" and "7.don’t do" responses for the help questions,
		and a few of these responses are given for all of the IADLs except help with medications and money."
		Decided to recode: "7.don’t do" as '0.no need help' and "6.can’t do" as '1.yes need help'
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
	array PHD[12] 		R2PHONEDE R3PHONEDE R4PHONEDE R5PHONEDE R6PHONEDE R7PHONEDE R8PHONEDE R9PHONEDE R10PHONEDE R11PHONEDE  R12PHONEDE	R13PHONEDE;
	array MOD[12] 		R2MONEYDE R3MONEYDE R4MONEYDE R5MONEYDE R6MONEYDE R7MONEYDE R8MONEYDE R9MONEYDE R10MONEYDE R11MONEYDE  R12MONEYDE	R13MONEYDE;
	array MED[12] 		R2MEDSDE  R3MEDSDE  R4MEDSDE  R5MEDSDE  R6MEDSDE  R7MEDSDE  R8MEDSDE  R9MEDSDE  R10MEDSDE  R11MEDSDE   R12MEDSDE	R13MEDSDE;
	array SHD[12] 		R2SHOPDE  R3SHOPDE  R4SHOPDE  R5SHOPDE  R6SHOPDE  R7SHOPDE  R8SHOPDE  R9SHOPDE  R10SHOPDE  R11SHOPDE   R12SHOPDE	R13SHOPDE;
	array MLD[12] 		R2MEALSDE R3MEALSDE R4MEALSDE R5MEALSDE R6MEALSDE R7MEALSDE R8MEALSDE R9MEALSDE R10MEALSDE R11MEALSDE  R12MEALSDE	R13MEALSDE;
	array IADLDE[12] 	R2IADLDE  R3IADLDE  R4IADLDE  R5IADLDE  R6IADLDE  R7IADLDE  R8IADLDE  R9IADLDE  R10IADLDE  R11IADLDE   R12IADLDE	R13IADLDE;

	do i=1 to 12;
		if PHDIF[i]=1 then do;
			if phhelp2[i]=1 then PHD[i]=1;
			else if phhelp2[i]=0 then PHD[i]=0;
			else if phhelp2[i]=. then PHD[i]=.;
		end;
		else if PHDIF[i] in (0,.X) then PHD[i]=0; /*if the IADL data is missing because they “X.don’t do” then IADLdiff=0*/ 

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
	  end;

   	  else if (i=1 and HACOHORT ne 3) or i in (2,3,4,5,6,7,8,9,10,11,12) then do; /*from wave 2A and 3 forward there are 5 IADLs*/
	    if PHD[i]=1 or MOD[i]=1 or MED[i]=1 or SHD[i]=1 or MLD[i]=1 then IADLDE[i]=1; /* In wave 2A, there are no IADL help variables, so we cannot tell whether Dependence=1*/
	    else if PHD[i]=0 and MOD[i]=0 and MED[i]=0 and SHD[i]=0 and MLD[i]=0 then IADLDE[i]=0;
   	  end;
	end; drop i;
proc sort; by hhidpn; run;
/*42053 observations and 596 variables*/

proc contents data=rand.derived_adl_iadl_gdr_20190702; run;

















	
