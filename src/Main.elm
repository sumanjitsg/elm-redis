port module Main exposing (main, messageReceiver, sendMessage)

import Platform exposing (worker)


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
    Maybe {}


init : () -> ( Model, Cmd Msg )
init _ =
    ( Nothing, Cmd.none )



-- UPDATE


type Msg
    = Receive String


update : Msg -> Model -> ( Model, Cmd Msg )
update (Receive message) model =
    ( model, sendMessage message )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    messageReceiver Receive
