#' Generate Connection to original R Session
#' @param node host to run R session on
#' @param ID the port ID to open socket on
#' @param host location of host server, local or external
#' 
makeSandbox<-function(node,ID,host="local"){
  switch(host,
         "local"=makeSandbox.local(node,ID),
         makeSandbox.external(node,ID))
}

makeSandbox.local<-function(node,ID){
  
  socketCon<-socketConnection(host = node, port = ID, blocking = TRUE,
                   open = "a+b", timeout = 60 * 60 * 24 * 30)
  return(socketCon)
}

makeSandbox.external<-function(node,ID){
  socketCon<-socketConnection(host = node, port = ID, blocking = TRUE,
                              open = "a+b", timeout = 60 * 60 * 24 * 30 )
  return(socketCon)
}


#' Evaluate code from original R Session
#' @importFrom evaluate evaluate
#' @param mold code supplied to sandbox R session to evaluate, contained in a function call
#' @export
castSand<-function(mold){
  results<-evaluate(mold, output_handler = sandbox_handler(), stop_on_error = 1)
  newSandboxOutput(results,leakEnv)
}

#' Evaluate code from a serialized function
#' @importFrom evaluate evaluate
#' @param mold string version of the serialized function to evaluate
#' @export
castSand_serial<-function(mold){
  saveRDS(mold,"f:/Documents/Projects/sandbox.rds")
  toEval <- dexpressionize(mold)
  results<-evaluate(toEval, output_handler = sandbox_handler(), stop_on_error = 1)
  sbOutput <- newSandboxOutput(results,leakEnv)
  cat(expressionize(sbOutput))
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

