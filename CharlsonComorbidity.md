# Charlson Comorbidity Index

Writer: Kathy Fung, MS
Updated to include ICD 9 and ICD 10 codes by Bocheng Jing MS; 4/28/2020


Language: SAS


```
data DM_all_diag;

      set data.DM_VAIP_diag

           data.DM_VAOP_diag

           data.DM_medicare_ip_diag

           data.DM_medicare_op_diag;

 

proc sort ;

by numscrssn;

run;

 

proc sql;

      select count(distinct numscrssn), count(*) from _last_;

quit; **78630//7174710;

 

proc contents data=DM_all_diag;run;

 

data DM_all_diag1;

      set DM_all_diag;

      rename DGNSCD1=DX_1

DGNSCD2=DX_2

DGNSCD3=DX_3

DGNSCD4=DX_4

DGNSCD5=DX_5

DGNSCD6=DX_6

DGNSCD7=DX_7

DGNSCD8=DX_8

DGNSCD9=DX_9

DGNSCD10=DX_10

DGNSCD11=DX_11

DGNSCD12=DX_12

DGNSCD13=DX_13

DGNSCD14=DX_14

DGNSCD15=DX_15

DGNSCD16=DX_16

DGNSCD17=DX_17

DGNSCD18=DX_18

DGNSCD19=DX_19

DGNSCD20=DX_20

DGNSCD21=DX_21

DGNSCD22=DX_22

DGNSCD23=DX_23

DGNSCD24=DX_24

DGNSCD25=DX_25

DXF2=DX_26

DXF3=DX_27

DXF4=DX_28

DXF5=DX_29

DXF6=DX_30

DXF7=DX_31

DXF8=DX_32

DXF9=DX_33

DXF10=DX_34

DXF11=DX_35

DXF12=DX_36

DXF13=DX_37

DXLSF=DX_38

DXPRIME=DX_39

ICD_DGNS_CD1=DX_40

ICD_DGNS_CD2=DX_41

ICD_DGNS_CD3=DX_42

ICD_DGNS_CD4=DX_43

ICD_DGNS_CD5=DX_44

ICD_DGNS_CD6=DX_45

ICD_DGNS_CD7=DX_46

ICD_DGNS_CD8=DX_47

ICD_DGNS_CD9=DX_48

ICD_DGNS_CD10=DX_49

ICD_DGNS_CD11=DX_50

ICD_DGNS_CD12=DX_51

ICD_DGNS_CD13=DX_52

ICD_DGNS_CD14=DX_53

ICD_DGNS_CD15=DX_54;

run;

 

 

data condition_ICD10 ;

      set DM_all_diag1(keep=numscrssn DX_:);

      by numscrssn;

      array CONDITIONS (17) ICD10_ANYMI ICD10_CHF ICD10_VASCUL1 ICD10_CVD ICD10_PULMON1 ICD10_DEMENTIA ICD10_PARALYS ICD10_DIABET1 ICD10_DIABET3

                                   ICD10_RENAL1 ICD10_LIVER1 ICD10_LIVER2 ICD10_ANYULCER ICD10_RHEUM ICD10_AIDS ICD10_MALIGNANCY ICD10_METASTATIC;

      do i= 1 to 17;

      if FIRST.NUMSCRSSN then CONDITIONS(i)=0;

      retain CONDITIONS;

      end;

      array dxcode DX_1-DX_54;

      do over dxcode;

      dx_3=substr(dxcode,1,3);

      dx_4=substr(dxcode,1,4);

      /********** MYOCARDIAL INFARCTION WEIGHT=1 ****************/

      if dx_3 in ('I21','I22')|dx_4='I252' then ICD10_ANYMI=1;

      if ICD10_ANYMI=. then ICD10_ANYMI=0;

      /********** CHF ***** WEIGHT=1 ****************************/

      if dx_3 in ('I43','I50')|dx_4 in ('I099','I110','I130','I132',

'I255','I420','I425','I426','I427','I428','I429','P290') then ICD10_CHF=1;

      if ICD10_CHF=. then ICD10_CHF=0;

      /*********** PERIPHERAL VASCULAR DISEASE ******* WEIGHT=1**/

      if dx_3 in ('I70','I71')|dx_4 in('I731','I738','I739','I771',

  'I790','I792','K551','K558','K559','Z958','Z959') then ICD10_VASCUL1=1;

      if ICD10_VASCUL1=. then ICD10_VASCUL1=0;

      /********* CEREBROVASCULAR DISEASE ******* WEIGHT=1 *******/

      if dx_3 in ('G45','G46','I60','I61','I62','I63','I64','I65','I66','I67','I68','I69')|dx_4='H340' then ICD10_CVD=1;

      if ICD10_CVD=. then ICD10_CVD=0;

      /*********** COPD *********************** WEIGHT=1 ********/

      if dx_3 in ('J40','J41','J42','J43','J44','J45','J46','J47','J60','J61','J62','J63','J64','J65','J66','J67')|

        dx_4 in ('I278','I279','J684','J701','J703') then ICD10_PULMON1=1;

      if ICD10_PULMON1=. then ICD10_PULMON1=0;

      /******** DEMENTIA ****** WEIGHT=1 ***********************/

      if dx_3 in ('F00','F01','F02','F03','G30')|dx_4 in ('F051','G311') then ICD10_DEMENTIA=1;

      if ICD10_DEMENTIA=. then ICD10_DEMENTIA=0;

 

      /********* PARALYSIS **************** WEIGHT=2 ************/

      if dx_3 in ('G81','G82')|dx_4 in ('G041','G114','G801','G802',

      'G830','G831','G832','G833','G834','G839') then ICD10_PARALYS=1;

      if ICD10_PARALYS=. then ICD10_PARALYS=0;

      /******** DIABETES ************* WEIGHT=1 *****************/

      if dx_4 in ('E100','E101','E106','E108','E109','E110','E111','E116','E118','E119',

      'E120','E121','E126','E128','E129',

      'E130','E131','E136','E138','E139',

      'E140','E141','E146','E148','E149') then ICD10_DIABET1=1;

      if ICD10_DIABET1=. then ICD10_DIABET1=0;

      /********* DIABETES WITH SEQUELAE ****** WEIGHT=2 *********/

      if dx_4 in ('E102','E103','E104','E105','E107',

      'E112','E113','E114','E115','E117',

      'E122','E123','E124','E125','E127',

      'E132','E133','E134','E135','E137',

      'E142','E143','E144','E145','E147') then ICD10_DIABET3=1;

      if ICD10_DIABET3=. then ICD10_DIABET3=0;

      /********* CHRONIC RENAL FAILURE ******* WEIGHT=2 *********/

      if dx_3 in ('N18','N19')| dx_4 in ('N052','N053','N054','N055','N056','N057', 'N250','I120','I131','N032','N033',

      'N034','N035','N036','N037','Z490','Z491','Z492','Z940','Z992') then ICD10_RENAL1=1;

      if ICD10_RENAL1=. then ICD10_RENAL1=0;

 

      /************** VARIOUS CIRRHODITES MILD LIVER DISEASE ******** WEIGHT=1 *****/

      if dx_3 in ('B18','K73','K74') | dx_4 in('K700','K701','K702','K703','K709',

'K717','K713','K714','K715','K760','K762','K763','K764','K768','K769','Z944') then ICD10_LIVER1=1;

      if ICD10_LIVER1=. then ICD10_LIVER1=0;

      /************** MODERATE-SEVERE LIVER DISEASE *** WEIGHT=3*/

      if dx_4 in ('K704','K711','K721','K729','K765','K766','K767','I850','I859','I864','I982') then ICD10_LIVER2=1;

      if ICD10_LIVER2=. then ICD10_LIVER2=0;

      /***************PEPTIC ULCERS ********** WEIGHT=1 ***************/

      if dx_3 in ('K25','K26','K27','K28') then ICD10_ANYULCER=1;

      if ICD10_ANYULCER=. then ICD10_ANYULCER=0;

      /*************** RHEUM ********** WEIGHT=1 ***************/

      if dx_3 in ('M05','M32','M33','M34','M06')|dx_4 in ('M315','M351','M353','M360') then ICD10_RHEUM=1;

      if ICD10_RHEUM=. then ICD10_RHEUM=0;

      /*************** AIDS ********** WEIGHT=6 ***************/

      if dx_3 in ('B20','B21','B22','B24') then ICD10_AIDS=1;

      if ICD10_AIDS=. then ICD10_AIDS=0;

      /*************** ANY MALIGNANCY ** WEIGHT=2 **************/

      if dx_3 in ('C00','C01','C02','C03','C04','C05','C06','C07','C08','C09',

'C10','C11','C12','C13','C14','C15','C16','C17','C18','C19',

      'C20','C21','C22','C23','C24','C25','C26',

   'C30','C31','C32','C33','C34','C37','C38','C39',

   'C40','C41','C43','C45','C46','C47','C48','C49',

'C50','C51','C52','C53','C54','C55','C56','C57','C58',

'C60','C61','C62','C63','C64','C65','C66','C67','C68','C69',

      'C70','C71','C72','C73','C74','C75','C76',

      'C81','C82','C83','C84','C85','C88',

   'C90','C91','C92','C93','C94','C95','C96','C97') then ICD10_MALIGNANCY=1;

      if ICD10_MALIGNANCY=. then ICD10_MALIGNANCY=0;

      /*************** METASTATIC SOLID TUMOR ********** WEIGHT=6 *****/

      if dx_3 in ('C77','C78','C79','C80') then ICD10_METASTATIC=1;

      if ICD10_METASTATIC=. then ICD10_METASTATIC=0;

      end;

      if LAST.NUMSCRSSN;

      drop i dx_3 dx_4;

proc sort ;

by numscrssn;

run;

 

/*real time           4:14.55*/

proc sql;

      select count(distinct numscrssn), count(*) from _last_;

quit; **78630//78630;

 

 

data condition_ICD9 ;

      set DM_all_diag1(keep=numscrssn DX_:);

      by numscrssn;

      array CONDITIONS (17) ICD9_ANYMI ICD9_CHF ICD9_VASCUL1 ICD9_CVD ICD9_PULMON1 ICD9_DEMENTIA ICD9_PARALYS ICD9_DIABET1 ICD9_DIABET3 ICD9_RENAL1

                                   ICD9_LIVER1 ICD9_LIVER2 ICD9_ANYULCER ICD9_RHEUM ICD9_AIDS ICD9_MALIGNANCY ICD9_METASTATIC;

      do i= 1 to 17;

      if FIRST.NUMSCRSSN then CONDITIONS(i)=0;

      retain CONDITIONS;

      end;

      array dxcode DX_1-DX_54;

      do over dxcode;

      dx_3=substr(dxcode,1,3);

      dx_4=substr(dxcode,1,4);

      /********** MYOCARDIAL INFARCTION WEIGHT=1 ****************/

      if dx_3 in ('410','412') then ICD9_ANYMI=1;

      if ICD9_ANYMI=. then ICD9_ANYMI=0;

      /********** CHF ***** WEIGHT=1 ****************************/

      if dx_3='428' or '4254'<=dx_4<='4259' or dxcode in ('39891','40201','40211','40291','40401','40403','40411','40413','40491','40493') then ICD9_CHF=1;

      if ICD9_CHF=. then ICD9_CHF=0;

      /*********** PERIPHERAL VASCULAR DISEASE ******* WEIGHT=1**/

      if dx_3 in ('441','440')|dx_4 in('0930','4373','4439','4471','5571','5579','V434','v434')|'4431'<=dx_4<='4439' then ICD9_VASCUL1=1;

      if ICD9_VASCUL1=. then ICD9_VASCUL1=0;

      /********* CEREBROVASCULAR DISEASE ******* WEIGHT=1 *******/

      if '430'<=dx_3<='438'|dxcode='36234' then ICD9_CVD=1;

      if ICD9_CVD=. then ICD9_CVD=0;

      /*********** COPD *********************** WEIGHT=1 ********/

      if '490'<=dx_3<='505'|dx_4 in ('4168','4169','5064','5081','5088') then ICD9_PULMON1=1;

      if ICD9_PULMON1=. then ICD9_PULMON1=0;

      /******** DEMENTIA ****** WEIGHT=1 ***********************/

      if dx_3='290' | dx_4 in ('2941','3312') then ICD9_DEMENTIA=1;

      if ICD9_DEMENTIA=. then ICD9_DEMENTIA=0;

      /********* PARALYSIS **************** WEIGHT=2 ************/

      if '342'<=dx_3<='343'|dx_4 in ('3341','3449')|'3440'<=dx_4<='3446' then ICD9_PARALYS=1;

      if ICD9_PARALYS=. then ICD9_PARALYS=0;

      /******** DIABETES WITHOUT COMPLICATION ************* WEIGHT=1 *****************/

      if dx_4 in ('2508','2509')|'2500'<=dx_4<='2503' then ICD9_DIABET1=1;

      if ICD9_DIABET1=. then ICD9_DIABET1=0;

      /********* DIABETES WITH COMPLICATION ****** WEIGHT=2 *********/

      if ('2504'<=dx_4<='2507') then ICD9_DIABET3=1;

      if ICD9_DIABET3=. then ICD9_DIABET3=0;

      /********* CHRONIC RENAL FAILURE ******* WEIGHT=2 *********/

      if dxcode in ('40301','40311','40391','40402','40403','40412','40413','40492','40493') | dx_3 in('582','585','586','V56')

        | ('5830'<=dx_4<='5837') |dx_4 in ('5880','V420','V451') then ICD9_RENAL1=1;

      if ICD9_RENAL1=. then ICD9_RENAL1=0;

      /************** VARIOUS CIRRHODITES ******** WEIGHT=1 *****/

      if dxcode in ('07022','07023','07032','07033','07044','07054') | '570'<=dx_3<='571' |

           dx_4 in ('0706','0709','5733','5734','5738','5739','V427') then ICD9_LIVER1=1;

      if ICD9_LIVER1=. then ICD9_LIVER1=0;

      /************** MODERATE-SEVERE LIVER DISEASE *** WEIGHT=3*/

      if ('5722'<=dx_4<='5728')|('4560'<=dx_4<='4561')|dxcode in('4562 ','45620','45621') then ICD9_LIVER2=1;

      if ICD9_LIVER2=. then ICD9_LIVER2=0;

      /*************** ULCERS ********** WEIGHT=1 ***************/

      if '531'<=dx_3<='534' then ICD9_ANYULCER=1;

      if ICD9_ANYULCER=. then ICD9_ANYULCER=0;

      /*************** RHEUM ********** WEIGHT=1 ***************/

      if dx_3='725'|'7140'<=dx_4<='7142' |'7100'<=dx_4<='7104' | dx_4 in ('4465','7148') then ICD9_RHEUM=1;

      if ICD9_RHEUM=. then ICD9_RHEUM=0;

      /*************** AIDS ********** WEIGHT=6 ***************/

      if '042'<=dx_3<='044' then ICD9_AIDS=1;

      if ICD9_AIDS=. then ICD9_AIDS=0;

      /*************** ANY MALIGNANCY ** WEIGHT=2 **************/

      if ('140'<=dxcode<='1729')| ('174'<=dxcode<='1958')|('200'<=dxcode<='2089') | dx_4='2386' then ICD9_MALIGNANCY=1;

      if ICD9_MALIGNANCY=. then ICD9_MALIGNANCY=0;

      /*************** METASTATIC SOLID TUMOR ********** WEIGHT=6 *****/

      if '196'<=dx_3<='199' then ICD9_METASTATIC=1;

      if ICD9_METASTATIC=. then ICD9_METASTATIC=0;

      end;

      if LAST.NUMSCRSSN;

      drop i dx_3 dx_4;

proc sort ;

by numscrssn;

run;

 

proc sql;

      select count(distinct numscrssn), count(*) from _last_;

quit; **78630//78630;

 

proc freq data=condition_ICD9;

      table ICD9_ANYMI ICD9_CHF ICD9_VASCUL1 ICD9_CVD ICD9_PULMON1 ICD9_DEMENTIA ICD9_PARALYS ICD9_DIABET1 ICD9_DIABET3 ICD9_RENAL1

                                   ICD9_LIVER1 ICD9_LIVER2 ICD9_ANYULCER ICD9_RHEUM ICD9_AIDS ICD9_MALIGNANCY ICD9_METASTATIC;

run;

proc freq data=condition_ICD10;

      table ICD10_ANYMI ICD10_CHF ICD10_VASCUL1 ICD10_CVD ICD10_PULMON1 ICD10_DEMENTIA ICD10_PARALYS ICD10_DIABET1 ICD10_DIABET3 ICD10_RENAL1

                                   ICD10_LIVER1 ICD10_LIVER2 ICD10_ANYULCER ICD10_RHEUM ICD10_AIDS ICD10_MALIGNANCY ICD10_METASTATIC;

run;

 

proc sort data=data.cohort_8 out=cohort(keep=numscrssn);by numscrssn;

data conditions;

      merge cohort condition_ICD9(keep=numscrssn ICD9:) condition_ICD10(keep=numscrssn ICD10:);

      by numscrssn;

      array cond _numeric;

      do over cond;

           if cond=. then cond=0;

      end;

      if ICD9_ANYMI=1 or ICD10_ANYMI=1 then ANYMI=1;else ANYMI=0;

      if ICD9_CHF=1 or ICD10_CHF=1 then CHF=1;else CHF=0;

      if ICD9_VASCUL1=1 or ICD10_VASCUL1=1 then VASCUL1=1;else VASCUL1=0;

      if ICD9_CVD=1 or ICD10_CVD=1 then CVD=1;else CVD=0;

      if ICD9_PULMON1=1 or ICD10_PULMON1=1 then PULMON1=1;else PULMON1=0;

      if ICD9_DEMENTIA=1 or ICD10_DEMENTIA=1 then DEMENTIA=1;else DEMENTIA=0;

      if ICD9_PARALYS=1 or ICD10_PARALYS=1 then PARALYS=1;else PARALYS=0;

      if ICD9_DIABET1=1 or ICD10_DIABET1=1 then DIABET1=1;else DIABET1=0;

      if ICD9_DIABET3=1 or ICD10_DIABET3=1 then DIABET3=1;else DIABET3=0;

      if ICD9_RENAL1=1 or ICD10_RENAL1=1 then RENAL1=1;else RENAL1=0;

      if ICD9_LIVER1=1 or ICD10_LIVER1=1 then LIVER1=1;else LIVER1=0;

      if ICD9_LIVER2=1 or ICD10_LIVER2=1 then LIVER2=1;else LIVER2=0;

      if ICD9_ANYULCER=1 or ICD10_ANYULCER=1 then ANYULCER=1;else ANYULCER=0;

      if ICD9_RHEUM=1 or ICD10_RHEUM=1 then RHEUM=1;else RHEUM=0;

      if ICD9_AIDS=1 or ICD10_AIDS=1 then AIDS=1;else AIDS=0;

      if ICD9_MALIGNANCY=1 or ICD10_MALIGNANCY=1 then MALIGNANCY=1;else MALIGNANCY=0;

      if ICD9_METASTATIC=1 or ICD10_METASTATIC=1 then METASTATIC=1;else METASTATIC=0;

run;

 

 

data Charlie_S;

      set conditions;

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

 

proc freq data=Charlie_S;table Charlson;run;

 

 

proc sql;

      create table data.DM_charlson as

      select A.*, B.charlson,

                      B.ANYMI as MI,

                      B.CHF,

                      B.VASCUL1 as PVD,

                      B.CVD,

                      B.PULMON1 as CPD,

                      B.Dementia,

                      B.PARALYS as HP,

                      B.Diabet1 as DMWTCC,

                      B.Diabet3 as DMWCC,

                      B.RENAL1 as Renal,

                      B.Liver1 as MLD,

                      B.Liver2 as MSLD,

                      B.Anyulcer as PUD,

                      B.RHEUM as RD,

                      B.AIDS,

                      B.Malignancy,

                      B.Metastatic

      from data.DM_demo_income_location A inner join charlie_S B on A.numscrssn=B.numscrssn;

quit;

 

 


proc freq data=data.DM_charlson;

      table charlson MI CHF PVD CVD CPD Dementia HP DMWTCC DMWCC RENAL MLD MSLD PUD RD AIDS Malignancy MEtastatic;

run;
```


