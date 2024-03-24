module Resp.Decoder exposing (Data(..), Problem(..))


type Problem
    = ExpectingPlus
    | ExpectingCrlf
    | ExpectingDollar
    | ExpectingInteger
    | InvalidNumber
    | ExpectingLengthMismatch -- TODO: change problem name
    | ExpectingMinusOne
    | ExpectingMinusCharacter
    | ExpectingAsterisk


type Data
    = SimpleString String
    | BulkString (Maybe String)
    | Array (List Data)
