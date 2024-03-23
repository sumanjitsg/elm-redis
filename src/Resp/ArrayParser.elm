module Resp.ArrayParser exposing (RespValue(..), parser)

import Parser.Advanced as Parser exposing ((|.), (|=))
import Resp.BulkStringParser
import Resp.Problem
import Resp.SimpleStringParser


type RespValue
    = SimpleString String
    | BulkString (Maybe String)
    | Array (List RespValue)



-- TODO: the number is an unsigned, base-10 value (except -1).
-- PARSER


parser : Parser.Parser () Resp.Problem.Problem (List RespValue)
parser =
    Parser.succeed identity
        |. Parser.symbol (Parser.Token "*" Resp.Problem.ExpectingAsterisk)
        |= Parser.int Resp.Problem.ExpectingInteger Resp.Problem.InvalidNumber
        |. Parser.symbol (Parser.Token "\u{000D}\n" Resp.Problem.ExpectingCrlf)
        |> Parser.andThen (\count -> Parser.loop ( count, [] ) parseList)


parseList : ( Int, List RespValue ) -> Parser.Parser () Resp.Problem.Problem (Parser.Step ( Int, List RespValue ) (List RespValue))
parseList ( count, list ) =
    if count == 0 then
        Parser.succeed (Parser.Done list)

    else
        Parser.oneOf
            [ Resp.SimpleStringParser.parser
                |> Parser.andThen
                    (\value ->
                        Parser.succeed (Parser.Loop ( count - 1, list ++ [ SimpleString value ] ))
                    )
            , Resp.BulkStringParser.parser
                |> Parser.andThen
                    (\value ->
                        Parser.succeed (Parser.Loop ( count - 1, list ++ [ BulkString value ] ))
                    )
            , parser
                |> Parser.andThen
                    (\value ->
                        Parser.succeed (Parser.Loop ( count - 1, list ++ [ Array value ] ))
                    )
            ]
