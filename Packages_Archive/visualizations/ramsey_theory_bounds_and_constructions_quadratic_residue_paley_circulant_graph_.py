from typing import Callable, Set

def paley(p: int) -> Callable[[int, int], bool]:
    """Adjacency predicate of the Paley graph on Z/p (p = 1 mod 4)."""
    qr: Set[int] = {(x * x) % p for x in range(1, p)}
    def adj(a: int, b: int) -> bool:
        return ((a - b) % p) in qr
    return adj

# For p = 17 the residues are {1,2,4,8,9,13,15,16}, the Ramsey witness.
