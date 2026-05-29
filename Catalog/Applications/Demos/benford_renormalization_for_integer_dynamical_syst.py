#!/usr/bin/env python3
"""
Benford Renormalization: Applications

Demonstrates real-world and mathematical applications of the
Benford renormalization theory for integer dynamical systems.

Applications include:
1. Fraud detection via Benford compliance testing
2. Pseudorandomness testing for arithmetic recurrences
3. Dynamical system classification by spectral type
"""

import math
from collections import Counter
from typing import List, Dict, Callable, Tuple


# ═══════════════════════════════════════════════════════════════════
# Core functions (self-contained)
# ═══════════════════════════════════════════════════════════════════

def leading_digit(n: int, base: int = 10) -> int:
    if n <= 0 or base <= 1:
        return 0
    while n >= base:
        n //= base
    return n


def benford_predicted(d: int, base: int = 10) -> float:
    return math.log(1 + 1 / d) / math.log(base)


def frac_log(x: float, base: int = 10) -> float:
    if x <= 0:
        return 0.0
    v = math.log(x) / math.log(base)
    return v - math.floor(v)


def digit_frequencies(data: List[int], base: int = 10) -> Dict[int, float]:
    N = sum(1 for x in data if x >= 1)
    if N == 0:
        return {}
    counts = Counter(leading_digit(x, base) for x in data if x >= 1)
    return {d: counts.get(d, 0) / N for d in range(1, base)}


def chi_squared_benford(data: List[int], base: int = 10) -> float:
    """Chi-squared test statistic against Benford's law."""
    N = sum(1 for x in data if x >= 1)
    if N == 0:
        return 0.0
    freqs = digit_frequencies(data, base)
    chi2 = 0.0
    for d in range(1, base):
        observed = freqs.get(d, 0) * N
        expected = benford_predicted(d, base) * N
        if expected > 0:
            chi2 += (observed - expected) ** 2 / expected
    return chi2


def fourier_obstruction_score(data: List[int], base: int = 10,
                               max_m: int = 10) -> float:
    """
    Spectral obstruction score: maximum Fourier magnitude over modes 1..max_m.
    Values close to 1 indicate strong rational resonance (obstruction).
    Values close to 0 indicate spectral flatness (no obstruction).
    """
    N = len(data)
    if N == 0:
        return 0.0
    max_mag = 0.0
    for m in range(1, max_m + 1):
        total = sum(
            complex(math.cos(2 * math.pi * m * frac_log(x, base)),
                    math.sin(2 * math.pi * m * frac_log(x, base)))
            for x in data if x >= 1
        )
        mag = abs(total / N)
        max_mag = max(max_mag, mag)
    return max_mag


# ═══════════════════════════════════════════════════════════════════
# Application 1: Financial Fraud Detection
# ═══════════════════════════════════════════════════════════════════

def fraud_detection_demo():
    """
    Demonstrate Benford-based fraud detection.

    Natural financial data tends to follow Benford's law. Fabricated data
    often deviates because humans tend to choose digits uniformly.
    The spectral obstruction framework provides a deeper diagnostic:
    not just "does it match Benford?" but "what kind of structure
    causes the deviation?"
    """
    print("=" * 60)
    print("Application 1: Financial Fraud Detection")
    print("=" * 60)

    # Simulate "natural" financial data (geometric growth with noise)
    import random
    random.seed(42)
    natural_data = []
    for _ in range(1000):
        # Multiplicative random walk (log-normal-ish)
        val = int(math.exp(random.gauss(5, 2)))
        if val > 0:
            natural_data.append(val)

    # Simulate "fabricated" data (uniform digits)
    fabricated_data = [random.randint(100, 999) for _ in range(1000)]

    # Simulate "obstructed" data (powers of 10 with small perturbations)
    obstructed_data = [10**k + random.randint(0, 5) for k in range(1, 100)
                       for _ in range(10)]

    for name, data in [("Natural (log-normal)", natural_data),
                       ("Fabricated (uniform)", fabricated_data),
                       ("Obstructed (near-powers-of-10)", obstructed_data)]:
        freqs = digit_frequencies(data)
        chi2 = chi_squared_benford(data)
        obstruction = fourier_obstruction_score(data)

        print(f"\n  {name} (n={len(data)}):")
        print(f"    Chi² vs Benford: {chi2:.2f}")
        print(f"    Spectral obstruction score: {obstruction:.4f}")
        print(f"    Verdict: ", end="")
        if chi2 < 15 and obstruction < 0.3:
            print("✓ Benford-compliant (likely natural)")
        elif obstruction > 0.7:
            print("⚠ Strong spectral obstruction (structured deviation)")
        else:
            print("⚠ Non-Benford (possible fabrication)")

        print(f"    Digit frequencies: ", end="")
        for d in range(1, 10):
            print(f"{d}:{freqs.get(d,0):.3f}", end=" ")
        print()


