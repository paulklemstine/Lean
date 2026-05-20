#!/usr/bin/env python3
"""
applications.py — Real-World Applications of Arithmetic Phase Locking

Demonstrates practical applications of the arithmetic phase locking theory
to optimization diagnostics, system design, and trainability analysis.

Applications:
    1. Trainability Diagnostic: Detect resonant optimization configurations
    2. Learning Rate Selector: Find rates that avoid arithmetic locking
    3. Quadratic Loss Analyzer: Full spectral-arithmetic analysis
    4. Finite-Field Orbit Visualizer: ASCII visualization of orbits
"""

from __future__ import annotations

import math
from fractions import Fraction


def sieve_primes(bound: int) -> list[int]:
    """Return all primes up to bound."""
    if bound < 2:
        return []
    sieve = [True] * (bound + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(bound**0.5) + 1):
        if sieve[i]:
            for j in range(i * i, bound + 1, i):
                sieve[j] = False
    return [i for i in range(bound + 1) if sieve[i]]


def orbit_period_1d(a: int, b: int, x0: int, p: int) -> tuple[int, int]:
    """Compute (preperiod, period) of T(y) = a*y + b mod p from x0."""
    visited = {}
    x = x0 % p
    for t in range(p + 1):
        if x in visited:
            return visited[x], t - visited[x]
        visited[x] = t
        x = (a * x + b) % p
    return p, 1


# ─────────────────────────────────────────────────────────────
# Application 1: Trainability Diagnostic
# ─────────────────────────────────────────────────────────────

class TrainabilityDiagnostic:
    """
    Diagnose potential training issues by detecting arithmetic phase locking.

    For a 1D quadratic loss L(w) = (1/2)*A*w^2 + B*w + C with learning rate eta,
    the GD update is T(w) = (1 - eta*A)*w - eta*B.

    If 1 - eta*A is a root of unity (i.e., eta*A in {0, 2}), training may
    oscillate forever. This diagnostic detects this condition.
    """

    def __init__(self, A: Fraction, B: Fraction, eta: Fraction):
        self.A = A
        self.B = B
        self.eta = eta
        self.propagator = Fraction(1) - eta * A
        self.translation = -eta * B

    def diagnose(self) -> dict:
        """Run the trainability diagnostic."""
        prop = self.propagator
        trans = self.translation

        # Check spectral torsion
        if prop == 1:
            torsion = "TRIVIAL"
            order = 1
            verdict = ("STAGNANT: Propagator = 1 means eta*A = 0. "
                       "Gradient step has no effect on curvature direction.")
        elif prop == -1:
            torsion = "OSCILLATING"
            order = 2
            geom = 1 + prop  # = 0
            if geom * trans == 0:
                verdict = ("LOCKED: Period-2 oscillation. Training will never "
                           "converge; it will alternate between two points forever.")
            else:
                verdict = ("QUASI-LOCKED: Propagator has order 2 but translation "
                           "breaks exact periodicity. Orbit is eventually periodic "
                           "with period 2 in some coordinate.")
        else:
            torsion = "GENERIC"
            order = None
            if abs(prop) < 1:
                verdict = ("CONVERGENT (classical): |propagator| < 1, so "
                           "classical analysis predicts convergence to the minimum.")
            elif abs(prop) > 1:
                verdict = ("DIVERGENT (classical): |propagator| > 1, so "
                           "classical analysis predicts divergence.")
            else:
                verdict = "MARGINAL: |propagator| = 1 but not ±1."

        return {
            "A": str(self.A),
            "B": str(self.B),
            "eta": str(self.eta),
            "propagator": str(prop),
            "translation": str(trans),
            "torsion_type": torsion,
            "torsion_order": order,
            "verdict": verdict,
        }


# ─────────────────────────────────────────────────────────────
# Application 2: Learning Rate Selector
# ─────────────────────────────────────────────────────────────

