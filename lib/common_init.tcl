proc fail {why} {
    puts "[info script]:Script failed: $why"
    exit -1
}

set timeout 3

expect_after {
    eof                 {fail "Unexpected EOF"}
    timeout             {fail "Timed out"}
    "> "                {fail "Expected output not found"}
}
