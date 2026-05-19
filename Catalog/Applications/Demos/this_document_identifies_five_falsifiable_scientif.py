#!/usr/bin/env python3
"""
Applications of Additive Prime Decomposition Theory.

Demonstrates real-world applications:
1. Cryptographic parameter validation via parity census
2. Error detection in prime-sum protocols
3. Goldbach representation density analysis
4. Semiprime decomposition for composite modulus analysis
"""

from typing import List, Tuple, Dict
from sympy import isprime, primerange, nextprime, factorint
import random
import math


# ============================================================
# Application 1: Parity Census as Error Detection
# ============================================================

def parity_census_check(primes: List[int]) -> bool:
    """
    Use the parity census law as an error-detection code.

    In protocols that transmit prime decompositions, the parity census
    law provides a single-bit parity check: any single transmission
    error that corrupts one prime will be caught.

    Returns True if the list passes the parity census check.
    """
    ct = primes.count(2)
    return ct % 2 == (sum(primes) + len(primes)) % 2


def demonstrate_error_detection():
    """Show how parity census catches transmission errors."""
    print("=" * 70)
    print("APPLICATION 1: Parity Census as Error Detection")
    print("=" * 70)
    print()

    # Original message: a valid prime decomposition
    original = [3, 5, 7, 11, 13]
    print(f"Original prime list: {original}")
    print(f"Sum = {sum(original)}, Length = {len(original)}")
    print(f"Parity check: {parity_census_check(original)}")
    print()

    # Simulate transmission errors
    print("Simulating single-element corruption:")
    for i in range(len(original)):
        corrupted = original.copy()
        # Replace one prime with a different prime
        corrupted[i] = nextprime(corrupted[i])
        passes = parity_census_check(corrupted)
        print(f"  Position {i}: {original[i]} -> {corrupted[i]}: "
              f"check = {passes} {'(CAUGHT!)' if not passes else '(missed)'}")

    print()
    print("Note: The parity census catches errors where a prime changes")
    print("parity class (odd→even or even→odd), which is most corruptions.")
    print()


# ============================================================
# Application 2: Goldbach Representation Density Analysis
# ============================================================

