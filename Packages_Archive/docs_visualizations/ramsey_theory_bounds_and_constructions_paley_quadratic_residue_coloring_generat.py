from typing import Callable, Set

def quadratic_residues(p: int) -> Set[int]:
    """Nonzero quadratic residues modulo a prime p."""
    return {(x * x) % p for x in range(1, p)}

def paley_coloring(p: int) -> Callable[[int, int], bool]:
    """For prime p = 1 (mod 4): the self-complementary Paley coloring on Z/p,
    red iff (a-b) is a quadratic residue mod p. The canonical Ramsey witness
    (p = 17 gives the extremal lower bound R(4,4) > 17)."""
    qr = quadratic_residues(p)
    def red(a: int, b: int) -> bool:
        return ((a - b) % p) in qr
    return red
