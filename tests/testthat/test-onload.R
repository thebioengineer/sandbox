context("test-onload")

test_that(".onLoad sets the options properly", {
  
  nodeID<-options("Sandbox_masterNode")[[1]]

  on.exit({
    options("Sandbox_masterNode"=nodeID)
  })
  
  sandbox:::.onLoad("testlib","testPackage")
  
  expect_true(options("Sandbox_masterNode")[[1]]==Sys.info()[["nodename"]])

})
