## Defines a classes cDMatrix & rDMatrix ###############################################################
# The class inherits from list, each element of the list is an FF object
# cDMatrix splits the matrix by columns, rDMatrix by rows

setClass('cDMatrix', slots = 'list', contains = 'list')  
setClass('rDMatrix', slots = 'list', contains = 'list')  

## Idea we can define in the future a class for a collection of rDMatrices or cDMatrices (dDatabase)
# Defines the class genData, which has three slots:
setClass('genData', slots = c(pheno = 'data.frame', map = 'data.frame', geno = 'list'))

# Defines method dim() (extract # of rows and number of columns) of an object getnosFF ##
dim.cDMatrix <- function(x){
   n <- nrow(x[[1]])
   p <- 0
   for(i in 1:length(x)){
     p <- p + ncol(x[[i]])
   }
   return(c(n, p))
}

dim.rDMatrix <- function(x){
   p <- ncol(x[[1]])
   n <- 0
   for(i in 1:length(x)){
     n <- n + nrow(x[[i]])
   }
   return(c(n, p))
}

## sets method dim for cDMatrix and rDMatrix objects
 setMethod(f = "dim", signature("cDMatrix"), definition = dim.cDMatrix)
 setMethod(f = "dim", signature("rDMatrix"), definition = dim.rDMatrix)


# chunks: returns which columns are contained in each chunk of a cDMatrix or rDMatrix object
chunks <- function(x){
	if(class(x) == 'cDMatrix'){
        n <- length(x)
        OUT <- matrix(nrow = n, ncol = 3, NA)
        colnames(OUT) <- c('chunk', 'col.ini', 'col.end')
        end <- 0
        for(i in 1:n){
                ini <- end + 1
                end <- ini + ncol(x[[i]]) - 1
                OUT[i, ] <- c(i, ini, end)
        }
    }
	if(class(x) == 'rDMatrix'){
        n <- length(x)
        OUT <- matrix(nrow = n, ncol = 3, NA)
        colnames(OUT) <- c('chunk', 'row.ini', 'row.end')
        end <- 0
        for(i in 1:n){
            ini <- end + 1
            end <- ini + nrow(x[[i]]) - 1
            OUT[i, ] <- c(i, ini, end)
        }
    }
    return(OUT)
}

# colnames method for cDMatrix and rDMatrix
 get.colnames.cDMatrix <- function(x){
	out <- NULL
	if(!is.null(colnames(x[[1]]))){
		p <- dim(x)[2]
		out <- rep('', p)
		TMP <- chunks(x)
		for(i in 1:nrow(TMP)){
			out[(TMP[i, 2]:TMP[i, 3])] <- colnames(x[[i]])
		}
	}
	return(out)
  }
  
  get.colnames.rDMatrix <- function(x){
	out <- colnames(x[[1]])
	return(out)
  }
  
 setMethod(f = "colnames", signature("cDMatrix"), definition = get.colnames.cDMatrix)
 setMethod(f = "colnames", signature("rDMatrix"), definition = get.colnames.rDMatrix)

# rownames method for cDMatrix and rDMatrix
get.rownames.cDMatrix <- function(x){
    out <- rownames(x[[1]])
	return(out)
}

get.rownames.rDMatrix <- function(x){
    out <- NULL
    if(!is.null(rownames(x[[1]]))){ 
		n <- dim(x)[1]
		out <- rep('', n)
		TMP <- chunks(x)
		for(i in 1:nrow(TMP)){
			out[(TMP[i, 2]:TMP[i, 3])] <- rownames(x[[i]])
		}
	}
    return(out)
}
  
set.rownames.cDMatrix <- function(x, ...){
    for(i in 1:length(out)){
		rownames(out[[i]]) <- value
	}
}
  
set.rownames.rDMatrix <- function(x, names){
   	TMP <- chunks(x)
	for(i in 1:nrow(TMP)){
		out[(TMP[i, 2]:TMP[i, 3])] <- names
	}
}
setMethod(f = "rownames", signature("cDMatrix"), definition = get.rownames.cDMatrix)
#setMethod(f = "rownames <- ", signature("cDMatrix"), definition = set.rownames.cDMatrix)
setMethod(f = "rownames", signature("rDMatrix"), definition = get.rownames.rDMatrix)
#setMethod(f = "rownames <- ", signature("rDMatrix"), definition = set.rownames.rDMatrix)


