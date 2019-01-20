#testScript
set.seed(42)
generateDF<-function(ncols=1,nrows=1){
  do.call('cbind',lapply(seq(1,ncols),function(x,y){runif(y)},nrows))
}
testDF <- generateDF(10,10)
print(testDF)
