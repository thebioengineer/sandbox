sandbox R
================
Ellis Hughes

This is an example of running your code within a sandbox. write your code as normal, but wrap it within a "sandbox" function. Your code will now be evaluated within its own R session, and outputs will be returned to your console.

``` r
library(sandbox)
```

    ## Loading required package: Unicode

    ## Loading required package: evaluate

    ## Loading required package: stringi

``` r
sandbox({
  suppressPackageStartupMessages({
  library(tidyverse)
  })
  
  attach(diamonds)
  
  ggplot(diamonds, aes(x=carat, y=price)) + geom_point()
  
  diamonds%>%
    mutate(carat_binned=cut(carat, c(0,.5,.9,1,1.5,1.9,2,2.5,3,4,5,6)))%>%
    group_by(carat_binned,cut)%>%
    summarize(avgPrice=mean(price))%>%
    spread(cut,avgPrice)
  
})
```

![](inst/sandbox_files/figure-markdown_github/sandbox-1.png)

    ## # A tibble: 11 x 6
    ## # Groups:   carat_binned [11]
    ##    carat_binned   Fair   Good `Very Good` Premium  Ideal
    ##    <fct>         <dbl>  <dbl>       <dbl>   <dbl>  <dbl>
    ##  1 (0,0.5]       1028.   786.        766.    863.   864.
    ##  2 (0.5,0.9]     2297.  2520.       2548.   2387.  2425.
    ##  3 (0.9,1]       3715.  4586.       4922.   4698.  4861.
    ##  4 (1,1.5]       5003.  5897.       6502.   6260.  7055.
    ##  5 (1.5,1.9]     7899.  9810.      11066.  11039. 11741.
    ##  6 (1.9,2]      11551. 14393.      14903.  14062. 14667.
    ##  7 (2,2.5]      11524. 14483.      15135.  14946. 15568.
    ##  8 (2.5,3]      13212. 15402.      15036.  15987. 16333 
    ##  9 (3,4]        13611  18359       15669   14914. 14427.
    ## 10 (4,5]        17930     NA          NA   15223     NA 
    ## 11 (5,6]        18018     NA          NA      NA     NA

This may seem pointless, but now the output and dirtyness that results from loading large/competing libraries into your environment are contained into small sections of your code, and cannot interfere with other chunks.

``` r
ls()
```

    ## character(0)

``` r
"tidyverse"%in%loadedNamespaces()
```

    ## [1] FALSE

You can also now 'leak' objects out of the sandbox environment into your own. This may be useful if you only want the side effects of running or the end result of an analysis that may be dirty if multiple libraries are used. For example, if you had your own version of a function, you can safely run your code in the sandbox and still expect a save environment outside.

``` r
sandbox({

  #weird function overwriting a normally used function. In this case, transposing a data.frame
  data.frame<-function(...){
    base::data.frame(t(base::data.frame(...)))
  }

  transposedDataFrame<-data.frame(c(1,2,3),c(4,5,6))
  
  leak(transposedDataFrame)
})
```

The result is that now 'transposedDataFrame' is in the environment for access, and we still have a normal data.frame function!

``` r
transposedDataFrame
```

    ##            X1 X2 X3
    ## c.1..2..3.  1  2  3
    ## c.4..5..6.  4  5  6