# ═══════════════════════════════════════════════════════════════════
# Application 2: Pseudorandomness Testing
# ═══════════════════════════════════════════════════════════════════

def pseudorandomness_demo():
    """
    Test pseudorandomness of arithmetic recurrences via Benford compliance.

    The insight: a recurrence that produces Benford-distributed leading
    digits has an equidistributed logarithmic cocycle, which is a
    necessary condition for high-quality pseudorandomness. Rational
    obstructions reveal hidden periodic structure.
    """
    print("\n" + "=" * 60)
    print("Application 2: Pseudorandomness Testing")
    print("=" * 60)

    recurrences = {
        "Linear: x_{n+1} = 3x_n (mod large prime)": (
            lambda x: (3 * x) % 1000003, 7, 5000
        ),
        "Fibonacci-like: x_{n+1} = x_n + x_{n-1}": (
            None, None, None  # special handling
        ),
        "Powers of 2: x_n = 2^n": (
            lambda x: 2 * x, 1, 2000
        ),
        "Exponential: x_n = 3^n": (
            lambda x: 3 * x, 1, 1000
        ),
    }

    for name, params in recurrences.items():
        print(f"\n  {name}:")

        if "Fibonacci" in name:
            # Generate Fibonacci sequence
            seq = [1, 1]
            for _ in range(2000):
                seq.append(seq[-1] + seq[-2])
            data = seq[10:]  # skip initial transient
        else:
            T, seed, steps = params
            data = [seed]
            x = seed
            for _ in range(steps):
                x = T(x)
                if x <= 0:
                    break
                data.append(x)

        freqs = digit_frequencies(data)
        chi2 = chi_squared_benford(data)
        obstruction = fourier_obstruction_score(data)

        print(f"    Chi² vs Benford: {chi2:.2f}")
        print(f"    Spectral obstruction: {obstruction:.4f}")

        if obstruction < 0.2:
            print(f"    → Cocycle is spectrally flat: good pseudorandomness indicator")
        elif obstruction > 0.7:
            print(f"    → Strong rational resonance: reveals periodic structure")
        else:
            print(f"    → Moderate spectral structure: intermediate quality")


# ═══════════════════════════════════════════════════════════════════
# Application 3: Dynamical System Classification
# ═══════════════════════════════════════════════════════════════════

