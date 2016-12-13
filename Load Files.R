
# Set Working Directory
setwd("F:/Documents/Data work/Coursera Capstone Project/Week 1")

# Read in data
# blogs
con <- file("./Files/final/en_US/en_US.blogs.txt")
blogs <- readLines(con, skipNul=TRUE)
close(con)
# twitter
con <- file("./Files/final/en_US/en_US.twitter.txt")
twitter <- readLines(con, skipNul=TRUE)
close(con)
# news
con <- file("./Files/final/en_US/en_US.news.txt")
news <- readLines(con, skipNul=TRUE)
close(con)

# Profanity
# from https://github.com/LDNOOBW/List-of-Dirty-Naughty-Obscene-and-Otherwise-Bad-Words
con <- file("./Files/profanity.txt")
profanity <- readLines(con)
close(con)