module Resp.SimpleErrorParser exposing (..)

import Parser.Advanced as Parser exposing ((|.), (|=))



-- PROBLEM


type Problem
    = ExpectingMinusCharacter
    | ExpectingCrlf


problemExpectingMinusCharacter : Problem
problemExpectingMinusCharacter =
    ExpectingMinusCharacter


problemExpectingCrlf : Problem
problemExpectingCrlf =
    ExpectingCrlf



-- PARSER


parser : Parser.Parser () Problem String
parser =
    Parser.succeed identity
        |. Parser.symbol (Parser.Token "-" ExpectingMinusCharacter)
        |= Parser.getChompedString (Parser.chompUntil (Parser.Token "\u{000D}\n" ExpectingCrlf))
