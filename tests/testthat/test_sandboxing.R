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

  testVal<-"test"
  testVal2<-42

  sandbox({
    testVal <- 1
    testVal2 <- 1
  })

  testthat::expect_equal(testVal,"test") #object should still be "test"
  testthat::expect_equal(testVal2,42) #object should still be "test"


})


test_that("libraries loaded in the sandbox remain there", {

  if("MASS"%in%installed.packages()[,'Package'] &
     !"MASS"%in%loadedNamespaces() ){
    sandbox({
      library(MASS)
    })
    testthat::expect_false("tidyverse"%in%loadedNamespaces())
  }

})


test_that("Sandbox only returns printed value", {
  output<-capture.output(sandbox({
    donotreturn<-4
    print(92)
    }))

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


