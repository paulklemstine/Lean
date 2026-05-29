"""
applications.py — Real-world applications of Iterated Shadow Geometry.

Demonstrates:
1. Sparse differentiation complexity analysis
2. Newton polytope shadow geometry
3. Polynomial identity testing via shadow invariants
4. Derivative complexity prediction for symbolic computation
"""

from itertools import combinations
from collections import defaultdict


# ─── Inline core functions ──────────────────────────────────────────

def multi_indices_of_mass(n, k):
    if k == 0: return [tuple([0]*n)]
    if n == 0: return []
    if n == 1: return [(k,)]
    result = []
    for first in range(k+1):
        for rest in multi_indices_of_mass(n-1, k-first):
            result.append((first,)+rest)
    return result

def kth_shadow(S, k):
    if not S: return set()
    n = len(next(iter(S)))
    shadow = set()
    for alpha in S:
        for tau in multi_indices_of_mass(n, k):
            if all(tau[i] <= alpha[i] for i in range(n)):
                shadow.add(tuple(alpha[i]-tau[i] for i in range(n)))
    return shadow

def shadow_profile(S, max_k=None):
    if not S: return [0]
    if max_k is None: max_k = max(sum(a) for a in S)
    return [len(kth_shadow(S, k)) for k in range(max_k+1)]

def ascending_factorial(m, k):
    r = 1
    for j in range(k): r *= (m+j)
    return r

def iterated_pderiv(poly, tau):
    n = len(tau)
    result = {}
    for alpha, coeff in poly.items():
        if all(alpha[i] >= tau[i] for i in range(n)):
            beta = tuple(alpha[i]-tau[i] for i in range(n))
            scalar = 1
            for i in range(n):
                scalar *= ascending_factorial(beta[i]+1, tau[i])
            val = scalar * coeff
            if val != 0:
                result[beta] = result.get(beta, 0.0) + val
    return {k: v for k, v in result.items() if abs(v) > 1e-15}


# ─── Application 1: Sparse Differentiation Complexity ───────────────

def sparse_derivative_complexity(support, k):
    """
    Predict the number of nonzero terms in all k-th order derivatives
    using the shadow theorem, without computing any derivatives.

    This is the key application to symbolic computation: the shadow
    gives an exact prediction of derivative sparsity.

    Args:
        support: Set of exponent vectors.
        k: Derivative order.

    Returns:
        Exact number of distinct monomials across all k-th derivatives.
    """
    shadow = kth_shadow(support, k)
    return len(shadow)


def compare_shadow_vs_naive(poly, max_k):
    """
    Compare shadow-based complexity prediction with naive computation.

    Shows that shadow analysis gives exact results without computing
    any actual derivatives — a key win for sparse symbolic computation.
    """
    print("  Application: Sparse Differentiation Complexity Analysis")
    print("  " + "-" * 60)

    support = set(a for a, c in poly.items() if c != 0)
    n = len(next(iter(support)))

    print(f"  Polynomial in {n} variables, {len(support)} terms")
    print(f"  {'k':>4} {'Shadow prediction':>20} {'Actual count':>15} {'Match':>8}")
    print("  " + "-" * 50)

    for k in range(max_k + 1):
        predicted = sparse_derivative_complexity(support, k)
        # Compute actual (expensive)
        actual = set()
        for tau in multi_indices_of_mass(n, k):
            deriv = iterated_pderiv(poly, tau)
            actual.update(deriv.keys())
        match = predicted == len(actual)
        print(f"  {k:>4} {predicted:>20} {len(actual):>15} {'✓' if match else '✗':>8}")
    print()


# ─── Application 2: Newton Polytope Analysis ────────────────────────

def newton_polytope_layers(support):
    """
    Decompose the Newton polytope into shadow layers.

    The k-th shadow represents the "k-interior" of the Newton polytope —
    the set of lattice points reachable by moving k steps inward from
    boundary elements.

    Returns:
        Dict mapping k to the set of points first appearing at depth k.
    """
    max_deg = max(sum(a) for a in support)
    layers = {}
    previous = set()
    for k in range(max_deg + 1):
        current = kth_shadow(support, k)
        new_points = current - previous
        if not new_points and k > 0:
            break
        layers[k] = new_points
        previous = current
    return layers


