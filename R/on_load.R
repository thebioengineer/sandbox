.onLoad<-function(libname, pkgname){
  options("Sandbox_masterNode"=Sys.info()[["nodename"]])
}

