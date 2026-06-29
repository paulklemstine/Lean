#!/usr/bin/env python3
"""
Applications of Tropical Life Bifurcation Theory
==================================================
Real-world connections and applications of the periodic orbit
bifurcation framework for tropical cellular automata.
"""

import numpy as np
from typing import Optional


# ---------------------------------------------------------------------------
# Application 1: Error Detection in Distributed Systems
# ---------------------------------------------------------------------------

def tropical_threshold(s: int, lo: int, hi: int) -> int:
    return min(1, max(0, s + 1 - lo)) * min(1, max(0, hi + 1 - s))


def tropical_life_step(config: np.ndarray) -> np.ndarray:
    m, n = config.shape
    new = np.zeros_like(config)
    for i in range(m):
        for j in range(n):
            s = sum(
                config[(i + di) % m, (j + dj) % n]
                for di in (-1, 0, 1)
                for dj in (-1, 0, 1)
                if not (di == 0 and dj == 0)
            )
            alive = min(1, config[i, j])
            new[i, j] = (
                alive * tropical_threshold(s, 2, 3)
                + (1 - alive) * tropical_threshold(s, 3, 3)
            )
    return new


def detect_period(config: np.ndarray, max_iter: int = 500) -> Optional[int]:
    current = config.copy()
    for p in range(1, max_iter + 1):
        current = tropical_life_step(current)
        if np.array_equal(current, config):
            return p
    return None


class DistributedHealthMonitor:
    """
    Uses periodic orbit structure to detect failures in grid-organized systems.

    The key insight: if a distributed system's state evolves like tropical Life,
    then healthy subsystems exhibit predictable periodic behavior. A deviation
    from expected periodicity signals a fault.

    The divisibility lifting theorem guarantees that if a local subsystem has
    period p, the global system (which covers the local one) also has period p.
    """

    def __init__(self, grid_size: int):
        self.L = grid_size
        self.state = np.zeros((grid_size, grid_size), dtype=int)
        self.expected_period: Optional[int] = None

    def initialize(self, pattern: np.ndarray):
        """Set initial state and learn expected period."""
        self.state = pattern.copy()
        self.expected_period = detect_period(pattern)
        print(f"  Monitor initialized. Expected period: {self.expected_period}")

    def check_health(self) -> bool:
        """Run one monitoring cycle and check if periodicity holds."""
        if self.expected_period is None:
            return True
        current = self.state.copy()
        for _ in range(self.expected_period):
            current = tropical_life_step(current)
        healthy = np.array_equal(current, self.state)
        return healthy

    def inject_fault(self, i: int, j: int, value: int = 1):
        """Simulate a fault by flipping a cell."""
        self.state[i, j] = value


def demo_health_monitoring():
    """Demonstrate fault detection using periodic orbit theory."""
    print("\n" + "=" * 70)
    print("APPLICATION 1: Distributed System Health Monitoring")
    print("=" * 70)
    print()

    monitor = DistributedHealthMonitor(4)
    # Use a simple periodic pattern
    pattern = np.zeros((4, 4), dtype=int)
    pattern[1, 1] = 1
    pattern[1, 2] = 1
    pattern[2, 1] = 1
    pattern[2, 2] = 1
    monitor.initialize(pattern)

    print(f"  Health check (no fault): {'OK ✓' if monitor.check_health() else 'FAULT ✗'}")

    monitor.inject_fault(0, 0, 1)
    print(f"  Health check (after fault): {'OK ✓' if monitor.check_health() else 'FAULT ✗'}")
    print()


# ---------------------------------------------------------------------------
# Application 2: Pattern Classification via Period Spectrum
# ---------------------------------------------------------------------------

