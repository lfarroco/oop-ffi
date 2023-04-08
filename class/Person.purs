module Person where

import Prelude
import Data.Maybe (Maybe)
import Data.Nullable (Nullable, toMaybe)
import Effect (Effect)
import Effect.Uncurried (EffectFn1, runEffectFn1, EffectFn2, runEffectFn2)

foreign import data PersonInstance :: Type

class Person:: forall k. k -> Constraint
class Person a

instance Person PersonInstance

foreign import newPersonImpl :: EffectFn2 String Int PersonInstance

newPerson :: String -> Int -> Effect PersonInstance
newPerson = runEffectFn2 newPersonImpl

foreign import nameImpl:: forall a. EffectFn1 a Unit

name :: forall a. Person a => a -> Effect Unit
name = runEffectFn1 nameImpl

foreign import ageImpl:: forall a. EffectFn1 a Int

age :: forall a. Person a => a -> Effect Int
age = runEffectFn1 ageImpl

foreign import sayNameImpl:: forall person. EffectFn1 person Unit

sayName :: forall person. Person person => person -> Effect Unit
sayName = runEffectFn1 sayNameImpl

foreign import sayAgeImpl:: forall person. EffectFn2 Int person person

sayAge :: forall person. Person person => Int -> person -> Effect person
sayAge = runEffectFn2 sayAgeImpl


