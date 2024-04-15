module Database exposing (run)

import Command
import Resp


run : Command.Command -> Resp.Data
run command =
    case command of
        Command.Ping maybeArg ->
            case maybeArg of
                Just arg ->
                    Resp.BulkString (Just arg)

                Nothing ->
                    Resp.SimpleString "PONG"
