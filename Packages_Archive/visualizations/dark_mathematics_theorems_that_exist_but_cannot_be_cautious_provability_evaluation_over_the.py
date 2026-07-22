from dataclasses import dataclass
from typing import Callable, Optional

@dataclass(frozen=True)
class Sentence:
    kind: str
    n: int = 0
    k: int = 0
    pred: Optional[Callable[[int], "Sentence"]] = None

def c_true(s: Sentence, atom_true: Callable[[int], bool], bound: int = 64) -> bool:
    if s.kind == "atom":
        return atom_true(s.n)
    if s.kind == "bot":
        return False
    if s.kind == "ex":
        assert s.pred is not None
        return any(c_true(s.pred(n), atom_true, bound) for n in range(bound))
    if s.kind == "atLeast":
        assert s.pred is not None
        w = [n for n in range(bound) if c_true(s.pred(n), atom_true, bound)]
        return len(w) >= s.k
    raise ValueError(s.kind)

def c_prov(s: Sentence, atom_true: Callable[[int], bool], bound: int = 64) -> bool:
    if s.kind in ("ex", "atLeast"):
        return c_true(s, atom_true, bound)
    return False
