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
    run diffdir /ThisFolderDoseNotExist /
    assert_output "Error: Source Directory /ThisFolderDoseNotExist does not exist."
    assert_failure
}

@test "destination directory does not exist" {
    run diffdir / /ThisFolderDoseNotExist
    assert_output "Error: Destination Directory /ThisFolderDoseNotExist does not exist."
    assert_failure
}

@test "no diff 00" {
    mkdir -p /tmp/src /tmp/dest
    echo "Hello World!" > /tmp/src/hello
    echo "Hello World!" > /tmp/dest/hello
    run diffdir /tmp/src /tmp/dest
    assert_success
}

@test "diff 00" {
    mkdir -p /tmp/src /tmp/dest
    echo "Hello World!" > /tmp/src/hello
    echo "Hello Earth!" > /tmp/dest/hello
    run diffdir /tmp/src /tmp/dest
    assert_failure
}

@test "diff 01" {
    mkdir -p /tmp/src/src /tmp/dest/dest
    echo "Hello World!" > /tmp/src/hello
    echo "Hello World!" > /tmp/dest/hello
    run diffdir /tmp/src /tmp/dest
    assert_failure
}

@test "diff 02" {
    mkdir -p /tmp/src /tmp/dest
    echo "Hello World!" > /tmp/src/hello
    echo "Hello World!" > /tmp/dest/hello
    echo "Bye World!"   > /tmp/dest/bye
    run diffdir /tmp/src /tmp/dest
    assert_failure
}

@test "diff 03" {
    mkdir -p /tmp/src /tmp/dest
    echo "Hello World!" > /tmp/src/hello
    echo "Bye World!"   > /tmp/src/bye
    echo "Hello World!" > /tmp/dest/hello
    run diffdir /tmp/src /tmp/dest
    assert_failure
}