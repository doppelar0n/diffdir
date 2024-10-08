setup() {
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'

    CURRENT_DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
    PATH="$CURRENT_DIR/..:$PATH"
}

@test "show Usage" {
    run diffdir
    assert_output "Usage: $CURRENT_DIR/../diffdir <source_directory> <destination_directory>"
}