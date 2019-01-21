context("test-sandbox-handler")

sandbox_wrap<-function(x){substitute(x)} #performs processing done in sandbox function prior


test_that("printing in the evaluator returns the printed output",{
  
  expr<-sandbox_wrap({
    testDF <- data.frame(x = 1:5, y = 6:10)
    print(testDF)
  })
  
  func<-sandbox:::functionalizeInput(expr)
  
  evalOut<-evaluate(func,output_handler = sandbox:::sandbox_handler())
  
  expect_equivalent(evalOut[[3]],"  x  y\n1 1  6\n2 2  7\n3 3  8\n4 4  9\n5 5 10\n")
})

test_that("Captures the actual object for returning if not printed",{
  expr<-sandbox_wrap({
    testDF <- data.frame(x = 1:5, y = 6:10)
    testDF
  })
  
  func<-sandbox:::functionalizeInput(expr)
  
  evalOut<-evaluate(func,output_handler = sandbox:::sandbox_handler())
  
  expect_equivalent(evalOut[[3]],data.frame(x = 1:5, y = 6:10))
})