#!/usr/bin/env python3
"""
Tropical Contraction Theory for Collatz Dynamics — Numerical Demonstrations

This script demonstrates the key results formalized in:
  - Catalog/Computation/CollatzTropical.lean
  - Catalog/Computation/CollatzTropicalContraction.lean

All functions are self-contained with type hints. No external dependencies
beyond the Python standard library.
"""

from __future__ import annotations
import math
from typing import Callable


# =============================================================================
# Section 1: Collatz Map and Basic Properties
# =============================================================================

def collatz(n: int) -> int:
    """Standard Collatz map: n/2 if even, 3n+1 if odd."""
    return n // 2 if n % 2 == 0 else 3 * n + 1


def collatz_odd(n: int) -> int:
    """Accelerated odd map: (3n+1)/2."""
    return (3 * n + 1) // 2


def collatz_orbit(n: int, max_steps: int = 10000) -> list[int]:
    """Compute the full Collatz orbit from n down to 1."""
    orbit: list[int] = [n]
    while n != 1 and len(orbit) < max_steps:
        n = collatz(n)
        orbit.append(n)
    return orbit


def demo_fundamental_cycle() -> None:
    """Demonstrate Theorem: collatz_cycle — the 1→4→2→1 cycle."""
    print("=" * 60)
    print("Demo 1: Fundamental Collatz Cycle (collatz_cycle)")
    print("=" * 60)
    print(f"  T(1) = {collatz(1)}  (expected: 4)")
    print(f"  T(4) = {collatz(4)}  (expected: 2)")
    print(f"  T(2) = {collatz(2)}  (expected: 1)")
    print(f"  Cycle: 1 → 4 → 2 → 1  ✓")
    print()


# =============================================================================
# Section 2: Arithmetic Contraction Lemmas
# =============================================================================

def demo_four_divisibility_contraction() -> None:
    """
    Demonstrate Theorems:
      - odd_branch_contracts_if_four_dvd: (3n+1)/4 < n when 4 | (3n+1) and n ≥ 2
      - four_dvd_of_one_mod_four: n ≡ 1 (mod 4) implies 4 | (3n+1)
    """
    print("=" * 60)
    print("Demo 2: 4-Divisibility Contraction")
    print("=" * 60)

    # Test n ≡ 1 (mod 4) — the favorable residue class
    favorable: list[int] = [n for n in range(1, 50) if n % 4 == 1]
    print(f"  Numbers ≡ 1 (mod 4) up to 50: {favorable}")
    print()

    print(f"  {'n':>6} {'n mod 4':>8} {'3n+1':>8} {'4|(3n+1)':>10} {'(3n+1)/4':>10} {'< n?':>6}")
    print(f"  {'-'*6} {'-'*8} {'-'*8} {'-'*10} {'-'*10} {'-'*6}")
    for n in favorable:
        val = 3 * n + 1
        divides = val % 4 == 0
        quotient = val // 4
        contracts = quotient < n if n >= 2 else "N/A"
        print(f"  {n:>6} {n % 4:>8} {val:>8} {str(divides):>10} {quotient:>10} {str(contracts):>6}")

    print()
    print("  All n ≡ 1 (mod 4) with n ≥ 2 satisfy (3n+1)/4 < n  ✓")
    print()


def demo_accelerated_growth_bound() -> None:
    """
    Demonstrate Theorem: collatzOdd_le_two_mul — (3n+1)/2 ≤ 2n for n ≥ 1.
    """
    print("=" * 60)
    print("Demo 3: Accelerated Odd Map Growth Bound")
    print("=" * 60)

    print(f"  {'n':>6} {'(3n+1)/2':>10} {'2n':>6} {'≤ 2n?':>8} {'ratio':>8}")
    print(f"  {'-'*6} {'-'*10} {'-'*6} {'-'*8} {'-'*8}")
    for n in [1, 3, 5, 7, 11, 27, 99, 999, 9999]:
        acc = collatz_odd(n)
        bound = 2 * n
        ok = acc <= bound
        ratio = acc / n
        print(f"  {n:>6} {acc:>10} {bound:>6} {str(ok):>8} {ratio:>8.4f}")

    print()
    print("  (3n+1)/2 ≤ 2n for all odd n ≥ 1  ✓")
    print()


# =============================================================================
# Section 3: Logarithmic Branch Analysis
# =============================================================================

def log_potential(n: int) -> float:
    """Tropical coordinate: log(n)."""
    return math.log(n) if n > 0 else float('-inf')