# colindeces: finds the position of a set of columns in an object cDMatrix
colindices <- function(x, columns){
    TMP <- chunks(x)
    nCol <- (TMP[nrow(TMP), ncol(TMP)])
    INDEX <- matrix(nrow = nCol, ncol = 3)
    colnames(INDEX) <- c('chunk', 'col.global', 'col.local')
    INDEX[, 2] <- 1:nCol
    end <- 0
    for(i in 1:length(x)){
        ini <- end + 1
        end <- ini + TMP[i, 3] - TMP[i, 2]
        INDEX[ini:end, 1] <- i
        INDEX[ini:end, 3] <- 1:ncol(x[[i]])
    }
    if(!is.null(columns)){ INDEX <- INDEX[columns, ] }
    if(is.vector(INDEX)){
        tmp <- names(INDEX)
	    INDEX <- matrix(INDEX, ncol = 3)
    	colnames(INDEX) <- tmp
    }
    return(INDEX)
}

# rowindices: finds the position of a set of rows in an object rDMatrix
rowindices <- function(x, rows){
    TMP <- chunks(x)
    nRow <- (TMP[nrow(TMP), ncol(TMP)])
    INDEX <- matrix(nrow = nRow, ncol = 3)
    colnames(INDEX) <- c('chunk', 'row.global', 'row.local')
    INDEX[, 2] <- 1:nRow
    end <- 0
    for(i in 1:length(x)){
        ini <- end + 1
        end <- ini + TMP[i, 3] - TMP[i, 2]
        INDEX[ini:end, 1] <- i
        INDEX[ini:end, 3] <- 1:nrow(x[[i]])
    }
    if(!is.null(rows)){ INDEX <- INDEX[rows, ] }
    if(is.vector(INDEX)){
        tmp <- names(INDEX)
	    INDEX <- matrix(INDEX, ncol = 3)
    	colnames(INDEX) <- tmp
    }
    return(INDEX)
}

## subset.cDmatrix: indexing for cDMatrix objects
subset.cDMatrix <- function(x, i = (1:nrow(x)), j = (1:ncol(x))){
    rows <- i
    columns <- j
    n <- length(rows)
    p <- length(columns)
    originalOrder <- (1:p)[order(columns)]
    columns <- sort(columns)
    dimX <- dim(x)
    if( p > dimX[2] | n > dimX[1] ){
        stop('Either the number of columns or number of rows requested exceed the number of rows or columns in x, try dim(x)...')
    }
    Z <- matrix(nrow = n, ncol = p, NA)
    colnames(Z) <- colnames(x)[columns]
    rownames(Z) <- rownames(x)[rows]
    INDEXES <- colindices(x, columns = columns)
    whatChunks <- unique(INDEXES[, 1])
    end <- 0
    for(i in whatChunks){
        TMP <- matrix(data = INDEXES[INDEXES[, 1] == i, ], ncol = 3)
        ini <- end + 1; end <- ini + nrow(TMP) - 1
        Z[, ini:end] <- x[[i]][rows, TMP[, 3]]
    }
    if(length(originalOrder) > 1){        Z <- Z[, originalOrder] }
    return(Z)
}

setMethod(f = "[", signature("cDMatrix"), definition = subset.cDMatrix)
# We should also set "[ <- " for modifying entries of the object


