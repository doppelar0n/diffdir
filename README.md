# diffdir

`diffdir` is a Bash script for comparing files in two directories. It helps identify differences between the contents of two directories and verifies if all files and subdirectories match.

## Installation

Clone the repository from GitHub:

```bash
git clone https://github.com/doppelar0n/diffdir.git
cd diffdir
```

Make the script executable:

```bash
chmod +x diffdir
```

## Usage

Run the script with the following parameters:

```bash
./diffdir <source_directory> <destination_directory> [OPTIONS]
```

### Options

- `--fast-fail`: Enable fast fail. If a difference is found, the script will exit immediately.
- `--find-type <string>`: Specify the types to find in the directory. Default is `fd` (files and directories).
- `--ignore-dest-extras`: Ignore extra files or subdirectories in the destination directory.
- `-h`, `--help`: Display help message.

### Example

To compare the contents of two directories:

```bash
./diffdir /path/to/source_directory /path/to/destination_directory
```

### Error Handling

If differences between files or directories are found, the script outputs a corresponding message and exits with a non-zero exit code.

### Test

Run test with:
```bash
docker run -it -v "$PWD:/code" bats/bats:latest /code/test
```

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more information.
