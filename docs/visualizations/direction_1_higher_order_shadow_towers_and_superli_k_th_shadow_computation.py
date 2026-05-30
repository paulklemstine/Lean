"""
Algorithms for Higher-Order Shadow Tower Computation
=====================================================

Implements efficient algorithms for computing k-th shadows,
shadow tower analysis, and circuit lower bound estimation.

All algorithms include type hints, docstrings, and example usage.
"""
from math import comb, log2
from typing import Optional
from collections import defaultdict


# ============================================================
# Core Shadow Computation
# ============================================================

def generate_simplex_vectors(d: int, m: int) -> list[tuple[int, ...]]:
    """Generate all vectors in N^d summing to m using dynamic programming.
    
    Time: O(C(m+d-1, d-1) * d)
    Space: O(C(m+d-1, d-1) * d)
    
    Args:
        d: Number of variables (dimension).
        m: Total degree.
    
    Returns:
        List of d-tuples summing to m.
    
    >>> len(generate_simplex_vectors(3, 4))
    15
    """
    if d <= 0:
        return [()] if m == 0 else []
    if d == 1:
        return [(m,)]
    result = []
    for first in range(m + 1):
        for rest in generate_simplex_vectors(d - 1, m - first):
            result.append((first,) + rest)
    return result


def compute_first_shadow(support: set[tuple[int, ...]]) -> set[tuple[int, ...]]:
    """Compute the first shadow of a support set.
    
    For each vector alpha in S and each coordinate i with alpha_i > 0,
    produces beta = alpha - e_i.
    
    Time: O(|S| * d)
    Space: O(|Sh_1(S)| * d)
    
    Args:
        support: Set of exponent vectors.
    
    Returns:
        The first shadow Sh_1(S).
    """
    shadow: set[tuple[int, ...]] = set()
    for alpha in support:
        d = len(alpha)
        for i in range(d):
            if alpha[i] > 0:
                beta = list(alpha)
                beta[i] -= 1
                shadow.add(tuple(beta))
    return shadow


def compute_kth_shadow(k: int, support: set[tuple[int, ...]]) -> set[tuple[int, ...]]:
    """Compute the k-th shadow by iterating first shadow k times.
    
    Time: O(k * |S| * d)  (amortized, actual depends on intermediate sizes)
    Space: O(max_{j} |Sh_j(S)| * d)
    
    Args:
        k: Shadow order.
        support: Initial support set.
    
    Returns:
        The k-th shadow Sh_k(S).
    """
    current = support
    for _ in range(k):
        current = compute_first_shadow(current)
    return current


def shadow_tower(support: set[tuple[int, ...]], max_k: Optional[int] = None) -> list[set[tuple[int, ...]]]:
    """Compute the full shadow tower Sh_0, Sh_1, ..., Sh_k.
    
    Stops when the shadow becomes empty or max_k is reached.
    
    Args:
        support: Initial support set.
        max_k: Maximum shadow order (None for automatic).
    
    Returns:
        List of shadow sets from order 0 to k.
    """
    tower = [support]
    current = support
    k = 0
    while current and (max_k is None or k < max_k):
        current = compute_first_shadow(current)
        tower.append(current)
        k += 1
    return tower


# ============================================================
# Circuit Lower Bound Algorithms
# ============================================================

def circuit_lower_bound(d: int, m: int, k: int) -> float:
    """Compute the circuit lower bound for k-th derivative computation.
    
    For support T(d, m), the circuit must have size at least:
        C(m - k + d - 1, d - 1) / d^k
    
    Time: O(d)  (for binomial coefficient computation)
    
    Args:
        d: Number of variables.
        m: Polynomial degree.
        k: Derivative order.
    
    Returns:
        Lower bound on circuit size.
    
    >>> circuit_lower_bound(3, 10, 2) >= 5.0
    True
    """
    if k > m:
        return 0.0
    shadow_card = comb(m - k + d - 1, d - 1)
    channels = d ** k
    return shadow_card / channels if channels > 0 else float('inf')


def tower_lower_bounds(d: int, m: int, max_k: Optional[int] = None) -> list[dict]:
    """Compute the full tower of circuit lower bounds.
    
    Returns a list of dictionaries with shadow cardinality, bound,
    and ratio information for each level.
    
    Args:
        d: Number of variables.
        m: Polynomial degree.
        max_k: Maximum order (default: m).
    
    Returns:
        List of bound information dictionaries.
    """
    if max_k is None:
        max_k = m
    
    base_card = comb(m + d - 1, d - 1)
    bounds = []
    
    for k in range(max_k + 1):
        shadow_card = comb(m - k + d - 1, d - 1) if k <= m else 0
        channels = d ** k
        lb = shadow_card / channels if channels > 0 else 0.0
        ratio = shadow_card / base_card if base_card > 0 else 0.0
        
        bounds.append({
            'k': k,
            'shadow_card': shadow_card,
            'channels': channels,
            'lower_bound': lb,
            'shadow_ratio': ratio,
            'log2_bound': log2(lb) if lb > 0 else float('-inf'),
        })
    
    return bounds


