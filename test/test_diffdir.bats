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
    assert_output --partial "Usage: $CURRENT_DIR/../diffdir <source_directory> <destination_directory> [OPTIONS]"
    assert_failure
}

@test "show --help" {
    run diffdir --help
    assert_output --partial "Usage: $CURRENT_DIR/../diffdir <source_directory> <destination_directory> [OPTIONS]"
    assert_success
}

@test "show -h" {
    run diffdir -h
    assert_output --partial "Usage: $CURRENT_DIR/../diffdir <source_directory> <destination_directory> [OPTIONS]"
    assert_success
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

@test "diff dir name in both find-type f" {
    mkdir -p /tmp/src/src /tmp/dest/dest
    echo "Hello World!" > /tmp/src/hello
    echo "Hello World!" > /tmp/dest/hello
    run diffdir /tmp/src /tmp/dest --find-type f
    assert_success
}

@test "diff extra file in dest" {
    mkdir -p /tmp/src /tmp/dest
    echo "Hello World!" > /tmp/src/hello
    echo "Hello World!" > /tmp/dest/hello
    echo "Bye World!"   > /tmp/dest/bye
    run diffdir /tmp/src /tmp/dest
    assert_failure
}

@test "diff in file" {
    mkdir -p /tmp/src /tmp/dest
    echo "Hello World!" > /tmp/src/hello
    echo "Bye World!"   > /tmp/src/bye
    echo "Hello Earth!" > /tmp/dest/hello
    echo "Bye Earth!"   > /tmp/dest/bye
    run diffdir /tmp/src /tmp/dest

    # Check if both 'hello' and 'bye' are in the output
    if [[ "$output" =~ hello && "$output" =~ bye ]]; then
        true  # Test passes if both conditions are met
    else
        # If either condition is not met, the test fails
        fail "The output does not contain both 'hello' and 'bye'."
    fi

    assert_failure
}


@test "diff in file --fast-fail" {
    mkdir -p /tmp/src /tmp/dest
    echo "Hello World!" > /tmp/src/hello
    echo "Bye World!"   > /tmp/src/bye
    echo "Hello Earth!" > /tmp/dest/hello
    echo "Bye Earth!"   > /tmp/dest/bye
    run diffdir /tmp/src /tmp/dest --fast-fail

    # Check if 'hello' is in the output but 'bye' is not
    if [[ "$output" =~ hello && ! "$output" =~ bye ]]; then
        true  # Test passes if this condition is met
    # Check if 'bye' is in the output but 'hello' is not
    elif [[ "$output" =~ bye && ! "$output" =~ hello ]]; then
        true  # Test passes if this condition is met
    else
        # If neither condition is met, the test fails
        fail "The output contains either both or neither of the words."
    fi

    assert_failure
}

@test "diff extra file in dest --ignore-dest-extras" {
    mkdir -p /tmp/src /tmp/dest
    echo "Hello World!" > /tmp/src/hello
    echo "Hello World!" > /tmp/dest/hello
    echo "Bye World!"   > /tmp/dest/bye
    run diffdir /tmp/src /tmp/dest --ignore-dest-extras
    assert_success
}

@test "diff extra file in dest --ignore-files" {
    mkdir -p /tmp/src /tmp/dest
    echo "Hello World!" > /tmp/src/hello
    echo "Hello World!" > /tmp/dest/hello
    echo "Bye World!"   > /tmp/dest/bye
    run diffdir /tmp/src /tmp/dest --ignore-files "bye$"
    assert_success
}

@test "diff extra file in dest --ignore-files fail regex" {
    mkdir -p /tmp/src /tmp/dest
    echo "Hello World!" > /tmp/src/hello
    echo "Hello World!" > /tmp/dest/hello
    echo "Bye World!"   > /tmp/dest/bye
    run diffdir /tmp/src /tmp/dest --ignore-files "byebye$"
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

@test "diff --ignore-files img and json" {
    mkdir -p /tmp/src /tmp/dest
    echo "Hello World!" > /tmp/src/hello
    echo "Bye World!"   > /tmp/src/bye.img
    echo "Bye World!"   > /tmp/src/bye.json
    echo "Hello World!" > /tmp/dest/hello
    echo "Bye Earth!"   > /tmp/dest/bye.img
    echo "Bye Earth!"   > /tmp/dest/bye.json
    run diffdir /tmp/src /tmp/dest --ignore-files "\.img$|\.json$"
    assert_success
}

@test "diff --ignore-files env and json" {
    mkdir -p /tmp/src /tmp/dest
    echo "Hello World!" > /tmp/src/hello
    echo "Bye World!"   > /tmp/src/.env.local
    echo "Bye World!"   > /tmp/src/local.json
    echo "Hello World!" > /tmp/dest/hello
    echo "Bye Earth!"   > /tmp/dest/.env.local
    echo "Bye Earth!"   > /tmp/dest/local.json
    run diffdir /tmp/src /tmp/dest --ignore-files "^/\.env\.local$|^/local\.json$"
    assert_success
}

@test "diff --ignore-files env and json src and dest dir with / at end" {
    mkdir -p /tmp/src /tmp/dest
    echo "Hello World!" > /tmp/src/hello
    echo "Bye World!"   > /tmp/src/.env.local
    echo "Bye World!"   > /tmp/src/local.json
    echo "Hello World!" > /tmp/dest/hello
    echo "Bye Earth!"   > /tmp/dest/.env.local
    echo "Bye Earth!"   > /tmp/dest/local.json
    run diffdir /tmp/src/ /tmp/dest/ --ignore-files "^/\.env\.local$|^/local\.json$"
    assert_success
}

@test "diff fail --ignore-files env and json and subdir" {
    mkdir -p /tmp/src/ok /tmp/dest/ok
    echo "Hello World!" > /tmp/src/hello
    echo "Bye World!"   > /tmp/src/.env.local
    echo "Bye World!"   > /tmp/src/ok/.env.local
    echo "Bye World!"   > /tmp/src/ok/local.json
    echo "Hello World!" > /tmp/dest/hello
    echo "Bye Earth!"   > /tmp/dest/.env.local
    echo "Bye Earth!"   > /tmp/dest/local.json
    echo "Bye Earth!"   > /tmp/dest/ok/.env.local
    echo "Bye Earth!"   > /tmp/dest/ok/local.json
    run diffdir /tmp/src /tmp/dest --ignore-files "^/\.env\.local$|^/local\.json$"
    assert_failure
}

@test "diff success --ignore-files env and json and subdir" {
    mkdir -p /tmp/src/ok /tmp/dest/ok
    echo "Hello World!" > /tmp/src/hello
    echo "Bye World!"   > /tmp/src/.env.local
    echo "Bye World!"   > /tmp/src/ok/.env.local
    echo "Bye World!"   > /tmp/src/ok/local.json
    echo "Hello World!" > /tmp/dest/hello
    echo "Bye Earth!"   > /tmp/dest/.env.local
    echo "Bye Earth!"   > /tmp/dest/local.json
    echo "Bye Earth!"   > /tmp/dest/ok/.env.local
    echo "Bye Earth!"   > /tmp/dest/ok/local.json
    run diffdir /tmp/src /tmp/dest --ignore-files "/\.env\.local$|/local\.json$"
    assert_success
}

@test "diff fail --ignore-files .*tmp.*" {
    mkdir -p /tmp/src /tmp/dest
    echo "Hello World!" > /tmp/src/hello
    echo "Hello World!" > /tmp/src/abtmp12
    echo "Hello Earth!" > /tmp/dest/hello
    echo "Hello Earth!" > /tmp/dest/abtmp12
    run diffdir /tmp/src /tmp/dest --ignore-files ".*tmp.*"
    assert_failure
}

@test "diff suc --ignore-files .*tmp.*" {
    mkdir -p /tmp/src /tmp/dest
    echo "Hello World!" > /tmp/src/hello
    echo "Hello World!" > /tmp/src/abtmp12
    echo "Hello World!" > /tmp/dest/hello
    echo "Hello Earth!" > /tmp/dest/abtmp12
    run diffdir /tmp/src /tmp/dest --ignore-files ".*tmp.*"
    assert_success
}

@test "no diff special chars" {
    mkdir -p /tmp/src /tmp/dest '/tmp/src/@#$_&-+*~^`[]{}|!() ;:"<>,./?end' '/tmp/dest/@#$_&-+*~^`[]{}|!() ;:"<>,./?end'
    echo "Hello World!"  > /tmp/src/hello
    echo "My File With Spaces & Special#Chars\!_123@ok" > '/tmp/src/@#$_&-+*~^`[]{}|!() ;:"<>,./?end/ _!@#$%^&*()_+[]{}|;:,.<>?~`"'
    echo "Hello World!"  > /tmp/dest/hello
    echo "My File With Spaces & Special#Chars\!_123@ok" > '/tmp/dest/@#$_&-+*~^`[]{}|!() ;:"<>,./?end/ _!@#$%^&*()_+[]{}|;:,.<>?~`"'
    run diffdir /tmp/src /tmp/dest
    assert_success
}