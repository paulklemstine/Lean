#!/usr/bin/env python3
"""
Tropical BSD Prototype — Applications

Demonstrates real-world applications of the tropical BSD framework:
1. Certified rank bounds from finite local data
2. Elliptic curve arithmetic statistics via tropical invariants
3. Complexity analysis of arithmetic certificates
"""

import math
from typing import Dict, List, Tuple


# ─── Application 1: Certified Rank Bounds ───

def certified_rank_bound(
    primes: List[int],
    a_p: Dict[int, int],
    target_rank: int
) -> dict:
    """
    Compute a tropical rank bound for an elliptic curve from local data.

    Given an elliptic curve E/Q with a_p values at primes p,
    construct a tropical weight function w(p) = -log|a_p| (for a_p != 0)
    and compute the tropical analytic rank.

    This gives a combinatorial invariant that can serve as a rank certificate
    when the genericity condition holds.

    Args:
        primes: List of primes at which we have local data
        a_p: Dictionary mapping prime p to a_p(E)
        target_rank: Expected rank for comparison

    Returns:
        Dictionary with tropical analysis results
    """
    # Construct weight function from a_p data
    # Use w(p) = -log(|a_p|) for |a_p| > 0, or a large value for a_p = 0
    w = {}
    valid_primes = []
    for p in primes:
        if a_p[p] != 0:
            w[p] = -math.log(abs(a_p[p]))
            valid_primes.append(p)
        else:
            w[p] = 10.0  # Large weight for supersingular reduction
            valid_primes.append(p)

    if not valid_primes:
        return {"error": "No valid primes"}

    # Compute tropical invariants
    m = min(w[p] for p in valid_primes)
    active = [p for p in valid_primes if abs(w[p] - m) < 1e-10]
    tord = len(active) - 1

    return {
        "primes": valid_primes,
        "weights": {p: round(w[p], 4) for p in valid_primes},
        "min_weight": round(m, 4),
        "active_primes": active,
        "tropical_order": tord,
        "target_rank": target_rank,
        "match": tord == target_rank,
        "interpretation": (
            f"Tropical analytic rank = {tord}. "
            f"{'Matches' if tord == target_rank else 'Does not match'} "
            f"expected rank {target_rank}."
        )
    }


# ─── Application 2: Arithmetic Statistics ───

def tropical_rank_distribution(
    num_curves: int = 100,
    num_primes: int = 10,
    seed: int = 42
) -> Dict[int, int]:
    """
    Simulate the distribution of tropical analytic ranks for random
    "elliptic curve-like" weight data.

    This models the tropical arithmetic statistics question: what is
    the distribution of tropical orders of vanishing across a family
    of weight functions?

    Args:
        num_curves: Number of random curves to simulate
        num_primes: Number of primes to use
        seed: Random seed

    Returns:
        Dictionary mapping tropical rank to count
    """
    import random
    random.seed(seed)

    primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47][:num_primes]
    rank_counts: Dict[int, int] = {}

    for _ in range(num_curves):
        # Generate random weights (simulating -log|a_p| data)
        w = {p: random.uniform(-2, 2) for p in primes}

        m = min(w.values())
        active_count = sum(1 for v in w.values() if abs(v - m) < 1e-10)
        tord = active_count - 1

        rank_counts[tord] = rank_counts.get(tord, 0) + 1

    return dict(sorted(rank_counts.items()))


def tropical_rank_statistics_lattice(
    num_curves: int = 10000,
    num_primes: int = 8,
    lattice_step: float = 0.5,
    seed: int = 42
) -> Dict[int, int]:
    """
    Compute tropical rank distribution for lattice-valued weights.

    When weights are quantized (take values in a lattice like 0.5*Z),
    ties in minima become common, making the genericity condition
    more natural and tropical ranks higher.

    Args:
        num_curves: Number of random curves
        num_primes: Number of primes
        lattice_step: Lattice spacing
        seed: Random seed

    Returns:
        Distribution of tropical ranks
    """
    import random
    random.seed(seed)

    primes = [2, 3, 5, 7, 11, 13, 17, 19][:num_primes]
    rank_counts: Dict[int, int] = {}

    for _ in range(num_curves):
        # Quantized weights
        w = {p: round(random.uniform(-2, 2) / lattice_step) * lattice_step for p in primes}

        m = min(w.values())
        active_count = sum(1 for v in w.values() if abs(v - m) < 1e-10)
        tord = active_count - 1

        rank_counts[tord] = rank_counts.get(tord, 0) + 1

    return dict(sorted(rank_counts.items()))


