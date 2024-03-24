module Resp exposing (Data, Decoder(..), Problem(..), decode, encode, unwrapBulkString, unwrapSimpleString)

import Parser.Advanced as Parser exposing ((|.), (|=))


type Data
    = SimpleString String
    | BulkString (Maybe String)
    | Array (List Data)


type Decoder
    = SimpleStringDecoder
    | BulkStringDecoder


type Problem
    = ExpectingPlus
    | ExpectingCrlf
    | ExpectingDollar
    | ExpectingValidLength
    | ExpectingDataOfLength
    | ExpectingMinusOne
    | ExpectingMinusCharacter
    | ExpectingAsterisk



-- DECODERS


decode : Decoder -> String -> Result (List (Parser.DeadEnd () Problem)) Data
decode decoder encodedString =
    case decoder of
        SimpleStringDecoder ->
            Parser.run simpleStringDecoder encodedString

        BulkStringDecoder ->
            Parser.run bulkStringDecoder encodedString



-- SIMPLE STRING DECODER


simpleStringDecoder : Parser.Parser () Problem Data
simpleStringDecoder =
    Parser.succeed SimpleString
        |. Parser.symbol (Parser.Token "+" ExpectingPlus)
        |= Parser.getChompedString (Parser.chompUntil (Parser.Token "\u{000D}\n" ExpectingCrlf))
        |. Parser.symbol (Parser.Token "\u{000D}\n" ExpectingCrlf)


unwrapSimpleString : Data -> Result (List (Parser.DeadEnd () Problem)) String
unwrapSimpleString data =
    case data of
        SimpleString string ->
            Ok string

        _ ->
            Err []



-- BULK STRING DECODER


bulkStringDecoder : Parser.Parser () Problem Data
bulkStringDecoder =
    Parser.succeed identity
        |. Parser.symbol (Parser.Token "$" ExpectingDollar)
        |= Parser.getChompedString (Parser.chompUntil (Parser.Token "\u{000D}\n" ExpectingCrlf))
        |. Parser.symbol (Parser.Token "\u{000D}\n" ExpectingCrlf)
        |> Parser.andThen
            (\parsedLength ->
                case getValidLength parsedLength of
                    Just length ->
                        if length == -1 then
                            Parser.succeed (BulkString Nothing)

                        else
                            Parser.succeed identity
                                |= Parser.getChompedString (Parser.chompUntil (Parser.Token "\u{000D}\n" ExpectingCrlf))
                                |. Parser.symbol (Parser.Token "\u{000D}\n" ExpectingCrlf)
                                |> Parser.andThen
                                    (validateData length)
                                |> Parser.map (BulkString << Just)

                    Nothing ->
                        Parser.problem ExpectingValidLength
            )


getValidLength : String -> Maybe Int
getValidLength string =
    String.toInt string
        |> Maybe.andThen
            (\length ->
                if length >= -1 then
                    Just length

                else
                    Nothing
            )


validateData : Int -> String -> Parser.Parser () Problem String
validateData length string =
    if String.length string == length then
        Parser.succeed string

    else
        Parser.problem ExpectingDataOfLength


unwrapBulkString : Data -> Result (List (Parser.DeadEnd () Problem)) (Maybe String)
unwrapBulkString data =
    case data of
        BulkString maybeString ->
            Ok maybeString

        _ ->
            Err []



-- ENCODER


encode : Data -> Result String String
encode data =
    case data of
        SimpleString value ->
            Ok ("+" ++ value ++ "\u{000D}\n")

        _ ->
            Err "Resp: Unsupported data type"
