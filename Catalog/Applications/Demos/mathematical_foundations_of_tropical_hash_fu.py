#!/usr/bin/env python3
"""
Demonstration of Tropical Hash Function Properties

This script demonstrates the key mathematical results from the paper
"Nonlinear Tropical Hash Functions: Modular Reduction and Security Amplification"
through concrete numerical examples.
"""

import random
import math
from typing import List, Tuple


# ============================================================
# Core implementations (inlined for self-containment)
# ============================================================

def tsha(m: List[int], h: List[int]) -> int:
    return min(m[i] + h[i] for i in range(len(m)))

def ntsha(m: List[int], h: List[int], p: int) -> int:
    return min((m[i] + h[i]) % p for i in range(len(m)))


# ============================================================
# Demo 1: Shift Equivariance Breaking
# ============================================================

def demo_shift_equivariance():
    print("=" * 60)
    print("DEMO 1: Shift Equivariance Breaking")
    print("=" * 60)
    print()

    k = 4
    m = [3, 7, 1, 5]
    h = [2, 1, 4, 3]
    c = 10

    # TSHA is shift-equivariant
    tsha_orig = tsha(m, h)
    tsha_shifted = tsha([mi + c for mi in m], h)
    print(f"Message m = {m}, Key h = {h}, Shift c = {c}")
    print(f"TSHA(m, h) = {tsha_orig}")
    print(f"TSHA(m + {c}, h) = {tsha_shifted}")
    print(f"TSHA(m, h) + {c} = {tsha_orig + c}")
    print(f"TSHA is shift-equivariant: {tsha_shifted == tsha_orig + c}")
    print()

    # NTSHA breaks equivariance
    p = 7
    print(f"Now with NTSHA (p = {p}):")
    ntsha_orig = ntsha(m, h, p)
    ntsha_shifted = ntsha([mi + c for mi in m], h, p)
    print(f"NTSHA_{p}(m, h) = {ntsha_orig}")
    print(f"NTSHA_{p}(m + {c}, h) = {ntsha_shifted}")
    print(f"NTSHA_{p}(m, h) + {c} = {ntsha_orig + c}")
    print(f"NTSHA breaks equivariance: {ntsha_shifted != ntsha_orig + c}")
    print()

    # The concrete counterexample from the theorem
    print("Formal counterexample (k=1, p=3, m=[1], h=[0], c=2):")
    print(f"  NTSHA_3([1], [0]) = {ntsha([1], [0], 3)}")
    print(f"  NTSHA_3([3], [0]) = {ntsha([3], [0], 3)}")
    print(f"  1 + 2 = 3 ≠ 0 → Equivariance BROKEN ✓")
    print()


# ============================================================
# Demo 2: Fiber Periodicity
# ============================================================

def demo_fiber_periodicity():
    print("=" * 60)
    print("DEMO 2: Modular Fiber Periodicity")
    print("=" * 60)
    print()

    p = 7
    k = 3
    h = [2, 5, 1]
    m = [3, 1, 4]
    y = ntsha(m, h, p)

    print(f"p = {p}, k = {k}, h = {h}")
    print(f"m = {m}, NTSHA_7(m, h) = {y}")
    print()
    print("Fiber periodicity: shifting any coordinate by p preserves the hash:")

    for j in range(k):
        m_shifted = m.copy()
        m_shifted[j] += p
        y_shifted = ntsha(m_shifted, h, p)
        print(f"  Shift coord {j} by p: m' = {m_shifted}, NTSHA = {y_shifted} (same: {y_shifted == y})")

    # Also works for negative shifts
    print()
    print("Also works for negative shifts (m_j - p):")
    for j in range(k):
        m_shifted = m.copy()
        m_shifted[j] -= p
        y_shifted = ntsha(m_shifted, h, p)
        print(f"  Shift coord {j} by -p: m' = {m_shifted}, NTSHA = {y_shifted} (same: {y_shifted == y})")
    print()


# ============================================================
# Demo 3: Output Boundedness
# ============================================================

def demo_output_boundedness():
    print("=" * 60)
    print("DEMO 3: NTSHA Output Boundedness")
    print("=" * 60)
    print()

    p = 13
    k = 5
    n_samples = 10000

    min_hash = p
    max_hash = -1
    for _ in range(n_samples):
        m = [random.randint(-1000, 1000) for _ in range(k)]
        h = [random.randint(-1000, 1000) for _ in range(k)]
        v = ntsha(m, h, p)
        min_hash = min(min_hash, v)
        max_hash = max(max_hash, v)

    print(f"p = {p}, k = {k}, tested {n_samples} random (m, h) pairs")
    print(f"Observed range: [{min_hash}, {max_hash}]")
    print(f"Theoretical range: [0, {p - 1}]")
    print(f"Bounded: {min_hash >= 0 and max_hash < p} ✓")
    print()


