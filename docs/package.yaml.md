# __package.yaml__ explained

## __name__:
- _Type_: __string__
- _String format_: __user/repo__
- _Description_: Used for _git clone_ command along with __specified source__.

## __description__:
- _Type_: __string__
- _Description_:
  - Package description, for others to see what contained source code is about.
  - Currently not used, saved for later use.

## __version__:
- _Type_: __number__
- _Default_: __1.0__
- _Description_:
  - Specifies source code's version number.
  - Currently not used, saved for later use.

## __author__:
- _Type_: __array__
- _Description_:
  - Stores information about source code's authors.
  - Currently not used, saved for later use.
  - Can be used as temporary contact information for users.

  ## __author item structure__:
  - __name__:
    - _Type_: __string__
    - _Description_: Author's name, surname, nickname etc.
  - __email__:
    - _Type_: __string__
    - _String format_: __user@host.com__
    - _Description_: Contact email.

## __autoload__:
- _Type_: __array__
- _Description_:
  - Stores information about source code's entry points.
  - Used for __autoload file__ generation.

  ## __autoload item structure__:
  There are two types of autoload items.
  1. _Type_: __file__
    - __path__:
      - _Type_: __string__
      - _Description_: Path to file to be executed.
    - __relative__:
      - _Type_: __boolean__
      - _Default_: __True__
      - _Description_:
        - Searches for __path__ under _lib/repo/name/path/to/file.lua_ if __relative__ set to __true__.
        - Searches for __path__ under _lib/path/to/file.lua_ if __relative__ set to __false__.

  2. _Type_: __global__
    - __name__:
      - _Type_: __string__
      - _Description_: Name under which source code will be stored.
    - __path__: exactly as in 1.
    - __relative__: exactly as in 1.

## __require__:
- _Type_: __array__
- _Description_:
  - Stores information about source code's dependent packages.
  - Used for dependency resolution and queue building for later use with __autoload file__ generation.
  - Currently does not resolve recurrenting packages requires.

  ## __require item structure__:
  - __name__:
    - _Type_: __string__
    - _String format_: __user/repo__
    - _Description_: Used for _git clone_ command along with __specified source__.
  - __source__:
    - _Type_: __string__
    - _Supported values_:
      - __local__ - means do not clone any source, because it should already be present under __lib__ directory.
      - Any other value is handled by `git clone` command.
    - _Description_:
      - Used for _git clone_ command along with __specified name__.
