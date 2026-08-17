module TagHelpers where

newtype HtmlTag = HtmlTag String

tagPair :: HtmlTag -> (String, String)
tagPair (HtmlTag a) = ("<" ++ a ++ ">", "</" ++ a ++ ">")