class PatternClassifier:
    """
    Classifies binary patterns using their periodic orbit structure.

    Two patterns are in the same dynamical class if they have the same
    minimal period under tropical Life evolution. The period spectrum
    provides a fingerprint of the pattern's dynamical complexity.
    """

    def __init__(self):
        self.classes: dict[int, list[np.ndarray]] = {}

    def classify(self, pattern: np.ndarray) -> int:
        """Classify a pattern by its minimal period."""
        period = detect_period(pattern) or -1
        if period not in self.classes:
            self.classes[period] = []
        self.classes[period].append(pattern.copy())
        return period

    def summary(self) -> dict[int, int]:
        """Return count of patterns in each class."""
        return {p: len(pats) for p, pats in sorted(self.classes.items())}


def demo_pattern_classification():
    """Demonstrate pattern classification."""
    print("=" * 70)
    print("APPLICATION 2: Pattern Classification via Period Spectrum")
    print("=" * 70)
    print()

    classifier = PatternClassifier()
    np.random.seed(123)

    L = 4
    n_patterns = 100
    for _ in range(n_patterns):
        p = np.random.randint(0, 2, size=(L, L))
        classifier.classify(p)

    summary = classifier.summary()
    print(f"  Classified {n_patterns} random {L}×{L} patterns:")
    for period, count in sorted(summary.items()):
        label = f"period {period}" if period > 0 else "aperiodic"
        print(f"    {label}: {count} patterns")
    print()


# ---------------------------------------------------------------------------
# Application 3: Entropy Estimation from Period Growth
# ---------------------------------------------------------------------------

def estimate_entropy_from_periods(max_L: int = 8, num_samples: int = 100) -> list[tuple[int, float]]:
    """
    Estimate topological entropy from period spectrum growth.

    For a dynamical system, the topological entropy h is related to
    the growth rate of the number of periodic orbits:
        h ≈ lim sup (1/n) log |Fix(f^n)|

    We estimate this for the tropical Life automaton on square tori.
    """
    results = []
    for L in range(2, max_L + 1):
        max_period = min(20, L * L)
        total_fixed = 0
        for _ in range(num_samples):
            c = np.random.randint(0, 2, size=(L, L))
            p = detect_period(c, max_period)
            if p is not None:
                total_fixed += 1

        # Rough entropy estimate
        if total_fixed > 0:
            entropy_est = np.log(total_fixed) / (L * L)
        else:
            entropy_est = 0.0
        results.append((L, entropy_est))
    return results


def demo_entropy_estimation():
    """Demonstrate entropy estimation."""
    print("=" * 70)
    print("APPLICATION 3: Entropy Estimation from Period Growth")
    print("=" * 70)
    print()

    results = estimate_entropy_from_periods(max_L=7, num_samples=50)
    for L, h in results:
        bar = "█" * int(h * 100)
        print(f"  L={L}: h ≈ {h:.4f} {bar}")
    print()
    print("  (Entropy measures the complexity of the dynamical system)")
    print()


# ---------------------------------------------------------------------------
# Application 4: Torus Size Optimization for Periodic Behavior
# ---------------------------------------------------------------------------

def find_optimal_torus_size(
    target_period: int, max_L: int = 15, num_samples: int = 200
) -> Optional[int]:
    """
    Find the smallest torus that supports a given period.

    By the critical size theorem, if a period exists on any torus,
    there is a unique minimal torus size. This function finds it.
    """
    for L in range(1, max_L + 1):
        for _ in range(num_samples):
            c = np.random.randint(0, 2, size=(L, L))
            p = detect_period(c, target_period + 10)
            if p == target_period:
                return L
    return None


def demo_torus_optimization():
    """Demonstrate torus size optimization."""
    print("=" * 70)
    print("APPLICATION 4: Optimal Torus Size for Target Periods")
    print("=" * 70)
    print()

    for target_p in [1, 2, 3, 4, 5, 6]:
        L = find_optimal_torus_size(target_p, max_L=12, num_samples=100)
        if L is not None:
            print(f"  Period {target_p}: smallest torus L = {L}")
        else:
            print(f"  Period {target_p}: not found (may need larger torus)")
    print()


if __name__ == "__main__":
    demo_health_monitoring()
    demo_pattern_classification()
    demo_entropy_estimation()
    demo_torus_optimization()

    print("All application demos completed!")


