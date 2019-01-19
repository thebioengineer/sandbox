#methods for handling inputs, either file names or 

functionalizeInput<-function(expr){
  # UseMethod("functionalizeInput")
  switch(class(expr)[1],
         "{"=functionalizeInput.curly(expr),
         "character"=functionalizeInput.character(expr),
         functionalizeInput.default(expr)
         )
}

functionalizeInput.default<-function(expr){
  stop(paste0("<Error> No Sandboxing Method for inputs of class <",class(expr),">.\nPlease provide either an expression or character."))
}

functionalizeInput.curly<-function(expr){
  expr <- eval(substitute(expr))
  func<-eval(call("function",NULL,expr))
  return(func)
}

functionalizeInput.character<-function(expr){
  expr<-parse(text = paste("{",paste(readLines(expr),collapse="\n"),"}"))[[1]]
  func<-eval(call("function",NULL,expr))
  return(func)
}
