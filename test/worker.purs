module Worker where

import Prelude
import Data.Maybe (Maybe)
import Data.Nullable (Nullable, toMaybe)
import Effect (Effect)
import Effect.Uncurried (EffectFn1, runEffectFn1, EffectFn3, runEffectFn3)
import Person (class Person)

foreign import data WorkerInstance :: Type

class Worker :: forall k. k -> Constraint
class (Person a) <= Worker a

instance Person WorkerInstance
instance Worker WorkerInstance

foreign import newWorkerImpl :: EffectFn3 String String String WorkerInstance

newWorker :: String -> String -> String -> Effect WorkerInstance
newWorker = runEffectFn3 newWorkerImpl

foreign import employerImpl :: forall a. EffectFn1 a String

employer :: forall a. Worker a => a -> Effect String
employer = runEffectFn1 employerImpl

foreign import sayOccupationImpl :: forall worker. EffectFn1 worker Unit

sayOccupation :: forall worker. Worker worker => worker -> Effect Unit
sayOccupation = runEffectFn1 sayOccupationImpl
