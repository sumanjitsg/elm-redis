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
        , Test.test "fails on bulk strings without leading '$'" <|
            \_ ->
                "5\u{000D}\nhello\u{000D}\n"
                    |> Parser.run Resp.BulkStringParser.parser
                    |> Result.mapError (List.map .problem)
                    |> Expect.equal (Err [ Resp.BulkStringParser.problemExpectingDollar ])
        , Test.test "fails on bulk strings without the integer" <|
            \_ ->
                "$\u{000D}\nhello\u{000D}\n"
                    |> Parser.run Resp.BulkStringParser.parser
                    |> Result.mapError (List.map .problem)
                    |> Expect.equal
                        (Err
                            [ Resp.BulkStringParser.problemExpectingMinusOne
                            , Resp.BulkStringParser.problemExpectingInteger
                            ]
                        )
        , Test.test "fails on bulk strings with a string in place of the integer" <|
            \_ ->
                "$hello\u{000D}\nhello\u{000D}\n"
                    |> Parser.run Resp.BulkStringParser.parser
                    |> Result.mapError (List.map .problem)
                    |> Expect.equal
                        (Err
                            [ Resp.BulkStringParser.problemExpectingMinusOne
                            , Resp.BulkStringParser.problemExpectingInteger
                            ]
                        )
        , Test.skip <|
            Test.test "fails on bulk strings with an integer less than -1" <|
                \_ ->
                    "$-13\u{000D}\nhello\u{000D}\n"
                        |> Parser.run Resp.BulkStringParser.parser
                        |> Result.mapError (List.map .problem)
                        |> Expect.equal
                            (Err
                                [ Resp.BulkStringParser.problemExpectingMinusOne
                                , Resp.BulkStringParser.problemExpectingInteger
                                ]
                            )
        , Test.test "fails on bulk strings with length mismatch" <|
            \_ ->
                "$5\u{000D}\nhell\u{000D}\n"
                    |> Parser.run Resp.BulkStringParser.parser
                    |> Result.mapError (List.map .problem)
                    |> Expect.equal (Err [ Resp.BulkStringParser.problemExpectingLengthMismatch ])
        , Test.test "fails on bulk strings without trailing '\\r\\n'" <|
            \_ ->
                "$5\u{000D}\nhello"
                    |> Parser.run Resp.BulkStringParser.parser
                    |> Result.mapError (List.map .problem)
                    |> Expect.equal (Err [ Resp.BulkStringParser.problemExpectingCrlf ])
        , Test.test "fails on bulk strings without '\\r\\n' between the integer and the data" <|
            \_ ->
                "$5hello\u{000D}\n"
                    |> Parser.run Resp.BulkStringParser.parser
                    |> Result.mapError (List.map .problem)
                    |> Expect.equal (Err [ Resp.BulkStringParser.problemExpectingCrlf ])
        ]
