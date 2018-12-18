context("Ensure Sandboxing")
library(sandbox)

test_that("objects only exist in sandbox", {
  sandbox({
    testVal1<-1
    testVal2<-2
  })

  testthat::expect_error({print(testVal1)}) #object should not exist
  testthat::expect_error({print(testVal2)}) #object should not exist

})

test_that("Objects in current environment will not be overwritten by sandbox", {

  testVal<-42

  sandbox({
    testVal<-1
  })

  testthat::expect_equal(testVal,42) #object should still be 42

})


test_that("libraries loaded in the sandbox remain there", {

  if("tidyverse"%in%installed.packages()[,'Package']){
    sandbox({
      library(tidyverse)
    })
    testthat::expect_false("tidyverse"%in%loadedNamespaces())
  }

})


test_that("Sandbox only returns printed outputs", {
  sbOutput<-sandbox({
    donotreturn<-4
    print(92)
    })

  output<-capture.output(sbOutput)
  testthat::expect_identical(output,"[1] 92")
})

# #need to find a way to diff plot outputs
# test_that("Sandbox returns plot object correctly", {
#   sbOutput<-sandbox({
#     library(ggplot2)
#     ggplot()+
#       geom_point(aes(x=c(1,2,3,4),
#                      y=c(4,2,6,8)))
#   })
#
#   testthat::expect_equal_to_reference(sbOutput,"sandbox_plotTest.rda",update = FALSE)
# })


