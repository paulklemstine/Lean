from dataclasses import dataclass
from typing import Sequence

@dataclass(frozen=True)
class Proof:
    name: str
    length: int
    depth: int
    lemmas: int

    @property
    def complexity(self) -> int:
        return self.length + self.depth + self.lemmas

def minimal_proof(family: Sequence[Proof]) -> Proof:
    if not family:
        raise ValueError('family must be nonempty')
    best = family[0]
    for p in family[1:]:
        if p.complexity < best.complexity:
            best = p
    return best
