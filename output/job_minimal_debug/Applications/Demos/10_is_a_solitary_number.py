"""
Applications of Divisor Sum Theory

Demonstrates practical applications of the abundancy index framework
and solitary number theory.
"""

from math import gcd, isqrt
from fractions import Fraction
from typing import List, Dict, Tuple


def sigma(n: int) -> int:
    """Sum of positive divisors of n."""
    if n <= 0:
        return 0
    s = 0
    for d in range(1, isqrt(n) + 1):
        if n % d == 0:
            s += d
            if d != n // d:
                s += n // d
    return s


def abundancy(n: int) -> Fraction:
    """Abundancy index σ(n)/n."""
    return Fraction(sigma(n), n)


# ============================================================
# Application 1: Perfect number detection
# ============================================================
def find_perfect_numbers(bound: int) -> List[int]:
    """
    Find perfect numbers up to bound.
    
    A perfect number n satisfies σ(n) = 2n, or equivalently
    abundancy(n) = 2. This is a special case of the abundancy
    equation a·σ(n) = b·n with (a,b) = (1,2).
    """
    return [n for n in range(2, bound + 1) if sigma(n) == 2 * n]


# ============================================================
# Application 2: Multiperfect number detection
# ============================================================
def find_multiperfect(k: int, bound: int) -> List[int]:
    """
    Find k-perfect numbers up to bound.
    
    A k-perfect number satisfies σ(n) = k·n.
    """
    return [n for n in range(2, bound + 1) if sigma(n) == k * n]


# ============================================================
# Application 3: Abundancy spectrum analysis
# ============================================================
def abundancy_spectrum(bound: int, precision: int = 1000) -> Dict[str, int]:
    """
    Analyze the distribution of abundancy indices.
    
    Groups indices into intervals of width 1/precision.
    """
    from collections import Counter
    spectrum = Counter()
    for n in range(1, bound + 1):
        a = float(abundancy(n))
        bucket = round(a * precision) / precision
        spectrum[f"{bucket:.3f}"] += 1
    return dict(sorted(spectrum.items()))


# ============================================================
# Application 4: Divisor sum cryptographic hash
# ============================================================
def abundancy_fingerprint(n: int) -> Tuple[int, int]:
    """
    Compute a number-theoretic fingerprint based on divisor structure.
    
    Returns (numerator, denominator) of reduced abundancy.
    This uniquely characterizes the "divisor density" of n.
    """
    a = abundancy(n)
    return (a.numerator, a.denominator)


# ============================================================
# Application 5: Testing the coprimality criterion
# ============================================================
def solitary_by_coprimality(bound: int) -> List[int]:
    """
    Find numbers provably solitary by the coprimality criterion:
    gcd(n, σ(n)) = 1 implies n is solitary.
    
    Note: This is sufficient but not necessary (10 is solitary
    but fails this criterion).
    """
    return [n for n in range(1, bound + 1) if gcd(n, sigma(n)) == 1]


# ============================================================
# Application 6: Equation uniqueness checker
# ============================================================
def check_equation_uniqueness(a: int, b: int, bound: int) -> dict:
    """
    For the equation a·σ(m) = b·m, check if the solution is unique.
    
    Returns analysis including solutions found and whether
    uniqueness can be concluded.
    """
    solutions = [m for m in range(1, bound + 1) if a * sigma(m) == b * m]
    target = Fraction(b, a)
    
    return {
        'equation': f'{a}·σ(m) = {b}·m',
        'target_abundancy': str(target),
        'solutions_found': solutions,
        'count': len(solutions),
        'unique_up_to_bound': len(solutions) <= 1,
        'bound': bound,
    }


if __name__ == "__main__":
    print("Applications of Divisor Sum Theory")
    print("=" * 50)
    
    # Perfect numbers
    print("\n1. Perfect numbers up to 10000:")
    perfects = find_perfect_numbers(10000)
    for n in perfects:
        print(f"   {n}: σ({n}) = {sigma(n)} = 2×{n}")
    
    # Multiperfect
    print("\n2. Triperfect numbers up to 1000000:")
    triperfects = find_multiperfect(3, 1000000)
    for n in triperfects:
        print(f"   {n}: σ({n}) = {sigma(n)} = 3×{n}")
    
    # Equation uniqueness for small ratios
    print("\n3. Equation uniqueness for σ(m)/m = b/a:")
    test_cases = [(5, 9), (1, 2), (2, 3), (3, 4), (4, 7)]
    for a, b in test_cases:
        result = check_equation_uniqueness(a, b, 10000)
        print(f"   {result['equation']}: solutions = {result['solutions_found'][:5]}"
              f"{'...' if result['count'] > 5 else ''}")
    
    # Coprimality criterion
    print("\n4. Numbers solitary by coprimality (first 20):")
    cop_sol = solitary_by_coprimality(100)
    print(f"   {cop_sol[:20]}...")
    print(f"   Note: 10 is NOT in this list (gcd(10, 18) = 2)")
    print(f"   Yet 10 IS solitary - the criterion is sufficient, not necessary")
    
    # Fingerprints
    print("\n5. Abundancy fingerprints:")
    for n in [6, 10, 12, 28, 496]:
        fp = abundancy_fingerprint(n)
        print(f"   n={n}: fingerprint = {fp[0]}/{fp[1]} = {float(Fraction(*fp)):.4f}")


"""
Demonstration: 10 is a Solitary Number

This script demonstrates the key mathematical concepts behind the proof
that 10 is solitary - the only positive integer with abundancy index 9/5.
"""

from math import gcd
from fractions import Fraction


