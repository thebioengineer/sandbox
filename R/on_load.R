.onLoad<-function(libname, pkgname){
  options("Sandbox_masterNode"=Sys.info()[["nodename"]])
  options("Sandbox_scriptdir"=file.path(libname, pkgname))
}

