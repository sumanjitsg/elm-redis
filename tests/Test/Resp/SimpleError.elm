module Test.Resp.SimpleError exposing (testSuite)

import Expect
import Resp
import Test


testSuite : Test.Test
testSuite =
    Test.describe "RESP Simple Error Decoder"
        [ Test.test "decodes non-empty error strings correctly" <|
            \_ ->
                "-ERR unknown command 'hello'\u{000D}\n"
                    |> Resp.decode Resp.SimpleErrorDecoder
                    |> Result.andThen Resp.unwrapSimpleError
                    |> Expect.equal (Ok "ERR unknown command 'hello'")
        , Test.test "decodes empty error strings correctly" <|
            \_ ->
                "-\u{000D}\n"
                    |> Resp.decode Resp.SimpleErrorDecoder
                    |> Result.andThen Resp.unwrapSimpleError
                    |> Expect.equal (Ok "")
        , Test.test "decodes error strings containing '-' correctly" <|
            \_ ->
                "--O-K-\u{000D}\n"
                    |> Resp.decode Resp.SimpleErrorDecoder
                    |> Result.andThen Resp.unwrapSimpleError
                    |> Expect.equal (Ok "-O-K-")
        , Test.test "fails on error strings without leading '-'" <|
            \_ ->
                "OK\u{000D}\n"
                    |> Resp.decode Resp.SimpleErrorDecoder
                    |> Expect.err
        , Test.test "fails on error strings without trailing '\\r\\n'" <|
            \_ ->
                "-OK"
                    |> Resp.decode Resp.SimpleErrorDecoder
                    |> Expect.err
        , Test.test "fails on error strings ending with '\\n' instead of '\\r\\n'" <|
            \_ ->
                "-OK\n"
                    |> Resp.decode Resp.SimpleErrorDecoder
                    |> Expect.err
        ]
