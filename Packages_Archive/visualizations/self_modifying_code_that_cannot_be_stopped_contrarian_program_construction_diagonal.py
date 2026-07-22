from __future__ import annotations
from typing import Callable

Prog = str
Predictor = Callable[[Prog, Prog], bool]

def build_contrarian(H: Predictor, name: str = "d") -> Callable[[Prog], bool]:
    """Return d such that d halts on q  <=>  H(q, q) is False.

    `halts_on(q)` reports whether the contrarian d halts on input q."""
    def halts_on(q: Prog) -> bool:
        return H(q, q) is False
    halts_on.__name__ = name
    return halts_on

def witness_incorrectness(H: Predictor, d_name: str = "d") -> bool:
    """True iff H is wrong about the contrarian running on its own code."""
    d = build_contrarian(H, d_name)
    halts_d_on_d = d(d_name)                 # forced by construction
    return (H(d_name, d_name) is True) != halts_d_on_d  # H's verdict is wrong
