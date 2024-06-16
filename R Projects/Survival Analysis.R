# Section 0: Packages and dataset
library(survival) # main package that includes statistical functions and dataset
library(sjlabelled) # removal of labels on variables within the dataset
library(dplyr) # creating dataframes more easily
library(tidyr) # creating dataframes more easily
library(ggplot2) # creating plots efficiently
library(tibble) # creating dataframes more easily
library(ggsurvfit) # survival distributions
library(stats4) # mle function

# Initialise dataset into the environment
data(cancer, package= "survival")
force(rotterdam)

# Create Survival times (relapse)
rotterdam$rtime<-as.numeric(rotterdam$rtime)
rotterdam$rtime_years<-rotterdam$rtime/365
rotterdam$rfs_status<-Surv(rotterdam$rtime_years, rotterdam$recur)

# Create Survival times (death)
rotterdam$dtime<-as.numeric(rotterdam$dtime)
rotterdam$dtime_years<-rotterdam$dtime/365
rotterdam$os_status<-Surv(rotterdam$dtime_years, rotterdam$death)

# Section 1: Understanding the dataset using graphs

# Figure 1.1: Bar chart

# convert death variable from haven labelled to numeric 
rotterdam$death2<-sjlabelled::remove_label(rotterdam$death)
rotterdam$death<-sjlabelled::remove_all_labels(rotterdam$death)
rotterdam$death<-sjlabelled::as_numeric(rotterdam$death2)

# create two new variables 
rotterdam$event<-ifelse(rotterdam$recur==0 & rotterdam$death2==0,'0.0',
                        ifelse(rotterdam$recur==0 & rotterdam$death2==1,'0.1',
                               ifelse(rotterdam$recur==1 & rotterdam$death2==0,
                                      '1.0','1.1')))
rotterdam$diffrtimedtime<-ifelse(rotterdam$dtime-rotterdam$rtime==0,'no','yes')

# create a new dataframe
rotterdam2<- rotterdam %>% group_by(event,diffrtimedtime) %>% 
  summarise(frequency = n())

# create bar chart
ggplot(rotterdam2, aes(x = event, y = frequency, fill = diffrtimedtime))+
  geom_bar(stat = "identity", position = "stack")+
  geom_text(aes(label = frequency), position = position_stack(vjust=0.5))+
  scale_fill_manual(values=c("firebrick3","steelblue"))+
  theme_minimal()+
  labs(title="A bar chart showing the number of patients who had differing
      statuses", x="Status (recurrence status.death status)", y="Frequency",
      fill="Difference in rtime and dtime", caption="Figure 1.1")

# Figure 1.2 and 1.3: Histogram

# Create a histogram for rtime 

