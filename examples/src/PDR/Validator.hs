{-# LANGUAGE DataKinds             #-}
{-# LANGUAGE DeriveAnyClass        #-}
{-# LANGUAGE DeriveGeneric         #-}
{-# LANGUAGE FlexibleContexts      #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE NoImplicitPrelude     #-}
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE ScopedTypeVariables   #-}
{-# LANGUAGE TemplateHaskell       #-}
{-# LANGUAGE TypeApplications      #-}
{-# LANGUAGE TypeFamilies          #-}
{-# LANGUAGE TypeOperators         #-}

-- Simple contract illustrating the use of parameterized (P) contract having custom types for datum (D) & redeemer (R).
module PDR.Validator (MyParam (..), MyDatum (..), MyRedeemer (..), validator) where

import           Plutus.Script.Utils.V2.Typed.Scripts (DatumType, RedeemerType,
                                                       TypedValidator,
                                                       ValidatorTypes,
                                                       mkTypedValidatorParam,
                                                       mkUntypedValidator,
                                                       validatorScript)
import           Plutus.V2.Ledger.Api                 (ScriptContext, Validator)
import qualified PlutusTx
import           PlutusTx.Prelude                     hiding (Semigroup (..),
                                                       unless)

newtype MyParam = MyParam { pGetNumber :: Integer }
PlutusTx.makeLift ''MyParam

newtype MyDatum = MyDatum { dGetNumber :: Integer }
PlutusTx.makeIsDataIndexed ''MyDatum [('MyDatum, 0)]

newtype MyRedeemer = MyRedeemer { rGetNumber :: Integer }
PlutusTx.makeIsDataIndexed ''MyRedeemer [('MyRedeemer, 0)]

{-# INLINEABLE mkValidator #-}
mkValidator :: MyParam -> MyDatum -> MyRedeemer -> ScriptContext -> Bool
mkValidator p dat red _ = traceIfFalse "Total should be 6" isTotalSix
  where
    isTotalSix = pGetNumber p + dGetNumber dat + rGetNumber red == 6

data PDR
instance ValidatorTypes PDR where
    type instance DatumType PDR = MyDatum
    type instance RedeemerType PDR = MyRedeemer

typedValidator :: MyParam -> TypedValidator PDR
typedValidator = mkTypedValidatorParam @PDR
        $$(PlutusTx.compile [|| mkValidator ||])
        $$(PlutusTx.compile [|| wrap ||])
  where
    wrap = mkUntypedValidator

validator :: MyParam -> Validator
validator = validatorScript . typedValidator
