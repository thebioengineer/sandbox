#' share and send objects over sockets
#' Get code to evaluate from original R Session
#' @param sandboxCon socket connection to original R session
receiveSand<-function(sandboxCon){
  # primer <- recieveMessage(sandboxCon)
  # ss <- recieveMessage(sandboxCon,maxlen = as.character(primer))
  # stringToObject(ss)
  stringToObject(unserialize(sandboxCon))
}

#' share and send objects over sockets
#' Get code to evaluate from original R Session
#' @param expr the expression to be sent to the r session on the other end of the `sandboxCon`
#' @param sandboxCon socket connection to original R session
sendSand<-function(expr,sandboxCon){
  # serObject<-objectToString(expr)
  # sendMessage(sandboxCon,as.character(stri_numbytes(serObject)))
  # sendMessage(sandboxCon,serObject,maxlen = stri_numbytes(serObject))
  serialize(objectToString(expr),sandboxCon)
}