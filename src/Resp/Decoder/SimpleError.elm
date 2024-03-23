module Resp.Decoder.SimpleError exposing (..)

import Parser.Advanced as Parser exposing ((|.), (|=))
import Resp.Decoder



-- PARSER


parser : Parser.Parser () Resp.Decoder.Problem String
parser =
    Parser.succeed identity
        |. Parser.symbol (Parser.Token "-" Resp.Decoder.ExpectingMinusCharacter)
        |= Parser.getChompedString (Parser.chompUntil (Parser.Token "\u{000D}\n" Resp.Decoder.ExpectingCrlf))
