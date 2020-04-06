# Stanley
Git-based local directory package manager for Lua.

## Requirements
* __*nix__ system

* __git__ discoverable with ```which git``` command

* __python 3__ with following libraries:
  * __os__ (built-in) for file/directory based operations and executing ```os.system('git clone ...')```
  * __shutil__ (built-in) for executable discovery using ```shutil.which()```
  * __argparse__ (built-in) for CLI parameters parsing
  * __yaml__ for configuration file parsing
  * __re__ (built-in) for regex-based operations
  * __base64__ (built-in) for ```base64.b64decode()```
  * __datetime__ (built-in) for ```datetime.now().strftime()```
  
## Installation
1. Download [stanley](./stanley) to project directory.
2. Create ```package.yaml``` file inside project's root. Example file structure: [example.package.yaml](./example.package.yaml)

## Usage
>
    stanley [-h] [-v] [-n NAME] [-s SOURCE_HOST] command [source]

    command, can be either:
        require - add [source] to required
        remove  - remove [source] from required
        update  - clone from remote sources
        dump    - generate autoload file

    optional arguments:
    -h, --help            show help message and exit
    -v, --verbosity       Increase output verbosity (e.g. -vv is more than -v)
    -n NAME, --name NAME  Set name for newly required package instead of [source].
    -s SOURCE_HOST, --source_host SOURCE_HOST
                          Set source for newly required package (overwrite default source).

## Creating custom package
1. Create package directory under __projects_root/lib/package_name__
2. Create ```package.yaml``` file inside directory from previous step. Example file structure: [example.package.yaml](./example.package.yaml)
3. ```./stanley require package_name -s local```
4. Publish package (create git repo, push code)
5. ```./stanley remove package_name -s local```
6. ```./stanley require repo/package_name [-s full_source_path_if_other_than_github]```

## Additional features
Generated "autoload.lua" file contains special function, that allows requiring files from directories that contains dot (.) in it's name.

How? Each literal dot should be escaped with ``` ` ``` character, for example ```require('path.to`.file.containing`.dots')``` points to ```path/to.file/containing.dots```.

## TODO
* Fix bugs if any
* Add usage examples
