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
sandbox<-function(x,env=parent.frame()){

  # convert expression to function to be sent to sandbox session
  expr <- eval(substitute(substitute(x)))
  body<-eval(call("function",NULL,expr))

  # generate new R session to run sandboxed code in
  sandboxCon<-sandboxSession()
  on.exit({destroySandbox(sandboxCon)})

  # run new code
  sendSand(body,sandboxCon)

  # capture outputs
  output<-receiveSand(sandboxCon)

  #inform sandbox session to close
  serialize("complete",sandboxCon)

  class(output)<-"sandbox.output"

  # print(output,env)
  invisible(output)
}

# #Results to return from sandbox

sandboxSession<-function(){
  ID<-sample(1000:1079,1)

  # These two lines need to execute soon one after another. The new R session initializes the socket connection,
  # and waits for the connection. the order matters, which is why
  # the system call is first, prevents locking
  makeExternalRSession(ID)
  # con <- make.socket("localhost", ID)
  con <- socketConnection(host = "localhost",
                          port = ID,
                          server=TRUE,
                          blocking=TRUE,
                          open="a+b")
  return(con)
}

destroySandbox<-function(sandboxCon){
    serialize("complete",sandboxCon)
    close.connection(sandboxCon)
}


