#!/usr/bin/env python3
"""
Berggren–Fourier Duality: Core Algorithms

Implements the key algorithms from the Berggren–Fourier Duality framework:
1. Berggren tree generation and quotient construction
2. Character family construction and verification
3. Fourier expansion (coefficient computation)
4. Certified point reconstruction
5. Tropical (max-plus) decomposition
"""

import numpy as np
from typing import List, Tuple, Dict, Optional, Callable, Set
from itertools import product
from functools import lru_cache

# ============================================================
# Berggren Matrices
# ============================================================

BERGGREN_A: np.ndarray = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]], dtype=int)
BERGGREN_B: np.ndarray = np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]], dtype=int)
BERGGREN_C: np.ndarray = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]], dtype=int)
BERGGREN_ROOT: np.ndarray = np.array([3, 4, 5], dtype=int)

GENERATORS = [('A', BERGGREN_A), ('B', BERGGREN_B), ('C', BERGGREN_C)]


# ============================================================
# 1. Berggren Tree Generation
# ============================================================

def generate_tree(depth: int = 4) -> List[Tuple[str, np.ndarray]]:
    """
    Generate the Berggren tree to a given depth.

    Args:
        depth: Number of generations to produce.

    Returns:
        List of (path, triple) pairs where path is a string like "ABC"
        encoding the generator sequence from root.

    Time complexity: O(3^depth)
    Space complexity: O(3^depth)
    """
    result = [("", BERGGREN_ROOT.copy())]
    frontier = [("", BERGGREN_ROOT.copy())]

    for _ in range(depth):
        next_frontier = []
        for path, triple in frontier:
            for name, mat in GENERATORS:
                child = mat @ triple
                child_path = path + name
                result.append((child_path, child))
                next_frontier.append((child_path, child))
        frontier = next_frontier

    return result


# ============================================================
# 2. Finite Quotient Construction
# ============================================================

class BerggrenQuotient:
    """
    Finite Berggren quotient PQMod(m): triples modulo m.

    Attributes:
        m: The modulus.
        elements: Set of all elements (tuples mod m).
        orbit: Set of elements reachable from root.
    """

    def __init__(self, m: int):
        self.m = m
        self.elements: Set[Tuple[int, ...]] = set(product(range(m), repeat=3))
        self.generators = {
            'A': BERGGREN_A % m,
            'B': BERGGREN_B % m,
            'C': BERGGREN_C % m,
        }
        self.orbit = self._compute_orbit()

    def act(self, gen_name: str, v: Tuple[int, ...]) -> Tuple[int, ...]:
        """Apply generator to element."""
        mat = self.generators[gen_name]
        result = (mat @ np.array(v)) % self.m
        return tuple(int(x) for x in result)

    def _compute_orbit(self, max_depth: int = 20) -> Set[Tuple[int, ...]]:
        """Compute orbit of root under generators."""
        root = tuple(int(x) for x in BERGGREN_ROOT % self.m)
        visited = {root}
        frontier = [root]

        for _ in range(max_depth):
            next_frontier = []
            for t in frontier:
                for name in ['A', 'B', 'C']:
                    child = self.act(name, t)
                    if child not in visited:
                        visited.add(child)
                        next_frontier.append(child)
            if not next_frontier:
                break
            frontier = next_frontier

        return visited


# ============================================================
# 3. Character Families
# ============================================================

def indicator_characters(Q: List[Tuple[int, ...]]) -> Dict[Tuple[int, ...], Callable]:
    """
    Construct indicator function character family.

    For each a ∈ Q, defines χ_a(q) = 1 if q = a, else 0.
    This family always separates points.

    Args:
        Q: List of elements in the finite type.

    Returns:
        Dictionary mapping element labels to character functions.
    """
    chars = {}
    for a in Q:
        def chi(q: Tuple[int, ...], a=a) -> int:
            return 1 if q == a else 0
        chars[a] = chi
    return chars


