multipagebox
============

multipagebox.sty is a LaTeX macro for multi-page spanning framed box.

Usage
-----

See multipagebox.tex for detail.

    \usepackage{multipagebox}% in preamble
    ...
    \begin{multipagebox}
    ...
    \end{multipagebox}

Known Problems
--------------

  * Footnotes inside may not be printed.
  * Conflicts with \null\vspace* in \@startsection.
    Possible workaround: Replace them with \addvspace.

How it works
------------

    +--------+         +--------+          -----------
    |        |  loop   | first  |         /first slice\
    |        |         +--------+         +-----------+
    |        | vsplit  +--------+         +-----------+
    |  rest  | ------> |  gap   |   -->   | mid slice |
    |        |         +--------+         +-----------+
    |        |         +--------+              ...
    |        |         |  rest  |         +-----------+
    |        | < - - - |        |         \last slice /
    +--------+         +--------+          -----------
    
    slice = picture + content (i.e. |foo| = |   | + foo)

References
----------

  * Hideki Isozaki, "LaTeX Jiyu Jizai" (Saiensusha, 1992)
  * Tetsumi Yoshinaga, "LaTeX2e Macro & Class Programming Jissen Kaisetsu"
    (Gijutsu Hyoronsha, 2003)
