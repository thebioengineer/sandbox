context("test-functionalizeinput")

sandbox_wrap<-function(x){substitute(x)} #performs processing done in sandbox function prior

test_that("Expressions are returned as functions", {
  
  expr<-sandbox_wrap({
    testDF <- data.frame(x = 1:5, y = runif(5))
    print(testDF)
  })
  
  funcionalized<-function(){
    testDF <- data.frame(x = 1:5, y = runif(5))
    print(testDF)
  }
  
  expect_equivalent(functionalizeInput(expr),funcionalized)

})

test_that("Character vectors read in source and are returned as functions", {
  
  funcionalized<-function(){
    testDF <- data.frame(x = 1:5, y = runif(5))
    print(testDF)
  }
  
  expect_equivalent(functionalizeInput("sample_script_1.R"),funcionalized)
})

test_that("Unexpected inputs return errors", {
  expect_error(functionalizeInput(42),"No Sandboxing Method for inputs of class <numeric>.")
  expect_error(functionalizeInput(factor("factorTime")),"No Sandboxing Method for inputs of class <factor>.")
  expect_error(functionalizeInput(list(a="ListTime")),"No Sandboxing Method for inputs of class <list>.")
})
