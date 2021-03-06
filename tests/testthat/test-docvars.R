context("test docvars")

test_that("docvars of corpus is a data.frame", {
    expect_that(
        docvars(data_corpus_inaugural),
        is_a('data.frame')
    )
})

test_that("docvars works for metadoc fields", {
    mycorpus <- corpus(c(textone = "This is a paragraph.\n\nAnother paragraph.\n\nYet paragraph.", 
                         texttwo = "Premiere phrase.\n\nDeuxieme phrase."), 
                       docvars = data.frame(country=c("UK", "USA"), year=c(1990, 2000)),
                       metacorpus = list(notes = "Example showing how corpus_reshape() works."))
    metadoc(mycorpus, "test") <- c("A", "B")
    
    expect_identical(
        docvars(mycorpus, "_test"),
        c("A", "B")
    )
})

test_that("metadoc drops dimension for single column", {
    mycorpus <- corpus(c(textone = "This is a paragraph.\n\nAnother paragraph.\n\nYet paragraph.", 
                         texttwo = "Premiere phrase.\n\nDeuxieme phrase."), 
                       docvars = data.frame(country=c("UK", "USA"), year=c(1990, 2000)),
                       metacorpus = list(notes = "Example showing how corpus_reshape() works."))
    metadoc(mycorpus, "test") <- c("A", "B")
    expect_identical(
        metadoc(mycorpus, "test"),
        c("A", "B")
    )
    
    df <- data.frame("_test" = c("A", "B"), row.names = c("textone", "texttwo"), stringsAsFactors = FALSE)
    names(df)[1] <- "_test"
    expect_identical(
        metadoc(mycorpus),
        df
    )
})

test_that("docvars with non-existent field names generate correct error messages", {
    expect_error(
        docvars(data_corpus_inaugural, c("President", "nonexistent")),
        "field\\(s\\) nonexistent not found"
    )

    metadoc(data_corpus_inaugural, "language") <- "english"
    expect_silent(metadoc(data_corpus_inaugural, "language"))
    expect_error(
        metadoc(data_corpus_inaugural, "notametadocname"),
        "field\\(s\\) _notametadocname not found"
    )

    toks <- tokens(data_corpus_inaugural, include_docvars = TRUE)
    expect_error(
        docvars(toks, c("President", "nonexistent")),
        "field\\(s\\) nonexistent not found"
    )
})


test_that("docvars is working with tokens", {
    corp <- data_corpus_inaugural
    toks <- tokens(corp, include_docvars = TRUE)
    expect_equal(docvars(toks), docvars(corp))
    expect_equal(docvars(toks, 'President'), docvars(corp, 'President'))
    
    # Subset
    toks2 <- toks[docvars(toks, 'Year') > 2000]
    expect_equal(ndoc(toks2), nrow(docvars(toks2)))
    
    # # Add field to meta-data
    # expect_equal(
    #     docvars(quanteda:::"docvars<-"(toks2, 'Type', 'Speech'), "Type"), 
    #     rep('Speech', 5)
    # )
    # 
    # # Remove meta-data
    # expect_equal(
    #     docvars(quanteda:::"docvars<-"(toks, field = NULL, NULL)), 
    #     NULL
    # )
    # 
    # # Add fresh meta-data
    # expect_equal(
    #     docvars(quanteda:::"docvars<-"(toks, field = "ID", 1:58), "ID"), 
    #     1:58
    # )
}) 

test_that("metadoc for tokens works", {
    
    corp <- data_corpus_irishbudget2010
    metadoc(corp, "language") <- "english"
    toks <- tokens(corp, include_docvars = TRUE)
    
    expect_equal(docvars(toks), docvars(corp))
    expect_equal(metadoc(toks), metadoc(corp))
    
    expect_equal(docvars(toks, 'name'), docvars(corp, 'name'))
    
    # Subset
    toks2 <- toks[metadoc(toks, 'language') == "english"]
    expect_equal(ndoc(toks2), nrow(docvars(toks2)))
}) 

