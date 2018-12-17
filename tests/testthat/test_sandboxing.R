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

  if("ggplot2"%in%installed.packages()[,'Package']){
    sandbox({
      library(ggplot2)
    })
    testthat::expect_false("ggplot2"%in%loadedNamespaces())
  }

})


test_that("Sandbox only returns printed outputs", {
    sbOutput<-sandbox({
      donotreturn<-42
      print()
      })

    testthat::expect_false("ggplot2"%in%loadedNamespaces())
  }

})