ggplot(rotterdam, aes(x = rtime_years))+
  geom_histogram(fill = "cornflowerblue", color = "white", bins = 20,
                 binwidth = 1)+
  theme_minimal()+
  labs(title="A histogram showing the number of patients, who either
       experienced their last follow up or reccurence, at one year time
       intervals", x="rtime (years)", y="Frequency", caption="Figure 1.2")+
  geom_vline(xintercept = mean(rotterdam$rtime_years), linetype = "dashed")+
  annotate("text", mean(rotterdam$rtime_years)-1,400, label = "Mean\n5.75")

# Create a histogram for dtime
ggplot(rotterdam, aes(x = dtime_years))+
  geom_histogram(fill = "indianred", color = "white", bins = 20, binwidth = 1)+
  theme_minimal()+
  labs(title="A histogram showing the number of patients, who either experienced
       their last follow up or death, at one year time intervals",
       x="dtime (years)", y="Frequency", caption="Figure 1.3")+
  geom_vline(xintercept = mean(rotterdam$dtime_years), linetype = "dashed")+
  ggplot2::annotate("text", mean(rotterdam$dtime_years)-1,400,
                    label = "Mean\n7.14")

#Figure 1.4, 1.5, 1.6: Boxplots

#create a node outlier variable
nodeoutliers<-rotterdam$nodes[!(rotterdam$nodes<10)]

#create boxplots
boxplot(nodeoutliers, ylab = "Number of Cancerous Nodes",
        main = "Boxplot of the outliers of the number of cancerous nodes
        in patients", caption="figure 1.6")
boxplot(rotterdam$nodes, ylab = "Number of Cancerous Nodes",
        main = "Boxplot of the number of\n cancerous nodes in patients",
        caption="figure 1.5")
boxplot(rotterdam$age, ylab = "Age (years)",
        main = "Boxplot of the age of patients", caption="figure 1.4")

# Section 2: Censoring

# Figure 2.1: Time Plot

#create data frame to produce time plot for censoring

#creating variables
Patient<-1:7
year<-c(1978,1985,1988,1988,1991,1989,1985)
rtime_years<-c(16.8,1.59,3.75,11.2,3.18,0.97,2.64)
dtime_years<-c(16.8,1.59,6.09,11.2,6.35,0.97,5.65)
rtime_year<-year+rtime_years
dtime_year<-year+dtime_years

# Create new dataset
Rotterdamtimeplotdata<-tibble(Patient,year,rtime_year,dtime_year)
Rotterdamtimeplotdata<-gather(Rotterdamtimeplotdata, key="event_type", 
                              value="event_time",year:dtime_year)
Rotterdamtimeplotdata$event_type<-c("surgery","surgery","surgery","surgery",
                                    "surgery","surgery","surgery",
                                    "last follow up","death","last follow up",
                                    "recurrence","recurrence","recurrence",
                                    "recurrence","last follow up","death",
                                    "death","recurrence","last follow up",
                                    "death","death")

# Create plot
ggplot(Rotterdamtimeplotdata, aes(y = Patient, x = event_time))+
  geom_point(aes(shape=event_type) )+
  scale_shape_manual(values=c(4,3,0,20))+
  scale_size_manual(values = c(2,2,2,1))+
  theme_minimal()+theme(legend.position = 'top')+
  geom_line(aes(group = Patient),linetype = 'dashed')+
  geom_segment(aes(x=1988,y=3,xend =rtime_year[3],yend=3))+
  geom_segment(aes(x=1991,y=5,xend =rtime_year[5],yend=5))+
  geom_segment(aes(x=1985,y=7,xend =rtime_year[7],yend=7))+
  geom_line(aes(group = Patient),linetype = 'dashed')+
  geom_segment(aes(x=1978,y=1,xend =dtime_year[1],yend=1))+
  geom_segment(aes(x=1985,y=2,xend =dtime_year[2],yend=2))+
  geom_segment(aes(x=1988,y=4,xend =dtime_year[4],yend=4))+
  geom_segment(aes(x=1989,y=6,xend =dtime_year[6],yend=6))+
  labs(title="Time plot showing all possible observations of varying patients",
       y="Patient No.", x="Time of observation",shape="Type of observation")+
  scale_y_continuous(breaks = seq(1, 7, 1),limits=c(1, 7))+
  scale_x_continuous(limits = c(1978,2000))

# Section 3: Kaplan-Meier Estimates

# RFS Distributions (KP Estimates)
sfit_rfs=survfit2(rfs_status ~ 1, data=rotterdam)
ggsurvfit(sfit_rfs, color = "cornflowerblue")+
  add_confidence_interval(fill = "cornflowerblue")+
  add_quantile()+
  scale_ggsurvfit()+
  labs(title = "Relapse-Free Survival Distribution",
       subtitle = "Kaplan-Meier Estimates with confidence interval and median",
       x = "Time (years)", caption = "Figure 3.1")+
  annotate("text",8.15,0.01,label="median = 8.171")

# OS Distributions (KP Estimates)
sfit_os=survfit2(os_status ~ 1, data=rotterdam)
ggsurvfit(sfit_os, color = "indianred")+
  add_confidence_interval(fill = "indianred")+add_quantile()+scale_ggsurvfit()+
  labs(title = "Overall (Death) Survival Distribution",
       subtitle = "Kaplan-Meier Estimates with confidence interval and median",
       x = "Time (years)", caption = "Figure 3.2")+
  annotate("text",8.15,0.01,label="median = 8.171")

# Section 4: Log rank tests

# Creating plots and log rank tests to compare groups who possess different
# characteristics such as grade and size of tumour

# Create new variables RFS
sfit_rfs_size<-survfit(Surv(rotterdam$rtime_years,rotterdam$recur)~ size,
                       data = rotterdam)
sfit_rfs_grade<-survfit(Surv(rotterdam$rtime_years,rotterdam$recur)~ grade,
                        data = rotterdam)

#create new variables OS
sfit_os_size<-survfit(Surv(rotterdam$dtime_years,rotterdam$death)~ size,
                      data = rotterdam)
sfit_os_grade<-survfit(Surv(rotterdam$dtime_years,rotterdam$death)~ grade,
                       data = rotterdam)

#create plots RFS
ggsurvfit(sfit_rfs_grade)+add_confidence_interval()+
  labs(title = "Relapse-Free Survival Distrubtion",
       subtitle = "patients with differing tumour grade ratings",
       x = "Time (years)", caption = "Figure 4.1")+
  annotate("text",10,0.01,
           label="Chisq= 68.2  on 1 degrees of freedom, p= <2e-16 ")
ggsurvfit(sfit_rfs_size)+add_confidence_interval()+
  labs(title = "Relapse-Free Survival Distrubtion",
       subtitle = "patients with differing tumour sizes",
       x = "Time (years)", caption = "Figure 4.2")+
  annotate("text",10,0.01,
           label="Chisq= 202  on 2 degrees of freedom, p= <2e-16 ")

#create plots OS
ggsurvfit(sfit_os_grade)+add_confidence_interval()+
  labs(title = "Overall(Death) Survival Distrubtion",
       subtitle = "patients with differing tumour grade ratings",
       x = "Time (years)", caption = "Figure 4.3")+
  annotate("text",10,0.01,
           label=" Chisq= 54.2  on 1 degrees of freedom, p= 2e-13")
ggsurvfit(sfit_os_size)+add_confidence_interval()+
  labs(title = "Overall(Death) Survival Distrubtion",
       subtitle = "patients with differing tumour sizes",
       x = "Time (years)", caption = "Figure 4.4")+
  annotate("text",10,0.01,
           label="Chisq= 281  on 2 degrees of freedom, p= <2e-16")

#create tests RFS
survdiff(Surv(rotterdam$rtime_years,rotterdam$recur)~ size, data = rotterdam)
survdiff(Surv(rotterdam$rtime_years,rotterdam$recur)~ grade, data = rotterdam)

#create tests OS
survdiff(Surv(rotterdam$dtime_years,rotterdam$death)~ grade, data = rotterdam)
survdiff(Surv(rotterdam$dtime_years,rotterdam$death)~ size, data = rotterdam)

# Section 5: Parametric estimations of survival time

#Exponential RFS
sfit_rfs<-tidy_survfit(sfit_rfs)
sfit_rfs$minuslog.KMestimate<--log(sfit_rfs$estimate)
ggplot(sfit_rfs, aes(x=time,y=minuslog.KMestimate))+
  geom_point(shape=1, col='blue', size=0.5)+theme_minimal()+
  geom_smooth(method=lm,  col='black', linetype='dashed')+
  labs(title = 'Exponential Distribution of Relaps-Free Survival',
       x = 'Time (years)', y = 'y=-logS(t)', caption = 'Figure 5.1')+
  annotate("text",10,0.01,label="lambda = 0.0701972")
summary(lm(minuslog.KMestimate~time, data = sfit_rfs))

#Exponential OS
sfit_os<-tidy_survfit(sfit_os)
sfit_os$minuslog.KMestimate<--log(sfit_os$estimate)
ggplot(sfit_os, aes(x=time,y=minuslog.KMestimate))+
  geom_point(shape=1, col='red', size=0.5)+theme_minimal()+
  geom_smooth(method=lm, col='black', linetype='dashed')+
  labs(title = 'Exponential Distribution of Overall(Death) Survival',
       x = 'Time (years)', y = 'y=-logS(t)', caption = 'Figure 5.2')+
  annotate("text",10,0.01,label="lambda = 0.0663962")
summary(lm(minuslog.KMestimate~time, data = sfit_os))

# Weibull RFS
sfit_rfs$weibull.y<-log(-log(sfit_rfs$estimate))
sfit_rfs$weibull.x<-log(sfit_rfs$time)
ggplot(sfit_rfs, aes(x=weibull.x,y=weibull.y))+
  geom_point(shape=1, col='green', size=0.5)+theme_minimal()+
  geom_smooth(method=lm, col='black', linetype='dashed')+
  labs(title = 'Weibull Distribution of Relaps-Free Survival', x = 'x=logt',
       y = 'y=log[-logS(t)]', caption = 'Figure 5.3')+
  annotate("text",0,-8,label="lambda = 0.082274 and gamma = 1.057098")
summary(lm(weibull.y[-c(1,2)]~weibull.x[-c(1,2)], data = sfit_rfs))

# Weibull OS
sfit_os$weibull.y<-log(-log(sfit_os$estimate))
sfit_os$weibull.x<-log(sfit_os$time)
ggplot(sfit.os, aes(x=weibull.x,y=weibull.y))+
  geom_point(shape=1, col='purple', size=0.5)+
  theme_minimal()+geom_smooth(method=lm, col='black', linetype='dashed')+
  labs(title = 'Weibull Distribution of Overall(Death) Survival', x = 'x=logt',
       y = 'y=log[-logS(t)]', caption = 'Figure 5.4')+
  annotate("text",0,-8,label="lambda = 0.027619 and gamma = 1.376376")
summary(lm(weibull.y[-c(1,2)]~weibull.x[-c(1,2)], data = sfit_os))

# Section 6: MLEs

# We use Rotterdam2 dataframe created for the production of the bar chart

# Exponential RFS 
r_rfs<-sum(rotterdam2$frequency[c(4:7)])
Yi<-rotterdam$rtime_years         
nll_rfs_exp<-function(lambda){ -(r_rfs*log(lambda)-lambda*sum(Yi))}
mle_rfs_exp<-mle(minuslog=nll_rfs_exp, start= list(lambda=0.07))
summary(mle_rfs_exp)

# Exponential OS
r_os<-sum(rotterdam2$frequency[c(2,3,6,7)])
nll_os_exp<-function(lambda){ -(r_os*log(lambda)-lambda*sum(Yi))}
mle_os_exp<-mle(minuslog=nll_os_exp, start= list(lambda=0.07))
summary(mle_os_exp)

# Weibull RFS
deltai_rfs<-rotterdam$recur
nll_rfs_wei<-function(lambda,gamma){ -(r_rfs*(log(lambda)+log(gamma))+(gamma-1)*
                                         sum(deltai_rfs*log(Yi))-lambda*
                                         sum((Yi)^gamma))}
mle_rfs_wei<-mle(minuslog=nll_rfs_wei, start= list(lambda=exp(-2.5), gamma=1))
summary(mle_rfs_wei)

# Weibull OS
deltai_os<-rotterdam$death
nll_os_wei<-function(lambda,gamma){ -(r_os*(log(lambda)+log(gamma))+(gamma-1)*
                                        sum(deltai_os*log(Yi))-lambda*
                                        sum((Yi)^gamma))}
mle_os_wei<-mle(minuslog=nll_os_wei, start= list(lambda=exp(-2.5), gamma=1))
summary(mle_os_wei)

# Section 7: Major Analysis

# Major analysis on Rotterdam

# analysis meno status on rfs 
rotterdam$meno<-remove_all_labels(rotterdam$meno)
rotterdam$meno<-as_character(rotterdam$meno)
sfit_rfs_meno<-survfit(Surv(rotterdam$rtime_years,rotterdam$recur)~ meno,
                       data = rotterdam)
ggsurvfit(sfit_rfs_meno)+add_confidence_interval()+
  labs(title = "Relapse-Free Survival Distrubtion",
       subtitle = "patients with different menopausal status",
       x = "Time (years)", caption = "Figure 7.1")+
  annotate("text",10,0.01,label="Chisq= 0.8  on 1 degrees of freedom, p= 0.4")
survdiff(Surv(rotterdam$rtime_years,rotterdam$recur)~ meno, data = rotterdam)

# analysis meno status on os
sfit_os_meno<-survfit(Surv(rotterdam$dtime_years,rotterdam$death)~ meno,
                      data = rotterdam)
ggsurvfit(sfit_os_meno)+add_confidence_interval()+
  labs(title = "Overall(Death) Survival Distrubtion",
       subtitle = "patients with different menopausal status",
       x = "Time (years)", caption = "Figure 7.2")+
  annotate("text",10,0.01,
           label=" Chisq= 55.1  on 1 degrees of freedom, p= 1e-13")
survdiff(Surv(rotterdam$dtime_years,rotterdam$death)~ meno,
         data = rotterdam)


mean(rotterdam$age[rotterdam$meno==0])
mean(rotterdam$age[rotterdam$meno==1])

# creating null models for rfs and os...
M0_rfs<-coxph(Surv(rtime_years,recur)~1, ties="breslow", data=rotterdam)
M0_os<-coxph(Surv(dtime_years,death)~1, ties="breslow", data=rotterdam)

# analysis age on rfs
M1_rfs_age<-coxph(Surv(rtime_years,recur)~age, ties="breslow", data=rotterdam)
M1_rfs_age
rotterdam$agefactor<-ifelse(rotterdam$age<48,'<48',ifelse(rotterdam$age>60,
                                                          '>60','48-60'))
rotterdam$agefactor<-as_factor(rotterdam$agefactor)
summary(rotterdam$agefactor)
sfit_rfs_age<-survfit(Surv(rotterdam$rtime_years,rotterdam$recur)~ agefactor,
                      data = rotterdam)
ggsurvfit(sfit_rfs_age)+add_confidence_interval()+
  labs(title = "Relapse-free Survival Distrubtion",
       subtitle = "patients split into different age groups",
       x = "Time (years)", caption = "Figure 7.3")+
  annotate("text",10,0.01,label="Chisq= 2.4  on 2 degrees of freedom, p= 0.3")
survdiff(Surv(rotterdam$rtime_years,rotterdam$recur)~ agefactor,
         data = rotterdam)
M1.rfs.agefactor<-coxph(Surv(rtime_years,recur)~agefactor, ties="breslow",
                        data=rotterdam)
M1.rfs.agefactor

# analysis age on os...
sfit_os_age<-survfit(Surv(rotterdam$dtime_years,rotterdam$death)~ agefactor,
                     data = rotterdam)
ggsurvfit(sfit_os_age)+add_confidence_interval()+
  labs(title = "Overall Survival Distrubtion",
       subtitle = "patients split into different age groups",
       x = "Time (years)", caption = "Figure 7.4")+
  annotate("text",10,0.01,label="54.9  on 2 degrees of freedom, p= 1e-12")
survdiff(Surv(dtime_years,death)~ agefactor, data = rotterdam)
# evidence of non-linearity

# determining appropriate function to explain the effect of age on death 
M1_os_age<-coxph(Surv(dtime_years,death)~age, ties="breslow", data=rotterdam)
M1_os_agefactor<-coxph(Surv(dtime_years,death)~agefactor, ties="breslow",
                       data=rotterdam)
rotterdam$agesquared<-(rotterdam$age)^2
M1_os_agesquared<-coxph(Surv(dtime_years,death)~agesquared, ties="breslow",
                        data=rotterdam)
rotterdam$agecubed<-(rotterdam$age)^3
M1_os_agecubed<-coxph(Surv(dtime_years,death)~agecubed, ties="breslow",
                      data=rotterdam)
rotterdam$agequad<-(rotterdam$age)^4
M1_os_agequad<-coxph(Surv(dtime_years,death)~agequad, ties="breslow",
                     data=rotterdam)
rotterdam$age5<-(rotterdam$age)^5
M1_os_age5<-coxph(Surv(dtime_years,death)~age5, ties="breslow",
                  data=rotterdam)
rotterdam$age6<-(rotterdam$age)^6
M1_os_age6<-coxph(Surv(dtime_years,death)~age6, ties="breslow",
                  data=rotterdam)
# The difference between age5 and age6 is not signficant within Chisquared
# distribution

# Prog & Oes Analysis

# Positive and Negative Pgr and Er effects on survival
rotterdam$pgr_status<-ifelse(rotterdam$pgr==0,'-','+')
rotterdam$er_status<-ifelse(rotterdam$er==0,'-','+')

# rfs
sfit_rfs_pgr<-survfit(Surv(rotterdam$rtime_years,rotterdam$recur)~ pgr_status,
                      data = rotterdam)
sfit_rfs_er<-survfit(Surv(rotterdam$rtime_years,rotterdam$recur)~ er_status,
                     data = rotterdam)
ggsurvfit(sfit_rfs_pgr)+add_confidence_interval()+
  labs(title = "Relapse-Free Survival Distrubtion",
       subtitle = "patients with different progesterone statuses",
       x = "Time (years)", caption = "Figure 7.5")+
  annotate("text",10,0.01,label="Chisq= 8.3  on 1 degrees of freedom, p= 0.004")
ggsurvfit(sfit_rfs_er)+add_confidence_interval()+
  labs(title = "Relapse-Free Survival Distrubtion",
       subtitle = "patients with different oestrogen statuses",
       x = "Time (years)", caption = "Figure 7.6")+
  annotate("text",10,0.01,label="Chisq= 0.6  on 1 degrees of freedom, p= 0.4")
survdiff(Surv(rotterdam$rtime_years,rotterdam$recur)~ pgr_status,
         data = rotterdam)
survdiff(Surv(rotterdam$rtime_years,rotterdam$recur)~ er_status,
         data = rotterdam)

# os
sfit_os_pgr<-survfit(Surv(rotterdam$dtime_years,rotterdam$death)~ pgr_status,
                     data = rotterdam)
sfit_os_er<-survfit(Surv(rotterdam$dtime_years,rotterdam$death)~ er_status,
                    data = rotterdam)
ggsurvfit(sfit_os_pgr)+add_confidence_interval()+
  labs(title = "Overall(Death) Survival Distrubtion",
       subtitle = "patients with different progesterone statuses",
       x = "Time (years)", caption = "Figure 7.7")+
  annotate("text",10,0.01,
           label=" Chisq= 18.1  on 1 degrees of freedom, p= 2e-05")
ggsurvfit(sfit_os_er)+add_confidence_interval()+
  labs(title = "Overall(Death) Distrubtion",
       subtitle = "patients with different oestrogen statuses",
       x = "Time (years)", caption = "Figure 7.8")+
  annotate("text",10,0.01,
           label=" Chisq= 6.9  on 1 degrees of freedom, p= 0.009")
survdiff(Surv(rotterdam$dtime_years,rotterdam$death)~ pgr_status,
         data = rotterdam)
survdiff(Surv(rotterdam$dtime_years,rotterdam$death)~ er_status,
         data = rotterdam)


# analysis of positive pgr on survival
rotterdam_pgr_status<-filter(rotterdam, pgr_status=='+')
rotterdam_pgr_status$pgrfactor<-ifelse(rotterdam_pgr_status$pgr<50,'<50',
                                       ifelse(rotterdam_pgr_status$pgr>50 &
                                                rotterdam_pgr_status$pgr<100,
                                              '50-100',
                                              ifelse(
                                                rotterdam_pgr_status$pgr>100 &
                                                  rotterdam_pgr_status$pgr<300,
                                                '100-300','>300')))
rotterdam_pgr_status$pgrfactor2<-ifelse(rotterdam_pgr_status$pgr<50,'<50','>50')

#rfs
sfit_rfs_pgrfactor<-survfit(Surv(rtime_years,recur)~ pgrfactor,
                            data = rotterdam_pgr_status)
ggsurvfit(sfit_rfs_pgrfactor)
survdiff(Surv(rtime_years,recur)~ pgrfactor, data = rotterdam_pgr_status)
sfit_rfs_pgrfactor2<-survfit(Surv(rtime_years,recur)~ pgrfactor2,
                             data = rotterdam_pgr_status)
ggsurvfit(sfit_rfs_pgrfactor2)
survdiff(Surv(rtime_years,recur)~ pgrfactor2, data = rotterdam_pgr_status)

# chosen two positive classes 
sfit_rfs_pgrfactor2<-survfit(Surv(rtime_years,recur)~ pgrfactor,
                             data = rotterdam)
ggsurvfit(sfit_rfs_pgrfactor2)+add_confidence_interval()+
  labs(title = "Relapse-free Survival Distrubtion",
       subtitle = "patients with different progesterone statuses",
       x = "Time (years)", caption = "Figure 7.9")+
  annotate("text",10,0.01,
           label="Chisq= 30.5  on 1 degrees of freedom, p= 3e-08")
survdiff(Surv(rtime_years,recur)~ pgrfactor, data = rotterdam)



#os
sfit_os_pgrfactor<-survfit(Surv(dtime_years,death)~ pgrfactor,
                           data = rotterdam_pgr_status)
ggsurvfit(sfit_os_pgrfactor)
survdiff(Surv(dtime_years,death)~ pgrfactor, data = rotterdam_pgr_status)
sfit_os_pgrfactor2<-survfit(Surv(dtime_years,death)~ pgrfactor2,
                            data = rotterdam_pgr_status)
ggsurvfit(sfit_os_pgrfactor2)
survdiff(Surv(rotterdam_pgr_status$dtime_years,
              rotterdam_pgr_status$death)~ pgrfactor2,
         data = rotterdam_pgr_status)
rotterdam$pgrfactor<-ifelse(rotterdam$pgr<50,'<50','>50')

# chosen two positive classes 
sfit_os_pgrfactor2<-survfit(Surv(dtime_years,death)~ pgrfactor2,
                            data = rotterdam_pgr_status)
ggsurvfit(sfit_os_pgrfactor2)+add_confidence_interval()+
  labs(title = "Overall Survival Distrubtion",
       subtitle = "patients with different progesterone statuses",
       x = "Time (years)", caption = "Figure 7.10")+
  annotate("text",10,0.01,
           label="Chisq= 55.3  on 1 degrees of freedom, p= 1e-13")
survdiff(Surv(dtime_years,death)~ pgrfactor, data = rotterdam)


# analysis of positive er on survival

# rfs
sfit_rfs_erfactor<-survfit(Surv(rtime_years,recur)~ erfactor,
                           data = rotterdam_er_status)
ggsurvfit(sfit_rfs_erfactor)
survdiff(Surv(rtime_years,recur)~ erfactor, data = rotterdam_er_status)
sfit_rfs_erfactor2<-survfit(Surv(rtime_years,recur)~ erfactor2,
                            data = rotterdam_er_status)
ggsurvfit(sfit_rfs_erfactor2)+add_confidence_interval()+
  labs(title = "Relapse-free Survival Distrubtion", subtitle = "patients with different progesterone statuses", x = "Time (years)", caption = "Figure 7.11")+annotate("text",10,0.01,label="Chisq= 3  on 1 degrees of freedom, p= 0.08")
survdiff(Surv(rtime_years,recur)~ erfactor2, data = rotterdam_er_status)

# os
rotterdam_er_status<-filter(rotterdam, er_status=='+')
rotterdam_er_status$erfactor<-ifelse(rotterdam_er_status$er<50,'<50',
                                     ifelse(rotterdam_er_status$er>50 &
                                              rotterdam_er_status$er<100,
                                            '50-100',
                                            ifelse(rotterdam_er_status$er>100 &
                                                     rotterdam_er_status$er<300,
                                                   '100-300','>300')))
sfit_os_erfactor<-survfit(Surv(dtime_years,death)~ erfactor,
                          data = rotterdam_er_status)
ggsurvfit(sfit_os_erfactor)
survdiff(Surv(dtime_years,death)~ erfactor, data = rotterdam_er_status)
rotterdam_er_status$erfactor2<-ifelse(rotterdam_er_status$er<50,'<50','>50')
sfit_os_erfactor2<-survfit(Surv(dtime_years,death)~ erfactor2,
                           data = rotterdam_er_status)
ggsurvfit(sfit_os_erfactor2)+add_confidence_interval()+
  labs(title = "Overall Survival Distrubtion",
       subtitle = "patients with different progesterone statuses",
       x = "Time (years)", caption = "Figure 7.12")+
  annotate("text",10,0.01,label="Chisq= 0.3  on 1 degrees of freedom, p= 0.6")
survdiff(Surv(dtime_years,death)~ erfactor2, data = rotterdam_er_status)

# Checking linearity of pgr of rfs
M1_rfs_pgr<-coxph(Surv(rtime_years,recur)~pgr, ties="breslow", data=rotterdam)
M1_rfs_pgrfactor<-coxph(Surv(rtime_years,recur)~pgrfactor, ties="breslow",
                        data=rotterdam)
M1_rfs_pgrfactor2<-coxph(Surv(rtime_years,recur)~pgrfactor2, ties="breslow",
                         data=rotterdam_pgr_status)

# Checking linearity of pgr of os
M1_os_pgr<-coxph(Surv(dtime_years,death)~pgr, ties="breslow", data=rotterdam)
M1_os_pgrfactor<-coxph(Surv(dtime_years,death)~pgrfactor, ties="breslow",
                       data=rotterdam)
M1_os_pgrfactor2<-coxph(Surv(dtime_years,death)~pgrfactor2, ties="breslow",
                        data=rotterdam_pgr_status)

# pgrfactor2 is the best one. pgrfactor shows a small change wtih X distribution

# Node Analysis
rotterdam$node_status<-ifelse(rotterdam$nodes==0,'-','+')

# rfs
sfit_rfs_nodes<-survfit(Surv(rtime_years,recur)~ node_status, data = rotterdam)
ggsurvfit(sfit_rfs_nodes)+add_confidence_interval()+
  labs(title = "Relapse-Free Survival Distrubtion",
       subtitle = "patients with different progesterone statuses",
       x = "Time (years)", caption = "Figure 7.13")+
  annotate("text",10,0.01,
           label="Chisq= 245  on 1 degrees of freedom, p= <2e-16")
survdiff(Surv(rtime_years,recur)~ node_status, data = rotterdam)

# os
sfit_os_nodes<-survfit(Surv(dtime_years,death)~ node_status, data = rotterdam)
ggsurvfit(sfit_os_nodes)+add_confidence_interval()+
  labs(title = "Overall Survival Distrubtion",
       subtitle = "patients with different progesterone statuses",
       x = "Time (years)", caption = "Figure 7.14")+
  annotate("text",10,0.01,
           label="Chisq= 290  on 1 degrees of freedom, p= <2e-16")
survdiff(Surv(dtime_years,death)~ node_status, data = rotterdam)

# number of nodes have an effect?
rotterdam_node_status<-filter(rotterdam, node_status=='+')
rotterdam_node_status$nodefactor<-ifelse(rotterdam_node_status$nodes==1,'1',
                                         ifelse(rotterdam_node_status$nodes==2,
                                                '2',
                                                ifelse(
                                                  rotterdam_node_status$nodes==3
                                                  |rotterdam_node_status$
                                                    nodes==4,'3-4','=>5')))
rotterdam_node_status$nodefactor<-as_factor(rotterdam_node_status$nodefactor)
summary(rotterdam_node_status$nodefactor)
rotterdam$nodefactor<-ifelse(rotterdam$nodes==1,'1',
                             ifelse(rotterdam$nodes==2,'2',
                                    ifelse(rotterdam$nodes==3 |
                                             rotterdam$nodes==4,'3-4',
                                           ifelse(rotterdam$nodes==0,'0',
                                                  '<=5'))))


# rfs
sfit_rfs_nodefactor<-survfit(Surv(rtime_years,recur)~ nodefactor,
                             data = rotterdam)
ggsurvfit(sfit_rfs_nodefactor)
survdiff(Surv(rtime_years,recur)~ nodefactor, data = rotterdam)

# os
sfit_os_nodefactor<-survfit(Surv(dtime_years,death)~ nodefactor,
                            data = rotterdam)
ggsurvfit(sfit_os_nodefactor)
survdiff(Surv(dtime_years,death)~ nodefactor, data = rotterdam)

# checking linearity of nodes...

#rfs
M1_rfs_nodes<-coxph(Surv(rtime_years,recur)~nodes, ties="breslow",
                    data=rotterdam)
M1_rfs_nodes
M1_rfs_nodefactor<-coxph(Surv(rtime_years,recur)~nodefactor, ties="breslow",
                         data=rotterdam)
M1_rfs_nodefactor

# os
M1_os_nodes<-coxph(Surv(dtime_years,death)~nodes, ties="breslow",
                   data=rotterdam)
M1_os_nodes
M1_os_nodefactor<-coxph(Surv(dtime_years,death)~nodefactor, ties="breslow",
                        data=rotterdam)
M1_os_nodefactor

# Collett recommends general strategy of choosing factors
rotterdam$nodesquared<-(rotterdam$nodes)^2
M1_os_nodesquared<-coxph(Surv(dtime_years,death)~nodesquared, ties="breslow",
                         data=rotterdam)
M1_os_nodesquared
rotterdam$nodescubed<-(rotterdam$nodes)^3
M1_os_nodescubed<-coxph(Surv(dtime_years,death)~nodescubed, ties="breslow",
                        data=rotterdam)
M1_os_nodescubed
# Factors for nodes

# Tumour size analysis
M1_rfs_size<-coxph(Surv(rtime_years,recur)~size, ties="breslow", data=rotterdam)
M1_rfs_size
M1_os_size<-coxph(Surv(dtime_years,death)~size, ties="breslow", data=rotterdam)
M1_os_size

# Tumour grade analysis
M1_rfs_grade<-coxph(Surv(rtime_years,recur)~grade, ties="breslow",
                    data=rotterdam)
M1_rfs_grade
M1_os_grade<-coxph(Surv(dtime_years,death)~grade, ties="breslow",
                   data=rotterdam)
M1_os_grade

# Size and Grade have already been split into factors therefore no need to test
# for linearity

# Recommended Analysis:
# 1. collect all variables that we will include in the model and compare to the
# null model

M0_rfs<-coxph(Surv(rtime_years,recur)~1, ties="breslow", data=rotterdam)
M0_os<-coxph(Surv(dtime_years,death)~1, ties="breslow", data=rotterdam)

# os
M1_os_age5<-coxph(Surv(dtime_years,death)~age5, ties="breslow", data=rotterdam)
M1_os_pgrfactor<-coxph(Surv(dtime_years,death)~pgrfactor, ties="breslow",
                       data=rotterdam)
M1_os_nodefactor<-coxph(Surv(dtime_years,death)~nodefactor, ties="breslow",
                        data=rotterdam)
M1_os_size<-coxph(Surv(dtime_years,death)~size, ties="breslow", data=rotterdam)
M1_os_grade<-coxph(Surv(dtime_years,death)~grade, ties="breslow",
                   data=rotterdam)
M2_os_nodefactor_size<-coxph(Surv(dtime_years,death)~size+nodefactor,
                             ties="breslow", data=rotterdam)
M3_os_nodefactor_size_age5<-coxph(Surv(dtime_years,death)~size+nodefactor+age5,
                                  ties="breslow", data=rotterdam)
M4_os_nodefactor_size_age5_grade<-coxph(Surv(dtime_years,death)~size+nodefactor+
                                          age5+grade, ties="breslow",
                                        data=rotterdam)
M4_os_nodefactor_size_age5_pgrfactor<-coxph(Surv(dtime_years,death)~size+
                                              nodefactor+age5+pgrfactor,
                                            ties="breslow", data=rotterdam)
M5_os_nodefactor_size_age5_grade_pgrfactor<-coxph(Surv(dtime_years,death)~size+
                                                    nodefactor+age5+grade+
                                                    pgrfactor, ties="breslow",
                                                  data=rotterdam)
Rotterdam_M5_os<-with(rotterdam, data.frame(hypothetical.patients=c(1,2,3),
                                            nodefactor=c('<=5','2','0'),
                                            size=c('>50','20-50','<=20'),
                                            grade=c('3','3','2'),
                                            pgrfactor=c('<50','>50','>50'),
                                            age5=c(70^5,55^5,40^5)))
plot(survfit(M5_os_nodefactor_size_age5_grade_pgrfactor,
             newdata = Rotterdam_M5_os),col=c('red','green','blue'),
     xlab = "Time (years)", ylab = "Survival Probability",
     main = "Overall Survival Distribution\nof hypothetical patients")
legend('bottomleft',c("Patient 1","Patient 2","Patient 3"),
       col = c('red','green','blue'),lty=1, cex=1)



# rfs
M1_rfs_pgrfactor<-coxph(Surv(rtime_years,recur)~pgrfactor, ties="breslow",
                        data=rotterdam)
M1_rfs_nodefactor<-coxph(Surv(rtime_years,recur)~nodefactor, ties="breslow",
                         data=rotterdam)
M1_rfs_size<-coxph(Surv(rtime_years,recur)~size, ties="breslow", data=rotterdam)
M1_rfs_grade<-coxph(Surv(rtime_years,recur)~grade, ties="breslow",
                    data=rotterdam)
M2_rfs_nodefactor_size<-coxph(Surv(rtime_years,recur)~size+nodefactor,
                              ties="breslow", data=rotterdam)
M3_rfs_nodefactor_size_grade<-coxph(Surv(rtime_years,recur)~size+nodefactor+
                                      grade, ties="breslow", data=rotterdam)
M4_rfs_nodefactor_size_grade_pgrfactor<-coxph(Surv(rtime_years,recur)~size+
                                                nodefactor+grade+pgrfactor,
                                              ties="breslow", data=rotterdam)
Rotterdam_M4_rfs<-with(rotterdam, data.frame(hypothetical.patients=c(1,2,3),
                                             nodefactor=c('<=5','2','0'),
                                             size=c('>50','20-50','<=20'),
                                             grade=c('3','3','2'),
                                             pgrfactor=c('<50','>50','>50')))
plot(survfit(M4_rfs_nodefactor_size_grade_pgrfactor,
             newdata = Rotterdam_M4_rfs),col=c('red','green','blue'),
     xlab = "Time (years)", ylab = "Survival Probability",
     main = "Relaps-free Survival Distribution\nof hypothetical patients")
legend('bottomleft',c("Patient 1","Patient 2","Patient 3"),
       col = c('red','green','blue'),lty=1, cex=1)


survivor_rfs_function<-basehaz(M4_rfs_nodefactor_size_grade_pgrfactor)                                                                                                                                              
survivor_rfs_function$survival_prob<-survivor_rfs_function$hazard
survivor_rfs_function$survival_prob<-exp(-survivor_rfs_function$survival_prob)
survivor_rfs_function<-survivor_rfs_function[-c(1)]
plot(survivor_rfs_function)

