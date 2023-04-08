# oop-ffi
Utilities to convert JavaScript classes into FFI bindings for PureScript.

This tool does the following to you:
- Generates the .purs and .js code;
- Wraps multi-parameters functions with `EffectFn_` and `runEffectFn_`;
- Expose only the relevant binding functions (not the `_Impl` ones)
- Optional properties are wrapped into `Maybe`;
- Creates a typeclass for each class;
- Extends typeclasses to preserve inheritance.

Declare how the foreign class looks like:

```purescript
personClass :: ClassSpec
personClass =
  { name: "Person" -- instances of this class will have the type "PersonInstance"
  , namespace: "Person" -- how the generated js will call "new _"
  , constructor: [ "String" ]
  , extends: []
  , members:
      [ Member "name" true "String" -- name, required, type
      , Member "job" false "String"
      ]
  , methods:
      [ Method "setJob" [ "String" ] "Person" -- name, args, return type
      , Method "sayName" [] "Unit"
      ]
  }
```

Then feed it into `generatePurs` and `generateJs`:

```purescript
generate :: Effect Unit
generate = do
  log (generatePurs personClass)
  log (generateJs personClass)```

The output .purs and .js code look like this:

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

Check the `generated.*` files under `/test` for the full examples.

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

# Current Issues:
- Lacks support methods that return nullable values
- Lacks support union types for arguments
- Lacks support for record arguments with optional properties
- You need to import the library and run it somewhere to get the output, then copy it into a file. A CLI workflow would be better.
