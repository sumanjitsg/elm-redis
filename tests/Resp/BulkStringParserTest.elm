module Resp.BulkStringParserTest exposing (testSuite)

import Expect
import Parser.Advanced as Parser
import Resp.BulkStringParser
import Resp.Problem
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
        , Test.test "parses strings containing '$' correctly" <|
            \_ ->
                "$5\u{000D}\n$O$K$\u{000D}\n"
                    |> Parser.run Resp.BulkStringParser.parser
                    |> Expect.equal (Ok (Just "$O$K$"))
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
                    |> Expect.equal (Err [ Resp.Problem.ExpectingDollar ])
        , Test.test "fails on bulk strings without the integer" <|
            \_ ->
                "$\u{000D}\nhello\u{000D}\n"
                    |> Parser.run Resp.BulkStringParser.parser
                    |> Result.mapError (List.map .problem)
                    |> Expect.equal
                        (Err
                            [ Resp.Problem.ExpectingMinusOne
                            , Resp.Problem.ExpectingInteger
                            ]
                        )
        , Test.test "fails on bulk strings with a string in place of the integer" <|
            \_ ->
                "$hello\u{000D}\nhello\u{000D}\n"
                    |> Parser.run Resp.BulkStringParser.parser
                    |> Result.mapError (List.map .problem)
                    |> Expect.equal
                        (Err
                            [ Resp.Problem.ExpectingMinusOne
                            , Resp.Problem.ExpectingInteger
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
                                [ Resp.Problem.ExpectingMinusOne
                                , Resp.Problem.ExpectingInteger
                                ]
                            )
        , Test.test "fails on bulk strings with length mismatch" <|
            \_ ->
                "$5\u{000D}\nhell\u{000D}\n"
                    |> Parser.run Resp.BulkStringParser.parser
                    |> Result.mapError (List.map .problem)
                    |> Expect.equal (Err [ Resp.Problem.ExpectingLengthMismatch ])
        , Test.test "fails on bulk strings without trailing '\\r\\n'" <|
            \_ ->
                "$5\u{000D}\nhello"
                    |> Parser.run Resp.BulkStringParser.parser
                    |> Result.mapError (List.map .problem)
                    |> Expect.equal (Err [ Resp.Problem.ExpectingCrlf ])
        , Test.test "fails on bulk strings without '\\r\\n' between the integer and the data" <|
            \_ ->
                "$5hello\u{000D}\n"
                    |> Parser.run Resp.BulkStringParser.parser
                    |> Result.mapError (List.map .problem)
                    |> Expect.equal (Err [ Resp.Problem.ExpectingCrlf ])
        , Test.test "fails on error strings having '\\n' instead of '\\r\\n' after the integer" <|
            \_ ->
                "$2\nOK\u{000D}\n"
                    |> Parser.run Resp.BulkStringParser.parser
                    |> Result.mapError (List.map .problem)
                    |> Expect.equal (Err [ Resp.Problem.ExpectingCrlf ])
        , Test.test "fails on error strings ending with '\\n' instead of '\\r\\n'" <|
            \_ ->
                "$2\u{000D}\nOK\n"
                    |> Parser.run Resp.BulkStringParser.parser
                    |> Result.mapError (List.map .problem)
                    |> Expect.equal (Err [ Resp.Problem.ExpectingCrlf ])
        ]
