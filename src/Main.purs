module Main where

import Prelude

import Data.Argonaut.Core (Json)
import Data.Argonaut.Decode (decodeJson)
import Data.Argonaut.Parser (jsonParser)
import Data.Array (fold)
import Data.Array as Array
import Data.Either (Either(..))
import Data.String as String
import Data.Tuple (Tuple(..))
import Effect (Effect)
import Effect.Console (log)
import Node.Encoding (Encoding(..))
import Node.FS.Sync (readTextFile, writeTextFile)
import Options.Applicative (Parser, execParser, help, helper, info, long, metavar, strOption, (<**>))

-- TODO: support methods that may return a nullable

type Member = { name :: String, required :: Boolean, returns :: String }
type Method = { name :: String, args :: Array String, returns :: String }

type ClassSpec =
  { name :: String
  , namespace :: String
  , constructor :: Array String
  , extends :: Array String
  , members :: Array Member
  , methods :: Array Method
  }

data Args = Args { path :: String, output :: String }

cliArgs :: Parser Args
cliArgs = ado
  path <- strOption $ fold
    [ long "path"
    , metavar "TARGET"
    , help "The file location"
    ]
  output <- strOption $ fold
    [ long "output"
    , metavar "TARGET"
    , help "The location to output the generated files"
    ]
  in Args { path, output }

main :: Effect Unit
main = do
  (Args { path, output }) <- execParser $ info (cliArgs <**> helper) mempty
  file <- readTextFile UTF8 path
  let spec = jsonParser file
  let result = spec >>= decodeClass
  case result of
    Left err -> log err
    Right classSpec -> do
      writeTextFile UTF8 (output <> classSpec.name <> ".purs") $ generatePurs classSpec
      writeTextFile UTF8 (output <> classSpec.name <> ".js") $ generateJs classSpec
      log "Done"

generatePurs :: ClassSpec -> String
generatePurs { name, constructor, extends, members, methods } =
  let
    constructorArgCount = Array.length constructor
    allArgumentLengths =
      ( ( methods
            # map (\{ args } -> Array.length args + 1)
        )
          <> [ constructorArgCount ]
          <> (if Array.length members > 0 then [ 1 ] else [])
          # Array.filter \n -> n > 0
      )
        # Array.nub
        # Array.sort
    exports = Array.intercalate ",\n  " $ [ "  class " <> name, name <> "Instance", "new" <> name ] <> (methods # map _.name) <> (members # map _.name)
  in
    Array.intercalate "\n" $
      [ "module " <> name <> " (\n" <> exports <> "\n) where"
      , ""
      , "import Prelude"
      , "import Data.Maybe (Maybe)"
      , "import Data.Nullable (Nullable, toMaybe)"
      , "import Effect (Effect)"
      , "import Effect.Uncurried ("
          <> Array.intercalate ", "
            ( allArgumentLengths
                # map (\x -> "EffectFn" <> (show x) <> ", runEffectFn" <> (show x))
            )
          <> ")"
      ]
        <> (extends # map (\extend -> "import " <> extend <> " (class " <> extend <> ")"))
        <>
          [ "" ]
        <> classDefinition name extends
        <> pursConstructor constructorArgCount constructor name
        <> pursMembers name members
        <> pursMethods methods name
        <> [ "", "" ]

decodeClass :: Json -> Either String ClassSpec
decodeClass json = case decodeJson json of
  Left err -> Left $ show err
  Right spec -> Right spec

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
pursMembers className members = members
  >>=
    ( \{ name, required, returns } ->
        let
          nullableLabel = if required then returns else "(Nullable " <> returns <> ")"
          returnLabel = if required then returns else "(Maybe " <> returns <> ")"
          toMaybeLabel = if required then "" else ">=> (toMaybe >>> pure)"
          implName = name <> "Impl"
        in
          [ "foreign import " <> implName <> ":: forall a. EffectFn1 a " <> nullableLabel
          , ""
          , name <> " :: forall a. " <> className <> " a => a -> Effect " <> returnLabel
          , name <> " = runEffectFn1 " <> implName <> toMaybeLabel
          , ""
          ]
    )

pursMethods :: Array Method -> String -> Array String
pursMethods methods className = methods
  >>=
    ( \{ name, args, returns } ->
        let
          argCount = Array.length args
          implName = name <> "Impl"
          lowerCaseName = String.toLower className
          returnTypeImpl = if returns == className then lowerCaseName else returns
          returnTypeMethod = if returns == className then lowerCaseName else returns
        in
          [ "foreign import " <> implName <> ":: forall " <> lowerCaseName <> ". EffectFn" <> (show $ argCount + 1) <> " " <> (Array.intercalate " " $ args <> [ lowerCaseName, returnTypeImpl ])
          , ""
          , name <> " :: forall " <> lowerCaseName <> ". " <> className <> " " <> lowerCaseName <> " => " <> (Array.intercalate " -> " (args <> [ lowerCaseName ])) <> " -> Effect " <> returnTypeMethod
          , name <> " = " <> ("runEffectFn" <> (show $ argCount + 1)) <> " " <> implName
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
      ( \{ name } ->
          [ "export const " <> name <> "Impl = obj => obj." <> name <> ";"
          , ""
          ]
      )

jsMethods :: Array Method -> Array String
jsMethods methods =
  methods
    >>=
      ( \{ name, args } ->
          let
            charaArgs = argsToChars args
          in
            [ "export const "
                <> name
                <> "Impl = ("
                <> Array.intercalate ", " (charaArgs <> [ "obj" ])
                <> ") => obj."
                <> name
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