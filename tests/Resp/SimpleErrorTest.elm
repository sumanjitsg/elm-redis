module Resp.SimpleErrorTest exposing (testSuite)

import Expect
import Resp
import Test


testSuite : Test.Test
testSuite =
    Test.describe "RESP Simple Error Decoder"
        [ Test.test "parses non-empty error strings correctly" <|
            \_ ->
                "-ERR unknown command 'hello'\u{000D}\n"
                    |> Resp.decode Resp.SimpleErrorDecoder
                    |> Result.andThen Resp.unwrapSimpleError
                    |> Expect.equal (Ok "ERR unknown command 'hello'")
        , Test.test "parses empty error strings correctly" <|
            \_ ->
                "-\u{000D}\n"
                    |> Resp.decode Resp.SimpleErrorDecoder
                    |> Result.andThen Resp.unwrapSimpleError
                    |> Expect.equal (Ok "")
        , Test.test "parses error strings containing '-' correctly" <|
            \_ ->
                "--O-K-\u{000D}\n"
                    |> Resp.decode Resp.SimpleErrorDecoder
                    |> Result.andThen Resp.unwrapSimpleError
                    |> Expect.equal (Ok "-O-K-")
        , Test.test "fails on error strings without leading '-'" <|
            \_ ->
                "OK\u{000D}\n"
                    |> Resp.decode Resp.SimpleErrorDecoder
                    |> Result.mapError (List.map .problem)
                    |> Expect.equal (Err [ Resp.ExpectingMinus ])
        , Test.test "fails on error strings without trailing '\\r\\n'" <|
            \_ ->
                "-OK"
                    |> Resp.decode Resp.SimpleErrorDecoder
                    |> Result.mapError (List.map .problem)
                    |> Expect.equal (Err [ Resp.ExpectingCrlf ])
        , Test.test "fails on error strings ending with '\\n' instead of '\\r\\n'" <|
            \_ ->
                "-OK\n"
                    |> Resp.decode Resp.SimpleErrorDecoder
                    |> Result.mapError (List.map .problem)
                    |> Expect.equal (Err [ Resp.ExpectingCrlf ])
        ]
