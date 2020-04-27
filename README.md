# Introduction to UCSF Geriatrics Github Code Repository
This is how UCSF Geriatrics will use Github to construct and publish their analysis coding repositories.

Purpose:
- Create a valuable learning resource for our PI’s, MSTAR students, Fellows, and support staff who are increasingly invested in learning more about data analysis to become better researchers
- Adhere to transparency, reproducibility, and practice good science principles as we contribute more new knowledge into the greater scientific community

Criteria for GitHub Manuscript Repository:
-	code needs to be generalizable so please minimize hard coded lines so users can incorporate this into their own analyses
example: 
NHATS NSOC provide SAS and Stata Programming Codes have been made publicly available for this purpose: https://www.nhats.org/scripts/TechnicalDementiaClass.htm

-	remove instances of unique cases (especially if they refer to patient data)

-	for code used to generate figures/tables:
please format it as a stand-alone code file
within the top of the file, document name of statistician, publication citation, and which table/figure that this code corresponds to, what is the data source it points to, and note restriction, such as if data is unavailable for distribution due to data usage agreements
for major steps, if not already indicated, please have a comment indicated for each section of code (ie: what this step is for, how it fits into the analysis, how it manipulates the dataset)

-	Verify and check that the code runs correctly (same results as publication) before we upload it into GitHub





# Code Corresponding to Specific Manuscripts
## "Geriatric Syndromes and Atrial Fibrillation: Prevalence and Association with Anticoagulant use in a National Cohort of Older Americans" 
Sachin J. Shah, MD, MPH (1); Margaret C. Fang, MD, MPH (1); Sun Y. Jeon, MS, PhD (2); Steven Gregorich, PhD (3); Kenneth E. Covinsky, MD, MPH (2)

Division of Hospital Medicine, University of California, San Francisco, CA, USA
Division of Geriatrics, University of California, San Francisco, CA, USA
Division of General Internal Medicine, University of California, San Francisco, CA, USA

### [view manuscript](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6694766/) | [view repository](https://github.com/sachinjshah/AF-geriatric-syndrome-2014)

#### Repository of data cleaning and analytic files used to perform the analysis for the manuscirpt titled "Geriatric Syndromes and Atrial Fibrillation: Prevalence and Association with Anticoagulant use in a National Cohort of Older Americans"


## "A Novel Method for Identifying a Parsimonious and Accurate Predictive Model for Multiple Clinical Outcomes" 
L. Grisell Diaz-Ramirez MS,a,b Sei J. Lee MD,a,b Alexander K. Smith MD,a,b Siqi Gan MS,a,b W. John Boscardin PhDa,b

Division of Hospital Medicine, University of California, San Francisco, CA, USA
Division of Geriatrics, University of California, San Francisco, CA, USA
Division of General Internal Medicine, University of California, San Francisco, CA, USA

### manuscript(under review) | [view repository](https://github.com/sachinjshah/AF-geriatric-syndrome-2014)



# Code Used in Multiple Manuscripts
### [Charlson Comoribidty Index (for SAS)](https://github.com/UCSFGeriatrics/Manuscript-Code/blob/master/CharlsonComorbidity.md) - written by: Kathy Fung, MS

### [Cognitive measures (for SAS)](https://github.com/UCSFGeriatrics/Manuscript-Code/blob/master/CompositeMemoryScore.md) - written by Grisell Diaz-Ramirez, MS
###### Publications 
* Wu Q, Tchetgen Tchetgen EJ, Osypuk TL, White K, Mujahid M, Glymour MM. 2013. Combining Direct and Proxy Assessments to Reduce Attrition Bias in a Longitudinal Study. Alzheimer Dis. Assoc Disord 27, No. 3, pp: 207-212

* Whitlock EL, Diaz-Ramirez LG, Smith AK, Boscardin WJ, Avidan MS, Glymour MM. Cognitive Change After Cardiac Surgery Versus Cardiac Catheterization: A Population-Based Study. Ann Thorac Surg. 2019 Apr. 107(4):1119-1125. doi: 10.1016/j.athoracsur.2018.10.021. PMID: 30578068.

* Whitlock EL, Diaz-Ramirez LG, Glymour MM, Boscardin WJ, Covinsky KE, Smith AK. Association Between Persistent Pain and Memory Decline and Dementia in a Longitudinal Cohort of Elders. JAMA Intern Med. 2017 Aug 01; 177(8):1146-1153. doi: 10.1001/jamainternmed.2017.1622. PMID: 28586818.

### [ADL/IADL](https://github.com/UCSFGeriatrics/Manuscript-Code/blob/master/Derived-ADL-IADL.md) - written by Grisell Diaz-Ramirez, MS
###### Publications 
* Brown RT, Diaz-Ramirez LG, Boscardin WJ, Lee SJ, Williams BA, Steinman MA. Association of Functional Impairment in Middle Age With Hospitalization, Nursing Home Admission, and Death. JAMA Intern Med. 2019 Apr 8. doi:10.1001/jamainternmed.2019.0008. PMID: 30958504.

* Brown RT, Diaz-Ramirez LG, Boscardin WJ, Lee SJ, Steinman MA. Functional Impairment and Decline in Middle Age: A Cohort Study. Ann Intern Med. 2017 Dec 05; 167(11):761-768. doi: 10.7326/M17-0496. PMID: 29132150.

### [NHATS ADL/IADL](https://github.com/UCSFGeriatrics/Manuscript-Code/blob/master/NHATS_ADL_IADL.md)- written by Kanan Patel, MS
###### Publications
* Harrison KL, Ritchie CS, Patel K, Hunt LJ, Covinsky KE, Yaffe K, Smith AK. Care Settings and Clinical Characteristics of Older Adults with Moderately Severe Dementia. J Am Geriatr Soc. 2019; 67(9):1907-1912. PMID: 31389002

# Additional Resources
### Geriatric Research Algorithms & Statistical Programs (GRASP) - hosted by OAIC National Coordinating Center Site
https://www.peppercenter.org/public/grasp.cfm

GRASP, a curated list of statistical analysis programs useful to biostatisticians engaged in studies of human aging, is an Internet resource development project of the Claude D. Pepper Older Americans Independence Centers at Yale University, Duke University and Wake Forest University. Development of the content was originally supported by National Institute on Aging grant 2P30 AG021342-06S1 to Yale University and is currently supported by National Institute on Aging grant numbers U24AG05964 for the OAIC CCC and R33 AG045050 for the Aging Initiative. GRASP topics can include downloadable code, sample data, links to online resources and any number of associated documents.

# Cite UCSF Pepper Center 
NIH Funding Acknowledgment: This resource is made possible by NIH/ NIA funding for the UCSF Pepper Center via the grant P30AG044281.

