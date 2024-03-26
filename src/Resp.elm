module Resp exposing (Data, Decoder(..), dataToString, decode, encode)

import Parser.Advanced as Parser exposing ((|.), (|=))


type Data
    = SimpleString String
    | BulkString (Maybe String)
    | SimpleError String
    | Array (Maybe (List Data))


type Decoder
    = SimpleStringDecoder
    | BulkStringDecoder
    | SimpleErrorDecoder
    | ArrayDecoder


type Problem
    = ExpectingPlus
    | ExpectingCrlf
    | ExpectingDollar
    | ExpectingValidLength
    | ExpectingDataOfLength
    | ExpectingMinus
    | ExpectingAsterisk



-- DECODERS


decode : Decoder -> String -> Result (List (Parser.DeadEnd () Problem)) Data
decode decoder respEncodedString =
    case decoder of
        SimpleStringDecoder ->
            Parser.run simpleStringDecoder respEncodedString

        BulkStringDecoder ->
            Parser.run bulkStringDecoder respEncodedString

        SimpleErrorDecoder ->
            Parser.run simpleErrorDecoder respEncodedString

        ArrayDecoder ->
            Parser.run arrayDecoder respEncodedString


dataToString : Data -> String
dataToString data =
    case data of
        SimpleString string ->
            string

        BulkString maybeString ->
            Maybe.withDefault "" maybeString

        SimpleError string ->
            string

        Array maybeList ->
            maybeList
                |> Maybe.map
                    (List.map dataToString)
                |> Maybe.map
                    (String.join ",")
                |> Maybe.map
                    (\list -> "[" ++ list ++ "]")
                |> Maybe.withDefault ""



-- SIMPLE STRING DECODER


simpleStringDecoder : Parser.Parser () Problem Data
simpleStringDecoder =
    Parser.succeed SimpleString
        |. Parser.symbol (Parser.Token "+" ExpectingPlus)
        |= Parser.getChompedString (Parser.chompUntil (Parser.Token "\u{000D}\n" ExpectingCrlf))
        |. Parser.symbol (Parser.Token "\u{000D}\n" ExpectingCrlf)



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


validateBulkStringLength : Int -> String -> Parser.Parser () Problem String
validateBulkStringLength length string =
    if String.length string == length then
        Parser.succeed string

    else
        Parser.problem ExpectingDataOfLength



-- SIMPLE ERROR DECODER


simpleErrorDecoder : Parser.Parser () Problem Data
simpleErrorDecoder =
    Parser.succeed SimpleError
        |. Parser.symbol (Parser.Token "-" ExpectingMinus)
        |= Parser.getChompedString (Parser.chompUntil (Parser.Token "\u{000D}\n" ExpectingCrlf))



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
                                                |> Parser.andThen
                                                    (\data ->
                                                        Parser.succeed <|
                                                            Parser.Loop
                                                                ( count - 1
                                                                , list ++ [ data ]
                                                                )
                                                    )
                                            , bulkStringDecoder
                                                |> Parser.andThen
                                                    (\data ->
                                                        Parser.succeed <|
                                                            Parser.Loop
                                                                ( count - 1
                                                                , list ++ [ data ]
                                                                )
                                                    )
                                            , arrayDecoder
                                                |> Parser.andThen
                                                    (\data ->
                                                        Parser.succeed <|
                                                            Parser.Loop
                                                                ( count - 1
                                                                , list ++ [ data ]
                                                                )
                                                    )
                                            ]
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



-- ENCODER


encode : Data -> Result String String
encode data =
    case data of
        SimpleString value ->
            Ok ("+" ++ value ++ "\u{000D}\n")

        _ ->
            Err "Resp: Unsupported data type"