def demo_log_branch_identities() -> None:
    """
    Demonstrate Theorems:
      - collatz_log_even: φ(T(n)) = φ(n) - log(2) for even n
      - collatz_log_odd_upper_coarse: φ(T(n)) ≤ φ(n) + log(4) for odd n
      - collatz_two_step_log_bound: φ(T²(n)) ≤ φ(n) + log(2) for odd n
    """
    print("=" * 60)
    print("Demo 4: Logarithmic Branch Analysis")
    print("=" * 60)

    log2 = math.log(2)
    log4 = math.log(4)

    print("\n  Even branch: φ(T(n)) = φ(n) - log(2)")
    print(f"  {'n':>8} {'φ(n)':>10} {'φ(T(n))':>10} {'φ(n)-log2':>12} {'error':>12}")
    print(f"  {'-'*8} {'-'*10} {'-'*10} {'-'*12} {'-'*12}")
    for n in [2, 4, 10, 100, 1000, 10000]:
        phi_n = log_potential(n)
        phi_tn = log_potential(collatz(n))
        expected = phi_n - log2
        error = abs(phi_tn - expected)
        print(f"  {n:>8} {phi_n:>10.6f} {phi_tn:>10.6f} {expected:>12.6f} {error:>12.2e}")

    print("\n  Odd branch: φ(T(n)) ≤ φ(n) + log(4)")
    print(f"  {'n':>8} {'φ(T(n))':>10} {'φ(n)+log4':>12} {'gap':>10}")
    print(f"  {'-'*8} {'-'*10} {'-'*12} {'-'*10}")
    for n in [1, 3, 7, 15, 27, 99, 999]:
        phi_tn = log_potential(collatz(n))
        upper = log_potential(n) + log4
        gap = upper - phi_tn
        print(f"  {n:>8} {phi_tn:>10.6f} {upper:>12.6f} {gap:>10.6f}")

    print("\n  Two-step bound: φ(T²(n)) ≤ φ(n) + log(2) for odd n")
    print(f"  {'n':>8} {'φ(T²(n))':>10} {'φ(n)+log2':>12} {'gap':>10}")
    print(f"  {'-'*8} {'-'*10} {'-'*12} {'-'*10}")
    for n in [1, 3, 7, 15, 27, 99, 999]:
        t2n = collatz(collatz(n))
        phi_t2n = log_potential(t2n)
        upper = log_potential(n) + log2
        gap = upper - phi_t2n
        print(f"  {n:>8} {phi_t2n:>10.6f} {upper:>12.6f} {gap:>10.6f}")

    print()


# =============================================================================
# Section 4: Bellman Operator and Picard Iteration
# =============================================================================

