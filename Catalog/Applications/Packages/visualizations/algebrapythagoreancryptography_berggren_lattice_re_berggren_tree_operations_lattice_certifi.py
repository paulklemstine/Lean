#!/usr/bin/env python3
"""
Algorithms for Berggren Lattice-Reduction Duality

Implements the core algorithms from the research:
1. Berggren tree generation and traversal
2. Gram matrix construction (positive-definite, degenerate, lifted)
3. Certificate extraction and reconstruction
4. Ancestry inversion (parent computation)
5. Minimal subtree computation
"""

import numpy as np
from math import gcd, isqrt
from typing import Tuple, List, Optional, Set, Dict

# ─── Type aliases ────────────────────────────────────────────────

Triple = Tuple[int, int, int]

# ─── Berggren Matrices ──────────────────────────────────────────

BERGGREN_A = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]], dtype=int)
BERGGREN_B = np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]], dtype=int)
BERGGREN_C = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]], dtype=int)

INV_A = np.array([[1, 2, -2], [-2, -1, 2], [-2, -2, 3]], dtype=int)
INV_B = np.array([[1, 2, -2], [2, 1, -2], [-2, -2, 3]], dtype=int)
INV_C = np.array([[-1, -2, 2], [2, 1, -2], [-2, -2, 3]], dtype=int)

BERGGREN_MATRICES = [BERGGREN_A, BERGGREN_B, BERGGREN_C]
INVERSE_MATRICES = [INV_A, INV_B, INV_C]

# ─── Core Functions ─────────────────────────────────────────────

def is_primitive_triple(a: int, b: int, c: int) -> bool:
    """Check if (a, b, c) is a normalized primitive Pythagorean triple.

    Args:
        a: First leg (must be odd)
        b: Second leg (must be even)
        c: Hypotenuse

    Returns:
        True if (a, b, c) is a primitive Pythagorean triple with a odd, b even.
    """
    return (a > 0 and b > 0 and c > 0 and
            a*a + b*b == c*c and
            gcd(a, b) == 1 and
            a % 2 == 1 and b % 2 == 0)


def berggren_child(matrix_idx: int, triple: Triple) -> Triple:
    """Apply a Berggren matrix to a triple.

    Args:
        matrix_idx: 0 for A, 1 for B, 2 for C
        triple: Input (a, b, c)

    Returns:
        Child triple (a', b', c')
    """
    v = np.array(triple, dtype=int)
    result = BERGGREN_MATRICES[matrix_idx] @ v
    return (int(result[0]), int(result[1]), int(result[2]))


def berggren_parent(triple: Triple) -> Optional[Tuple[int, Triple]]:
    """Compute the unique parent of a triple in the Berggren tree.

    Args:
        triple: Input (a, b, c)

    Returns:
        (matrix_idx, parent_triple) or None if triple is root (3, 4, 5)
    """
    if triple == (3, 4, 5):
        return None

    v = np.array(triple, dtype=int)
    for idx, inv_mat in enumerate(INVERSE_MATRICES):
        parent = inv_mat @ v
        a, b, c = int(parent[0]), int(parent[1]), int(parent[2])
        if a > 0 and b > 0 and c > 0 and a*a + b*b == c*c:
            return (idx, (a, b, c))

    return None


def berggren_ancestry(triple: Triple) -> List[Tuple[int, Triple]]:
    """Compute the full ancestry path from root to triple.

    Args:
        triple: Input (a, b, c)

    Returns:
        List of (matrix_idx, triple) from root to input
    """
    path = []
    current = triple
    while current != (3, 4, 5):
        result = berggren_parent(current)
        if result is None:
            break
        idx, parent = result
        path.append((idx, current))
        current = parent
    path.reverse()
    return path


def berggren_depth(triple: Triple) -> int:
    """Compute the depth of a triple in the Berggren tree.

    Args:
        triple: Input (a, b, c)

    Returns:
        Depth (0 for root)
    """
    return len(berggren_ancestry(triple))


# ─── Gram Matrix Construction ───────────────────────────────────

def gram_positive_definite(a: int, b: int, c: int) -> np.ndarray:
    """Construct the rank-2 positive-definite Gram matrix.

    G+(a,b,c) = [[c, a], [a, c]]

    Properties:
        - det(G+) = c² - a² = b² > 0
        - trace(G+) = 2c
        - Symmetric, positive definite

    Args:
        a, b, c: Components of a primitive Pythagorean triple

    Returns:
        2×2 integer Gram matrix
    """
    return np.array([[c, a], [a, c]], dtype=int)


def gram_lifted(a: int, b: int, c: int) -> np.ndarray:
    """Construct the rank-3 lifted Gram matrix.

    G̃(a,b,c) = [[c, a, 0], [a, c, 0], [0, 0, c]]

    Properties:
        - det(G̃) = c · b²
        - Positive definite
        - Block diagonal: G+ ⊕ [c]

    Args:
        a, b, c: Components of a primitive Pythagorean triple

    Returns:
        3×3 integer Gram matrix
    """
    return np.array([[c, a, 0], [a, c, 0], [0, 0, c]], dtype=int)


def gram_degenerate(a: int, b: int, c: int) -> np.ndarray:
    """Construct the degenerate boundary Gram matrix.

    G₀(a,b,c) = [[c+a, b], [b, c-a]]

    Properties:
        - det(G₀) = (c+a)(c-a) - b² = c² - a² - b² = 0
        - Rank 1 (semidefinite boundary)
        - Positive semidefinite for valid triples

    Args:
        a, b, c: Components of a primitive Pythagorean triple

    Returns:
        2×2 integer Gram matrix (degenerate)
    """
    return np.array([[c + a, b], [b, c - a]], dtype=int)


