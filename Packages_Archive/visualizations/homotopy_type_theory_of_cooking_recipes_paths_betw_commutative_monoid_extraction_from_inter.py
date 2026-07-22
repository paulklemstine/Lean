from typing import Callable, List, Dict, Tuple

BinOp = Callable[[int, int], int]

def extract_commutative_monoid(
    vcomp: BinOp, elems: List[int], unit: int
) -> Dict[str, object]:
    """Extract the commutative monoid guaranteed by the Eckmann-Hilton theorem:
    multiplication is the common composition, identity is the shared unit.
    Builds the full Cayley table in O(|elems|^2)."""
    table: Dict[Tuple[int, int], int] = {}
    for a in elems:
        for b in elems:
            table[(a, b)] = vcomp(a, b)
    return {"identity": unit, "cayley_table": table, "carrier": list(elems)}