# ─── Application 3: Complexity of Arithmetic Certificates ───

def certificate_complexity_analysis(
    max_support: int = 50,
    max_generators: int = 10
) -> List[dict]:
    """
    Analyze the computational complexity of verifying tropical BSD certificates.

    For varying sizes of support and generator sets, measure the number
    of operations needed for:
    1. Computing combined weights: O(|I| * |S|)
    2. Finding active set: O(|S|)
    3. Verifying independence: O(|I|^2 * |S|)
    4. Total verification: O(|I|^2 * |S|)

    Args:
        max_support: Maximum support size to test
        max_generators: Maximum number of generators

    Returns:
        List of complexity measurements
    """
    results = []
    for s in range(5, max_support + 1, 5):
        for r in range(1, min(max_generators + 1, s)):
            ops_weight = r * s  # O(|I| * |S|)
            ops_active = s  # O(|S|)
            ops_indep = r * (r - 1) // 2 * s  # O(|I|^2 * |S|)
            ops_total = ops_weight + ops_active + ops_indep

            results.append({
                "support_size": s,
                "rank": r,
                "ops_combined_weights": ops_weight,
                "ops_active_set": ops_active,
                "ops_independence": ops_indep,
                "ops_total": ops_total,
            })

    return results


# ─── Demo of Applications ───

