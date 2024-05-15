Araç Fiyat Tahmini
Bu proje, kullanılmış araçların fiyatlarını tahmin etmek için bir XGBoost modeli kullanır. Proje, R dili ve tidyverse, xgboost, caret ve diğer yardımcı kütüphaneleri kullanarak geliştirilmiştir.

Veri Ön İşleme
Veri ön işleme adımları şu işlemleri içerir:

Model yılı, kilometre, motor gücü gibi sayısal değerlerin dönüştürülmesi ve temizlenmesi
Yakıt tipi ve şanzıman gibi kategorik değişkenlerin işlenmesi
Eksik değerlerin ele alınması
Model Eğitimi
Veri, eğitim ve test setlerine ayrılır ve ardından XGBoost modeli eğitilir. Model eğitimi sırasında, regresyon için kare hatası hedeflenir.

Model Performansı
Modelin performansı, kök ortalama kare hatası (RMSE) ve R-kare metrikleri kullanılarak değerlendirilir. Tahminler gerçek fiyatlarla karşılaştırılarak modelin ne kadar iyi çalıştığı belirlenir.

Grafikler
Proje, veri setinin çeşitli özelliklerinin dağılımını gösteren histogramlar içerir. Ayrıca, gerçek ve tahmin edilen fiyatlar arasındaki ilişkiyi gösteren bir scatter plot da bulunmaktadır.

Kullanım
Projenin kullanımı için aşağıdaki adımları izleyebilirsiniz:

Veri Ön İşleme ve Model Eğitimi: R dilindeki kodu kullanarak veri ön işleme ve model eğitimi işlemlerini gerçekleştirin.
Model Performansını Değerlendirme: Eğitilen modelin performansını değerlendirmek için evaluate_model fonksiyonunu kullanın.
Grafikleri İnceleme: Oluşturulan grafikler aracılığıyla veri setinin özelliklerini görselleştirin.
Bağımlılıklar
Projeyi çalıştırmak için aşağıdaki R kütüphanelerine ihtiyacınız olacaktır:

tidyverse
xgboost
caret
readr
ggplot2
