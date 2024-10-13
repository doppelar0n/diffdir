# diffdir

`diffdir` is a Bash script for comparing files in two directories. It helps identify differences between the contents of two directories, including all files and subdirectories.

## Why?

If you want to compare two directories, you can use:

```bash
diff -r <source_directory> <destination_directory>
```

That's fine, but what if you want to ignore a `.env.local` file and a `local.json` file in the destination directory?

```bash
diff -r <source_directory> <destination_directory> | grep -v -E "\.env\.local$|local\.json$"
```

The problem with this approach is that if there are no .env.local or local.json files, you'll get an exit code 1 because grep can't find them. If there are such files, the exit code will be 0, even if the directories are completely different. In many scripting scenarios, the exit code is essential for determining whether the directories differ.

Alternatively, you can use rsync, but it also has an exit code issue. rsync will always return exit code 0:

```bash
rsync -n -r -v --exclude='*.env.local'  <source_directory> <destination_directory>
```

In both cases (diff+grep and rsync), you could theoretically count lines with `| wc -l`, but that’s not a clean solution.

With `diffdir`, you can simply do this:
```bash
diffdir <source_directory> <destination_directory> --ignore-files "^/\.env\.local$|^/local\.json$"
```
...and you'll get the expected exit code!

You face the same problem with the exit code when you want to ignore extra files and directories in the destination directory. See more [Examples](#example).

## Installation

Clone the repository from GitHub:

```bash
git clone https://github.com/doppelar0n/diffdir.git
cd diffdir
```

Copy the program to /usr/local/bin/ to make it globally available:

```bash
sudo cp diffdir /usr/local/bin/
```

## Usage

Run the script with the following parameters:

```bash
./diffdir <source_directory> <destination_directory> [OPTIONS]
```

### Options

- `--fast-fail`: Enable fast fail. If a difference is found, the script exits immediately. Helpful for scripts.
- `--find-type <string>`: Specify the types to find in the directory. The default is `fd` (files and directories).
- `--ignore-dest-extras`: Ignore extra files or subdirectories in the destination directory.
- `--ignore-files <regex>`: Ignore files or paths matching this regex pattern.
- `-h`, `--help`: Display help message.

### Example

To compare the contents of two directories:

```bash
./diffdir /path/to/source_directory /path/to/destination_directory
```

Ignore all `.img` files:
```bash
./diffdir /path/to/source_directory /path/to/destination_directory --ignore-files "\.img$"
```

Ignore all `.png` and `.jpeg` files:
```bash
./diffdir /path/to/source_directory /path/to/destination_directory --ignore-files "\.png$|\.jpeg$"
```

Ignore all `.env.local` and `local.json` files in root directory:
```bash
diffdir <source_directory> <destination_directory> --ignore-files "^/\.env\.local$|^/local\.json$"
```

Ignore all `.env.local` and `local.json` files in all sub directory:
```bash
diffdir <source_directory> <destination_directory> --ignore-files "/\.env\.local$|/local\.json$"
```

Ignore all files that ends with `.env.local` or `local.json` in all sub directory:
```bash
diffdir <source_directory> <destination_directory> --ignore-files "\.env\.local$|local\.json$"
```

Ignore any path containing `abc`. This will ignore `abc` in both source and destination directories, but only in sub-paths:
```bash
./diffdir /abc/path/to/source_directory /abc/path/to/destination_directory --ignore-files ".*abc.*"
```

Ignore all files and subdirectories that exist only in the destination directory:
```bash
./diffdir /path/to/source_directory /path/to/destination_directory --ignore-dest-extras
```

`diffdir` uses the `find` command to locate all files and directories. If you want to ignore all empty directories, you can specify the find type to only include files (f), thus ignoring empty folders:
```bash
./diffdir /path/to/source_directory /path/to/destination_directory --find-type f
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
