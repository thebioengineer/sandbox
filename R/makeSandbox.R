
#generate new R session and prep it to recieve a function
makeExternalRSession<-function(ID){
  
  if (.Platform$OS.type == "windows"){
    r_exe <- file.path(R.home("bin"), "Rscript.exe")
  } else {
    r_exe <- file.path(R.home("bin"), "Rscript")
  }
  makeRSession(r_exe,ID)
}

makeRSession<-function(r_exe,ID){
  
  
  rscript<-tempfile()
  writeLines(c("args <- commandArgs(trailingOnly=TRUE)",
             "old <- options(timeout = 60 * 60 * 24 * 30)",
             "on.exit(options(old))",
             "",
             "library(sandbox)",
             "sandbox:::evaluateSandbox(args[1])"),con = rscript)
  
  # rscript<-file.path(find.package("sandbox"),"sandbox","start_ext_Rsession.R")
  cmd<-paste(r_exe,"--vanilla --slave",rscript,ID)

  if (.Platform$OS.type == "windows") {
    system(cmd, wait = FALSE, input = "")
  } else{
    system(cmd, wait = FALSE)
  }
}