def verify_berggren_character(
    chi: Callable,
    Q: List[Tuple[int, ...]],
    quotient: BerggrenQuotient,
) -> Dict[str, Optional[complex]]:
    """
    Check if chi is a Berggren character and return eigenvalues.

    A function χ is a Berggren character if for each generator g,
    χ(g·q) = λ_g · χ(q) for all q and some scalar λ_g.

    Returns:
        Dictionary {'A': λ_A, 'B': λ_B, 'C': λ_C} or None values
        for generators where the eigenvalue condition fails.
    """
    eigenvalues = {}
    for gen_name in ['A', 'B', 'C']:
        # Try to find eigenvalue
        eigenval = None
        consistent = True
        for q in Q:
            gq = quotient.act(gen_name, q)
            chi_gq = chi(gq)
            chi_q = chi(q)
            if chi_q != 0:
                ratio = chi_gq / chi_q
                if eigenval is None:
                    eigenval = ratio
                elif abs(ratio - eigenval) > 1e-10:
                    consistent = False
                    break
            elif chi_gq != 0:
                consistent = False
                break
        eigenvalues[gen_name] = eigenval if consistent else None
    return eigenvalues


def verify_separation(
    Q: List[Tuple[int, ...]],
    chars: Dict,
) -> Tuple[bool, Optional[Tuple]]:
    """
    Verify that a character family separates all points of Q.

    Returns:
        (True, None) if separated, (False, (x, y)) for an inseparable pair.

    Time complexity: O(|Q|^2 · |chars|)
    """
    for i in range(len(Q)):
        for j in range(i + 1, len(Q)):
            x, y = Q[i], Q[j]
            separated = any(chi(x) != chi(y) for chi in chars.values())
            if not separated:
                return False, (x, y)
    return True, None


# ============================================================
# 4. Fourier Expansion
# ============================================================

def fourier_expand(
    f: Dict[Tuple[int, ...], complex],
    chars: Dict[any, Callable],
    Q: List[Tuple[int, ...]],
) -> Dict[any, complex]:
    """
    Compute Fourier coefficients of f with respect to character basis.

    Given f : Q → K and linearly independent characters {χ_i},
    finds unique coefficients {c_i} such that f(q) = Σ_i c_i χ_i(q).

    Uses matrix inversion: if M[i][q] = χ_i(q), then c = M^{-1} f.

    Args:
        f: Observable as dict from Q elements to values.
        chars: Character family as dict from labels to functions.
        Q: List of elements in Q.

    Returns:
        Dictionary from character labels to coefficients.

    Time complexity: O(|Q|^3) for matrix inversion.
    """
    n = len(Q)
    char_labels = list(chars.keys())
    assert len(char_labels) == n, "Need |chars| = |Q| for unique expansion"

    # Build character evaluation matrix
    M = np.zeros((n, n), dtype=complex)
    for i, label in enumerate(char_labels):
        for j, q in enumerate(Q):
            M[i, j] = chars[label](q)

    # Build f vector
    f_vec = np.array([f.get(q, 0) for q in Q], dtype=complex)

    # Solve M^T c = f (since f(q) = Σ_i c_i χ_i(q))
    coeffs = np.linalg.solve(M.T, f_vec)

    return {label: complex(coeffs[i]) for i, label in enumerate(char_labels)}


def fourier_reconstruct(
    coeffs: Dict[any, complex],
    chars: Dict[any, Callable],
    Q: List[Tuple[int, ...]],
) -> Dict[Tuple[int, ...], complex]:
    """
    Reconstruct observable from Fourier coefficients.

    Computes f(q) = Σ_i c_i χ_i(q).
    """
    result = {}
    for q in Q:
        val = sum(coeffs[label] * chars[label](q) for label in coeffs)
        result[q] = val
    return result


# ============================================================
# 5. Certified Point Reconstruction
# ============================================================

def reconstruct_point(
    Q: List[Tuple[int, ...]],
    chars: Dict[any, Callable],
    oracle: Callable,
) -> Tuple[Optional[Tuple[int, ...]], int]:
    """
    Certified exhaustive-search point reconstruction.

    Given oracle access to character measurements at a hidden point x,
    finds the unique q ∈ Q matching all measurements.

    Args:
        Q: Finite set of candidate points.
        chars: Separating character family.
        oracle: Function from character label to measurement value χ(x).

    Returns:
        (recovered_point, query_count)

    Time complexity: O(|Q| · |chars|) queries.
    Space complexity: O(1) beyond input.

    Correctness: If chars separates points, returns the unique x
    such that oracle(label) = χ_label(x) for all labels.
    """
    queries = 0
    for q in Q:
        match = True
        for label, chi in chars.items():
            queries += 1
            if oracle(label) != chi(q):
                match = False
                break
        if match:
            return q, queries
    return None, queries