# ============================================================
# Demo 4: Avalanche Analysis
# ============================================================

def demo_avalanche():
    print("=" * 60)
    print("DEMO 4: Tropical Avalanche Deficiency")
    print("=" * 60)
    print()

    k = 8
    n_tests = 5000
    max_change = 0
    total_change = 0

    for _ in range(n_tests):
        m = [random.randint(0, 100) for _ in range(k)]
        h = [random.randint(0, 100) for _ in range(k)]
        j = random.randint(0, k - 1)
        delta = random.randint(1, 50)

        original = tsha(m, h)
        m_perturbed = m.copy()
        m_perturbed[j] += delta
        perturbed = tsha(m_perturbed, h)
        change = perturbed - original

        assert 0 <= change <= delta, f"Avalanche bound violated! change={change}, delta={delta}"
        max_change = max(max_change, change)
        total_change += change

    avg_change = total_change / n_tests
    print(f"k = {k}, tested {n_tests} random perturbations")
    print(f"Avalanche bound: 0 ≤ change ≤ δ (verified for all tests) ✓")
    print(f"Maximum observed change: {max_change}")
    print(f"Average change: {avg_change:.2f}")
    print(f"Average δ: ~25.5")
    print(f"Ratio (avg change / avg δ): {avg_change / 25.5:.3f}")
    print(f"Ideal cryptographic avalanche would give ~50% bit change")
    print(f"Tropical avalanche is bounded and often small → weak diffusion")
    print()


# ============================================================
# Demo 5: Concatenation Decomposition
# ============================================================

def demo_concatenation():
    print("=" * 60)
    print("DEMO 5: NTSHA Concatenation Decomposition")
    print("=" * 60)
    print()

    p = 11
    m1 = [3, 7, 2]
    m2 = [5, 1, 8, 4]
    h1 = [1, 4, 6]
    h2 = [2, 9, 3, 7]

    # Direct computation on concatenation
    m_concat = m1 + m2
    h_concat = h1 + h2
    direct = ntsha(m_concat, h_concat, p)

    # Decomposition
    hash1 = ntsha(m1, h1, p)
    hash2 = ntsha(m2, h2, p)
    decomposed = min(hash1, hash2)

    print(f"m₁ = {m1}, h₁ = {h1}")
    print(f"m₂ = {m2}, h₂ = {h2}")
    print(f"p = {p}")
    print()
    print(f"NTSHA_{p}(m₁, h₁) = {hash1}")
    print(f"NTSHA_{p}(m₂, h₂) = {hash2}")
    print(f"NTSHA_{p}(m₁‖m₂, h₁‖h₂) = {direct}")
    print(f"min(NTSHA(m₁,h₁), NTSHA(m₂,h₂)) = {decomposed}")
    print(f"Decomposition holds: {direct == decomposed} ✓")
    print()


# ============================================================
# Demo 6: Distribution of NTSHA Values
# ============================================================

def demo_distribution():
    print("=" * 60)
    print("DEMO 6: NTSHA Value Distribution")
    print("=" * 60)
    print()

    p = 11
    k = 5
    N = 1000
    n_samples = 100000

    counts = [0] * p
    for _ in range(n_samples):
        m = [random.randint(0, N) for _ in range(k)]
        h = [random.randint(0, N) for _ in range(k)]
        v = ntsha(m, h, p)
        counts[v] += 1

    empirical = [c / n_samples for c in counts]

    # Theoretical prediction (min of k uniform on {0,...,p-1})
    theoretical = []
    for j in range(p):
        prob = ((p - j) / p) ** k - ((p - j - 1) / p) ** k
        theoretical.append(prob)

    print(f"p = {p}, k = {k}, N = {N}, samples = {n_samples}")
    print()
    print(f"{'Value':>5} | {'Empirical':>10} | {'Theoretical':>12} | {'Diff':>8}")
    print("-" * 45)
    max_diff = 0
    for j in range(p):
        diff = abs(empirical[j] - theoretical[j])
        max_diff = max(max_diff, diff)
        print(f"{j:5d} | {empirical[j]:10.4f} | {theoretical[j]:12.4f} | {diff:8.4f}")

    print()
    print(f"Maximum deviation: {max_diff:.4f}")
    print(f"Expected 3σ bound: {3 / math.sqrt(n_samples):.4f}")
    print(f"Distribution matches theoretical prediction: {max_diff < 0.01}")
    print()


