
#generate new R session and prep it to recieve a function
makeExternalRSession<-function(host,ID){
  
  if (.Platform$OS.type == "windows"){
    r_exe <- file.path(R.home("bin"), "Rscript.exe")
  } else {
    r_exe <- file.path(R.home("bin"), "Rscript")
  }
  makeRSession(r_exe,host,ID)
}

makeRSession<-function(r_exe,host,ID){
  
  
  rscript<-tempfile()
  writeLines(c("old <- options(timeout = 60 * 60 * 24 * 30);on.exit(options(old))",
              paste0("library(sandbox);sandbox:::evaluateSandbox(\"",host,"\",",ID,")")),con = rscript)
  
  # rscript<-file.path(find.package("sandbox"),"sandbox","start_ext_Rsession.R")
  cmd<-paste(r_exe,"--vanilla --slave",rscript)

  if (.Platform$OS.type == "windows") {
    system(cmd, wait = FALSE, input = "")
  } else{
    system(cmd, wait = FALSE)
  }
}
