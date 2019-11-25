# Charlson Comorbidity Index

Writer: Kathy Fung, MS

Language: SAS


```
data charlson_conditions ;
	set multimor.diagnosis_codes_ip_op;
	by hhidpn;
	array CONDITIONS (17) ANYMI CHF VASCUL1 CVD PULMON1 DEMENTIA PARALYS DIABET1 DIABET3 RENAL1 LIVER1 LIVER2 ANYULCER RHEUM AIDS MALIGNANCY METASTATIC;
	do i= 1 to 17;
	if FIRST.hhidpn then CONDITIONS(i)=0;
	retain CONDITIONS;
	end;
	array dxcode DGNSCD01-DGNSCD25;
	do over dxcode;
	dx_3=substr(dxcode,1,3);
	dx_4=substr(dxcode,1,4);
	/********** MYOCARDIAL INFARCTION WEIGHT=1 ****************/
	if dx_3='410' then do; ACUTEMI=1; ANYMI=1;end;
	if dx_3='412' then do; OLDMI=1; ANYMI=1; end;
	if ACUTEMI=. then ACUTEMI=0;
	if ANYMI=. then ANYMI=0;
	if OLDMI=. then OLDMI=0;
	/********** CHF ***** WEIGHT=1 ****************************/
	if dx_3='428' or '4254'<=dx_4<='4259' or dxcode in ('39891','40201','40211','40291','40401','40403','40411','40413','40491','40493') then CHF=1;
	if CHF=. then CHF=0;
	/*********** PERIPHERAL VASCULAR DISEASE ******* WEIGHT=1**/
	if dx_3 in ('441','440')|dx_4 in('0930','4373','4439','4471','5571','5579','V434','v434')|'4431'<=dx_4<='4439' then VASCUL1=1;
	if VASCUL1=. then VASCUL1=0;
	/********* CEREBROVASCULAR DISEASE ******* WEIGHT=1 *******/
	if '430'<=dx_3<='438'|dxcode='36234' then CVD=1;
	if CVD=. then CVD=0;
	/*********** COPD *********************** WEIGHT=1 ********/
	if '490'<=dx_3<='505'|dx_4 in ('4168','4169','5064','5081','5088') then PULMON1=1;
	if PULMON1=. then PULMON1=0;
	/******** DEMENTIA ****** WEIGHT=1 ***********************/
	if dx_3='290' | dx_4 in ('2941','3312') then DEMENTIA=1;
	if DEMENTIA=. then DEMENTIA=0;
	/********* PARALYSIS **************** WEIGHT=2 ************/
	if '342'<=dx_3<='343'|dx_4 in ('3341','3449')|'3440'<=dx_4<='3446' then PARALYS=1;
	if PARALYS=. then PARALYS=0;
	/******** DIABETES WITHOUT COMPLICATION ************* WEIGHT=1 *****************/
	if dx_4 in ('2508','2509')|'2500'<=dx_4<='2503' then DIABET1=1;
	if DIABET1=. then DIABET1=0;
	/********* DIABETES WITH COMPLICATION ****** WEIGHT=2 *********/
	if ('2504'<=dx_4<='2507') then DIABET3=1;
	if DIABET3=. then DIABET3=0;
	/********* CHRONIC RENAL FAILURE ******* WEIGHT=2 *********/
	if dxcode in ('40301','40311','40391','40402','40403','40412','40413','40492','40493') | dx_3 in('582','585','586','V56')
	  | ('5830'<=dx_4<='5837') |dx_4 in ('5880','V420','V451') then RENAL1=1;
	if RENAL1=. then RENAL1=0;
	/************** VARIOUS CIRRHODITES ******** WEIGHT=1 *****/
	if dxcode in ('07022','07023','07032','07033','07044','07054') | '570'<=dx_3<='571' | 
		dx_4 in ('0706','0709','5733','5734','5738','5739','V427') then LIVER1=1;
	if LIVER1=. then LIVER1=0;
	/************** MODERATE-SEVERE LIVER DISEASE *** WEIGHT=3*/
	if ('5722'<=dx_4<='5728')|('4560'<=dx_4<='4561')|dxcode in('4562 ','45620','45621') then LIVER2=1;
	if LIVER2=. then LIVER2=0;
	/*************** ULCERS ********** WEIGHT=1 ***************/
	if '531'<=dx_3<='534' then ANYULCER=1;
	if ANYULCER=. then ANYULCER=0;
	/*************** RHEUM ********** WEIGHT=1 ***************/
	if dx_3='725'|'7140'<=dx_4<='7142' |'7100'<=dx_4<='7104' | dx_4 in ('4465','7148') then RHEUM=1;
	if RHEUM=. then RHEUM=0;
	/*************** AIDS ********** WEIGHT=6 ***************/
	if '042'<=dx_3<='044' then AIDS=1;
	if AIDS=. then AIDS=0;
	/*************** ANY MALIGNANCY ** WEIGHT=2 **************/
	if ('140'<=dxcode<='1729')| ('174'<=dxcode<='1958')|('200'<=dxcode<='2089') | dx_4='2386' then MALIGNANCY=1;
	if MALIGNANCY=. then MALIGNANCY=0;
	/*************** METASTATIC SOLID TUMOR ********** WEIGHT=6 *****/
	if '196'<=dx_3<='199' then METASTATIC=1; 

	if METASTATIC=. then METASTATIC=0;
	end;
	if LAST.hhidpn;
	drop i dx_3 dx_4;
proc sort ;
by hhidpn;
run;


data Charlie_S;
	set charlson_conditions;
	Charlson=(ANYMI * 1) +
	(CHF * 1) +
	(VASCUL1 * 1) +
	(CVD * 1) +
	(PULMON1 * 1) +
	(DEMENTIA * 1) +
	(PARALYS * 2) +
	(DIABET1 * 1) +
	(DIABET3 * 2) +
	(RENAL1 * 2) +
	(LIVER1 * 1) +
	(LIVER2 * 3) +
	(ANYULCER * 1) +
	(RHEUM * 1) +
	(AIDS * 6) +
	(MALIGNANCY * 2) +
	(METASTATIC * 6);
run;
```

end code block
