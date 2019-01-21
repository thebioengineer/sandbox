#' sandbox_evaluate_handler
#' 
#' expand upon basic output_handler from evaluate. Really only adds returning the actual value to return
#' 
sandbox_handler<-function(){
  evaluate::new_output_handler(
    value = function(x){
      withVisible(x)$`value`
    })
}