def sigma(n: int) -> int:
    """Sum of all positive divisors of n."""
    if n <= 0:
        return 0
    return sum(d for d in range(1, n + 1) if n % d == 0)


def abund(n: int) -> Fraction:
    """Abundancy index σ(n)/n as an exact fraction."""
    return Fraction(sigma(n), n)


def is_friendly(m: int, n: int) -> bool:
    """Check if m and n are friendly (same abundancy index)."""
    return abund(m) == abund(n)


def is_solitary_up_to(n: int, bound: int) -> bool:
    """Check if n appears solitary among all m in [1, bound]."""
    target = abund(n)
    for m in range(1, bound + 1):
        if m != n and abund(m) == target:
            return False
    return True


# ============================================================
# Demonstration 1: Basic sigma and abundancy computations
# ============================================================
print("=" * 60)
print("DEMONSTRATION 1: Divisor sums and abundancy indices")
print("=" * 60)

for n in [1, 2, 3, 5, 6, 10, 12, 28]:
    s = sigma(n)
    a = abund(n)
    print(f"  σ({n:3d}) = {s:4d},  abundancy = σ({n})/{n} = {a}")

# ============================================================
# Demonstration 2: The key equation 5σ(m) = 9m
# ============================================================
print("\n" + "=" * 60)
print("DEMONSTRATION 2: Searching for solutions to 5σ(m) = 9m")
print("=" * 60)

solutions = []
for m in range(1, 10001):
    if 5 * sigma(m) == 9 * m:
        solutions.append(m)

print(f"  Solutions in [1, 10000]: {solutions}")
print(f"  σ(10) = {sigma(10)}")
print(f"  5 × σ(10) = {5 * sigma(10)}")
print(f"  9 × 10   = {9 * 10}")
print(f"  Abundancy of 10: {abund(10)} = {float(abund(10)):.4f}")

# ============================================================
# Demonstration 3: Why the coprimality criterion fails for 10
# ============================================================
print("\n" + "=" * 60)
print("DEMONSTRATION 3: The coprimality criterion")
print("=" * 60)

print(f"  gcd(10, σ(10)) = gcd(10, 18) = {gcd(10, 18)}")
print(f"  The coprimality criterion requires gcd(n, σ(n)) = 1.")
print(f"  Since gcd(10, 18) = 2 ≠ 1, the criterion does NOT apply to 10.")
print(f"  Yet 10 IS solitary! This makes the result more interesting.")

# Numbers where coprimality criterion DOES apply
coprime_solitary = []
for n in range(1, 100):
    if gcd(n, sigma(n)) == 1:
        coprime_solitary.append(n)
print(f"\n  Numbers n < 100 with gcd(n, σ(n)) = 1 (automatically solitary):")
print(f"  {coprime_solitary}")

# ============================================================
# Demonstration 4: The proof structure - multiplicativity
# ============================================================
print("\n" + "=" * 60)
print("DEMONSTRATION 4: Multiplicativity of σ")
print("=" * 60)

# σ is multiplicative: σ(ab) = σ(a)σ(b) when gcd(a,b) = 1
pairs = [(2, 5), (3, 7), (4, 9), (2, 15), (6, 35)]
for a, b in pairs:
    g = gcd(a, b)
    prod_sigma = sigma(a) * sigma(b)
    sigma_prod = sigma(a * b)
    status = "✓" if prod_sigma == sigma_prod else "✗"
    print(f"  σ({a})×σ({b}) = {sigma(a)}×{sigma(b)} = {prod_sigma}, "
          f"σ({a*b}) = {sigma_prod}  "
          f"{'(coprime)' if g == 1 else f'(gcd={g})'} {status}")

# ============================================================
# Demonstration 5: The descent argument
# ============================================================
print("\n" + "=" * 60)
print("DEMONSTRATION 5: The descent argument")
print("=" * 60)

print("  If 5σ(m) = 9m and 5|m, write m = 5j.")
print("  If gcd(j, 5) = 1: σ(5j) = σ(5)σ(j) = 6σ(j)")
print("  → 30σ(j) = 45j → 2σ(j) = 3j")
print("  → 2|j, so j = 2k")
print("  If gcd(k, 2) = 1: σ(2k) = 3σ(k) → 6σ(k) = 6k → σ(k) = k → k = 1")
print("  → j = 2, m = 10 ✓")
print()
print("  If gcd(k, 2) > 1: j = 2^c·l (c ≥ 2, l odd)")
print("  → (2^(c+1)-1)σ(l) = 3·2^(c-1)·l")
print("  For c ≥ 2: 2^(c+1)-1 > 3·2^(c-1), so σ(l) < l. But σ(l) ≥ l. ✗")
for c in range(1, 8):
    lhs_coeff = 2 ** (c + 1) - 1
    rhs_coeff = 3 * 2 ** (c - 1)
    print(f"    c = {c}: 2^{c+1}-1 = {lhs_coeff} vs 3·2^{c-1} = {rhs_coeff}  "
          f"{'σ(l)/l < 1 ✗' if lhs_coeff > rhs_coeff else 'σ(l) = l ✓'}")

# ============================================================
# Demonstration 6: Solitary verification
# ============================================================
print("\n" + "=" * 60)
print("DEMONSTRATION 6: Computational verification of solitude")
print("=" * 60)

bound = 5000
print(f"  Checking all m in [1, {bound}] for abundancy 9/5...")
target = Fraction(9, 5)
matches = [m for m in range(1, bound + 1) if abund(m) == target]
print(f"  Numbers with abundancy 9/5: {matches}")
print(f"  10 is solitary up to {bound}: {is_solitary_up_to(10, bound)}")
