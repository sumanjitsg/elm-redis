module Resp.Decoder.ArrayTest exposing (testSuite)

import Expect
import Parser.Advanced as Parser
import Resp.Decoder
import Resp.Decoder.Array
import Test


testSuite : Test.Test
testSuite =
    Test.describe "RESP Array Parser"
        [ Test.test "parses empty array correctly" <|
            \_ ->
                "*0\u{000D}\n"
                    |> Parser.run Resp.Decoder.Array.parser
                    |> Expect.equal (Ok [])
        , Test.test "parses array of simple strings correctly" <|
            \_ ->
                "*2\u{000D}\n+hello\u{000D}\n+world\u{000D}\n"
                    |> Parser.run Resp.Decoder.Array.parser
                    |> Expect.equal
                        (Ok
                            [ Resp.Decoder.SimpleString "hello"
                            , Resp.Decoder.SimpleString "world"
                            ]
                        )
        , Test.test "parses array of bulk strings correctly" <|
            \_ ->
                "*2\u{000D}\n$5\u{000D}\nhello\u{000D}\n$5\u{000D}\nworld\u{000D}\n"
                    |> Parser.run Resp.Decoder.Array.parser
                    |> Expect.equal
                        (Ok
                            [ Resp.Decoder.BulkString (Just "hello")
                            , Resp.Decoder.BulkString (Just "world")
                            ]
                        )
        , Test.test "parses array of simple and bulk strings correctly" <|
            \_ ->
                "*2\u{000D}\n$5\u{000D}\nhello\u{000D}\n+world\u{000D}\n"
                    |> Parser.run Resp.Decoder.Array.parser
                    |> Expect.equal
                        (Ok
                            [ Resp.Decoder.BulkString (Just "hello")
                            , Resp.Decoder.SimpleString "world"
                            ]
                        )
        , Test.test "parses nested array of simple and bulk strings correctly" <|
            \_ ->
                "*2\u{000D}\n*3\u{000D}\n+a\u{000D}\n+b\u{000D}\n+c\u{000D}\n*2\u{000D}\n+hello\u{000D}\n$5\u{000D}\nworld\u{000D}\n"
                    |> Parser.run Resp.Decoder.Array.parser
                    |> Expect.equal
                        (Ok
                            [ Resp.Decoder.Array
                                [ Resp.Decoder.SimpleString "a"
                                , Resp.Decoder.SimpleString "b"
                                , Resp.Decoder.SimpleString "c"
                                ]
                            , Resp.Decoder.Array
                                [ Resp.Decoder.SimpleString "hello"
                                , Resp.Decoder.BulkString (Just "world")
                                ]
                            ]
                        )
        ]
