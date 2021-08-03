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



ssh_install_sandbox <- function(session,ref = NULL, force = FALSE){
  
  ssh_rscript_exec(
    session,
    shQuote(paste0(
      paste0("sandbox <- inherits(try(find.package(\"sandbox\")),\"try-error\") | ", force,";"),
      "remotes <- inherits(try(find.package(\"remotes\")),\"try-error\");",
      "rv <- R.version;",
      "rdate <- paste0(rv$year,'-',rv$month,'-',rv$day);",
      "};",
      "if(sandbox){",
      paste0("remotes::install_github('thebioengineer/sandbox",ifelse(!is.null(ref),paste0("@",ref),""),"')"),
      "};"
    )))
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
