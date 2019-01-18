#' Generate Connection to original R Session
#' @param ID the port ID to open socket on
#' @import utils
makeSandbox<-function(ID){
  # socketCon <- make.socket("localhost", port=ID, server=TRUE)
  socketCon<-socketConnection("localhost", port = ID, blocking = TRUE,
                   open = "a+b", timeout = 60 * 60 * 24 * 30)
  return(socketCon)
}


#' Evaluate code from original R Session
#' @import evaluate
#' @param mold code supplied to sandbox R session to evaluate, contained in a function call
castSand<-function(mold){
  leakEnv<-createleak()
  results<-evaluate(mold,stop_on_error = 1)
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
#' @param socketCon socket connection to original R session
closeSandbox<-function(sandboxCon){
   repeat({
    message<-unserialize(sandboxCon)
    if(message=="complete"){
      break
    }else{
      serialize(message,sandboxCon)
    }
  })
  # q(save='no')
}

#' Make Sandbox Run
#'
#' wrapper function to assist with running in sandbox
#' @param ID the port ID to open socket on
evaluateSandbox<-function(ID){

  retryDelay <- 0.1     # 0.1 second initial delay before retrying
  retryScale <- 1.5     # 50% increase of delay at each retry
  setup_timeout <- 120  # retry setup for 2 minutes before failing
  t0 <- Sys.time()
  writeLines("starting connection\n","C:/Users/ehhughes/Documents/Projects/sandbox.log")
  repeat({
    con<-try(makeSandbox(ID))
    if(!inherits(con,'try-error')){
      break
    }
    if (Sys.time() - t0 > setup_timeout){
      q(save = "no")
      }
    Sys.sleep(retryDelay)
    retryDelay <- retryScale * retryDelay
  })
  on.exit(close.connection(con))
  sand<-receiveSand(con)
  mold<-castSand(sand)
  returnSand(con,mold)
  closeSandbox(con)
}
