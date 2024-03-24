module Resp.Decoder.SimpleString exposing (parser)

import Parser.Advanced as Parser exposing ((|.), (|=))
import Resp.Decoder



-- PARSER


parser : Parser.Parser () Resp.Decoder.Problem String
parser =
    Parser.succeed identity
        |. Parser.symbol (Parser.Token "+" Resp.Decoder.ExpectingPlus)
        |= Parser.getChompedString (Parser.chompUntil (Parser.Token "\u{000D}\n" Resp.Decoder.ExpectingCrlf))
        |. Parser.symbol (Parser.Token "\u{000D}\n" Resp.Decoder.ExpectingCrlf)
