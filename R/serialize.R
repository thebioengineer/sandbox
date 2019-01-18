#' Serialize Object to a string to transmit over socket
#'
#' @param object The object to be serialized
#'
#' @import Unicode
#' @import stringi
#'
#' @return serialized object string
objectToString<-function(object){
  serialized <- serialize(object, NULL)
  compressedserializedData<-rawToChar(memCompress(serialized,type = "bzip2"),TRUE)
  compressedserializedData[which(compressedserializedData=="")]<-'BLANK'
  compressedserializedData[which(compressedserializedData==" ")]<-"SPC"
  compressedserializedData[which(compressedserializedData=='"')]<-"DQ"
  compressedserializedData[which(compressedserializedData=="]")]<-"CSB"
  compressedserializedData[which(compressedserializedData=="[")]<-"OSB"
  compressedserializedData[which(compressedserializedData=="'")]<-"SQ"
  compressedserializedData<-stri_join(compressedserializedData, collapse=" ")
  return(compressedserializedData)
}

#' Unserialize Object from a string to transmit over socket
#'
#' @param string A string that once decompressed/unserialized is an object
#'
#' @import Unicode
#' @import stringi
#'
#' @return object that was serialized
stringToObject<-function(string){
  tmpCompressedObject<-stri_split_regex(string," ")[[1]]
  tmpCompressedObject[which(tmpCompressedObject=="DQ")]<-'"'
  tmpCompressedObject[which(tmpCompressedObject=="CSB")]<-"]"
  tmpCompressedObject[which(tmpCompressedObject=="OSB")]<-"["
  tmpCompressedObject[which(tmpCompressedObject=="SQ")]<-"'"
  tmpCompressedObject[which(tmpCompressedObject=="SPC")]<-" "
  tmpCompressedObject[which(tmpCompressedObject=="BLANK")]<-''

  #Convert Chars to Raws, making sure to put in the empty raws --------------
  CompressedemptyRaws<-tmpCompressedObject!=""

  CompressedNonEmptyRaws<-stri_enc_toutf8(stri_join(tmpCompressedObject[CompressedemptyRaws],collapse=""))
  CompressedNonEmptyRaws_char<-charToRaw(CompressedNonEmptyRaws)
  if(length(CompressedNonEmptyRaws_char)!=sum(CompressedemptyRaws)){
    CompressedNonEmptyRaws_char<-charToRaw(stri_enc_tonative(CompressedNonEmptyRaws))
  }

  CompressedrawVector <- raw(length(tmpCompressedObject))
  CompressedrawVector[CompressedemptyRaws]<-CompressedNonEmptyRaws_char

  rawVector<-memDecompress(CompressedrawVector,type = "bzip2")
  unserializedObject<-unserialize(rawVector)
}
