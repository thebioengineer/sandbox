externalInit<-function(localNode,port){
  old <- options(timeout = 60 * 60 * 24 * 30)
  on.exit(options(old))
  library(sandbox)
  sandbox:::evaluateSandbox(localNode,port)
}