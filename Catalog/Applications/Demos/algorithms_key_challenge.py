#!/usr/bin/env python3
"""
Algorithms for Generalized Reed–Muller Code Analysis

Implements:
1. Minimum distance computation
2. Extremal polynomial construction
3. Codeword weight enumeration
4. Low-degree test soundness computation
"""

from itertools import product as cart_product
from collections import defaultdict


def rm_min_distance(q: int, n: int, d: int) -> int:
    """Compute the minimum distance of the generalized Reed-Muller code RM_q(n,d).
    
    For d = a*(q-1) + b with 0 ≤ b < q-1 and a < n:
        min_distance = (q - b) * q^(n - 1 - a)
    
    Args:
        q: Field size (prime power, q > 1)
        n: Number of variables (n ≥ 1)
        d: Degree bound (0 ≤ d < n*(q-1))
    
    Returns:
        The minimum Hamming distance of RM_q(n,d)
    
    Time complexity: O(1)
    Space complexity: O(1)
    
    >>> rm_min_distance(3, 3, 4)
    3
    >>> rm_min_distance(5, 2, 2)
    15
    """
    if q <= 1:
        raise ValueError("q must be > 1")
    if n < 1:
        raise ValueError("n must be >= 1")
    a, b = divmod(d, q - 1)
    if a >= n:
        raise ValueError(f"d={d} too large: a={a} >= n={n}")
    return (q - b) * (q ** (n - 1 - a))


def rm_dimension(q: int, n: int, d: int) -> int:
    """Compute the dimension of the Reed-Muller code RM_q(n,d).
    
    This is the number of monomials x_1^{e_1}...x_n^{e_n} with
    0 ≤ e_i < q and e_1 + ... + e_n ≤ d.
    
    Args:
        q, n, d: Code parameters
    
    Returns:
        Dimension of RM_q(n,d)
    
    >>> rm_dimension(2, 3, 1)
    4
    """
    count = 0
    for exps in cart_product(range(q), repeat=n):
        if sum(exps) <= d:
            count += 1
    return count


def construct_extremal_codeword(q: int, n: int, d: int, alpha: int = 0) -> dict:
    """Construct the extremal polynomial achieving minimum distance.
    
    The extremal polynomial is:
        f(x) = ∏_{i<a} ∏_{c≠α} (x_i - c) · ∏_{j<b} (x_a - β_j)
    
    where β_j are the first b elements of GF(q) different from {}.
    
    Args:
        q: Prime field size
        n: Number of variables
        d: Degree bound
        alpha: The "fixed" field element (default 0)
    
    Returns:
        Dictionary mapping monomial exponent tuples to coefficients mod q
    
    >>> poly = construct_extremal_codeword(3, 2, 2)
    >>> compute_weight(poly, 3, 2)
    3
    """
    a, b = divmod(d, q - 1)
    if a >= n:
        raise ValueError(f"a={a} >= n={n}")
    
    poly = {tuple([0] * n): 1}
    
    def mul_linear(poly, var, root, q):
        result = {}
        for monom, coeff in poly.items():
            m = list(monom)
            m[var] += 1
            m = tuple(m)
            result[m] = (result.get(m, 0) + coeff) % q
            result[monom] = (result.get(monom, 0) - coeff * root) % q
        return {k: v for k, v in result.items() if v != 0}
    
    # Full coordinate factors
    for i in range(a):
        for c in range(q):
            if c != alpha:
                poly = mul_linear(poly, i, c, q)
    
    # Partial coordinate factor
    for j in range(b):
        poly = mul_linear(poly, a, j, q)
    
    return poly


def compute_weight(poly: dict, q: int, n: int) -> int:
    """Compute the Hamming weight of a polynomial's evaluation vector.
    
    Args:
        poly: Dictionary mapping monomial exponent tuples to coefficients
        q: Prime field size
        n: Number of variables
    
    Returns:
        Number of points in GF(q)^n where the polynomial evaluates to nonzero
    """
    weight = 0
    for pt in cart_product(range(q), repeat=n):
        val = 0
        for monom, coeff in poly.items():
            term = coeff
            for i in range(n):
                term = (term * pow(pt[i], monom[i], q)) % q
            val = (val + term) % q
        if val != 0:
            weight += 1
    return weight


def compute_zero_count(poly: dict, q: int, n: int) -> int:
    """Compute the number of zeros of a polynomial over GF(q)^n."""
    return q**n - compute_weight(poly, q, n)


def low_degree_test_soundness(q: int, n: int, d: int) -> float:
    """Compute the exact soundness of the low-degree test.
    
    A nonzero polynomial of degree ≤ d, evaluated at a random point of GF(q)^n,
    is zero with probability at most:
        1 - (q-b) * q^(n-1-a) / q^n
    
    This is the exact worst-case false acceptance probability.
    
    Args:
        q: Field size
        n: Number of variables
        d: Degree bound
    
    Returns:
        Maximum probability of zero evaluation
    """
    min_wt = rm_min_distance(q, n, d)
    total = q ** n
    return 1 - min_wt / total


def weight_distribution_sample(q: int, n: int, d: int, num_samples: int = 100) -> list:
    """Sample random polynomials of degree ≤ d and compute their weights.
    
    Args:
        q: Prime field size
        n: Number of variables
        d: Degree bound
        num_samples: Number of random polynomials to sample
    
    Returns:
        List of (polynomial_description, weight) tuples
    """
    import random
    
    monomials = []
    for exps in cart_product(range(q), repeat=n):
        if sum(exps) <= d:
            monomials.append(exps)
    
    results = []
    for _ in range(num_samples):
        poly = {}
        for monom in monomials:
            coeff = random.randint(0, q - 1)
            if coeff != 0:
                poly[monom] = coeff
        
        if not poly:
            continue
        
        weight = compute_weight(poly, q, n)
        if weight > 0:
            results.append(weight)
    
    return sorted(results)


if __name__ == "__main__":
    # Example usage
    print("Reed-Muller Code Parameters")
    print("=" * 50)
    
    for q, n, d in [(3, 3, 4), (5, 2, 2), (7, 3, 10)]:
        a, b = divmod(d, q - 1)
        if a >= n:
            continue
        print(f"\nRM_{q}({n}, {d}):")
        print(f"  Length:           {q**n}")
        print(f"  Dimension:        {rm_dimension(q, n, d)}")
        print(f"  Min distance:     {rm_min_distance(q, n, d)}")
        print(f"  Rate:             {rm_dimension(q, n, d) / q**n:.4f}")
        print(f"  LDT soundness:    {low_degree_test_soundness(q, n, d):.6f}")
