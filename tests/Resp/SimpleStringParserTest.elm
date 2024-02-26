module Resp.SimpleStringParserTest exposing (testSuite)

import Expect
import Parser.Advanced as Parser
import Resp.SimpleStringParser
import Test exposing (..)


testSuite : Test
testSuite =
    describe "Simple String Parser"
        [ test "parses non-empty simple strings correctly" <|
            \_ ->
                "+OK\u{000D}\n"
                    |> Parser.run Resp.SimpleStringParser.parser
                    |> Expect.equal (Ok "OK")
        , test "parses empty simple strings correctly" <|
            \_ ->
                "+\u{000D}\n"
                    |> Parser.run Resp.SimpleStringParser.parser
                    |> Expect.equal (Ok "")
        , test "parses strings containing '+' correctly" <|
            \_ ->
                "++\u{000D}\n"
                    |> Parser.run Resp.SimpleStringParser.parser
                    |> Expect.equal (Ok "+")
        , test "fails on strings without leading '+'" <|
            \_ ->
                "OK\u{000D}\n"
                    |> Parser.run Resp.SimpleStringParser.parser
                    |> Result.mapError (List.map .problem)
                    |> Expect.equal (Err [ Resp.SimpleStringParser.ExpectingPlus ])
        , test "fails on strings without trailing '\\r\\n'" <|
            \_ ->
                "+OK\n"
                    |> Parser.run Resp.SimpleStringParser.parser
                    |> Result.mapError (List.map .problem)
                    |> Expect.equal (Err [ Resp.SimpleStringParser.ExpectingCrlf ])
        ]