#*# check this one
# subset.rDMatrix: indexing for rDMatrix objects
subset.rDMatrix <- function(x, i = (1:nrow(x)), j = (1:ncol(x))){
    rows <- i
    columns <- j
    n <- length(rows)
    p <- length(columns)
    originalOrder <- (1:n)[order(rows)]
    rows <- sort(rows)
    dimX <- dim(x)
    if( p > dimX[2] | n > dimX[1] ){
        stop('Either the number of columns or number of rows requested exceed the number of rows or columns in x, try dim(x)...')
    }
    Z <- matrix(nrow = n, ncol = p, NA)
    colnames(Z) <- colnames(x)[columns]
    rownames(Z) <- rownames(x)[rows]
    INDEXES <- rowindices(x, rows = rows)
    whatChunks <- unique(INDEXES[, 1])
    end <- 0
    for(i in whatChunks){
        TMP <- matrix(data = INDEXES[INDEXES[, 1] == i, ], ncol = 3)
        ini <- end + 1; end <- ini + nrow(TMP) - 1
        Z[ini:end, ] <- x[[i]][TMP[, 3], columns]
    }
    if(length(originalOrder) > 1){        Z <- Z[originalOrder, ] }
    return(Z)
}

setMethod(f = "[", signature("rDMatrix"), definition = subset.rDMatrix)
 # We should also set "[ <- " for modifuing entries of the object


# setGenData: creates an rDMatrix or cDMatrix from a ped file

