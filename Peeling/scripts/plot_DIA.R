# Directorio de trabajo
setwd("C:/Users/Ignacio/Desktop/OneDrive/Cuarto/Segundo Cuatri/Compiladores/p2 optim/Peeling")

# Leer los datos
datos_old <- read.table("resultados/DIA-opt.txt", header = TRUE)
datos_sin <- read.table("resultados/DIA-sin-opt.txt", header = TRUE)

# Calcular la media de OPT_OLD para cada valor de N
medias_old <- aggregate(OPT_OLD ~ N, data = datos_old, FUN = mean)
medias_sin <- aggregate(SIN_OPT ~ N, data = datos_sin, FUN = mean)

datos <- merge(medias_old, medias_sin, by = "N")
names(datos) <- c("N", "MED_OLD", "MED_SIN")

# Calcular m�nimos y m�ximos para cada N
min_max_old <- aggregate(OPT_OLD ~ N, data = datos_old, FUN = function(x) c(min = min(x), max = max(x)))
min_max_sin <- aggregate(SIN_OPT ~ N, data = datos_sin, FUN = function(x) c(min = min(x), max = max(x)))

# Separar en columnas min y max
min_max_old <- data.frame(N = min_max_old$N, MIN_OLD = min_max_old$OPT_OLD[, "min"], MAX_OLD = min_max_old$OPT_OLD[, "max"])
min_max_sin <- data.frame(N = min_max_sin$N, MIN_SIN = min_max_sin$SIN_OPT[, "min"], MAX_SIN = min_max_sin$SIN_OPT[, "max"])

# Unir con las medias
datos <- merge(datos, min_max_old, by = "N")
datos <- merge(datos, min_max_sin, by = "N")


### Tiempos

# Abrir el dispositivo gr�fico PDF
pdf("graficas/DIA_tiempos.pdf", width = 7, height = 6)

ylim_range <- range(c(datos$MED_OLD, datos$MED_SIN))
plot(datos$N, datos$MED_OLD, type="n", ylim=ylim_range, xlab = "N (escala logar�tmica)", ylab = "Tiempo (s)", 
     main = "Comparaci�n entre medias, m�ximos y m�nimos", log = "x")
axis(1, at = datos$N, labels = FALSE)
points(datos$N, datos$MED_OLD, col = "blue", pch = 22, cex = 0.7)
points(datos$N, datos$MED_SIN, col = "red", pch = 21, cex = 0.7)

# A�adir l�neas verticales para min y max (como barras de error)
arrows(datos$N, datos$MIN_OLD, datos$N, datos$MAX_OLD, col = "blue", angle = 90, code = 3, length = 0.05)
arrows(datos$N, datos$MIN_SIN, datos$N, datos$MAX_SIN, col = "red", angle = 90, code = 3, length = 0.05)

curve_old <- spline(datos$N, datos$MED_OLD)
lines(curve_old, col="blue", lwd = 0.5)
curve_sin <- spline(datos$N, datos$MED_SIN)
lines(curve_sin, col="red", lwd = 0.5)

legend("topleft", 
       legend = c("Original", "Peeling"), 
       col = c("red", "blue"), 
       pch = c(21, 22),
       lwd = c(2, 2), 
       bty = "n", 
       inset = 0.02)

# 3. Cerrar el dispositivo gr�fico
dev.off()


### Speedup

pdf("graficas/DIA_speedup.pdf", width = 7, height = 6)

datos$speedup <- datos$MED_SIN / datos$MED_OLD
colores <- ifelse(datos$speedup >= 1, "blue", "red")
plot(datos$N, datos$speedup, log="x", col = colores, 
     pch = 16, cex = 0.7, ylim = range(0.5, 1.5),
     xlab = "N (escala logar�tmica)",
     ylab = "Aceleraci�n (original / peeling)",
     main = "Aceleraci�n comparada")
abline(h = 1, col = "black", lty = 1, lwd = 0.5)  # h = valor de y

lines(datos$N, datos$speedup, col = "blue", lwd = 0.5)

# Primero dividimos los vectores seg�n N
split_old <- split(datos_old$OPT_OLD, datos_old$N)
split_sin <- split(datos_sin$SIN_OPT, datos_sin$N)

# Calcular cuantiles 25% y 75% para cada N
q25_old <- sapply(split_old, function(x) quantile(x, probs = 0.25))
q75_old <- sapply(split_old, function(x) quantile(x, probs = 0.75))
q25_sin <- sapply(split_sin, function(x) quantile(x, probs = 0.25))
q75_sin <- sapply(split_sin, function(x) quantile(x, probs = 0.75))

# Extraer n�meros antes del primer punto
n_vals <- as.numeric(sub("\\..*", "", names(q25_old)))

# Crear data.frames con nombres consistentes
cuantiles_old_df <- data.frame(N = n_vals, Q25_OLD = q25_old, Q75_OLD = q75_old)
cuantiles_sin_df <- data.frame(N = n_vals, Q25_SIN = q25_sin, Q75_SIN = q75_sin)

# Unir con el dataframe principal
datos <- merge(datos, cuantiles_old_df, by = "N")
datos <- merge(datos, cuantiles_sin_df, by = "N")

# Cuantil inferior del speedup (poca ganancia): SIN �ptimo bajo / OLD �ptimo alto
datos$Q25_SPEEDUP <- datos$Q25_SIN / datos$Q75_OLD
# Cuantil superior del speedup (m�xima ganancia): SIN �ptimo alto / OLD �ptimo bajo
datos$Q75_SPEEDUP <- datos$Q75_SIN / datos$Q25_OLD

# Dibujar flechas solo si la diferencia entre Q75 y Q25 es mayor que un umbral
for (i in 1:nrow(datos)) {
  if (abs(datos$Q75_SPEEDUP[i] - datos$Q25_SPEEDUP[i]) > 1e-5) {
    arrows(datos$N[i], datos$Q25_SPEEDUP[i], 
           datos$N[i], datos$Q75_SPEEDUP[i], 
           col = colores[i], angle = 90, code = 3, length = 0.05)
  }
}

legend("topleft", 
       legend = c("Mejor original", "Mejor peeling"), 
       col = c("red", "blue"), 
       pch = c(16, 16),
       bty = "n", 
       inset = 0.02)


dev.off()


