# Stanley
Self-contained git-based local directory package manager for Lua.

# Installation

## Requirements
* __*nix__ system
* __git__ discoverable with ```which git``` command
* __Lua__ at least 5.2.4

## Per project installation
1. Download [stanley](https://stanley-release-url) to project directory.
2. Issue ```./stanley init``` command.

## Global installation
1. Put [stanley](./stanley) under one of the directories from $PATH variable.
> If working directory is not automatically detected, then please consider using [first option](#per-project-installation)

# Usage
    Usage: stanley [options] command [repo]

    Available commands:
        dump            Generate ./lib/autoload.lua file.
        help            Show this message.
        init            Create package.yaml in current working directory.
        install         Alias for: stanley update && stanley dump
        remove          Remove package from required list.
        require         Add package to required list.
        update          Clone or pull all required packages from remote sources.

    Optional arguments:
        --source  [string]      Set source for newly required package.
                                Appended to every repository that does not have source specified.
        --verbose [number]      Enable verbose mode (print debug messages).
                                The higher the value, the deeper you dig.
        --version [boolean]     Print current version and exit.

## Example usage scenarios
```bash
$ ./stanley init
$ ./stanley require user/example_repo
# require repo with the same name from another hosting source
$ ./stanley require user/example_repo --source https://another_hosting.io/
$ ./stanley update
$ ./stanley dump
```

```bash
$ cp /some/example/package.yaml ./package.yaml
$ ./stanley install # alias for: ./stanley update && ./stanley dump
```

### package.yaml structure explanation [here](./docs/package.yaml.md).

# Additional features
Generated __autoload.lua__ file contains additional functionalities. More about it __[here](./docs/autoload.lua.md)__.

# Building from source

## Requirements
* __GNU Make__
* __Lua__ at least 5.2.4

```bash
$ git clone https://github.com/Wolf2789/Stanley.git
$ make
```

# TODO
* Fix bugs if any
* Resolve recurrent package dependencies.
* Add functionality for currently unused fields.