setGenData <- function(fileIn, n, header, dataType, distributed.by = 'rows', map = data.frame(), mrkCol = NULL, folderOut = paste('genData_', fileIn, sep = ''), 
                    returnData = TRUE, saveData = TRUE, na.strings = 'NA', nColSkip = 6, idCol = 2, verbose = FALSE, nChunks = NULL, add.map = TRUE){
        ###
        # Use: creates (returns, saves or both) a genData object from an ASCII file
        # fileIn (character): the name of the ped file.
        # n (integer): the number of individuals.
        # dataType : the coding of genotypes, use 'character' for A/C/G/T or 'integer' for numeric coding.
        #            if type = 'numeric' vmode needs must be 'double'.
        # folderOut (charater): the name of the folder where to save the binary files.
        #                     NOTE: associated to this file there will be files containing the acutal data genos_*.bin
        # returnData (logical): if TRUE the function returns a list with genotypes (X), MAP file and subject information (phenos)
        # saveData (logical): if TRUE the function saves the objects listed above into an object (genData.RData)
        # header (logical): TRUE if the 1st line of the ped file is a header
        # na.strings (character): the character string use to denote missing value.
        # nColSkip (integer): the number of columsn to be skipped.
        # idCol (integer): the column that contains the subject ID
        # map (data.frame): map containing marker info
        # nmax (integer): the maximum number of individuals expected. 
        # Requires: package ff
        ###

	dir.create(folderOut)
    vMode <- ifelse( dataType%in%c('character', 'integer'), 'byte', 'double')
    library(ff)
    p <- length(scan(fileIn, what = character(), nlines = 1, skip = ifelse(header, 1, 0), quiet = TRUE)) - nColSkip
    IDs <- rep(NA, n)
    if(header){
        mrkNames <- scan(fileIn, what = character(), nlines = 1, skip = 0, quiet = TRUE)[-(1:nColSkip)]
    }else{
        mrkNames <- paste('mrk_', 1:p, sep = '')
    }
	if(!distributed.by%in%c('columns', 'rows')){stop('distributed.by must be either columns or rows') }
    if(is.null(nChunks)){
		if(distributed.by == 'columns'){
			chunkSize <- min(p, floor(.Machine$integer.max/n/1.2))
			nChunks <- ceiling(p/chunkSize)
		}else{
			chunkSize <- min(n, floor(.Machine$integer.max/p/1.2))
			nChunks <- ceiling(n/chunkSize)		
		}

	}else{
		if(distributed.by == 'columns'){
			chunkSize <- ceiling(p/nChunks)
			if(chunkSize*n > = .Machine$integer.max/1.2){ stop(' More chunks are needed')}
		}else{
			chunkSize <- ceiling(n/nChunks)
			if(chunkSize*p > =  .Machine$integer.max/1.2){ stop(' More chunks are needed')}
		}
	}
    genosList <- list()
    end <- 0
    for(i in 1:nChunks){
        if(distributed.by == 'columns'){
			ini <- end + 1
			end <- min(p, ini + chunkSize - 1)
			genosList[[i]] <- ff(vmode = vMode, dim = c((end - ini + 1), n))
			rownames(genosList[[i]]) <- mrkNames[ini:end]
		}else{
			ini <- end + 1
			end <- min(n, ini + chunkSize - 1)
			genosList[[i]] <- ff(vmode = vMode, dim = c(p, (end - ini + 1)))
			rownames(genosList[[i]]) <- mrkNames
		}
    }
	fileIn <- file(fileIn, open = 'r')
    if(header){
        tmp <- scan(fileIn, nlines = 1, what = character(), quiet = TRUE)
    }
    for(i in 1:n){
		#if(verbose){ cat(' Subject ', i, '\n')}
		time1 <- proc.time()
		x <- scan(fileIn, nlines = 1, what = character(), na.strings = na.strings, quiet = TRUE)
        time2 <- proc.time()
        IDs[i] <- x[idCol]
        
        ## now we split x into its chunks
		end <- 0
		time3 <- proc.time()
		x <- x[-c(1:nColSkip)]
    	if(distributed.by == 'columns'){
			for(j in 1:nChunks){
				ini <- end + 1
				end <- ini + nrow(genosList[[j]]) - 1
				genosList[[j]][, i] <- x[ini:end]
			}
		}else{
			tmpChunk <- ceiling(i/chunkSize)
			tmpCol <- i - (tmpChunk - 1)*chunkSize
			genosList[[tmpChunk]][, tmpCol] <- x
		}
    	time4 <- proc.time()
        if(verbose){ cat(' Subject ', i, '  ', round(time4[3] - time1[3], 3), ' sec/subject.', '\n')}
    }
	close(fileIn)

	# Adding names
	if(distributed.by == 'rows'){
	    end <- 0
		for(i in 1:nChunks){
			ini <- end + 1
			end <- min(ini + ncol(genosList[[i]]) - 1, n)
			colnames(genosList[[i]]) <- IDs[ini:end]
		}
	}else{
		for(i in 1:nChunks){
			colnames(genosList[[i]]) <- IDs
		}
	}
		
	# Now we transopose
	genosList2 <- list()
	end <- 0
	for(i in 1:nChunks){
		timeIn <- proc.time()[3]
		genosList2[[i]] <- t(genosList[[i]]) 
		dataFile <- paste(folderOut, '/geno_', i, '.bin', sep = '')
		file.copy(from = filename(genosList2[[i]]), to = dataFile)
		delete(filename(genosList2[[i]]))
		attr(attributes(genosList2[[i]])$physical, "filename") <- dataFile
		if(verbose){ cat('Transposed chunk ', i, ' of ', nChunks, ' ', round(proc.time()[3] - timeIn, 1), 'second/chunk', '\n') }
	}
	rm(genosList)
    tmp <- new(ifelse(distributed.by == 'columns', 'cDMatrix', 'rDMatrix'), genosList2)
    genData <- new('genData', geno = tmp, map = map)
	
	if((nrow(map) == 0)&add.map){
		genData@map <- data.frame(mrk = mrkNames, maf = as.numeric(NA), freqNA = as.numeric(NA), stringsAsFactors = FALSE)
	}
	if(saveData){ 
		for(i in 1:nChunks){
			attr(attributes(genData@geno[[i]])$physical, "filename") <- paste('geno_', i, '.bin', sep = '')
		}
		save(genData, file = paste(folderOut, '/genData.RData', sep = '')) 
	}
    if(returnData){ return(genData) }
}

## Example: GWAS using function lm

