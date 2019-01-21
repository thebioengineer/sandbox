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

test_that("Expressions containing functions are properly generated", {
  
  expr<-sandbox_wrap({
    set.seed(42)
    generateDF<-function(ncols=1,nrows=1){
      do.call('cbind',lapply(seq(1,ncols),function(x,y){runif(y)},nrows))
    }
    testDF <- generateDF(10,10)
    print(testDF)
  })
  
  funcionalized<-function(){
    set.seed(42)
    generateDF<-function(ncols=1,nrows=1){
      do.call('cbind',lapply(seq(1,ncols),function(x,y){runif(y)},nrows))
    }
    testDF <- generateDF(10,10)
    print(testDF)
  }
  
  expect_equivalent(functionalizeInput(expr),funcionalized)
  
})


test_that("Character vectors read in as path to source and are returned as functions", {
  funcionalized<-function(){
    testDF <- data.frame(x = 1:5, y = runif(5))
    print(testDF)
  }
  expect_equivalent(functionalizeInput("test_scripts/sample_script_1.R"),funcionalized)
})

test_that("Character vectors read in as path source and are returned as functions - complex source", {
  funcionalized<-function(){
    set.seed(42)
    generateDF<-function(ncols=1,nrows=1){
      do.call('cbind',lapply(seq(1,ncols),function(x,y){runif(y)},nrows))
    }
    testDF <- generateDF(10,10)
    print(testDF)
  }
  expect_equivalent(functionalizeInput("test_scripts/sample_script_2.R"),funcionalized)
})

test_that("Unexpected inputs return errors", {
  expect_error(functionalizeInput(42),
               "No Sandboxing Method for inputs of class <numeric>.")
  expect_error(functionalizeInput(factor("factorTime")),
               "No Sandboxing Method for inputs of class <factor>.")
  expect_error(functionalizeInput(list(a="ListTime")),
               "No Sandboxing Method for inputs of class <list>.")
})