#!./test/libs/bats/bin/bats

# This test is just to test whether the test system works.

load 'libs/bats-support/load'
load 'libs/bats-assert/load'

@test "Should add numbers together" {
    assert_equal $(echo 1+1 | bc) 2
}