# ─── Certificate Operations ─────────────────────────────────────

def extract_certificate(triple: Triple) -> Dict:
    """Extract a lattice certificate from a primitive triple.

    Args:
        triple: (a, b, c) primitive Pythagorean triple

    Returns:
        Certificate dictionary with gram_diag, gram_off, gram_det, and validity data
    """
    a, b, c = triple
    return {
        'gram_diag': c,
        'gram_off': a,
        'gram_det': b * b,
        'trace': 2 * c,
        'short_basis_bound': c,
        'parity': 'a_odd' if a % 2 == 1 else 'a_even',
        'depth': berggren_depth(triple),
    }


def reconstruct_from_certificate(cert: Dict) -> Optional[Triple]:
    """Reconstruct a primitive triple from a valid certificate.

    Args:
        cert: Certificate dictionary

    Returns:
        Reconstructed triple (a, b, c) or None if invalid
    """
    c = cert['gram_diag']
    a = cert['gram_off']
    det = cert['gram_det']

    # Check b² = det
    b = isqrt(det)
    if b * b != det:
        return None

    # Verify Pythagorean
    if a * a + b * b != c * c:
        return None

    # Verify primitivity
    if gcd(a, b) != 1:
        return None

    return (a, b, c)


# ─── Minimal Subtree Computation ────────────────────────────────

def minimal_generating_subtree(triples: Set[Triple]) -> Set[Triple]:
    """Compute the minimal generating subtree for a set of triples.

    A triple t is a generator if no ancestor of t is also in the set.

    Args:
        triples: Set of primitive Pythagorean triples

    Returns:
        Minimal generating subset
    """
    generators = set()
    for t in triples:
        # Check if any ancestor is in the set
        current = t
        is_generated = False
        while current != (3, 4, 5):
            result = berggren_parent(current)
            if result is None:
                break
            _, parent = result
            if parent in triples and parent != t:
                is_generated = True
                break
            current = parent
        if not is_generated:
            generators.add(t)
    return generators


def berggren_closure(generators: Set[Triple], max_depth: int = 5) -> Set[Triple]:
    """Compute the Berggren closure of a set of generators up to a given depth.

    Args:
        generators: Set of seed triples
        max_depth: Maximum number of Berggren steps to apply

    Returns:
        Closure set
    """
    closure = set(generators)
    frontier = set(generators)
    for _ in range(max_depth):
        new_frontier = set()
        for t in frontier:
            for idx in range(3):
                child = berggren_child(idx, t)
                if child not in closure:
                    closure.add(child)
                    new_frontier.add(child)
        frontier = new_frontier
    return closure


# ─── Verification ────────────────────────────────────────────────

def verify_duality_package(triples: List[Triple]) -> Dict:
    """Verify all components of the duality package for a family of triples.

    Args:
        triples: List of primitive Pythagorean triples

    Returns:
        Dictionary of verification results
    """
    results = {
        'family_size': len(triples),
        'all_primitive': all(is_primitive_triple(*t) for t in triples),
        'certificates': [],
        'all_certs_distinct': True,
        'all_pos_def': True,
        'all_bounded': True,
        'all_reconstructible': True,
    }

    cert_set = set()
    for a, b, c in triples:
        cert = extract_certificate((a, b, c))
        cert_key = (cert['gram_diag'], cert['gram_off'], cert['gram_det'])

        G = gram_positive_definite(a, b, c)
        det_G = int(np.linalg.det(G).round())

        results['certificates'].append({
            'triple': (a, b, c),
            'certificate': cert,
            'det': det_G,
            'pos_def': c > 0 and det_G > 0,
            'bounded': a <= c and b <= c,
        })

        if cert_key in cert_set:
            results['all_certs_distinct'] = False
        cert_set.add(cert_key)

        if not (c > 0 and det_G > 0):
            results['all_pos_def'] = False
        if not (a <= c and b <= c):
            results['all_bounded'] = False

        reconstructed = reconstruct_from_certificate(cert)
        if reconstructed != (a, b, c):
            results['all_reconstructible'] = False

    return results


if __name__ == "__main__":
    # Quick verification
    print("Berggren Lattice-Reduction Duality - Algorithm Verification")
    print("=" * 60)

    # Test ancestry
    triple = (7, 24, 25)
    ancestry = berggren_ancestry(triple)
    print(f"\nAncestry of {triple}:")
    print(f"  Root: (3, 4, 5)")
    for idx, t in ancestry:
        label = ['A', 'B', 'C'][idx]
        print(f"  → [{label}] → {t}")

    # Test reconstruction
    cert = extract_certificate((5, 12, 13))
    print(f"\nCertificate of (5, 12, 13): {cert}")
    rec = reconstruct_from_certificate(cert)
    print(f"Reconstructed: {rec}")

    # Test minimal subtree
    family = {(3, 4, 5), (5, 12, 13), (7, 24, 25), (21, 20, 29)}
    minimal = minimal_generating_subtree(family)
    print(f"\nMinimal generators of {family}:")
    print(f"  {minimal}")

    # Full verification
    triples = [(3, 4, 5), (5, 12, 13), (7, 24, 25), (15, 8, 17), (21, 20, 29)]
    results = verify_duality_package(triples)
    print(f"\nDuality package verification for {len(triples)} triples:")
    print(f"  All primitive: {results['all_primitive']}")
    print(f"  All certificates distinct: {results['all_certs_distinct']}")
    print(f"  All positive definite: {results['all_pos_def']}")
    print(f"  All bounded: {results['all_bounded']}")
    print(f"  All reconstructible: {results['all_reconstructible']}")