def classification_demo():
    """
    Classify dynamical systems by their Benford spectral type.

    The renormalization framework provides a new invariant for integer
    dynamical systems: the spectral type of the logarithmic cocycle.
    Systems are classified as:
    - Type I (Benford): equidistributed cocycle, no obstruction
    - Type R (Rational): rational resonance, periodic digit structure
    - Type M (Mixed): partial obstruction, complex digit statistics
    """
    print("\n" + "=" * 60)
    print("Application 3: Dynamical System Classification")
    print("=" * 60)

    systems: List[Tuple[str, List[int]]] = []

    # Type I: Irrational rotation (powers of 2)
    systems.append(("Powers of 2 (irrational log₁₀)", [2**k for k in range(1, 2001)]))

    # Type I: Powers of 3
    systems.append(("Powers of 3 (irrational log₁₀)", [3**k for k in range(1, 1001)]))

    # Type R: Powers of 10
    systems.append(("Powers of 10 (rational log₁₀)", [10**k for k in range(1, 201)]))

    # Type R: Powers of 100
    systems.append(("Powers of 100 (rational log₁₀)", [100**k for k in range(1, 101)]))

    # Type I: Factorials
    factorials = [1]
    for k in range(1, 501):
        factorials.append(factorials[-1] * k)
    systems.append(("Factorials n!", factorials[1:]))

    # Mixed: Collatz orbits
    x = 27
    collatz_orbit = [x]
    for _ in range(5000):
        x = x // 2 if x % 2 == 0 else 3 * x + 1
        collatz_orbit.append(x)
    systems.append(("Collatz orbit (seed=27)", collatz_orbit))

    print(f"\n  {'System':<40} {'χ²':<10} {'Obstruction':<14} {'Type'}")
    print(f"  {'-'*80}")

    for name, data in systems:
        chi2 = chi_squared_benford(data)
        obstruction = fourier_obstruction_score(data)

        if obstruction > 0.7:
            stype = "Type R (Rational)"
        elif chi2 < 20 and obstruction < 0.3:
            stype = "Type I (Benford)"
        else:
            stype = "Type M (Mixed)"

        print(f"  {name:<40} {chi2:<10.2f} {obstruction:<14.4f} {stype}")


