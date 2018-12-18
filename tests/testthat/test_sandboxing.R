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
    donotreturn<-4
    print(92)
    })
  testthat::expect_false("ggplot2"%in%loadedNamespaces())
})


test_that("Sandbox returns plot object correctly", {
  sbOutput<-sandbox({
    library(ggplot2)
    ggplot()+
      geom_point(aes(x=c(1,2,3,4),
                     y=c(4,2,6,8)))
  })

  ggplot2::ggplot()+
    ggplot2::geom_point(ggplot2::aes(x=c(1,2,3,4),
                   y=c(4,2,6,8)))

  testOutput<-recordPlot()

  testthat::expect_e(sbOutput[[1]],testOutput)
})