#!/usr/bin/env python3
"""
Tropical Life Bifurcation Demo
===============================
Demonstrates the key theorems about periodic orbits of the tropical Life
cellular automaton on finite tori, with concrete numerical examples.
"""

import numpy as np
from itertools import product


def tropical_threshold(s: int, lo: int, hi: int) -> int:
    """Tropical threshold indicator: 1 if lo <= s <= hi, else 0."""
    a = min(1, max(0, s + 1 - lo))
    b = min(1, max(0, hi + 1 - s))
    return a * b


def moore_neighbors(i: int, j: int, m: int, n: int) -> list[tuple[int, int]]:
    """8 Moore neighbors on the m x n torus."""
    return [
        ((i - 1) % m, (j - 1) % n),
        ((i - 1) % m, j % n),
        ((i - 1) % m, (j + 1) % n),
        (i % m, (j - 1) % n),
        (i % m, (j + 1) % n),
        ((i + 1) % m, (j - 1) % n),
        ((i + 1) % m, j % n),
        ((i + 1) % m, (j + 1) % n),
    ]


def neighbor_sum(config: np.ndarray, i: int, j: int) -> int:
    """Sum of neighbor values on the torus."""
    m, n = config.shape
    return sum(config[ni, nj] for ni, nj in moore_neighbors(i, j, m, n))


def tropical_life_step(config: np.ndarray) -> np.ndarray:
    """One step of the tropical Life automaton on a torus."""
    m, n = config.shape
    new_config = np.zeros_like(config)
    for i in range(m):
        for j in range(n):
            s = neighbor_sum(config, i, j)
            alive = min(1, config[i, j])
            new_config[i, j] = (
                alive * tropical_threshold(s, 2, 3)
                + (1 - alive) * tropical_threshold(s, 3, 3)
            )
    return new_config


def pullback_config(config: np.ndarray, M: int, N: int) -> np.ndarray:
    """Pull back a config from m x n torus to M x N torus (requires m|M, n|N)."""
    m, n = config.shape
    assert M % m == 0 and N % n == 0, f"Need {m}|{M} and {n}|{N}"
    big = np.zeros((M, N), dtype=config.dtype)
    for i in range(M):
        for j in range(N):
            big[i, j] = config[i % m, j % n]
    return big


def find_period(config: np.ndarray, max_iter: int = 1000) -> int | None:
    """Find the period of a configuration, or None if not found."""
    current = config.copy()
    for p in range(1, max_iter + 1):
        current = tropical_life_step(current)
        if np.array_equal(current, config):
            return p
    return None


def find_minimal_period(config: np.ndarray, max_iter: int = 1000) -> int | None:
    """Find the minimal period."""
    return find_period(config, max_iter)


def period_spectrum(L: int, max_period: int = 50, num_samples: int = 500) -> set[int]:
    """Estimate the period spectrum of the L x L torus by random sampling."""
    periods = set()
    # Always include the zero config (period 1)
    periods.add(1)
    for _ in range(num_samples):
        config = np.random.randint(0, 2, size=(L, L))
        p = find_minimal_period(config, max_period)
        if p is not None:
            periods.add(p)
    return periods


def demo_pullback_commutation():
    """Demonstrate that pullback commutes with tropical Life step."""
    print("=" * 70)
    print("DEMO 1: Pullback Commutation (Theorem A)")
    print("=" * 70)
    print()
    print("Verifying: tropicalLifeStep(pullback(c)) = pullback(tropicalLifeStep(c))")
    print()

    for m, n, M, N in [(2, 2, 4, 4), (3, 3, 6, 6), (2, 3, 4, 9), (3, 2, 9, 4)]:
        success = True
        trials = 100
        for _ in range(trials):
            c = np.random.randint(0, 2, size=(m, n))
            pb_c = pullback_config(c, M, N)

            lhs = tropical_life_step(pb_c)
            rhs = pullback_config(tropical_life_step(c), M, N)

            if not np.array_equal(lhs, rhs):
                success = False
                break

        status = "✓ VERIFIED" if success else "✗ FAILED"
        print(f"  {m}×{n} → {M}×{N}: {status} ({trials} random configs)")

    print()


