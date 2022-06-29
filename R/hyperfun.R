
hfp <- function(x, ...) {
    UseMethod("hfp")
}

hfp.HyperFunObject <- function(x, ...) {
    hfp(hfModel(x), ...)
}

fixDensity <- function(density) {
    density <- as.numeric(density)
    n <- length(density)
    if (n < 1 || n == 2 || n > 3)
        stop("Invalid density")
    rep(density, length.out=3)
}

fixBBox <- function(bbox) {
    bbox <- as.numeric(bbox)
    n <- length(bbox)
    if (n < 1 || (n > 3 && n < 6) || n > 6) {
        stop("Invalid bounding box")
    }
    if (n == 1) {
            rep(c(-bbox, bbox), each=3)
    } else if (n == 2) {
        rep(bbox, each=3)
    } else if (n == 3) {
        as.numeric(cbind(-bbox, bbox))
    } else {
        bbox
    }
}

hfp.HyperFunModel <- function(x, format = "rgl",
                              bbox = 10, density = 30,
                              port = 54321, ...) {
    ## Assemble arguments for 'hfp'
    if (format == "rgl") {
        plot <- TRUE
        format <- "stlb"
    } else {
        plot <- FALSE
    }
    density <- fixDensity(density)
    bbox <- fixBBox(bbox)
    hfFile <- tempfile(fileext = ".hf")
    outFile <- gsub("hf$", format, hfFile)
    params <- c(paste0("-", format), outFile,
                "-b", paste0(bbox, collapse=","),
                "-g", paste0(density, collapse=","))
    ## Write .hf file
    writeLines(as.character(x), hfFile)
    ## Call 'hfp' or 'hfp-client'
    if (isExternal(x)) {
        hyperfun.socket(c(hfFile, params),
                        port = port)
    } else {
        hyperfun(c(hfFile, params))
    }
    ## Render result (optionally)
    if (plot) {
        rgl::readSTL(outFile, ...)
    }
    ## Return output file
    outFile
}

################################################################################
## HyperFun models (combinations of objects)

hfModel <- function(..., op = "|", name = NULL) {
    objects <- list(...)
    if (length(objects) < 1)
        stop("Model must contain at least one object or model")
    if (!all(sapply(objects, inherits, "HyperFunObject") |
             sapply(objects, inherits, "HyperFunModel"))) {
        stop("A model can only contain HyperFun objects and/or models")
    }
    if (length(op) > 1) {
        op <- op[1]
        warning("Ignoring operators after first operator")
    }
    if (op == "!" &&
        (length(objects) > 1 || length(objects[[1]]) > 1))
        stop("Logical not is only valid on single object or model")
    if (!(op %in% c("|", "&", "-", "!", "*"))) {
        stop(paste0("Operator ", op, " not supported"))
    }
    name <- hfName(name, 1)
    model <- list(objects = objects, op = op, name = name)
    class(model) <- c("HyperFunModel", "HyperFun")
    model
}

## NOTE that we MUST call the final model "my_model"
as.character.HyperFunModel <- function(x, ..., top=TRUE) {
    ## Special case unary ! (not)
    if (x$op == "!") {
        modelChar <- paste0(x$name,
                            "(x[3], a[1])\n",
                            "{\n",
                            "  ", x$name, " = ",
                            ## Constructor ensure 'objects' is length 1
                            hfOp(x$op), getName(x$objects[[1]]), "(x, a);\n",
                            "}\n")
    } else {
        modelChar <- paste0(x$name,
                            "(x[3], a[1])\n",
                            "{\n",
                            "  ", x$name, " = ",
                            paste(paste0(unlist(lapply(x$objects, getName)),
                                         "(x, a)"),
                                  collapse = paste0(" ", hfOp(x$op), " ")),
                            ";\n",
                            "}\n")
    }
    if (top) {
        modelChar <- paste0(modelChar,
                            "my_model(x[3], a[1])\n",
                            "{\n",
                            paste0("  my_model = ", x$name, "(x, a);\n"),
                            "}\n")
    }
    c(unlist(lapply(x$objects, as.character, top=FALSE)), 
      modelChar)
}

length.HyperFunModel <- function(x, ...) {
    1
}

################################################################################
## Plot methods

plot.HyperFunObject <- function(x, ...) {
    plot(hfModel(x), ...)
}

plot.HyperFunModel <- function(x, ...) {
    hfp(x, format="rgl", ...)
}
    
################################################################################
## General methods

Ops.HyperFun <- function(e1, e2) {
    if (nargs() < 2) {
        if (!(.Generic == "!"))
            stop("Unary operations not valid on HyperFun objects")
        hfModel(e1, op = .Generic)
    } else {
        if (!(.Generic %in% c("|", "&", "-", "*"))) {
            stop("Operation not supported on HyperFun objects")
        }
        if (inherits(e1, "HyperFun") && inherits(e2, "HyperFun")) {
            hfModel(e1, e2, op = .Generic)
        } else {
            stop("Operations only supported between HyperFun objects")
        }
    }
}

################################################################################
## Call 'hfp' or 'hfp-client'

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

hyperfun.socket <- function(args, port) {
    ## Run 'hfp' asynchronously and communicate via socket
    suffix <- ""
    if(.Platform$OS.type == "windows")
        suffix <- ".exe"
    binary <- paste0("hfp-client", suffix)
    call <- system.file("bin", Sys.getenv("R_ARCH"), binary,
                        package="hyperfun")
    args <- c(args, "-p", port)
    system2(call, args, wait=FALSE)
    ## Create socket 
    s <- make.socket("localhost", port, server=TRUE)
    ## Wait for a response
    while (TRUE) {
        reply <- read.socket(s, loop=TRUE)
        ## "0" response means hfp-client is done
        if (substring(reply, 1, 1) == "0")
            break
        ## "i x y z" response means hfExternal call
        input <- as.numeric(strsplit(reply, " ")[[1]])
        output <- hfRcall(input[-1], input[1])
        write.socket(s, as.character(output))
    }
    on.exit(close.socket(s))    
}

