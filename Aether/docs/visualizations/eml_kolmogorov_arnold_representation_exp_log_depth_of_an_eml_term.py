from typing import Tuple, Union

# An EML term is represented as a nested tuple:
#   ("var",) | ("const", c) | ("add", t1, t2) | ("mul", t1, t2)
#   | ("exp", t) | ("log", t)
EMLTerm = Tuple

def el_depth(term: EMLTerm) -> int:
    """Exp/log-depth: max nesting of exp/log nodes, ignoring add/mul."""
    head = term[0]
    if head in ("var", "const"):
        return 0
    if head in ("add", "mul"):
        return max(el_depth(term[1]), el_depth(term[2]))
    if head in ("exp", "log"):
        return el_depth(term[1]) + 1
    raise ValueError(f"unknown EML node: {head}")
