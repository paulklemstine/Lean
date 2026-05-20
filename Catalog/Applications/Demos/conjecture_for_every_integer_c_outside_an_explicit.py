#!/usr/bin/env python3
"""
Applications of Benford Analysis for Quadratic Dynamical Systems

This module demonstrates real-world and mathematical applications of the
Benford universality theory for quadratic maps T_c(x) = x² + c.

Applications:
1. Anomaly detection in financial/scientific data using Benford deviations
2. Parameter classification for quadratic maps via digit statistics
3. Prime orbit visualization and canonical height landscapes
4. Entropy-rate decay analysis
"""

import math
from collections import Counter
from typing import List, Dict, Tuple, Optional


def leading_digit(x: int, base: int = 10) -> int:
    """Extract leading digit of |x| in given base."""
    if x == 0:
        return 0
    x = abs(x)
    while x >= base:
        x //= base
    return x


def quad_map(c: int, x: int) -> int:
    """T_c(x) = x² + c."""
    return x * x + c


def sieve_primes(n: int) -> List[int]:
    """Sieve of Eratosthenes."""
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, n + 1, i):
                is_prime[j] = False
    return [p for p in range(2, n + 1) if is_prime[p]]


# ─────────────────────────────────────────────────────────────────────
# Application 1: Anomaly Detection via Benford Deviation
# ─────────────────────────────────────────────────────────────────────

def detect_anomalous_parameters(c_range: range, prime_bound: int = 500,
                                 n_iters: int = 12, threshold: float = 0.01) -> List[int]:
    """
    Identify parameters c where quadratic orbit digit statistics deviate
    significantly from Benford's law.

    Such anomalous parameters are candidates for having hidden algebraic
    structure (monomial semiconjugacy), as predicted by the rigidity conjecture.

    Args:
        c_range: Range of parameters to scan.
        prime_bound: Upper bound for prime seeds.
        n_iters: Orbit length.
        threshold: KL divergence threshold for anomaly.

    Returns:
        List of anomalous c values.
    """
    primes = sieve_primes(prime_bound)
    anomalous = []

    for c in c_range:
        counts: Dict[int, int] = Counter()

        for p in primes:
            val = p
            for _ in range(n_iters):
                val = val * val + c
                d = leading_digit(val)
                if d >= 1:
                    counts[d] += 1

        total = sum(counts.values())
        if total == 0:
            continue

        # KL divergence
        kl = 0.0
        for d in range(1, 10):
            p_d = counts.get(d, 0) / total
            b_d = math.log10(1 + 1.0 / d)
            if p_d > 0:
                kl += p_d * math.log(p_d / b_d)

        if kl > threshold:
            anomalous.append(c)

    return anomalous


# ─────────────────────────────────────────────────────────────────────
# Application 2: Canonical Height Landscape
# ─────────────────────────────────────────────────────────────────────

def canonical_height_landscape(c_values: List[int],
                                primes: List[int],
                                precision_iters: int = 30) -> Dict[int, List[Tuple[int, float]]]:
    """
    Compute the canonical height Λ_c(p) for a grid of parameters c and primes p.

    The distribution of these heights governs Benford behavior:
    if {2ⁿ·Λ_c(p)} is equidistributed mod 1, then Benford's law holds.

    Args:
        c_values: List of c parameters.
        primes: List of prime starting points.
        precision_iters: Number of iterations for height computation.

    Returns:
        Dict mapping c to list of (prime, height) pairs.
    """
    landscape = {}

    for c in c_values:
        heights = []
        for p in primes:
            val = p
            for _ in range(precision_iters):
                val = val * val + c
            if val != 0:
                try:
                    h = math.log(abs(val)) / (2 ** precision_iters)
                    heights.append((p, h))
                except (OverflowError, ValueError):
                    pass
        landscape[c] = heights

    return landscape


# ─────────────────────────────────────────────────────────────────────
# Application 3: Entropy-Rate Decay Analysis
# ─────────────────────────────────────────────────────────────────────

