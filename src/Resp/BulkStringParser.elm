module Resp.BulkStringParser exposing (parser)

import Parser.Advanced as Parser exposing ((|.), (|=))
import Resp.Problem



-- TODO: the number is an unsigned, base-10 value (except -1).
-- PARSER


parser : Parser.Parser () Resp.Problem.Problem (Maybe String)
parser =
    Parser.succeed identity
        |. Parser.symbol (Parser.Token "$" Resp.Problem.ExpectingDollar)
        |= Parser.oneOf
            [ Parser.map (\_ -> Nothing) nullValueParser
            , Parser.map Just stringValueParser
            ]


stringValueParser : Parser.Parser () Resp.Problem.Problem String
stringValueParser =
    Parser.succeed Tuple.pair
        |= Parser.int Resp.Problem.ExpectingInteger Resp.Problem.InvalidNumber
        |. Parser.symbol (Parser.Token "\u{000D}\n" Resp.Problem.ExpectingCrlf)
        |= Parser.getChompedString (Parser.chompUntil (Parser.Token "\u{000D}\n" Resp.Problem.ExpectingCrlf))
        |. Parser.symbol (Parser.Token "\u{000D}\n" Resp.Problem.ExpectingCrlf)
        |> Parser.andThen (uncurry expectLength)


expectLength : Int -> String -> Parser.Parser () Resp.Problem.Problem String
expectLength len str =
    if String.length str == len then
        Parser.succeed str

    else
        Parser.problem Resp.Problem.ExpectingLengthMismatch


nullValueParser : Parser.Parser () Resp.Problem.Problem ()
nullValueParser =
    Parser.succeed ()
        |. Parser.symbol (Parser.Token "-1" Resp.Problem.ExpectingMinusOne)
        |. Parser.symbol (Parser.Token "\u{000D}\n" Resp.Problem.ExpectingCrlf)


uncurry : (a -> b -> c) -> ( a, b ) -> c
uncurry f ( x, y ) =
    f x y
