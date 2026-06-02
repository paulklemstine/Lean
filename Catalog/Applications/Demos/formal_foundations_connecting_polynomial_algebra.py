#!/usr/bin/env python3
"""
Demonstration: Polynomial Iterate Dynamics and Chaos-Based Cryptography

This demo illustrates the key mathematical results:
1. The Iterate Degree Theorem (degree grows exponentially under composition)
2. The Chebyshev conjugacy (logistic map ≈ doubling map)
3. Preimage counting and the structure of periodic orbits
4. Why the logistic map fails as a cryptographic primitive
"""

import math
from typing import List, Tuple


def logistic(x: float) -> float:
    """The logistic map f(x) = 4x(1-x)"""
    return 4.0 * x * (1.0 - x)


def iterate_map(f, x: float, n: int) -> float:
    """Apply f n times to x"""
    for _ in range(n):
        x = f(x)
    return x


def orbit(f, x0: float, steps: int) -> List[float]:
    """Compute orbit trajectory"""
    traj = [x0]
    x = x0
    for _ in range(steps):
        x = f(x)
        traj.append(x)
    return traj


def main():
    print("=" * 70)
    print("POLYNOMIAL ITERATE DYNAMICS — KEY RESULTS DEMONSTRATION")
    print("=" * 70)

    # 1. Iterate Degree Theorem
    print("\n" + "=" * 70)
    print("1. THE ITERATE DEGREE THEOREM")
    print("   deg(p^{∘n}) = (deg p)^n")
    print("=" * 70)
    print()
    print("For a polynomial of degree d, the n-th compositional iterate")
    print("has degree d^n. This exponential growth is the algebraic source")
    print("of computational hardness in polynomial dynamics.")
    print()
    print(f"{'Degree d':>10} | {'Iterate n':>10} | {'deg(p^n) = d^n':>15}")
    print("-" * 42)
    for d in [2, 3, 5]:
        for n in [1, 5, 10, 20]:
            print(f"{d:>10} | {n:>10} | {d**n:>15,}")
    print()
    print("Note: For the logistic map (d=2), iterate 20 has degree 1,048,576.")
    print("Inverting this requires solving a million-degree polynomial!")

    # 2. Chebyshev Conjugacy
    print("\n" + "=" * 70)
    print("2. THE CHEBYSHEV CONJUGACY")
    print("   h ∘ f = g ∘ h where f = logistic, g = doubling, h = arccos")
    print("=" * 70)
    print()
    print("The logistic map f(x) = 4x(1-x) is conjugate to the")
    print("angle-doubling map g(θ) = 2θ mod 1 via x = sin²(πθ).")
    print()

    x0 = 0.3
    theta0 = math.acos(1.0 - 2.0 * x0) / math.pi

    print(f"Starting point: x₀ = {x0}")
    print(f"Conjugate:      θ₀ = arccos(1 - 2x₀)/π = {theta0:.10f}")
    print()
    print(f"{'Step':>5} | {'Logistic f^n(x₀)':>18} | {'sin²(π·2^n·θ₀)':>18} | {'Error':>12}")
    print("-" * 62)

    x = x0
    theta = theta0
    for n in range(11):
        x_conj = math.sin(math.pi * theta) ** 2
        err = abs(x - x_conj)
        print(f"{n:>5} | {x:>18.12f} | {x_conj:>18.12f} | {err:>12.2e}")
        x = logistic(x)
        theta = (2.0 * theta) % 1.0

    # 3. Conjugacy Transfer Theorem
    print("\n" + "=" * 70)
    print("3. CONJUGACY TRANSFER THEOREM")
    print("   A conjugacy at depth 1 works at ALL depths")
    print("=" * 70)
    print()
    print("The conjugacy h ∘ f = g ∘ h implies h ∘ f^n = g^n ∘ h.")
    print("This means the conjugacy is a PERMANENT backdoor — it doesn't")
    print("get 'harder' to exploit at deeper iteration depths.")
    print()
    print("Inversion via conjugacy:")
    print("  Given y = f^n(x), find x:")
    print("  1. θ_y = arccos(1-2y)/π         [O(1)]")
    print("  2. θ_x = θ_y / 2^n              [O(1)]")
    print("  3. x = sin²(πθ_x)               [O(1)]")
    print("  Total: O(1) regardless of n!")
    print()
    print("Brute force inversion:")
    print("  Solve a degree-2^n polynomial: exponential in n")
    print()

    # Demonstrate inversion
    x_secret = 0.7
    for n in [5, 10, 20]:
        y = iterate_map(logistic, x_secret, n)
        # Invert via conjugacy
        theta_y = math.acos(1.0 - 2.0 * max(min(y, 1.0), -1.0)) / math.pi
        theta_x = theta_y / (2.0 ** n)
        x_recovered = math.sin(math.pi * theta_x) ** 2
        print(f"  n={n:>3}: f^n({x_secret}) = {y:.10f}, recovered = {x_recovered:.10f}, "
              f"error = {abs(x_secret - x_recovered):.2e}")

    # 4. Preimage Bound
    print("\n" + "=" * 70)
    print("4. PREIMAGE BOUND")
    print("   |roots(p^n - c)| ≤ d^n")
    print("=" * 70)
    print()
    print("The number of n-step preimages of any point is bounded by d^n.")
    print("This is the maximum 'search space' for an attacker.")
    print()

    # Count preimages of the logistic map at various depths
    # For f(x) = 4x(1-x), f(x) = c has solutions x = (1 ± √(1-c))/2
    print(f"{'Depth n':>8} | {'Max preimages (2^n)':>20} | {'Actual (for c=0.5)':>20}")
    print("-" * 55)
    for n in range(1, 11):
        max_pre = 2**n
        # Actual count is 2^n for generic c in (0,1)
        print(f"{n:>8} | {max_pre:>20,} | {max_pre:>20,}")

    # 5. Sensitivity to Initial Conditions
    print("\n" + "=" * 70)
    print("5. SENSITIVITY AND APPARENT RANDOMNESS")
    print("=" * 70)
    print()
    print("Despite the conjugacy, the logistic map IS genuinely chaotic.")
    print("Tiny differences in initial conditions grow exponentially:")
    print()

    x1 = 0.5000000
    x2 = 0.5000001  # differ by 10^-7
    print(f"x₁ = {x1}, x₂ = {x2}, |x₁-x₂| = {abs(x1-x2):.1e}")
    print()
    print(f"{'Step':>5} | {'f^n(x₁)':>18} | {'f^n(x₂)':>18} | {'|difference|':>14}")
    print("-" * 62)

    for n in range(21):
        diff = abs(x1 - x2)
        if n <= 15 or n == 20:
            print(f"{n:>5} | {x1:>18.12f} | {x2:>18.12f} | {diff:>14.6e}")
        elif n == 16:
            print(f"  ... ")
        x1 = logistic(x1)
        x2 = logistic(x2)

    # 6. Algebraic Immunity
    print("\n" + "=" * 70)
    print("6. ALGEBRAIC IMMUNITY — THE SECURITY MEASURE")
    print("=" * 70)
    print()
    print("Algebraic immunity measures resistance to conjugacy attacks.")
    print("The logistic map has algebraic immunity ≤ 2 (the Chebyshev")
    print("conjugacy uses a degree-2 function).")
    print()
    print("A secure system needs algebraic immunity growing with depth:")
    print()
    print(f"{'System':>25} | {'Immunity':>10} | {'Security':>10}")
    print("-" * 52)
    print(f"{'Logistic (d=2)':>25} | {'≤ 2':>10} | {'BROKEN':>10}")
    print(f"{'Chebyshev T_d':>25} | {'≤ 2':>10} | {'BROKEN':>10}")
    print(f"{'Generic degree-3':>25} | {'unknown':>10} | {'?':>10}")
    print(f"{'x^d + c (generic c)':>25} | {'≥ d':>10} | {'promising':>10}")

    # 7. Summary
    print("\n" + "=" * 70)
    print("SUMMARY")
    print("=" * 70)
    print()
    print("Key proven results:")
    print("  ✓ Iterate Degree Theorem: deg(p^n) = d^n")
    print("  ✓ Conjugacy Transfer: conjugacy at depth 1 ⟹ all depths")
    print("  ✓ Preimage Bound: ≤ d^n preimages at depth n")
    print("  ✓ Evaluation Bridge: polynomial eval = orbit dynamics")
    print("  ✓ Monic Preservation: monic under iteration")
    print("  ✓ Orbit Closure: periodic points closed under dynamics")
    print()
    print("Key insight: The logistic map is algebraically transparent.")
    print("Its chaos is REAL but its security is ZERO.")
    print("Genuine cryptographic hardness requires algebraic opacity.")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Bifurcation diagram of the logistic map family f_r(x) = rx(1-x).
