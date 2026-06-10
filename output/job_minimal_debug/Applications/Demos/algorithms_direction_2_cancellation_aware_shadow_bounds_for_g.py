"""
algorithms.py — Cancellation-Aware Shadow Bounds: Core Algorithms

Implements the combinatorial machinery for computing one-step shadows,
cancellation witness sets, shadow deficits, and circuit-level cancellation
budgets for multivariate polynomial supports.

All algorithms operate on supports represented as sets of tuples (exponent vectors).
"""

from itertools import permutations, product
from typing import Set, Tuple, List, Dict, Optional
from collections import Counter
import math


# Type aliases
ExponentVector = tuple  # tuple of non-negative ints
SupportFamily = frozenset  # frozenset of ExponentVectors


def one_shadow(S: Set[ExponentVector]) -> Set[ExponentVector]:
    """
    Compute the one-step downward shadow of a support family S.

    For each exponent vector α in S and each coordinate i with α[i] > 0,
    produce the vector obtained by decrementing α[i] by 1.

    Time: O(|S| * n) where n = dimension of exponent vectors.

    >>> one_shadow({(1, 1, 0)})
    {(0, 1, 0), (1, 0, 0)}
    """
    shadow = set()
    for alpha in S:
        n = len(alpha)
        for i in range(n):
            if alpha[i] > 0:
                beta = list(alpha)
                beta[i] -= 1
                shadow.add(tuple(beta))
    return shadow


def cancel_set(supp_f: Set[ExponentVector], supp_g: Set[ExponentVector],
               supp_fg: Set[ExponentVector]) -> Set[ExponentVector]:
    """
    Compute the cancellation witness set:
        Cancel(f, g) = (supp(f) ∪ supp(g)) \ supp(f + g)

    These are the monomials that exist in at least one of f, g but
    vanish in f + g due to coefficient cancellation.

    >>> cancel_set({(1,0)}, {(1,0), (0,1)}, {(0,1)})
    {(1, 0)}
    """
    return (supp_f | supp_g) - supp_fg


def shadow_deficit(supp_f: Set[ExponentVector], supp_g: Set[ExponentVector],
                   supp_fg: Set[ExponentVector]) -> int:
    """
    Compute the shadow deficit:
        Δ_sh(f,g) = |Sh(supp(f) ∪ supp(g))| - |Sh(supp(f+g))|

    This measures how much one-shadow is lost under cancellation.

    Returns: non-negative integer (proven ≤ |Sh(Cancel(f,g))|).
    """
    union_shadow = len(one_shadow(supp_f | supp_g))
    sum_shadow = len(one_shadow(supp_fg))
    return max(0, union_shadow - sum_shadow)


def support_mul(A: Set[ExponentVector], B: Set[ExponentVector]) -> Set[ExponentVector]:
    """
    Minkowski sum (pointwise addition) of two support families.
    Models the support of f * g in the absence of cancellation.

    Time: O(|A| * |B| * n)
    """
    result = set()
    for a in A:
        for b in B:
            result.add(tuple(ai + bi for ai, bi in zip(a, b)))
    return result


def monotone_envelope_shadow_bound(circuit: dict) -> int:
    """
    Compute the recursive monotone envelope shadow bound for a circuit.

    Circuit is a dict with:
      - 'type': 'atom' | 'add' | 'mul'
      - 'support': set of ExponentVectors (for atoms)
      - 'left', 'right': sub-circuits (for add/mul)
      - 'n': dimension
    """
    if circuit['type'] == 'atom':
        return circuit['n'] * len(circuit['support'])
    elif circuit['type'] == 'add':
        return (monotone_envelope_shadow_bound(circuit['left']) +
                monotone_envelope_shadow_bound(circuit['right']))
    elif circuit['type'] == 'mul':
        n = circuit['n']
        left_env = compute_envelope(circuit['left'])
        right_env = compute_envelope(circuit['right'])
        return n * len(left_env) * len(right_env)
    else:
        raise ValueError(f"Unknown circuit type: {circuit['type']}")


def compute_envelope(circuit: dict) -> Set[ExponentVector]:
    """
    Compute the monotone support envelope of a circuit.
    Ignores all cancellation: add → union, mul → Minkowski sum.
    """
    if circuit['type'] == 'atom':
        return circuit['support']
    elif circuit['type'] == 'add':
        return compute_envelope(circuit['left']) | compute_envelope(circuit['right'])
    elif circuit['type'] == 'mul':
        return support_mul(compute_envelope(circuit['left']),
                          compute_envelope(circuit['right']))
    else:
        raise ValueError(f"Unknown circuit type: {circuit['type']}")


def compute_actual_support(circuit: dict) -> Set[ExponentVector]:
    """
    Compute the actual support of a circuit (with cancellation at add gates).
    """
    if circuit['type'] == 'atom':
        return circuit['support']
    elif circuit['type'] == 'add':
        return circuit.get('actual_support',
                          compute_actual_support(circuit['left']) |
                          compute_actual_support(circuit['right']))
    elif circuit['type'] == 'mul':
        return support_mul(compute_actual_support(circuit['left']),
                          compute_actual_support(circuit['right']))
    else:
        raise ValueError(f"Unknown circuit type: {circuit['type']}")


