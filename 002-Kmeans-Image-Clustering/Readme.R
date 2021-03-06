library(jpeg)
library(reshape)
library(ggplot2)
library(dplyr)
library(mclust)

img.path <- "Tulip-Farm-Skagit.jpg"

readImage <- readJPEG(img.path)

longImage <- melt(readImage)
head(longImage)

rgbImage <- reshape(longImage, timevar = "X3", idvar = c("X1", "X2"), direction = "wide")
rgbImage <- rgbImage %>%
  mutate(X1 = -X1,
         rgb = rgb(value.1, value.2, value.3))

head(rgbImage)


plot(rgbImage$X2, rgbImage$X1, col = rgbImage$rgb, asp = 1, pch = ".")


# Cluster in color space:
kColors <- 7  # Number of palette colors
kMeans <- kmeans(rgbImage %>% select(value.1, value.2, value.3), centers = kColors)


rgbImage <- rgbImage %>% mutate(rbgApp = rgb(kMeans$centers[kMeans$cluster, ]))

head(rgbImage)

rgbImage_aux <- rgbImage %>%
  group_by(rbgApp) %>%
  summarise(n=n()) %>%
  arrange(n) %>%
  mutate(rbgApp = factor(rbgApp, levels = rbgApp))

rgbImage_aux

ggplot(rgbImage_aux) +
  geom_bar(aes(x=rbgApp, y=n, fill=rbgApp),  stat="identity") +
  scale_fill_manual(values=as.character(rgbImage_aux$rbgApp)) + 
  coord_flip() + theme_bw()


plot(rgbImage$X2, rgbImage$X1, col = rgbImage$rbgApp, asp = 1, pch = ".")



plot(rgbImage$X2, rgbImage$X1, col = rgbImage$rgb, asp = 1, pch = ".")