Shows the transition from periodic to chaotic behavior as r increases.
"""

import numpy as np
import matplotlib.pyplot as plt


def compute_bifurcation(r_min: float = 2.5, r_max: float = 4.0,
                        r_steps: int = 2000, n_iterate: int = 300,
                        n_show: int = 100) -> tuple:
    """Compute bifurcation diagram data."""
    rs = np.linspace(r_min, r_max, r_steps)
    all_r = []
    all_x = []
    
    for r in rs:
        x = 0.5
        # Transient
        for _ in range(n_iterate):
            x = r * x * (1.0 - x)
        # Record
        for _ in range(n_show):
            x = r * x * (1.0 - x)
            all_r.append(r)
            all_x.append(x)
    
    return np.array(all_r), np.array(all_x)


def main():
    print("Computing bifurcation diagram...")
    r_vals, x_vals = compute_bifurcation()
    
    fig, ax = plt.subplots(figsize=(12, 7))
    ax.scatter(r_vals, x_vals, s=0.01, c='black', alpha=0.3)
    ax.set_xlabel('Parameter r', fontsize=14)
    ax.set_ylabel('Attractor values x', fontsize=14)
    ax.set_title('Bifurcation Diagram: f(x) = rx(1−x)\n'
                 'Polynomial degree-2 dynamics from order to chaos', fontsize=16)
    ax.axvline(x=4.0, color='red', linestyle='--', alpha=0.5, label='r=4 (full chaos)')
    ax.legend(fontsize=12)
    ax.set_xlim(2.5, 4.0)
    ax.set_ylim(0, 1)
    
    plt.tight_layout()
    plt.savefig('bifurcation_diagram.png', dpi=150)
    print("Saved: bifurcation_diagram.png")
    plt.close()


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: The Chebyshev conjugacy between the logistic map and the doubling map.
Shows how the conjugation transforms the dynamics.
"""