``` r
data.frame
```

    ## function (..., row.names = NULL, check.rows = FALSE, check.names = TRUE, 
    ##     fix.empty.names = TRUE, stringsAsFactors = default.stringsAsFactors()) 
    ## {
    ##     data.row.names <- if (check.rows && is.null(row.names)) 
    ##         function(current, new, i) {
    ##             if (is.character(current)) 
    ##                 new <- as.character(new)
    ##             if (is.character(new)) 
    ##                 current <- as.character(current)
    ##             if (anyDuplicated(new)) 
    ##                 return(current)
    ##             if (is.null(current)) 
    ##                 return(new)
    ##             if (all(current == new) || all(current == "")) 
    ##                 return(new)
    ##             stop(gettextf("mismatch of row names in arguments of 'data.frame', item %d", 
    ##                 i), domain = NA)
    ##         }
    ##     else function(current, new, i) {
    ##         if (is.null(current)) {
    ##             if (anyDuplicated(new)) {
    ##                 warning(gettextf("some row.names duplicated: %s --> row.names NOT used", 
    ##                   paste(which(duplicated(new)), collapse = ",")), 
    ##                   domain = NA)
    ##                 current
    ##             }
    ##             else new
    ##         }
    ##         else current
    ##     }
    ##     object <- as.list(substitute(list(...)))[-1L]
    ##     mirn <- missing(row.names)
    ##     mrn <- is.null(row.names)
    ##     x <- list(...)
    ##     n <- length(x)
    ##     if (n < 1L) {
    ##         if (!mrn) {
    ##             if (is.object(row.names) || !is.integer(row.names)) 
    ##                 row.names <- as.character(row.names)
    ##             if (anyNA(row.names)) 
    ##                 stop("row names contain missing values")
    ##             if (anyDuplicated(row.names)) 
    ##                 stop(gettextf("duplicate row.names: %s", paste(unique(row.names[duplicated(row.names)]), 
    ##                   collapse = ", ")), domain = NA)
    ##         }
    ##         else row.names <- integer()
    ##         return(structure(list(), names = character(), row.names = row.names, 
    ##             class = "data.frame"))
    ##     }
    ##     vnames <- names(x)
    ##     if (length(vnames) != n) 
    ##         vnames <- character(n)
    ##     no.vn <- !nzchar(vnames)
    ##     vlist <- vnames <- as.list(vnames)
    ##     nrows <- ncols <- integer(n)
    ##     for (i in seq_len(n)) {
    ##         xi <- if (is.character(x[[i]]) || is.list(x[[i]])) 
    ##             as.data.frame(x[[i]], optional = TRUE, stringsAsFactors = stringsAsFactors)
    ##         else as.data.frame(x[[i]], optional = TRUE)
    ##         nrows[i] <- .row_names_info(xi)
    ##         ncols[i] <- length(xi)
    ##         namesi <- names(xi)
    ##         if (ncols[i] > 1L) {
    ##             if (length(namesi) == 0L) 
    ##                 namesi <- seq_len(ncols[i])
    ##             vnames[[i]] <- if (no.vn[i]) 
    ##                 namesi
    ##             else paste(vnames[[i]], namesi, sep = ".")
    ##         }
    ##         else if (length(namesi)) {
    ##             vnames[[i]] <- namesi
    ##         }
    ##         else if (fix.empty.names && no.vn[[i]]) {
    ##             tmpname <- deparse(object[[i]], nlines = 1L)[1L]
    ##             if (substr(tmpname, 1L, 2L) == "I(") {
    ##                 ntmpn <- nchar(tmpname, "c")
    ##                 if (substr(tmpname, ntmpn, ntmpn) == ")") 
    ##                   tmpname <- substr(tmpname, 3L, ntmpn - 1L)
    ##             }
    ##             vnames[[i]] <- tmpname
    ##         }
    ##         if (mirn && nrows[i] > 0L) {
    ##             rowsi <- attr(xi, "row.names")
    ##             if (any(nzchar(rowsi))) 
    ##                 row.names <- data.row.names(row.names, rowsi, 
    ##                   i)
    ##         }
    ##         nrows[i] <- abs(nrows[i])
    ##         vlist[[i]] <- xi
    ##     }
    ##     nr <- max(nrows)
    ##     for (i in seq_len(n)[nrows < nr]) {
    ##         xi <- vlist[[i]]
    ##         if (nrows[i] > 0L && (nr%%nrows[i] == 0L)) {
    ##             xi <- unclass(xi)
    ##             fixed <- TRUE
    ##             for (j in seq_along(xi)) {
    ##                 xi1 <- xi[[j]]
    ##                 if (is.vector(xi1) || is.factor(xi1)) 
    ##                   xi[[j]] <- rep(xi1, length.out = nr)
    ##                 else if (is.character(xi1) && inherits(xi1, "AsIs")) 
    ##                   xi[[j]] <- structure(rep(xi1, length.out = nr), 
    ##                     class = class(xi1))
    ##                 else if (inherits(xi1, "Date") || inherits(xi1, 
    ##                   "POSIXct")) 
    ##                   xi[[j]] <- rep(xi1, length.out = nr)
    ##                 else {
    ##                   fixed <- FALSE
    ##                   break
    ##                 }
    ##             }
    ##             if (fixed) {
    ##                 vlist[[i]] <- xi
    ##                 next
    ##             }
    ##         }
    ##         stop(gettextf("arguments imply differing number of rows: %s", 
    ##             paste(unique(nrows), collapse = ", ")), domain = NA)
    ##     }
    ##     value <- unlist(vlist, recursive = FALSE, use.names = FALSE)
    ##     vnames <- unlist(vnames[ncols > 0L])
    ##     if (fix.empty.names && any(noname <- !nzchar(vnames))) 
    ##         vnames[noname] <- paste0("Var.", seq_along(vnames))[noname]
    ##     if (check.names) {
    ##         if (fix.empty.names) 
    ##             vnames <- make.names(vnames, unique = TRUE)
    ##         else {
    ##             nz <- nzchar(vnames)
    ##             vnames[nz] <- make.names(vnames[nz], unique = TRUE)
    ##         }
    ##     }
    ##     names(value) <- vnames
    ##     if (!mrn) {
    ##         if (length(row.names) == 1L && nr != 1L) {
    ##             if (is.character(row.names)) 
    ##                 row.names <- match(row.names, vnames, 0L)
    ##             if (length(row.names) != 1L || row.names < 1L || 
    ##                 row.names > length(vnames)) 
    ##                 stop("'row.names' should specify one of the variables")
    ##             i <- row.names
    ##             row.names <- value[[i]]
    ##             value <- value[-i]
    ##         }
    ##         else if (!is.null(row.names) && length(row.names) != 
    ##             nr) 
    ##             stop("row names supplied are of the wrong length")
    ##     }
    ##     else if (!is.null(row.names) && length(row.names) != nr) {
    ##         warning("row names were found from a short variable and have been discarded")
    ##         row.names <- NULL
    ##     }
    ##     class(value) <- "data.frame"
    ##     if (is.null(row.names)) 
    ##         attr(value, "row.names") <- .set_row_names(nr)
    ##     else {
    ##         if (is.object(row.names) || !is.integer(row.names)) 
    ##             row.names <- as.character(row.names)
    ##         if (anyNA(row.names)) 
    ##             stop("row names contain missing values")
    ##         if (anyDuplicated(row.names)) 
    ##             stop(gettextf("duplicate row.names: %s", paste(unique(row.names[duplicated(row.names)]), 
    ##                 collapse = ", ")), domain = NA)
    ##         row.names(value) <- row.names
    ##     }
    ##     value
    ## }
    ## <bytecode: 0x00000000180f2a88>
    ## <environment: namespace:base>

This is just the beginning, with future work to allow the import of specific objects to the sandbox session, logging, etc
