from __future__ import annotations
import cmath, math
from typing import Dict

def evaluate_representation(char_table: Dict[int, complex], n: int, a: int) -> complex:
    """rho_D(sigma_a) = D(a)  (explicit_reciprocity / langlandsGL1_apply_coe).
    char_table maps each unit residue to its Dirichlet character value."""
    a %= n
    return char_table.get(a, 0.0 + 0.0j)
