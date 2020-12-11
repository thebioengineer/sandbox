#' share and send objects over sockets
#' Get code to evaluate from original R Session
#' @param sandboxCon socket connection to original R session
receiveSand<-function(sandboxCon){
  unserialize(sandboxCon)
}

#' share and send objects over sockets
#' Get code to evaluate from original R Session
#' @param expr the expression to be sent to the r session on the other end of the `sandboxCon`
#' @param sandboxCon socket connection to original R session
sendSand<-function(expr,sandboxCon){
  serialize(expr,sandboxCon)
}