# ─── Application 3: Polynomial Identity Testing ────────────────────

def shadow_fingerprint(support, max_k=None):
    """
    Compute a polynomial's shadow fingerprint — a sequence of shadow
    cardinalities that serves as a combinatorial invariant.

    Two polynomials with different shadow fingerprints CANNOT be equal,
    regardless of coefficients.

    This gives a fast combinatorial certificate for polynomial non-identity.
    """
    return tuple(shadow_profile(support, max_k))


def test_polynomial_identity(poly1, poly2, max_k=None):
    """
    Quick test: if shadow fingerprints differ, polynomials are definitely
    not identical (modulo coefficient values).
    """
    supp1 = set(a for a, c in poly1.items() if c != 0)
    supp2 = set(a for a, c in poly2.items() if c != 0)
    fp1 = shadow_fingerprint(supp1, max_k)
    fp2 = shadow_fingerprint(supp2, max_k)
    if fp1 != fp2:
        return "DEFINITELY DIFFERENT (shadow fingerprints differ)"
    elif supp1 != supp2:
        return "DIFFERENT SUPPORTS (same fingerprint)"
    else:
        return "SAME SUPPORT (need coefficient check)"


# ─── Application 4: Derivative Decay Rate ──────────────────────────

def derivative_decay_rate(support):
    """
    Compute the rate at which derivative complexity decays.

    Returns pairs (k, a_k / a_{k-1}) showing the fractional decrease
    at each shadow step.
    """
    prof = shadow_profile(support)
    rates = []
    for k in range(1, len(prof)):
        if prof[k-1] > 0:
            rates.append((k, prof[k] / prof[k-1]))
        else:
            rates.append((k, 0.0))
    return rates


# ─── Main ───────────────────────────────────────────────────────────

if __name__ == "__main__":
    print()
    print("=" * 70)
    print("ITERATED SHADOW GEOMETRY — Applications")
    print("=" * 70)
    print()

    # App 1: Sparse differentiation
    poly = {
        (3, 2, 1): 1.0, (2, 0, 3): -2.0, (1, 4, 0): 3.0,
        (0, 1, 5): 1.0, (4, 1, 0): -1.0, (2, 2, 2): 7.0,
    }
    compare_shadow_vs_naive(poly, 6)

    # App 2: Newton polytope layers
    print("  Application: Newton Polytope Layer Decomposition")
    print("  " + "-" * 60)
    support = set(poly.keys())
    layers = newton_polytope_layers(support)
    for k, pts in sorted(layers.items()):
        print(f"  Layer {k}: {len(pts)} new lattice points")
    print()

    # App 3: Polynomial identity testing
    print("  Application: Shadow-Based Identity Testing")
    print("  " + "-" * 60)
    poly2 = {(3, 2, 1): 5.0, (2, 0, 3): -2.0, (1, 4, 0): 3.0,
             (0, 1, 5): 1.0, (4, 1, 0): -1.0, (2, 2, 2): 7.0}
    poly3 = {(3, 2, 1): 1.0, (2, 0, 3): -2.0, (1, 3, 0): 3.0}
    print(f"  f vs f (same coeffs): {test_polynomial_identity(poly, poly)}")
    print(f"  f vs g (same support): {test_polynomial_identity(poly, poly2)}")
    print(f"  f vs h (different support): {test_polynomial_identity(poly, poly3)}")
    print()

    # App 4: Derivative decay rates
    print("  Application: Derivative Complexity Decay Rates")
    print("  " + "-" * 60)
    rates = derivative_decay_rate(support)
    for k, r in rates:
        bar = '▓' * int(30 * r) if r > 0 else ''
        print(f"  k={k}: ratio = {r:.4f}  {bar}")
    print()
