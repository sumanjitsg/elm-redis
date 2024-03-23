module Resp.ArrayParserTest exposing (testSuite)

import Expect
import Parser.Advanced as Parser
import Resp.ArrayParser
import Resp.Problem
import Test


testSuite : Test.Test
testSuite =
    Test.describe "RESP Array Parser"
        [ Test.test "parses an empty array correctly" <|
            \_ ->
                "*0\u{000D}\n"
                    |> Parser.run Resp.ArrayParser.parser
                    |> Expect.equal (Ok [])
        , Test.test "parses array of simple strings correctly" <|
            \_ ->
                "*2\u{000D}\n+hello\u{000D}\n+world\u{000D}\n"
                    |> Parser.run Resp.ArrayParser.parser
                    |> Expect.equal (Ok [ Just "hello", Just "world" ])
        , Test.test "parses array of bulk strings correctly" <|
            \_ ->
                "*2\u{000D}\n$5\u{000D}\nhello\u{000D}\n$5\u{000D}\nworld\u{000D}\n"
                    |> Parser.run Resp.ArrayParser.parser
                    |> Expect.equal (Ok [ Just "hello", Just "world" ])
        ]
