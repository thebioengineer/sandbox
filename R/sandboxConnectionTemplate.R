#' Contains template information for connection to external server 
#' 
#' @param host server where  R code will be exectuted, defaults to local
#' @param port port of the connection
#' @param username external servers username
#' @param hostOS what is the hosts OS? (unix vs windows)
#'  
#' @export
sandboxConnectionTemplate<-function(host="localhost",port,username="",hostOS=c("unix","windows")){
  if( host=="localhost" || host == getLocalIP() ){
    localnode<-"localhost"
    host<- "localhost"
  }else{
    localnode<-getLocalIP()
  }
  
  if(missing(port)){
    if( host=="localhost"){
      port<-getPort()
    }else{
      port<-22
    }
  }
  hostOS<-match.arg(hostOS)
  newSandboxConnectionTemplate(host,username,port,localnode,hostOS)
}


newSandboxConnectionTemplate<-function(host,username,port,localnode,hostOS){
  structure(
    list(host=host, #return only results/error
         username=username,
         port=port,
         localnode=localnode,
         hostOS=hostOS),
    class = "sandboxConnection")
}

getLocalIP<-function(){
  switch(.Platform$OS.type,
         "windows"=ip.windows(),
         ip.unix())
}

ip.windows<-function(){
  ipconf<-system("ipconfig",intern = TRUE)
  IP<-gsub("(.*)(\\s)((\\d+[.])+(\\d+))(.*)","\\3",ipconf[grepl("IPv4 Address",ipconf)])
  IP[1] #first IP address is the internal IP address of the machine
}

ip.unix<-function(){
  ipconf<-system("ifconfig",intern = TRUE)
  IP<-gsub("(.+)(inet )((\\d+[.])+(\\d+))(.*)","\\3",ipconf[grepl("inet ",ipconf)])
  IP[length(IP)] #last IP address is the internal IP address of the machine
}
