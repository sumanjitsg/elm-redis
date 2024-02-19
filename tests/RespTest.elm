module RespTest exposing (testSuite)

import Expect
import Parser
import Resp
import Test exposing (..)


testSuite : Test
testSuite =
    describe "RESP simpleStringParser"
        [ test "parses simple strings correctly" <|
            \_ ->
                "+OK\u{000D}\n"
                    |> Parser.run Resp.simpleStringParser
                    |> Expect.equal (Ok "OK")

        -- , test "fails on strings without leading '+'" <|
        --     \_ ->
        --         "OK\u{000D}\n"
        --             |> Parser.run Resp.simpleString
        --             |> Expect.equal (Err "Expected '+' at position 1 but saw 'O'")
        -- , test "fails on strings without trailing '\\r\\n'" <|
        --     \_ ->
        --         "+OK\n"
        --             |> Parser.run Resp.simpleString
        --             |> Expect.equal (Err "Expected '\\r\\n' at position 4 but saw '\\n'")
        ]
