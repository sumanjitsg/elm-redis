module Test.Resp.Array exposing (testSuite)

import Expect
import Resp
import Test


testSuite : Test.Test
testSuite =
    Test.describe "RESP Array Parser"
        [ Test.test "decodes empty array correctly" <|
            \_ ->
                "*0\u{000D}\n"
                    |> Resp.decode Resp.ArrayDecoder
                    |> Result.map Resp.dataToString
                    |> Expect.equal (Ok "[]")
        , Test.test "decodes null array correctly" <|
            \_ ->
                "*-1\u{000D}\n"
                    |> Resp.decode Resp.ArrayDecoder
                    |> Result.map Resp.dataToString
                    |> Expect.equal (Ok "")
        , Test.test "decodes array of simple strings correctly" <|
            \_ ->
                "*2\u{000D}\n+hello\u{000D}\n+world\u{000D}\n"
                    |> Resp.decode Resp.ArrayDecoder
                    |> Result.map Resp.dataToString
                    |> Expect.equal (Ok "[hello,world]")
        , Test.test "decodes array of bulk strings correctly" <|
            \_ ->
                "*2\u{000D}\n$5\u{000D}\nhello\u{000D}\n$5\u{000D}\nworld\u{000D}\n"
                    |> Resp.decode Resp.ArrayDecoder
                    |> Result.map Resp.dataToString
                    |> Expect.equal (Ok "[hello,world]")
        , Test.test "decodes array of mixed data correctly" <|
            \_ ->
                "*2\u{000D}\n$5\u{000D}\nhello\u{000D}\n+world\u{000D}\n"
                    |> Resp.decode Resp.ArrayDecoder
                    |> Result.map Resp.dataToString
                    |> Expect.equal (Ok "[hello,world]")
        , Test.test "decodes nested array of mixed data correctly" <|
            \_ ->
                "*2\u{000D}\n*3\u{000D}\n+a\u{000D}\n+b\u{000D}\n+c\u{000D}\n*2\u{000D}\n+hello\u{000D}\n$5\u{000D}\nworld\u{000D}\n"
                    |> Resp.decode Resp.ArrayDecoder
                    |> Result.map Resp.dataToString
                    |> Expect.equal (Ok "[[a,b,c],[hello,world]]")
        ]
