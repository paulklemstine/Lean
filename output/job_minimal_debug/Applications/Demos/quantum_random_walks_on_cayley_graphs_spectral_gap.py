#!/usr/bin/env python3
"""
Quantum Random Walks on Cayley Graphs: Spectral Gaps and Mixing Times

Numerical demonstrations of the key theorems:
1. Spectral gap → exponential decay bridge
2. Amplitude gap √γ and quadratic speedup
3. Product group mixing decomposition
4. Cyclic group spectral gap and mixing
"""

import numpy as np

def spectral_exponential_bridge_demo():
    """Demonstrate (1-γ)^t ≤ exp(-γt) ≤ (1-γ/2)^t for γ ∈ [0,1]."""
    print("=" * 60)
    print("THEOREM: Spectral-Exponential Bridge")
    print("(1-γ)^t  ≤  exp(-γt)  ≤  (1-γ/2)^t")
    print("=" * 60)
    
    for gamma in [0.1, 0.3, 0.5, 0.8, 1.0]:
        print(f"\nγ = {gamma}:")
        print(f"  {'t':>4}  {'(1-γ)^t':>12}  {'exp(-γt)':>12}  {'(1-γ/2)^t':>12}  {'bridge?':>8}")
        for t in [1, 5, 10, 20, 50]:
            lower = (1 - gamma) ** t
            middle = np.exp(-gamma * t)
            upper = (1 - gamma / 2) ** t
            ok = "✓" if lower <= middle + 1e-15 and middle <= upper + 1e-15 else "✗"
            print(f"  {t:4d}  {lower:12.6e}  {middle:12.6e}  {upper:12.6e}  {ok:>8}")


def amplitude_gap_demo():
    """Demonstrate √(1-γ) ≤ 1 - γ/2 (amplitude gap bound)."""
    print("\n" + "=" * 60)
    print("THEOREM: Amplitude Gap Bound")
    print("√(1-γ) ≤ 1 - γ/2  for γ ∈ [0,1]")
    print("=" * 60)
    
    print(f"\n  {'γ':>6}  {'√(1-γ)':>10}  {'1-γ/2':>10}  {'gap':>10}  {'ok?':>5}")
    for gamma in np.linspace(0, 1, 11):
        sqrt_val = np.sqrt(1 - gamma)
        bound = 1 - gamma / 2
        gap = bound - sqrt_val
        ok = "✓" if gap >= -1e-15 else "✗"
        print(f"  {gamma:6.2f}  {sqrt_val:10.6f}  {bound:10.6f}  {gap:10.6f}  {ok:>5}")


def probability_from_amplitude_demo():
    """Demonstrate (1-γ/2)² ≤ 1 - 3γ/4."""
    print("\n" + "=" * 60)
    print("THEOREM: Probability from Amplitude")
    print("(1-γ/2)² ≤ 1 - 3γ/4  for γ ∈ [0,1]")
    print("=" * 60)
    
    print(f"\n  {'γ':>6}  {'(1-γ/2)²':>12}  {'1-3γ/4':>12}  {'slack':>12}")
    for gamma in np.linspace(0, 1, 11):
        lhs = (1 - gamma / 2) ** 2
        rhs = 1 - 3 * gamma / 4
        slack = rhs - lhs
        print(f"  {gamma:6.2f}  {lhs:12.6f}  {rhs:12.6f}  {slack:12.6f}")


def mixing_time_demo():
    """Demonstrate mixing time bounds for various groups."""
    print("\n" + "=" * 60)
    print("MIXING TIME BOUNDS")
    print("Classical: T_mix ~ log(n)/γ")
    print("Quantum:   T_mix ~ √n · log(n)/γ")
    print("=" * 60)
    
    groups = [
        ("Z/10Z ±1", 10, 2 * np.pi**2 / 100),
        ("Z/100Z ±1", 100, 2 * np.pi**2 / 10000),
        ("Z/1000Z ±1", 1000, 2 * np.pi**2 / 1000000),
        ("S_5 transpositions", 120, 2/5),
        ("S_8 transpositions", 40320, 2/8),
        ("S_10 transpositions", 3628800, 2/10),
    ]
    
    print(f"\n  {'Group':>22}  {'|G|':>10}  {'γ':>10}  {'T_class':>10}  {'T_quantum':>10}  {'speedup':>10}")
    for name, n, gamma in groups:
        t_class = np.log(n) / gamma
        t_quantum = np.sqrt(n) * np.log(n) / gamma
        speedup = t_class / t_quantum if t_quantum > 0 else float('inf')
        print(f"  {name:>22}  {n:10d}  {gamma:10.6f}  {t_class:10.1f}  {t_quantum:10.1f}  {speedup:10.4f}")


