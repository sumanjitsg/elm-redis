module Resp.Decoder.Array exposing (parser)

import Parser.Advanced as Parser exposing ((|.), (|=))
import Resp.Decoder
import Resp.Decoder.BulkString
import Resp.Decoder.SimpleString



-- TODO: the number is an unsigned, base-10 value (except -1).
-- PARSER


type alias State =
    ( Int, List Resp.Decoder.Data )


parser : Parser.Parser () Resp.Decoder.Problem (List Resp.Decoder.Data)
parser =
    Parser.succeed identity
        |. Parser.symbol (Parser.Token "*" Resp.Decoder.ExpectingAsterisk)
        |= Parser.int Resp.Decoder.ExpectingInteger Resp.Decoder.InvalidNumber
        |. Parser.symbol (Parser.Token "\u{000D}\n" Resp.Decoder.ExpectingCrlf)
        |> Parser.andThen (\count -> Parser.loop ( count, [] ) iterator)


iterator :
    State
    -> Parser.Parser () Resp.Decoder.Problem (Parser.Step State (List Resp.Decoder.Data))
iterator ( count, list ) =
    if count == 0 then
        Parser.succeed (Parser.Done list)

    else
        Parser.oneOf
            [ Resp.Decoder.SimpleString.parser
                |> Parser.andThen
                    (\value ->
                        Parser.succeed <|
                            Parser.Loop
                                ( count - 1
                                , list ++ [ Resp.Decoder.SimpleString value ]
                                )
                    )
            , Resp.Decoder.BulkString.parser
                |> Parser.andThen
                    (\value ->
                        Parser.succeed <|
                            Parser.Loop
                                ( count - 1
                                , list ++ [ Resp.Decoder.BulkString value ]
                                )
                    )
            , parser
                |> Parser.andThen
                    (\value ->
                        Parser.succeed <|
                            Parser.Loop
                                ( count - 1
                                , list ++ [ Resp.Decoder.Array value ]
                                )
                    )
            ]
