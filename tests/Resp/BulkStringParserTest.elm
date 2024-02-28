module Resp.BulkStringParserTest exposing (testSuite)

import Expect
import Parser.Advanced as Parser
import Resp.BulkStringParser
import Test


testSuite : Test.Test
testSuite =
    Test.describe "RESP Bulk String Parser"
        [ Test.test "parses non-empty bulk strings correctly" <|
            \_ ->
                "$5\u{000D}\nhello\u{000D}\n"
                    |> Parser.run Resp.BulkStringParser.parser
                    |> Expect.equal (Ok (Just "hello"))
        , Test.test "parses empty bulk strings correctly" <|
            \_ ->
                "$0\u{000D}\n\u{000D}\n"
                    |> Parser.run Resp.BulkStringParser.parser
                    |> Expect.equal (Ok (Just ""))
        , Test.test "parses null bulk strings correctly" <|
            \_ ->
                "$-1\u{000D}\n"
                    |> Parser.run Resp.BulkStringParser.parser
                    |> Expect.equal (Ok Nothing)
        ]
