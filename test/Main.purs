module Test.Main where

import Prelude

import Effect (Effect)
import Effect.Console (log)
import Employee (class Employee)
import Employee as Employee
import GenerateTest as GenerateTest
import Person (class Person)
import Person as Person
import TestClasses as TestClasses

main :: Effect Unit
main = do
  TestClasses.expose
  GenerateTest.generate
  log " ~~~ Person Tests ~~~"
  log ""

  person <- Person.newPerson "Person" 22
  personTests person

  log ""
  log " ~~~ Employee Tests ~~~"
  log ""

  employee <- Employee.newEmployee "Employee" 33 "Telecom"
  employeeTests employee

  log ""
  log " ~~~ Inheritance Tests ~~~"
  log ""

  personTests employee

  log ""
  log " ~~~ The End ~~~"
  log ""

personTests :: forall p. Person p => p -> Effect Unit
personTests person = do
  Person.sayName person
  age <- Person.age person
  log $ "Person's age is " <> show age
  Person.setAge (age + 1) person
    >>= Person.age
    >>= \newAge -> log $ "Person's age changed to " <> show newAge

employeeTests :: forall e. Employee e => e -> Effect Unit
employeeTests employee = do
  Employee.sayEmployer employee
  Employee.employer employee >>= log
  Employee.room employee
    >>= \room -> log $ "The room number is " <> show room
  void $ Employee.setRoom 44 employee
  Employee.room employee
    >>= \room -> log $ "Now the room number is " <> show room