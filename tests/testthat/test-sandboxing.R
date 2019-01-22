context("test-sandboxing")

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



test_that("sandbox session will only close if 'complete' is sent", {
  
  wrapper3<-function(){
    testVal1<-1
    print(testVal1)
  }
  
  # generate new R session to run sandboxed code in
  sandboxCon<-sandbox:::sandboxSession(sandboxConnectionTemplate())
  on.exit({sandbox:::destroySandbox(sandboxCon)}) #ensure session closes
  sandbox:::sendSand(wrapper3,sandboxCon)
  output<-sandbox:::receiveSand(sandboxCon)
  
  #sending a message that is not complete will return it
  serialize("return this message",sandboxCon)
  returnedMessage<-unserialize(sandboxCon)
  
  #sending the "complete" message closes the rsession
  serialize("complete",sandboxCon)
  returnedMessage2<-try(unserialize(sandboxCon),silent = TRUE)

  #message returned if not "complete"
  testthat::expect_equal(returnedMessage,"return this message") 
  
  #no messages to capture if completed"
  testthat::expect_equal(class(returnedMessage2),"try-error") 
  
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



test_that("sandbox session will persist for a short period of time", {
  
  wrapper3<-function(){
    testVal1<-1
    print(testVal1)
  }
  
  # generate new R session to run sandboxed code in
  sbTemplate<-sandboxConnectionTemplate()
  makeExternalRSession(sbTemplate)
  Sys.sleep(1) #wait 1 second(s) to make connection
  con <- try(socketConnection(host = sbTemplate$host,
                          port = sbTemplate$port,
                          server=TRUE,
                          blocking=TRUE,
                          open="a+b",
                          timeout=5),silent = TRUE)
  
  #able to connect even after a small delay
  testthat::expect_equal(class(con),c("sockconn","connection")) 

  sandboxCon<-sandbox:::sandboxSession(sbTemplate)
  on.exit({sandbox:::destroySandbox(sandboxCon)}) #ensure session closes
  sandbox:::sendSand(wrapper3,sandboxCon)
  output<-sandbox:::receiveSand(sandboxCon)
  serialize("complete",sandboxCon)
  
})



test_that("Sandbox evaluates input functions properly",{ 
  
  output<-capture.output(sandbox({
    set.seed(42)
    generateDF<-function(ncols=1,nrows=1){
      do.call('cbind',lapply(seq(1,ncols),function(x,y){runif(y)},nrows))
    }
    testDF <- generateDF(1,1)
    print(testDF)
  }))
  
  testthat::expect_identical(output,c("         [,1]","[1,] 0.914806"))
})



test_that("Sandbox does not import objects/functions from current session",{ 
  
  testFunc<-function(){
    print("Dont Evaluate Me")
  }
  testObject<-42
  
  output1<-sandbox({
    testFunc()
  })
  
  output2<-sandbox({
    print(testObject)
  })
  
  expect_match(output1$outputs[[1]][[1]],"could not find function")
  expect_match(output2$outputs[[1]][[1]],"object '.+' not found")

})