GWAS.lm <- function(baseline.model, phen.data, id.col, gen.data, verbose = TRUE, manhattan.plot = FALSE, min.pValue = 1e - 10){
    #verbose = TRUE
	#phen.data = Y
    #baseline.model = y~x1
    #id.col = 4
    #gen.data = genData@geno
    
    gwas.model <- update(baseline.model, '.~z + .')
    
    phen.data[, id.col] <- as.character(phen.data[, id.col])
    
    IDs.geno <- rownames(gen.data)
    tmp <- which(phen.data[, id.col]%in%IDs.geno)
    if(length(tmp) == 0){ stop('No subject in phen.data is present in gen.data') }
    phen.data <- phen.data[tmp, ]
    
    rows.geno <- which(IDs.geno%in%phen.data[, id.col])
    
    tmp <- order(as.integer(factor(x = phen.data[, id.col], levels = IDs.geno[rows.geno], ordered = TRUE)))
    phen.data <- phen.data[tmp, ]
    stopifnot(all.equal(rownames(gen.data)[rows.geno], phen.data[, id.col]))

    p <- ncol(gen.data)
    OUT <- matrix(nrow = p, ncol = 4, NA)
    rownames(OUT) <- colnames(gen.data)
    colnames(OUT) <- c('Estimate', 'SE', 't - ratio', 'p - value')
    phen.data$z <- NA

    if(manhattan.plot){
       plot(numeric() ~ numeric(), xlim = c(0, p), ylim = c(0,  -log(min.pValue, base = 10)), ylab = ' -log(p - value)', xlab = 'Marker')
    }

    for(i in 1:p){
        time.in <- proc.time()[3]
    	phen.data$z <- gen.data[rows.geno, i]
    	fm <- lm(gwas.model, data = phen.data)
    	OUT[i, ] <- summary(fm)$coef[2, ]
    	if(manhattan.plot){ 
    		points(y = -log(OUT[i, 4], base = 10), col = 2, cex = .5, x = i)
    		x = c(i - 1, i)
    		y = -log(OUT[c(i - 1, i), 4], base = 10)
            if(i > 1){ lines(x = x, y = y, col = 4, lwd = .5) }
    	}	
        if(verbose){ cat(sep = '', 'Marker ', i, ' (', round(proc.time()[3] - time.in, 2), ' seconds/marker, ', round(i/p*100, 3), '% done )\n') }
    }
    return(OUT)    
}

## Computes a Genomic Relationship Matrix
getG <- function(x, n_submatrix = 3, scaleCol = TRUE, verbose = TRUE, minMAF = 1/100){
	#This function takes as input an object of the class cFF or rFF and computes the
	#Genomic relationship matrix
	#Arguments:
	#the cFF object that holds the matrix with Markers (e.g. SNPs or )

	#Obtain the number of rows and columns for the matrix with molecular markers
	rows_cols = dim(x)
	n = rows_cols[1]
	p = rows_cols[2]
	
	to_column = 0;
	delta = ceiling(p/n_submatrix);
	G = matrix(0, nrow = n, ncol = n)
	rownames(G) <- rownames(x)
	colnames(G) <- rownames(x)
	
	K <- 0
	from_column <- 0
    for(k in 1:n_submatrix){
		from_column = to_column + 1;
		to_column = min(p, from_column + delta - 1)
		if(verbose){
			cat("Submatrix: ", k, " (", from_column, ":", to_column, ")\n");
			cat("   = > Aquiring genotypes...\n")
		}
		X = x[, from_column:to_column];
		tmp <- colMeans(X, na.rm = TRUE)/2
		maf <- ifelse(tmp > .5, 1 - tmp, tmp)
		VAR <- apply(X = X, FUN = var, MARGIN = 2, na.rm = TRUE)
		
		tmp <- which((maf < minMAF) | (VAR < 1e - 8))
		if(length(tmp) > 0){
			X <- X[,  - tmp]
			VAR <- VAR[-tmp]
		}

		if(ncol(X) > 0){
			cat("   = > Computing...\n")
			if(scaleCol){
				X <- scale(X, center = TRUE, scale = scaleCol)
			}
			X <- ifelse(is.na(X), 0, X)
			K <- K + ifelse(scaleCol, ncol(X)*(n - 1)/n, sum(VAR))
			G <- G + tcrossprod(X)
		}
		
   }
   G <- G/K
   return(G)
}


##  Utils

simPED <- function(filename, n, p, propNA = .02){
   fileOut <- file(filename, open = 'w')
   for(i in 1:n){
        timeIn <- proc.time()[3]
        geno <- rbinom(n = p, size = 2, prob = .3)
        geno[runif(p) < propNA] <- NA
   		x <- c(0, paste('id_', i, sep = ''), rep(NA, 4), geno)
   		write(x, ncol = length(x), append = TRUE, file = fileOut)
   		cat(i, round(proc.time()[3] - timeIn, 1), '\n')
   }
   close(fileOut)
}