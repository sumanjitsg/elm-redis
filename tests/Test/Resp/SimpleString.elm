module Test.Resp.SimpleString exposing (testSuite)

import Expect
import Resp
import Test


testSuite : Test.Test
testSuite =
    Test.describe "RESP Simple String Decoder"
        [ Test.test "decodes non-empty simple string correctly" <|
            \_ ->
                "+OK\u{000D}\n"
                    |> Resp.decode
                    |> Result.map Resp.encode
                    |> Expect.equal (Ok "+OK\u{000D}\n")
        , Test.test "decodes empty simple string correctly" <|
            \_ ->
                "+\u{000D}\n"
                    |> Resp.decode
                    |> Result.map Resp.encode
                    |> Expect.equal (Ok "+\u{000D}\n")
        , Test.test "decodes string containing '+' correctly" <|
            \_ ->
                "++O+K+\u{000D}\n"
                    |> Resp.decode
                    |> Result.map Resp.encode
                    |> Expect.equal (Ok "++O+K+\u{000D}\n")
        , Test.test "fails on string without leading '+'" <|
            \_ ->
                "OK\u{000D}\n"
                    |> Resp.decode
                    |> Expect.err
        , Test.test "fails on string without trailing '\\r\\n'" <|
            \_ ->
                "+OK"
                    |> Resp.decode
                    |> Expect.err
        , Test.test "fails on string ending with '\\n' instead of '\\r\\n'" <|
            \_ ->
                "+OK\n"
                    |> Resp.decode
                    |> Expect.err
        ]