test_that("metadoc works with selection", {
    mycorpus <- corpus(c(textone = "This is a sentence.  Another sentence.  Yet another.", 
                         texttwo = "Premiere phrase.  Deuxieme phrase."), 
                       docvars = data.frame(country=c("UK", "USA"), year=c(1990, 2000)),
                       metacorpus = list(notes = "Example showing how corpus_reshape() works."))
    mycorpus_reshaped <- corpus_reshape(mycorpus, to = "sentences")
    expect_equal(metadoc(mycorpus_reshaped, "document"),
                 c("textone", "textone", "textone", "texttwo", "texttwo"))
    expect_equal(
        metadoc(mycorpus_reshaped, c("document", "segid")),
        data.frame("_document" = c("textone", "textone", "textone", "texttwo", "texttwo"),
                   "_segid" = c(1, 2, 3, 1, 2),
                   check.names = FALSE, stringsAsFactors = FALSE,
                   row.names = c(paste0("textone.", 1:3), paste0("texttwo.", 1:2)))
    )
}) 

test_that("docvars is working with dfm", {
    corp <- data_corpus_irishbudget2010
    toks <- tokens(corp, include_docvars = TRUE)
    thedfm <- dfm(toks)
    
    expect_equal(docvars(toks), docvars(thedfm))
    expect_equal(docvars(toks, 'party'), docvars(corp, 'party'))
    
    thedfm2 <- dfm(corp)
    expect_equal(docvars(corp), docvars(thedfm2))
    expect_equal(docvars(corp, 'party'), docvars(thedfm2, 'party'))

    corp2 <- corpus_subset(corp, party == "LAB")
    thedfm3 <- dfm(corp2)    
    expect_equal(docvars(corp2), docvars(thedfm3))
}) 

test_that("metadoc for dfm works", {
    
    corp <- data_corpus_irishbudget2010
    metadoc(corp, "language") <- "english"
    toks <- tokens(corp, include_docvars = TRUE)
    thedfm <- dfm(corp, include_docvars = TRUE)
    
    expect_equal(metadoc(corp), metadoc(thedfm))
    expect_equal(metadoc(corp, 'language'), metadoc(thedfm, 'language'))
    
    thedfm2 <- dfm(corp)
    expect_equal(docvars(corp), docvars(thedfm2))
    expect_equal(docvars(corp, 'party'), docvars(thedfm2, 'party'))
    
    corp2 <- corpus_subset(corp, party == "LAB")
    thedfm3 <- dfm(corp2)    
    expect_equal(docvars(corp2), docvars(thedfm3))
    
}) 

test_that("creating tokens and dfms with empty docvars", {
    expect_true(
        length(docvars(tokens(data_corpus_irishbudget2010, include_docvars = FALSE))) == 0
    )
    expect_true(
        length(docvars(dfm(data_corpus_irishbudget2010, include_docvars = FALSE))) == 0
    )
    
})

test_that("tokens works works with one docvar", {
    docv1 <- data.frame(dvar1 = c("A", "B"))
    mycorpus1 <- corpus(c(d1 = "This is sample document one.",
                          d2 = "Here is the second sample document."), 
                        docvars = docv1)
    toks1 <- tokens(mycorpus1, include_docvars = TRUE)
    expect_equivalent(docvars(toks1), docv1)
})


test_that("tokens works works with two docvars", {
    docv2 <- data.frame(dvar1 = c("A", "B"),
                        dvar2 = c(1, 2))
    mycorpus2 <- corpus(c(d1 = "This is sample document one.",
                          d2 = "Here is the second sample document."), 
                        docvars = docv2)
    toks2 <- tokens(mycorpus2, include_docvars = TRUE)
    expect_equivalent(docvars(toks2), docv2)
})

test_that("dfm works works with one docvar", {
    docv1 <- data.frame(dvar1 = c("A", "B"))
    mycorpus1 <- corpus(c(d1 = "This is sample document one.",
                          d2 = "Here is the second sample document."), 
                        docvars = docv1)
    dfm1 <- dfm(mycorpus1, include_docvars = TRUE)
    expect_equivalent(docvars(dfm1), docv1)
})


test_that("dfm works works with two docvars", {
    docv2 <- data.frame(dvar1 = c("A", "B"),
                        dvar2 = c(1, 2))
    mycorpus2 <- corpus(c(d1 = "This is sample document one.",
                          d2 = "Here is the second sample document."), 
                        docvars = docv2)
    dfm2 <- dfm(mycorpus2, include_docvars = TRUE)
    expect_equivalent(docvars(dfm2), docv2)
})

