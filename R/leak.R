#' Return object from sandbox environment
#' @param x object to return from sandbox environment
#' @param name name to export object as if alternate to the name of the input object
#' @export
leak<-function(x,name){
  if(missing(name)){
    name<-as.character(substitute(x))
  }
  assign(name,x,envir = leakEnv)
}

leakEnv<-new.env()

#' Accessor function to return the hidden leakEnv (mainly for testing)
accessLeakEnv<-function(){
  return(leakEnv)
}

# createleak<-function(env=parent.frame()){
#   leakEnv<-leakEnv
#   leak<-leak
#   assign("leak",leak,envir = env)
#   return(leakEnv)
# }
