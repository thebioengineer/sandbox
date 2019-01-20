#' Sandbox code into another R session
#' 
#' Run expression in a sandboxed environment and return outputs
#' 
#' @param x an expression to be exectuted, or file name of script, in the sandbox environment
#' @param host Where to evaluate the code. assumed to be 'localhost'
#' @param env envionment that the leaked objects are to be assigned to. Assumes [global.env()]
#'  
#' @export
#' @examples
#' sandbox({
#'   testval<-22
#'   print(testval)
#' })
sandbox<-function(x,host="localhost",env=parent.frame()){

  # convert input to function to be sent to sandbox session
  toEval<-functionalizeInput(substitute(x))

  # generate new R session to run sandboxed code in
  sandboxCon<-sandboxSession(host)
  on.exit({destroySandbox(sandboxCon)})

  # run new code
  sendSand(toEval,sandboxCon)

  # capture outputs
  output<-receiveSand(sandboxCon)

  #inform sandbox session to close
  serialize("complete",sandboxCon)

  captureLeakedObjects(output,env)
  return(output)
}

# #Results to return from sandbox

sandboxSession<-function(host='localhost'){
  ID<-getPort()

  # These two lines need to execute soon one after another. The new R session
  # initializes the socket connection,
  # and waits for the connection. The order matters, which is why
  # the system call is first, prevents locking
  makeExternalRSession(host,ID)
  # con <- make.socket(host, ID)
  con <- socketConnection(host = host,
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

getPort<-function(){
  port<-sample(20000:20200,1)
  return(port)
}
