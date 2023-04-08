module Main
  ( ClassSpec
  , Member(..)
  , Method(..)
  , generateJs
  , generatePurs
  ) where

import Prelude

import Data.Array as Array
import Data.String as String
import Data.Tuple (Tuple(..))

-- TODO: support methods that may return a nullable

data Member = Member String Boolean String -- name, required, returns
data Method = Method String (Array String) String -- name, args, returns

type ClassSpec =
  { name :: String
  , namespace :: String
  , constructor :: Array String
  , extends :: Array String
  , members :: Array Member
  , methods :: Array Method
  }

generatePurs :: ClassSpec -> String
generatePurs { name, constructor, extends, members, methods } =
  let
    constructorArgCount = Array.length constructor
    allArgumentLengths =
      ( ( methods
            # map (\(Method _ args _) -> Array.length args + 1)
        )
          <> [ constructorArgCount ]
          <> (if Array.length members > 0 then [ 1 ] else [])
          # Array.filter \n -> n > 0
      )
        # Array.nub
        # Array.sort
  in
    Array.intercalate "\n" $
      [ "module " <> name <> " where"
      , ""
      , "import Prelude"
      , "import Data.Maybe (Maybe)"
      , "import Data.Nullable (Nullable, toMaybe)"
      , "import Effect (Effect)"
      , "import Effect.Uncurried (" <> Array.intercalate ", " (allArgumentLengths # map (\x -> "EffectFn" <> (show x) <> ", runEffectFn" <> (show x))) <> ")"
      ]
        <> (extends # map (\extend -> "import " <> extend <> " (class " <> extend <> ")"))
        <>
          [ "" ]
        <> classDefinition name extends
        <> pursConstructor constructorArgCount constructor name
        <> pursMembers name members
        <> pursMethods methods name
        <> [ "", "" ]

pursConstructor :: Int -> Array String -> String -> Array String
pursConstructor constructorArgCount constructor name =
  [ ""
  , "foreign import new" <> name <> "Impl :: EffectFn" <> (show constructorArgCount) <> " " <> Array.intercalate " " constructor <> " " <> name <> "Instance"
  , ""
  , "new" <> name <> " :: " <> Array.intercalate " -> " (constructor) <> " -> Effect " <> name <> "Instance"
  , "new" <> name <> " = runEffectFn" <> (show $ Array.length constructor) <> " new" <> name <> "Impl"
  , ""
  ]

pursMembers :: String -> Array Member -> Array String
pursMembers name members = members
  >>=
    ( \(Member memberName required returns) ->
        let
          nullableLabel = if required then returns else "(Nullable " <> returns <> ")"
          returnLabel = if required then returns else "(Maybe " <> returns <> ")"
          toMaybeLabel = if required then "" else ">=> (toMaybe >>> pure)"
          implName = memberName <> "Impl"
        in
          [ "foreign import " <> implName <> ":: forall a. EffectFn1 a " <> nullableLabel
          , ""
          , memberName <> " :: forall a. " <> name <> " a => a -> Effect " <> returnLabel
          , memberName <> " = runEffectFn1 " <> implName <> toMaybeLabel
          , ""
          ]
    )

pursMethods :: Array Method -> String -> Array String
pursMethods methods name = methods
  >>=
    ( \(Method methodName args returns) ->
        let
          argCount = Array.length args
          implName = methodName <> "Impl"
          lowerCaseName = String.toLower name
          returnTypeImpl = if returns == name then lowerCaseName else returns
          returnTypeMethod = if returns == name then lowerCaseName else returns
        in
          [ "foreign import " <> implName <> ":: forall " <> lowerCaseName <> ". EffectFn" <> (show $ argCount + 1) <> " " <> (Array.intercalate " " $ args <> [ lowerCaseName, returnTypeImpl ])
          , ""
          , methodName <> " :: forall " <> lowerCaseName <> ". " <> name <> " " <> lowerCaseName <> " => " <> (Array.intercalate " -> " (args <> [ lowerCaseName ])) <> " -> Effect " <> returnTypeMethod
          , methodName <> " = " <> ("runEffectFn" <> (show $ argCount + 1)) <> " " <> implName
          , ""

          ]
    )

generateJs :: ClassSpec -> String
generateJs { name, namespace, members, methods, constructor } =
  Array.intercalate "\n" $
    jsConstructor name namespace constructor
      <> jsMembers members
      <> jsMethods methods

jsConstructor :: String -> String -> Array String -> Array String
jsConstructor name namespace constructor =
  let
    constructorArgs = map (String.toLower) constructor # argsToChars
  in

    [ "export const new" <> name <> "Impl = (" <> Array.intercalate ", " (constructorArgs) <> ") =>"
    , "  new " <> namespace <> "(" <> Array.intercalate ", " constructorArgs <> ");"
    , ""
    ]

jsMembers :: Array Member -> Array String
jsMembers members =
  members
    >>=
      ( \(Member memberName _ _) ->
          [ "export const " <> memberName <> "Impl = obj => obj." <> memberName <> ";"
          , ""
          ]
      )

jsMethods :: Array Method -> Array String
jsMethods methods =
  methods
    >>=
      ( \(Method methodName args _) ->
          let
            charaArgs = argsToChars args
          in
            [ "export const "
                <> methodName
                <> "Impl = ("
                <> Array.intercalate ", " (charaArgs <> [ "obj" ])
                <> ") => obj."
                <> methodName
                <> "("
                <> Array.intercalate ", " charaArgs
                <> ");"
            , ""
            ]
      )

argsToChars :: Array String -> Array String
argsToChars args = map (String.toLower) args
  # Array.zip [ "a", "b", "c", "d", "e", "f", "g", "h", "i", "j" ]
  # map (\(Tuple a _) -> a)

classDefinition :: String -> Array String -> Array String
classDefinition name extends =
  let
    extendsFrom =
      if Array.length extends < 1 then
        "class " <> name <> " a"
      else
        "class (" <> Array.intercalate ", " (map (\str -> str <> " a") extends) <> ") <= " <> name <> " a"

    instances =
      ( extends # map
          ( \className ->
              "instance " <> className <> " " <> name <> "Instance"
          )
      ) <> [ "instance " <> name <> " " <> name <> "Instance" ]

  in
    [ "foreign import data " <> name <> "Instance :: Type"
    , ""
    , "class " <> name <> ":: forall k. k -> Constraint"
    , extendsFrom
    , ""
    ] <> instances