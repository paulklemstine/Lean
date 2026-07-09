from itertools import product
from typing import Dict, List, Optional, Tuple


def characters_to_Z2(moduli: Tuple[int, ...]) -> List[Tuple[int, ...]]:
    """
    Enumerate all additive characters psi : (prod_j Z/moduli[j]) -> Z/2,
    each recorded by its values on the standard generators e_j. A generator
    e_j of order m_j can map to a in Z/2 only if m_j * a = 0 in Z/2, i.e.
    a = 0 whenever m_j is odd, and a in {0,1} whenever m_j is even.
    """
    choices: List[List[int]] = [
        [0, 1] if m % 2 == 0 else [0] for m in moduli
    ]
    return [tuple(v) for v in product(*choices)]


def eval_character(gen_values: Tuple[int, ...], x: Tuple[int, ...]) -> int:
    """psi(x) = sum_j gen_values[j] * x[j]  (mod 2)."""
    return sum(g * xi for g, xi in zip(gen_values, x)) % 2


def bipartite_certificate(
    moduli: Tuple[int, ...], connection_set: List[Tuple[int, ...]]
) -> Optional[Tuple[int, ...]]:
    """
    Return the generator-values of a character sending every connection-set
    element to 1 (a bipartiteness certificate), or None if none exists.
    """
    for gv in characters_to_Z2(moduli):
        if all(eval_character(gv, s) == 1 for s in connection_set):
            return gv
    return None
