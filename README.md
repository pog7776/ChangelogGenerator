# ChangelogGenerator
 A really bad automatic changelog generator for git

In git commit messages use the following tags to categorize your work for the changelog </br>
Only lines of the commit with these tags will be included in the change log

* [Added] : for new features.
* [Changed] : for changes in existing functionality.
* [Deprecated] : for once-stable features removed in upcoming releases.
* [Removed] : for deprecated features removed in this release.
* [Fixed] : for any bug fixes.
* [Security] : to invite users to upgrade in case of vulnerabilities.

Once commits have been made run the script and it will generate a CHANGELOG.md
