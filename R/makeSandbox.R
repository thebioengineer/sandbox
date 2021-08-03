
#' Generate new R session and prep it to recieve a function
#' 
#' Actual function that generates the connection with the sandbox R session
#' 
#' @param sbConnection the sandbox connection object
#' @import ssh
makeExternalRSession<-function(sbConnection){
  r_exe<-switch(.Platform$OS.type,
                "windows"=file.path(R.home("bin"), "Rscript.exe"),
                file.path(R.home("bin"), "Rscript"))
  
  rscript <- system.file("scripts","start_ext_Rsession.R", package = "sandbox")
  
  cmd<-paste(r_exe,"--vanilla --slave", rscript, sbConnection$localnode, sbConnection$port)
  
  if (.Platform$OS.type == "windows") {
    system(cmd, wait = FALSE, input = "",ignore.stdout = TRUE,ignore.stderr = TRUE,show.output.on.console = FALSE)
  } else{
    system(cmd, wait = FALSE,intern = FALSE,ignore.stdout = TRUE,ignore.stderr = TRUE)
  }

}

rloc_path <- function(x){
  normalizePath(std_out(x),winslash = "/",mustWork = FALSE)
}

std_err <- function(x){rawToChar(x$stderr)}
std_out <- function(x){rawToChar(x$stdout)}