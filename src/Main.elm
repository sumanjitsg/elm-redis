port module Main exposing (main, messageReceiver, sendMessage)

import Command
import Database
import Platform exposing (worker)
import Resp


port sendMessage : { clientId : String, message : String } -> Cmd msg


port messageReceiver : ({ clientId : String, message : String } -> msg) -> Sub msg



-- MAIN


main : Program () Model Msg
main =
    worker
        { init = init
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    ()


init : () -> ( Model, Cmd Msg )
init _ =
    ( (), Cmd.none )



-- UPDATE


type Msg
    = Receive { clientId : String, message : String }


update : Msg -> Model -> ( Model, Cmd Msg )
update (Receive { clientId, message }) model =
    case Resp.decode message of
        Err _ ->
            ( model
            , sendMessage
                { clientId = clientId
                , message =
                    "ERR invalid message format"
                        |> Resp.SimpleError
                        |> Resp.encode
                }
            )

        Ok data ->
            case
                data
                    |> Resp.dataToList
                    |> Command.fromList
            of
                Err error ->
                    ( model
                    , sendMessage
                        { clientId = clientId
                        , message =
                            error
                                |> Command.errorToString
                                |> Resp.SimpleError
                                |> Resp.encode
                        }
                    )

                Ok command ->
                    ( model
                    , sendMessage
                        { clientId = clientId
                        , message =
                            command
                                |> Database.run
                                |> Resp.encode
                        }
                    )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    messageReceiver Receive