def entropy_rate_decay(c: int, primes: List[int],
                       max_n: int = 20) -> List[Tuple[int, float]]:
    """
    Measure how the KL divergence from Benford decays as a function of
    the number of orbit steps n.

    The entropy-rate hypothesis predicts exponential decay for generic c.

    Args:
        c: Map parameter.
        primes: List of prime seeds.
        max_n: Maximum number of steps.

    Returns:
        List of (n, kl_divergence) pairs.
    """
    results = []

    for n_steps in range(1, max_n + 1):
        counts: Dict[int, int] = Counter()

        for p in primes:
            val = p
            for _ in range(n_steps):
                val = val * val + c
            d = leading_digit(val)
            if d >= 1:
                counts[d] += 1

        total = sum(counts.values())
        if total == 0:
            results.append((n_steps, float('inf')))
            continue

        kl = 0.0
        for d in range(1, 10):
            p_d = counts.get(d, 0) / total
            b_d = math.log10(1 + 1.0 / d)
            if p_d > 0:
                kl += p_d * math.log(p_d / b_d)

        results.append((n_steps, kl))

    return results


# ─────────────────────────────────────────────────────────────────────
# Application 4: Base-Invariance Test
# ─────────────────────────────────────────────────────────────────────

def test_base_invariance(c: int, primes: List[int], n_iters: int = 12,
                          bases: List[int] = None) -> Dict[int, float]:
    """
    Test the base-invariance hypothesis: if Benford holds in one base
    multiplicatively independent from 2, it holds in all such bases.

    Args:
        c: Map parameter.
        primes: List of prime seeds.
        n_iters: Orbit length.
        bases: List of bases to test.

    Returns:
        Dict mapping base to KL divergence from Benford.
    """
    if bases is None:
        bases = [3, 5, 6, 7, 10, 11, 12, 15]

    results = {}

    for base in bases:
        counts: Dict[int, int] = Counter()

        for p in primes:
            val = p
            for _ in range(n_iters):
                val = val * val + c
                d = leading_digit(val, base)
                if 1 <= d < base:
                    counts[d] += 1

        total = sum(counts.values())
        if total == 0:
            results[base] = float('inf')
            continue

        kl = 0.0
        for d in range(1, base):
            p_d = counts.get(d, 0) / total
            b_d = math.log(1 + 1.0 / d) / math.log(base)
            if p_d > 0:
                kl += p_d * math.log(p_d / b_d)

        results[base] = kl

    return results


# ─────────────────────────────────────────────────────────────────────
# Main: Run all applications
# ─────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    primes = sieve_primes(500)

    print("=" * 70)
    print("APPLICATION 1: Anomalous Parameter Detection")
    print("=" * 70)
    anomalous = detect_anomalous_parameters(range(-20, 21))
    print(f"Parameters with significant Benford deviation (KL > 0.01):")
    print(f"  {anomalous if anomalous else 'None found — universality holds!'}")
    print()

    print("=" * 70)
    print("APPLICATION 2: Canonical Height Landscape")
    print("=" * 70)
    landscape = canonical_height_landscape([0, 1, -1, -2], primes[:10])
    for c, heights in landscape.items():
        print(f"\n  c = {c}:")
        for p, h in heights[:5]:
            print(f"    Λ_{c}({p}) = {h:.10f}")
    print()

    print("=" * 70)
    print("APPLICATION 3: Entropy-Rate Decay")
    print("=" * 70)
    for c in [0, 1, -1]:
        decay = entropy_rate_decay(c, primes[:100], max_n=15)
        print(f"\n  c = {c}:")
        print(f"  {'Step':>6} {'KL divergence':>14}")
        for n, kl in decay:
            bar = "█" * max(0, min(50, int(kl * 500)))
            print(f"  {n:>6} {kl:>14.6f}  {bar}")
    print()

    print("=" * 70)
    print("APPLICATION 4: Base-Invariance Test")
    print("=" * 70)
    for c in [0, 1, -1]:
        invariance = test_base_invariance(c, primes[:200])
        print(f"\n  c = {c}:")
        print(f"  {'Base':>6} {'KL divergence':>14}")
        for base in sorted(invariance.keys()):
            kl = invariance[base]
            print(f"  {base:>6} {kl:>14.6f}")
    print()


#!/usr/bin/env python3
"""
Benford Universality for Prime-Seeded Quadratic Orbits — Demonstrations

This script demonstrates the key mathematical phenomena formalized in the
accompanying proofs:

1. Escape growth: |x²+c| ≈ |x|² for large |x|
2. Renormalized log-height convergence: 2⁻ⁿ·log|T_c⁽ⁿ⁾(x)| → Λ_c(x)
3. Benford behavior of leading digits for quadratic orbits
4. Doubling-map shadowing of log-orbits
"""

