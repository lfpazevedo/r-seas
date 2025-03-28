# Generate holiday regressors based on holiday summary and user-defined ranges
generate_regressors <- function(holiday_summary, carnival_range, corpus_range) {
  carnival_weights <- genhol(holiday_summary$Carnival,
                             start = carnival_range[1],
                             end = carnival_range[2],
                             center = "calendar")
  corpus_weights <- genhol(holiday_summary$Corpus,
                           start = corpus_range[1],
                           end = corpus_range[2],
                           center = "calendar")
  regs <- cbind(carnival_weights, corpus_weights)
  return(regs)
}
