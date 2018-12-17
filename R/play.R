#' Generate Connection to original R Session
#' @param ID the port ID to open socket on
#' @import utils
makeSandbox<-function(ID){
  socketCon <- make.socket("localhost", port=ID, server=TRUE)
  return(socketCon)
}

#' Get code to evaluate from original R Session
#' @param sandboxCon socket connection to original R session
receiveSand<-function(sandboxCon){
  primer <- read.socket(sandboxCon)
  print("recieved Primer")
  ss <- read.socket(sandboxCon,maxlen = as.character(primer))
  print("recieved object")
  stringToObject(ss)
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
  cat("here2",file="C:/Users/ehhughes/Documents/VISC_Packages/sandbox/test123.txt",append = TRUE)
  sendSand(results,sandboxCon)
  cat("here3",file="C:/Users/ehhughes/Documents/VISC_Packages/sandbox/test123.txt",append=TRUE)

}

#' Quit from sandboxed R session
#'
#' keep socket connection open until original session confirms it has recieved all outputs
#' @param socketCon socket connection to original R session
closeSandbox<-function(sandboxCon){
  recievedConfirmation<-read.socket(sandboxCon)
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
  cat("here1",file="C:/Users/ehhughes/Documents/VISC_Packages/sandbox/test123.txt")
  returnSand(con,mold)
  cat("here5",file="C:/Users/ehhughes/Documents/VISC_Packages/sandbox/test123.txt",append=TRUE)
  closeSandbox(con)
  cat("here20",file="C:/Users/ehhughes/Documents/VISC_Packages/sandbox/test123.txt",append=TRUE)

}
