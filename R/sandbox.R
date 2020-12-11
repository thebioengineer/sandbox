#' Sandbox code into another R session
#' 
#' Run expression in a sandboxed environment and return outputs
#' 
#' @param x an expression to be exectuted, or file name of script, in the sandbox environment
#' @param sbConnection output of the [sandboxConnectionTemplate()]
#' @param env envionment that the leaked objects are to be assigned to. Assumes [global.env()]
#'  
#' @export
#' @examples
#' sandbox({
#'   testval<-22
#'   print(testval)
#' })
sandbox<-function(x,sbConnection=sandboxConnectionTemplate(),env=parent.frame()){

  # convert input to function to be sent to sandbox session
  toEval<-functionalizeInput(substitute(x))

  # generate new R session to run sandboxed code in
  sandboxCon<-sandboxSession(sbConnection)
  on.exit({destroySandbox(sandboxCon)})

  # run new code
  sendSand(toEval,sandboxCon)

  # capture outputs
  output<-receiveSand(sandboxCon)

  captureLeakedObjects(output,env)
  
  return(output)
}

# #Results to return from sandbox

sandboxSession<-function(sbConnection){
  

  # These two lines need to execute soon one after another. 
  # first an The new R session
  # initializes the socket connection,
  # and waits for the connection. The order matters, which is why
  # the system call is first, prevents locking
    makeExternalRSession(sbConnection)
    # con <- make.socket(host, ID)
    con <- socketConnection(host = sbConnection$host,
                          port = sbConnection$port,
                          server = ifelse(sbConnection$host == 'localhost', TRUE, FALSE),
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