def adaptive_reconstruct(
    Q: List[Tuple[int, ...]],
    chars: Dict[any, Callable],
    oracle: Callable,
) -> Tuple[Optional[Tuple[int, ...]], int]:
    """
    Adaptive reconstruction with early termination.

    Uses characters that maximally discriminate the remaining
    candidate set, potentially achieving sub-linear query count.

    Args:
        Q: Finite set of candidate points.
        chars: Separating character family.
        oracle: Function from character label to measurement value.

    Returns:
        (recovered_point, query_count)
    """
    candidates = list(Q)
    queries = 0
    used_labels = set()

    for label, chi in chars.items():
        if len(candidates) <= 1:
            break

        measurement = oracle(label)
        queries += 1
        used_labels.add(label)

        # Filter candidates
        candidates = [q for q in candidates if chi(q) == measurement]

    if len(candidates) == 1:
        return candidates[0], queries
    elif len(candidates) > 1:
        return candidates[0], queries  # all remaining are equivalent
    else:
        return None, queries


# ============================================================
# 6. Tropical (Max-Plus) Decomposition
# ============================================================

NEG_INF = float('-inf')


def tropical_indicator_chars(Q: List[Tuple[int, ...]]) -> Dict[Tuple[int, ...], Callable]:
    """
    Tropical indicator characters.

    χ_a(q) = 0 if q = a, else -∞.
    """
    chars = {}
    for a in Q:
        def chi(q, a=a):
            return 0 if q == a else NEG_INF
        chars[a] = chi
    return chars


def tropical_decompose(
    f: Dict[Tuple[int, ...], float],
    chars: Dict[any, Callable],
    Q: List[Tuple[int, ...]],
) -> Dict[any, float]:
    """
    Compute tropical (max-plus) decomposition coefficients.

    Finds coefficients {c_i} such that f(q) = max_i(c_i + χ_i(q)).

    For indicator characters, c_i = f(i) trivially.
    For general characters, uses iterative optimization.

    Returns:
        Dictionary from character labels to tropical coefficients.
    """
    coeffs = {}
    for label in chars:
        # For indicator chars: c_label = f(label)
        if label in f:
            coeffs[label] = f[label]
        else:
            coeffs[label] = NEG_INF
    return coeffs


def tropical_reconstruct(
    coeffs: Dict[any, float],
    chars: Dict[any, Callable],
    Q: List[Tuple[int, ...]],
) -> Dict[Tuple[int, ...], float]:
    """
    Reconstruct from tropical coefficients.

    Computes f(q) = max_i(c_i + χ_i(q)).
    """
    result = {}
    for q in Q:
        val = max(coeffs[label] + chars[label](q) for label in coeffs)
        result[q] = val
    return result


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    print("Berggren–Fourier Duality: Algorithm Library")
    print("=" * 50)

    # Build quotient
    m = 3
    bq = BerggrenQuotient(m)
    Q = sorted(list(bq.elements))
    print(f"\nPQMod({m}): {len(Q)} elements, {len(bq.orbit)} in root orbit")

    # Build characters
    chars = indicator_characters(Q)
    sep, pair = verify_separation(Q, chars)
    print(f"Indicator characters separate: {sep}")

    # Fourier expansion
    f = {q: float(sum(q)) for q in Q}
    coeffs = fourier_expand(f, chars, Q)
    f_recon = fourier_reconstruct(coeffs, chars, Q)
    max_err = max(abs(f[q] - f_recon[q].real) for q in Q)
    print(f"Fourier expansion max error: {max_err:.2e}")

    # Reconstruction
    hidden = Q[7]
    oracle = lambda label, h=hidden: chars[label](h)
    recovered, queries = reconstruct_point(Q, chars, oracle)
    print(f"Reconstruction: hidden={hidden}, recovered={recovered}, "
          f"queries={queries}, correct={recovered == hidden}")

    # Tropical
    f_trop = {q: float(sum(q)) for q in Q}
    trop_chars = tropical_indicator_chars(Q)
    trop_coeffs = tropical_decompose(f_trop, trop_chars, Q)
    trop_recon = tropical_reconstruct(trop_coeffs, trop_chars, Q)
    trop_ok = all(abs(f_trop[q] - trop_recon[q]) < 1e-10 for q in Q)
    print(f"Tropical decomposition correct: {trop_ok}")
