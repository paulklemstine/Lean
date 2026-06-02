#!/usr/bin/env python3
"""
NTSHA Demo — Nonlinear Tropical Secure Hash Algorithm
Demonstrates key properties with numerical examples.
"""

from algorithms import (
    tropical_hash, ntsha, avalanche_deficiency,
    avalanche_zero_proportion, verify_shift_equivariance_tsha,
    verify_shift_break_ntsha, fiber_periodicity_check,
    ntsha_fiber, preimage_count_by_modulus
)


def demo_basic_hashing():
    """Demonstrate basic TSHA vs NTSHA computation."""
    print("=" * 60)
    print("DEMO 1: Basic Hash Computation")
    print("=" * 60)

    m = [3, 7, 1, 5]
    h = [2, 1, 4, 3]
    p = 11

    tsha_val = tropical_hash(m, h)
    ntsha_val = ntsha(p, m, h)

    print(f"Message:  m = {m}")
    print(f"Key:      h = {h}")
    print(f"Modulus:  p = {p}")
    print(f"\nComponent sums: {[mi + hi for mi, hi in zip(m, h)]}")
    print(f"Component sums mod {p}: {[(mi + hi) % p for mi, hi in zip(m, h)]}")
    print(f"\nTSHA(m, h)    = min(sums)     = {tsha_val}")
    print(f"NTSHA_{p}(m, h) = min(sums mod {p}) = {ntsha_val}")


def demo_shift_equivariance():
    """Demonstrate shift equivariance breaking."""
    print("\n" + "=" * 60)
    print("DEMO 2: Shift Equivariance — TSHA vs NTSHA")
    print("=" * 60)

    m = [0, 3]
    h = [0, 0]
    c = 3
    p = 5

    m_shifted = [mi + c for mi in m]

    # TSHA
    tsha_orig = tropical_hash(m, h)
    tsha_shifted = tropical_hash(m_shifted, h)
    print(f"\nTSHA (shift-equivariant):")
    print(f"  TSHA(m, h) = {tsha_orig}")
    print(f"  TSHA(m+{c}, h) = {tsha_shifted}")
    print(f"  TSHA(m, h) + {c} = {tsha_orig + c}")
    print(f"  Equal? {tsha_shifted == tsha_orig + c} ✓")

    # NTSHA
    ntsha_orig = ntsha(p, m, h)
    ntsha_shifted = ntsha(p, m_shifted, h)
    expected = (ntsha_orig + c) % p
    print(f"\nNTSHA_{p} (shift equivariance BROKEN):")
    print(f"  NTSHA(m, h) = {ntsha_orig}")
    print(f"  NTSHA(m+{c}, h) = {ntsha_shifted}")
    print(f"  (NTSHA(m, h) + {c}) mod {p} = {expected}")
    print(f"  Equal? {ntsha_shifted == expected} ✗ — Equivariance is broken!")

    # Statistical test
    breaks, total = verify_shift_break_ntsha(p=7, k=4, trials=5000)
    print(f"\n  Random test (p=7, k=4): {breaks}/{total} "
          f"({100*breaks/total:.1f}%) of shifts break equivariance")


def demo_fiber_periodicity():
    """Demonstrate the lattice structure of preimage fibers."""
    print("\n" + "=" * 60)
    print("DEMO 3: Fiber Periodicity — Lattice Structure")
    print("=" * 60)

    p = 5
    h = [0, 0]
    y = 2

    fiber = ntsha_fiber(p, h, y, bound=15)
    print(f"\nNTSHA_{p} fiber for y={y}, h={h}:")
    print(f"  Messages m in [0,15)² with NTSHA_{p}(m, h) = {y}:")
    for m in fiber[:20]:
        components = [(mi + hi) % p for mi, hi in zip(m, h)]
        print(f"    m = {m}, components mod {p} = {components}, "
              f"min = {min(components)}")
    if len(fiber) > 20:
        print(f"    ... and {len(fiber) - 20} more")
    print(f"  Total fiber size: {len(fiber)}")

    # Verify periodicity
    ok = fiber_periodicity_check(p=7, k=3, trials=500)
    print(f"\n  Periodicity verified (p=7, k=3, 500 trials): {ok}")


def demo_avalanche():
    """Demonstrate avalanche behavior analysis."""
    print("\n" + "=" * 60)
    print("DEMO 4: Avalanche Analysis")
    print("=" * 60)

    for p in [5, 7, 11]:
        for k in [2, 3, 4]:
            h = [0] * k
            prop = avalanche_zero_proportion(p, k, h, 0)
            print(f"  p={p:2d}, k={k}: zero-avalanche proportion = "
                  f"{prop:.4f} (threshold 1/k = {1/k:.4f})")


def demo_collision_structure():
    """Demonstrate collision existence from fiber periodicity."""
    print("\n" + "=" * 60)
    print("DEMO 5: Collision Structure")
    print("=" * 60)

    p = 7
    m = [3, 5, 1]
    h = [2, 4, 6]

    y = ntsha(p, m, h)
    print(f"  Original: m = {m}, h = {h}")
    print(f"  NTSHA_{p}(m, h) = {y}")

    # Generate collisions via lattice shifts
    print(f"\n  Collisions via (p={p})ℤ³ lattice shifts:")
    for j in range(3):
        m_collision = m.copy()
        m_collision[j] += p
        y_collision = ntsha(p, m_collision, h)
        print(f"    m' = {m_collision} → NTSHA = {y_collision} "
              f"{'✓' if y_collision == y else '✗'}")

    for j in range(3):
        m_collision = m.copy()
        m_collision[j] -= p
        y_collision = ntsha(p, m_collision, h)
        print(f"    m' = {m_collision} → NTSHA = {y_collision} "
              f"{'✓' if y_collision == y else '✗'}")


