module Resp.SimpleStringParser exposing (parser)

import Parser.Advanced as Parser exposing ((|.), (|=))
import Resp.Problem



-- PARSER


parser : Parser.Parser () Resp.Problem.Problem String
parser =
    Parser.succeed identity
        |. Parser.symbol (Parser.Token "+" Resp.Problem.ExpectingPlus)
        |= Parser.getChompedString (Parser.chompUntil (Parser.Token "\u{000D}\n" Resp.Problem.ExpectingCrlf))
        |. Parser.symbol (Parser.Token "\u{000D}\n" Resp.Problem.ExpectingCrlf)
