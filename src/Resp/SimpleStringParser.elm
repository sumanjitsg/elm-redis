module Resp.SimpleStringParser exposing (Problem(..), parser)

import Parser.Advanced as Parser exposing ((|.), (|=))


type Problem
    = ExpectingPlus
    | ExpectingCrlf


parser : Parser.Parser () Problem String
parser =
    Parser.succeed identity
        |. Parser.symbol (Parser.Token "+" ExpectingPlus)
        |= Parser.getChompedString (Parser.chompUntil (Parser.Token "\u{000D}\n" ExpectingCrlf))
