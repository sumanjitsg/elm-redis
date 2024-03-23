module Resp.Decoder exposing (Problem(..), Value(..))


type Problem
    = ExpectingPlus
    | ExpectingCrlf
    | ExpectingDollar
    | ExpectingInteger
    | InvalidNumber
    | ExpectingLengthMismatch
    | ExpectingMinusOne
    | ExpectingMinusCharacter
    | ExpectingAsterisk


type Value
    = SimpleString String
    | BulkString (Maybe String)
    | Array (List Value)
