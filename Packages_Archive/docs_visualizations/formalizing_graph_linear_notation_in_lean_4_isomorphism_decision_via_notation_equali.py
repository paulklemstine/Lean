from typing import Tuple

Matrix = Tuple[Tuple[int, ...], ...]

def are_isomorphic_via_gln(g: Matrix, h: Matrix) -> bool:
    """Decide isomorphism by comparing graph linear notations.
       Correctness is the theorem gln_eq_iff_iso:
           gln(G) == gln(H)  <=>  G is isomorphic to H.
       (gln is imported from the canonicalization algorithm.)"""
    from_gln = lambda m: gln(m)[0]  # type: ignore  # noqa: F821
    return from_gln(g) == from_gln(h)
