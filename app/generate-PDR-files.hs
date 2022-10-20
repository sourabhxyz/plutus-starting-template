module Main where

import           Cardano.Api
import           PDR.Compiler

main :: IO ()
main = do
  writeDatum
  writeRedeemer
  result <- writePDRValidator
  case result of
    Left err -> print $ displayError err
    Right () -> putStrLn "successsfully written validator"


