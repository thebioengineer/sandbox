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
  
  unserialize(jsonlite::base64_dec(std_out(res)))
}

expressionize <- function(x){
  gsub("\n","\\\\n",jsonlite::base64_enc(serialize(x,connection = NULL)))
}

dexpressionize <- function(x){
  unserialize(jsonlite::base64_dec(gsub("\\n","\n",paste(x,collapse = ""), fixed=TRUE)))
}

ssh_install_sandbox <- function(session,ref = NULL, force = FALSE){
  
  ssh_rscript_exec(
    session,
    paste0(
      paste0("sandbox <- inherits(try(find.package(\"sandbox\")),\"try-error\") | ", force,";"),
      "remotes <- inherits(try(find.package(\"remotes\")),\"try-error\");",
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
      "pkg_list <- c(",paste0("'", packages, "'", collapse = ","),");",
      "p_installed <- do.call('c',lapply(pkg_list, function(p){!inherits(try(find.package(p)),'try-error')}));",
      "cat(pkg_list[p_installed])"
    )
  )
  
  remote_installed_packages <- unlist(strsplit(std_out(res),"\\s+"))
  
  list(
    remote_installed = remote_installed_packages,
    remote_missing = setdiff(packages, remote_installed_packages)
  )
}
