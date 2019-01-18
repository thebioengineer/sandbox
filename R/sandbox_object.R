
# newSandboxOutput<-function(outputs){
#   structure(list())
# }

#' print method for sandbox.output
#'

#' @param x sandbox.output to be printed
#' @export
print.sandbox.output<-function(x,env=parent.frame()){

  #send leaked objects to global env
  lapply(ls(x[['leak']]),function(objectName){
         assign(objectName,x[['leak']][[objectName]],envir = env)
    })

  #print outputs
  lapply(x[["outputs"]],function(y){
    if(is.character(y)){
      cat(y)
    }else{
      print(y)
    }
  })
}