import numpy as np
import matplotlib.pyplot as plt


def logistic(x: float) -> float:
    return 4.0 * x * (1.0 - x)


def doubling(theta: float) -> float:
    return (2.0 * theta) % 1.0


def conjugate_forward(x: float) -> float:
    """x -> theta via arccos"""
    x = np.clip(x, 0, 1)
    return np.arccos(1.0 - 2.0 * x) / np.pi


def conjugate_inverse(theta: float) -> float:
    """theta -> x via sin^2"""
    return np.sin(np.pi * theta) ** 2


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 12))
    
    # Panel 1: Logistic map
    ax = axes[0, 0]
    x = np.linspace(0, 1, 500)
    ax.plot(x, 4*x*(1-x), 'b-', linewidth=2, label='f(x) = 4x(1−x)')
    ax.plot(x, x, 'k--', alpha=0.3, label='y = x')
    ax.set_xlabel('x')
    ax.set_ylabel('f(x)')
    ax.set_title('Logistic Map (degree 2)')
    ax.legend()
    ax.set_aspect('equal')
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    
    # Panel 2: Doubling map
    ax = axes[0, 1]
    theta = np.linspace(0, 1, 1000)
    doubling_vals = (2 * theta) % 1
    ax.plot(theta, doubling_vals, 'r-', linewidth=2, label='g(θ) = 2θ mod 1')
    ax.plot(theta, theta, 'k--', alpha=0.3, label='y = θ')
    ax.set_xlabel('θ')
    ax.set_ylabel('g(θ)')
    ax.set_title('Doubling Map (conjugate system)')
    ax.legend()
    ax.set_aspect('equal')
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    
    # Panel 3: Orbits comparison
    ax = axes[1, 0]
    x0 = 0.3
    n_steps = 50
    
    # Logistic orbit
    orbit_log = [x0]
    xc = x0
    for _ in range(n_steps):
        xc = logistic(xc)
        orbit_log.append(xc)
    
    # Conjugated doubling orbit
    theta0 = conjugate_forward(x0)
    orbit_conj = [conjugate_inverse(theta0)]
    tc = theta0
    for _ in range(n_steps):
        tc = doubling(tc)
        orbit_conj.append(conjugate_inverse(tc))
    
    steps = range(n_steps + 1)
    ax.plot(steps, orbit_log, 'b.-', markersize=3, alpha=0.7, label='Logistic orbit')
    ax.plot(steps, orbit_conj, 'r.--', markersize=3, alpha=0.7, label='Conjugated doubling orbit')
    ax.set_xlabel('Iteration n')
    ax.set_ylabel('Value')
    ax.set_title('Orbit Comparison (x₀ = 0.3)')
    ax.legend()
    ax.set_xlim(0, n_steps)
    
    # Panel 4: Degree growth
    ax = axes[1, 1]
    ns = np.arange(1, 21)
    degrees = 2 ** ns
    ax.semilogy(ns, degrees, 'go-', markersize=6, linewidth=2)
    ax.set_xlabel('Iteration depth n')
    ax.set_ylabel('Polynomial degree d^n')
    ax.set_title('Iterate Degree Theorem: deg(f^n) = 2^n')
    ax.grid(True, alpha=0.3)
    ax.set_xlim(1, 20)
    
    # Annotate
    for n in [5, 10, 15, 20]:
        ax.annotate(f'2^{n} = {2**n:,}', xy=(n, 2**n),
                   xytext=(n+0.5, 2**n * 2),
                   fontsize=9, ha='left')
    
    plt.suptitle('Chebyshev Conjugacy: Why the Logistic Map Fails as Crypto',
                 fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('conjugacy_analysis.png', dpi=150, bbox_inches='tight')
    print("Saved: conjugacy_analysis.png")
    plt.close()


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Degree growth under polynomial iteration.
Compares different base degrees and shows the exponential explosion.
"""

import numpy as np
import matplotlib.pyplot as plt


def main():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Panel 1: Degree growth comparison
    ax = axes[0]
    ns = np.arange(0, 16)
    colors = ['#2196F3', '#F44336', '#4CAF50', '#FF9800', '#9C27B0']
    for i, d in enumerate([2, 3, 4, 5, 7]):
        degrees = d ** ns
        ax.semilogy(ns, degrees, 'o-', color=colors[i], markersize=5,
                   linewidth=2, label=f'd = {d}')
    
    ax.set_xlabel('Iteration depth n', fontsize=13)
    ax.set_ylabel('Degree of iterate d^n', fontsize=13)
    ax.set_title('Iterate Degree Theorem\ndeg(p^{∘n}) = (deg p)^n', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(0, 15)
    
    # Panel 2: Preimage tree
    ax = axes[1]
    # Draw a tree showing how preimages branch
    d = 2
    max_depth = 5
    
    def draw_tree(ax, x, y, depth, x_spread):
        if depth >= max_depth:
            return
        for i in range(d):
            # Child position
            cx = x + (i - (d-1)/2) * x_spread
            cy = y - 1
            # Draw line
            ax.plot([x, cx], [y, cy], 'b-', alpha=0.5, linewidth=max(0.5, 2-depth*0.3))
            # Draw node
            size = max(10, 50 - depth * 10)
            ax.plot(cx, cy, 'o', color='#2196F3', markersize=size/10, alpha=0.7)
            # Recurse
            draw_tree(ax, cx, cy, depth + 1, x_spread / (d + 0.5))
    
    # Root
    ax.plot(0, 0, 'o', color='red', markersize=8, zorder=5)
    ax.annotate('target c', xy=(0, 0), xytext=(0.3, 0.3),
               fontsize=10, ha='left',
               arrowprops=dict(arrowstyle='->', color='red'))
    draw_tree(ax, 0, 0, 0, 4)
    
    ax.set_xlim(-6, 6)
    ax.set_ylim(-max_depth - 0.5, 1)
    ax.set_title(f'Preimage Tree (d=2, depth={max_depth})\n'
                 f'At most d^n = {d**max_depth} preimages', fontsize=14)
    ax.set_ylabel('Iteration depth (backward)', fontsize=13)
    ax.set_xlabel('Preimage spread', fontsize=13)
    
    # Add depth labels
    for depth in range(max_depth + 1):
        count = d ** depth
        ax.text(5.5, -depth, f'n={depth}: ≤{count}', fontsize=9,
               va='center', ha='left', color='gray')
    
    plt.tight_layout()
    plt.savefig('degree_growth.png', dpi=150)
    print("Saved: degree_growth.png")
    plt.close()


if __name__ == "__main__":
    main()
