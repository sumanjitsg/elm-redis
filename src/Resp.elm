module Resp exposing (Data(..), dataToList, decode, encode)

import Parser.Advanced as Parser exposing ((|.), (|=))


type Data
    = SimpleString String
    | SimpleError String
    | BulkString (Maybe String)
    | Array (Maybe (List Data))


type Problem
    = ExpectingPlus
    | ExpectingCrlf
    | ExpectingDollar
    | ExpectingValidLength
    | ExpectingDataOfLength
    | ExpectingMinus
    | ExpectingAsterisk



-- ENCODERS


encode : Data -> String
encode data =
    case data of
        SimpleString value ->
            "+"
                ++ value
                ++ "\u{000D}\n"

        SimpleError value ->
            "-"
                ++ value
                ++ "\u{000D}\n"

        BulkString value ->
            case value of
                Just string ->
                    "$"
                        ++ String.fromInt (String.length string)
                        ++ "\u{000D}\n"
                        ++ string
                        ++ "\u{000D}\n"

                Nothing ->
                    "$-1\u{000D}\n"

        Array value ->
            case value of
                Just list ->
                    let
                        encodedList =
                            List.map encode list
                                |> String.join ""
                    in
                    "*" ++ String.fromInt (List.length list) ++ "\u{000D}\n" ++ encodedList

                Nothing ->
                    "*-1\u{000D}\n"



-- DECODERS


decode : String -> Result (List (Parser.DeadEnd () Problem)) Data
decode respEncodedString =
    Parser.run
        (Parser.oneOf
            [ simpleStringDecoder
            , simpleErrorDecoder
            , bulkStringDecoder
            , arrayDecoder
            ]
        )
        respEncodedString



-- SIMPLE STRING DECODER


simpleStringDecoder : Parser.Parser () Problem Data
simpleStringDecoder =
    Parser.succeed SimpleString
        |. Parser.symbol (Parser.Token "+" ExpectingPlus)
        |= Parser.getChompedString (Parser.chompUntil (Parser.Token "\u{000D}\n" ExpectingCrlf))
        |. Parser.symbol (Parser.Token "\u{000D}\n" ExpectingCrlf)



-- SIMPLE ERROR DECODER


simpleErrorDecoder : Parser.Parser () Problem Data
simpleErrorDecoder =
    Parser.succeed SimpleError
        |. Parser.symbol (Parser.Token "-" ExpectingMinus)
        |= Parser.getChompedString (Parser.chompUntil (Parser.Token "\u{000D}\n" ExpectingCrlf))



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
                                    (validateBulkStringLength length)
                                |> Parser.map (BulkString << Just)

                    Nothing ->
                        Parser.problem ExpectingValidLength
            )


validateBulkStringLength : Int -> String -> Parser.Parser () Problem String
validateBulkStringLength length string =
    if String.length string == length then
        Parser.succeed string

    else
        Parser.problem ExpectingDataOfLength



-- ARRAY DECODER


arrayDecoder : Parser.Parser () Problem Data
arrayDecoder =
    Parser.succeed identity
        |. Parser.symbol (Parser.Token "*" ExpectingAsterisk)
        |= Parser.getChompedString (Parser.chompUntil (Parser.Token "\u{000D}\n" ExpectingCrlf))
        |. Parser.symbol (Parser.Token "\u{000D}\n" ExpectingCrlf)
        |> Parser.andThen
            (\parsedLength ->
                case getValidLength parsedLength of
                    Just length ->
                        if length == -1 then
                            Parser.succeed (Array Nothing)

                        else
                            Parser.loop ( length, [] )
                                (\( count, list ) ->
                                    if count == 0 then
                                        validateArrayLength length list
                                            |> Parser.andThen
                                                (\validatedList ->
                                                    Parser.succeed
                                                        (Parser.Done (Array (Just validatedList)))
                                                )

                                    else
                                        Parser.oneOf
                                            [ simpleStringDecoder
                                            , bulkStringDecoder
                                            , simpleErrorDecoder
                                            , arrayDecoder
                                            ]
                                            |> Parser.andThen
                                                (\data ->
                                                    Parser.succeed
                                                        (Parser.Loop
                                                            ( count - 1
                                                            , list ++ [ data ]
                                                            )
                                                        )
                                                )
                                )

                    Nothing ->
                        Parser.problem ExpectingValidLength
            )


validateArrayLength : Int -> List Data -> Parser.Parser () Problem (List Data)
validateArrayLength length list =
    if List.length list == length then
        Parser.succeed list

    else
        Parser.problem ExpectingDataOfLength



-- UTILS


dataToList : Data -> List String
dataToList data =
    case data of
        SimpleString value ->
            [ value ]

        SimpleError value ->
            [ value ]

        BulkString value ->
            [ Maybe.withDefault "" value ]

        Array value ->
            case value of
                Just list ->
                    List.concatMap dataToList list

                Nothing ->
                    []


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