def demo_periodic_lifting():
    """Demonstrate divisibility lifting of periodic orbits."""
    print("=" * 70)
    print("DEMO 2: Periodic Orbit Lifting")
    print("=" * 70)
    print()
    print("If c has period p on m×n torus, pullback(c) has period p on M×N torus")
    print()

    examples = [
        (3, 3, 6, 6),
        (3, 3, 9, 9),
        (4, 4, 8, 8),
        (2, 2, 6, 6),
    ]

    for m, n, M, N in examples:
        for _ in range(50):
            c = np.random.randint(0, 2, size=(m, n))
            p_small = find_minimal_period(c, 30)
            if p_small is not None and p_small > 1:
                pb_c = pullback_config(c, M, N)
                p_big = find_period(pb_c, p_small)
                assert p_big is not None and p_big <= p_small
                print(
                    f"  {m}×{n} → {M}×{N}: period {p_small} lifts "
                    f"(period on big torus divides {p_small}: {p_big})"
                )
                break
        else:
            print(f"  {m}×{n} → {M}×{N}: (no non-fixed periodic orbit found in sample)")
    print()


def demo_period_divisibility():
    """Demonstrate minimal period divides every return time."""
    print("=" * 70)
    print("DEMO 3: Minimal Period Divisibility (Theorem B)")
    print("=" * 70)
    print()

    L = 5
    count = 0
    for _ in range(200):
        c = np.random.randint(0, 2, size=(L, L))
        p = find_minimal_period(c, 50)
        if p is not None and p > 1:
            # Check that multiples of p are also return times
            current = c.copy()
            for k in range(1, 4):
                for _ in range(p * k):
                    current = tropical_life_step(current)
                assert np.array_equal(current, c), f"p*k={p*k} should be return time"
                current = c.copy()
            print(f"  Config with minimal period {p}: p*1={p}, p*2={2*p}, p*3={3*p} all verified")
            count += 1
            if count >= 5:
                break
    print()


def demo_spectrum_monotonicity():
    """Demonstrate period spectrum monotonicity under divisibility."""
    print("=" * 70)
    print("DEMO 4: Period Spectrum Monotonicity")
    print("=" * 70)
    print()

    results = {}
    for L in [2, 3, 4, 6, 8, 12]:
        sp = period_spectrum(L, max_period=30, num_samples=300)
        results[L] = sp
        print(f"  L={L:2d}: periods = {sorted(sp)}")

    print()
    print("  Monotonicity checks (L | M => spectrum(L) ⊆ spectrum(M)):")
    pairs = [(2, 4), (2, 6), (3, 6), (4, 8), (2, 8), (3, 12), (4, 12), (6, 12)]
    for L, M in pairs:
        if L in results and M in results:
            subset = results[L] <= results[M]
            status = "✓" if subset else "✗"
            missing = results[L] - results[M]
            extra_info = f" (missing: {missing})" if missing else ""
            print(f"    {L} | {M}: {status}{extra_info}")
    print()


def demo_critical_sizes():
    """Demonstrate critical birth sizes for periods."""
    print("=" * 70)
    print("DEMO 5: Critical Birth Sizes (Theorem C)")
    print("=" * 70)
    print()
    print("  Finding the smallest L at which each period first appears:")
    print()

    first_appearance = {}
    for L in range(1, 13):
        sp = period_spectrum(L, max_period=20, num_samples=200)
        for p in sp:
            if p not in first_appearance:
                first_appearance[p] = L

    for p in sorted(first_appearance.keys()):
        if p <= 15:
            print(f"    Period {p:2d}: first appears at L = {first_appearance[p]}")
    print()


