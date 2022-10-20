{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeApplications  #-}

module PDR.Compiler (writePDRValidator, writeDatum, writeRedeemer, writeUnit) where

import           Cardano.Api
import           Cardano.Api.Shelley   (PlutusScript (..))
import           Codec.Serialise       (serialise)
import           Data.Aeson            (encode)
import qualified Data.ByteString.Lazy  as LBS
import qualified Data.ByteString.Short as SBS
import qualified PDR.Validator         as PDRV
import qualified Plutus.V2.Ledger.Api
import           PlutusTx              (Data (..))
import qualified PlutusTx
import           PlutusTx.Prelude      hiding (Semigroup (..), unless)
import           Prelude               (FilePath, IO)

dataToScriptData :: Data -> ScriptData
dataToScriptData (Constr n xs) = ScriptDataConstructor n $ dataToScriptData <$> xs
dataToScriptData (Map xs)      = ScriptDataMap [(dataToScriptData x, dataToScriptData y) | (x, y) <- xs]
dataToScriptData (List xs)     = ScriptDataList $ dataToScriptData <$> xs
dataToScriptData (I n)         = ScriptDataNumber n
dataToScriptData (B bs)        = ScriptDataBytes bs

writeJSON :: PlutusTx.ToData a => FilePath -> a -> IO ()
writeJSON file = LBS.writeFile file . encode . scriptDataToJson ScriptDataJsonDetailedSchema . dataToScriptData . PlutusTx.toData

writeUnit :: IO ()
writeUnit = writeJSON "output/unit.json" ()

writeDatum :: IO ()
writeDatum = writeJSON "output/datum.json" $ PDRV.MyDatum 2

writeRedeemer :: IO ()
writeRedeemer = writeJSON "output/redeemer.json" $ PDRV.MyRedeemer 3

writeValidator :: FilePath -> Plutus.V2.Ledger.Api.Validator -> IO (Either (FileError ()) ())
writeValidator file = writeFileTextEnvelope @(PlutusScript PlutusScriptV2) file Nothing . PlutusScriptSerialised . SBS.toShort . LBS.toStrict . serialise . Plutus.V2.Ledger.Api.unValidatorScript

writePDRValidator :: IO (Either (FileError ()) ())
writePDRValidator = writeValidator "output/PDR.plutus" $ PDRV.validator $ PDRV.MyParam 1
