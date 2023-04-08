module Person where

import Prelude
import Data.Maybe (Maybe)
import Data.Nullable (Nullable, toMaybe)
import Effect (Effect)
import Effect.Uncurried (EffectFn1, runEffectFn1, EffectFn2, runEffectFn2)

foreign import data PersonInstance :: Type

class Person :: forall k. k -> Constraint
class Person a

instance Person PersonInstance

foreign import newPersonImpl :: EffectFn1 String PersonInstance

newPerson :: String -> Effect PersonInstance
newPerson = runEffectFn1 newPersonImpl

foreign import nameImpl :: forall a. EffectFn1 a String

name :: forall a. Person a => a -> Effect String
name = runEffectFn1 nameImpl

foreign import jobImpl :: forall a. EffectFn1 a (Nullable String)

job :: forall a. Person a => a -> Effect (Maybe String)
job = runEffectFn1 jobImpl >=> (toMaybe >>> pure)

foreign import setJobImpl :: forall person. EffectFn2 String person person

setJob :: forall person. Person person => String -> person -> Effect person
setJob = runEffectFn2 setJobImpl

foreign import sayNameImpl :: forall person. EffectFn1 person Unit

sayName :: forall person. Person person => person -> Effect Unit
sayName = runEffectFn1 sayNameImpl