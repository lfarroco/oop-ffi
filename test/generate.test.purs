module GenerateTest where

import Prelude

import Effect (Effect)
import Effect.Console (log)
import Main (ClassSpec, Member(..), Method(..), generateJs, generatePurs)

generate :: Effect Unit
generate = do
  log (generatePurs personClass)
  log (generateJs personClass)
  log (generatePurs employeeClass)
  log (generateJs employeeClass)

personClass :: ClassSpec
personClass =
  { name: "Person"
  , namespace: "Person"
  , extends: []
  , constructor: [ "String", "Int" ]
  , members:
      [ Member "name" true "Unit"
      , Member "age" true "Int"
      ]
  , methods:
      [ Method "sayName" [] "Unit"
      , Method "setAge" [ "Int" ] "Person"
      ]
  }

employeeClass :: ClassSpec
employeeClass =
  { name: "Employee"
  , namespace: "Employee"
  , extends: [ "Person" ]
  , constructor: [ "String", "Int", "String" ]
  , members:
      [ Member "employer" true "String"
      , Member "room" false "Int"
      ]
  , methods:
      [ Method "sayEmployer" [] "Unit"
      , Method "setRoom" [ "Int" ] "Employee"
      ]
  }

