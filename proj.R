# Load libraries
library(caret)
library(randomForest)
library(ggplot2)

# Load data
data <- read.csv("WA_Fn-UseC_-Telco-Customer-Churn.csv")

# Clean data
data$Churn <- as.factor(data$Churn)
data <- na.omit(data)
data <- data[, !names(data) %in% "customerID"]
data[sapply(data, is.character)] <- lapply(data[sapply(data, is.character)], as.factor)

# Split data
set.seed(123)
split <- createDataPartition(data$Churn, p = 0.8, list = FALSE)
train <- data[split, ]
test <- data[-split, ]

# Train Random Forest model
model <- randomForest(Churn ~ ., data = train, ntree = 100)

# Predict on test data
pred <- predict(model, test)

# Confusion matrix
cm <- confusionMatrix(pred, test$Churn)
print(cm)

# Accuracy
acc <- cm$overall["Accuracy"]

# Plot accuracy
df <- data.frame(Metric = "Accuracy", Value = acc)
ggplot(df, aes(x = Metric, y = Value)) +
  geom_bar(stat = "identity", fill = "skyblue") +
  geom_text(aes(label = paste0(round(Value * 100, 1), "%")), vjust = -0.5) +
  ylim(0, 1) +
  labs(title = "Random Forest Model Accuracy", y = "Score", x = "") +
  theme_minimal()

# Predict for a new customer
new_customer <- data.frame(
  gender = factor("Female", levels = levels(data$gender)),
  SeniorCitizen = 0,
  Partner = factor("Yes", levels = levels(data$Partner)),
  Dependents = factor("No", levels = levels(data$Dependents)),
  tenure = 5,
  PhoneService = factor("Yes", levels = levels(data$PhoneService)),
  MultipleLines = factor("No", levels = levels(data$MultipleLines)),
  InternetService = factor("Fiber optic", levels = levels(data$InternetService)),
  OnlineSecurity = factor("No", levels = levels(data$OnlineSecurity)),
  OnlineBackup = factor("Yes", levels = levels(data$OnlineBackup)),
  DeviceProtection = factor("No", levels = levels(data$DeviceProtection)),
  TechSupport = factor("No", levels = levels(data$TechSupport)),
  StreamingTV = factor("Yes", levels = levels(data$StreamingTV)),
  StreamingMovies = factor("Yes", levels = levels(data$StreamingMovies)),
  Contract = factor("Month-to-month", levels = levels(data$Contract)),
  PaperlessBilling = factor("Yes", levels = levels(data$PaperlessBilling)),
  PaymentMethod = factor("Electronic check", levels = levels(data$PaymentMethod)),
  MonthlyCharges = 85.5,
  TotalCharges = 400.5
)

new_prediction <- predict(model, new_customer)
print(paste("New customer churn prediction:", new_prediction))

# Visualize churn distribution
ggplot(data, aes(x = Churn, fill = Churn)) +
  geom_bar() +
  geom_text(stat = "count", aes(label = ..count..), vjust = -0.5) +
  labs(title = "Churn Distribution", x = "Churn", y = "Number of Customers") +
  theme_minimal()