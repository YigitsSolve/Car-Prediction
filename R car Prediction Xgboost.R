library(tidyverse)
library(stringr)
library(xgboost)
library(caret)
library(readr)

df <- load_data("C:/./used_cars.csv")

# Veri ön işleme
preprocess_data <- function(df) {
  df <- df %>%
    select(-model, -ext_col, -int_col, -clean_title) %>%
    mutate(
      model_year = as.integer(model_year),
      milage = parse_number(milage),
      fuel_type = if_else(str_trim(fuel_type) == "–", NA_character_, 
                          if_else(str_trim(fuel_type) == "not supported", "electric", fuel_type)),
      HP = as.numeric(str_extract(engine, "\\d+(?=HP)")),
      `Engine Volume (L)` = as.numeric(str_extract(engine, "\\d+\\.?\\d*(?=L)")),
      transmission = if_else(str_detect(transmission, "(A/T|Automatic)", negate = TRUE), "0", "1"),
      accident = if_else(accident == "None", 0, 1),
      price = as.numeric(gsub("[$,]", "", price))
    )
  return(df)
}

df <- preprocess_data(df)

# Eksik değerleri işle
handle_missing_values <- function(df) {
  df$milage <- ifelse(is.na(df$milage), 0, df$milage)
  df <- df %>% drop_na(HP, `Engine Volume (L)`)
  return(df)
}

df <- handle_missing_values(df)

# One-hot encoding
one_hot_encode <- function(df) {
  df <- df %>%
    pivot_longer(where(is.character), names_to = "variable", values_to = "value") %>%
    mutate(value = as.factor(value)) %>%
    pivot_wider(names_from = "variable", values_from = "value") %>%
    mutate(across(where(is.character), as.numeric))
  return(df)
}

df <- one_hot_encode(df)


# Veriyi eğitim ve test setlerine ayır
split_data <- function(df, seed, p) {
  set.seed(seed)
  train_index <- createDataPartition(df$price, p = p, list = FALSE)
  train_data <- df[train_index, ]
  test_data <- df[-train_index, ]
  return(list(train_data, test_data))
}

train_data <- split_data(df, 42, 0.4)[[1]]
test_data <- split_data(df, 42, 0.6)[[2]]

# XGBoost modeli eğitimi

train_xgb_model <- function(train_data) {
  xgb_model <- xgboost(data = as.matrix(select(train_data, where(is.numeric))),
                       label = train_data$price,
                       nrounds = 100,
                       max_depth = 1,
                       objective = "reg:squarederror",
                       verbose = 0)
  return(xgb_model)
}

xgb_model <- train_xgb_model(train_data)
# Test verisi üzerinde tahminler yap
make_predictions <- function(xgb_model, test_data) {
  test_prediction <- predict(xgb_model, xgb.DMatrix(data = as.matrix(select(test_data, where(is.numeric)))))
  return(test_prediction)
}


test_prediction <- make_predictions(xgb_model, test_data)
test_prediction
# Model performansını değerlendir
evaluate_model <- function(test_data, test_prediction) {
  rmse <- sqrt(mean((test_data$price - test_prediction)^2))
  print(paste("RMSE:", rmse))
}
evaluate_model(test_data, test_prediction)

evaluate_model <- function(test_data, test_prediction) {
  rmse <- sqrt(mean((test_data$price - test_prediction)^2))
  r_squared <- R2(pred = test_prediction, obs = test_data$price)
  print(paste("RMSE:", rmse))
  print(paste("R-squared:", r_squared))
}

evaluate_model(test_data, test_prediction)

library(ggplot2)
library(gridExtra)

# Grafikleri oluştur
histogram_hp <- ggplot(df, aes(x = HP)) +
  geom_histogram(fill = "skyblue", color = "black") +
  labs(x = "HP", y = "Frekans", title = "HP Dağılımı") +
  theme_minimal()

histogram_engine_volume <- ggplot(df, aes(x = `Engine Volume (L)`)) +
  geom_histogram(fill = "lightgreen", color = "black") +
  labs(x = "Motor Hacmi (L)", y = "Frekans", title = "Motor Hacmi Dağılımı") +
  theme_minimal()

histogram_model_year <- ggplot(df, aes(x = model_year)) +
  geom_histogram(fill = "lightblue", color = "black") +
  labs(x = "Model Yılı", y = "Frekans", title = "Model Yılı Dağılımı") +
  theme_minimal()

histogram_milage <- ggplot(df, aes(x = milage)) +
  geom_histogram(fill = "lightgreen", color = "black") +
  labs(x = "Kilometre", y = "Frekans", title = "Kilometre Dağılımı") +
  theme_minimal()

histogram_accident <- ggplot(df, aes(x = accident)) +
  geom_bar(fill = "orange", color = "black") +
  labs(x = "Kaza Durumu", y = "Frekans", title = "Kaza Durumu Dağılımı") +
  theme_minimal()

histogram_price <- ggplot(df, aes(x = price)) +
  geom_histogram(fill = "lightpink", color = "black") +
  labs(x = "Fiyat", y = "Frekans", title = "Fiyat Dağılımı") +
  theme_minimal()

histogram_brand <- ggplot(df, aes(x = brand)) +
  geom_bar(fill = "lightyellow", color = "black") +
  labs(x = "Marka", y = "Frekans", title = "Marka Dağılımı") +
  theme_minimal()

histogram_fuel_type <- ggplot(df, aes(x = fuel_type)) +
  geom_bar(fill = "lightcyan", color = "black") +
  labs(x = "Yakıt Tipi", y = "Frekans", title = "Yakıt Tipi Dağılımı") +
  theme_minimal()

histogram_transmission <- ggplot(df, aes(x = transmission)) +
  geom_bar(fill = "lightgreen", color = "black") +
  labs(x = "Şanzıman", y = "Frekans", title = "Şanzıman Dağılımı") +
  theme_minimal()

# Tahminlerin gerçek değerlerle ilişki scatter plot'u
scatter_plot <- ggplot(results, aes(x = Real_Price, y = Predicted_Price)) +
  geom_point() +
  geom_abline(intercept = 0, slope = 1, color = "red", linetype = "dashed") +
  labs(x = "Gerçek Fiyat", y = "Tahmin Edilen Fiyat", title = "Gerçek vs. Tahmin Edilen Fiyatlar") +
  theme_minimal()

# Grafikleri birleştir
combined_plots <- grid.arrange(histogram_hp, histogram_engine_volume, histogram_model_year, histogram_milage,
                               histogram_accident, histogram_price, histogram_brand, histogram_fuel_type,
                               histogram_transmission, scatter_plot,
                               ncol = 3)

# Grafikleri ekrana bastır
print(combined_plots)