import math
from collections import Counter
from typing import List, Tuple


def quad_map(c: int, x: int) -> int:
    """Quadratic map T_c(x) = x² + c."""
    return x * x + c


def quad_orbit(c: int, x: int, n: int) -> List[int]:
    """Compute the first n iterates of the quadratic orbit starting at x."""
    orbit = [x]
    val = x
    for _ in range(n):
        val = quad_map(c, val)
        orbit.append(val)
    return orbit


def leading_digit(x: int, base: int = 10) -> int:
    """Extract the leading digit of |x| in the given base."""
    if x == 0:
        return 0
    x = abs(x)
    while x >= base:
        x //= base
    return x


def benford_freq(digit: int, base: int = 10) -> float:
    """Benford's law predicted frequency for leading digit d in given base."""
    if digit < 1 or digit >= base:
        return 0.0
    return math.log(1 + 1.0 / digit) / math.log(base)


def demo_escape_growth():
    """Demonstrate Theorem 1: Escape Growth Inequality.

    Shows that |x²+c| is sandwiched between |x|²/2 and 3|x|²/2
    when |x| ≥ |c| + 2.
    """
    print("=" * 70)
    print("DEMO 1: Escape Growth Inequality")
    print("  For |x| ≥ |c| + 2: |x|²/2 ≤ |x² + c| ≤ 3|x|²/2")
    print("=" * 70)

    test_cases = [
        (0, 3), (0, 10), (0, 100),
        (1, 5), (1, 20), (1, 1000),
        (-1, 4), (-1, 15), (-1, 500),
        (5, 10), (5, 50), (5, 200),
        (-10, 15), (-10, 100), (-10, 1000),
    ]

    print(f"{'c':>6} {'x':>8} {'|x|²/2':>14} {'|x²+c|':>14} {'3|x|²/2':>14} {'OK?':>5}")
    print("-" * 65)

    all_ok = True
    for c, x in test_cases:
        x2 = abs(x) ** 2
        val = abs(x * x + c)
        lower = x2 / 2
        upper = 3 * x2 / 2
        ok = lower <= val <= upper
        all_ok = all_ok and ok
        print(f"{c:>6} {x:>8} {lower:>14.1f} {val:>14} {upper:>14.1f} {'✓' if ok else '✗':>5}")

    print(f"\nAll bounds satisfied: {'YES ✓' if all_ok else 'NO ✗'}")
    print()


def demo_renormalized_convergence():
    """Demonstrate Theorem 2: Convergence of Renormalized Log-Height.

    Shows that 2⁻ⁿ·log|T_c⁽ⁿ⁾(x)| converges for escaping orbits.
    """
    print("=" * 70)
    print("DEMO 2: Renormalized Log-Height Convergence")
    print("  aₙ = 2⁻ⁿ · log|T_c⁽ⁿ⁾(x)| converges for escaping orbits")
    print("=" * 70)

    configs = [
        (0, 3, "c=0, x=3"),
        (1, 2, "c=1, x=2"),
        (-1, 3, "c=-1, x=3"),
        (2, 5, "c=2, x=5"),
        (-2, 3, "c=-2, x=3"),
    ]

    for c, x0, label in configs:
        print(f"\n  {label}:")
        print(f"  {'n':>4} {'|T_c^(n)(x)|':>20} {'aₙ = 2⁻ⁿ·log|...|':>22} {'|aₙ - aₙ₋₁|':>16}")
        print("  " + "-" * 66)

        val = x0
        prev_a = None
        for n in range(16):
            if val == 0:
                print(f"  {n:>4} {'0':>20} {'(orbit hit 0)':>22}")
                break
            try:
                log_val = math.log(abs(val))
            except OverflowError:
                log_val = math.log(2) * abs(val).bit_length()
            a_n = log_val / (2 ** n)
            diff = abs(a_n - prev_a) if prev_a is not None else float('nan')
            try:
                val_str = str(abs(val))
                if len(val_str) > 18:
                    val_str = f"~10^{math.log10(abs(val)):.1f}"
            except (ValueError, OverflowError):
                val_str = f"~10^{math.log(abs(val))/math.log(10):.1f}"
            print(f"  {n:>4} {val_str:>20} {a_n:>22.10f} {diff:>16.2e}")
            prev_a = a_n
            val = quad_map(c, val)

    print()


