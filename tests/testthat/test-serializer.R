context("test-serialize")

# test_that("objects are serialized/compressed consistently", {
#   
#   expect_equal(objectToString("compressthis"),
#                "B Z h 9 1 A Y & S Y \\ˆ OSB É À BLANK BLANK \017 c € ~ 4 @ BLANK BLANK @ \n b Ü BLANK SPC BLANK ! ¦ © é 4 ô & \006 B \u0081 ¦ † F L E 4 f T I ‰ ü ¨ Ä H † 5 ! ì ñ § Ó Ä E G E Ü ‘ N \024 $ DQ \026 ò p BLANK")
#   expect_equal(objectToString(c(1,2,3)),
#                "B Z h 9 1 A Y & S Y k õ ‘ = BLANK BLANK \024 Î BLANK Ú Q BLANK BLANK À BLANK BLANK @ @ BLANK SPC BLANK ! § ¨ F Ô Ð € i ¦ ‰ Þ z ð L „ ° A \f J H } Ú « \r ø » ’ ) Â „ ƒ _ ¬ ‰ è")
#   
# })
# 
# test_that("objects are unserialized/decompressed consistently", {
#   
#   expect_equal(stringToObject("B Z h 9 1 A Y & S Y ˆ OSB É À BLANK BLANK \017 c € ~ 4 @ BLANK BLANK @ \n b Ü BLANK SPC BLANK ! ¦ © é 4 ô & \006 B \u0081 ¦ † F L E 4 f T I ‰ ü ¨ Ä H † 5 ! ì ñ § Ó Ä E G E Ü ‘ N \024 $ DQ \026 ò p BLANK"),
#                "compressthis")
#   expect_equal(stringToObject("B Z h 9 1 A Y & S Y k õ ‘ = BLANK BLANK \024 Î BLANK Ú Q BLANK BLANK À BLANK BLANK @ @ BLANK SPC BLANK ! § ¨ F Ô Ð € i ¦ ‰ Þ z ð L „ ° A \f J H } Ú « \r ø » ’ ) Â „ ƒ _ ¬ ‰ è"),
#                c(1,2,3))
#   
# })