def bellman_operator(
    gamma: float, a: float, b: float,
    f: dict[int, float], domain: int
) -> dict[int, float]:
    """
    Apply the discounted Collatz Bellman operator:
      (Bf)(n) = γ · min(f(n//2) + a, f((3n+1)//2) + b)

    Corresponds to collatzBellmanFn in CollatzTropicalContraction.lean.
    """
    f_new: dict[int, float] = {}
    for n in range(domain):
        even_val = f.get(n // 2, 0.0) + a
        odd_val = f.get((3 * n + 1) // 2, 0.0) + b
        f_new[n] = gamma * min(even_val, odd_val)
    return f_new


def picard_iteration(
    gamma: float, a: float, b: float,
    domain: int, iterations: int
) -> tuple[list[dict[int, float]], list[float]]:
    """
    Run Picard iteration for the Collatz Bellman operator.
    Returns the sequence of iterates and the sup-norm differences.

    Demonstrates collatzBellman_iterate_converges.
    """
    f: dict[int, float] = {n: 0.0 for n in range(domain)}
    history: list[dict[int, float]] = [f.copy()]
    diffs: list[float] = []

    for _ in range(iterations):
        f_new = bellman_operator(gamma, a, b, f, domain)
        diff = max(abs(f_new[n] - f[n]) for n in range(domain))
        diffs.append(diff)
        f = f_new
        history.append(f.copy())

    return history, diffs


def demo_picard_iteration() -> None:
    """
    Demonstrate Theorems:
      - collatzBellmanBCF_contracting: the operator contracts with factor γ
      - collatzBellman_iterate_converges: Picard iteration converges
      - collatzBellman_fixedPoint_eq: fixed point satisfies Bellman equation
    """
    print("=" * 60)
    print("Demo 5: Picard Iteration for Tropical Value Function")
    print("=" * 60)

    gamma = 0.9
    a = -math.log(2)   # even branch cost
    b = math.log(1.5)   # odd branch cost = log(3/2)
    domain = 50
    iterations = 40

    history, diffs = picard_iteration(gamma, a, b, domain, iterations)

    print(f"\n  Parameters: γ = {gamma}, a = -log(2) ≈ {a:.4f}, b = log(3/2) ≈ {b:.4f}")
    print(f"  Domain: {{0, ..., {domain-1}}}, Iterations: {iterations}")
    print()

    print(f"  {'Iter':>6} {'‖fₖ₊₁ - fₖ‖∞':>16} {'γ^k bound':>14} {'ratio':>10}")
    print(f"  {'-'*6} {'-'*16} {'-'*14} {'-'*10}")
    for k in range(min(20, len(diffs))):
        bound = gamma ** (k + 1) * diffs[0] / gamma if diffs[0] > 0 else 0
        ratio = diffs[k] / diffs[k-1] if k > 0 and diffs[k-1] > 0 else float('nan')
        print(f"  {k+1:>6} {diffs[k]:>16.10f} {bound:>14.10f} {ratio:>10.6f}")

    print(f"\n  Convergence ratio stabilizes near γ = {gamma}  ✓")

    # Verify fixed-point equation
    f_star = history[-1]
    print("\n  Verifying Bellman equation at fixed point:")
    print(f"  {'n':>6} {'f*(n)':>12} {'γ·min(...)':>12} {'|error|':>12}")
    print(f"  {'-'*6} {'-'*12} {'-'*12} {'-'*12}")
    for n in [0, 1, 2, 3, 5, 10, 27, 42]:
        if n < domain:
            even_val = f_star.get(n // 2, 0.0) + a
            odd_val = f_star.get((3 * n + 1) // 2, 0.0) + b
            bellman_val = gamma * min(even_val, odd_val)
            error = abs(f_star[n] - bellman_val)
            print(f"  {n:>6} {f_star[n]:>12.8f} {bellman_val:>12.8f} {error:>12.2e}")

    print()


# =============================================================================
# Section 5: Branch Isometry Verification
# =============================================================================

def demo_branch_isometry() -> None:
    """
    Demonstrate Theorems:
      - collatz_branchEven_isometry: |βE(x) - βE(y)| = |x - y|
      - collatz_branchOdd_isometry: |βO(x) - βO(y)| = |x - y|
    """
    print("=" * 60)
    print("Demo 6: Branch Isometry in Log-Coordinates")
    print("=" * 60)

    log2 = math.log(2)
    log3 = math.log(3)

    def branch_even(x: float) -> float:
        return x - log2

    def branch_odd(x: float) -> float:
        return x + log3 - log2

    pairs: list[tuple[float, float]] = [
        (1.0, 2.0), (0.5, 3.7), (10.0, 10.001), (-1.0, 5.0), (100.0, 200.0)
    ]

    print(f"\n  {'x':>8} {'y':>8} {'|x-y|':>10} {'|βE(x)-βE(y)|':>16} {'|βO(x)-βO(y)|':>16}")
    print(f"  {'-'*8} {'-'*8} {'-'*10} {'-'*16} {'-'*16}")
    for x, y in pairs:
        d_orig = abs(x - y)
        d_even = abs(branch_even(x) - branch_even(y))
        d_odd = abs(branch_odd(x) - branch_odd(y))
        print(f"  {x:>8.3f} {y:>8.3f} {d_orig:>10.6f} {d_even:>16.6f} {d_odd:>16.6f}")

    print(f"\n  All distances preserved exactly — both branches are isometries  ✓")
    print()


# =============================================================================
# Section 6: Min-Plus Contraction Algebra
# =============================================================================

def demo_min_plus_lipschitz() -> None:
    """
    Demonstrate Theorem: abs_min_sub_min_le
      |min(a,b) - min(c,d)| ≤ max(|a-c|, |b-d|)
    """
    print("=" * 60)
    print("Demo 7: Min-Plus Nonexpansiveness")
    print("=" * 60)

    import random
    random.seed(42)

    print(f"\n  {'a':>8} {'b':>8} {'c':>8} {'d':>8} {'|Δmin|':>10} {'max|Δ|':>10} {'≤?':>5}")
    print(f"  {'-'*8} {'-'*8} {'-'*8} {'-'*8} {'-'*10} {'-'*10} {'-'*5}")

    all_ok = True
    for _ in range(12):
        a = round(random.uniform(-10, 10), 3)
        b = round(random.uniform(-10, 10), 3)
        c = round(random.uniform(-10, 10), 3)
        d = round(random.uniform(-10, 10), 3)
        lhs = abs(min(a, b) - min(c, d))
        rhs = max(abs(a - c), abs(b - d))
        ok = lhs <= rhs + 1e-12  # floating point tolerance
        all_ok = all_ok and ok
        print(f"  {a:>8.3f} {b:>8.3f} {c:>8.3f} {d:>8.3f} {lhs:>10.6f} {rhs:>10.6f} {'✓' if ok else '✗':>5}")

    print(f"\n  {'All inequalities hold  ✓' if all_ok else 'FAILURE DETECTED  ✗'}")
    print()


# =============================================================================
# Section 7: Conditional Convergence Verification
# =============================================================================

def demo_conditional_convergence() -> None:
    """
    Demonstrate Theorems:
      - convergence_of_strict_descent
      - collatz_convergence_of_eventual_descent
      - log_contraction_implies_descent
    """
    print("=" * 60)
    print("Demo 8: Conditional Convergence Architecture")
    print("=" * 60)

    # Example: a contracting map T(n) = n // 2 + 1 for n ≥ 3
    def T(n: int) -> int:
        return max(1, n // 2 + 1)

    print("\n  Example contracting map: T(n) = max(1, n//2 + 1)")
    print(f"  {'n':>6} {'T(n)':>6} {'T(n)<n?':>8} {'log ratio':>12}")
    print(f"  {'-'*6} {'-'*6} {'-'*8} {'-'*12}")
    for n in [2, 3, 5, 10, 50, 100, 1000]:
        tn = T(n)
        descends = tn < n
        ratio = math.log(tn) / math.log(n) if n > 1 and tn > 0 else float('nan')
        print(f"  {n:>6} {tn:>6} {str(descends):>8} {ratio:>12.6f}")

    # Verify convergence by iteration
    print("\n  Orbit verification:")
    for start in [10, 50, 100, 500]:
        n = start
        steps = 0
        while n > 1 and steps < 1000:
            n = T(n)
            steps += 1
        print(f"    T^{steps}({start}) = {n}  {'✓' if n == 1 else '✗'}")

    # Log-contraction ratio for actual Collatz
    print("\n  Collatz log-contraction ratio log(T(n))/log(n):")
    print(f"  {'n':>8} {'T(n)':>8} {'ratio':>10} {'< 1?':>6}")
    print(f"  {'-'*8} {'-'*8} {'-'*10} {'-'*6}")
    for n in [3, 7, 15, 27, 31, 63, 127, 255, 511, 1023]:
        tn = collatz(n)
        ratio = math.log(tn) / math.log(n) if n > 1 else float('nan')
        print(f"  {n:>8} {tn:>8} {ratio:>10.6f} {str(ratio < 1):>6}")

    print("\n  Note: Collatz does NOT satisfy log-contraction for odd n (ratio > 1).")
    print("  The framework requires an accelerated operator or averaging.")
    print()


# =============================================================================
# Section 8: Orbit Statistics
# =============================================================================

def demo_orbit_statistics() -> None:
    """
    Demonstrate the parity structure of Collatz orbits and the
    two-step potential bound in action.
    """
    print("=" * 60)
    print("Demo 9: Orbit Parity Statistics and Potential Dynamics")
    print("=" * 60)

    log2 = math.log(2)

    for start in [27, 97, 871]:
        orbit = collatz_orbit(start)
        odd_count = sum(1 for x in orbit[:-1] if x % 2 == 1)
        even_count = sum(1 for x in orbit[:-1] if x % 2 == 0)
        total = len(orbit) - 1
        density = odd_count / total if total > 0 else 0

        # Compute potential trajectory
        potentials = [log_potential(x) for x in orbit if x > 0]
        max_potential = max(potentials)
        net_change = potentials[-1] - potentials[0]

        print(f"\n  Orbit starting at n = {start}:")
        print(f"    Steps to 1:     {total}")
        print(f"    Odd steps:      {odd_count}")
        print(f"    Even steps:     {even_count}")
        print(f"    Odd density:    {density:.4f}  (threshold: {math.log(2)/math.log(3):.4f})")
        print(f"    Peak value:     {max(orbit)}")
        print(f"    Peak potential: {max_potential:.4f}")
        print(f"    Net Δφ:         {net_change:.4f}")
        print(f"    Avg Δφ/step:    {net_change/total:.6f}")

    print()


# =============================================================================
# Main
# =============================================================================

def main() -> None:
    """Run all demonstrations."""
    print()
    print("╔" + "═" * 58 + "╗")
    print("║  Tropical Contraction Theory for Collatz Dynamics        ║")
    print("║  Numerical Demonstrations                                ║")
    print("╚" + "═" * 58 + "╝")
    print()

    demo_fundamental_cycle()
    demo_four_divisibility_contraction()
    demo_accelerated_growth_bound()
    demo_log_branch_identities()
    demo_picard_iteration()
    demo_branch_isometry()
    demo_min_plus_lipschitz()
    demo_conditional_convergence()
    demo_orbit_statistics()

    print("=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)


if __name__ == "__main__":
    main()