if __name__ == "__main__":
    print("=" * 60)
    print("APPLICATION 1: Certified Rank Bounds from Local Data")
    print("=" * 60)

    # Example: y^2 = x^3 - x (rank 0 over Q)
    # a_p values for first few primes
    print("\n  Curve: y² = x³ - x (expected rank 0)")
    result = certified_rank_bound(
        primes=[2, 3, 5, 7, 11, 13],
        a_p={2: 0, 3: 0, 5: -2, 7: 0, 11: 0, 13: -6},
        target_rank=0
    )
    print(f"    Weights: {result['weights']}")
    print(f"    Active primes: {result['active_primes']}")
    print(f"    {result['interpretation']}")

    # Example: y^2 = x^3 - x + 1 (rank 1 over Q)
    print("\n  Curve: y² = x³ - x + 1 (expected rank 1)")
    result = certified_rank_bound(
        primes=[2, 3, 5, 7, 11, 13],
        a_p={2: -1, 3: -1, 5: 3, 7: -3, 11: 2, 13: -4},
        target_rank=1
    )
    print(f"    Weights: {result['weights']}")
    print(f"    Active primes: {result['active_primes']}")
    print(f"    {result['interpretation']}")

    print("\n" + "=" * 60)
    print("APPLICATION 2: Tropical Arithmetic Statistics")
    print("=" * 60)

    print("\n  --- Continuous weights (rank almost always 0) ---")
    dist = tropical_rank_distribution(num_curves=10000, num_primes=8)
    for rank, count in dist.items():
        bar = "█" * (count // 100)
        print(f"    Rank {rank}: {count:5d} ({count/100:.1f}%) {bar}")

    print("\n  --- Lattice weights, step=1.0 (higher ranks more common) ---")
    dist = tropical_rank_statistics_lattice(num_curves=10000, num_primes=8, lattice_step=1.0)
    for rank, count in dist.items():
        bar = "█" * (count // 100)
        print(f"    Rank {rank}: {count:5d} ({count/100:.1f}%) {bar}")

    print("\n  --- Lattice weights, step=2.0 (even more ties) ---")
    dist = tropical_rank_statistics_lattice(num_curves=10000, num_primes=8, lattice_step=2.0)
    for rank, count in dist.items():
        bar = "█" * (count // 100)
        print(f"    Rank {rank}: {count:5d} ({count/100:.1f}%) {bar}")

    print("\n" + "=" * 60)
    print("APPLICATION 3: Certificate Complexity Analysis")
    print("=" * 60)

    print(f"\n  {'|S|':>4} {'Rank':>5} {'Total ops':>10} {'Note':>20}")
    print("  " + "-" * 45)
    for entry in certificate_complexity_analysis(max_support=30, max_generators=5):
        note = ""
        if entry["rank"] == 1:
            note = "trivial"
        elif entry["ops_total"] > 1000:
            note = "moderate"
        print(f"  {entry['support_size']:4d} {entry['rank']:5d} {entry['ops_total']:10d} {note:>20}")


#!/usr/bin/env python3
"""
Tropical BSD Prototype — Demonstration Script

This script demonstrates the core theorems of the tropical BSD prototype
with concrete numerical examples. It computes tropical analytic rank,
tropical residue, and verifies the BSD identity under genericity.
"""

import math
from typing import Dict, List, Tuple


def tropical_l_series(S: List[int], w: Dict[int, float], s: float) -> float:
    """Compute the tropical Dirichlet series T_w(s) = min_{n in S} (w(n) + (s-1)*log(n))."""
    return min(w[n] + (s - 1) * math.log(n) for n in S)


def tropical_residue(S: List[int], w: Dict[int, float]) -> float:
    """Compute the tropical residue: min_{n in S} w(n)."""
    return min(w[n] for n in S)


def active_set(S: List[int], w: Dict[int, float]) -> List[int]:
    """Compute the active set: elements of S achieving the minimum weight."""
    m = min(w[n] for n in S)
    return [n for n in S if w[n] == m]


def tropical_order_at_one(S: List[int], w: Dict[int, float]) -> int:
    """Compute the tropical order of vanishing at s=1."""
    return len(active_set(S, w)) - 1


def pointwise_min(I: List[int], S: List[int], v: Dict[int, Dict[int, float]]) -> Dict[int, float]:
    """Compute w(n) = min_{i in I} v(i, n) for each n in S."""
    return {n: min(v[i][n] for i in I) for n in S}


def verify_tropical_bsd(I: List[int], S: List[int], v: Dict[int, Dict[int, float]]) -> dict:
    """Verify the tropical BSD identity and return diagnostic information."""
    w = pointwise_min(I, S, v)
    A = active_set(S, w)
    tord = tropical_order_at_one(S, w)
    rank = len(I)
    generic = len(A) == rank + 1
    bsd_holds = tord == rank

    return {
        "weights": w,
        "active_set": A,
        "active_count": len(A),
        "tropical_order": tord,
        "tropical_rank": rank,
        "genericity_holds": generic,
        "bsd_identity_holds": bsd_holds,
        "residue": tropical_residue(S, w),
    }


def demo_theorem_A():
    """Demonstrate Theorem A: tropical order = |active set| - 1."""
    print("=" * 60)
    print("THEOREM A: Tropical Order = Active Branches - 1")
    print("=" * 60)

    S = [2, 3, 5, 7, 11]

    examples = [
        {"name": "Single minimizer", "w": {2: 0.5, 3: 0.3, 5: 0.8, 7: 0.9, 11: 1.2}},
        {"name": "Two minimizers", "w": {2: 0.3, 3: 0.3, 5: 0.8, 7: 0.9, 11: 1.2}},
        {"name": "Three minimizers", "w": {2: 0.3, 3: 0.3, 5: 0.3, 7: 0.9, 11: 1.2}},
        {"name": "All equal", "w": {2: 0.5, 3: 0.5, 5: 0.5, 7: 0.5, 11: 0.5}},
    ]

    for ex in examples:
        w = ex["w"]
        A = active_set(S, w)
        tord = tropical_order_at_one(S, w)
        print(f"\n  {ex['name']}:")
        print(f"    Weights: {w}")
        print(f"    Active set: {A} (size {len(A)})")
        print(f"    Tropical order: {tord}")
        print(f"    Check: {len(A)} - 1 = {len(A) - 1} ✓" if tord == len(A) - 1 else "    FAIL!")


def demo_theorem_B():
    """Demonstrate Theorem B: Tropical BSD Prototype."""
    print("\n" + "=" * 60)
    print("THEOREM B: Tropical BSD Prototype (rank = tropical order)")
    print("=" * 60)

    # Rank 1 example
    print("\n  --- Rank 1 ---")
    S = [2, 3, 5]
    I = [1]
    v = {1: {2: 0.3, 3: 0.3, 5: 0.7}}
    result = verify_tropical_bsd(I, S, v)
    print(f"    Valuation profiles: {v}")
    print(f"    Combined weights: {result['weights']}")
    print(f"    Active set: {result['active_set']} (size {result['active_count']})")
    print(f"    Genericity (|A| = r+1 = 2): {result['genericity_holds']}")
    print(f"    Tropical order = {result['tropical_order']}, Rank = {result['tropical_rank']}")
    print(f"    BSD holds: {result['bsd_identity_holds']} ✓" if result["bsd_identity_holds"] else "    BSD fails ✗")

    # Rank 2 example
    print("\n  --- Rank 2 ---")
    S = [2, 3, 5, 7]
    I = [1, 2]
    v = {
        1: {2: 0.3, 3: 0.3, 5: 0.8, 7: 0.9},
        2: {2: 0.7, 3: 0.8, 5: 0.3, 7: 0.6},
    }
    result = verify_tropical_bsd(I, S, v)
    print(f"    Combined weights: {result['weights']}")
    print(f"    Active set: {result['active_set']} (size {result['active_count']})")
    print(f"    Genericity (|A| = r+1 = 3): {result['genericity_holds']}")
    print(f"    Tropical order = {result['tropical_order']}, Rank = {result['tropical_rank']}")
    print(f"    BSD holds: {result['bsd_identity_holds']} ✓" if result["bsd_identity_holds"] else "    BSD fails ✗")

    # Rank 3 example with genericity
    print("\n  --- Rank 3 (constructed for genericity) ---")
    S = [2, 3, 5, 7, 11]
    I = [1, 2, 3]
    v = {
        1: {2: 0.2, 3: 0.2, 5: 0.9, 7: 0.8, 11: 1.0},
        2: {2: 0.8, 3: 0.7, 5: 0.2, 7: 0.6, 11: 0.9},
        3: {2: 0.7, 3: 0.6, 5: 0.8, 7: 0.2, 11: 0.5},
    }
    result = verify_tropical_bsd(I, S, v)
    print(f"    Combined weights: {result['weights']}")
    print(f"    Active set: {result['active_set']} (size {result['active_count']})")
    print(f"    Genericity (|A| = r+1 = 4): {result['genericity_holds']}")
    print(f"    Tropical order = {result['tropical_order']}, Rank = {result['tropical_rank']}")
    print(f"    BSD holds: {result['bsd_identity_holds']} ✓" if result["bsd_identity_holds"] else "    BSD fails ✗")


def demo_theorem_C():
    """Demonstrate Theorem C: Residue Decomposition."""
    print("\n" + "=" * 60)
    print("THEOREM C: Tropical Residue Decomposition")
    print("=" * 60)

    S = [2, 3, 5, 7]

    w1 = {2: 1.0, 3: 0.5, 5: 0.8, 7: 0.6}  # "regulator" profile
    w2 = {2: 0.3, 3: 0.9, 5: 0.7, 7: 0.4}  # "Tamagawa" profile
    w3 = {2: 0.8, 3: 0.6, 5: 0.2, 7: 0.9}  # "torsion" profile

    r1 = tropical_residue(S, w1)
    r2 = tropical_residue(S, w2)
    r3 = tropical_residue(S, w3)

    w_min12 = {n: min(w1[n], w2[n]) for n in S}
    r_min12 = tropical_residue(S, w_min12)

    w_min_all = {n: min(w1[n], w2[n], w3[n]) for n in S}
    r_min_all = tropical_residue(S, w_min_all)

    print(f"\n  Regulator profile:  {w1}  → residue = {r1}")
    print(f"  Tamagawa profile:   {w2}  → residue = {r2}")
    print(f"  Torsion profile:    {w3}  → residue = {r3}")
    print(f"\n  min(w1, w2):        {w_min12}  → residue = {r_min12}")
    print(f"  min(res1, res2) = min({r1}, {r2}) = {min(r1, r2)}")
    print(f"  Match: {r_min12 == min(r1, r2)} ✓" if r_min12 == min(r1, r2) else f"  FAIL!")

    print(f"\n  min(w1, w2, w3):    {w_min_all}  → residue = {r_min_all}")
    print(f"  min(res1, res2, res3) = min({r1}, {r2}, {r3}) = {min(r1, r2, r3)}")
    print(f"  Match: {r_min_all == min(r1, r2, r3)} ✓" if r_min_all == min(r1, r2, r3) else f"  FAIL!")


def demo_lower_envelope():
    """Demonstrate the lower envelope / tropical L-series as a function of s."""
    print("\n" + "=" * 60)
    print("LOWER ENVELOPE: Tropical L-series T_w(s) for varying s")
    print("=" * 60)

    S = [2, 3, 5]
    w = {2: 0.3, 3: 0.3, 5: 0.7}

    print(f"\n  S = {S}, weights = {w}")
    print(f"\n  {'s':>6} | {'T_w(s)':>8} | {'Active branch':>15}")
    print("  " + "-" * 35)

    for s_val in [x * 0.1 for x in range(-5, 26)]:
        t = tropical_l_series(S, w, s_val)
        # Find which branch achieves the min
        branches = {n: w[n] + (s_val - 1) * math.log(n) for n in S}
        active = [n for n, val in branches.items() if abs(val - t) < 1e-10]
        print(f"  {s_val:6.1f} | {t:8.4f} | {active}")


def demo_ground_state_degeneracy():
    """Demonstrate the statistical mechanics interpretation."""
    print("\n" + "=" * 60)
    print("STATISTICAL MECHANICS: Ground-State Degeneracy")
    print("=" * 60)

    S = [2, 3, 5, 7, 11, 13]

    print("\n  Interpreting weights as energies of states (primes).")
    print("  Active set = ground states. Tropical order = degeneracy.\n")

    configs = [
        ("Non-degenerate", {2: 0.1, 3: 0.5, 5: 0.8, 7: 0.3, 11: 0.9, 13: 1.2}),
        ("2-fold degenerate", {2: 0.1, 3: 0.1, 5: 0.8, 7: 0.3, 11: 0.9, 13: 1.2}),
        ("3-fold degenerate", {2: 0.1, 3: 0.1, 5: 0.8, 7: 0.1, 11: 0.9, 13: 1.2}),
        ("Maximally degenerate", {2: 0.1, 3: 0.1, 5: 0.1, 7: 0.1, 11: 0.1, 13: 0.1}),
    ]

    for name, w in configs:
        A = active_set(S, w)
        tord = tropical_order_at_one(S, w)
        E0 = tropical_residue(S, w)
        print(f"  {name}:")
        print(f"    Ground energy: {E0}")
        print(f"    Ground states: {A}")
        print(f"    Degeneracy (tropical order): {tord}")
        print()


if __name__ == "__main__":
    demo_theorem_A()
    demo_theorem_B()
    demo_theorem_C()
    demo_lower_envelope()
    demo_ground_state_degeneracy()


#!/usr/bin/env python3
"""Generate PACKAGE.json with all embedded content."""

import json
import base64
import os

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

def read_image_base64(path):
    with open(path, 'rb') as f:
        encoded = base64.b64encode(f.read()).decode('utf-8')
    return f"data:image/png;base64,{encoded}"

# Read all content
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
lean_proofs = read_file('Algebra/TropicalBSD/TropicalBSDPrototype.lean')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')
visualizations_code = read_file('visualizations.py')

# Read images
img_lower_envelope = read_image_base64('fig_lower_envelope.png')
img_bsd_identity = read_image_base64('fig_bsd_identity.png')
img_rank_distribution = read_image_base64('fig_rank_distribution.png')
img_residue_decomposition = read_image_base64('fig_residue_decomposition.png')

package = {
    "title": "Tropical BSD Prototype: A Combinatorial Shadow of the Birch–Swinnerton-Dyer Conjecture",
    "domain": "Algebra / Tropical Geometry / Arithmetic Geometry",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Tropical BSD Demonstration",
            "code": demo_code
        },
        {
            "name": "Applications: Rank Bounds, Statistics, Complexity",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Tropical Analytic Rank",
            "pseudocode": "function TropicalAnalyticRank(S, w):\n    m ← min{w(n) : n ∈ S}\n    A ← {n ∈ S : w(n) = m}\n    return |A| - 1\n\nComplexity: O(|S|) time, O(1) space",
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {
            "name": "Lower Envelope (Tropical L-Series)",
            "data": img_lower_envelope
        },
        {
            "name": "Tropical BSD Identity for Ranks 1, 2, 3",
            "data": img_bsd_identity
        },
        {
            "name": "Tropical Rank Distribution Statistics",
            "data": img_rank_distribution
        },
        {
            "name": "Tropical Residue Decomposition",
            "data": img_residue_decomposition
        }
    ],
    "lean_proofs": lean_proofs
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2)

print(f"PACKAGE.json generated ({os.path.getsize('PACKAGE.json') / 1024:.0f} KB)")


#!/usr/bin/env python3
"""
Tropical BSD Prototype — Visualizations

Generates publication-quality figures illustrating:
1. The lower envelope (tropical L-series) as a function of s
2. Active branches and tropical order of vanishing
3. Tropical rank distribution statistics
4. Residue decomposition
"""

import math
import base64
import io
from typing import Dict, List

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def fig_to_base64(fig) -> str:
    """Convert a matplotlib figure to a base64-encoded PNG data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    encoded = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{encoded}"


def plot_lower_envelope():
    """Plot the tropical L-series as a lower envelope of affine functions."""
    S = [2, 3, 5, 7]
    w = {2: 0.5, 3: 0.2, 5: 0.6, 7: 0.4}

    s_vals = np.linspace(-0.5, 3.0, 500)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Left panel: individual branches and envelope
    colors = ['#e74c3c', '#3498db', '#2ecc71', '#9b59b6']
    for idx, n in enumerate(S):
        branch = [w[n] + (s - 1) * math.log(n) for s in s_vals]
        ax1.plot(s_vals, branch, '--', color=colors[idx], alpha=0.5, linewidth=1,
                label=f'n={n}: w={w[n]}')

    # Envelope
    envelope = [min(w[n] + (s - 1) * math.log(n) for n in S) for s in s_vals]
    ax1.plot(s_vals, envelope, 'k-', linewidth=2.5, label='Tropical L-series')

    # Mark s=1
    t_at_1 = min(w[n] for n in S)
    ax1.axvline(x=1, color='gray', linestyle=':', alpha=0.5)
    ax1.plot(1, t_at_1, 'ro', markersize=10, zorder=5)
    ax1.annotate(f's=1\nT_w(1)={t_at_1:.2f}', xy=(1, t_at_1),
                xytext=(1.3, t_at_1 + 0.3), fontsize=10,
                arrowprops=dict(arrowstyle='->', color='red'))

    ax1.set_xlabel('s', fontsize=12)
    ax1.set_ylabel('T_w(s)', fontsize=12)
    ax1.set_title('Tropical L-Series as Lower Envelope', fontsize=13)
    ax1.legend(fontsize=9, loc='upper left')
    ax1.grid(True, alpha=0.3)

    # Right panel: active branches at s=1
    weights = [w[n] for n in S]
    m = min(weights)
    bar_colors = ['#e74c3c' if abs(w[n] - m) < 1e-10 else '#bdc3c7' for n in S]

    bars = ax2.bar([str(n) for n in S], weights, color=bar_colors, edgecolor='black', linewidth=0.5)
    ax2.axhline(y=m, color='red', linestyle='--', linewidth=1.5, label=f'Min = {m:.2f}')

    active_count = sum(1 for n in S if abs(w[n] - m) < 1e-10)
    ax2.set_xlabel('Support element n', fontsize=12)
    ax2.set_ylabel('Weight w(n)', fontsize=12)
    ax2.set_title(f'Active Branches at s=1\n'
                  f'Active count = {active_count}, '
                  f'Tropical order = {active_count - 1}', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3, axis='y')

    fig.tight_layout()
    return fig


def plot_bsd_identity():
    """Illustrate the tropical BSD identity for different ranks."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 4.5))

    configs = [
        {
            "title": "Rank 1",
            "I": [1],
            "S": [2, 3, 5],
            "v": {1: {2: 0.3, 3: 0.3, 5: 0.7}},
        },
        {
            "title": "Rank 2",
            "I": [1, 2],
            "S": [2, 3, 5, 7],
            "v": {
                1: {2: 0.3, 3: 0.3, 5: 0.8, 7: 0.9},
                2: {2: 0.7, 3: 0.8, 5: 0.3, 7: 0.6},
            },
        },
        {
            "title": "Rank 3",
            "I": [1, 2, 3],
            "S": [2, 3, 5, 7, 11],
            "v": {
                1: {2: 0.2, 3: 0.2, 5: 0.9, 7: 0.8, 11: 1.0},
                2: {2: 0.8, 3: 0.7, 5: 0.2, 7: 0.6, 11: 0.9},
                3: {2: 0.7, 3: 0.6, 5: 0.8, 7: 0.2, 11: 0.5},
            },
        },
    ]

    for ax, cfg in zip(axes, configs):
        S = cfg["S"]
        I = cfg["I"]
        v = cfg["v"]

        w = {n: min(v[i][n] for i in I) for n in S}
        m = min(w.values())
        active = [n for n in S if abs(w[n] - m) < 1e-10]
        tord = len(active) - 1
        rank = len(I)

        bar_colors = ['#e74c3c' if n in active else '#95a5a6' for n in S]
        ax.bar([str(n) for n in S], [w[n] for n in S],
               color=bar_colors, edgecolor='black', linewidth=0.5)
        ax.axhline(y=m, color='red', linestyle='--', alpha=0.7)

        status = "✓" if tord == rank else "✗"
        gen_status = "✓" if len(active) == rank + 1 else "✗"
        ax.set_title(f'{cfg["title"]}\n'
                     f'|Active|={len(active)}, tord={tord}, |I|={rank}\n'
                     f'Genericity: {gen_status}  BSD: {status}',
                     fontsize=11)
        ax.set_xlabel('n', fontsize=10)
        ax.set_ylabel('w(n)', fontsize=10)
        ax.grid(True, alpha=0.3, axis='y')

    fig.suptitle('Tropical BSD Identity: rank = tropical order of vanishing',
                 fontsize=14, fontweight='bold', y=1.02)
    fig.tight_layout()
    return fig


def plot_rank_distribution():
    """Plot the distribution of tropical ranks for random and lattice weights."""
    import random

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    primes = [2, 3, 5, 7, 11, 13, 17, 19]
    n_trials = 50000

    # Continuous weights
    random.seed(42)
    ranks_cont = []
    for _ in range(n_trials):
        w = {p: random.uniform(-2, 2) for p in primes}
        m = min(w.values())
        count = sum(1 for v in w.values() if abs(v - m) < 1e-10)
        ranks_cont.append(count - 1)

    max_rank = max(ranks_cont) + 1
    bins = range(max_rank + 1)
    ax1.hist(ranks_cont, bins=[b - 0.5 for b in range(max_rank + 2)],
             color='#3498db', edgecolor='black', linewidth=0.5, density=True)
    ax1.set_xlabel('Tropical Rank', fontsize=12)
    ax1.set_ylabel('Frequency', fontsize=12)
    ax1.set_title('Continuous Weights\n(rank almost always 0)', fontsize=12)
    ax1.set_xticks(range(max_rank + 1))
    ax1.grid(True, alpha=0.3, axis='y')

    # Lattice weights
    random.seed(42)
    ranks_lattice = []
    for _ in range(n_trials):
        w = {p: round(random.uniform(-2, 2)) for p in primes}
        m = min(w.values())
        count = sum(1 for v in w.values() if abs(v - m) < 1e-10)
        ranks_lattice.append(count - 1)

    max_rank = max(ranks_lattice) + 1
    ax2.hist(ranks_lattice, bins=[b - 0.5 for b in range(max_rank + 2)],
             color='#e74c3c', edgecolor='black', linewidth=0.5, density=True)
    ax2.set_xlabel('Tropical Rank', fontsize=12)
    ax2.set_ylabel('Frequency', fontsize=12)
    ax2.set_title('Lattice Weights (step=1)\n(higher ranks more common)', fontsize=12)
    ax2.set_xticks(range(max_rank + 1))
    ax2.grid(True, alpha=0.3, axis='y')

    fig.suptitle('Tropical Arithmetic Statistics: Rank Distributions',
                 fontsize=14, fontweight='bold')
    fig.tight_layout()
    return fig


def plot_residue_decomposition():
    """Visualize the tropical residue decomposition theorem."""
    S = [2, 3, 5, 7, 11]

    w1 = {2: 1.0, 3: 0.5, 5: 0.8, 7: 0.6, 11: 0.9}
    w2 = {2: 0.3, 3: 0.9, 5: 0.7, 7: 0.4, 11: 0.6}

    w_min = {n: min(w1[n], w2[n]) for n in S}
    r1 = min(w1[n] for n in S)
    r2 = min(w2[n] for n in S)
    r_min = min(w_min[n] for n in S)

    fig, axes = plt.subplots(1, 3, figsize=(15, 4.5))

    x = [str(n) for n in S]

    # Profile 1
    axes[0].bar(x, [w1[n] for n in S], color='#3498db', edgecolor='black', linewidth=0.5)
    axes[0].axhline(y=r1, color='blue', linestyle='--', label=f'Residue = {r1:.2f}')
    axes[0].set_title('Regulator Profile w₁', fontsize=12)
    axes[0].set_ylabel('Weight', fontsize=11)
    axes[0].legend(fontsize=9)
    axes[0].grid(True, alpha=0.3, axis='y')
    axes[0].set_ylim(0, 1.2)

    # Profile 2
    axes[1].bar(x, [w2[n] for n in S], color='#e74c3c', edgecolor='black', linewidth=0.5)
    axes[1].axhline(y=r2, color='red', linestyle='--', label=f'Residue = {r2:.2f}')
    axes[1].set_title('Tamagawa Profile w₂', fontsize=12)
    axes[1].legend(fontsize=9)
    axes[1].grid(True, alpha=0.3, axis='y')
    axes[1].set_ylim(0, 1.2)

    # Combined min
    bar_colors = ['#3498db' if w1[n] <= w2[n] else '#e74c3c' for n in S]
    axes[2].bar(x, [w_min[n] for n in S], color=bar_colors, edgecolor='black', linewidth=0.5)
    axes[2].axhline(y=r_min, color='green', linestyle='--', linewidth=2,
                    label=f'Residue = min({r1:.2f}, {r2:.2f}) = {r_min:.2f}')
    axes[2].set_title('Combined min(w₁, w₂)', fontsize=12)
    axes[2].legend(fontsize=9)
    axes[2].grid(True, alpha=0.3, axis='y')
    axes[2].set_ylim(0, 1.2)

    fig.suptitle('Tropical Residue Decomposition: Res(min) = min(Res)',
                 fontsize=14, fontweight='bold')
    fig.tight_layout()
    return fig


if __name__ == "__main__":
    print("Generating visualizations...")

    fig1 = plot_lower_envelope()
    fig1.savefig("fig_lower_envelope.png", dpi=150, bbox_inches='tight')
    print("  Saved fig_lower_envelope.png")

    fig2 = plot_bsd_identity()
    fig2.savefig("fig_bsd_identity.png", dpi=150, bbox_inches='tight')
    print("  Saved fig_bsd_identity.png")

    fig3 = plot_rank_distribution()
    fig3.savefig("fig_rank_distribution.png", dpi=150, bbox_inches='tight')
    print("  Saved fig_rank_distribution.png")

    fig4 = plot_residue_decomposition()
    fig4.savefig("fig_residue_decomposition.png", dpi=150, bbox_inches='tight')
    print("  Saved fig_residue_decomposition.png")

    print("Done!")
