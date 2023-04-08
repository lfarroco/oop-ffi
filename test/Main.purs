module Test.Main where

import Prelude

import Effect (Effect)
import Effect.Console (log)
import Employee (class Employee)
import Employee as Employee
import GenerationTest as GenerationTest
import Person (class Person)
import Person as Person
import TestClasses as TestClasses

main :: Effect Unit
main = do
  TestClasses.expose
  GenerationTest.generate
  log " ~~~ Person Tests ~~~"
  log "Creating an instance of a class and using its methods:"

  person <- Person.newPerson "Person" 22
  personTests person

  log ""
  log " ~~~ Employee Tests ~~~"
  log "Creating an instance from a class that extends Person:"
  log ""

  employee <- Employee.newEmployee "Employee" 33 "Telecom"
  employeeTests employee

  log ""
  log " ~~~ Inheritance Tests ~~~"
  log "The employee instance should support operations from the Person class:"
  log ""

  personTests employee

  log ""
  log " ~~~ The End ~~~"
  log ""

personTests :: forall p. Person p => p -> Effect Unit
personTests person = do
  Person.sayName person
  age <- Person.age person
  log $ "My age is " <> show age
  Person.setAge (age + 1) person
    >>= Person.age
    >>= \newAge -> log $ "My age changed to " <> show newAge

employeeTests :: forall e. Employee e => e -> Effect Unit
employeeTests employee = do
  Employee.sayEmployer employee
  Employee.room employee
    >>= \room -> log $ "I don't have a room. Its number is " <> show room
  void $ Employee.setRoom 44 employee
  Employee.room employee
    >>= \room -> log $ "Now I have a room. Its number is " <> show room