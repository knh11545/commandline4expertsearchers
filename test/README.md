Tests
==============================================================================

## Setup

Sertup for tests according to the tutorial [Testing Your Shell Scripts, with Bats](https://medium.com/@pimterry/testing-your-shell-scripts-with-bats-abfca9bdc5b9) by Tim Perry.

In the projects's root directory:

```bash
mkdir -p test/libs

git submodule add https://github.com/sstephenson/bats test/libs/bats
git submodule add https://github.com/ztombol/bats-support test/libs/bats-support
git submodule add https://github.com/ztombol/bats-assert test/libs/bats-assert

git submodule update --init --recursive
```

**FIXME**: The following test does not work in my WSL installation:


```bash
./test/libs/bats/bin/bats test/addition-test.bats
```


