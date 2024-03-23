module Resp.ArrayParser exposing (parser)

import Parser.Advanced as Parser exposing ((|.), (|=))
import Resp.Problem
import Resp.SimpleStringParser



-- TODO: the number is an unsigned, base-10 value (except -1).
-- PARSER


parser : Parser.Parser () Resp.Problem.Problem (List String)
parser =
    Parser.succeed identity
        |. Parser.symbol (Parser.Token "*" Resp.Problem.ExpectingAsterisk)
        |= Parser.int Resp.Problem.ExpectingInteger Resp.Problem.InvalidNumber
        |. Parser.symbol (Parser.Token "\u{000D}\n" Resp.Problem.ExpectingCrlf)
        |> Parser.andThen (\length -> Parser.loop ( length, [] ) parseList)


parseList : ( Int, List String ) -> Parser.Parser () Resp.Problem.Problem (Parser.Step ( Int, List String ) (List String))
parseList ( count, list ) =
    if count == 0 then
        Parser.succeed (Parser.Done list)

    else
        Resp.SimpleStringParser.parser
            |> Parser.andThen
                (\value ->
                    Parser.succeed (Parser.Loop ( count - 1, list ++ [ value ] ))
                )