def cancel_budget(circuit: dict) -> int:
    """
    Compute the recursive cancellation budget B(C).

    For atom: 0
    For add: B(left) + B(right) + |Sh(envelope \ actual)|
    For mul: B(left) + B(right)
    """
    if circuit['type'] == 'atom':
        return 0
    elif circuit['type'] == 'add':
        env = compute_envelope(circuit['left']) | compute_envelope(circuit['right'])
        act = circuit.get('actual_support', env)
        local_cancel = env - act
        local_shadow = len(one_shadow(local_cancel))
        return (cancel_budget(circuit['left']) +
                cancel_budget(circuit['right']) +
                local_shadow)
    elif circuit['type'] == 'mul':
        return cancel_budget(circuit['left']) + cancel_budget(circuit['right'])
    else:
        raise ValueError(f"Unknown circuit type: {circuit['type']}")


# --- Determinant and Permanent ---

def determinant_support(n: int) -> Set[ExponentVector]:
    """
    Support of the n×n determinant polynomial.
    Each permutation σ contributes the monomial ∏ x_{i,σ(i)}.
    Exponent vector has n² components indexed by (i,j) → i*n + j.
    """
    support = set()
    indices = list(range(n))
    for perm in permutations(indices):
        vec = [0] * (n * n)
        for i in range(n):
            vec[i * n + perm[i]] = 1
        support.add(tuple(vec))
    return support


def permanent_support(n: int) -> Set[ExponentVector]:
    """
    Support of the n×n permanent polynomial.
    Same as determinant support (both are sums over permutations
    with the same monomial structure; only signs differ).
    """
    return determinant_support(n)  # Same monomials, different coefficients


def determinant_polynomial(n: int) -> Dict[ExponentVector, int]:
    """
    Full determinant polynomial with coefficients.
    Returns dict mapping exponent vectors to coefficients.
    """
    poly = {}
    indices = list(range(n))
    for perm in permutations(indices):
        # Compute sign of permutation
        sign = perm_sign(list(perm))
        vec = [0] * (n * n)
        for i in range(n):
            vec[i * n + perm[i]] = 1
        key = tuple(vec)
        poly[key] = poly.get(key, 0) + sign
    return {k: v for k, v in poly.items() if v != 0}


def permanent_polynomial(n: int) -> Dict[ExponentVector, int]:
    """
    Full permanent polynomial with coefficients.
    All coefficients are +1.
    """
    poly = {}
    indices = list(range(n))
    for perm in permutations(indices):
        vec = [0] * (n * n)
        for i in range(n):
            vec[i * n + perm[i]] = 1
        key = tuple(vec)
        poly[key] = poly.get(key, 0) + 1
    return {k: v for k, v in poly.items() if v != 0}


def perm_sign(perm: List[int]) -> int:
    """Compute the sign of a permutation (+1 or -1)."""
    n = len(perm)
    visited = [False] * n
    sign = 1
    for i in range(n):
        if visited[i]:
            continue
        j = i
        cycle_len = 0
        while not visited[j]:
            visited[j] = True
            j = perm[j]
            cycle_len += 1
        if cycle_len % 2 == 0:
            sign *= -1
    return sign


def add_polynomials(p: Dict[ExponentVector, int],
                    q: Dict[ExponentVector, int]) -> Dict[ExponentVector, int]:
    """Add two polynomials represented as coefficient dictionaries."""
    result = dict(p)
    for k, v in q.items():
        result[k] = result.get(k, 0) + v
    return {k: v for k, v in result.items() if v != 0}


def poly_support(p: Dict[ExponentVector, int]) -> Set[ExponentVector]:
    """Get the support of a polynomial."""
    return set(p.keys())


def analyze_polynomial_pair(name: str,
                           supp_f: Set[ExponentVector],
                           supp_g: Set[ExponentVector],
                           supp_sum: Set[ExponentVector],
                           n_vars: int) -> Dict:
    """
    Full analysis of a polynomial addition f + g:
    support sizes, shadow sizes, cancellation, and deficit bounds.
    """
    union = supp_f | supp_g
    cancel = cancel_set(supp_f, supp_g, supp_sum)

    sh_union = one_shadow(union)
    sh_sum = one_shadow(supp_sum)
    sh_cancel = one_shadow(cancel)

    deficit = max(0, len(sh_union) - len(sh_sum))

    result = {
        'name': name,
        'n_vars': n_vars,
        '|supp(f)|': len(supp_f),
        '|supp(g)|': len(supp_g),
        '|supp(f) ∪ supp(g)|': len(union),
        '|supp(f+g)|': len(supp_sum),
        '|Cancel(f,g)|': len(cancel),
        '|Sh(supp(f) ∪ supp(g))|': len(sh_union),
        '|Sh(supp(f+g))|': len(sh_sum),
        '|Sh(Cancel(f,g))|': len(sh_cancel),
        'shadow_deficit': deficit,
        'deficit_bound_holds': deficit <= len(sh_cancel),
        'cancel_rate': len(cancel) / max(1, len(union)),
    }
    return result


if __name__ == '__main__':
    # Quick self-test
    S = {(1, 1, 0), (1, 0, 1), (0, 1, 1)}
    sh = one_shadow(S)
    print(f"Shadow of {S}:")
    print(f"  = {sh}")
    print(f"  |Sh| = {len(sh)}")

    # Test cancel set
    f_supp = {(1, 0), (0, 1)}
    g_supp = {(1, 0)}
    fg_supp = {(0, 1)}  # (1,0) cancelled
    cs = cancel_set(f_supp, g_supp, fg_supp)
    print(f"\nCancel set: {cs}")
    print(f"Shadow deficit: {shadow_deficit(f_supp, g_supp, fg_supp)}")
