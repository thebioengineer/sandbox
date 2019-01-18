#' Make Sandbox Run
#'
#' wrapper function to assist with running in sandbox
#' @param ID the port ID to open socket on
evaluateSandbox<-function(host,ID){
  
  retryDelay <- 0.1     # 0.1 second initial delay before retrying
  retryScale <- 1.5     # 50% increase of delay at each retry
  setup_timeout <- 120  # retry setup for 2 minutes before failing
  t0 <- Sys.time()
  
  repeat({
    con<-try(makeSandbox(host,ID))
    if(!inherits(con,'try-error')){
      break
    }
    if (Sys.time() - t0 > setup_timeout){
      q(save = "no")
    }
    Sys.sleep(retryDelay)
    retryDelay <- retryScale * retryDelay
  })
  on.exit(close.connection(con))
  sand<-receiveSand(con)
  mold<-castSand(sand)
  returnSand(con,mold)
  closeSandbox(con)
}