test_that("object always have docvars in the same rows as documents", {
    
    txts <- data_char_ukimmig2010
    corp1 <- corpus(txts)
    expect_true(nrow(docvars(corp1)) == ndoc(corp1))
    expect_true(all(rownames(docvars(corp1)) == docnames(corp1)))
    
    corp2 <- corpus_segment(corp1, "\\p{P}", valuetype = "regex")
    expect_true(nrow(docvars(corp2)) == ndoc(corp2))
    expect_true(all(rownames(docvars(corp2)) == docnames(corp2)))
    
    corp3 <- corpus_reshape(corp1, to = "sentences")
    expect_true(nrow(docvars(corp3)) == ndoc(corp3))
    expect_true(all(rownames(docvars(corp3)) == docnames(corp3)))
    
    corp4 <- corpus_sample(corp1, size = 5)
    expect_true(nrow(docvars(corp4)) == ndoc(corp4))
    expect_true(all(rownames(docvars(corp4)) == docnames(corp4)))
    
    toks1 <- tokens(txts)
    expect_true(nrow(docvars(toks1)) == ndoc(toks1))
    expect_true(all(rownames(docvars(toks1)) == docnames(toks1)))
    
    toks2 <- tokens(corpus(txts))
    expect_true(nrow(docvars(toks2)) == ndoc(toks2))
    expect_true(all(rownames(docvars(toks2)) == docnames(toks2)))
    
    toks3 <- quanteda:::tokens_group(toks1, rep(c(1, 2, 3), 3))
    expect_true(nrow(docvars(toks3)) == ndoc(toks3))
    expect_true(all(rownames(docvars(toks3)) == docnames(toks3)))
    
    toks4 <- tokens_select(toks1, stopwords())
    expect_true(nrow(docvars(toks4)) == ndoc(toks4))
    expect_true(all(rownames(docvars(toks4)) == docnames(toks4)))
    
    dfm1 <- dfm(txts)
    expect_true(nrow(docvars(dfm1)) == ndoc(dfm1))
    expect_true(all(rownames(docvars(toks3)) == docnames(toks3)))
    
    dfm2 <- dfm(tokens(txts))
    expect_true(nrow(docvars(dfm2)) == ndoc(dfm2))
    expect_true(all(rownames(docvars(dfm2)) == docnames(dfm2)))
    
    dfm3 <- dfm(corpus(txts))
    expect_true(nrow(docvars(dfm3)) == ndoc(dfm3))
    expect_true(all(rownames(docvars(dfm3)) == docnames(dfm3)))
    
    dfm4 <- dfm_group(dfm1, rep(c(1, 2, 3), 3))
    expect_true(nrow(docvars(dfm4)) == ndoc(dfm4))
    expect_true(all(rownames(docvars(dfm4)) == docnames(dfm4)))
    
    dfm5 <- dfm(dfm1, group = rep(c(1, 2, 3), 3))
    expect_true(nrow(docvars(dfm5)) == ndoc(dfm5))
    expect_true(all(rownames(docvars(dfm5)) == docnames(dfm5)))
    
    dfm6 <- dfm_subset(dfm1, rep(c(TRUE, TRUE, FALSE), 3))
    expect_true(nrow(docvars(dfm6)) == ndoc(dfm6))
    expect_true(all(rownames(docvars(dfm6)) == docnames(dfm6)))
    
    dfm7 <- rbind(dfm1, dfm1)
    expect_true(nrow(docvars(dfm7)) == ndoc(dfm7))
    
    dfm8 <- suppressWarnings(cbind(dfm1, dfm1))
    expect_true(nrow(docvars(dfm8)) == ndoc(dfm8))
    
})

test_that("error when nrow and ndoc mismatch", {
    
    toks <- tokens(c("a b c", "b c d", "c d e"))
    expect_error(docvars(toks) <- data.frame(var = c(1, 5)))
    expect_silent(docvars(toks) <- data.frame(var = c(1, 5, 6)))
    expect_error(docvars(toks) <- data.frame(var = c(1, 5, 6, 3)))
    
    mt <- dfm(toks)
    expect_error(docvars(mt) <- data.frame(var = c(1, 5)))
    expect_silent(docvars(mt) <- data.frame(var = c(1, 5, 6)))
    expect_error(docvars(mt) <- data.frame(var = c(1, 5, 6, 3)))
    
})

test_that("assignment of NULL only drop columns", {
    
    toks <- tokens(data_corpus_irishbudget2010)
    docvars(toks) <- NULL
    expect_identical(dim(docvars(toks)), c(14L, 0L))
    
    mt <- dfm(data_corpus_irishbudget2010)
    docvars(mt) <- NULL
    expect_identical(dim(docvars(mt)), c(14L, 0L))
    
})

