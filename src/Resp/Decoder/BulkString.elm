module Resp.Decoder.BulkString exposing (parser)

import Parser.Advanced as Parser exposing ((|.), (|=))
import Resp.Decoder



-- TODO: the number is an unsigned, base-10 value (except -1).
-- PARSER
