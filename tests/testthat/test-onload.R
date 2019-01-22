context("test-onload")

test_that("multiplication works", {
  
  nodeID<-options("Sandbox_masterNode")[[1]]
  scriptdir<-options("Sandbox_scriptdir")[[1]]
  
  on.exit({
    options("Sandbox_masterNode"=nodeID)
    options("Sandbox_scriptdir"=scriptdir)
  })
  
  sandbox:::.onLoad("testlib","testPackage")
  
  expect_true(options("Sandbox_masterNode")[[1]]==Sys.info()[["nodename"]])
  expect_true(options("Sandbox_scriptdir")[[1]]==file.path("testlib","testPackage"))
  
})
