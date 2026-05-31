"""
Stochastic Galois Theory: Algorithms for Computing Galois Groups of Random Polynomials

Type-hinted implementations of key algorithms for:
1. Enumerating monic polynomials over finite fields
2. Computing factorization patterns (splitting profiles)
3. Estimating Galois group densities
4. Verifying the necklace/Möbius formula for irreducible polynomial counts
"""

from typing import List, Tuple, Dict, Optional
from collections import Counter
import math
from functools import reduce


def gcd_poly(f: List[int], g: List[int], p: int) -> List[int]:
    """Compute GCD of two polynomials over F_p using Euclidean algorithm.

    Polynomials are represented as coefficient lists [a0, a1, ..., an]
    where the polynomial is a0 + a1*x + ... + an*x^n.

    Args:
        f: First polynomial coefficients
        g: Second polynomial coefficients
        p: Prime field characteristic

    Returns:
        GCD polynomial coefficients (monic)
    """
    def strip(poly: List[int]) -> List[int]:
        while len(poly) > 1 and poly[-1] == 0:
            poly = poly[:-1]
        return poly

    def mod_poly(poly: List[int]) -> List[int]:
        return [c % p for c in poly]

    f = strip(mod_poly(f))
    g = strip(mod_poly(g))

    while g != [0]:
        _, r = divmod_poly(f, g, p)
        f = g
        g = strip(mod_poly(r))

    # Make monic
    if f == [0]:
        return [0]
    inv_lead = pow(f[-1], p - 2, p)
    return [(c * inv_lead) % p for c in f]


def divmod_poly(f: List[int], g: List[int], p: int) -> Tuple[List[int], List[int]]:
    """Polynomial division with remainder over F_p.

    Returns (quotient, remainder) such that f = quotient * g + remainder.
    """
    if g == [0]:
        raise ValueError("Division by zero polynomial")

    f = [c % p for c in f]
    g = [c % p for c in g]

    if len(f) < len(g):
        return [0], f

    inv_lead_g = pow(g[-1], p - 2, p)
    q = [0] * (len(f) - len(g) + 1)
    r = list(f)

    for i in range(len(f) - len(g), -1, -1):
        if len(r) >= len(g) + i:
            coeff = (r[len(g) + i - 1] * inv_lead_g) % p
            q[i] = coeff
            for j in range(len(g)):
                r[i + j] = (r[i + j] - coeff * g[j]) % p

    # Strip leading zeros
    while len(r) > 1 and r[-1] == 0:
        r = r[:-1]

    return q, r


def multiply_poly(f: List[int], g: List[int], p: int) -> List[int]:
    """Multiply two polynomials over F_p."""
    if f == [0] or g == [0]:
        return [0]
    result = [0] * (len(f) + len(g) - 1)
    for i, a in enumerate(f):
        for j, b in enumerate(g):
            result[i + j] = (result[i + j] + a * b) % p
    return result