class LearningRateSelector:
    """
    Select learning rates that avoid arithmetic phase locking.

    For a quadratic loss with curvature A, the critical rates are:
    - eta = 0: trivial (no update)
    - eta = 2/A: period-2 oscillation
    The selector identifies these and recommends safe alternatives.
    """

    def __init__(self, A: Fraction):
        self.A = A

    def critical_rates(self) -> list[dict]:
        """Return the critical (locking) learning rates."""
        rates = []
        if self.A != 0:
            rates.append({
                "eta": str(Fraction(2, 1) / self.A),
                "propagator": "-1",
                "type": "Period-2 oscillation",
                "danger": "HIGH"
            })
        rates.append({
            "eta": "0",
            "propagator": "1",
            "type": "No update (trivial fixed point)",
            "danger": "TRIVIAL"
        })
        return rates

    def safe_range(self) -> tuple[str, str]:
        """Return the classical convergence range (0, 2/A)."""
        if self.A > 0:
            return ("0", str(Fraction(2, 1) / self.A))
        elif self.A < 0:
            return (str(Fraction(2, 1) / self.A), "0")
        else:
            return ("any", "any")

    def recommend(self) -> str:
        """Recommend a learning rate."""
        if self.A > 0:
            # Optimal for quadratic: eta = 1/A (midpoint of convergence range)
            optimal = Fraction(1, 1) / self.A
            return (f"Recommended: eta = {optimal} (= 1/A). "
                    f"This gives propagator = 0, one-step convergence. "
                    f"Avoid eta = {Fraction(2,1)/self.A} (oscillation).")
        elif self.A < 0:
            return "Loss is concave (A < 0). GD will diverge from minimum."
        else:
            return "A = 0: loss is linear, GD will not converge to a finite point."


# ─────────────────────────────────────────────────────────────
# Application 3: Quadratic Loss Analyzer
# ─────────────────────────────────────────────────────────────

class QuadraticLossAnalyzer:
    """
    Complete spectral-arithmetic analysis of a quadratic loss.
    Combines classical convergence theory with arithmetic phase locking.
    """

    def __init__(self, A: Fraction, B: Fraction, C: Fraction, eta: Fraction):
        self.A = A
        self.B = B
        self.C = C
        self.eta = eta

    def classical_analysis(self) -> dict:
        """Classical convergence analysis."""
        prop = 1 - self.eta * self.A
        minimum = -self.B / self.A if self.A != 0 else None
        converges = abs(prop) < 1

        return {
            "minimum": str(minimum) if minimum is not None else "none",
            "propagator": str(prop),
            "propagator_abs": str(abs(prop)),
            "converges": converges,
            "convergence_rate": str(abs(prop)) if converges else "divergent",
        }

    def arithmetic_analysis(self, prime_bound: int = 200) -> dict:
        """Arithmetic phase locking analysis."""
        # Integer model: clear denominators
        prop = 1 - self.eta * self.A
        trans = -self.eta * self.B

        # Convert to integers if possible
        if prop.denominator == 1 and trans.denominator == 1:
            a_int = int(prop)
            b_int = int(trans)
        else:
            # Scale to clear denominators
            lcm_den = math.lcm(prop.denominator, trans.denominator)
            a_int = int(prop * lcm_den)
            b_int = int(trans * lcm_den)

        # Check torsion
        if a_int == 1:
            torsion_order = 1
        elif a_int == -1:
            torsion_order = 2
        else:
            torsion_order = None

        # Compute orbit periods
        primes = sieve_primes(prime_bound)
        periods = {}
        for p in primes:
            _, period = orbit_period_1d(a_int, b_int, 0, p)
            periods[p] = period

        return {
            "integer_model": f"T(w) = {a_int}*w + ({b_int})",
            "torsion_order": torsion_order,
            "is_locked": torsion_order is not None and (
                sum(a_int**k for k in range(torsion_order)) * b_int == 0
                if torsion_order else False),
            "sample_periods": dict(list(periods.items())[:15]),
            "max_period": max(periods.values()) if periods else 0,
            "min_period": min(periods.values()) if periods else 0,
        }

    def full_report(self, prime_bound: int = 200) -> str:
        """Generate a complete analysis report."""
        classical = self.classical_analysis()
        arithmetic = self.arithmetic_analysis(prime_bound)

        lines = [
            f"╔══════════════════════════════════════════════════════╗",
            f"║  Quadratic Loss Analysis Report                     ║",
            f"╚══════════════════════════════════════════════════════╝",
            f"",
            f"Loss: L(w) = ({self.A}/2)*w² + ({self.B})*w + ({self.C})",
            f"Learning rate: η = {self.eta}",
            f"Update: T(w) = ({1 - self.eta * self.A})*w + ({-self.eta * self.B})",
            f"",
            f"── Classical Analysis ──",
            f"  Minimum at: w* = {classical['minimum']}",
            f"  Propagator: {classical['propagator']}",
            f"  |Propagator|: {classical['propagator_abs']}",
            f"  Converges: {classical['converges']}",
            f"",
            f"── Arithmetic Analysis ──",
            f"  Integer model: {arithmetic['integer_model']}",
            f"  Torsion order: {arithmetic['torsion_order']}",
            f"  Phase locked: {arithmetic['is_locked']}",
            f"  Period range: [{arithmetic['min_period']}, {arithmetic['max_period']}]",
            f"  Sample periods by prime: {arithmetic['sample_periods']}",
        ]
        return "\n".join(lines)


