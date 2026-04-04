#!/usr/bin/env python3
"""
DEMO 1: The Quine — Self-Reproducing Code as Strange Loop

A quine is a program that outputs its own source code. It is the simplest
computational strange loop: the program's output IS the program, which means
the program "knows" itself — it contains a complete description of its own
structure.

This is the computational analogue of Gödel's self-referential sentence:
"This statement is not provable." The quine says: "This program is [itself]."

The quine demonstrates the first requirement for a strange loop:
SELF-REPRESENTATION — the system contains a model of itself.

Run: python3 01_quine.py
Verify: python3 01_quine.py | diff - 01_quine.py  (should show no difference)
"""

# === THE QUINE ===
# This program prints its own source code.
# It works by storing its own template as a string, then using that string
# both as data (to print) and as code (the structure of the program).

s = 's = %r\nprint(s %% s)'
print(s % s)


# === EXPLANATION ===
# The variable s contains a template of the program.
# The %r format specifier produces a repr() of the string, which includes quotes.
# When we do s % s, we substitute s into its own template.
# The result is the complete source code of the program.
#
# This is NOT mere recursion. Recursion calls a function within itself.
# A quine ENCODES itself within itself. The data IS the code. The map IS the territory.
#
# Strange Loop Structure:
#   Level 0: The source code (syntax)
#   Level 1: The meaning of the code (semantics)
#   Level 2: The output of the code (behavior)
#   Level 0 again: The output IS the source code
#
# The levels fold back on themselves. This is the hallmark of a strange loop.
