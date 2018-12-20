#' Return object from sandbox environment
#' @param x object to return from sandbox environment
#' @export
leak<-function(x){
  objectName<-as.character(substitute(x))
  assign(objectName,x,envir = leakEnv)
}


createleak<-function(env=parent.frame()){
  leakEnv<-new.env()
  leak<-function(x){
    objectName<-as.character(substitute(x))
    assign(objectName,x,envir = leakEnv)
  }
  assign("leak",leak,envir = env)
  return(leakEnv)
}
