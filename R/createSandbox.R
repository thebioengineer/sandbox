createSandbox <- function(connection, toEval, ...){
  func <- switch(
    connection[["connectionType"]],
    websocket = createSandbox.websocket,
    ssh = createSandbox.ssh
  )
  
  func(connection, toEval)
}

createSandbox.websocket <- function(connection, toEval){
  # run new code
  sendSand(toEval,connection)
  
  # capture outputs
  receiveSand(connection)
  
}

createSandbox.ssh <- function(connection, toEval){
  
  remote_installed_packages <- ssh_installed_packages(connection[["session"]],c("sandbox"))
  
  if("sandbox" %in% remote_installed_packages$remote_missing){
    ssh_install_sandbox(connection[["session"]])
  }
  
  ssh_sandbox_exec(connection[["session"]],toEval)
  
  
  
}