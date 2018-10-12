pcs <- read_table2("R:/Beatriz/Research/DiseaseBurden/data/sgdp_head.eigenvec", col_names = FALSE)


plot(pcs$X3,pcs$X4, main="SGDP Native American PCA", xlab="PCA1", ylab="PCA2", col=pcs$X2)

legend("topright", inset=.05, title="Populations",
       c("CAI","SAI"), fill = c("orangered", "blue"),  horiz=TRUE)