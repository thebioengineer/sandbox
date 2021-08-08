std_err <- function(x){rawToChar(x$stderr)}
std_out <- function(x){rawToChar(x$stdout)}

ssh_rscript_exec <- function(session, expression, rscript_exe = "RScript") {
  cmd <- paste0(rscript_exe,
                " -e ",
                shQuote(expression)
  )
  
  ssh_exec_internal(session, cmd, error = FALSE)
}

ssh_sandbox_exec <- function(session, expression, rscript_exe = "RScript") {
  
  cmd <- paste0(rscript_exe,
                " -e ",
                shQuote(paste0(
                  "sandbox::castSand_serial('",
                  expressionize(expression),
                  "')")))
  
  res <- ssh_exec_internal(session, cmd)
  
  dexpressionize(std_out(res))
}

#' @importFrom jsonlite base64_enc
expressionize <- function(x){
  char_x <- gsub("\n","\\\\n",base64_enc(serialize(x,connection = NULL)))
  char_x <- gsub("\\","%%",char_x, fixed = TRUE)
  scan(text = char_x, what = "character", allowEscapes = FALSE,quiet = TRUE,encoding = "utf8")
}

#' @importFrom jsonlite base64_dec
dexpressionize <- function(x){
  char_x <-scan(text = paste(x,collapse = ""), what = "character", allowEscapes = TRUE,quiet = TRUE)
  char_x <- gsub("%%","\\",char_x, fixed = TRUE)
  unserialize(base64_dec(gsub("\\n","\n",char_x, fixed=TRUE)))
}



ssh_install_package_cran <- function(session, package, cran_mirror = "https://cran.rstudio.com/"){
  
  ssh_rscript_exec(
    session,
    paste0("install.packages(c(",paste("'",package,"'",collapse=","),"). , repos='",cran_mirror,"')")
    )
}

ssh_install_package_remote <- function(session, package){
  
  ssh_rscript_exec(
    session,
    paste0("remotes::install_github('",package,"')")
    )
}

ssh_install_sandbox <- function(session, ref){
  if(!ssh_installed_packages(session,"remotes")){
    ssh_install_package_cran(session,"remotes")
  }
  sandbox_ref <- "thebioengineer/sandbox"
  
  if(missing(ref)){
    ref <- packageDescription("sandbox")$GithubRef
  }
  
  if(!is.null(ref)){
    sandbox_ref <- paste0(sandbox_ref,"@",ref)
  }
  ssh_install_package_remote(session, sandbox_ref)
}


ssh_installed_packages <- function(session, packages){
  
  res <- ssh_rscript_exec(
    session,
    paste0(
      "pkg_list <- c(",paste0("'", packages, "'", collapse = ","),");",
      "p_installed <- do.call('c',lapply(pkg_list, function(p){!inherits(try(find.package(p)),'try-error')}));",
      "cat(pkg_list[p_installed])"
    )
  )
  
  remote_installed_packages <- unlist(strsplit(std_out(res),"\\s+"))
  
  package_list <- packages %in% remote_installed_packages
  
  names(package_list) <- packages
  
  package_list

}

ssh_installed_package_version <- function(session, packages){
  
  res <- ssh_rscript_exec(
    session,
    paste0(
      "pkg_list <- c(",paste0("'", packages, "'", collapse = ","),");",
      "p_installed <- do.call('c',lapply(pkg_list, function(p){tryCatch(as.character(packageVersion(p)),error = function(e){NA})}));",
      "cat(p_installed)"
    )
  )
  
  remote_installed_package_version <- unlist(strsplit(std_out(res),"\\s+"))

  names(remote_installed_package_version) <- packages
  
  remote_installed_package_version
  
}

