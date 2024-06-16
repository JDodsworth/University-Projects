# R Projects  <img src="https://github.com/JDodsworth/Univeristy-Projects/assets/171965237/2f69d19d-d0f3-436c-b154-3f08a01299fb" alt="R_icon" width="40">
The following are the list of all my R projects from university.

## Survival Analysis
This code was used in my undergraduate dissertation in Survival Analysis

### Aim
The aim of the following code is to apply survival analysis techniques to a real-world dataset. The dataset in question is on post-surgery breast cancer patients and fundamental questions on ‘which variables best explain the likelihood of recurrence or death’ and ‘whether parametric or non-parametric models best explain this likelihood’ are investigated and answered.

### The Rotterdam dataset explained using diagrams
- 2982 breast cancer patients had undergone surgery to remove their tumours
- data points were collected on 15 variables

| R code variable name | Variable name                        | Additional information                                                                                  |
|----------------------|--------------------------------------|--------------------------------------------------------------------------------------------------------|
| pid                  | Patient identifier                   |                                                                                                        |
| year                 | Year of surgery                      |                                                                                                        |
| age                  | Age at surgery                       |                                                                                                        |
| meno                 | Menopausal status                    | (0= premenopausal, 1= postmenopausal)                                                                  |
| size                 | Tumour size                          | A factor with levels (mm): <=20, 20-50, >50                                                            |
| grade                | Differentiation grade                | 1= cancer is slow-growing and less likely to spread                                                    |
|                      |                                      | 2= cancer with average growth and spread                                                               |
|                      |                                      | 3= cancer is faster-growing and more likely to spread                                                  |
| nodes                | Number of positive lymph nodes       | Positive (cancerous) lymph nodes are an indication that the cancer can spread around the body           |
| pgr                  | Progesterone receptors (fmol/l)      | Positive hormonal receptors detected in tumours imply that the body’s natural production of hormones might have an effect on the growth of cancerous cells |
| er                   | Oestrogen receptors (fmol/l)         |                                                                                                        |
| hormon               | Hormonal treatment                   | (0=no, 1=yes)                                                                                          |
| chemo                | Chemotherapy                         | (0=no, 1=yes)                                                                                          |
| rtime                | Days to relapse or last follow-up    |                                                                                                        |
| recur                | Relapse/Recurrence status            | (0= no relapse, 1= relapse). The individual has developed cancerous cells in either the same or a new site. |
| dtime                | Days to death or last follow-up      |                                                                                                        |
| death                | Death status                         | (0= alive, 1= dead)                                                                                    |


<img width="800" alt="Figure 1.2" src="https://github.com/JDodsworth/Univeristy-Projects/assets/171965237/baf4e27e-c4b1-4243-8a59-f066ff4ebfc5"> <img width="406" alt="Figure 2 3" src="https://github.com/JDodsworth/Univeristy-Projects/assets/171965237/206e889f-3937-4d3a-951e-54a222185aa9"> <img width="406" alt="Figure 2 4" src="https://github.com/JDodsworth/Univeristy-Projects/assets/171965237/abdf1037-cfd9-4138-9625-c48f5888c5f8">

### Censoring
Censoring is a very important feature of survival analysis: ‘A censored observation contains only partial information about the random variable of interest’ (Miller, G. 1981, pp.3). 

Below is a plot and table that clearly explains the prescence of censoring in the Rotterdam dataset.


<div class="container">
  <div class="image">
    <img src="https://github.com/JDodsworth/Univeristy-Projects/assets/171965237/f83e217b-6552-4885-be25-293ee5566bbb" alt="Time Plot">
  </div>
  <div class="table-container">
    <table>
        <tr>
          <th>Pid</th>
          <th>Patient No.</th>
          <th>Observations</th>
          <th>Explanation of Observations</th>
        </tr>
        <tr>
          <td>818</td>
          <td>1</td>
          <td>Recur=0<br>Death=0<br>rtime=dtime</td>
          <td>Patient did not relapse or die after treatment and <br> therefore are regarded as a survivor for both <br> recurrence and death.</td>
        </tr>
        <tr>
          <td>3005</td>
          <td>2</td>
          <td>Recur=0<br>Death=1<br>rtime=dtime</td>
          <td>Patient did not relapse yet died at the same time of <br> observations. This assumption is the patient died of old <br> age. The average age of death of these particular <br> patients is 75.5 years compared to the average age of <br> observations for the whole data set being 60.8 <br> and 62.2 years.</td>
        </tr>
        <tr>
          <td>41</td>
          <td>3</td>
          <td>Recur=0<br>Death=1<br>rtime&lt;dtime</td>
          <td>Patient did not relapse yet died after the last follow-up. <br> A reason for this is that death dates are updated on <br> medical health records after the study period has <br> ended. We have censored (unknown) information <br> about whether the patient relapsed between rtime <br> and dtime.</td>
        </tr>
        <tr>
          <td>1343</td>
          <td>4</td>
          <td>Recur=1<br>Death=0<br>rtime=dtime</td>
          <td>Patient relapsed yet did not die. Therefore, the patient is <br> regarded as a failure on relapse-free survival but <br> censored overall survival.</td>
        </tr>
        <tr>
          <td>1345</td>
          <td>5</td>
          <td>Recur=1<br>Death=0<br>rtime&lt;dtime</td>
          <td>Patient relapsed yet did not die and these two <br> observations occurred at the same time. An <br> explanation of this could be the patient was lost to <br> follow-up and the last observation was recurrence. <br> Therefore, the patient is regarded as a failure on <br> relapse-free survival but censored on overall survival.</td>
        </tr>
        <tr>
          <td>2421</td>
          <td>6</td>
          <td>Recur=1<br>Death=1<br>rtime=dtime</td>
          <td>Patient was observed to have relapsed and died at the <br> same time. The patient’s autopsy might have shown <br> death was caused by other cancerous cells that were <br> unknown to the patient and doctors.</td>
        </tr>
        <tr>
          <td>2024</td>
          <td>7</td>
          <td>Recur=1<br>Death=1<br>rtime&lt;dtime</td>
          <td>Patient relapsed and then later died. A clear indication <br> of the implication of relapse and a patient’s <br> survivability likelihoods. The patient is regarded as a failure <br> on both relapse-free and overall survival.</td>
        </tr>
      </table>
    </div>
</div>
