# Checking for necessary packages
library("dplyr")
library("corrplot")

username <- Sys.info()["user"]
path <- paste0("C:/Users/", username, "/OneDrive - Mount St. Mary's University/Desktop/FRED Data Science/")

#Pulling in data from downloaded csv's
#Data was obtained from Federal Reserve Economic Data (FRED)


VA_Emissions <- read.csv(path, "VA_Emissions_A.csv")

VA_Discouraged <- read.csv(path, "VA_Discouraged_A.csv")

VA_Spending <- read.csv(path, "VA_Spending_A.csv")

DC_Spending <- read.csv(path, "DC_Spending_A.csv")

VA_HH_Income <- read.csv(path, "VA_HH_Income_A.csv")

#Merge the data into one table
Merge_Data <- VA_Emissions %>%
  inner_join(VA_Discouraged, by = "DATE") %>%
  inner_join(VA_Spending, by = "DATE") %>%
  inner_join(VA_HH_Income, by = "DATE") %>%
  inner_join(DC_Spending, by = "DATE")

#Change column names for better legibility
Raw_Variables <- Merge_Data %>% rename(VA_Emissions = EMISSCO2TOTVTTTOVAA, VA_Discouraged = DISCWORKVA, VA_Spending = VAPCE, VA_HH_Income = MEHOINUSVAA672N, DC_Spending = DCPCE)

#Create table for variables without the DATE column and change to numeric 
Variables <- Raw_Variables %>%
  select(VA_Emissions, VA_Discouraged, VA_Spending, DC_Spending, VA_HH_Income)

Variables <- Variables %>%
  mutate(
    VA_Emissions = as.numeric(VA_Emissions),
    VA_Discouraged = as.numeric(VA_Discouraged),
    VA_Spending = as.numeric(VA_Spending),
    VA_HH_Income = as.numeric(VA_HH_Income),
    DC_Spending = as.numeric(DC_Spending)
  )

#Create and print the correlation matrix
Correlation_Matrix <- cor(Variables)
print(Correlation_Matrix)

#Noticing the -0.76 Correlation Coefficient between Personal Spending and Emissions in Virginia, I wanted to dive deeper

#Check for Necessary package
library(ggplot2)
library(lubridate)

#Create data frame with the necessary variables
Data_for_graph <- data.frame(
  time = year(Raw_Variables$DATE),
  a = Raw_Variables$VA_Emissions,
  b = Raw_Variables$VA_Spending
)

#Use data frame to create the graph
ggplot(Data_for_graph) +
  geom_line(aes(x = time, y = a, color = "Emissions")) +
  geom_line(aes(x = time, y = (b - 150000) / 3500 + 50, color = "Spending")) +
  scale_y_continuous(
    name = "Emissions",
    limits = c(50, 120),
    sec.axis = sec_axis(~ (. - 50) * 3500 + 150000, 
    name = "Spending")
  ) +
  labs(title = "Emissions vs. Spending in Virginia",
       x = "Time",
       y = "Values") +
  scale_color_manual(name = "Variables", values = c("Emissions" = "red", "Spending" = "green"))

#These results can be explained a few ways. First, recent technological advancements have made technology more energy efficient.
#As the tech evolves, more consumers are spending money on these products while we see emissions lower simultaneously.
#Second, there may have been a decline in jobs in the manufacturing field and other field related to emissions. At the same time,
#there has been a consistent increase in service-based jobs, leading to an increase in spending on services. Lastly, environmental friendly
#products have consistently been pushed over the past few years, possibly leading to a change in consumer preference, spending more money on
#products that are more environmentally friendly.

#Limitations to this exploratory analysis would include the small sample size (df=17) as well as outside factors that could obviously be affecting either of these variables.

VA_Manu_Jobs <- read.csv(path, "VA_Manufacturing_M.csv")
VA_Service <- read.csv(path, "VA_Business_Service_M.csv")

Data_for_graph2 <- VA_Manu_Jobs %>%
  inner_join(VA_Service, by = "DATE")

Data_for_graph2 <- Data_for_graph2 %>% rename(VA_Manufacturing = VAMFG, VA_Business = VAPBSV)
Data_for_graph2$DATE <- as.Date(Data_for_graph2$DATE)
Data_for_graph2$VA_Manufacturing <- as.numeric(Data_for_graph2$VA_Manufacturing)
Data_for_graph2$VA_Business <- as.numeric(Data_for_graph2$VA_Business)


Graph_Data2 <- Data_for_graph2 %>%
  select(DATE, VA_Manufacturing, VA_Business)

ggplot(Graph_Data2) +
  geom_line(aes(x = DATE, y = VA_Manufacturing, color = "Manufacturing")) +
  geom_line(aes(x = DATE, y = VA_Business, color = "Business Services")) +
  labs(title = "Manufacturing vs. Business Services Jobs in VA",
       x = "Time",
       y = "Values")
  scale_color_manual(name = "Variables", values = c("Manufacturing" = "red", "Business Services" = "blue"))
  
#With this graph, you can see that over the same time period, we have seen a consistent decrease in Manufacturing Jobs
# as well as a consistent increase in Business Services jobs in Virginia

  



