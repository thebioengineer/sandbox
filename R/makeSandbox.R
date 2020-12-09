
#' Generate new R session and prep it to recieve a function
#' 
#' Actual function that generates the connection with the sandbox R session
#' 
#' @param sbConnection the sandbox connection object
#' @import ssh
makeExternalRSession<-function(sbConnection){
  switch(sbConnection$host,
         "localhost"=makeExternalRSession.local(sbConnection),
         makeExternalRSession.ssh(sbConnection))
}

makeExternalRSession.local<-function(sbConnection){
  r_exe<-switch(.Platform$OS.type,
                "windows"=file.path(R.home("bin"), "Rscript.exe"),
                file.path(R.home("bin"), "Rscript"))
  
  rscript<-file.path(options("Sandbox_scriptdir"), "start_ext_Rsession.R")
  
  #to enable passing testing
  if(!file.exists(rscript)){ 
    rscript<-file.path(options("Sandbox_scriptdir"),"inst", "start_ext_Rsession.R")
  }
  
  cmd<-paste(r_exe,"--vanilla --slave",rscript,sbConnection$localnode,sbConnection$port)
  if (.Platform$OS.type == "windows") {
    system(cmd, wait = FALSE, input = "",ignore.stdout = TRUE,ignore.stderr = TRUE,show.output.on.console = FALSE)
  } else{
    system(cmd, wait = FALSE,intern = FALSE,ignore.stdout = TRUE,ignore.stderr = TRUE)
  }

}


makeExternalRSession.ssh<-function(sbConnection){
  session <- ssh_connect(paste0(sbConnection$username,"@",sbConnection$host))

  cmd<-paste0("Rscript --vanilla --slave -e sandbox:::externalInit('",sbConnection$localnode,"',",sbConnection$port,")")
  
  ssh_exec_wait(session,cmd)
  ssh_disconnect(session)
}

