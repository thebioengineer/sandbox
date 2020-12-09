
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
  on.exit(ssh_disconnect(session))
  
  remote_installed_packages <- ssh_installed_packages(session,c("sandbox","remotes"))
  
  if("sandbox" %in% remote_installed_packages$remote_missing){
    ssh_install_sandbox()
  }
  
  sandbox_external_init <-
    paste0(
      "sandbox:::externalInit('",
      sbConnection$localnode,"',",
      sbConnection$port,
      ")")

  
  init_res <- ssh_rscript_exec(session,sandbox_external_init)
  
  return(TRUE)
  
}

std_err <- function(x){rawToChar(x$stderr)}
std_out <- function(x){rawToChar(x$stdout)}

rloc_path <- function(x){
  normalizePath(std_out(x),winslash = "/",mustWork = FALSE)
}

ssh_rscript_exec <- function(session, expression) {
  cmd <- paste0("RScript",
               " -e \"",
               expression,
               "\"")
  
  ssh_exec_internal(session, cmd, error = FALSE)
}

ssh_install_sandbox <- function(session,ref = NULL, force = FALSE){
  
  ssh_rscript_exec(
    session,
    paste0(
    "local_installed_packages <- rownames(installed.packages());",
    "sandbox <- 'sandbox' %in% local_installed_packages;",
    ifelse(force,"sandbox <- TRUE;",""),
    "remotes <- 'remotes' %in% local_installed_packages;",
    "rv <- R.version;",
    "rdate <- paste0(rv$year,'-',rv$month,'-',rv$day);",
    "if(remotes){",
    "install.packages('remotes',repos = paste0('https://mran.microsoft.com/snapshot/',rdate))",
    "};",
    "if(sandbox){",
    paste0("remotes::install_github('thebioengineer/sandbox",ifelse(!is.null(ref),paste0("@",ref),""),"')"),
    "};"
    ))
}

ssh_installed_packages <- function(session, packages){
  
  res <- ssh_rscript_exec(
    session,
    paste0(
      "local_installed_packages <- rownames(installed.packages());",
      "pkg_list <- c(",paste0("'",packages,"'", collapse = ","),");",
      "cat(pkg_list[pkg_list %in% local_installed_packages])"
    ))
  
  remote_installed_packages <- unlist(strsplit(std_out(res),"\\s+"))
  
  list(
    remote_installed = remote_installed_packages,
    remote_missing = setdiff(packages, remote_installed_packages)
  )
}
