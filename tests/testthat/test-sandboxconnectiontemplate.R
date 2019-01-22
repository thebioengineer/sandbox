context("test-sandboxconnectiontemplate")

test_that("Defaults to Local host and a random port", {
  runif(42)
  sbTemplate<-sandboxConnectionTemplate()
  sbTemplate2<-sandboxConnectionTemplate()
  
  expect_equal(sbTemplate$host,"localhost")
  expect_true(sbTemplate$port!=sbTemplate2$port)
  })

test_that("If host is not 'localhost', localnode is the node ID", {
  sbTemplate<-sandboxConnectionTemplate(host="Alternate.Host")

  expect_equal(sbTemplate$host,"Alternate.Host")
  expect_equal(sbTemplate$localnode,getLocalIP())
})