# ─────────────────────────────────────────────────────────────
# Application 4: ASCII Orbit Visualizer
# ─────────────────────────────────────────────────────────────

def visualize_orbit_ascii(a: int, b: int, x0: int, p: int,
                          max_display: int = 40) -> str:
    """
    Create an ASCII visualization of the orbit of x0 under T(y) = a*y + b mod p.
    """
    lines = [f"Orbit of x₀={x0} under T(y)={a}y+{b} mod {p}:"]

    visited = {}
    trajectory = []
    x = x0 % p

    for t in range(min(p + 1, max_display)):
        if x in visited:
            mu = visited[x]
            period = t - mu
            # Draw the orbit
            lines.append("")
            for i, val in enumerate(trajectory):
                bar = "█" * (val * 40 // p)
                if i < mu:
                    marker = "→"  # tail
                elif i == mu:
                    marker = "⟳"  # cycle start
                else:
                    marker = "○"  # cycle body
                lines.append(f"  t={i:3d} {marker} {val:4d} |{bar}")

            lines.append(f"  [preperiod={mu}, period={period}]")
            return "\n".join(lines)

        visited[x] = t
        trajectory.append(x)
        x = (a * x + b) % p

    lines.append(f"  (orbit did not close within {max_display} steps)")
    return "\n".join(lines)


# ─────────────────────────────────────────────────────────────
# Main: run all applications
# ─────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 60)
    print("APPLICATION 1: Trainability Diagnostic")
    print("=" * 60)

    scenarios = [
        (Fraction(2), Fraction(3), Fraction(1)),     # eta*A = 2, oscillating
        (Fraction(4), Fraction(5), Fraction(1, 2)),   # eta*A = 2, oscillating
        (Fraction(1), Fraction(3), Fraction(1, 2)),   # eta*A = 1/2, converging
        (Fraction(1), Fraction(3), Fraction(3)),       # eta*A = 3, diverging
    ]

    for A, B, eta in scenarios:
        diag = TrainabilityDiagnostic(A, B, eta)
        result = diag.diagnose()
        print(f"\n  A={result['A']}, B={result['B']}, η={result['eta']}")
        print(f"  Propagator: {result['propagator']}")
        print(f"  Torsion: {result['torsion_type']}")
        print(f"  → {result['verdict']}")

    print("\n" + "=" * 60)
    print("APPLICATION 2: Learning Rate Selection")
    print("=" * 60)

    for A_val in [Fraction(2), Fraction(5), Fraction(1, 3)]:
        selector = LearningRateSelector(A_val)
        print(f"\n  Curvature A = {A_val}")
        print(f"  Critical rates: {selector.critical_rates()}")
        safe = selector.safe_range()
        print(f"  Safe range: ({safe[0]}, {safe[1]})")
        print(f"  {selector.recommend()}")

    print("\n" + "=" * 60)
    print("APPLICATION 3: Full Quadratic Loss Analysis")
    print("=" * 60)

    # Oscillating case
    analyzer = QuadraticLossAnalyzer(
        A=Fraction(2), B=Fraction(3), C=Fraction(1), eta=Fraction(1)
    )
    print(analyzer.full_report())

    # Converging case
    print()
    analyzer2 = QuadraticLossAnalyzer(
        A=Fraction(2), B=Fraction(3), C=Fraction(1), eta=Fraction(1, 2)
    )
    print(analyzer2.full_report())

    print("\n" + "=" * 60)
    print("APPLICATION 4: Orbit Visualization")
    print("=" * 60)

    # Locked orbit
    print("\n" + visualize_orbit_ascii(-1, 4, 0, 17))

    # Unlocked orbit
    print("\n" + visualize_orbit_ascii(2, 1, 0, 17))

    # Larger prime
    print("\n" + visualize_orbit_ascii(-1, 6, 3, 23))


#!/usr/bin/env python3
"""
demo.py — Arithmetic Phase Locking in Gradient Descent

Interactive demonstration of modular phase locking for affine gradient systems.
Reduces gradient descent maps modulo primes and visualizes orbit structures,
period distributions, and locking diagnostics.

Usage:
    python demo.py
"""

import math
from collections import Counter


def is_prime(n: int) -> bool:
    """Check if n is prime."""
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


def primes_up_to(bound: int) -> list[int]:
    """Return all primes up to bound using sieve of Eratosthenes."""
    if bound < 2:
        return []
    sieve = [True] * (bound + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(bound**0.5) + 1):
        if sieve[i]:
            for j in range(i * i, bound + 1, i):
                sieve[j] = False
    return [i for i in range(2, bound + 1) if sieve[i]]


def orbit_period_1d(a: int, b: int, x0: int, p: int) -> tuple[int, int]:
    """
    Compute the preperiod (mu) and period of the orbit of x0
    under T(y) = a*y + b (mod p).

    Returns (mu, period).
    """
    visited = {}
    x = x0 % p
    for t in range(p + 1):
        if x in visited:
            mu = visited[x]
            period = t - mu
            return mu, period
        visited[x] = t
        x = (a * x + b) % p
    # Should not reach here for p prime
    return p, 1


def detect_spectral_torsion_1d(a: int) -> int | None:
    """
    Detect if a is a root of unity in Z (i.e., a in {1, -1}).
    Returns the order m if torsion, None otherwise.
    """
    if a == 1:
        return 1
    elif a == -1:
        return 2
    else:
        return None


def geom_sum(a: int, m: int) -> int:
    """Compute sum_{k=0}^{m-1} a^k."""
    return sum(a**k for k in range(m))


def check_locking_condition_1d(a: int, b: int) -> tuple[bool, int | None]:
    """
    Check if the 1D affine map T(y) = a*y + b satisfies the
    spectral torsion phase locking condition.

    Returns (is_locked, period_or_None).
    """
    m = detect_spectral_torsion_1d(a)
    if m is None:
        return False, None
    gs = geom_sum(a, m)
    if gs * b == 0:
        return True, m
    return False, None


def demo_phase_locking_1d():
    """Demonstrate 1D arithmetic phase locking."""
    print("=" * 70)
    print("DEMO 1: 1D Arithmetic Phase Locking")
    print("=" * 70)

    # Example 1: Locked system (a=-1, b=4)
    a, b = -1, 4
    locked, m = check_locking_condition_1d(a, b)
    print(f"\nMap T(y) = {a}*y + {b}")
    print(f"Spectral torsion: a^2 = {a**2}, "
          f"geom sum = {geom_sum(a, 2)}, "
          f"geom_sum * b = {geom_sum(a, 2) * b}")
    print(f"Phase locked: {locked}, period: {m}")

    print(f"\nVerification across primes:")
    primes = primes_up_to(100)
    for p in primes[:15]:
        mu, period = orbit_period_1d(a, b, 0, p)
        print(f"  p = {p:3d}: preperiod = {mu}, period = {period}, "
              f"locked to {m}: {period <= m if m else 'N/A'}")

    # Example 2: Non-locked system (a=2, b=1)
    a, b = 2, 1
    locked, m = check_locking_condition_1d(a, b)
    print(f"\nMap T(y) = {a}*y + {b}")
    print(f"Spectral torsion: None (a={a} is not a root of unity)")
    print(f"Phase locked: {locked}")

    print(f"\nOrbit periods across primes (no universal locking):")
    periods = []
    for p in primes:
        mu, period = orbit_period_1d(a, b, 0, p)
        periods.append(period)
        if p <= 50:
            print(f"  p = {p:3d}: preperiod = {mu}, period = {period}")

    print(f"\n  Period statistics: min={min(periods)}, max={max(periods)}, "
          f"mean={sum(periods)/len(periods):.1f}")


def demo_period_distribution():
    """Show period distributions for locked vs unlocked systems."""
    print("\n" + "=" * 70)
    print("DEMO 2: Period Distributions — Locked vs Unlocked")
    print("=" * 70)

    primes = primes_up_to(1000)

    # Locked: a=-1, b=6
    print("\nLocked system: T(y) = -y + 6")
    periods_locked = []
    for p in primes:
        _, period = orbit_period_1d(-1, 6, 0, p)
        periods_locked.append(period)

    counter = Counter(periods_locked)
    print(f"  Period distribution: {dict(counter)}")
    print(f"  All periods ≤ 2: {all(per <= 2 for per in periods_locked)}")

    # Unlocked: a=3, b=1
    print("\nUnlocked system: T(y) = 3y + 1")
    periods_unlocked = []
    for p in primes:
        _, period = orbit_period_1d(3, 1, 0, p)
        periods_unlocked.append(period)

    print(f"  Period statistics: min={min(periods_unlocked)}, "
          f"max={max(periods_unlocked)}, "
          f"mean={sum(periods_unlocked)/len(periods_unlocked):.1f}")
    print(f"  Number of distinct periods: {len(set(periods_unlocked))}")

    # Histogram
    print(f"\n  Period histogram (buckets):")
    buckets = [0, 1, 2, 5, 10, 50, 100, 500, 1000]
    for i in range(len(buckets) - 1):
        count = sum(1 for per in periods_unlocked
                    if buckets[i] < per <= buckets[i + 1])
        bar = "#" * count
        print(f"    ({buckets[i]:4d}, {buckets[i+1]:4d}]: {count:3d} {bar}")


def demo_multidim_affine():
    """Demonstrate multi-dimensional affine phase locking (2D)."""
    print("\n" + "=" * 70)
    print("DEMO 3: 2D Affine Phase Locking")
    print("=" * 70)

    # 2D affine map: T(x, y) = M*(x,y) + b
    # M = [[-1, 0], [0, -1]] (order 2), b = [2, 4]
    # M^2 = I, geom sum (I + M) = 0, so (I + M)*b = 0
    # Phase locked with period 2

    print("\nMap: T(x,y) = (-x+2, -y+4)")
    print("Matrix M = -I (order 2), b = (2, 4)")
    print("Geom sum: (I + M) * b = (0,0) * (2,4) = (0,0) ✓")

    primes = primes_up_to(200)
    all_locked = True
    for p in primes:
        # Iterate T on (0, 0) mod p
        x, y = 0, 0
        visited = {}
        for t in range(p * p + 1):
            state = (x, y)
            if state in visited:
                mu = visited[state]
                period = t - mu
                if period > 2:
                    all_locked = False
                if p <= 20:
                    print(f"  p = {p:3d}: period = {period}, divides 2: {period <= 2}")
                break
            visited[state] = t
            x, y = (-x + 2) % p, (-y + 4) % p

    print(f"\n  All primes: period divides 2: {all_locked}")


def demo_quadratic_loss():
    """
    Demonstrate connection to quadratic loss optimization.
    L(w) = (1/2) * A * w^2 + B * w + C
    T(w) = (1 - eta*A) * w - eta * B
    """
    print("\n" + "=" * 70)
    print("DEMO 4: Quadratic Loss and Gradient Descent")
    print("=" * 70)

    print("\nQuadratic loss: L(w) = (1/2)*A*w² + B*w + C")
    print("Gradient descent: T(w) = (1 - η*A)*w - η*B")

    scenarios = [
        {"A": 2, "eta_num": 1, "eta_den": 1, "B": 3, "name": "η*A = 2 (oscillating)"},
        {"A": 4, "eta_num": 1, "eta_den": 2, "B": 5, "name": "η*A = 2 (oscillating)"},
        {"A": 1, "eta_num": 1, "eta_den": 2, "B": 3, "name": "η*A = 1/2 (no torsion)"},
    ]

    primes = primes_up_to(100)

    for sc in scenarios:
        A = sc["A"]
        eta_n, eta_d = sc["eta_num"], sc["eta_den"]
        B = sc["B"]
        # a = 1 - eta*A = (eta_d - eta_n*A) / eta_d
        # For integer maps, multiply through by eta_d
        # T_int(w_scaled) = (eta_d - eta_n*A) * w_scaled - eta_n * B * eta_d
        a_int = eta_d - eta_n * A
        b_int = -eta_n * B

        locked, m = check_locking_condition_1d(a_int, b_int)

        print(f"\n  {sc['name']}")
        print(f"  A={A}, η={eta_n}/{eta_d}, B={B}")
        print(f"  Propagator a = 1 - η*A = {a_int}/{eta_d}")
        print(f"  Integer model: T(w) = {a_int}*w + ({b_int})")
        print(f"  Spectral torsion: {detect_spectral_torsion_1d(a_int)}")
        print(f"  Phase locked: {locked}" +
              (f" with period {m}" if locked else ""))

        # Sample orbit periods
        sample_periods = []
        for p in primes[:10]:
            _, period = orbit_period_1d(a_int, b_int, 0, p)
            sample_periods.append((p, period))
        print(f"  Sample periods: {sample_periods[:8]}")


def demo_locking_density():
    """
    Compute the empirical locking density: fraction of primes
    where orbit period ≤ threshold.
    """
    print("\n" + "=" * 70)
    print("DEMO 5: Locking Density Analysis")
    print("=" * 70)

    primes = primes_up_to(5000)
    maps_to_test = [
        (-1, 4, "T(y) = -y + 4 (locked, a=-1)"),
        (1, 5, "T(y) = y + 5 (a=1, shift)"),
        (2, 1, "T(y) = 2y + 1 (no torsion)"),
        (3, 7, "T(y) = 3y + 7 (no torsion)"),
        (-1, 0, "T(y) = -y (locked, trivial)"),
    ]

    for a, b, name in maps_to_test:
        periods = []
        for p in primes:
            _, period = orbit_period_1d(a, b, 0, p)
            periods.append(period)

        thresholds = [2, 5, 10, 50]
        densities = {t: sum(1 for per in periods if per <= t) / len(periods)
                     for t in thresholds}

        print(f"\n  {name}")
        for t in thresholds:
            bar = "█" * int(densities[t] * 40)
            print(f"    Period ≤ {t:3d}: {densities[t]:.4f} {bar}")


def main():
    """Run all demonstrations."""
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║   Arithmetic Phase Locking in Gradient Descent — Demo Suite    ║")
    print("╚══════════════════════════════════════════════════════════════════╝")

    demo_phase_locking_1d()
    demo_period_distribution()
    demo_multidim_affine()
    demo_quadratic_loss()
    demo_locking_density()

    print("\n" + "=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)


if __name__ == "__main__":
    main()
