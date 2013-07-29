BigCtrl
=======

Add full Ctrl key functionality to the space bar on Windows.

Holding the space bar while pressing other keys will act just the same
as if you were holding the Ctrl key. If you press and release space
without pressing another key then a normal space is returned as
expected. This works because the Ctrl key is virtually never used by
itself and the space key is rarely used in conjunction with another
key. This is particularly useful with the Emacs text editor and other
programs that make extensive use of the Ctrl key.

Features
--------

Two features try to help minimize mistakes while typing.

1. A timeout is used to prevent accidental spaces from being inserted
when the space bar key is held down for longer than a quick tap and
then released without another key having been pressed. This can happen
frequently when a typist is about to press a Ctrl key combo and then
decides not to. The default timeout is set to 300ms.

2. A delay is used to try to ensure a key that was briefly pressed
with the space bar is an intended Ctrl combo and not a fast typist
starting a new word. If the space bar is released within the specified
delay then the normal keys are returned instead of the Ctrl key
sequence. The default delay is 70ms.

Both the timeout and the delay settings are customizable in the script
version.

How to Run
----------

There are two ways to run the script.

1. The executable file (BigCtrl.exe) - Just download and double click.

2. The script file (BigCtrl.ahk) - In order to run the script you will
need to download and install AutoHotKey first at
[AutoHotKey](http://www.autohotkey.com/).

Note in either case if you want to use this script with programs that
are running under administrator privileges you must also run the
script under administrator privileges otherwise the key strokes will
not be captured.

Similar Projects
----------------

For Linux there are two similar implementations.

1. [At Home Modifier](http://gitorious.org/at-home-modifier/pages/Home)
2. [Space2Ctrl](https://github.com/r0adrunner/Space2Ctrl)

This project has been incorporated into the [ergoemacs keybindings](https://code.google.com/p/ergoemacs/source/browse/ergoemacs/ergoemacs-keybindings/ahk-us.ahk) project which provides system-wide ErgoEmacs keybindings.

License
-------

Licensed under the MIT.
