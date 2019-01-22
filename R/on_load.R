.onLoad<-function(libname, pkgname){
  options("Sandbox_masterNode"=getLocalIP())
  options("Sandbox_scriptdir"=file.path(libname, pkgname))
}

