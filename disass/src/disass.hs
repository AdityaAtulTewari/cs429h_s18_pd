module Main where

main :: IO ()
main = do
  args <- getArgs;
  content <- readFile (args !! 0)
  writeFile "output.txt" (map toUpper content)
