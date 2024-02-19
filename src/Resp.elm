module Resp exposing (simpleStringParser)

import Parser exposing (..)



-- SIMPLE STRINGS


simpleStringParser : Parser String
simpleStringParser =
    symbol "+"
        |> andThen
            (\_ ->
                getChompedString (chompWhile (\c -> c /= '\u{000D}'))
                    |> andThen
                        (\str ->
                            symbol "\u{000D}\n"
                                |> map (\_ -> str)
                        )
            )
