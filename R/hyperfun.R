
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
}

