# oop-ffi
Utilities to create FFI to OOP code

Declare the foreign class:

```purescript
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
```

It generates the .purs and .js code:

```purescript
module Person where

(...)

foreign import data PersonInstance :: Type

class Person :: forall k. k -> Constraint
class Person a

instance Person PersonInstance

newPerson :: String -> Effect PersonInstance
newPerson = runEffectFn1 newPersonImpl

(...)
```

```javascript
export const newPersonImpl = (string) =>
	new Person(string);

export const nameImpl = obj => obj.name;

export const jobImpl = obj => obj.job;

export const setJobImpl = (a, obj) => obj.setJob(a);
(...)
```

## Inheritance

It can also create inheritance hierarquies:

```purescript
module Worker where

-- A Worker should support the same methods/properties from a Person

foreign import data WorkerInstance :: Type

class Worker :: forall k. k -> Constraint
class (Person a) <= Worker a

instance Person WorkerInstance
instance Worker WorkerInstance
```


## Still lacks:
- Support methods that return nullable values
- Support union types for arguments
- Support for record arguments with optional properties
