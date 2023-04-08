module GenerationTest where

import Prelude

import Effect (Effect)
import Effect.Console (log)
import Main (ClassSpec, generateJs, generatePurs)

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
      [ { name: "name"
        , required: true
        , returns: "String"
        }
      , { name: "age"
        , required: true
        , returns: "Int"
        }
      ]
  , methods:
      [ { name: "sayName"
        , args: []
        , returns: "Unit"
        }
      , { name: "sayAge"
        , args: [ "Int" ]
        , returns: "Person"
        }

      ]
  }

employeeClass :: ClassSpec
employeeClass =
  { name: "Employee"
  , namespace: "Employee"
  , extends: [ "Person" ]
  , constructor: [ "String", "Int", "String" ]
  , members:
      [ { name: "employer"
        , required: true
        , returns: "String"
        }
      , { name: "room"
        , required: false
        , returns: "Int"
        }
      ]
  , methods:
      [ { name: "sayEmployer"
        , args: []
        , returns: "Unit"
        }
      , { name: "sayRoom"
        , args: []
        , returns: "Employee"
        }
      ]
  }

