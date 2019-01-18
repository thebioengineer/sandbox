
newSandboxOutput<-function(results,leakEnv,call){
  
  results<-results[which(sapply(results,function(x)!inherits(x,"source")))]
  metadata<-sessionInfo()
  
  structure(
    list(outputs=results, #return only results/error
         leak=leakEnv,
         metadata=metadata),
    class = "sandbox_output")
  
}

#' print method for sandbox.output
#'

#' @param x sandbox.output to be printed
#' @param env environment to assign leaked objects to
#' @param ... additional arguments passed to print
#' @export
print.sandbox_output<-function(x,...,env=parent.frame()){

  #send leaked objects to global env
  lapply(ls(x[['leak']]),function(objectName){
         assign(objectName,x[['leak']][[objectName]],envir = env)
    })

  #print outputs
  lapply(x[["outputs"]],function(y){
    if(is.character(y)){
      cat(y)
    }else{
      print(y,...)
    }
  })
}