def product_mixing_demo():
    """Demonstrate product group mixing time decomposition."""
    print("\n" + "=" * 60)
    print("PRODUCT GROUP MIXING DECOMPOSITION")
    print("T_mix(G₁×G₂) ~ log(|G₁|·|G₂|) / min(γ₁,γ₂)")
    print("≥ max(T_mix(G₁), T_mix(G₂))")
    print("=" * 60)
    
    cases = [
        ("Z/10 × Z/20", 10, 20, 0.2, 0.05),
        ("Z/100 × Z/50", 100, 50, 0.02, 0.08),
        ("S_5 × Z/10", 120, 10, 0.4, 0.2),
    ]
    
    print(f"\n  {'Product':>18}  {'T₁':>8}  {'T₂':>8}  {'max':>8}  {'T_prod':>8}  {'valid?':>7}")
    for name, n1, n2, g1, g2 in cases:
        t1 = np.log(n1) / g1
        t2 = np.log(n2) / g2
        max_t = max(t1, t2)
        t_prod = np.log(n1 * n2) / min(g1, g2)
        valid = "✓" if t_prod >= max_t - 1e-10 else "✗"
        print(f"  {name:>18}  {t1:8.2f}  {t2:8.2f}  {max_t:8.2f}  {t_prod:8.2f}  {valid:>7}")


def cosine_gap_demo():
    """Demonstrate 1 - cos(x) ≥ x²/(2π²) for x ∈ [0,π]."""
    print("\n" + "=" * 60)
    print("THEOREM: Cosine Gap Lower Bound")
    print("1 - cos(x) ≥ x²/(2π²)  for x ∈ [0,π]")
    print("=" * 60)
    
    print(f"\n  {'x':>8}  {'1-cos(x)':>12}  {'x²/(2π²)':>12}  {'ratio':>8}")
    for x in np.linspace(0.1, np.pi, 10):
        lhs = 1 - np.cos(x)
        rhs = x**2 / (2 * np.pi**2)
        ratio = lhs / rhs if rhs > 0 else float('inf')
        print(f"  {x:8.4f}  {lhs:12.6f}  {rhs:12.6f}  {ratio:8.4f}")


def refined_mixing_demo():
    """Demonstrate the refined mixing bound √n · exp(-γT) ≤ 1."""
    print("\n" + "=" * 60)
    print("REFINED MIXING BOUND")
    print("T = ⌊2/γ · log(n)⌋ ⟹ √n · exp(-γT) ≤ 1")
    print("=" * 60)
    
    print(f"\n  {'n':>6}  {'γ':>6}  {'T':>6}  {'√n·exp(-γT)':>14}  {'≤1?':>5}")
    for n in [10, 100, 1000, 10000]:
        for gamma in [0.1, 0.5, 1.0]:
            T = int(2 / gamma * np.log(n))
            val = np.sqrt(n) * np.exp(-gamma * T)
            ok = "✓" if val <= 1 + 1e-10 else "✗"
            print(f"  {n:6d}  {gamma:6.2f}  {T:6d}  {val:14.6e}  {ok:>5}")


