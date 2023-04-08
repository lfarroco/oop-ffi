module Test.Main where

import Prelude

import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Class.Console (log)
import GenerateTest as GenerateTest
import Person as Person
import Worker as Worker

main :: Effect Unit
main = do
  GenerateTest.generate
  john <- Person.newPerson "John"
  Person.sayName john
  job1 <- Person.job john
  printJob job1
  void $ Person.setJob "Engineer" john
  job2 <- Person.job john
  printJob job2
  worker1 <- Worker.newWorker "Worker1" "Engineer" "Telecom"
  Worker.sayOccupation worker1
  job3 <- Person.job worker1
  printJob job3
  pure unit

printJob :: Maybe String -> Effect Unit
printJob job = case job of
  Nothing -> log "No job"
  Just j -> do
    log "Job:"
    log j