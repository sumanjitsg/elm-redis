module Test.Resp.BulkString exposing (testSuite)

import Expect
import Resp
import Test


testSuite : Test.Test
testSuite =
    Test.describe "RESP Bulk String Decoder"
        [ Test.test "decodes non-empty bulk strings correctly" <|
            \_ ->
                "$5\u{000D}\nhello\u{000D}\n"
                    |> Resp.decode Resp.BulkStringDecoder
                    |> Result.andThen Resp.unwrapBulkString
                    |> Expect.equal (Ok (Just "hello"))
        , Test.test "decodes empty bulk strings correctly" <|
            \_ ->
                "$0\u{000D}\n\u{000D}\n"
                    |> Resp.decode Resp.BulkStringDecoder
                    |> Result.andThen Resp.unwrapBulkString
                    |> Expect.equal (Ok (Just ""))
        , Test.test "decodes strings containing '$' correctly" <|
            \_ ->
                "$5\u{000D}\n$O$K$\u{000D}\n"
                    |> Resp.decode Resp.BulkStringDecoder
                    |> Result.andThen Resp.unwrapBulkString
                    |> Expect.equal (Ok (Just "$O$K$"))
        , Test.test "decodes null bulk strings correctly" <|
            \_ ->
                "$-1\u{000D}\n"
                    |> Resp.decode Resp.BulkStringDecoder
                    |> Result.andThen Resp.unwrapBulkString
                    |> Expect.equal (Ok Nothing)
        , Test.test "fails on bulk strings without leading '$'" <|
            \_ ->
                "5\u{000D}\nhello\u{000D}\n"
                    |> Resp.decode Resp.BulkStringDecoder
                    |> Expect.err
        , Test.test "fails on bulk strings without the integer" <|
            \_ ->
                "$\u{000D}\nhello\u{000D}\n"
                    |> Resp.decode Resp.BulkStringDecoder
                    |> Expect.err
        , Test.test "fails on bulk strings with a string in place of the integer" <|
            \_ ->
                "$hello\u{000D}\nhello\u{000D}\n"
                    |> Resp.decode Resp.BulkStringDecoder
                    |> Expect.err
        , Test.test "fails on bulk strings with an integer less than -1" <|
            \_ ->
                "$-13\u{000D}\nhello\u{000D}\n"
                    |> Resp.decode Resp.BulkStringDecoder
                    |> Expect.err
        , Test.test "fails on bulk strings with length mismatch" <|
            \_ ->
                "$5\u{000D}\nhell\u{000D}\n"
                    |> Resp.decode Resp.BulkStringDecoder
                    |> Expect.err
        , Test.test "fails on bulk strings without trailing '\\r\\n'" <|
            \_ ->
                "$5\u{000D}\nhello"
                    |> Resp.decode Resp.BulkStringDecoder
                    |> Expect.err
        , Test.test "fails on bulk strings without '\\r\\n' between the integer and the data" <|
            \_ ->
                "$5hello\u{000D}\n"
                    |> Resp.decode Resp.BulkStringDecoder
                    |> Expect.err
        , Test.test "fails on error strings having '\\n' instead of '\\r\\n' after the integer" <|
            \_ ->
                "$2\nOK\u{000D}\n"
                    |> Resp.decode Resp.BulkStringDecoder
                    |> Expect.err
        , Test.test "fails on error strings ending with '\\n' instead of '\\r\\n'" <|
            \_ ->
                "$2\u{000D}\nOK\n"
                    |> Resp.decode Resp.BulkStringDecoder
                    |> Expect.err
        ]
