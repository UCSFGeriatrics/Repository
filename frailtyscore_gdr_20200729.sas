***********************************************************************************************************************************************************************************;
*Purpose: Derive frailty score following definition from Cigolle et al. 2009                                                                                                       ;                                     
*Statistician: Grisell Diaz-Ramirez																																				   ;
*Date: 2020.07.29                                                                                                                                                                  ;
*Note: Program derives frailty score from within 3 years prior to procedure and 3 years after procedure                                                                            ;
***********************************************************************************************************************************************************************************;

/*References: 
 -- Cigolle CT, Ofstedal MB, Tian Z, Blaum CS.  Comparing models of frailty: the health and retirement study.  JAGS 2009 May; 57(5):830-9
 -- Whitlock EL, Diaz-Ramirez LG, Smith AK, Boscardin WJ, Avidan MS, Glymour MM. Cognitive Change After Cardiac Surgery Versus Cardiac Catheterization:
   A Population-Based Study. Ann Thorac Surg. 2019 Apr. 107(4):1119-1125. doi: 10.1016/j.athoracsur.2018.10.021. PMID: 30578068.
*/

*Note2: Some core variables like dizziness, fallnum, falls, sight, and hearing, can be updated to use cleaned variables from Harmonized HRS file instead of RAND Fat files variables;

