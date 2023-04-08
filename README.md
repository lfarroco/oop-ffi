# oop-ffi
Utilities to convert JavaScript classes into FFI bindings for PureScript.

This tool does the following to you:
- Generates the .purs and .js code;
- Wraps multi-parameters functions with `EffectFn_` and `runEffectFn_`;
- Expose only the relevant binding functions (not the `_Impl` ones)
- Optional properties are wrapped into `Maybe`;
- Creates a typeclass for each class;
- Extends typeclasses to preserve inheritance.

Declare how the foreign class looks like using JSON:

```json
{
  "name": "Person",
  "namespace": "Person",
  "constructor": [ "String", "Int" ],
  "extends": [],
  "members": [
    { "name": "name", "required": true, "returns": "Unit" },
    { "name": "age", "required": true, "returns": "Int" }
  ],
  "methods": [
    { "name": "sayName", "args": [], "returns": "Unit" },
    { "name": "setAge", "args": [ "Int" ], "returns": "Person" }
  ]
}
```

Then, to generate the .purs and .js files:
`npx lfarroco/oop-ffi --path ./path/to/spec.json --output ./where_to_place_files/`

You can also import this lib in PureScript and use `generatePurs` and `generateJs` to 
log to the files' contents to the console.

The files should look like this:

```purescript
module Person where
(...)
foreign import data PersonInstance :: Type

class Person:: forall k. k -> Constraint
class Person a

instance Person PersonInstance

foreign import newPersonImpl :: EffectFn2 String Int PersonInstance

newPerson :: String -> Int -> Effect PersonInstance
newPerson = runEffectFn2 newPersonImpl
(...)
```

```javascript
export const newPersonImpl = (a, b) =>
  new Person(a, b);

export const nameImpl = obj => obj.name;

export const ageImpl = obj => obj.age;

export const sayNameImpl = (obj) => obj.sayName();
(...)
```

Check `/test` for some examples of specs and generated files.

## Inheritance

If you declare some class names in the `extends` field, the generated 
file will preserve the inheritance structure:

```purescript
module Employee where
(...)
foreign import data EmployeeInstance :: Type

class Employee:: forall k. k -> Constraint
class (Person a) <= Employee a

instance Person EmployeeInstance
instance Employee EmployeeInstance

(...)
```

In the example above, an `Employee` can use all methods/members from `Person`.

# Missing features:
- Support for methods that return nullable values
- Support for union types for arguments
- Support for record arguments with optional properties
