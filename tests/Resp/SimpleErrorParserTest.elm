module Resp.SimpleErrorParserTest exposing (testSuite)

import Expect
import Parser.Advanced as Parser
import Resp.SimpleStringParser
import Test


testSuite : Test.Test
testSuite =
    Test.describe "RESP Simple String Parser" []
