### G. Montazeaud

#### Comparison of plant height measurements obtained with a ruler (manual and traditional method) and with an ultrasonic sensor. Measurements were performed on 24/09/2020 at Lavalette site on a Sorgho field trial (GEVES national variety trials for variety inscription). Germain (Op1) performed the comparison by measuring plant height in 26 Genotypes (3 measurements per genotype), three same plants measured with the ruler and with the sensor



###########################################
######### I. Data formatting ##############
###########################################


setwd("~/Work/Thèse/Recherche/Céréalomètre/Article/Computers and electronics in agriculture/Dépôt données/Field tests/")

sens <- read.table("Sensor.csv", header=T, dec=".", sep=";")
sens$Genotype <- rep(c(1:26), each=3)
sens$rep <- rep(c(1:3),26)
sens <- sens[,c(3,4,2)]
colnames(sens)[3] <- "height"
sens$Genotype <- as.factor(sens$Genotype)
sens$method <- "sensor"

rul <- read.table("Ruler.csv", header=T, dec=".", sep=";")
rul$Genotype <- rep(c(1:26), each=3)
rul$rep <- rep(c(1:3),26)
rul <- rul[,c(3,4,2)]
colnames(rul)[3] <- "height"
rul$Genotype <- as.factor(rul$Genotype)
rul$method <- "ruler"


###########################################
######### II. DATA ANALYSIS ##############
###########################################

global <- rbind(rul,sens)
mod_global <- lm(height~Genotype+method, data=global)
anova(mod_global)
## Strong effect of the genotype identity, no effect of the method of measurement (i.e. ruler and sensor provide equivalent values)

mod_ruler <- lm(height~Genotype, data=rul)
anova(mod_ruler)
mod_sensor <- lm(height~Genotype, data=sens)
anova(mod_sensor)
## The genotypic effect is very strong, no matter the method of measurement


## Correlation between sensor-based and ruler-based measurements
mod <- lm(sens$height~rul$height)
a_mod <- mod$coefficients[2]
b_mod <- mod$coefficients[1]

png("Sensor_vs_ruler_correlation.png",height=500, width=1200, res=130)

par(mfrow=c(1,2), mar=c(5,5,3,1))

plot(sens$height~rul$height, las=1, bty="l", type="n", xlab="Plant height measured with the ruler (cm)", ylab="Plant height measured with\nthe ultrasonic device (cm)", main="", xlim=c(70,130), ylim=c(70,130))

abline(a=0, b=1, lty=2)

points(rul$height, sens$height, pch=16, cex=0.8)

legend("topleft",legend=c(paste("y = ",format(round(a_mod,4),nsmall = 4),"x + ",format(round(b_mod,4),nsmall = 4),sep=""), paste("R² = ", format(round(summary(mod)$r.squared,4),nsmall = 4),sep="")), bty="n")

mtext(expression("("*bold("a")*")"),side=3, line=1, at=70, cex=1.3, font=2)

## Distribution of differences between ruler-based and sensor-based plant height values
hist(sens$height-rul$height, breaks = 15, xlim=c(-2,2), las=1, xlab="Differences between sensor-based measurements\nand ruler-based measurements (cm)", ylab="Nb obs", main="", ylim=c(0,15), col="grey", border="black")

legend("topleft",legend=substitute(paste(italic("b")," = 0.0859 cm",sep="")), bty="n")

mtext(expression("("*bold("b")*")"),side=3, line=1, at=-2, cex=1.3, font=2)

dev.off()



### Same analysis using mean plant heights per genotype

rul_avg <- aggregate(height~Genotype, data=rul, FUN=mean)
sens_avg <-  aggregate(height~Genotype, data=sens, FUN=mean)

png("Sensor_vs_ruler_correlation_avg.png",height=500, width=1200, res=130)

par(mfrow=c(1,2), mar=c(5,5,3,1))

mod_avg <- lm(sens_avg$height~rul_avg$height)
a_mod_avg <- mod_avg$coefficients[2]
b_mod_avg <- mod_avg$coefficients[1]
predicted.intervals_mod_avg <- predict(mod_avg,data.frame(x=rul_avg$height),interval='confidence', level=0.95)

plot(sens_avg$height~rul_avg$height, las=1, bty="l", type="n", xlab="Plant height measured with the ruler (cm)", ylab="Plant height measured with\nthe ultrasonic device (cm)", main="", xlim=c(80,130), ylim=c(80,130))

abline(a=0, b=1, lty=2)

points(rul_avg$height, sens_avg$height, pch=16, cex=0.8)

legend("topleft",legend=c(paste("y = ",format(round(a_mod_avg,4),nsmall = 4),"x - ",format(round(abs(b_mod_avg),4),nsmall = 4),sep=""), paste("R² = ", format(round(summary(mod_avg)$r.squared,4),nsmall = 4),sep="")), bty="n")

mtext(expression("("*bold("a")*")"),side=3, line=1, at=70, cex=1.3, font=2)


## Distribution of differences between ruler-based and sensor-based plant height values
hist(sens_avg$height-rul_avg$height, breaks = 15, xlim=c(-1,1), las=1, xlab="Differences between sensor-based measurements\nand ruler-based measurements (cm)", ylab="Nb obs", main="", ylim=c(0,5), col="grey", border="black")

legend("topleft",legend=substitute(paste(italic("b")," = 0.0859 cm",sep="")), bty="n")

mtext(expression("("*bold("b")*")"),side=3, line=1, at=-1.3, cex=1.3, font=2)


dev.off()