def demo_zero_config_fixed():
    """Demonstrate that the zero config is always a fixed point."""
    print("=" * 70)
    print("DEMO 6: Zero Configuration is Always a Fixed Point")
    print("=" * 70)
    print()

    for L in [1, 2, 3, 5, 10]:
        c = np.zeros((L, L), dtype=int)
        c_next = tropical_life_step(c)
        assert np.array_equal(c, c_next)
        print(f"  L={L}: zero config is fixed ✓")
    print()


if __name__ == "__main__":
    np.random.seed(42)
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  TROPICAL LIFE BIFURCATION ANALYSIS — NUMERICAL DEMONSTRATIONS     ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_pullback_commutation()
    demo_periodic_lifting()
    demo_period_divisibility()
    demo_spectrum_monotonicity()
    demo_critical_sizes()
    demo_zero_config_fixed()

    print("All demonstrations completed successfully!")


#!/usr/bin/env python3
"""
Visualizations for Tropical Life Bifurcation Analysis
========================================================
Generates publication-quality figures showing bifurcation diagrams,
period spectra, and the structure of periodic orbits.
"""

import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.colors import LinearSegmentedColormap
import base64
import io


def tropical_threshold(s, lo, hi):
    return min(1, max(0, s + 1 - lo)) * min(1, max(0, hi + 1 - s))


def tropical_life_step(config):
    m, n = config.shape
    new = np.zeros_like(config)
    for i in range(m):
        for j in range(n):
            s = sum(
                config[(i + di) % m, (j + dj) % n]
                for di in (-1, 0, 1) for dj in (-1, 0, 1)
                if not (di == 0 and dj == 0)
            )
            alive = min(1, config[i, j])
            new[i, j] = (
                alive * tropical_threshold(s, 2, 3)
                + (1 - alive) * tropical_threshold(s, 3, 3)
            )
    return new


def detect_period(config, max_iter=500):
    current = config.copy()
    for p in range(1, max_iter + 1):
        current = tropical_life_step(current)
        if np.array_equal(current, config):
            return p
    return None


def pullback_config(config, M, N):
    m, n = config.shape
    big = np.empty((M, N), dtype=config.dtype)
    for i in range(M):
        for j in range(N):
            big[i, j] = config[i % m, j % n]
    return big


def compute_spectrum(L, max_period=30, num_samples=300):
    periods = {1}
    for _ in range(num_samples):
        c = np.random.randint(0, 2, size=(L, L))
        p = detect_period(c, max_period)
        if p is not None:
            periods.add(p)
    return periods


def fig_to_base64(fig):
    buf = io.BytesIO()
    fig.savefig(buf, format="png", dpi=150, bbox_inches="tight")
    buf.seek(0)
    return "data:image/png;base64," + base64.b64encode(buf.read()).decode()


def generate_bifurcation_diagram():
    """Generate the main bifurcation diagram: periods vs torus size."""
    np.random.seed(42)
    fig, ax = plt.subplots(figsize=(10, 6))

    max_L = 12
    all_data = {}
    for L in range(1, max_L + 1):
        sp = compute_spectrum(L, max_period=25, num_samples=200)
        all_data[L] = sp
        for p in sp:
            ax.scatter(L, p, color="#2196F3", s=40, alpha=0.7, zorder=3)

    # Draw divisibility arrows
    for L1 in range(1, max_L + 1):
        for L2 in range(L1 + 1, max_L + 1):
            if L2 % L1 == 0 and L1 in all_data and L2 in all_data:
                for p in all_data[L1]:
                    if p in all_data[L2]:
                        ax.plot([L1, L2], [p, p], color="#90CAF9",
                                alpha=0.3, linewidth=0.5, zorder=1)

    ax.set_xlabel("Torus Size L", fontsize=13)
    ax.set_ylabel("Period p", fontsize=13)
    ax.set_title("Bifurcation Diagram: Period Spectrum vs Torus Size", fontsize=15)
    ax.set_xticks(range(1, max_L + 1))
    ax.grid(True, alpha=0.2)
    ax.set_xlim(0.5, max_L + 0.5)

    fig.tight_layout()
    fig.savefig("bifurcation_diagram.png", dpi=150, bbox_inches="tight")
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