# ═══════════════════════════════════════════════════════════════════
# Main
# ═══════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║   BENFORD RENORMALIZATION: Applications Showcase            ║")
    print("╚══════════════════════════════════════════════════════════════╝")

    fraud_detection_demo()
    pseudorandomness_demo()
    classification_demo()

    print("\n" + "=" * 60)
    print("  All applications demonstrated successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Benford Renormalization: Interactive Demo

Demonstrates the theory of Benford renormalization for integer dynamical
systems. Users can explore how different map families produce or fail to
produce Benford-distributed leading digits, and inspect the spectral
obstruction diagnostics.

Usage:
    python demo.py

The demo presents a menu of map families and analysis options.
"""

import math
from collections import Counter
from typing import Callable, Dict, List, Optional, Tuple


# ═══════════════════════════════════════════════════════════════════
# Core algorithms (self-contained for demo purposes)
# ═══════════════════════════════════════════════════════════════════

def leading_digit_base(b: int, n: int) -> int:
    """Extract leading digit of n in base b."""
    if b <= 1 or n <= 0:
        return 0
    while n >= b:
        n //= b
    return n


def benford_theoretical(b: int, d: int) -> float:
    """Benford-predicted frequency for digit d in base b."""
    return math.log(1 + 1 / d) / math.log(b)


def frac_log_base(b: int, x: float) -> float:
    """Fractional part of log_b(x)."""
    if x <= 0:
        return 0.0
    v = math.log(x) / math.log(b)
    return v - math.floor(v)


def digit_frequency_profile(seq: List[int], base: int = 10) -> Dict[int, float]:
    """Compute empirical leading-digit frequencies."""
    N = len(seq)
    if N == 0:
        return {}
    counts = Counter(leading_digit_base(base, n) for n in seq if n >= 1)
    return {d: counts.get(d, 0) / N for d in range(1, base)}


def benford_discrepancy(seq: List[int], base: int = 10) -> float:
    """Total absolute discrepancy from Benford's law."""
    profile = digit_frequency_profile(seq, base)
    return sum(abs(profile.get(d, 0) - benford_theoretical(base, d))
               for d in range(1, base))


def fourier_mode_estimate(seq: List[int], m: int, base: int = 10) -> complex:
    """Estimate m-th Fourier mode of frac(log_b(u_k))."""
    N = len(seq)
    if N == 0:
        return 0j
    total = sum(
        complex(math.cos(2 * math.pi * m * frac_log_base(base, x)),
                math.sin(2 * math.pi * m * frac_log_base(base, x)))
        for x in seq if x >= 1
    )
    return total / N


def detect_rational_obstruction(seq: List[int], base: int = 10,
                                 max_q: int = 20,
                                 threshold: float = 0.1) -> Optional[Tuple[int, float]]:
    """Detect rational eigen-obstruction via Fourier modes."""
    for q in range(1, max_q + 1):
        mode = fourier_mode_estimate(seq, q, base)
        mag = abs(mode)
        if mag > 1 - threshold:
            return (q, mag)
    return None


def generate_orbit(T: Callable[[int], int], seed: int, steps: int) -> List[int]:
    """Generate orbit of T starting from seed."""
    orbit = [seed]
    x = seed
    for _ in range(steps):
        x = T(x)
        if x <= 0:
            break
        orbit.append(x)
    return orbit


# ═══════════════════════════════════════════════════════════════════
# Map families
# ═══════════════════════════════════════════════════════════════════

MAP_FAMILIES = {
    '1': ('Multiplication: T(n) = r·n', 'mult'),
    '2': ('Affine: T(n) = a·n + c', 'affine'),
    '3': ('Power of base: T(n) = b^n (obstruction example)', 'powbase'),
    '4': ('Collatz-type: 3n+1 / n÷2', 'collatz'),
    '5': ('Reverse-and-add', 'revaddd'),
    '6': ('Polynomial perturbation: T(n) = r·n + c', 'polpert'),
}


def run_analysis(name: str, orbit: List[int], base: int = 10):
    """Run full Benford analysis on an orbit and display results."""
    print(f"\n{'=' * 60}")
    print(f"  {name}")
    print(f"{'=' * 60}")
    print(f"  Orbit length: {len(orbit)}")
    if len(orbit) > 0:
        print(f"  First 5 values: {orbit[:5]}")
        print(f"  Last 5 values: {orbit[-5:]}")

    print(f"\n  {'Digit':<8} {'Empirical':<12} {'Benford':<12} {'Diff':<12}")
    print(f"  {'-'*44}")

    profile = digit_frequency_profile(orbit, base)
    for d in range(1, base):
        emp = profile.get(d, 0)
        pred = benford_theoretical(base, d)
        diff = emp - pred
        bar = '█' * int(abs(diff) * 200)
        print(f"  {d:<8} {emp:<12.4f} {pred:<12.4f} {diff:+.4f}  {bar}")

    disc = benford_discrepancy(orbit, base)
    print(f"\n  Total discrepancy: {disc:.6f}")

    # Fourier mode analysis
    print(f"\n  Fourier mode analysis (spectral obstruction detection):")
    print(f"  {'Mode m':<10} {'|c_m|':<12} {'Status':<20}")
    print(f"  {'-'*42}")
    for m in range(1, 6):
        mode = fourier_mode_estimate(orbit, m, base)
        mag = abs(mode)
        status = "⚠ OBSTRUCTION" if mag > 0.5 else "✓ decaying"
        print(f"  {m:<10} {mag:<12.6f} {status}")

    obs = detect_rational_obstruction(orbit, base)
    if obs:
        print(f"\n  ⚠ RATIONAL OBSTRUCTION DETECTED: q={obs[0]}, magnitude={obs[1]:.4f}")
        print(f"    The sequence has a rational resonance at frequency q={obs[0]}.")
        print(f"    This blocks Benford universality (Theorem 2 in the formal development).")
    else:
        print(f"\n  ✓ No rational obstruction detected.")
        print(f"    The logarithmic cocycle appears spectrally flat.")

    # Fractional log histogram
    print(f"\n  Fractional log histogram (10 bins in [0, 1)):")
    frac_logs = [frac_log_base(base, x) for x in orbit if x >= 1]
    bins = [0] * 10
    for fl in frac_logs:
        idx = min(int(fl * 10), 9)
        bins[idx] += 1
    total = len(frac_logs)
    for i in range(10):
        freq = bins[i] / total if total > 0 else 0
        bar = '▓' * int(freq * 50)
        print(f"  [{i/10:.1f}, {(i+1)/10:.1f})  {freq:.3f}  {bar}")


def main():
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║      BENFORD RENORMALIZATION: Interactive Demo              ║")
    print("║                                                            ║")
    print("║  Exploring digit-law universality in arithmetic dynamics   ║")
    print("╚══════════════════════════════════════════════════════════════╝")

    while True:
        print("\n── Choose a map family ──────────────────────────────────────")
        for key, (desc, _) in MAP_FAMILIES.items():
            print(f"  [{key}] {desc}")
        print(f"  [q] Quit")

        choice = input("\nYour choice: ").strip()
        if choice.lower() == 'q':
            print("\nGoodbye!")
            break

        if choice not in MAP_FAMILIES:
            print("Invalid choice. Try again.")
            continue

        _, family = MAP_FAMILIES[choice]
        base = 10

        try:
            base_input = input("Base (default 10): ").strip()
            if base_input:
                base = int(base_input)
                if base < 2:
                    base = 10
        except ValueError:
            base = 10

        if family == 'mult':
            try:
                r = int(input("Multiplier r (e.g. 3): ").strip() or "3")
                seed = int(input("Seed (e.g. 1): ").strip() or "1")
                steps = int(input("Steps (e.g. 1000): ").strip() or "1000")
            except ValueError:
                r, seed, steps = 3, 1, 1000

            orbit = generate_orbit(lambda n: r * n, seed, steps)
            run_analysis(f"Multiplication map T(n) = {r}·n, seed={seed}", orbit, base)

            # Check if log_b(r) is rational
            log_r = math.log(r) / math.log(base)
            # Test rationality heuristically
            is_likely_rational = False
            for q in range(1, 50):
                if abs(q * log_r - round(q * log_r)) < 1e-10:
                    is_likely_rational = True
                    print(f"\n  Note: log_{base}({r}) ≈ {round(q*log_r)}/{q} "
                          f"(rational => obstruction expected)")
                    break
            if not is_likely_rational:
                print(f"\n  Note: log_{base}({r}) ≈ {log_r:.6f} "
                      f"(likely irrational => Benford expected)")

        elif family == 'affine':
            try:
                a = int(input("Slope a (e.g. 3): ").strip() or "3")
                c = int(input("Intercept c (e.g. 1): ").strip() or "1")
                seed = int(input("Seed (e.g. 1): ").strip() or "1")
                steps = int(input("Steps (e.g. 1000): ").strip() or "1000")
            except ValueError:
                a, c, seed, steps = 3, 1, 1, 1000

            orbit = generate_orbit(lambda n: a * n + c, seed, steps)
            run_analysis(f"Affine map T(n) = {a}·n + {c}, seed={seed}", orbit, base)

        elif family == 'powbase':
            try:
                steps = int(input("Number of powers (e.g. 100): ").strip() or "100")
            except ValueError:
                steps = 100

            orbit = [base ** k for k in range(1, steps + 1)]
            run_analysis(f"Powers of {base}: {base}^1, {base}^2, ..., {base}^{steps}",
                        orbit, base)
            print(f"\n  This demonstrates Theorem 1: powers of the base have")
            print(f"  leading digit 1 always, creating a maximal obstruction.")

        elif family == 'collatz':
            try:
                seed = int(input("Seed (e.g. 27): ").strip() or "27")
                steps = int(input("Steps (e.g. 5000): ").strip() or "5000")
            except ValueError:
                seed, steps = 27, 5000

            def collatz(n):
                return n // 2 if n % 2 == 0 else 3 * n + 1

            orbit = generate_orbit(collatz, seed, steps)
            run_analysis(f"Collatz map, seed={seed}", orbit, base)

        elif family == 'revaddd':
            try:
                seed = int(input("Seed (e.g. 196): ").strip() or "196")
                steps = int(input("Steps (e.g. 500): ").strip() or "500")
            except ValueError:
                seed, steps = 196, 500

            def rev_add(n):
                return n + int(str(n)[::-1])

            orbit = generate_orbit(rev_add, seed, steps)
            run_analysis(f"Reverse-and-add, seed={seed}", orbit, base)

        elif family == 'polpert':
            try:
                r = int(input("Multiplier r (e.g. 3): ").strip() or "3")
                c = int(input("Perturbation c (e.g. 7): ").strip() or "7")
                seed = int(input("Seed (e.g. 1): ").strip() or "1")
                steps = int(input("Steps (e.g. 1000): ").strip() or "1000")
            except ValueError:
                r, c, seed, steps = 3, 7, 1, 1000

            orbit = generate_orbit(lambda n: r * n + c, seed, steps)
            run_analysis(f"Perturbed map T(n) = {r}·n + {c}, seed={seed}", orbit, base)

            print(f"\n  This demonstrates Theorem 5 (stability): the perturbation")
            print(f"  +{c} is asymptotically negligible compared to ×{r} growth.")

        print("\n" + "─" * 60)


if __name__ == "__main__":
    main()


"""
Visualization: Benford Digit Frequency Comparison

Compares empirical leading-digit frequencies of several integer sequences
against the Benford prediction log_10(1 + 1/d). Demonstrates the dichotomy:
sequences with irrational logarithmic growth follow Benford's law,
while those with rational structure (powers of the base) deviate maximally.
"""

import math
import matplotlib.pyplot as plt
import numpy as np
from collections import Counter


def leading_digit(n, base=10):
    if n <= 0 or base <= 1:
        return 0
    while n >= base:
        n //= base
    return n


def digit_freqs(data, base=10):
    N = sum(1 for x in data if x >= 1)
    if N == 0:
        return {d: 0 for d in range(1, base)}
    counts = Counter(leading_digit(x, base) for x in data if x >= 1)
    return {d: counts.get(d, 0) / N for d in range(1, base)}


# Generate sequences
powers_of_2 = [2**k for k in range(1, 2001)]
powers_of_3 = [3**k for k in range(1, 1001)]
powers_of_10 = [10**k for k in range(1, 201)]

# Fibonacci
fib = [1, 1]
for _ in range(2000):
    fib.append(fib[-1] + fib[-2])
fibonacci = fib[2:]

# Factorials
facts = [1]
for k in range(1, 501):
    facts.append(facts[-1] * k)
factorials = facts[1:]

sequences = {
    'Powers of 2': powers_of_2,
    'Powers of 3': powers_of_3,
    'Fibonacci': fibonacci,
    'Factorials': factorials,
    'Powers of 10\n(obstructed)': powers_of_10,
}

digits = list(range(1, 10))
benford = [math.log10(1 + 1/d) for d in digits]

fig, axes = plt.subplots(2, 3, figsize=(14, 9))
axes = axes.flatten()

# Plot Benford prediction
ax = axes[0]
ax.bar(digits, benford, color='#2c3e50', alpha=0.9, edgecolor='white')
ax.set_title("Benford's Law\n(Predicted)", fontsize=11, fontweight='bold')
ax.set_xlabel('Leading Digit')
ax.set_ylabel('Frequency')
ax.set_ylim(0, 0.35)
ax.set_xticks(digits)

# Plot each sequence
colors = ['#27ae60', '#2980b9', '#8e44ad', '#e67e22', '#c0392b']
for i, (name, seq) in enumerate(sequences.items()):
    ax = axes[i + 1]
    freqs = digit_freqs(seq)
    emp = [freqs.get(d, 0) for d in digits]

    x = np.array(digits)
    width = 0.35
    ax.bar(x - width/2, emp, width, label='Empirical',
           color=colors[i], alpha=0.8, edgecolor='white')
    ax.bar(x + width/2, benford, width, label='Benford',
           color='#95a5a6', alpha=0.6, edgecolor='white')
    ax.set_title(name, fontsize=11, fontweight='bold')
    ax.set_xlabel('Leading Digit')
    ax.set_ylim(0, max(max(emp), 0.35) * 1.1)
    ax.set_xticks(digits)
    if i == 0:
        ax.legend(fontsize=8)

fig.suptitle('Benford Renormalization: Digit Frequency Dichotomy',
             fontsize=14, fontweight='bold', y=0.98)
plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.savefig('viz_digit_frequencies.png', dpi=150, bbox_inches='tight')
print("Saved viz_digit_frequencies.png")


"""
Visualization: Fourier Spectral Obstruction Analysis

Plots the magnitude of Fourier modes |c_m| = |N^{-1} Σ exp(2πi·m·frac(log_b(u_k)))|
for several sequences. Benford sequences have decaying Fourier modes
(spectral flatness), while obstructed sequences show persistent peaks
(rational resonance).

This visualization makes the spectral obstruction theory concrete:
the dichotomy between Benford and non-Benford behavior is visible
as the presence or absence of spectral peaks.
"""

import math
import matplotlib.pyplot as plt
import numpy as np


def frac_log(x, base=10):
    if x <= 0:
        return 0.0
    v = math.log(x) / math.log(base)
    return v - math.floor(v)


def fourier_magnitudes(data, base=10, max_m=30):
    """Compute |c_m| for m = 1, ..., max_m."""
    N = len(data)
    if N == 0:
        return []
    mags = []
    for m in range(1, max_m + 1):
        total = sum(
            complex(math.cos(2 * math.pi * m * frac_log(x, base)),
                    math.sin(2 * math.pi * m * frac_log(x, base)))
            for x in data if x >= 1
        )
        mags.append(abs(total / N))
    return mags


# Generate sequences
pow2 = [2**k for k in range(1, 2001)]
pow3 = [3**k for k in range(1, 1001)]
pow10 = [10**k for k in range(1, 201)]
pow100 = [100**k for k in range(1, 101)]

fib = [1, 1]
for _ in range(2000):
    fib.append(fib[-1] + fib[-2])
fibonacci = fib[10:]

# 3^k * 2^k = 6^k (rational in base 10? No, log10(6) is irrational)
pow6 = [6**k for k in range(1, 501)]

max_m = 25
datasets = [
    ('Powers of 2 (Benford)', pow2, '#27ae60'),
    ('Powers of 3 (Benford)', pow3, '#2980b9'),
    ('Fibonacci (Benford)', fibonacci[:1000], '#8e44ad'),
    ('Powers of 6 (Benford)', pow6, '#e67e22'),
    ('Powers of 10 (Obstructed)', pow10, '#c0392b'),
    ('Powers of 100 (Obstructed)', pow100, '#e74c3c'),
]

fig, axes = plt.subplots(2, 3, figsize=(15, 9))
axes_flat = axes.flatten()

for idx, (title, data, color) in enumerate(datasets):
    ax = axes_flat[idx]
    mags = fourier_magnitudes(data, 10, max_m)
    modes = list(range(1, max_m + 1))

    ax.bar(modes, mags, color=color, alpha=0.8, edgecolor='white', linewidth=0.5)
    ax.axhline(y=0.1, color='gray', linewidth=1, linestyle='--', alpha=0.5)
    ax.set_title(title, fontsize=10, fontweight='bold')
    ax.set_xlabel('Fourier mode m')
    ax.set_ylabel('|cₘ|')
    ax.set_ylim(0, 1.05)

    # Highlight obstruction threshold
    max_mag = max(mags) if mags else 0
    if max_mag > 0.5:
        ax.text(max_m * 0.6, 0.9, '⚠ OBSTRUCTION',
                fontsize=9, color='red', fontweight='bold',
                bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))
    else:
        ax.text(max_m * 0.6, 0.9, '✓ Flat spectrum',
                fontsize=9, color='green', fontweight='bold',
                bbox=dict(boxstyle='round', facecolor='honeydew', alpha=0.8))

