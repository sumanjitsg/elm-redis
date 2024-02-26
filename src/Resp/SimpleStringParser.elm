module Resp.SimpleStringParser exposing (Problem(..), parser)

import Parser.Advanced exposing (..)


type Problem
    = ExpectingPlus
    | ExpectingCrlf


parser : Parser () Problem String
parser =
    succeed identity
        |. symbol (Token "+" ExpectingPlus)
        |= getChompedString (chompUntil (Token "\u{000D}\n" ExpectingCrlf))