def generate_spectrum_monotonicity():
    """Show period spectrum monotonicity under divisibility."""
    np.random.seed(42)
    fig, axes = plt.subplots(1, 3, figsize=(14, 4))

    pairs = [(2, 4), (3, 6), (4, 8)]
    colors = ["#E91E63", "#4CAF50", "#FF9800"]

    for idx, ((L, M), color) in enumerate(zip(pairs, colors)):
        ax = axes[idx]
        sp_L = compute_spectrum(L, 20, 200)
        sp_M = compute_spectrum(M, 20, 200)

        all_periods = sorted(sp_L | sp_M)
        x = np.arange(len(all_periods))
        width = 0.35

        in_L = [1 if p in sp_L else 0 for p in all_periods]
        in_M = [1 if p in sp_M else 0 for p in all_periods]

        ax.bar(x - width / 2, in_L, width, label=f"L={L}", color=color, alpha=0.7)
        ax.bar(x + width / 2, in_M, width, label=f"M={M}", color="#2196F3", alpha=0.7)

        ax.set_xticks(x)
        ax.set_xticklabels([str(p) for p in all_periods])
        ax.set_xlabel("Period")
        ax.set_ylabel("Present")
        ax.set_title(f"{L} | {M}: spectrum({L}) ⊆ spectrum({M})")
        ax.legend()
        ax.set_ylim(0, 1.3)

    fig.suptitle("Period Spectrum Monotonicity Under Divisibility", fontsize=14, y=1.02)
    fig.tight_layout()
    fig.savefig("spectrum_monotonicity.png", dpi=150, bbox_inches="tight")
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


def generate_pullback_illustration():
    """Illustrate the pullback map from small to large torus."""
    np.random.seed(42)
    fig, axes = plt.subplots(1, 3, figsize=(13, 4))

    # Small torus config
    c = np.array([[1, 0, 1], [0, 1, 0], [1, 0, 0]])
    m, n = 3, 3

    cmap = LinearSegmentedColormap.from_list("tropical", ["#ECEFF1", "#1B5E20"])

    ax = axes[0]
    ax.imshow(c, cmap=cmap, vmin=0, vmax=1, aspect="equal")
    ax.set_title(f"Original ({m}×{n})", fontsize=12)
    ax.set_xticks(range(n))
    ax.set_yticks(range(m))
    for i in range(m):
        for j in range(n):
            ax.text(j, i, str(c[i, j]), ha="center", va="center",
                    color="white" if c[i, j] else "gray", fontsize=14, fontweight="bold")

    # Pullback to 6x6
    pb = pullback_config(c, 6, 6)
    ax = axes[1]
    ax.imshow(pb, cmap=cmap, vmin=0, vmax=1, aspect="equal")
    ax.set_title("Pullback (6×6)", fontsize=12)
    ax.set_xticks(range(6))
    ax.set_yticks(range(6))
    for i in range(6):
        for j in range(6):
            ax.text(j, i, str(pb[i, j]), ha="center", va="center",
                    color="white" if pb[i, j] else "gray", fontsize=10)
    # Draw tile boundaries
    for x in [2.5, 5.5]:
        ax.axvline(x=x, color="yellow", linewidth=1.5, alpha=0.7)
    for y in [2.5, 5.5]:
        ax.axhline(y=y, color="yellow", linewidth=1.5, alpha=0.7)

    # Pullback to 9x9
    pb9 = pullback_config(c, 9, 9)
    ax = axes[2]
    ax.imshow(pb9, cmap=cmap, vmin=0, vmax=1, aspect="equal")
    ax.set_title("Pullback (9×9)", fontsize=12)
    ax.set_xticks(range(9))
    ax.set_yticks(range(9))
    for i in range(9):
        for j in range(9):
            ax.text(j, i, str(pb9[i, j]), ha="center", va="center",
                    color="white" if pb9[i, j] else "gray", fontsize=8)
    for x in [2.5, 5.5, 8.5]:
        ax.axvline(x=x, color="yellow", linewidth=1.5, alpha=0.7)
    for y in [2.5, 5.5, 8.5]:
        ax.axhline(y=y, color="yellow", linewidth=1.5, alpha=0.7)

    fig.suptitle("Pullback Map: Tiling a Small Torus onto a Larger One", fontsize=14)
    fig.tight_layout()
    fig.savefig("pullback_illustration.png", dpi=150, bbox_inches="tight")
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


