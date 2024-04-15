port module Main exposing (main, messageReceiver, sendMessage)

import Command
import Database
import Platform exposing (worker)
import Resp


port sendMessage : String -> Cmd msg


port messageReceiver : (String -> msg) -> Sub msg



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
    = Receive String


update : Msg -> Model -> ( Model, Cmd Msg )
update (Receive clientMessage) model =
    case Resp.decode clientMessage of
        Err _ ->
            ( model
            , sendMessage
                ("ERR invalid message format"
                    |> Resp.SimpleError
                    |> Resp.encode
                )
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
                        (error
                            |> Command.errorToString
                            |> Resp.SimpleError
                            |> Resp.encode
                        )
                    )

                Ok command ->
                    ( model
                    , sendMessage
                        (command
                            |> Database.run
                            |> Resp.encode
                        )
                    )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    messageReceiver Receive
