"""
Algorithms for Divisor Sum Analysis and Solitary Number Detection

Implements the key algorithms from the research on solitary numbers,
abundancy indices, and divisor-sum equations.
"""

from math import gcd, isqrt
from fractions import Fraction
from typing import List, Tuple, Optional, Set
from collections import defaultdict


def sigma(n: int) -> int:
    """Compute σ(n) = sum of positive divisors of n. O(√n) time."""
    if n <= 0:
        return 0
    s = 0
    for d in range(1, isqrt(n) + 1):
        if n % d == 0:
            s += d
            if d != n // d:
                s += n // d
    return s


def sigma_prime_power(p: int, a: int) -> int:
    """Compute σ(p^a) = 1 + p + p^2 + ... + p^a = (p^(a+1) - 1) / (p - 1)."""
    return (p ** (a + 1) - 1) // (p - 1)


def factorize(n: int) -> dict:
    """Return prime factorization as {prime: exponent} dict."""
    factors = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1
    if n > 1:
        factors[n] = factors.get(n, 0) + 1
    return factors


def sigma_from_factorization(factors: dict) -> int:
    """Compute σ(n) from prime factorization using multiplicativity."""
    result = 1
    for p, a in factors.items():
        result *= sigma_prime_power(p, a)
    return result


def abundancy(n: int) -> Fraction:
    """Compute abundancy index σ(n)/n as exact fraction."""
    return Fraction(sigma(n), n)


def find_abundancy_class(target: Fraction, bound: int) -> List[int]:
    """Find all n ≤ bound with abundancy equal to target."""
    return [n for n in range(1, bound + 1) if abundancy(n) == target]


def is_coprime_solitary(n: int) -> bool:
    """Check if n satisfies the coprimality criterion gcd(n, σ(n)) = 1."""
    return gcd(n, sigma(n)) == 1


def check_solitary_equation(a: int, b: int, bound: int) -> List[int]:
    """
    Find all m ≤ bound satisfying a·σ(m) = b·m.
    
    This is the integer-cleared form of σ(m)/m = b/a.
    
    Args:
        a: Coefficient of σ(m)
        b: Coefficient of m
        bound: Search up to this value
    
    Returns:
        List of solutions
    """
    solutions = []
    for m in range(1, bound + 1):
        if a * sigma(m) == b * m:
            solutions.append(m)
    return solutions


def descent_analysis(a: int, b: int, max_depth: int = 10) -> List[dict]:
    """
    Analyze the descent structure of the equation a·σ(n) = b·n.
    
    At each step, if gcd(a, b) = g, reduce to (a/g)·σ(n) = (b/g)·n.
    Then a/g | n, write n = (a/g)·k, get σ(a/g)·σ(k) = (b/g)·k
    (if coprime).
    
    Returns list of descent steps with coefficients and analysis.
    """
    steps = []
    current_a, current_b = a, b
    
    for depth in range(max_depth):
        g = gcd(current_a, current_b)
        reduced_a = current_a // g
        reduced_b = current_b // g
        
        step = {
            'depth': depth,
            'equation': f"{current_a}·σ(n) = {current_b}·n",
            'reduced': f"{reduced_a}·σ(n) = {reduced_b}·n",
            'divisor': reduced_a,
            'sigma_divisor': sigma(reduced_a),
            'ratio': f"σ(n)/n = {reduced_b}/{reduced_a}",
            'ratio_value': reduced_b / reduced_a if reduced_a > 0 else float('inf'),
        }
        
        if reduced_b < reduced_a:
            step['conclusion'] = f"CONTRADICTION: σ(n)/n = {reduced_b}/{reduced_a} < 1, but σ(n) ≥ n"
            steps.append(step)
            break
        
        # Next step: σ(reduced_a) becomes new coefficient
        steps.append(step)
        current_a = sigma(reduced_a)
        current_b = reduced_b
    
    return steps


def classify_abundancy_classes(bound: int) -> dict:
    """
    Classify all abundancy classes up to bound.
    
    Returns dict mapping abundancy values to lists of integers.
    """
    classes = defaultdict(list)
    for n in range(1, bound + 1):
        a = abundancy(n)
        classes[a].append(n)
    return dict(classes)


def find_friendly_pairs(bound: int) -> List[Tuple[int, int]]:
    """Find all friendly pairs (m, n) with m < n ≤ bound."""
    classes = classify_abundancy_classes(bound)
    pairs = []
    for members in classes.values():
        if len(members) >= 2:
            for i in range(len(members)):
                for j in range(i + 1, len(members)):
                    pairs.append((members[i], members[j]))
    return pairs


def find_solitary_candidates(bound: int) -> Set[int]:
    """Find numbers that appear solitary up to bound."""
    classes = classify_abundancy_classes(bound)
    return {members[0] for members in classes.values() if len(members) == 1}


# ============================================================
# Example usage
# ============================================================
if __name__ == "__main__":
    print("Abundancy Equation Solver")
    print("=" * 50)
    
    # The equation 5σ(m) = 9m (abundancy = 9/5)
    print("\nSolutions to 5σ(m) = 9m up to 10000:")
    sols = check_solitary_equation(5, 9, 10000)
    print(f"  {sols}")
    
    # Descent analysis
    print("\nDescent analysis for the equation 5σ(m) = 9m:")
    print("  Starting from 31σ(n) = 45n (after extracting factor 5):")
    steps = descent_analysis(31, 45)
    for step in steps:
        print(f"  Step {step['depth']}: {step['equation']}")
        print(f"    Divisor to extract: {step['divisor']}")
        print(f"    σ(divisor) = {step['sigma_divisor']}")
        if 'conclusion' in step:
            print(f"    >>> {step['conclusion']}")
    
    # Friendly pairs
    print(f"\nFriendly pairs up to 1000:")
    pairs = find_friendly_pairs(1000)
    for m, n in pairs[:10]:
        print(f"  ({m}, {n}): abundancy = {abundancy(m)}")
    if len(pairs) > 10:
        print(f"  ... and {len(pairs) - 10} more pairs")
    
    # Coprime-solitary numbers
    print(f"\nNumbers n < 50 where gcd(n, σ(n)) = 1 (coprime-solitary):")
    coprime = [n for n in range(1, 50) if is_coprime_solitary(n)]
    print(f"  {coprime}")
