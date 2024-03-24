module Resp.Decoder.BulkString exposing (parser)

import Parser.Advanced as Parser exposing ((|.), (|=))
import Resp.Decoder



-- TODO: the number is an unsigned, base-10 value (except -1).
-- PARSER


parser : Parser.Parser () Resp.Decoder.Problem (Maybe String)
parser =
    Parser.succeed identity
        |. Parser.symbol (Parser.Token "$" Resp.Decoder.ExpectingDollar)
        |= Parser.oneOf
            [ Parser.map (\_ -> Nothing) nullValueParser
            , Parser.map Just stringValueParser
            ]


stringValueParser : Parser.Parser () Resp.Decoder.Problem String
stringValueParser =
    Parser.succeed Tuple.pair
        |= Parser.int Resp.Decoder.ExpectingInteger Resp.Decoder.InvalidNumber
        |. Parser.symbol (Parser.Token "\u{000D}\n" Resp.Decoder.ExpectingCrlf)
        |= Parser.getChompedString (Parser.chompUntil (Parser.Token "\u{000D}\n" Resp.Decoder.ExpectingCrlf))
        |. Parser.symbol (Parser.Token "\u{000D}\n" Resp.Decoder.ExpectingCrlf)
        |> Parser.andThen (uncurry expectLength)


expectLength : Int -> String -> Parser.Parser () Resp.Decoder.Problem String
expectLength len str =
    if String.length str == len then
        Parser.succeed str

    else
        Parser.problem Resp.Decoder.ExpectingLengthMismatch


nullValueParser : Parser.Parser () Resp.Decoder.Problem ()
nullValueParser =
    Parser.succeed ()
        |. Parser.symbol (Parser.Token "-1" Resp.Decoder.ExpectingInteger)
        |. Parser.symbol (Parser.Token "\u{000D}\n" Resp.Decoder.ExpectingCrlf)


uncurry : (a -> b -> c) -> ( a, b ) -> c
uncurry f ( x, y ) =
    f x y
