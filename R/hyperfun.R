
hyperfun <- function(args) {
    ## Run 'hfp' synchronously
    suffix <- ""
    if(.Platform$OS.type == "windows")
        suffix <- ".exe"
    binary <- paste0("hfp", suffix)
    call <- system.file("bin", Sys.getenv("R_ARCH"), binary,
                        package="hyperfun")
    system2(call, args)
}

hyperfun.socket <- function(args) {
    ## Run 'hfp' asynchronously and communicate via socket
    suffix <- ""
    if(.Platform$OS.type == "windows")
        suffix <- ".exe"
    binary <- paste0("hfp-client", suffix)
    call <- system.file("bin", Sys.getenv("R_ARCH"), binary,
                        package="hyperfun")
    system2(call, args, wait=FALSE)
    ## Create socket 
    s <- make.socket("localhost", 12345, server=TRUE)
    ## Wait for a response
    reply <- read.socket(s, loop=TRUE)
    print(reply)
    on.exit(close.socket(s))    
}