def demo_benford_digits():
    """Demonstrate the Benford reduction: leading digits of quadratic orbits.

    Computes leading-digit frequencies for prime-seeded quadratic orbits
    and compares to Benford's law predictions.
    """
    print("=" * 70)
    print("DEMO 3: Benford's Law for Prime-Seeded Quadratic Orbits")
    print("  Leading-digit frequencies vs. Benford prediction log₁₀(1+1/d)")
    print("=" * 70)

    # Generate primes up to 1000
    def sieve(n):
        is_prime = [True] * (n + 1)
        is_prime[0] = is_prime[1] = False
        for i in range(2, int(n**0.5) + 1):
            if is_prime[i]:
                for j in range(i*i, n + 1, i):
                    is_prime[j] = False
        return [p for p in range(2, n + 1) if is_prime[p]]

    primes = sieve(200)
    n_iters = 8  # Number of iterations

    for c in [0, 1, -1, 2, -2]:
        digit_counts = Counter()
        total = 0

        for p in primes:
            val = p
            for n in range(1, n_iters + 1):
                val = quad_map(c, val)
                if val != 0:
                    d = leading_digit(val)
                    if d >= 1:
                        digit_counts[d] += 1
                        total += 1

        if total == 0:
            continue

        print(f"\n  c = {c}, primes ≤ 1000, iterations 1..{n_iters}")
        print(f"  Total samples: {total}")
        print(f"  {'Digit':>7} {'Observed':>10} {'Benford':>10} {'Deviation':>10}")
        print("  " + "-" * 42)

        max_dev = 0
        for d in range(1, 10):
            obs = digit_counts[d] / total if total > 0 else 0
            pred = benford_freq(d)
            dev = abs(obs - pred)
            max_dev = max(max_dev, dev)
            print(f"  {d:>7} {obs:>10.4f} {pred:>10.4f} {dev:>10.4f}")

        print(f"  Max deviation: {max_dev:.4f}")

    print()


def demo_doubling_map_shadowing():
    """Demonstrate Theorem 4: Logarithmic Shadowing by Doubling Map.

    Shows that log|T_c⁽ⁿ⁾(x)| ≈ 2ⁿ·Λ_c(x) with bounded error.
    """
    print("=" * 70)
    print("DEMO 4: Doubling-Map Shadowing")
    print("  |log|T_c⁽ⁿ⁾(x)| - 2ⁿ·Λ_c(x)| ≤ log(2) ≈ 0.693")
    print("=" * 70)

    configs = [
        (0, 3, "c=0, x=3"),
        (1, 5, "c=1, x=5"),
        (-1, 3, "c=-1, x=3"),
        (2, 7, "c=2, x=7"),
    ]

    for c, x0, label in configs:
        # First, estimate Λ_c(x) by computing many iterates
        val = x0
        n_est = 20
        for _ in range(n_est):
            val = quad_map(c, val)
        # Approximate Λ_c(x) from a late iterate
        if val != 0:
            try:
                Lambda = math.log(abs(val)) / (2 ** n_est)
            except OverflowError:
                Lambda = math.log(2) * abs(val).bit_length() / (2 ** n_est)
        else:
            continue

        print(f"\n  {label}, estimated Λ_c(x) ≈ {Lambda:.10f}")
        print(f"  {'n':>4} {'log|T_c^(n)(x)|':>22} {'2ⁿ·Λ_c(x)':>22} {'|error|':>12} {'≤ log2?':>8}")
        print("  " + "-" * 72)

        val = x0
        all_ok = True
        for n in range(12):
            if val == 0:
                break
            log_val = math.log(abs(val))
            predicted = (2 ** n) * Lambda
            error = abs(log_val - predicted)
            ok = error <= math.log(2) + 1e-10  # small tolerance for floating point
            all_ok = all_ok and ok
            print(f"  {n:>4} {log_val:>22.8f} {predicted:>22.8f} {error:>12.8f} {'✓' if ok else '✗':>8}")
            val = quad_map(c, val)

        print(f"  All within log(2) bound: {'YES ✓' if all_ok else 'NO ✗'}")

    print()


if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  BENFORD UNIVERSALITY FOR PRIME-SEEDED QUADRATIC ORBITS            ║")
    print("║  Computational Demonstrations                                      ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_escape_growth()
    demo_renormalized_convergence()
    demo_benford_digits()
    demo_doubling_map_shadowing()

    print("=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)
