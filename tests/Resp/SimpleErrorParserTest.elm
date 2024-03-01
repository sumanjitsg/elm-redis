module Resp.SimpleErrorParserTest exposing (testSuite)

import Expect
import Parser.Advanced as Parser
import Resp.SimpleErrorParser
import Test


testSuite : Test.Test
testSuite =
    Test.describe "RESP Simple String Parser"
        [ Test.test "parses non-empty error strings correctly" <|
            \_ ->
                "-ERR unknown command 'hello'\u{000D}\n"
                    |> Parser.run Resp.SimpleErrorParser.parser
                    |> Expect.equal (Ok "ERR unknown command 'hello'")
        , Test.test "parses empty error strings correctly" <|
            \_ ->
                "-\u{000D}\n"
                    |> Parser.run Resp.SimpleErrorParser.parser
                    |> Expect.equal (Ok "")
        , Test.test "parses error strings containing '-' correctly" <|
            \_ ->
                "--O-K-\u{000D}\n"
                    |> Parser.run Resp.SimpleErrorParser.parser
                    |> Expect.equal (Ok "-O-K-")
        , Test.test "fails on error strings without leading '-'" <|
            \_ ->
                "OK\u{000D}\n"
                    |> Parser.run Resp.SimpleErrorParser.parser
                    |> Result.mapError (List.map .problem)
                    |> Expect.equal (Err [ Resp.SimpleErrorParser.problemExpectingMinusCharacter ])
        , Test.test "fails on error strings without trailing '\\r\\n'" <|
            \_ ->
                "-OK"
                    |> Parser.run Resp.SimpleErrorParser.parser
                    |> Result.mapError (List.map .problem)
                    |> Expect.equal (Err [ Resp.SimpleErrorParser.problemExpectingCrlf ])
        , Test.test "fails on error strings ending with '\\n' instead of '\\r\\n'" <|
            \_ ->
                "-OK\n"
                    |> Parser.run Resp.SimpleErrorParser.parser
                    |> Result.mapError (List.map .problem)
                    |> Expect.equal (Err [ Resp.SimpleErrorParser.problemExpectingCrlf ])
        ]
