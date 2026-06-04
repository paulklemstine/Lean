#!/usr/bin/env python3
"""
Quantum Random Walks on Cayley Graphs: Demonstration

Computes spectral gaps, mixing times, and quantum speedup factors
for several families of Cayley graphs.
"""
import math

def spectral_gap_cyclic(n: int) -> float:
    """Spectral gap of the cycle graph C_n (Cayley graph of Z/nZ, S={1,-1})."""
    return 1 - math.cos(2 * math.pi / n)

def spectral_gap_complete(n: int) -> float:
    """Spectral gap of the complete graph K_n."""
    return 1 - 1 / (n - 1)

def classical_mix_time(N: int, gap: float, eps: float = 0.01) -> float:
    """Classical mixing time: (1/γ) · log(N/ε)."""
    return (1 / gap) * (math.log(N) + math.log(1 / eps))

def quantum_mix_time(N: int, gap: float, eps: float = 0.01) -> float:
    """Quantum mixing time: (1/√γ) · log(N/ε)."""
    return (1 / math.sqrt(gap)) * (math.log(N) + math.log(1 / eps))

def speedup_factor(gap: float) -> float:
    """Quantum speedup factor: √(1/γ)."""
    return math.sqrt(1 / gap)

def quantum_advantage_threshold() -> float:
    """Below this spectral gap, quantum speedup > 2."""
    return 0.25

print("=" * 70)
print("QUANTUM RANDOM WALKS ON CAYLEY GRAPHS")
print("Spectral Gaps and Mixing Times")
print("=" * 70)

# Example 1: Cyclic groups Z/nZ
print("\n--- Cyclic Groups Z/nZ (generators {1, -1}) ---")
print(f"{'n':>6} {'γ':>10} {'τ_classical':>14} {'τ_quantum':>14} {'speedup':>10}")
print("-" * 60)
for n in [5, 10, 20, 50, 100, 500, 1000]:
    gap = spectral_gap_cyclic(n)
    tc = classical_mix_time(n, gap)
    tq = quantum_mix_time(n, gap)
    su = speedup_factor(gap)
    print(f"{n:>6} {gap:>10.6f} {tc:>14.2f} {tq:>14.2f} {su:>10.2f}")

# Example 2: Complete graphs K_n
print("\n--- Complete Graphs K_n (all transpositions) ---")
print(f"{'n':>6} {'γ':>10} {'τ_classical':>14} {'τ_quantum':>14} {'speedup':>10}")
print("-" * 60)
for n in [4, 8, 16, 32, 64, 128]:
    gap = spectral_gap_complete(n)
    tc = classical_mix_time(n, gap)
    tq = quantum_mix_time(n, gap)
    su = speedup_factor(gap)
    print(f"{n:>6} {gap:>10.6f} {tc:>14.2f} {tq:>14.2f} {su:>10.2f}")

# Example 3: Quantum advantage threshold
print("\n--- Quantum Advantage Threshold ---")
print(f"Threshold γ* = {quantum_advantage_threshold()}")
print(f"For γ < γ*, speedup > 2 (quantum advantage is meaningful)")
print(f"For γ ≥ γ*, speedup ≤ 2 (quantum advantage is marginal)")
print()
for gap in [0.01, 0.05, 0.1, 0.25, 0.5, 0.9]:
    su = speedup_factor(gap)
    label = "QUANTUM ADVANTAGE" if gap < 0.25 else "marginal"
    print(f"  γ = {gap:.2f}: speedup = {su:.2f}  [{label}]")

# Example 4: Verify cyclic spectral gap lower bound
print("\n--- Verifying γ ≥ 2/n² for Z/nZ ---")
for n in [3, 5, 10, 50, 100]:
    actual = spectral_gap_cyclic(n)
    lower = 2 / n**2
    ratio = actual / lower
    print(f"  n={n:>4}: γ = {actual:.6f}, 2/n² = {lower:.6f}, ratio = {ratio:.2f}")

# Example 5: Bipartite obstruction
print("\n--- Bipartite Obstruction ---")
print("For bipartite Cayley graphs (e.g., Z/2Z):")
print("  eigenvalue λ_min = -1")
print("  spectral gap = 1 - |λ_min| = 1 - 1 = 0")
print("  → NO mixing (walk oscillates)")
print("  This is the periodicity boundary condition.")