data temp14 (drop=filler);
	set temp13;
	filler=.;
		
	array pre_vars [11] 	dizz0	fallsnum0	falls0	lifting0	weight0		cogtot0		proxymem0	iwrate0		sight0	hearing0	proxy0;
	array post_vars [11] 	dizz1	fallsnum1	falls1	lifting1	weight1		cogtot1		proxymem1	iwrate1		sight1	hearing1	proxy1;

	array wave3a [11] 		D967	D879		D878	R3LIFTA		R3WEIGHT	R3COGTOT	D1056		filler		D900	D908		R3PROXY;
	array wave3h [11] 		E969	E879		E878	R3LIFTA		R3WEIGHT	R3COGTOT	E1056		filler		E900	E908		R3PROXY;
	array wave4 [11] 		F1306	F1207		F1206	R4LIFTA		R4WEIGHT	R4COGTOT	F1373		filler		F1228	F1236		R4PROXY;
	array wave5 [11] 		G1439	G1340		G1339	R5LIFTA		R5WEIGHT	R5COGTOT	G1527		g517		G1361	G1369		R5PROXY;
	array wave6 [11] 		HC145	HC080		HC079	R6LIFTA		R6WEIGHT	R6COGTOT	HD501		ha011		HC095	HC103		R6PROXY;
	array wave7 [11] 		JC145	JC080		JC079	R7LIFTA		R7WEIGHT	R7COGTOT	JD501		ja011		JC095	JC103		R7PROXY;
	array wave8 [11] 		KC145	KC080		KC079	R8LIFTA		R8WEIGHT	R8COGTOT	KD501		ka011		KC095	KC103		R8PROXY;
	array wave9 [11] 		LC145	LC080		LC079	R9LIFTA		R9WEIGHT	R9COGTOT	LD501		la011		LC095	LC103		R9PROXY;	
	array wave10 [11] 		MC145	MC080		MC079	R10LIFTA	R10WEIGHT	R10COGTOT	MD501		ma011		MC095	MC103		R10PROXY;
	array wave11 [11] 		NC145	NC080		NC079	R11LIFTA	R11WEIGHT	R11COGTOT	ND501		na011		NC095	NC103		R11PROXY;
	array wave12 [11] 		OC145	OC080		OC079	R12LIFTA	R12WEIGHT	R12COGTOT	OD501		oa011		OC095	OC103		R12PROXY;
	array wave13 [11] 		PC145	PC080		PC079	R13LIFTA	R13WEIGHT	filler		PD501		pa011		PC095	PC103		R13PROXY;

	do i = 1 to 11;
		if pre_wavenum = 3 and HACOHORT in (0,1) then pre_vars{i} = wave3a{i};
		else if pre_wavenum = 3 and HACOHORT=3 then pre_vars{i} = wave3h{i};
		else if pre_wavenum = 4 then pre_vars{i} = wave4{i};
		else if pre_wavenum = 5 then pre_vars{i} = wave5{i};
		else if pre_wavenum = 6 then pre_vars{i} = wave6{i};
		else if pre_wavenum = 7 then pre_vars{i} = wave7{i};
		else if pre_wavenum = 8 then pre_vars{i} = wave8{i};
		else if pre_wavenum = 9 then pre_vars{i} = wave9{i};
		else if pre_wavenum = 10 then pre_vars{i} = wave10{i};
		else if pre_wavenum = 11 then pre_vars{i} = wave11{i};
		else if pre_wavenum = 12 then pre_vars{i} = wave12{i};
	end; drop i;

	if core_within3yrafter=1 then do i = 1 to 11;
		if post_wavenum = 4 then post_vars{i} = wave4{i};
		else if post_wavenum = 5 then post_vars{i} = wave5{i};
		else if post_wavenum = 6 then post_vars{i} = wave6{i};
		else if post_wavenum = 7 then post_vars{i} = wave7{i};
		else if post_wavenum = 8 then post_vars{i} = wave8{i};
		else if post_wavenum = 9 then post_vars{i} = wave9{i};
		else if post_wavenum = 10 then post_vars{i} = wave10{i};
		else if post_wavenum = 11 then post_vars{i} = wave11{i};
		else if post_wavenum = 12 then post_vars{i} = wave12{i};
		else if post_wavenum = 13 then post_vars{i} = wave13{i};
	end; drop i;

	array olvar[6] 	dizz0 dizz1 falls0 falls1 lifting0 lifting1;
	do i=1 to 6;
	 if olvar[i]=5 then olvar[i]=0;
	 else if olvar[i] in (7,8,9, .R, .S, .X, .D) then olvar[i]=.;
	end; drop i;

	array olvar2[8] proxymem0 proxymem1 iwrate0 iwrate1 sight0 sight1 hearing0 hearing1;
	do i=1 to 8;
	 if olvar2[i] in (7,8,9, .R, .D) then olvar2[i]=.;
	 *if olvar2[i] in (7,8,9, .R, .D, 0) then olvar2[i]=.;
	end;drop i;

	*Physical domain;
	*If dizz0 is missing check value of previous wave, that is, instead of pre-procedure dizziness be drawn from iw 2 years before, it would be iw 4 years before;
	if dizz0=. then do;
		if pre_wavenum = 4 then dizz0=E969;
		else if pre_wavenum = 5 then dizz0=F1306;
		else if pre_wavenum = 6 then dizz0=G1439;
		else if pre_wavenum = 7 then dizz0=HC145;
		else if pre_wavenum = 8 then dizz0=JC145;
		else if pre_wavenum = 9 then dizz0=KC145;
		else if pre_wavenum = 10 then dizz0=LC145;
		else if pre_wavenum = 11 then dizz0=MC145;
		else if pre_wavenum = 12 then dizz0=NC145;
	end;

	*I have to do this recoding again because for those with dizz0=. in previous wave I take the value of the wave before previous wave;
	if dizz0=5 then dizz0=0;
	else if dizz0 in (7,8,9, .R, .S, .X, .D) then dizz0=.; 

	if falls0=0 then fallsnum0=0;
    if fallsnum0 in (997, 998, 98, 999, 99) then fallsnum0=.;
    if pre_wavenum = 3 and HACOHORT in (0,1) and fallsnum0>20 then fallsnum0=.; /*in wave 1995: 21-996. extreme values*/

	if falls1=0 then fallsnum1=0;
    if fallsnum1 in (997, 998, 98, 999, 99) then fallsnum1=.;
    if pre_wavenum = 3 and HACOHORT in (0,1) and fallsnum1>20 then fallsnum1=.; /*in wave 1995: 21-996. extreme values*/

	if dizz0=1 or fallsnum0>=2 or lifting0=1 then physical0=1;
	else if dizz0=0 and 0<=fallsnum0<2 and lifting0=0 then physical0=0;

	if dizz1=1 or fallsnum1>=2 or lifting1=1 then physical1=1;
	else if dizz1=0 and 0<=fallsnum1<2 and lifting1=0 then physical1=0;
	label physical0='R had problem in physical dom pre procedure. 0.no, 1.yes'
	      physical1='R had problem in physical dom post procedure. 0.no, 1.yes';

   *Nutritive domain;
	if (((weight0-weight1)/weight0)*100) >=10 then weightdom=1;
	else if ((weight0-weight1)/weight0) ne . and (((weight0-weight1)/weight0)*100)<10 then weightdom=0;
	label weightdom='R % decrease in weight from pre to post procedure is >=10%. 0.no, 1.yes';
	if weightdom=1 or 0<=bmi0<18.5 then nutritive0=1;
	else if weightdom=0 and bmi0>=18.5 then nutritive0=0;
	label nutritive0='R had problem in nutritive dom pre procedure. 0.no, 1.yes';

	*Cognitive domain;
	if cogtot0>10 then cognitive0=0;
	else if 0<=cogtot0<=10 or proxymem0 in (4,5) or iwrate0 in (3,4) then cognitive0=1;
	else if proxymem0 in (1,2,3) or iwrate0 in (1,2) then cognitive0=0;

	if cogtot1>10 then cognitive1=0;
	else if 0<=cogtot1<=10 or proxymem1 in (4,5) or iwrate1 in (3,4) then cognitive1=1;
	else if proxymem1 in (1,2,3) or iwrate1 in (1,2) then cognitive1=0;
	label cognitive0='R had problem in cognitive dom pre procedure. 0.no, 1.yes'
	      cognitive1='R had problem in cognitive dom post procedure. 0.no, 1.yes';

    *Sensory domain;
    if sight0 in (4,5,6) or hearing0 in (4,5) then sensory0=1;
    else if sight0 in (1,2,3) and hearing0 in (1,2,3) then sensory0=0;

	if sight1 in (4,5,6) or hearing1 in (4,5) then sensory1=1;
    else if sight1 in (1,2,3) and hearing1 in (1,2,3) then sensory1=0;
	label sensory0='R had problem in sensory dom pre procedure. 0.no, 1.yes'
	      sensory1='R had problem in sensory dom post procedure. 0.no, 1.yes';

	*Frailty score;
	 domainmiss0=nmiss(physical0, nutritive0, cognitive0,sensory0);
	 frailscore0=sum(physical0, nutritive0, cognitive0,sensory0);
	 if frailscore0 in (0,1) and domainmiss0 in (2,3) then frailscore0=.;
	 label  frailscore0='R frailty score pre procedure:0-4'
			domainmiss0='R number of frailty domains with missing value:0-4';
	 if frailscore0>=2 then frailstatus0=1;
	 else if 0<=frailscore0<2 then frailstatus0=0;
	 label frailstatus0='R frailty status pre procedure. 0.no frail, 1.frail';

	frailscore4g0=frailscore0;
	if frailscore0=4 then frailscore4g0=3;
	label frailscore4g0='R frailty score pre procedure:0-3+';

	label dizz0='R had persistent dizziness or lightheadedness pre procedure. 0.no, 1.yes'
          fallsnum0='R number of falls pre procedure'
          falls0='R fall in the last two years pre procedure. 0.no, 1.yes'
		  lifting0='R had Some Diff-Lift/carry 10 lbs pre procedure. 0.no, 1.yes'
          weight0='R weight in kg pre procedure'
          cogtot0='R cognition summary score pre procedure: 0-35'
          proxymem0='Proxy Memory rating pre procedure. 1.excellent, 2.very good, 3.good, 4.fair, 5.poor'
          iwrate0='Interviewer rating pre procedure. 1.No cog lim, 2.May have cog lim, can do iw, 3.Has cog lim, 4.Low TICS score'
          sight0='R eyesight pre procedure. 1.excellent, 2.very good, 3.good, 4.fair, 5.poor, 6.blind'
          hearing0='R hearing pre procedure. 1.excellent, 2.very good, 3.good, 4.fair, 5.poor'
		  proxy0='Whether Proxy Interview pre procedure. 1.proxy, 0.not proxy'

		  dizz1='R had persistent dizziness or lightheadedness post procedure. 0.no, 1.yes'
          fallsnum1='R number of falls post procedure'
          falls1='R fall in the last two years post procedure. 0.no, 1.yes'
		  lifting1='R had Some Diff-Lift/carry 10 lbs post procedure. 0.no, 1.yes'
          weight1='R weight in kg post procedure'
          cogtot1='R cognition summary score post procedure: 0-35'
          proxymem1='Proxy Memory rating post procedure. 1.excellent, 2.very good, 3.good, 4.fair, 5.poor'
          iwrate1='Interviewer rating post procedure. 1.No cog lim, 2.May have cog lim, can do iw, 3.Has cog lim, 4.Low TICS score'
          sight1='R eyesight post procedure. 1.excellent, 2.very good, 3.good, 4.fair, 5.poor, 6.blind'
          hearing1='R hearing post procedure. 1.excellent, 2.very good, 3.good, 4.fair, 5.poor'
		  proxy1='Whether Proxy Interview post procedure. 1.proxy, 0.not proxy';
run;