fig.suptitle('Fourier Spectral Analysis: Detecting Rational Obstruction',
             fontsize=14, fontweight='bold', y=0.98)
plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.savefig('viz_fourier_spectrum.png', dpi=150, bbox_inches='tight')
print("Saved viz_fourier_spectrum.png")


"""
Visualization: Fractional Logarithm Cocycle

Plots the fractional parts frac(log_10(u_k)) for several sequences,
revealing the equidistribution (or lack thereof) that controls Benford
behavior. For irrational rotations, the points fill [0,1) uniformly.
For rational obstructions, they cluster on a finite set.
"""

import math
import matplotlib.pyplot as plt
import numpy as np


def frac_log(x, base=10):
    if x <= 0:
        return 0.0
    v = math.log(x) / math.log(base)
    return v - math.floor(v)


# Generate sequences
N = 500

# Powers of 2: frac(k * log10(2)) — irrational rotation
pow2_frac = [frac_log(2**k) for k in range(1, N+1)]

# Powers of 3: frac(k * log10(3)) — irrational rotation
pow3_frac = [frac_log(3**k) for k in range(1, N+1)]

# Powers of 10: frac(k * log10(10)) = frac(k) = 0 — rational obstruction
pow10_frac = [frac_log(10**k) for k in range(1, N+1)]

