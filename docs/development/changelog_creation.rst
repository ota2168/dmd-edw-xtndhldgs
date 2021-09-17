Changelog Generation
====================
Changelogs help us keep track of our changes.

To generate a changelog:
.. code-block:: bash

    (venv) $ make changelog

We use ``gitchangelog`` to create the changelog automatically.
It examines the history of commits in the git log to produce its output.
The configurations for this are in the files ``.gitchangelog.rc`` and ``.gitchangelog-keepachangelog.tpl``.

To make your changelog useful you require good commit messages as well as good tags.


Read more about ``gitchangelog`` here: `<https://github.com/vaab/gitchangelog>`_


Tags
''''
Git tags are a way to bookmark commits.
Tags come in two varieties: lightweight and annotated.
Annotated tags contain author information and when used they will help organize our changelog.

To create an annotated tag for a version ``0.1.1`` release:

.. code-block:: bash

    $ git tag -a v0.1.1 -m "v0.1.1"

Using tags like this will break the changelog into sections based on versions.
If you forgot to make a tag you can checkout an old commit and make the tag (don't forget to adjust the date - you may want to google this...)

Sections
''''''''
The sections in the changelog are created from the git log commit messages, and are parsed using the regex defined in
 the ``.gitchangelog.rc`` configuration file.
