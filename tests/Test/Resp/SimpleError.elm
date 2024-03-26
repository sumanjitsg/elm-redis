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
                    |> Resp.decode
                    |> Result.map Resp.encode
                    |> Expect.equal (Ok "-ERR unknown command 'hello'\u{000D}\n")
        , Test.test "decodes empty error string correctly" <|
            \_ ->
                "-\u{000D}\n"
                    |> Resp.decode
                    |> Result.map Resp.encode
                    |> Expect.equal (Ok "-\u{000D}\n")
        , Test.test "decodes error string containing '-' correctly" <|
            \_ ->
                "--O-K-\u{000D}\n"
                    |> Resp.decode
                    |> Result.map Resp.encode
                    |> Expect.equal (Ok "--O-K-\u{000D}\n")
        , Test.test "fails on error string without leading '-'" <|
            \_ ->
                "OK\u{000D}\n"
                    |> Resp.decode
                    |> Expect.err
        , Test.test "fails on error string without trailing '\\r\\n'" <|
            \_ ->
                "-OK"
                    |> Resp.decode
                    |> Expect.err
        , Test.test "fails on error string ending with '\\n' instead of '\\r\\n'" <|
            \_ ->
                "-OK\n"
                    |> Resp.decode
                    |> Expect.err
        ]
