#' Run expression in a sandboxed environment and return outputs
#' @param x
#' @export
#' @examples
#' \dontrun{
#' sandbox({
#'   library(tidyverse)
#'   testval<-22
#'   print(testval)
#'   print(testVar)
#' })
#' }
sandbox<-function(x){

  # convert expression to function to be sent to new env
  expr <- eval(substitute(substitute(x)), parent.frame())
  body<-eval(call("function",NULL,expr))

  # generate new R session to run sandboxed code in
  sandboxCon<-sandboxSession()
  on.exit({destroySandbox(sandboxCon)})

  # run new code
  sendSand(body,sandboxCon)

  output<-receiveSand(sandboxCon)

  write.socket(sandboxCon,"complete")
  # eval(body(),envir = new.env(parent=baseenv()))

  class(output)<-"sandbox.output"

  return(output)
  # return(body)
}

# #Results to return from sandbox

sandboxSession<-function(){
  ID<-sample(1000:1079,1)

  # These two lines need to execute soon one after another. The new R session initializes the socket connection,
  # and waits for the connection. the order matters, which is why
  # the system call is first, prevents locking
  system(paste0("R --vanilla --slave -e library(sandbox);sandbox:::evaluateSandbox(",ID,") &"),wait=FALSE)
  con <- make.socket("localhost", ID)
  return(con)
}

destroySandbox<-function(sandboxCon){
    write.socket(sandboxCon,'complete')
    close.socket(sandboxCon)
}


