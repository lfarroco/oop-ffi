module GenerateTest where

import Prelude

import Effect (Effect)
import Effect.Console (log)
import Main (ClassSpec, Member(..), Method(..), generatePurs)

generate :: Effect Unit
generate = do
  log (generatePurs personClass)
  --log (generateJs workerClass)
  log (generatePurs workerClass)

--log (generateJs workerClass)

personClass :: ClassSpec
personClass =
  { name: "Person"
  , namespace: "Person"
  , constructor: [ "String" ]
  , extends: []
  , members:
      [ Member "name" true "String"
      , Member "job" false "String"
      ]
  , methods:
      [ Method "setJob" [ "String" ] "Person"
      , Method "sayName" [] "Unit"
      ]
  }

workerClass :: ClassSpec
workerClass =
  { name: "Worker"
  , namespace: "Worker"
  , constructor: [ "String", "String", "String" ]
  , extends: [ "Person" ]
  , members:
      [ Member "employer" true "String"
      ]
  , methods:
      [ Method "sayOccupation" [] "Unit"
      ]
  }

