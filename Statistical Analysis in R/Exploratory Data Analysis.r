#The goal of this script was to explore correlations contained in the Federal Reserve Economic Data (FRED).
#This was good practice for creating correlation matrices before creating graphs and running T-tests.

#Checking for necessary packages
library("dplyr")
library("corrplot")

username <- Sys.info()["user"]
path <- paste0("C:/Users/", username, "/OneDrive - Mount St. Mary's University/Desktop/FRED Data Science/")

# Loading all data into the script 
Unemployment = read.csv(path, "Unemployment.csv")
CC_Delinq = read.csv(path, "CC_Delinquency.csv")
Effective_Rate = read.csv(path, "Effective_Rate.csv")

#Check column names within the data for the join to work
head(Unemployment)
head(CC_Delinq)
head(Effective_Rate)

#Kept seeing an error with the inner_join so renaming the columns to make sure they match
Unemployment <- Unemployment %>% rename(Date = DATE, Unemployment = UNRATE)
CC_Delinq <- CC_Delinq %>% rename (Date = DATE, CC_Rate = DRCCLACBS)
Effective_Rate <- Effective_Rate %>% rename (Date = DATE, Effect_Rate = DFF)

# Join the data together based on their dates
Merged_Data <- Unemployment %>%
  inner_join(CC_Delinq, by = "Date") %>%
  inner_join(Effective_Rate, by = "Date")

# Putting all the joined data into one table
Raw_Variables <- Merged_Data %>%
  select(Unemployment, CC_Rate, Effect_Rate)

# Mutating the data to be numeric for the sake of the correlation matrix
# All raw data is a percentage so mutating to numeric should maintain correlational relationships
Variables <- Raw_Variables %>%
  mutate(
    Unemployment = as.numeric(Unemployment),
    CC_Rate = as.numeric(CC_Rate),
    Effect_Rate = as.numeric(Effect_Rate)
  )

# Create and print correlation matrix
Correlation_Matrix <- cor(Variables)
print(Correlation_Matrix)

# Seeing that the correlation between Credit Card Delinquency and Effective Federal Fund Rate is 0.77,
# it is somewhat expected because of the relationship between the two factors. As the Federal Funds Rate
# increases, so does the Credit Card Interest Rate which makes it more difficult for low income families
# to make their minimum monthly payment, therefore increasing the Credit Card Delinquency Rate

# Now I wanted to run an Independent Samples T-test to see if there is a significant difference in Personal Spending between Virginia and DC

VA_Spending <- read.csv(path, "VA_Spending_A.csv")

DC_Spending <- read.csv(path, "DC_Spending_A.csv")

t_test_data <- VA_Spending %>%
  inner_join(DC_Spending, by = "DATE")

t_test_data <- t_test_data %>% rename (VA_Spend = VAPCE, DC_Spend = DCPCE)

t.test(t_test_data$VA_Spend, t_test_data$DC_Spend, var.equal = TRUE)

#Since the results of the t-test show a p-value less than .05, we can say that the difference between the means is not due to chance.
#The central limitation to these findings is that DC has far less inhabitants compared to Virginia,
#so personal spending will obviously be much higher in Virginia since it is accounting for many more people.





