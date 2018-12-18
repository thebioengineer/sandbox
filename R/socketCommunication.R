#' share and send objects over sockets
#' Get code to evaluate from original R Session
#' @param sandboxCon socket connection to original R session
receiveSand<-function(sandboxCon){
  primer <- recieveMessage(sandboxCon)
  print("recieved Primer")
  ss <- recieveMessage(sandboxCon,maxlen = as.character(primer))
  print("recieved object")
  stringToObject(ss)
}


sendSand<-function(expr,sandboxCon){
  serObject<-objectToString(expr)
  sendMessage(sandboxCon,as.character(stri_numbytes(serObject)))
  sendMessage(sandboxCon,serObject,maxlen = stri_numbytes(serObject))
}

#' fascilitate communication, send message with unique ID. wait for confirmation of recept of message with unique identifier confirmation

sendMessage<-function(con,string,maxlen=256L){
  messageID<-round(runif(1)*300)
  write.socket(con,paste0(string," MID:",messageID))
  repeat({
    message<-read.socket(con,maxlen = maxlen)
    if( message == paste0("MID:",messageID,"R")){
      break
    }else{
      write.socket(con,message)
    }
  })
}

recieveMessage<-function(con,maxlen=256L){
  message<-read.socket(con,maxlen=maxlen)
  #getMessageID:
  messageID<-gsub("(.*)(MID:(\\d+))$","\\2",message)
  write.socket(con,paste0(messageID,"R"))
  message<-gsub("(.*) (MID:(\\d+))$","\\1",message)
  return(message)
}
