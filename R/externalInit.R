externalInit<-function(localnode,port){
  # old <- options(timeout = 60 * 60 * 24 * 30)
  # on.exit(options(old))
  # library(sandbox)
  # evaluateSandbox(localNode,port)
  r_exe<-switch(.Platform$OS.type,
                "windows"=file.path(R.home("bin"), "Rscript.exe"),
                file.path(R.home("bin"), "Rscript"))
  
  rscript <- system.file("scripts","start_hosted_ext_Rsession.R",package = "sandbox")
  
  cmd<-paste(r_exe,"--vanilla --slave", rscript, localnode, port)
  if (.Platform$OS.type == "windows") {
    system(cmd, wait = FALSE, input = "",ignore.stdout = TRUE,ignore.stderr = TRUE,show.output.on.console = FALSE)
  } else{
    system(cmd, wait = FALSE, intern = FALSE,ignore.stdout = TRUE,ignore.stderr = TRUE,show.output.on.console = FALSE)
  }
  
}