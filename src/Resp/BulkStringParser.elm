module Resp.BulkStringParser exposing (Problem(..), parser)

import Parser.Advanced as Parser exposing ((|.), (|=))


type Problem
    = ExpectingDollar
    | ExpectingCrlf
    | ExpectingInteger
    | InvalidNumber
    | ExpectingLengthMismatch
    | ExpectingMinusOne


parser : Parser.Parser () Problem (Maybe String)
parser =
    Parser.succeed identity
        |. Parser.symbol (Parser.Token "$" ExpectingDollar)
        |= Parser.oneOf
            [ Parser.map (\_ -> Nothing) nullValueParser
            , Parser.map Just stringValueParser
            ]


stringValueParser : Parser.Parser () Problem String
stringValueParser =
    Parser.succeed Tuple.pair
        |= Parser.int ExpectingInteger InvalidNumber
        |. Parser.symbol (Parser.Token "\u{000D}\n" ExpectingCrlf)
        |= Parser.getChompedString (Parser.chompUntil (Parser.Token "\u{000D}\n" ExpectingCrlf))
        |> Parser.andThen (uncurry expectLength)


expectLength : Int -> String -> Parser.Parser () Problem String
expectLength len str =
    if String.length str == len then
        Parser.succeed str

    else
        Parser.problem ExpectingLengthMismatch


nullValueParser : Parser.Parser () Problem ()
nullValueParser =
    Parser.succeed ()
        |. Parser.symbol (Parser.Token "-1" ExpectingMinusOne)
        |. Parser.symbol (Parser.Token "\u{000D}\n" ExpectingCrlf)


uncurry : (a -> b -> c) -> ( a, b ) -> c
uncurry f ( x, y ) =
    f x y
