"""
Stochastic Galois Theory: Algorithms for Computing Galois Group Distributions

Type-hinted implementations for analyzing random polynomials over finite fields.
"""

from typing import List, Tuple, Dict, Optional
from collections import Counter
import math


def is_prime(n: int) -> bool:
    """Test primality by trial division."""
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6
    return True


def quad_discriminant(b: int, c: int, p: int) -> int:
    """Compute the discriminant b² - 4c of x² + bx + c over F_p."""
    return (b * b - 4 * c) % p


def count_disc_fiber(d: int, p: int) -> int:
    """Count pairs (b,c) in F_p² with discriminant = d.

    Theorem: For odd prime p, every fiber has cardinality exactly p.
    """
    count = 0
    for b in range(p):
        for c in range(p):
            if quad_discriminant(b, c, p) == d:
                count += 1
    return count


def disc_fiber_distribution(p: int) -> Dict[int, int]:
    """Compute the full fiber distribution of the discriminant map over F_p.

    Returns: {d: count} where count = |{(b,c) : b² - 4c ≡ d (mod p)}|
    """
    dist: Dict[int, int] = {}
    for d in range(p):
        dist[d] = count_disc_fiber(d, p)
    return dist


def is_quadratic_residue(a: int, p: int) -> bool:
    """Test if a is a quadratic residue mod p (Euler's criterion)."""
    if a % p == 0:
        return True  # 0 is a square
    return pow(a, (p - 1) // 2, p) == 1


def quadratic_splitting_classification(p: int) -> Dict[str, int]:
    """Classify all monic quadratics x² + bx + c over F_p.

    Returns counts for three categories:
    - 'zero_disc': discriminant = 0 (double root, non-separable)
    - 'square_disc': disc ≠ 0 and disc is a QR (splits, Gal = {e})
    - 'nonsquare_disc': disc is a non-QR (irreducible, Gal = S₂)
    """
    counts: Dict[str, int] = {'zero_disc': 0, 'square_disc': 0, 'nonsquare_disc': 0}
    for b in range(p):
        for c in range(p):
            d = quad_discriminant(b, c, p)
            if d == 0:
                counts['zero_disc'] += 1
            elif is_quadratic_residue(d, p):
                counts['square_disc'] += 1
            else:
                counts['nonsquare_disc'] += 1
    return counts


def splitting_type(coeffs: List[int], p: int) -> List[int]:
    """Compute the splitting type of a monic polynomial over F_p.

    Args:
        coeffs: Coefficients [a_{n-1}, ..., a_0] for x^n + a_{n-1}x^{n-1} + ... + a_0
        p: Prime

    Returns: Sorted list of degrees of irreducible factors (nonincreasing).
    """
    from functools import reduce

    n = len(coeffs)

    # Build polynomial as list of coefficients [a_0, a_1, ..., a_n]
    poly = [c % p for c in reversed(coeffs)] + [1]  # monic

    def poly_mod(f: List[int], g: List[int]) -> List[int]:
        """Compute f mod g over F_p."""
        f = [x % p for x in f]
        while len(f) >= len(g) and f:
            if f[-1] != 0:
                coeff = f[-1] * pow(g[-1], p - 2, p) % p
                for i in range(len(g)):
                    f[len(f) - len(g) + i] = (f[len(f) - len(g) + i] - coeff * g[i]) % p
            f.pop()
        while f and f[-1] == 0:
            f.pop()
        return f if f else [0]

    def poly_mul_mod(f: List[int], g: List[int], mod: List[int]) -> List[int]:
        """Compute f * g mod 'mod' over F_p."""
        result = [0] * (len(f) + len(g) - 1)
        for i, a in enumerate(f):
            for j, b in enumerate(g):
                result[i + j] = (result[i + j] + a * b) % p
        return poly_mod(result, mod)

    def poly_pow_mod(base: List[int], exp: int, mod: List[int]) -> List[int]:
        """Compute base^exp mod 'mod' over F_p."""
        result = [1]
        base = poly_mod(base, mod)
        while exp > 0:
            if exp % 2 == 1:
                result = poly_mul_mod(result, base, mod)
            base = poly_mul_mod(base, base, mod)
            exp //= 2
        return result

    def poly_gcd(f: List[int], g: List[int]) -> List[int]:
        """Compute gcd(f, g) over F_p."""
        while g != [0] and g:
            f, g = g, poly_mod(f, g)
        if not f:
            return [0]
        # Make monic
        inv = pow(f[-1], p - 2, p)
        return [(c * inv) % p for c in f]

    # Distinct-degree factorization
    degrees: List[int] = []
    h = [0, 1]  # x
    remaining = poly[:]

    for d in range(1, n + 1):
        if len(remaining) <= 1:
            break
        # h = x^(p^d) mod remaining
        h = poly_pow_mod(h, p, remaining)
        # gcd(h - x, remaining)
        h_minus_x = h[:]
        if len(h_minus_x) < 2:
            h_minus_x.extend([0] * (2 - len(h_minus_x)))
        h_minus_x[1] = (h_minus_x[1] - 1) % p
        g = poly_gcd(h_minus_x[:], remaining)
        if len(g) > 1:  # nontrivial gcd
            num_factors = (len(g) - 1) // d
            degrees.extend([d] * num_factors)
            remaining = poly_mod(remaining, g)

    if len(remaining) > 1:
        degrees.append(len(remaining) - 1)

    degrees.sort(reverse=True)
    return degrees if degrees else [n]


def irreducible_count_degree_n(n: int, p: int) -> int:
    """Count monic irreducible polynomials of degree n over F_p.

    Uses the necklace formula: I(n,p) = (1/n) * Σ_{d|n} μ(n/d) * p^d
    """
    def mobius(k: int) -> int:
        if k == 1:
            return 1
        factors = set()
        temp = k
        d = 2
        while d * d <= temp:
            while temp % d == 0:
                factors.add(d)
                temp //= d
            d += 1
        if temp > 1:
            factors.add(temp)
        # Check squarefree
        temp2 = k
        for f in factors:
            if temp2 % (f * f) == 0:
                return 0
        return (-1) ** len(factors)

    total = 0
    for d in range(1, n + 1):
        if n % d == 0:
            total += mobius(n // d) * (p ** d)
    return total // n


def galois_group_distribution(n: int, p: int) -> Dict[str, float]:
    """Compute the distribution of Galois groups for degree-n polynomials over F_p.

    For finite fields, Galois groups are always cyclic. The Galois group
    Gal(f/F_p) = Z/kZ where k = lcm of degrees of irreducible factors.

    Returns: {group_description: probability}
    """
    if n > 5 or p > 23:
        return {"error": "too large for enumeration"}

    total = p ** n
    group_counts: Dict[str, int] = Counter()

    def enum_coeffs(remaining: int, current: List[int]):
        if remaining == 0:
            st = splitting_type(current, p)
            k = math.lcm(*st) if st else 1
            group_counts[f"Z/{k}Z (type {st})"] += 1
            return
        for a in range(p):
            enum_coeffs(remaining - 1, current + [a])

    enum_coeffs(n, [])

    return {k: v / total for k, v in sorted(group_counts.items())}


def verify_disc_uniformity(p: int) -> bool:
    """Verify that all discriminant fibers have cardinality p.

    This is the computational verification of our main theorem.
    """
    dist = disc_fiber_distribution(p)
    return all(v == p for v in dist.values())


def galois_genericity_sequence(max_p: int = 100) -> List[Tuple[int, float]]:
    """Compute P(Gal = S_2) = P(irreducible quadratic) for primes up to max_p.

    For quadratics, Gal = S_2 iff discriminant is a non-square.
    Theoretical prediction: P = (p-1)/(2p) → 1/2.
    """
    results: List[Tuple[int, float]] = []
    for p in range(3, max_p + 1):
        if not is_prime(p):
            continue
        counts = quadratic_splitting_classification(p)
        total = p * p
        prob_s2 = counts['nonsquare_disc'] / total
        results.append((p, prob_s2))
    return results


if __name__ == "__main__":
    # Quick verification
    for p in [3, 5, 7, 11, 13]:
        assert verify_disc_uniformity(p), f"Uniformity failed for p={p}"
        print(f"p={p}: Discriminant uniformity verified ✓")

    print("\nQuadratic splitting classification:")
    for p in [3, 5, 7, 11]:
        cls = quadratic_splitting_classification(p)
        total = p * p
        print(f"  p={p}: zero={cls['zero_disc']}/{total} "
              f"split={cls['square_disc']}/{total} "
              f"irred={cls['nonsquare_disc']}/{total}")

    print("\nIrreducible cubic counts:")
    for p in [2, 3, 5, 7, 11]:
        count = irreducible_count_degree_n(3, p)
        predicted = (p**3 - p) // 3
        print(f"  p={p}: count={count}, formula=(p³-p)/3={predicted}")
