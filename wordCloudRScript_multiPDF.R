##This code creates a word cloud from a single pdf in R
##These instructions came from the following source
##https://www.ryananddebi.com/2017/07/21/r-linux-creating-a-wordcloud-from-pdf/
##6/7/2023
##As a first step, create easy names for the pdfs in a folder.
##This helps with troubleshooting

##install packages
install.packages("tm")
install.packages("SnowballC")
install.packages("wordcloud")
install.packages("readtext")

##load packages
library(tm)
library(SnowballC)
library(wordcloud)
library(readtext)

##ensure that the workding directory is set to the location of the files
##getwd()
##setwd("/home/user/file")


##In the example we load all .pdf files stored in the subject folder
wordbase <- readtext("C:/Users/Heath Nieddu/OneDrive/Documents/PhD/WritingAssignments/Summer2023/Data/Lit3Material/Zotero_DLT_11_67/*.pdf")

##If you want to see the variable to make sure its working
##print(wordbase)
##Also, check the wordbase variable in the environment window (RStudio)
##The observations should equal the number of articles

##Convert the list to a corpus
corp<-Corpus(VectorSource(wordbase))

##Cleanup the corpus with the tm package

##First, convert to plain text
corp<-tm_map(corp,PlainTextDocument)

##Remove punctuation
corp<-tm_map(corp,removePunctuation)

##Remove numbers
corp<-tm_map(corp,removeNumbers)

##Make all lower case
corp<-tm_map(corp,tolower)

##Remove stop words
corp<-tm_map(corp,removeWords,stopwords(kind="en"))

##If you want to remove specific words
##corp<-tm_map(corp,removeWords,c("word1","word2","word3"))

##Beginformatting operations for wordcloud
##First, create color variable palatte
color<-brewer.pal(8,"Spectral")

##Tell R you're going to want a png file created in the wording directory
png("wordcloud.png", width=1280,height=800)

##Create wordcloud
wordcloud(corp,max.words=100,min.freq=15,random.order=FALSE,colors=color,scale=c(8,.3))

##This passes the word cloud just created to the png file
dev.off()

