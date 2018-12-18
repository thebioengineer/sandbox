#' Generate Connection to original R Session
#' @param ID the port ID to open socket on
#' @import utils
makeSandbox<-function(ID){
  socketCon <- make.socket("localhost", port=ID, server=TRUE)
  return(socketCon)
}


#' Evaluate code from original R Session
#' @import evaluate
#' @param mold code supplied to sandbox R session to evaluate, contained in a function call
castSand<-function(mold){
  results<-evaluate(mold,stop_on_error = 1)
  results[which(sapply(results,function(x)!inherits(x,"source")))] #return only results/error
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
    message<-read.socket(sandboxCon)
    if(message=="complete"){
      break
    }else{
      write.socket(sandboxCon,message)
    }
  })
  # q(save='no')
}

#' Make Sandbox Run
#'
#' wrapper function to assist with running in sandbox
#' @param ID the port ID to open socket on
evaluateSandbox<-function(ID){

  repeat({
    con<-try(makeSandbox(ID))
    if(!inherits(con,'try-error')){
      break
    }
  })
  on.exit(close.socket(con))
  sand<-receiveSand(con)
  mold<-castSand(sand)
  returnSand(con,mold)
  closeSandbox(con)
}
