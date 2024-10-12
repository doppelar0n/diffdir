setup() {
    bats_load_library bats-support
    bats_load_library bats-assert

    CURRENT_DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
    PATH="$CURRENT_DIR/..:$PATH"
}

teardown() {
    rm -rf /tmp/src /tmp/dest
}

@test "show Usage" {
    run diffdir
    assert_output "Usage: $CURRENT_DIR/../diffdir <source_directory> <destination_directory>"
    assert_failure
}

@test "source directory does not exist" {
    run diffdir /ThisDirDoseNotExist /
    assert_output "Error: Source Directory /ThisDirDoseNotExist does not exist."
    assert_failure
}

@test "destination directory does not exist" {
    run diffdir / /ThisDirDoseNotExist
    assert_output "Error: Destination Directory /ThisDirDoseNotExist does not exist."
    assert_failure
}

@test "no diff" {
    mkdir -p /tmp/src /tmp/dest
    echo "Hello World!" > /tmp/src/hello
    echo "Hello World!" > /tmp/dest/hello
    run diffdir /tmp/src /tmp/dest
    assert_success
}

@test "diff in dest file" {
    mkdir -p /tmp/src /tmp/dest
    echo "Hello World!" > /tmp/src/hello
    echo "Hello Earth!" > /tmp/dest/hello
    run diffdir /tmp/src /tmp/dest
    assert_failure
}

@test "diff dir name in both" {
    mkdir -p /tmp/src/src /tmp/dest/dest
    echo "Hello World!" > /tmp/src/hello
    echo "Hello World!" > /tmp/dest/hello
    run diffdir /tmp/src /tmp/dest
    assert_failure
}

@test "diff extra file in dest" {
    mkdir -p /tmp/src /tmp/dest
    echo "Hello World!" > /tmp/src/hello
    echo "Hello World!" > /tmp/dest/hello
    echo "Bye World!"   > /tmp/dest/bye
    run diffdir /tmp/src /tmp/dest
    assert_failure
}

@test "diff extra file in src" {
    mkdir -p /tmp/src /tmp/dest
    echo "Hello World!" > /tmp/src/hello
    echo "Bye World!"   > /tmp/src/bye
    echo "Hello World!" > /tmp/dest/hello
    run diffdir /tmp/src /tmp/dest
    assert_failure
}