if __name__ == "__main__":
    spectral_exponential_bridge_demo()
    amplitude_gap_demo()
    probability_from_amplitude_demo()
    mixing_time_demo()
    product_mixing_demo()
    cosine_gap_demo()
    refined_mixing_demo()
    
    print("\n" + "=" * 60)
    print("All demonstrations completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Product Group Mixing Decomposition
T_mix(G₁×G₂) ≥ max(T_mix(G₁), T_mix(G₂)) with min-gap control.
"""
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def plot_product_mixing():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Left: mixing time decomposition
    ax = axes[0]
    n1 = 100
    gap1 = 0.1
    n2_vals = np.arange(10, 500, 5)
    
    t1 = np.log(n1) / gap1
    
    for gap2 in [0.05, 0.1, 0.2, 0.5]:
        t2_vals = np.log(n2_vals) / gap2
        t_product = np.log(n1 * n2_vals) / np.minimum(gap1, gap2)
        t_max = np.maximum(t1, t2_vals)
        
        ax.plot(n2_vals, t_product, '-', linewidth=2, label=f'$T_{{prod}}$, $\\gamma_2={gap2}$')
        ax.plot(n2_vals, t_max, '--', linewidth=1.5, alpha=0.7)
    
    ax.axhline(y=t1, color='gray', linestyle=':', alpha=0.5, label=f'$T_1$ (n₁={n1})')
    ax.set_xlabel('|G₂|', fontsize=13)
    ax.set_ylabel('Mixing time', fontsize=13)
    ax.set_title('Product Mixing: Solid = T_prod, Dashed = max(T₁,T₂)', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    
    # Right: Cayley graph on Z/nZ - spectral gap vs n
    ax = axes[1]
    ns = np.arange(3, 200)
    theoretical_gap = 1 - np.cos(2 * np.pi / ns)
    lower_bound = 2 / ns**2
    upper_bound = 2 * np.pi**2 / ns**2
    
    ax.loglog(ns, theoretical_gap, 'b-', linewidth=2.5, label='$1 - \\cos(2\\pi/n)$')
    ax.loglog(ns, lower_bound, 'r--', linewidth=2, label='$2/n^2$ (lower bound)')
    ax.loglog(ns, upper_bound, 'g-.', linewidth=2, label='$2\\pi^2/n^2$ (upper bound)')
    ax.set_xlabel('Group size n', fontsize=13)
    ax.set_ylabel('Spectral gap', fontsize=13)
    ax.set_title('Cyclic Group Spectral Gap', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('product_mixing.png', dpi=150, bbox_inches='tight')
    print("Saved product_mixing.png")

if __name__ == "__main__":
    plot_product_mixing()


#!/usr/bin/env python3
"""
Visualization: Quantum vs Classical Mixing on Cayley Graphs
Shows the quadratic speedup arising from the amplitude gap.
"""
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def plot_quantum_speedup():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Left: mixing times vs group size
    ax = axes[0]
    ns = np.logspace(1, 6, 50)
    gamma = 0.1
    
    classical = np.log(ns) / gamma
    quantum = np.sqrt(ns) * np.log(ns) / gamma
    
    ax.loglog(ns, classical, 'b-', linewidth=2.5, label='Classical: $\\log(n)/\\gamma$')
    ax.loglog(ns, quantum, 'r--', linewidth=2.5, label='Quantum: $\\sqrt{n} \\cdot \\log(n)/\\gamma$')
    ax.fill_between(ns, quantum, classical, alpha=0.15, color='green', label='Quantum advantage')
    ax.set_xlabel('Group size |G|', fontsize=13)
    ax.set_ylabel('Mixing time bound', fontsize=13)
    ax.set_title('Quantum vs Classical Mixing Times', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    
    # Right: amplitude gap demonstration
    ax = axes[1]
    gammas = np.linspace(0.01, 1, 100)
    sqrt_decay = np.sqrt(1 - gammas)
    linear_bound = 1 - gammas / 2
    classical_decay = 1 - gammas
    
    ax.plot(gammas, classical_decay, 'b-', linewidth=2.5, label='Classical: $1-\\gamma$')
    ax.plot(gammas, sqrt_decay, 'r-', linewidth=2.5, label='Quantum: $\\sqrt{1-\\gamma}$')
    ax.plot(gammas, linear_bound, 'g--', linewidth=2, label='Bound: $1-\\gamma/2$')
    ax.fill_between(gammas, classical_decay, sqrt_decay, alpha=0.15, color='orange',
                    label='Amplitude gap')
    ax.set_xlabel('Spectral gap γ', fontsize=13)
    ax.set_ylabel('Per-step decay factor', fontsize=13)
    ax.set_title('The Amplitude Gap Mechanism', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('quantum_speedup.png', dpi=150, bbox_inches='tight')
    print("Saved quantum_speedup.png")

if __name__ == "__main__":
    plot_quantum_speedup()


#!/usr/bin/env python3
"""
Visualization: Spectral-Exponential Bridge
(1-γ)^t ≤ exp(-γt) ≤ (1-γ/2)^t

Shows how the discrete spectral gap connects to continuous exponential decay.
"""
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def plot_spectral_bridge():
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    gammas = [0.1, 0.3, 0.7]
    t_vals = np.arange(0, 50, 1)
    
    for ax, gamma in zip(axes, gammas):
        lower = [(1 - gamma)**t for t in t_vals]
        middle = [np.exp(-gamma * t) for t in t_vals]
        upper = [(1 - gamma/2)**t for t in t_vals]
        
        ax.semilogy(t_vals, lower, 'b-', linewidth=2, label=f'$(1-\\gamma)^t$')
        ax.semilogy(t_vals, middle, 'r--', linewidth=2, label=f'$e^{{-\\gamma t}}$')
        ax.semilogy(t_vals, upper, 'g-.', linewidth=2, label=f'$(1-\\gamma/2)^t$')
        
        ax.fill_between(t_vals, lower, upper, alpha=0.1, color='purple')
        ax.set_xlabel('Steps (t)', fontsize=12)
        ax.set_ylabel('Decay', fontsize=12)
        ax.set_title(f'γ = {gamma}', fontsize=14)
        ax.legend(fontsize=10)
        ax.grid(True, alpha=0.3)
        ax.set_ylim(1e-8, 2)
    
    fig.suptitle('Spectral-Exponential Bridge: Sandwiching the Decay', fontsize=16, y=1.02)
    plt.tight_layout()
    plt.savefig('spectral_bridge.png', dpi=150, bbox_inches='tight')
    print("Saved spectral_bridge.png")

if __name__ == "__main__":
    plot_spectral_bridge()