def optimal_derivative_order(d: int, m: int) -> dict:
    """Find the derivative order k that maximizes the circuit lower bound.
    
    The lower bound C(m-k+d-1, d-1)/d^k peaks at some k* that balances
    shadow shrinkage against channel explosion.
    
    Args:
        d: Number of variables.
        m: Polynomial degree.
    
    Returns:
        Dictionary with optimal k and corresponding bound.
    """
    best_k = 0
    best_bound = 0.0
    
    for k in range(m + 1):
        lb = circuit_lower_bound(d, m, k)
        if lb > best_bound:
            best_bound = lb
            best_k = k
    
    return {
        'optimal_k': best_k,
        'lower_bound': best_bound,
        'shadow_card': comb(m - best_k + d - 1, d - 1),
        'channels': d ** best_k,
    }


# ============================================================
# Jet Bundle Dimension
# ============================================================

def jet_dimension(d: int, k: int) -> int:
    """Compute the k-th jet bundle fiber dimension for R^d → R.
    
    This equals C(d + k - 1, k), the number of distinct k-th order
    partial derivatives in d variables.
    
    Args:
        d: Dimension of the base manifold.
        k: Jet order.
    
    Returns:
        Fiber dimension of J^k(R^d, R).
    
    >>> jet_dimension(3, 2)
    6
    """
    return comb(d + k - 1, k)


def jet_shadow_analysis(d: int, m: int) -> list[dict]:
    """Analyze the relationship between jet dimensions and shadow tower.
    
    For each order k, compares the jet fiber dimension with the
    shadow cardinality and circuit lower bound.
    
    Args:
        d: Number of variables.
        m: Polynomial degree.
    
    Returns:
        List of analysis dictionaries per level.
    """
    results = []
    for k in range(m + 1):
        jd = jet_dimension(d, k)
        sc = comb(m - k + d - 1, d - 1) if k <= m else 0
        lb = circuit_lower_bound(d, m, k)
        
        results.append({
            'k': k,
            'jet_dim': jd,
            'shadow_card': sc,
            'lower_bound': lb,
            'jet_shadow_product': jd * sc,
        })
    
    return results


# ============================================================
# Superlinear Conjecture Testing
# ============================================================

def test_superlinear_conjecture(d: int, m: int, k: int) -> dict:
    """Test the superlinear shadow growth conjecture for given parameters.
    
    Conjecture: C(m-k+d-1, d-1) * d^(k+1) > k * C(m+d-1, d-1) * d^k
    
    Rearranged: C(m-k+d-1, d-1) * d > k * C(m+d-1, d-1)
    
    Args:
        d: Number of variables (≥ 3).
        m: Degree (≥ 2k).
        k: Derivative order (≥ 1).
    
    Returns:
        Dictionary with test results.
    """
    lhs_card = comb(m - k + d - 1, d - 1)
    rhs_card = comb(m + d - 1, d - 1)
    lhs = lhs_card * d
    rhs = k * rhs_card
    
    return {
        'd': d, 'm': m, 'k': k,
        'lhs': lhs,
        'rhs': rhs,
        'holds': lhs > rhs,
        'ratio': lhs / rhs if rhs > 0 else float('inf'),
    }


def sweep_conjecture(d_range: range, m_range: range, k_range: range) -> list[dict]:
    """Sweep parameters to test the superlinear conjecture broadly.
    
    Args:
        d_range: Range of d values.
        m_range: Range of m values.
        k_range: Range of k values.
    
    Returns:
        List of failing test cases (empty if conjecture holds everywhere).
    """
    failures = []
    for d in d_range:
        for m in m_range:
            for k in k_range:
                if k >= 1 and 2 * k <= m and d >= 3:
                    result = test_superlinear_conjecture(d, m, k)
                    if not result['holds']:
                        failures.append(result)
    return failures


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    print("=== Shadow Tower Algorithms ===\n")
    
    # 1. Generate simplex support
    d, m = 3, 6
    S = set(generate_simplex_vectors(d, m))
    print(f"T({d}, {m}): {len(S)} vectors")
    
    # 2. Compute shadow tower
    tower = shadow_tower(S, max_k=m)
    print(f"\nShadow tower cardinalities:")
    for k, level in enumerate(tower):
        expected = comb(m - k + d - 1, d - 1) if k <= m else 0
        print(f"  Sh_{k}: {len(level):6d} (expected: {expected})")
    
    # 3. Circuit lower bounds
    print(f"\nCircuit lower bounds (d={d}, m={m}):")
    bounds = tower_lower_bounds(d, m)
    for b in bounds[:7]:
        print(f"  k={b['k']}: bound={b['lower_bound']:.4f}, "
              f"ratio={b['shadow_ratio']:.4f}")
    
    # 4. Optimal derivative order
    opt = optimal_derivative_order(d, m)
    print(f"\nOptimal k={opt['optimal_k']}, bound={opt['lower_bound']:.4f}")
    
    # 5. Jet-shadow analysis
    print(f"\nJet-Shadow Correspondence (d={d}):")
    analysis = jet_shadow_analysis(d, m)
    for a in analysis[:5]:
        print(f"  k={a['k']}: jet_dim={a['jet_dim']}, "
              f"shadow={a['shadow_card']}, product={a['jet_shadow_product']}")
    
    # 6. Conjecture sweep
    failures = sweep_conjecture(range(3, 8), range(6, 30), range(1, 10))
    print(f"\nSuperlinear conjecture: {'HOLDS' if not failures else 'FAILS'} "
          f"over tested range ({len(failures)} failures)")