# Fibonacci: frac(log10(F_k)) ≈ frac(k*log10(φ) + const) — irrational
fib = [1, 1]
for _ in range(N + 10):
    fib.append(fib[-1] + fib[-2])
fib_frac = [frac_log(fib[k]) for k in range(10, N+10)]

# 3n+1 orbit from seed 7
x = 7
collatz_orbit = [x]
for _ in range(N):
    x = x // 2 if x % 2 == 0 else 3 * x + 1
    collatz_orbit.append(x)
collatz_frac = [frac_log(v) for v in collatz_orbit if v > 0]

fig, axes = plt.subplots(2, 3, figsize=(15, 9))

datasets = [
    ('Powers of 2: frac(k·log₁₀(2))', pow2_frac, '#27ae60'),
    ('Powers of 3: frac(k·log₁₀(3))', pow3_frac, '#2980b9'),
    ('Powers of 10 (OBSTRUCTED)', pow10_frac, '#c0392b'),
    ('Fibonacci: frac(log₁₀(Fₖ))', fib_frac, '#8e44ad'),
    ('Collatz orbit (seed=7)', collatz_frac[:N], '#e67e22'),
]

for idx, (title, data, color) in enumerate(datasets):
    row, col = divmod(idx, 3)
    ax = axes[row][col]

    # Scatter plot of fractional parts
    ax.scatter(range(len(data)), data, s=1.5, c=color, alpha=0.6)
    ax.set_title(title, fontsize=10, fontweight='bold')
    ax.set_xlabel('Index k')
    ax.set_ylabel('frac(log₁₀(uₖ))')
    ax.set_ylim(-0.05, 1.05)
    ax.axhline(y=0, color='gray', linewidth=0.5, linestyle='--')
    ax.axhline(y=1, color='gray', linewidth=0.5, linestyle='--')

    # Add Benford digit boundaries
    for d in range(1, 10):
        boundary = math.log10(d)
        if 0 < boundary < 1:
            ax.axhline(y=boundary, color='lightgray', linewidth=0.3)

# Last panel: histogram comparison
ax = axes[1][2]
bins = np.linspace(0, 1, 51)
ax.hist(pow2_frac, bins=bins, alpha=0.6, density=True,
        label='2ᵏ', color='#27ae60')
ax.hist(pow10_frac, bins=bins, alpha=0.8, density=True,
        label='10ᵏ', color='#c0392b')
ax.axhline(y=1.0, color='black', linewidth=1.5, linestyle='--',
           label='Uniform')
ax.set_title('Histogram: Equidistributed vs Obstructed', fontsize=10,
             fontweight='bold')
ax.set_xlabel('frac(log₁₀(uₖ))')
ax.set_ylabel('Density')
ax.legend(fontsize=8)

fig.suptitle('The Logarithmic Cocycle: Equidistribution vs Rational Obstruction',
             fontsize=13, fontweight='bold', y=0.98)
plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.savefig('viz_fractional_log.png', dpi=150, bbox_inches='tight')
print("Saved viz_fractional_log.png")