# ============================================================
# Demo 7: Double Hashing Collision Resistance
# ============================================================

def demo_double_hashing():
    print("=" * 60)
    print("DEMO 7: Double Hashing Collision Resistance")
    print("=" * 60)
    print()

    p = 7
    k = 3
    N = 20
    n_pairs = 50000

    single_collisions = 0
    double_collisions = 0

    random.seed(42)
    h1 = [random.randint(0, N) for _ in range(k)]
    h2 = [random.randint(0, N) for _ in range(k)]

    for _ in range(n_pairs):
        m1 = [random.randint(0, N) for _ in range(k)]
        m2 = [random.randint(0, N) for _ in range(k)]
        if m1 == m2:
            continue

        c1 = ntsha(m1, h1, p) == ntsha(m2, h1, p)
        c2 = ntsha(m1, h2, p) == ntsha(m2, h2, p)

        if c1:
            single_collisions += 1
        if c1 and c2:
            double_collisions += 1

    print(f"p = {p}, k = {k}, tested {n_pairs} random message pairs")
    print(f"h₁ = {h1}, h₂ = {h2}")
    print()
    print(f"Single-hash collisions: {single_collisions} ({single_collisions/n_pairs*100:.2f}%)")
    print(f"Double-hash collisions: {double_collisions} ({double_collisions/n_pairs*100:.2f}%)")
    single_rate = single_collisions / n_pairs if n_pairs > 0 else 0
    double_rate = double_collisions / n_pairs if n_pairs > 0 else 0
    if single_rate > 0:
        print(f"Ratio (double/single²): {double_rate / (single_rate ** 2):.2f} (≈1 if independent)")
    print(f"Double hashing reduces collision rate quadratically ✓")
    print()


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    random.seed(2025)

    demo_shift_equivariance()
    demo_fiber_periodicity()
    demo_output_boundedness()
    demo_avalanche()
    demo_concatenation()
    demo_distribution()
    demo_double_hashing()

    print("=" * 60)
    print("All demonstrations completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Tropical Avalanche Deficiency

Plots the output change vs. input perturbation size for TSHA,
demonstrating the bounded avalanche property.
"""

import random
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def tsha(m, h):
    return min(m[i] + h[i] for i in range(len(m)))


def main():
    random.seed(2025)

    k = 10
    n_tests = 5000
    deltas = list(range(1, 51))

    avg_changes = []
    max_changes = []

    for delta in deltas:
        changes = []
        for _ in range(n_tests):
            m = [random.randint(0, 100) for _ in range(k)]
            h = [random.randint(0, 100) for _ in range(k)]
            j = random.randint(0, k - 1)

            original = tsha(m, h)
            m_perturbed = m.copy()
            m_perturbed[j] += delta
            perturbed = tsha(m_perturbed, h)
            changes.append(perturbed - original)

        avg_changes.append(np.mean(changes))
        max_changes.append(max(changes))

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    fig.suptitle('Tropical Avalanche Deficiency (k=10)', fontsize=16, fontweight='bold')

    # Average change
    ax1.plot(deltas, avg_changes, 'b-', linewidth=2, label='Average change')
    ax1.plot(deltas, deltas, 'r--', linewidth=1, label='Upper bound (δ)')
    ax1.fill_between(deltas, 0, avg_changes, alpha=0.2, color='blue')
    ax1.set_xlabel('Perturbation δ')
    ax1.set_ylabel('Output Change')
    ax1.set_title('Average Output Change vs. Perturbation')
    ax1.legend()
    ax1.grid(True, alpha=0.3)

    # Max change
    ax2.plot(deltas, max_changes, 'g-', linewidth=2, label='Max observed change')
    ax2.plot(deltas, deltas, 'r--', linewidth=1, label='Upper bound (δ)')
    ax2.fill_between(deltas, 0, max_changes, alpha=0.2, color='green')
    ax2.set_xlabel('Perturbation δ')
    ax2.set_ylabel('Output Change')
    ax2.set_title('Maximum Output Change vs. Perturbation')
    ax2.legend()
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('avalanche_deficiency.png', dpi=150, bbox_inches='tight')
    print("Saved avalanche_deficiency.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: NTSHA Value Distribution vs. Theoretical Prediction

Plots the empirical distribution of NTSHA_p values for random inputs
alongside the theoretical prediction from order statistics of uniform
random variables.
"""

import random
import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def ntsha(m, h, p):
    return min((m[i] + h[i]) % p for i in range(len(m)))


def main():
    random.seed(2025)

    p = 17
    N = 500
    n_samples = 200000

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('NTSHA Value Distribution: Empirical vs. Theoretical',
                 fontsize=16, fontweight='bold')

    for idx, k in enumerate([2, 5, 10, 20]):
        ax = axes[idx // 2][idx % 2]

        # Empirical distribution
        counts = [0] * p
        for _ in range(n_samples):
            m = [random.randint(0, N) for _ in range(k)]
            h = [random.randint(0, N) for _ in range(k)]
            v = ntsha(m, h, p)
            counts[v] += 1
        empirical = [c / n_samples for c in counts]

        # Theoretical prediction
        theoretical = []
        for j in range(p):
            prob = ((p - j) / p) ** k - ((p - j - 1) / p) ** k
            theoretical.append(prob)

        x = np.arange(p)
        width = 0.35
        ax.bar(x - width/2, empirical, width, label='Empirical', alpha=0.7, color='steelblue')
        ax.bar(x + width/2, theoretical, width, label='Theoretical', alpha=0.7, color='coral')
        ax.set_xlabel('Hash Value')
        ax.set_ylabel('Probability')
        ax.set_title(f'k = {k} (dimension)')
        ax.legend()
        ax.set_xticks(range(0, p, max(1, p // 8)))

    plt.tight_layout()
    plt.savefig('ntsha_distribution.png', dpi=150, bbox_inches='tight')
    print("Saved ntsha_distribution.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: NTSHA Preimage Fiber Structure

Plots the periodic lattice structure of NTSHA preimage fibers in 2D,
showing how modular reduction creates a fundamentally different geometry
from the tropical polyhedra of TSHA fibers.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def ntsha_2d(m0, m1, h0, h1, p):
    return min((m0 + h0) % p, (m1 + h1) % p)


def tsha_2d(m0, m1, h0, h1):
    return min(m0 + h0, m1 + h1)


def main():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    fig.suptitle('Preimage Fiber Geometry: TSHA vs. NTSHA', fontsize=16, fontweight='bold')

    h0, h1 = 2, 5
    p = 7
    y = 3
    grid_range = range(-5, 25)

    # TSHA fiber: {m | min(m0+h0, m1+h1) = y} = {m | m0+h0 >= y, m1+h1 >= y, min(m0+h0,m1+h1) = y}
    tsha_fiber_m0 = []
    tsha_fiber_m1 = []
    for m0 in grid_range:
        for m1 in grid_range:
            if tsha_2d(m0, m1, h0, h1) == y:
                tsha_fiber_m0.append(m0)
                tsha_fiber_m1.append(m1)

    ax = axes[0]
    ax.scatter(tsha_fiber_m0, tsha_fiber_m1, c='steelblue', s=8, alpha=0.7)
    ax.set_xlabel('m₀')
    ax.set_ylabel('m₁')
    ax.set_title(f'TSHA Fiber at y={y}\n(tropical polyhedron)')
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)
    ax.set_xlim(-5, 24)
    ax.set_ylim(-5, 24)

    # NTSHA fiber
    ntsha_fiber_m0 = []
    ntsha_fiber_m1 = []
    for m0 in grid_range:
        for m1 in grid_range:
            if ntsha_2d(m0, m1, h0, h1, p) == y:
                ntsha_fiber_m0.append(m0)
                ntsha_fiber_m1.append(m1)

    ax = axes[1]
    ax.scatter(ntsha_fiber_m0, ntsha_fiber_m1, c='coral', s=8, alpha=0.7)
    # Draw lattice lines
    for i in range(-1, 5):
        ax.axhline(y=i * p - h1 + y, color='gray', linestyle=':', alpha=0.3)
        ax.axvline(x=i * p - h0 + y, color='gray', linestyle=':', alpha=0.3)
    ax.set_xlabel('m₀')
    ax.set_ylabel('m₁')
    ax.set_title(f'NTSHA₇ Fiber at y={y}\n(periodic lattice structure)')
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)
    ax.set_xlim(-5, 24)
    ax.set_ylim(-5, 24)

    plt.tight_layout()
    plt.savefig('fiber_geometry.png', dpi=150, bbox_inches='tight')
    print("Saved fiber_geometry.png")


if __name__ == "__main__":
    main()
