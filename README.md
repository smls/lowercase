# lowercase

A tool for lowercasing (and if needed, later restoring) all filenames inside the current directory tree on Linux.

### Features
* Runs reasonably fast.
* Operates safely:
  * Does not override existing files.
  * Does not croak on filenames with unusual characters (e.g. newlines).
  * Does not leave behind an inconsistent state when killed with CTRL+C.
* Prints useful status reports.
* Can restore previously lowercased filenames.

### Installation

1. Make sure that the following two dependencies are installed *(on most Linux systems they already are)*:
  * `perl` (v5.10 or newer)
  * `find` (from the [Gnu Find Utilities](http://www.gnu.org/software/findutils/))
2. Copy the `lowercase` file from this repository to a location in your `$PATH`, and give it executable permissions.

### Usage

command                     | effect
----------------------------|-----------------------------------------------------
`lowercase`                 | Lowercase all filenames below the current directory. *(Asks for confirmation and prints a final report, unless the `-q` switch is also passed.)*
`lowercase --check`         | Check if lowercasing would cause conflicts.
`lowercase --restore`       | Restore all filenames that were lowercased by prior `lowercase` calls in the same directory. *(Asks for confirmation and prints a final report, unless the `-q` switch is also passed.)*
`lowercase --restore-check` | Check if restoring would cause conflicts.

The list of lowercased filenames (which is used for restoring) is saved in a file called `.lowercase_restore` in the current directory. If it already exists, it is appended to - thus it is safe to call `lowercase` multiple times without restoring in between.
