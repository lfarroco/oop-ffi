module Employee (
  class Employee,
  EmployeeInstance,
  newEmployee,
  sayEmployer,
  setRoom,
  employer,
  room
) where

import Prelude
import Data.Maybe (Maybe)
import Data.Nullable (Nullable, toMaybe)
import Effect (Effect)
import Effect.Uncurried (EffectFn1, runEffectFn1, EffectFn2, runEffectFn2, EffectFn3, runEffectFn3)
import Person (class Person)

foreign import data EmployeeInstance :: Type

class Employee:: forall k. k -> Constraint
class (Person a) <= Employee a

instance Person EmployeeInstance
instance Employee EmployeeInstance

foreign import newEmployeeImpl :: EffectFn3 String Int String EmployeeInstance

newEmployee :: String -> Int -> String -> Effect EmployeeInstance
newEmployee = runEffectFn3 newEmployeeImpl

foreign import employerImpl:: forall a. EffectFn1 a String

employer :: forall a. Employee a => a -> Effect String
employer = runEffectFn1 employerImpl

foreign import roomImpl:: forall a. EffectFn1 a (Nullable Int)

room :: forall a. Employee a => a -> Effect (Maybe Int)
room = runEffectFn1 roomImpl>=> (toMaybe >>> pure)

foreign import sayEmployerImpl:: forall employee. EffectFn1 employee Unit

sayEmployer :: forall employee. Employee employee => employee -> Effect Unit
sayEmployer = runEffectFn1 sayEmployerImpl

foreign import setRoomImpl:: forall employee. EffectFn2 Int employee employee

setRoom :: forall employee. Employee employee => Int -> employee -> Effect employee
setRoom = runEffectFn2 setRoomImpl


