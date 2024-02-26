module Resp.SimpleStringParserTest exposing (testSuite)

import Expect
import Parser.Advanced as Parser
import Resp.SimpleStringParser
import Test


testSuite : Test.Test
testSuite =
    Test.describe "Simple String Parser"
        [ Test.test "parses non-empty simple strings correctly" <|
            \_ ->
                "+OK\u{000D}\n"
                    |> Parser.run Resp.SimpleStringParser.parser
                    |> Expect.equal (Ok "OK")
        , Test.test "parses empty simple strings correctly" <|
            \_ ->
                "+\u{000D}\n"
                    |> Parser.run Resp.SimpleStringParser.parser
                    |> Expect.equal (Ok "")
        , Test.test "parses strings containing '+' correctly" <|
            \_ ->
                "++\u{000D}\n"
                    |> Parser.run Resp.SimpleStringParser.parser
                    |> Expect.equal (Ok "+")
        , Test.test "fails on strings without leading '+'" <|
            \_ ->
                "OK\u{000D}\n"
                    |> Parser.run Resp.SimpleStringParser.parser
                    |> Result.mapError (List.map .problem)
                    |> Expect.equal (Err [ Resp.SimpleStringParser.ExpectingPlus ])
        , Test.test "fails on strings without trailing '\\r\\n'" <|
            \_ ->
                "+OK\n"
                    |> Parser.run Resp.SimpleStringParser.parser
                    |> Result.mapError (List.map .problem)
                    |> Expect.equal (Err [ Resp.SimpleStringParser.ExpectingCrlf ])
        ]