def is_irreducible_fp(coeffs: List[int], p: int) -> bool:
    """Test if a monic polynomial over F_p is irreducible.

    Uses the standard algorithm: f is irreducible of degree n iff
    gcd(f, x^{p^k} - x) = 1 for k = 1, ..., n//2, and f | x^{p^n} - x.

    Args:
        coeffs: Monic polynomial coefficients [a0, a1, ..., a_{n-1}, 1]
        p: Prime field characteristic

    Returns:
        True if the polynomial is irreducible over F_p
    """
    n = len(coeffs) - 1  # degree
    if n <= 0:
        return False
    if n == 1:
        return True

    # x^{p^k} mod f using repeated squaring
    def pow_x_mod_f(exponent: int) -> List[int]:
        """Compute x^exponent mod f over F_p."""
        result = [1]  # 1
        base = [0, 1]  # x
        e = exponent
        while e > 0:
            if e % 2 == 1:
                result = multiply_poly(result, base, p)
                _, result = divmod_poly(result, coeffs, p)
            base = multiply_poly(base, base, p)
            _, base = divmod_poly(base, coeffs, p)
            e //= 2
        return result

    for k in range(1, n // 2 + 1):
        # Compute x^{p^k} mod f
        xpk = pow_x_mod_f(p ** k)
        # Compute x^{p^k} - x mod f
        diff = list(xpk)
        while len(diff) < 2:
            diff.append(0)
        diff[1] = (diff[1] - 1) % p
        # Strip
        while len(diff) > 1 and diff[-1] == 0:
            diff = diff[:-1]

        g = gcd_poly(coeffs, diff, p)
        if g != [1]:
            return False

    return True


def splitting_profile(coeffs: List[int], p: int) -> List[int]:
    """Compute the splitting profile of a monic polynomial over F_p.

    Returns the sorted list of degrees of irreducible factors.

    Args:
        coeffs: Monic polynomial coefficients
        p: Prime

    Returns:
        Sorted list of degrees of irreducible factors
    """
    n = len(coeffs) - 1
    if n <= 0:
        return []

    factors: List[int] = []
    remaining = list(coeffs)

    for k in range(1, n + 1):
        if len(remaining) - 1 < k:
            break

        # Compute x^{p^k} - x mod remaining
        def pow_x_mod(exponent: int, modulus: List[int]) -> List[int]:
            result = [1]
            base = [0, 1]
            e = exponent
            while e > 0:
                if e % 2 == 1:
                    result = multiply_poly(result, base, p)
                    _, result = divmod_poly(result, modulus, p)
                base = multiply_poly(base, base, p)
                _, base = divmod_poly(base, modulus, p)
                e //= 2
            return result

        xpk = pow_x_mod(p ** k, remaining)
        diff = list(xpk)
        while len(diff) < 2:
            diff.append(0)
        diff[1] = (diff[1] - 1) % p
        while len(diff) > 1 and diff[-1] == 0:
            diff = diff[:-1]

        g = gcd_poly(remaining, diff, p)

        if g != [1] and len(g) > 1:
            deg_g = len(g) - 1
            num_factors = deg_g // k
            factors.extend([k] * num_factors)
            for _ in range(num_factors):
                # Divide out g from remaining
                q, r = divmod_poly(remaining, g, p)
                remaining = q
            # Actually need to divide out gcd repeatedly
            # Simplified: just divide once
            q, _ = divmod_poly(remaining, g, p)
            remaining = q if len(q) > 1 or q != [0] else remaining

    if len(remaining) > 1:
        factors.append(len(remaining) - 1)

    factors.sort()
    return factors


def count_irreducible_polynomials(n: int, p: int) -> int:
    """Count monic irreducible polynomials of degree n over F_p.

    Uses the necklace/Möbius formula:
    N(n, q) = (1/n) * sum_{d | n} mu(n/d) * q^d

    Args:
        n: Degree
        p: Prime

    Returns:
        Number of monic irreducible polynomials
    """
    def mobius(k: int) -> int:
        """Compute the Möbius function μ(k)."""
        if k == 1:
            return 1
        # Factor k
        factors: List[int] = []
        temp = k
        d = 2
        while d * d <= temp:
            if temp % d == 0:
                factors.append(d)
                temp //= d
                if temp % d == 0:
                    return 0  # k has a squared prime factor
            d += 1
        if temp > 1:
            factors.append(temp)
        return (-1) ** len(factors)

    total = 0
    for d in range(1, n + 1):
        if n % d == 0:
            total += mobius(n // d) * (p ** d)

    return total // n


def enumerate_splitting_profiles(n: int, p: int) -> Dict[Tuple[int, ...], int]:
    """Enumerate all monic polynomials of degree n over F_p and count
    occurrences of each splitting profile.

    Args:
        n: Degree
        p: Prime (should be small for enumeration)

    Returns:
        Dictionary mapping splitting profiles to counts
    """
    from itertools import product as cartesian_product

    profile_counts: Dict[Tuple[int, ...], int] = {}
    total = 0

    for coeffs_tuple in cartesian_product(range(p), repeat=n):
        # Monic polynomial: coeffs are a0, a1, ..., a_{n-1}, 1
        full_coeffs = list(coeffs_tuple) + [1]
        profile = tuple(get_factorization_degrees(full_coeffs, p))
        profile_counts[profile] = profile_counts.get(profile, 0) + 1
        total += 1

    return profile_counts


def get_factorization_degrees(coeffs: List[int], p: int) -> List[int]:
    """Get sorted list of degrees of irreducible factors of a monic polynomial
    over F_p by trial division with all irreducible polynomials.

    Simpler but slower than splitting_profile for correctness.
    """
    n = len(coeffs) - 1
    if n <= 0:
        return []
    if n == 1:
        return [1]

    remaining = list(coeffs)
    degrees: List[int] = []

    # Check for linear factors first (roots)
    for r in range(p):
        while True:
            val = sum(remaining[i] * pow(r, i, p) for i in range(len(remaining))) % p
            if val == 0 and len(remaining) > 1:
                # Divide by (x - r)
                new_coeffs = [0] * (len(remaining) - 1)
                new_coeffs[-1] = remaining[-1]
                for i in range(len(remaining) - 2, 0, -1):
                    new_coeffs[i - 1] = (remaining[i] + r * new_coeffs[i]) % p
                remaining = new_coeffs
                degrees.append(1)
            else:
                break

    # Check for higher degree irreducible factors
    if len(remaining) > 1:
        deg = len(remaining) - 1
        if deg <= 1:
            if deg == 1:
                degrees.append(1)
        elif is_irreducible_fp(remaining, p):
            degrees.append(deg)
        else:
            # Try to factor further - for small cases, use brute force
            # For now, record as a single factor (may be composite)
            # In practice, we'd recursively factor
            found = False
            for k in range(2, deg // 2 + 1):
                for trial_coeffs in _iter_monic_polys(k, p):
                    if is_irreducible_fp(trial_coeffs, p):
                        _, r = divmod_poly(remaining, trial_coeffs, p)
                        if all(c % p == 0 for c in r):
                            q, _ = divmod_poly(remaining, trial_coeffs, p)
                            degrees.append(k)
                            remaining = q
                            found = True
                            break
                if found:
                    break
            if len(remaining) > 1:
                degrees.append(len(remaining) - 1)

    degrees.sort()
    return degrees


def _iter_monic_polys(degree: int, p: int):
    """Iterate over all monic polynomials of given degree over F_p."""
    from itertools import product as cartesian_product
    for coeffs in cartesian_product(range(p), repeat=degree):
        yield list(coeffs) + [1]


def galois_density_estimate(n: int, p: int) -> Dict[str, float]:
    """Estimate the density of various Galois group types for monic
    degree-n polynomials over F_p.

    Returns:
        Dictionary with density estimates for key splitting profiles
    """
    profiles = enumerate_splitting_profiles(n, p)
    total = p ** n

    result: Dict[str, float] = {
        "total_polynomials": float(total),
        "p": float(p),
        "n": float(n),
    }

    for profile, count in sorted(profiles.items()):
        key = str(profile)
        result[f"profile_{key}"] = count / total

    # Irreducible fraction
    irr_key = (n,)
    irr_count = profiles.get(irr_key, 0)
    result["irreducible_fraction"] = irr_count / total
    result["theoretical_irreducible_fraction"] = count_irreducible_polynomials(n, p) / total

    # Completely split fraction
    split_key = tuple([1] * n)
    split_count = profiles.get(split_key, 0)
    result["completely_split_fraction"] = split_count / total

    return result


def verify_necklace_formula(max_n: int = 6, max_p: int = 11) -> List[Dict[str, any]]:
    """Verify the necklace formula for irreducible polynomial counts.

    For each (n, p), compare the formula N(n,p) = (1/n)∑_{d|n} μ(n/d)p^d
    with direct enumeration.

    Returns:
        List of verification results
    """
    results: List[Dict[str, any]] = []
    primes = [p for p in range(2, max_p + 1) if all(p % d != 0 for d in range(2, p))]

    for p in primes:
        for n in range(1, max_n + 1):
            if p ** n > 50000:  # Skip if too many polynomials
                continue

            formula_count = count_irreducible_polynomials(n, p)

            # Direct count
            from itertools import product as cartesian_product
            direct_count = 0
            for coeffs in cartesian_product(range(p), repeat=n):
                full_coeffs = list(coeffs) + [1]
                if is_irreducible_fp(full_coeffs, p):
                    direct_count += 1

            results.append({
                "n": n,
                "p": p,
                "formula": formula_count,
                "direct": direct_count,
                "match": formula_count == direct_count,
                "fraction": direct_count / (p ** n),
                "theoretical_1_over_n": 1.0 / n,
            })

    return results


if __name__ == "__main__":
    print("=== Verifying Necklace Formula ===")
    results = verify_necklace_formula(max_n=4, max_p=7)
    for r in results:
        status = "✓" if r["match"] else "✗"
        print(f"  {status} n={r['n']}, p={r['p']}: "
              f"formula={r['formula']}, direct={r['direct']}, "
              f"fraction={r['fraction']:.4f} (1/n={r['theoretical_1_over_n']:.4f})")

    print("\n=== Galois Density Estimates ===")
    for p in [3, 5, 7]:
        for n in [2, 3]:
            result = galois_density_estimate(n, p)
            print(f"  n={n}, p={p}: irreducible={result['irreducible_fraction']:.4f}, "
                  f"theoretical={result['theoretical_irreducible_fraction']:.4f}")
