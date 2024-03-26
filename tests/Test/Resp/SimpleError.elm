module Test.Resp.SimpleError exposing (testSuite)

import Expect
import Resp
import Test


testSuite : Test.Test
testSuite =
    Test.describe "RESP Simple Error Decoder"
        [ Test.test "decodes non-empty error string correctly" <|
            \_ ->
                "-ERR unknown command 'hello'\u{000D}\n"
                    |> Resp.decode Resp.SimpleErrorDecoder
                    |> Result.map Resp.dataToString
                    |> Expect.equal (Ok "ERR unknown command 'hello'")
        , Test.test "decodes empty error string correctly" <|
            \_ ->
                "-\u{000D}\n"
                    |> Resp.decode Resp.SimpleErrorDecoder
                    |> Result.map Resp.dataToString
                    |> Expect.equal (Ok "")
        , Test.test "decodes error string containing '-' correctly" <|
            \_ ->
                "--O-K-\u{000D}\n"
                    |> Resp.decode Resp.SimpleErrorDecoder
                    |> Result.map Resp.dataToString
                    |> Expect.equal (Ok "-O-K-")
        , Test.test "fails on error string without leading '-'" <|
            \_ ->
                "OK\u{000D}\n"
                    |> Resp.decode Resp.SimpleErrorDecoder
                    |> Expect.err
        , Test.test "fails on error string without trailing '\\r\\n'" <|
            \_ ->
                "-OK"
                    |> Resp.decode Resp.SimpleErrorDecoder
                    |> Expect.err
        , Test.test "fails on error string ending with '\\n' instead of '\\r\\n'" <|
            \_ ->
                "-OK\n"
                    |> Resp.decode Resp.SimpleErrorDecoder
                    |> Expect.err
        ]
