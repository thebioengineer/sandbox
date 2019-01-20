
#' Return leaked objects from sandbox environment to the parent
#' @param x object to return from sandbox environment
#' @param env environment to assign the objects stored in x to
captureLeakedObjects<-function(x,env=parent.frame()){
  # print(paste("Nobjects:",length(ls(x[['leak']]))))
  # print(paste("env:",env))
  lapply(ls(x[['leak']]),function(objectName,env){
    assign(objectName,x[['leak']][[objectName]],envir = env)
  },env)
}
