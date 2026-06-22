from typing import Dict, List, Optional, Tuple
from dataclasses import dataclass

@dataclass(frozen=True)
class RepIndex:
    label: int
    weight: int

@dataclass(frozen=True)
class ObstructionWitness:
    idx: RepIndex
    mult_f: int
    mult_g: int

def find_obstruction(repMult: "callable", f: str, g: str,
                     indices: List[RepIndex]) -> Optional[ObstructionWitness]:
    """Algorithm A: certified non-containment by finite obstruction search.

    Scans a finite candidate set of representation indices for a strict
    multiplicity gap mult(ri, f) > mult(ri, g). The first gap found is a
    certificate that f is not in the orbit closure of g (Theorem 1). If no gap
    exists in the set, pointwise domination on that set is certified (Theorem 6).
    """
    for ri in indices:
        mf, mg = repMult(ri, f), repMult(ri, g)
        if mf > mg:
            return ObstructionWitness(ri, mf, mg)
    return None
