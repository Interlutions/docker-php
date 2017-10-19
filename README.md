This git project contains several preconfigured PHP environments as base for different kind of projects.

Each flavour should get an own branch, prefixed by the version and name of the inherited image and suffixed with the special purpose. `<base>-<purpose>`

e.G. `php-7.0-alpine-smyfony` where `php-7.0-alpine` ist the name of the used image and `symfony` means that this image should be used for symfony projects.

The branch name must then be added to docker hub in order to use this image via `FROM interlutions/php:<version>-<base>-<purpose>`

keep the following doc in your branch
--------------
# PHP x.x fpm (alpine) for ... projects

This image features
* Useful PHP extensions
* xdebug (de-)activate script
* UID mapping
* ...
