context("test-sandbox_object")

test_that("On Initialization saves sessionInfo", {
  sbo<-sandbox:::newSandboxOutput(list(dummyvar="dummy"),new.env())
  expect_identical(sbo$metadata,sessionInfo())
})


test_that("Printing only the 'results' entries", {
  output<-capture.output({sandbox:::newSandboxOutput(list(dummyvar="dummy"),new.env())})
  
  output2<-sandbox:::newSandboxOutput(list(dummyvar=data.frame(c=1:3)),new.env())
  
  expect_identical(output,"dummy")
  expect_identical(capture.output({output2}),
    capture.output({print(data.frame(c=1:3))}))
  
})

test_that("object cleans list of source values", {
  
  cop<-capture.output({evalOutput<-evaluate::evaluate({inVal<-42;print(inVal)})})
  
  sbo<-sandbox:::newSandboxOutput(evalOutput,new.env())
  expect_identical(identical(sbo$outputs,evalOutput),FALSE)
  expect_identical(sbo$outputs,evalOutput[which(sapply(evalOutput,function(x)!inherits(x,"source")))])
  
})


test_that("object stores outputs in 'outputs' slot", {
  
  cop<-capture.output({evalOutput<-evaluate::evaluate({inVal<-42;print(inVal)})})
  
  sbo<-sandbox:::newSandboxOutput(evalOutput,new.env())
  expect_identical(identical(sbo$outputs,evalOutput),FALSE)
  expect_identical(sbo$outputs,evalOutput[which(sapply(evalOutput,function(x)!inherits(x,"source")))])
  
})

test_that("object stores source call in 'source' slot", {
  
  expr<-function(){inVal<-42;print(inVal)}
  
  evalOutput<-evaluate::evaluate(expr)
  
  sbo<-sandbox:::newSandboxOutput(evalOutput,new.env())
  expect_equivalent(sbo$source,expr)
  
})
