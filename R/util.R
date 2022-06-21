
hfName <- (function() {
    i <- 0
    function(name, n) {
        if (is.null(name)) {
            i <<- i + 1
            name <- i
        }
        result <- paste0("HF_", name, "_", 1:n)
        ## In case 'name' is longer than 'n'
        result[1:n]
    }
})()

getName <- function(x) {
    x$name
}

hfOp <- function(op) {
    switch(op,
           "-" = "\\",
           "!" = "~",
           "*" = "@",
           op)
}

## Does a model contain an hfExternal object ?
isExternal <- function(x) {
    UseMethod("isExternal")
}

isExternal.HyperFunObject <- function(x) {
    inherits(x, "HyperFunR")
}

isExternal.HyperFunModel <- function(x) {
    any(unlist(lapply(x$objects, isExternal)))
}

print.HyperFun <- function(x, ...) {
    cat(as.character(x), sep="")
}