def demo_preimage_distribution():
    """Analyze preimage distribution across hash values."""
    print("\n" + "=" * 60)
    print("DEMO 6: Preimage Distribution Analysis")
    print("=" * 60)

    results = preimage_count_by_modulus([3, 5, 7], k=3)
    for p, data in results.items():
        print(f"\n  p = {p}, k = 3:")
        print(f"    Hash value distribution: {data['distribution']}")
        print(f"    Expected avg fiber: {data['expected_avg']:.1f}")
        print(f"    Actual avg fiber:   {data['actual_avg']:.1f}")
        print(f"    Max fiber: {data['max_fiber']}, Min fiber: {data['min_fiber']}")
        print(f"    Imbalance ratio: {data['max_fiber']/data['min_fiber']:.2f}")


if __name__ == "__main__":
    demo_basic_hashing()
    demo_shift_equivariance()
    demo_fiber_periodicity()
    demo_avalanche()
    demo_collision_structure()
    demo_preimage_distribution()
    print("\n" + "=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: NTSHA Fiber Structure and Avalanche Properties
Standalone matplotlib script — all functions inlined.
"""

import matplotlib.pyplot as plt
import numpy as np


def ntsha_val(p, m, h):
    """Compute NTSHA_p(m, h) = min_i((m_i + h_i) mod p)."""
    return min((mi + hi) % p for mi, hi in zip(m, h))


def fiber_size(p, y, k):
    """Exact fiber size for h=0: (p-y)^k - (p-y-1)^k."""
    return (p - y) ** k - (p - y - 1) ** k


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('NTSHA: Nonlinear Tropical Secure Hash Algorithm', fontsize=16, fontweight='bold')

    # Plot 1: Fiber size distribution
    ax = axes[0, 0]
    for k in [2, 3, 4, 5]:
        p = 11
        ys = list(range(p))
        sizes = [fiber_size(p, y, k) for y in ys]
        ax.bar([y + 0.2 * (k - 3) for y in ys], sizes, width=0.18,
               label=f'k={k}', alpha=0.8)
    ax.set_xlabel('Hash value y')
    ax.set_ylabel('Fiber size |F_y|')
    ax.set_title(f'Preimage Fiber Sizes (p={p})')
    ax.legend()
    ax.set_yscale('log')

    # Plot 2: Shift equivariance breaking rate
    ax = axes[0, 1]
    ps = [3, 5, 7, 11, 13, 17, 19, 23]
    for k in [2, 3, 4]:
        rates = []
        for p in ps:
            breaks = 0
            total = min(2000, p ** k)
            for idx in range(total):
                m = []
                temp = idx
                for _ in range(k):
                    m.append(temp % p)
                    temp //= p
                h = [0] * k
                c = 1
                m_shifted = [mi + c for mi in m]
                if ntsha_val(p, m_shifted, h) != (ntsha_val(p, m, h) + c) % p:
                    breaks += 1
            rates.append(breaks / total)
        ax.plot(ps, rates, 'o-', label=f'k={k}', markersize=5)
    ax.set_xlabel('Modulus p')
    ax.set_ylabel('Equivariance breaking rate')
    ax.set_title('Shift Equivariance Breaking Rate')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Plot 3: Fiber heatmap for k=2
    ax = axes[1, 0]
    p = 7
    h_vec = [0, 0]
    grid = np.zeros((p, p))
    for m0 in range(p):
        for m1 in range(p):
            grid[m1, m0] = ntsha_val(p, [m0, m1], h_vec)
    im = ax.imshow(grid, cmap='viridis', origin='lower', aspect='equal')
    ax.set_xlabel('m₀')
    ax.set_ylabel('m₁')
    ax.set_title(f'NTSHA₇ hash values (k=2, h=0)')
    plt.colorbar(im, ax=ax, label='Hash value')

    # Plot 4: Avalanche deficiency distribution
    ax = axes[1, 1]
    for p in [5, 7, 11]:
        k = 3
        h_vec = [0] * k
        deficiencies = {}
        for idx in range(p ** k):
            m = []
            temp = idx
            for _ in range(k):
                m.append(temp % p)
                temp //= p
            m_pert = m.copy()
            m_pert[0] += 1
            d = abs(ntsha_val(p, m_pert, h_vec) - ntsha_val(p, m, h_vec))
            deficiencies[d] = deficiencies.get(d, 0) + 1
        total = p ** k
        ds = sorted(deficiencies.keys())
        probs = [deficiencies[d] / total for d in ds]
        ax.bar([d + 0.25 * (p - 7) / 6 for d in ds], probs,
               width=0.2, label=f'p={p}', alpha=0.8)
    ax.set_xlabel('Avalanche deficiency')
    ax.set_ylabel('Probability')
    ax.set_title('Avalanche Deficiency Distribution (k=3)')
    ax.legend()

    plt.tight_layout()
    plt.savefig('ntsha_analysis.png', dpi=150, bbox_inches='tight')
    print("Saved ntsha_analysis.png")


if __name__ == "__main__":
    main()
