module Command exposing (Command(..), errorToString, fromList)

import Resp


type Command
    = Ping (Maybe String)


type Error
    = WrongNumberOfArgs String
    | UnknownCommand { command : String, args : List String }


fromList : List String -> Result Error Command
fromList list =
    case list of
        [] ->
            Err (UnknownCommand { command = "", args = [] })

        command :: args ->
            let
                lowerCommand =
                    String.toLower command
            in
            case lowerCommand of
                "ping" ->
                    case args of
                        [] ->
                            Ok (Ping Nothing)

                        [ arg ] ->
                            Ok (Ping (Just arg))

                        _ ->
                            Err (WrongNumberOfArgs command)

                _ ->
                    Err
                        (UnknownCommand { command = lowerCommand, args = args })


errorToString : Error -> String
errorToString error =
    case error of
        WrongNumberOfArgs command ->
            "ERR wrong number of arguments for '" ++ command ++ "' command"

        UnknownCommand { command, args } ->
            "ERR unknown command '"
                ++ command
                ++ "', with args beginning with: "
                ++ String.join " " (List.map (\arg -> "'" ++ arg ++ "'") args)
