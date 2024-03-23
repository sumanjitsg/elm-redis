module Resp.Problem exposing (Problem(..))


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
