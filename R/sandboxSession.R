connectSandboxSession <- function(sbConnection,...){
  if(!isTRUE(sbConnection[["connected"]])){
    connectFunc <- switch(
      sbConnection[["connectionType"]],
      websocket = connectSandboxSession.websocket,
      ssh = connectSandboxSession.ssh,
    )
    connectFunc(sbConnection,...)
  }else{
   sbConnection 
  }
}

destroySandbox<-function(sbConnection,...){
  if(sbConnection[["connected"]]){
    destroyFunc <- switch(
      sbConnection[["connectionType"]],
      websocket = destroySandbox.websocket,
      ssh = destroySandbox.ssh,
    )
    destroyFunc(sbConnection,...)
  }else{
    warning("sandbox Connection not connected")
  }
}

connectSandboxSession.websocket<-function(sbConnection,...){
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
  
  sbConnection[["session"]] <- con
  sbConnection[["connected"]] <- TRUE
  return(sbConnection)
}

destroySandbox.websocket<-function(sbConnection,...){
  serialize("complete",sbConnection[["session"]])
  close.connection(sbConnection[["session"]])
}

connectSandboxSession.ssh <- function(sbConnection,...){
 session <- ssh_connect(paste0(sbConnection$username,"@",sbConnection$host))
 sbConnection[["session"]] <- session
 sbConnection[["connected"]] <- TRUE
 return(sbConnection)
}

destroySandbox.ssh<-function(sbConnection){
  ssh_disconnect(sbConnection[["session"]])
  sbConnection[["session"]] <- NULL
  sbConnection[["connected"]] <- FALSE
}