test_that("can assign docvars when value is a dfm (#1417)", {
    mycorp <- corpus(data_char_ukimmig2010)

    thedfm <- dfm(mycorp)[, "the"]
    docvars(mycorp) <- thedfm
    expect_identical(
        docvars(mycorp),
        data.frame(the = as.vector(thedfm), row.names = docnames(mycorp))
    )
    
    anddfm <- dfm(mycorp)[, "and"]
    docvars(anddfm) <- anddfm
    expect_identical(
        docvars(anddfm),
        data.frame(and = as.vector(anddfm), row.names = 1:ndoc(mycorp)) # docnames(mycorp))
    )

    toks <- tokens(mycorp)
    docvars(toks) <- anddfm
    expect_identical(
        docvars(toks),
        data.frame(and = as.vector(anddfm), row.names = 1:ndoc(mycorp)) # docnames(mycorp))
    )
})

test_that("docvar assignment is fully robust including to renaming (#1603)", {
    # assigning a data.frame to blank docars
    corp <- corpus(c("A b c d.", "A a b. B c."))
    docvars(corp) <- data.frame(testdv = 10:11)
    expect_identical(
        docvars(corp),
        data.frame(testdv = 10:11, row.names = docnames(corp))
    )
    
    # assigning a vector to blank docars
    corp <- corpus(c("A b c d.", "A a b. B c."))
    docvars(corp) <- c("x", "y")
    expect_identical(
        docvars(corp),
        data.frame(V1 = c("x", "y"), row.names = docnames(corp), stringsAsFactors = FALSE)
    )
    
    # renaming a docvar
    corp <- corpus(c("A b c d.", "A a b. B c."),
               docvars = data.frame(testdv = 10:11))
    names(docvars(corp))[1] <- "renamed_dv"
    expect_identical(
        docvars(corp),
        data.frame(renamed_dv = 10:11, row.names = docnames(corp))
    )
    expect_identical(
        texts(corp),
        c(text1 = "A b c d.", text2 = "A a b. B c.")
    )
})

test_that("docvars<-.corpus error trapping works", {
    expect_error(
        docvars(data_corpus_irishbudget2010, "texts") <- 
            paste0("newtext", seq_len(ndoc(data_corpus_irishbudget2010))),
        "You should use texts"
    )
    
    # preexisting docvars keep unique names
    corp <- corpus(c("A b c d.", "A a b. B c."))
    docvars(corp) <- data.frame(docvar1 = 1:2)
    docvars(corp)[2] <- 11:12
    docvars(corp)[3] <- c("a", "b")
    expect_identical(
        docvars(corp),
        data.frame(docvar1 = 1:2, V2 = 11:12, V3 = c("a", "b"), stringsAsFactors = FALSE, 
                   row.names = c("text1", "text2"))
    )
})

test_that("docvars<- NULL removes docvars", {
    # can NULL the only docvar
    corp <- corpus(c("A b c d.", "A a b. B c."),
                   docvars = data.frame(testdv = 10:11))
    docvars(corp)["testdv"] <- NULL
    expect_identical(
        docvars(corp),
        data.frame(row.names = docnames(corp))
    )

    corp <- corpus(c("A b c d.", "A a b. B c."),
                   docvars = data.frame(testdv = 10:11))
    docvars(corp, "testdv") <- NULL
    expect_identical(
        docvars(corp),
        data.frame(row.names = docnames(corp))
    )

        
    # can NULL one of severeal docvars
    corp <- corpus(c("A b c d.", "A a b. B c."),
                   docvars = data.frame(testdv = 10:11, seconddv = letters[1:2]))
    docvars(corp)["seconddv"] <- NULL
    expect_identical(
        docvars(corp),
        data.frame(testdv = 10:11, row.names = docnames(corp))
    )
    
    # can NULL one of severeal docvars
    corp <- corpus(c("A b c d.", "A a b. B c."),
                   docvars = data.frame(testdv = 10:11, seconddv = letters[1:2]))
    docvars(corp, "seconddv") <- NULL
    expect_identical(
        docvars(corp),
        data.frame(testdv = 10:11, row.names = docnames(corp))
    )
    
    # can NULL all docvars
    corp <- corpus(c("A b c d.", "A a b. B c."),
                   docvars = data.frame(testdv = 10:11, seconddv = letters[1:2]))
    docvars(corp) <- NULL
    expect_identical(
        docvars(corp),
        data.frame(row.names = docnames(corp))
    )
})
