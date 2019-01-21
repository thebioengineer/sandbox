context("Returning Objects From Sandbox")

test_that("objects are written to leakEnv by leak", {
  wrapper<-function(){
    testVal1<-1
    leak(testVal1)
  }
  wrapper()
  leakEnv<-sandbox:::accessLeakEnv()
  
  testthat::expect_true("testVal1"%in%ls(leakEnv)) #object should not exist
})

test_that("objects are written to leakEnv by leak when evaluated", {
  wrapper2<-function(){
    testVal2<-2
    leak(testVal2)
  }
  evaluateOutputs<-evaluate(wrapper2())
  leakEnv<-sandbox:::accessLeakEnv()
  
  testthat::expect_true("testVal2"%in%ls(leakEnv)) #object should not exist
})


test_that("objects are returned from sandbox environment", {

  wrapper3<-function(){
    testVal1<-1
    leak(testVal1)
  }

  # generate new R session to run sandboxed code in
  sandboxCon<-sandbox:::sandboxSession()
  on.exit({sandbox:::destroySandbox(sandboxCon)})
  sandbox:::sendSand(wrapper3,sandboxCon)
  output<-sandbox:::receiveSand(sandboxCon)
  serialize("complete",sandboxCon)

  testthat::expect_equal(ls(output[['leak']]),"testVal1") #object should not exist
})


test_that("Sandbox only returns specified outputs - numericObject", {

  sandbox({
    donotreturn<-4
    testValue<-84
    leak(testValue)
    })

  
  
  testthat::expect_identical(testValue,84)
  testthat::expect_error({print(donotreturn)})

})

test_that("Sandbox only returns specified outputs - Multiple Objects", {

  sandbox({
    donotreturn<-4
    testValue<-84
    testValue2<-55

    leak(testValue)
    leak(testValue2)
  })

  ls(pos = 1)
  
  testthat::expect_identical(testValue,84)
  testthat::expect_identical(testValue2,55)
  testthat::expect_error({print(donotreturn)})

})

test_that("Sandbox only returns specified outputs - plots", {

  testthat::expect_false('ggReturn'%in%ls())

  sandbox({
    library(ggplot2)
    ggReturn<-ggplot()+
      geom_point(aes(x=1,y=1))
    leak(ggReturn)
  })

  testthat::expect_true('ggReturn'%in%ls())

})
