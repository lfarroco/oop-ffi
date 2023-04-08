module GameObject where

import Main (ClassSpec, Member(..), Method(..))

gameObject :: ClassSpec
gameObject =
  { name: "GameObject"
  , namespace: "Phaser.GameObjects.GameObject"
  , constructor: [ "Scene", "String" ]
  , extends: [ "EventEmitter" ]
  , members:
      [ Member "active" true "Boolean"
      , Member "body" false "PhysicsBody"
      , Member "cameraFilter" true "Number"
      , Member "data" true "DataManager"
      , Member "displayList" true "DisplayList"
      , Member "ignoreDestroy" true "Boolean"
      , Member "input" false "InteractiveObject"
      , Member "name" true "String"
      , Member "parentContainer" true "Container"
      , Member "renderFlags" true "Number"
      , Member "scene" true "Scene"
      , Member "state" true "String"
      , Member "tabIndex" true "Number"
      , Member "type" true "String"
      ]
  , methods:
      [ Method "addToDisplayList" [] "GameObject"
      , Method "addtoUpdateList" [] "GameObject"
      , Method "addToScene" [] "Unit"
      , Method "destroy" [] "Unit"
      , Method "disableInteractive" [] "GameObject"
      , Method "getData" [ "String" ] "Any"
      , Method "getIndexList" [] "Array Number"
      , Method "incData" [ "Number" ] "GameObject"
      , Method "removeFromDisplayList" [] "GameObject"
      , Method "removeFromUpdateList" [] "GameObject"
      , Method "removeInteractive" [] "GameObject"
      , Method "removedFromScene" [] "Unit"
      , Method "setActive" [ "Boolean" ] "GameObject"
      , Method "setData" [ "String" ] "GameObject"
      , Method "setDataEnabled" [] "GameObject"
      , Method "setInteractive" [] "GameObject"
      , Method "setName" [ "String" ] "GameObject"
      , Method "setState" [ "String" ] "GameObject"
      , Method "toJSON" [] "String"
      , Method "toggleData" [ "String" ] "GameObject"
      , Method "update" [] "GameObject"
      , Method "willRender" [ "Camera" ] "Boolean"
      ]
  }