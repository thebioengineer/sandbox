
newSandboxOutput<-function(results,leakEnv){
  
  sourceCode<-sapply(results,function(x)inherits(x,"source"))
  
  source<-createSource(results[sourceCode])
  outputs<-results[!sourceCode]
  metadata<-sessionInfo()
  
  
  structure(
    list(outputs=outputs, #return only results/error
         leak=leakEnv,
         source=source,
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


#` convert character vectors into an actual call
createSource<-function(x){
  x<-unlist(lapply(x,`[[`,1))
  expression_x<-parse(text = paste0("{",paste(x,collapse=""),"}"))[[1]]
  func_x<-eval(call("function",NULL,expression_x))
  return(func_x)
}

