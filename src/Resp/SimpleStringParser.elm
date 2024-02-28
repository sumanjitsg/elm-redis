module Resp.SimpleStringParser exposing (Problem, parser, problemExpectingCrlf, problemExpectingPlus)

import Parser.Advanced as Parser exposing ((|.), (|=))



-- PROBLEM


type Problem
    = ExpectingPlus
    | ExpectingCrlf


problemExpectingPlus : Problem
problemExpectingPlus =
    ExpectingPlus


problemExpectingCrlf : Problem
problemExpectingCrlf =
    ExpectingCrlf



-- PARSER


parser : Parser.Parser () Problem String
parser =
    Parser.succeed identity
        |. Parser.symbol (Parser.Token "+" ExpectingPlus)
        |= Parser.getChompedString (Parser.chompUntil (Parser.Token "\u{000D}\n" ExpectingCrlf))
