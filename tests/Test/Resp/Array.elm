module Test.Resp.Array exposing (testSuite)

import Expect
import Resp
import Test


testSuite : Test.Test
testSuite =
    Test.describe "RESP Array Parser"
        [ Test.test "decodes empty array correctly" <|
            \_ ->
                let
                    respEncodedString =
                        "*0\u{000D}\n"
                in
                respEncodedString
                    |> Resp.decode
                    |> Result.map Resp.encode
                    |> Expect.equal (Ok respEncodedString)
        , Test.test "decodes null array correctly" <|
            \_ ->
                let
                    respEncodedString =
                        "*-1\u{000D}\n"
                in
                respEncodedString
                    |> Resp.decode
                    |> Result.map Resp.encode
                    |> Expect.equal (Ok respEncodedString)
        , Test.test "decodes array of simple strings correctly" <|
            \_ ->
                let
                    respEncodedString =
                        "*2\u{000D}\n+hello\u{000D}\n+world\u{000D}\n"
                in
                respEncodedString
                    |> Resp.decode
                    |> Result.map Resp.encode
                    |> Expect.equal (Ok respEncodedString)
        , Test.test "decodes array of bulk strings correctly" <|
            \_ ->
                let
                    respEncodedString =
                        "*2\u{000D}\n$5\u{000D}\nhello\u{000D}\n$5\u{000D}\nworld\u{000D}\n"
                in
                respEncodedString
                    |> Resp.decode
                    |> Result.map Resp.encode
                    |> Expect.equal (Ok respEncodedString)
        , Test.test "decodes array of mixed data correctly" <|
            \_ ->
                let
                    respEncodedString =
                        "*2\u{000D}\n$5\u{000D}\nhello\u{000D}\n+world\u{000D}\n"
                in
                respEncodedString
                    |> Resp.decode
                    |> Result.map Resp.encode
                    |> Expect.equal (Ok respEncodedString)
        , Test.test "decodes nested array of mixed data correctly" <|
            \_ ->
                let
                    respEncodedString =
                        "*2\u{000D}\n*3\u{000D}\n+a\u{000D}\n+b\u{000D}\n+c\u{000D}\n*2\u{000D}\n+hello\u{000D}\n$5\u{000D}\nworld\u{000D}\n"
                in
                respEncodedString
                    |> Resp.decode
                    |> Result.map Resp.encode
                    |> Expect.equal (Ok respEncodedString)
        ]
