createSandbox <- function(connection, toEval, ...){
  func <- switch(
    connection[["connectionType"]],
    websocket = createSandbox.websocket,
    ssh = createSandbox.ssh
  )
  
  func(connection, toEval, ...)
}

createSandbox.websocket <- function(connection, toEval, ...){
  # run new code
  sendSand(toEval,connection[["session"]])
  
  # capture outputs
  receiveSand(connection[["session"]])
  
}

createSandbox.ssh <- function(connection, toEval, ..., update = TRUE){
  
  sb_not_installed_ssh <- !ssh_installed_packages(connection[["session"]],"sandbox")
  sb_old_ssh <- ssh_installed_package_version(connection[["session"]],"sandbox") < packageVersion("sandbox")
  
  ## If sandbox is not installed or is an old version, update
  if(sb_not_installed_ssh | (sb_old_ssh & update)){
    ssh_install_sandbox(connection[["session"]])
  }
  
  ssh_sandbox_exec(connection[["session"]],toEval)
}