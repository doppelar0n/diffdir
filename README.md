# diffdir

A Bash script to compare files in two directories

## Usage

```bash
./diffdir <source_directory> <destination_directory>
```

### Test

Run test with:
```bash
docker run -it -v "$PWD:/code" bats/bats:latest /code/test
```