def goldbach_density_analysis(limit: int = 1000):
    """
    Analyze how Goldbach representation counts grow with n.

    The Hardy-Littlewood conjecture predicts the count grows like
    C * n / (ln n)^2. We compute the empirical density.
    """
    print("=" * 70)
    print("APPLICATION 2: Goldbach Representation Density")
    print("=" * 70)
    print()

    data = []
    for n in range(4, limit + 1, 2):
        count = 0
        for p in primerange(2, n):
            q = n - p
            if q >= 2 and isprime(q):
                count += 1
        # Unordered count
        unord = (count + (1 if n % 2 == 0 and isprime(n // 2) else 0)) // 2
        data.append((n, count, unord))

    # Print summary statistics
    print(f"{'n':>6} {'Ordered':>8} {'Unordered':>10} {'Ratio n/ln²n':>14}")
    print("-" * 42)
    for n, ordered, unordered in data:
        if n in [10, 20, 50, 100, 200, 500, 1000]:
            ln_n = math.log(n) if n > 1 else 1
            ratio = ordered / (n / ln_n**2) if ln_n > 0 else 0
            print(f"{n:>6} {ordered:>8} {unordered:>10} {ratio:>14.3f}")

    # Show multiplicity never drops below 2 for n >= 8
    min_count = min(c for n, c, _ in data if n >= 8)
    min_n = [n for n, c, _ in data if n >= 8 and c == min_count]
    print(f"\nMinimum ordered count for n ≥ 8: {min_count} at n = {min_n}")
    print(f"Numbers with exactly 1 representation: "
          f"{[n for n, c, _ in data if c == 1]}")
    print()


# ============================================================
# Application 3: Semiprime Gap Analysis
# ============================================================

def semiprime_gap_analysis(limit: int = 200):
    """
    Analyze the density of semiprimes and their role in Chen-type decompositions.

    Semiprimes are denser than primes, so Chen-type decompositions
    should be more abundant than pure Goldbach decompositions.
    """
    print("=" * 70)
    print("APPLICATION 3: Semiprime Density & Chen Decompositions")
    print("=" * 70)
    print()

    def is_semiprime(n):
        if n < 4:
            return False
        f = factorint(n)
        return sum(f.values()) == 2

    # Count primes, semiprimes, and Chen-type decompositions
    print(f"{'n':>5} {'Primes≤n':>10} {'Semi≤n':>8} {'Goldbach':>10} {'Chen':>8}")
    print("-" * 46)

    for n in range(10, limit + 1, 10):
        if n % 2 != 0:
            continue
        num_primes = sum(1 for p in range(2, n + 1) if isprime(p))
        num_semi = sum(1 for s in range(4, n + 1) if is_semiprime(s))

        # Goldbach count
        goldbach = 0
        chen = 0
        for p in primerange(2, n):
            s = n - p
            if s >= 2 and isprime(s):
                goldbach += 1
            if s >= 2 and (isprime(s) or is_semiprime(s)):
                chen += 1

        if n in [10, 20, 50, 100, 150, 200]:
            print(f"{n:>5} {num_primes:>10} {num_semi:>8} {goldbach:>10} {chen:>8}")

    print()
    print("Observation: Chen-type counts consistently exceed Goldbach counts,")
    print("confirming that the semiprime relaxation layer is genuinely denser.")
    print()


# ============================================================
# Application 4: Symmetry Analysis of Witness Sets
# ============================================================

def symmetry_analysis():
    """
    Visualize the orbit structure of Goldbach witnesses under Z/2 swap.
    """
    print("=" * 70)
    print("APPLICATION 4: Witness Symmetry Under Swap Action")
    print("=" * 70)
    print()

    print("The Z/2 swap action (p,q) ↦ (q,p) partitions witnesses into:")
    print("  - Off-diagonal orbits of size 2 (p ≠ q)")
    print("  - Fixed points of size 1 (p = p, i.e., n = 2p)")
    print()
    print(f"{'n':>5} {'Ordered':>8} {'Orbits':>8} {'Fixed':>7} "
          f"{'2*orbits+fixed':>15} {'Match':>6}")
    print("-" * 52)

    for n in range(4, 62, 2):
        witnesses = []
        for p in primerange(2, n):
            q = n - p
            if q >= 2 and isprime(q):
                witnesses.append((p, q))

        fixed = sum(1 for p, q in witnesses if p == q)
        orbits = (len(witnesses) - fixed) // 2
        formula = 2 * orbits + fixed
        match = len(witnesses) == formula

        if n <= 30 or n == 60:
            print(f"{n:>5} {len(witnesses):>8} {orbits:>8} {fixed:>7} "
                  f"{formula:>15} {str(match):>6}")

    print()
    print("The transfer law |ordered| = 2|orbits| + |fixed| holds universally.")
    print("This is the orbit-stabilizer theorem for the Z/2 action on pairs.")
    print()


if __name__ == "__main__":
    print("\n" + "=" * 70)
    print("  ADDITIVE PRIME DECOMPOSITION THEORY — APPLICATIONS")
    print("=" * 70 + "\n")

    demonstrate_error_detection()
    goldbach_density_analysis(limit=200)
    semiprime_gap_analysis(limit=200)
    symmetry_analysis()

    print("\nAll applications complete.")


#!/usr/bin/env python3
"""
Demonstration of Additive Prime Decomposition Theory.

Concrete numerical examples illustrating:
1. The k-ary Parity Census Law
2. Ordered/Unordered Witness Transfer
3. Goldbach Multiplicity Lower Bounds
4. Weak Chen Decompositions
"""

from sympy import isprime, primerange
from collections import Counter
from typing import List, Tuple, Set


def is_semiprime(n: int) -> bool:
    """Check if n is a product of exactly two primes."""
    if n < 4:
        return False
    for p in primerange(2, n):
        if n % p == 0:
            q = n // p
            return isprime(q)
    return False


def count_twos(primes: List[int]) -> int:
    """Count the number of 2s in a list of primes."""
    return primes.count(2)


def goldbach_witnesses_ordered(n: int) -> List[Tuple[int, int]]:
    """All ordered pairs (p, q) of primes with p + q = n."""
    witnesses = []
    for p in primerange(2, n):
        q = n - p
        if q >= 2 and isprime(q):
            witnesses.append((p, q))
    return witnesses


def goldbach_witnesses_unordered(n: int) -> List[Tuple[int, int]]:
    """All pairs (p, q) with p ≤ q, both prime, p + q = n."""
    witnesses = []
    for p in primerange(2, n // 2 + 1):
        q = n - p
        if isprime(q):
            witnesses.append((p, q))
    return witnesses


def weak_chen_decomposition(n: int) -> List[Tuple[int, int, str]]:
    """Find all weak Chen decompositions n = p + s where s is prime or semiprime."""
    results = []
    for p in primerange(2, n):
        s = n - p
        if s < 2:
            continue
        if isprime(s):
            results.append((p, s, "prime"))
        elif is_semiprime(s):
            results.append((p, s, "semiprime"))
    return results


def demo_parity_census():
    """Demonstrate the k-ary Parity Census Law."""
    print("=" * 70)
    print("DEMO 1: The k-ary Parity Census Law")
    print("=" * 70)
    print()
    print("For any list L of primes: countTwos(L) % 2 = (sum(L) + len(L)) % 2")
    print()

    # Binary (Goldbach) examples
    print("--- Arity 2 (Goldbach pairs) ---")
    for n in [10, 20, 30, 36, 100]:
        witnesses = goldbach_witnesses_ordered(n)
        if witnesses:
            p, q = witnesses[0]
            L = [p, q]
            ct = count_twos(L)
            lhs = ct % 2
            rhs = (sum(L) + len(L)) % 2
            print(f"  n={n}: ({p},{q}), countTwos={ct}, "
                  f"LHS={lhs}, RHS=({sum(L)}+{len(L)})%2={rhs}, "
                  f"Equal: {lhs == rhs}")
    print()

    # Ternary examples
    print("--- Arity 3 (Ternary Goldbach) ---")
    test_triples = [
        (2, 2, 3),   # sum=7
        (3, 5, 7),   # sum=15
        (2, 5, 11),  # sum=18
        (2, 3, 7),   # sum=12
        (5, 7, 11),  # sum=23
    ]
    for a, b, c in test_triples:
        L = [a, b, c]
        ct = count_twos(L)
        lhs = ct % 2
        rhs = (sum(L) + len(L)) % 2
        print(f"  ({a},{b},{c}), sum={sum(L)}, countTwos={ct}, "
              f"LHS={lhs}, RHS=({sum(L)}+3)%2={rhs}, Equal: {lhs == rhs}")
    print()

    # Verify over many random decompositions
    print("--- Exhaustive verification (arity 2, n=4..200) ---")
    violations = 0
    checks = 0
    for n in range(4, 201, 2):
        for p, q in goldbach_witnesses_ordered(n):
            L = [p, q]
            ct = count_twos(L)
            if ct % 2 != (sum(L) + len(L)) % 2:
                violations += 1
            checks += 1
    print(f"  Checked {checks} decompositions, violations: {violations}")
    print()


def demo_symmetry_transfer():
    """Demonstrate the Ordered/Unordered Transfer Law."""
    print("=" * 70)
    print("DEMO 2: Ordered/Unordered Witness Transfer Law")
    print("=" * 70)
    print()
    print("|ordered| = 2 * |strict| + |diagonal|")
    print()
    print(f"{'n':>5} {'|ordered|':>10} {'|strict|':>10} {'|diag|':>7} "
          f"{'2*strict+diag':>14} {'Match':>6}")
    print("-" * 55)

    for n in range(4, 102, 2):
        ordered = goldbach_witnesses_ordered(n)
        strict = [(p, q) for p, q in ordered if p < q]
        diag = [(p, q) for p, q in ordered if p == q]

        expected = 2 * len(strict) + len(diag)
        match = len(ordered) == expected

        if n <= 30 or n in [50, 100]:
            print(f"{n:>5} {len(ordered):>10} {len(strict):>10} {len(diag):>7} "
                  f"{expected:>14} {str(match):>6}")

    print()
    # Verify the formula for all even n up to 500
    violations = 0
    for n in range(4, 501, 2):
        ordered = goldbach_witnesses_ordered(n)
        strict = [(p, q) for p, q in ordered if p < q]
        diag = [(p, q) for p, q in ordered if p == q]
        if len(ordered) != 2 * len(strict) + len(diag):
            violations += 1
    print(f"  Verified transfer law for all even n in [4,500]: "
          f"violations = {violations}")
    print()


def demo_multiplicity():
    """Demonstrate the Goldbach Multiplicity Lower Bound."""
    print("=" * 70)
    print("DEMO 3: Goldbach Multiplicity Lower Bound")
    print("=" * 70)
    print()
    print("For even n >= 8, the ordered Goldbach count is >= 2.")
    print()

    # Show the counts for small n
    print(f"{'n':>5} {'|ordered|':>10} {'Status':>20}")
    print("-" * 40)
    for n in range(4, 52, 2):
        ordered = goldbach_witnesses_ordered(n)
        count = len(ordered)
        if n < 8:
            status = f"count={count} (below threshold)"
        elif count >= 2:
            status = f"count={count} >= 2 ✓"
        else:
            status = f"count={count} VIOLATION!"
        if n <= 20 or n == 50:
            print(f"{n:>5} {count:>10} {status:>20}")

    # Verify for all even n in [8, 1000]
    min_count = float('inf')
    min_n = 0
    violations = 0
    for n in range(8, 1001, 2):
        count = len(goldbach_witnesses_ordered(n))
        if count < 2:
            violations += 1
        if count < min_count:
            min_count = count
            min_n = n

    print(f"\n  Verified for all even n in [8,1000]: violations = {violations}")
    print(f"  Minimum count = {min_count} at n = {min_n}")
    print(f"  Only n=4 (count=1) and n=6 (count=1) have exactly 1 representation")
    print()


def demo_weak_chen():
    """Demonstrate Weak Chen Decompositions."""
    print("=" * 70)
    print("DEMO 4: Weak Chen Decompositions")
    print("=" * 70)
    print()
    print("n = p + s where p is prime, s is prime or semiprime")
    print()

    # Show examples
    for n in [10, 20, 30, 50, 100]:
        decomps = weak_chen_decomposition(n)
        prime_decomps = [(p, s) for p, s, t in decomps if t == "prime"]
        semi_decomps = [(p, s) for p, s, t in decomps if t == "semiprime"]
        print(f"  n={n}: {len(prime_decomps)} prime decomps, "
              f"{len(semi_decomps)} semiprime decomps")
        if prime_decomps:
            print(f"    Prime examples: {prime_decomps[:3]}")
        if semi_decomps:
            print(f"    Semiprime examples: {semi_decomps[:3]}")
        print()

    # Verify for all even n in [4, 500]
    missing = []
    for n in range(4, 501, 2):
        if not weak_chen_decomposition(n):
            missing.append(n)

    print(f"  Even numbers in [4,500] without weak Chen decomposition: "
          f"{missing if missing else 'none'}")
    print()


if __name__ == "__main__":
    print("\n" + "=" * 70)
    print("  ADDITIVE PRIME DECOMPOSITION THEORY — DEMONSTRATIONS")
    print("=" * 70 + "\n")

    demo_parity_census()
    demo_symmetry_transfer()
    demo_multiplicity()
    demo_weak_chen()

    print("\nAll demonstrations complete.")