print("\n" + "=" * 70)
print("KEY FINDING: Quantum speedup = √(1/γ)")
print("For sparse graphs (small γ), quantum walks are dramatically faster.")
print("For dense graphs (γ ≈ 1), classical walks are already fast enough.")
print("The threshold γ* = 1/4 divides meaningful from marginal speedup.")
print("=" * 70)


#!/usr/bin/env python3
"""
Visualization: Spectral Gap and Mixing Times for Cayley Graphs

Standalone script using matplotlib. All functions inlined.
"""
import math
import matplotlib.pyplot as plt
import numpy as np


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Quantum Random Walks on Cayley Graphs:\nSpectral Gaps and Mixing Times', fontsize=14, fontweight='bold')

    # Panel 1: Spectral gap vs n for cyclic groups
    ax = axes[0, 0]
    ns = np.arange(3, 201)
    gaps = [1 - math.cos(2 * math.pi / n) for n in ns]
    lower_bounds = [2 / n**2 for n in ns]
    ax.semilogy(ns, gaps, 'b-', linewidth=2, label='γ = 1 - cos(2π/n)')
    ax.semilogy(ns, lower_bounds, 'r--', linewidth=1.5, label='Lower bound: 2/n²')
    ax.set_xlabel('n (group order)')
    ax.set_ylabel('Spectral gap γ')
    ax.set_title('Cyclic Group Z/nZ')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Panel 2: Classical vs Quantum mixing times
    ax = axes[0, 1]
    ns = np.arange(5, 501, 5)
    classical_times = []
    quantum_times = []
    for n in ns:
        gap = 1 - math.cos(2 * math.pi / n)
        tc = (1 / gap) * (math.log(n) + math.log(100))
        tq = (1 / math.sqrt(gap)) * (math.log(n) + math.log(100))
        classical_times.append(tc)
        quantum_times.append(tq)
    ax.semilogy(ns, classical_times, 'r-', linewidth=2, label='Classical: (1/γ)·log(N/ε)')
    ax.semilogy(ns, quantum_times, 'b-', linewidth=2, label='Quantum: (1/√γ)·log(N/ε)')
    ax.set_xlabel('n (group order)')
    ax.set_ylabel('Mixing time (steps)')
    ax.set_title('Classical vs Quantum Mixing (Z/nZ)')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Panel 3: Speedup factor vs spectral gap
    ax = axes[1, 0]
    gaps = np.linspace(0.001, 1, 500)
    speedups = [math.sqrt(1 / g) for g in gaps]
    ax.plot(gaps, speedups, 'g-', linewidth=2)
    ax.axvline(x=0.25, color='r', linestyle='--', alpha=0.7, label='γ* = 1/4 (threshold)')
    ax.axhline(y=2, color='orange', linestyle=':', alpha=0.7, label='Speedup = 2')
    ax.fill_between(gaps, speedups, 1, where=[g < 0.25 for g in gaps],
                     alpha=0.15, color='green', label='Meaningful advantage')
    ax.set_xlabel('Spectral gap γ')
    ax.set_ylabel('Speedup factor √(1/γ)')
    ax.set_title('Quantum Advantage Threshold')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(0, 35)

    # Panel 4: Exponential decay bound
    ax = axes[1, 1]
    ts = np.arange(0, 100)
    for gamma in [0.05, 0.1, 0.2, 0.5]:
        geometric = [(1 - gamma)**t for t in ts]
        exponential = [math.exp(-gamma * t) for t in ts]
        ax.plot(ts, geometric, '-', linewidth=1.5, label=f'(1-{gamma})^t')
        ax.plot(ts, exponential, '--', linewidth=1, alpha=0.6)
    ax.set_xlabel('Steps t')
    ax.set_ylabel('Decay')
    ax.set_title('Exponential Decay: (1-γ)^t ≤ exp(-γt)')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(0, 1.05)

    plt.tight_layout()
    plt.savefig('spectral_gap_analysis.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: spectral_gap_analysis.png")


if __name__ == "__main__":
    main()
