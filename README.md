
# gitlab cli

A simple gitlab cli to 
  - create a new project
  - update an existing project

See source for more info (this is a _works for me_ project).

## Notes:

This doesn't work with ``git version 1.5.2.2`` currently installed on
``fedora6.ssi.i2.dk``, it does how ever work with ``git version 1.9.1``
installed on ``buh.ssi.i2.dk``.

The error is in the command syntax for ``git add``

  - ``git version 1.9.1``: ``git add -A . *``
  - ``git version 1.5.2.2``: ``git add . *``

And

  - ``git version 1.9.1``: ``git push -u origin master``
  - ``git version 1.5.2.2``: ``git push origin master``

So that has been fixed.

