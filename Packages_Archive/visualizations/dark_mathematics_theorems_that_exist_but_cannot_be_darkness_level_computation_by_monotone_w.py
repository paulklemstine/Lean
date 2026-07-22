from typing import Callable, Optional
from dataclasses import dataclass

@dataclass(frozen=True)
class Sentence:
    kind: str
    n: int = 0
    k: int = 0
    pred: Optional[Callable[[int], "Sentence"]] = None

def atom(n: int) -> Sentence: return Sentence("atom", n=n)
def at_least(k: int, p: Callable[[int], Sentence]) -> Sentence:
    return Sentence("atLeast", k=k, pred=p)

def darkness_level(pred: Callable[[int], Sentence],
                   atom_true: Callable[[int], bool],
                   bound: int = 64) -> int:
    # not dark if any instance is provable (atoms are never provable here)
    def c_true(s: Sentence) -> bool:
        if s.kind == "atom": return atom_true(s.n)
        if s.kind == "atLeast":
            return sum(1 for n in range(bound) if c_true(pred(n))) >= s.k
        return False
    k = 0
    while c_true(at_least(k + 1, pred)):
        k += 1
    return k
