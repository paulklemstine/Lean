from enum import Enum
from typing import Callable, Tuple

class Edge(Enum):
    FLAT = "flat"; TAB = "tab"; BLANK = "blank"

def comp(e: Edge) -> Edge:
    return {Edge.FLAT: Edge.FLAT, Edge.TAB: Edge.BLANK, Edge.BLANK: Edge.TAB}[e]

def enc(value: bool) -> Edge:
    """Encode a truth value: true -> tab, false -> blank."""
    return Edge.TAB if value else Edge.BLANK

Literal = Tuple[int, bool]
Assignment = Callable[[int], bool]

def lit_fits(a: Assignment, lit: Literal) -> bool:
    """A literal's input edge interlocks with the variable output iff the
    literal is satisfied. The clause-piece input for polarity p is comp(enc(p));
    it fits the variable output enc(a(var)) exactly when enc(a(var)) == enc(p)."""
    var, polarity = lit
    variable_output = enc(a(var))
    clause_input = comp(enc(polarity))
    return clause_input == comp(variable_output)  # <=> a(var) == polarity
