#' Contains template information for connection to external server 
#' 
#' @param host server where  R code will be exectuted, defaults to local
#' @param port port of the connection
#' @param username external servers username
#' @param hostOS what is the hosts OS? (unix vs windows)
#'  
#' @export
sandboxConnectionTemplate<-function(host="localhost",port,username="",hostOS=c("unix","windows"), method = c("websocket","ssh")){
  
  if( host=="localhost" || host == getLocalNode() ){
    localnode<-"localhost"
    host<- "localhost"
  }else{
    localnode<-getLocalNode()
  }
  
  if(missing(port)){
    if( host=="localhost"){
      port<-getPort()
    }else{
      port<-22
    }
  }
  
  hostOS<-match.arg(hostOS)
  
  newSandboxConnectionTemplate(
    host = host, 
    username = username,
    port = port,
    localnode = localnode,
    hostOS = hostOS,
    connectionType = match.arg(method)
    )
}


newSandboxConnectionTemplate<-function(host,username,port,localnode,hostOS,session = NULL, connected = FALSE, connectionType = NULL){
  structure(
    list(host=host, #return only results/error
         username=username,
         port=port,
         localnode=localnode,
         hostOS=hostOS, 
         session = session,
         connected = connected, 
         connectionType = connectionType
    ),
    class = "sandboxConnection")
}

getLocalNode<-function(){
  Sys.info()[['nodename']]
}