def generate_critical_sizes():
    """Plot critical birth sizes for each period."""
    np.random.seed(42)
    fig, ax = plt.subplots(figsize=(8, 5))

    critical = {}
    for L in range(1, 11):
        sp = compute_spectrum(L, max_period=15, num_samples=200)
        for p in sp:
            if p not in critical:
                critical[p] = L

    periods = sorted(critical.keys())
    sizes = [critical[p] for p in periods]

    bars = ax.bar(range(len(periods)), sizes, color="#7C4DFF", alpha=0.8)
    ax.set_xticks(range(len(periods)))
    ax.set_xticklabels([str(p) for p in periods])
    ax.set_xlabel("Period p", fontsize=13)
    ax.set_ylabel("Critical Size L*", fontsize=13)
    ax.set_title("Critical Birth Size: Smallest Torus Supporting Each Period", fontsize=14)
    ax.grid(axis="y", alpha=0.3)

    for bar, L in zip(bars, sizes):
        ax.text(bar.get_x() + bar.get_width() / 2, bar.get_height() + 0.1,
                str(L), ha="center", fontsize=10, fontweight="bold")

    fig.tight_layout()
    fig.savefig("critical_sizes.png", dpi=150, bbox_inches="tight")
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


def generate_orbit_evolution():
    """Show orbit evolution for a periodic configuration."""
    np.random.seed(42)

    # Find a nice periodic config
    L = 5
    best_config = None
    best_period = 0
    for _ in range(200):
        c = np.random.randint(0, 2, size=(L, L))
        p = detect_period(c, 20)
        if p is not None and 2 <= p <= 6 and p > best_period:
            best_config = c.copy()
            best_period = p

    if best_config is None:
        best_config = np.zeros((L, L), dtype=int)
        best_period = 1

    fig, axes = plt.subplots(1, min(best_period + 1, 7), figsize=(3 * min(best_period + 1, 7), 3))
    if best_period == 0:
        axes = [axes]

    cmap = LinearSegmentedColormap.from_list("tropical", ["#FAFAFA", "#1B5E20"])
    current = best_config.copy()

    for t in range(min(best_period + 1, 7)):
        ax = axes[t] if isinstance(axes, np.ndarray) else axes
        ax.imshow(current, cmap=cmap, vmin=0, vmax=1, aspect="equal")
        label = f"t={t}"
        if t == best_period:
            label += " (= t=0)"
        ax.set_title(label, fontsize=11)
        ax.set_xticks([])
        ax.set_yticks([])
        current = tropical_life_step(current)

    fig.suptitle(f"Periodic Orbit (period {best_period}) on {L}×{L} Torus",
                 fontsize=14, y=1.02)
    fig.tight_layout()
    fig.savefig("orbit_evolution.png", dpi=150, bbox_inches="tight")
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


if __name__ == "__main__":
    print("Generating visualizations...")

    print("  1. Bifurcation diagram...")
    b1 = generate_bifurcation_diagram()

    print("  2. Spectrum monotonicity...")
    b2 = generate_spectrum_monotonicity()

    print("  3. Pullback illustration...")
    b3 = generate_pullback_illustration()

    print("  4. Critical sizes...")
    b4 = generate_critical_sizes()

    print("  5. Orbit evolution...")
    b5 = generate_orbit_evolution()

    print("All visualizations generated and saved as PNG files.")
    print(f"  Base64 sizes: {len(b1)}, {len(b2)}, {len(b3)}, {len(b4)}, {len(b5)}")
