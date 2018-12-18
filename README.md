sandbox R
================
Ellis Hughes

This is an example of running your code within a sandbox. write your code as normal, but wrap it within a "sandbox" function. Your code will now be evaluated within its own R session, and outputs will be returned to your console.

``` r
library(sandbox)

sandbox({
  suppressPackageStartupMessages({
  library(tidyverse)
  })
  
  attach(diamonds)
  
  ggplot(diamonds, aes(x=carat, y=price)) + geom_point()
  
})
```

![](sandbox_files/figure-markdown_github/sandbox-1.png)

    ## [[1]]
    ## 
    ## attr(,"class")
    ## [1] "sandbox.output"

This may seem pointless, but now the output and dirtyness that results from loading large/competing libraries into your environment are contained into small sections of your code, and cannot interfere with other chunks.

``` r
ls()
```

    ## character(0)

``` r
"tidyverse"%in%loadedNamespaces()
```

    ## [1] FALSE

This is just the beginning, with future work to allow the export of specific objects either into the sandbox or out, logging, etc
