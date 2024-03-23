module Resp.Decoder.SimpleStringTest exposing (testSuite)

import Expect
import Parser.Advanced as Parser
import Resp.Decoder
import Resp.Decoder.SimpleString
import Test


testSuite : Test.Test
testSuite =
    Test.describe "RESP Simple String Parser"
        [ Test.test "parses non-empty simple strings correctly" <|
            \_ ->
                "+OK\u{000D}\n"
                    |> Parser.run Resp.Decoder.SimpleString.parser
                    |> Expect.equal (Ok "OK")
        , Test.test "parses empty simple strings correctly" <|
            \_ ->
                "+\u{000D}\n"
                    |> Parser.run Resp.Decoder.SimpleString.parser
                    |> Expect.equal (Ok "")
        , Test.test "parses strings containing '+' correctly" <|
            \_ ->
                "++O+K+\u{000D}\n"
                    |> Parser.run Resp.Decoder.SimpleString.parser
                    |> Expect.equal (Ok "+O+K+")
        , Test.test "fails on strings without leading '+'" <|
            \_ ->
                "OK\u{000D}\n"
                    |> Parser.run Resp.Decoder.SimpleString.parser
                    |> Result.mapError (List.map .problem)
                    |> Expect.equal (Err [ Resp.Decoder.ExpectingPlus ])
        , Test.test "fails on strings without trailing '\\r\\n'" <|
            \_ ->
                "+OK"
                    |> Parser.run Resp.Decoder.SimpleString.parser
                    |> Result.mapError (List.map .problem)
                    |> Expect.equal (Err [ Resp.Decoder.ExpectingCrlf ])
        , Test.test "fails on strings ending with '\\n' instead of '\\r\\n'" <|
            \_ ->
                "+OK\n"
                    |> Parser.run Resp.Decoder.SimpleString.parser
                    |> Result.mapError (List.map .problem)
                    |> Expect.equal (Err [ Resp.Decoder.ExpectingCrlf ])
        ]
