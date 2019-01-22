#' Contains template information for connection to external server 
#' 
#' @param host server where  R code will be exectuted, defaults to local
#' @param port port of the connection
#' @param username external servers username
#'  
#' @export
sandboxConnectionTemplate<-function(host="localhost",port,username=""){
  if(missing(port)){
    port<-getPort()
  }
  
  if(host=="localhost"){
    localnode<-"localhost"
  }else{
    localnode<-options("Sandbox_masterNode")
  }
  
  structure(
    list(host=host, #return only results/error
         username=username,
         port=port,
         localnode=localnode),
    class = "sandboxConnection")
}