#' Generate Connection to original R Session
#' @param ID the port ID to open socket on
#' @param host host to run R session on
makeSandbox<-function(host,ID){
  # socketCon <- make.socket("localhost", port=ID, server=TRUE)
  socketCon<-socketConnection(host = host, port = ID, blocking = TRUE,
                   open = "a+b", timeout = 60 * 60 * 24 * 30)
  return(socketCon)
}


#' Evaluate code from original R Session
#' @import evaluate
#' @param mold code supplied to sandbox R session to evaluate, contained in a function call
castSand<-function(mold){
  results<-evaluate(mold, output_handler = sandbox_handler(), stop_on_error = 1)
  newSandboxOutput(results,leakEnv)
}

#' Return outputs to original R Session - wrapper for sendSand
#' @param sandboxCon socket connection to original R session
#' @param results results from evaluated code
returnSand<-function(sandboxCon,results){
  sendSand(results,sandboxCon)
}

#' Quit from sandboxed R session
#'
#' keep socket connection open until original session confirms it has recieved all outputs
#' @param sandboxCon socket connection to original R session
closeSandbox<-function(sandboxCon){
   repeat({
    message<-unserialize(sandboxCon)
    if(message=="complete"){
      break
    }else{
      serialize(message,sandboxCon)
    }
  })
}

