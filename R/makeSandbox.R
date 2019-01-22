
#generate new R session and prep it to recieve a function
makeExternalRSession<-function(sbConnection){
  
  if (.Platform$OS.type == "windows"){
    r_exe <- file.path(R.home("bin"), "Rscript.exe")
  } else {
    r_exe <- file.path(R.home("bin"), "Rscript")
  }
  makeRSession(r_exe,sbConnection)
}

makeRSession<-function(r_exe,sbConnection){
  
  
  rscript<-file.path(options("Sandbox_scriptdir"), "start_ext_Rsession.R")
  
  #to enable passing testing
  if(!file.exists(rscript)){ 
    rscript<-file.path(options("Sandbox_scriptdir"),"inst", "start_ext_Rsession.R")
    
  }
  
  # writeLines(c("old <- options(timeout = 60 * 60 * 24 * 30);on.exit(options(old))",
  #             paste0("library(sandbox);sandbox:::evaluateSandbox(\"",host,"\",",ID,")")),con = rscript)
  
  # rscript<-file.path(find.package("sandbox"),"sandbox","start_ext_Rsession.R")
  cmd<-paste(r_exe,"--vanilla --slave",rscript,sbConnection$localnode,sbConnection$port)

  if (.Platform$OS.type == "windows") {
    system(cmd, wait = FALSE, input = "",ignore.stdout = TRUE,ignore.stderr = TRUE,show.output.on.console = FALSE)
  } else{
    system(cmd, wait = FALSE,intern = FALSE,ignore.stdout = TRUE,ignore.stderr = TRUE)
  }
}
