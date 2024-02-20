module RespTest exposing (testSuite)

import Expect
import Parser
import Resp
import Test exposing (..)


testSuite : Test
testSuite =
    describe "simpleStringParser"
        [ test "parses simple strings correctly" <|
            \_ ->
                "+OK\u{000D}\n"
                    |> Parser.run Resp.simpleStringParser
                    |> Expect.equal (Ok "OK")
        , test "fails on strings without leading '+'" <|
            \_ ->
                let
                    result =
                        Parser.run Resp.simpleStringParser "OK\u{000D}\n"
                            |> Result.mapError Parser.deadEndsToString
                in
                result
                    |> Expect.equal (Err "Expected '+' at position 1 but saw 'O'")
        , test "fails on strings without trailing '\\r\\n'" <|
            \_ ->
                let
                    result =
                        Parser.run Resp.simpleStringParser "+OK\n"
                            |> Result.mapError Parser.deadEndsToString
                in
                result
                    |> Expect.equal (Err "Expected '\\r\\n' at position 4 but saw '\\n'")
        ]
