module Resp.SimpleErrorParser exposing (..)

import Parser.Advanced as Parser exposing ((|.), (|=))
import Resp.Problem



-- PARSER


parser : Parser.Parser () Resp.Problem.Problem String
parser =
    Parser.succeed identity
        |. Parser.symbol (Parser.Token "-" Resp.Problem.ExpectingMinusCharacter)
        |= Parser.getChompedString (Parser.chompUntil (Parser.Token "\u{000D}\n" Resp.Problem.ExpectingCrlf))
