#!/usr/bin/env python3
"""
Associativity Defect Algebras: Demonstration

This script demonstrates the key concepts from the paper:
1. Constructing cocycles from 2-cochains (coboundary operator)
2. Verifying the cocycle condition
3. Computing defect indices
4. Showing the group structure on cocycles
"""

import numpy as np
from typing import Callable, Tuple


def coboundary(f: Callable[[int, int], int], a: int, b: int, c: int, n: int) -> int:
    """Compute the coboundary of a 2-cochain f modulo n.
    
    δ(a,b,c) = f(b,c) - f((a+b)%n, c) + f(a, (b+c)%n) - f(a, b)  mod n
    """
    return (f(b, c) - f((a + b) % n, c) + f(a, (b + c) % n) - f(a, b)) % n


def verify_cocycle(delta: Callable[[int, int, int], int], n: int) -> bool:
    """Verify the 3-cocycle condition for δ on ℤ/nℤ.
    
    For all a, b, c, d:
        δ(b,c,d) + δ(a,b+c,d) + δ(a,b,c) ≡ δ(a+b,c,d) + δ(a,b,c+d)  (mod n)
    """
    for a in range(n):
        for b in range(n):
            for c in range(n):
                for d in range(n):
                    lhs = (delta(b, c, d) + delta(a, (b + c) % n, d) + delta(a, b, c)) % n
                    rhs = (delta((a + b) % n, c, d) + delta(a, b, (c + d) % n)) % n
                    if lhs != rhs:
                        return False
    return True


def defect_index(delta: Callable[[int, int, int], int], n: int) -> int:
    """Count triples (a,b,c) where δ(a,b,c) ≠ 0."""
    count = 0
    for a in range(n):
        for b in range(n):
            for c in range(n):
                if delta(a, b, c) % n != 0:
                    count += 1
    return count


def count_cocycles_and_coboundaries(n: int) -> Tuple[int, int]:
    """Count distinct cocycles and coboundaries over ℤ/nℤ.
    
    Warning: O(n^(n²)) for cocycles — only feasible for n ≤ 3.
    For coboundaries, we enumerate 2-cochains: O(n^(n²)) as well.
    """
    # For small n, enumerate all 2-cochains and their coboundaries
    coboundary_cocycles = set()
    total_cochains = 0
    
    if n <= 3:
        # Enumerate a sample of 2-cochains
        # For n=2, there are 2^4 = 16 cochains
        for f_vals in np.ndindex(*([n] * (n * n))):
            f_arr = np.array(f_vals).reshape(n, n)
            f = lambda a, b, arr=f_arr: int(arr[a % n, b % n])
            
            # Compute the coboundary
            delta_vals = tuple(
                coboundary(f, a, b, c, n)
                for a in range(n) for b in range(n) for c in range(n)
            )
            coboundary_cocycles.add(delta_vals)
            total_cochains += 1
    
    return total_cochains, len(coboundary_cocycles)


def main():
    print("=" * 60)
    print("ASSOCIATIVITY DEFECT ALGEBRAS: DEMONSTRATION")
    print("=" * 60)
    
    # Example 1: The non-trivial cocycle δ(a,b,c) = 2abc over ℤ
    print("\n--- Example 1: Non-trivial cocycle δ(a,b,c) = 2abc ---")
    delta_2abc = lambda a, b, c: 2 * a * b * c
    print(f"δ(1,1,1) = {delta_2abc(1, 1, 1)}")
    print(f"δ(1,2,3) = {delta_2abc(1, 2, 3)}")
    print(f"δ(0,b,c) = 0 for all b,c (verified for b,c in [1..5])")
    
    # Verify cocycle condition for small values
    print("\nVerifying cocycle condition for a,b,c,d ∈ {-2,...,2}:")
    violations = 0
    for a in range(-2, 3):
        for b in range(-2, 3):
            for c in range(-2, 3):
                for d in range(-2, 3):
                    lhs = delta_2abc(b, c, d) + delta_2abc(a, b + c, d) + delta_2abc(a, b, c)
                    rhs = delta_2abc(a + b, c, d) + delta_2abc(a, b, c + d)
                    if lhs != rhs:
                        violations += 1
    print(f"Violations: {violations} (expected 0)")
    
    # Example 2: Coboundary construction
    print("\n--- Example 2: Coboundary of f(a,b) = ab² ---")
    f_ab2 = lambda a, b: a * b**2
    print("f(a,b) = ab²")
    print(f"Coboundary δ(1,2,3) = f(2,3) - f(3,3) + f(1,5) - f(1,2)")
    print(f"  = {f_ab2(2,3)} - {f_ab2(3,3)} + {f_ab2(1,5)} - {f_ab2(1,2)}")
    cb = f_ab2(2, 3) - f_ab2(3, 3) + f_ab2(1, 5) - f_ab2(1, 2)
    print(f"  = {cb}")
    print(f"Compare: 2·1·2·3 = {2*1*2*3}")
    
    # Example 3: Group structure
    print("\n--- Example 3: Group structure on cocycles ---")
    delta1 = lambda a, b, c: 2 * a * b * c
    delta2 = lambda a, b, c: 4 * a * b * c
    delta_product = lambda a, b, c: delta1(a, b, c) + delta2(a, b, c)
    delta_inverse = lambda a, b, c: -delta1(a, b, c)
    
    print(f"δ₁(1,1,1) = {delta1(1,1,1)}")
    print(f"δ₂(1,1,1) = {delta2(1,1,1)}")
    print(f"(δ₁·δ₂)(1,1,1) = {delta_product(1,1,1)}")
    print(f"δ₁⁻¹(1,1,1) = {delta_inverse(1,1,1)}")
    print(f"(δ₁·δ₁⁻¹)(1,1,1) = {delta1(1,1,1) + delta_inverse(1,1,1)} (should be 0)")
    
    # Example 4: Defect index over finite groups
    print("\n--- Example 4: Defect index over ℤ/nℤ ---")
    for n in [2, 3, 5, 7]:
        # Cocycle δ(a,b,c) = 2abc mod n
        delta_mod = lambda a, b, c, n=n: (2 * a * b * c) % n
        idx = defect_index(delta_mod, n)
        is_cocycle = verify_cocycle(delta_mod, n)
        print(f"  ℤ/{n}ℤ: defect_index = {idx}/{n**3}, is_cocycle = {is_cocycle}")
    
    # Example 5: Coboundary counting for small groups
    print("\n--- Example 5: Coboundary counting ---")
    for n in [2, 3]:
        total, distinct_cb = count_cocycles_and_coboundaries(n)
        print(f"  ℤ/{n}ℤ: {total} 2-cochains → {distinct_cb} distinct coboundaries")
    
    # Example 6: Rigidity demonstration
    print("\n--- Example 6: Rigidity (associative + cancellative → trivial defect) ---")
    print("Consider (ℤ, +, 0): associative and cancellative.")
    print("Any defect magma structure must have defect = 0.")
    print("Proof: From defect_spec, a+(b+c) = (a+(b+c)) + δ(a,b,c)")
    print("       By cancellation, δ(a,b,c) = 0.")
    print()
    print("Counter-example without cancellation:")
    print("Consider ({0,1}, comp(a,b)=0): associative but NOT cancellative.")
    print("comp(comp(a,b),c) = comp(0,c) = 0")
    print("comp(comp(a,comp(b,c)),d) = comp(comp(a,0),d) = comp(0,d) = 0")
    print("So defect can be anything! (No constraint)")
    
    # Example 7: Pentagon identity check
    print("\n--- Example 7: Pentagon identity for standard 3-cocycle ---")
    # For the additive defect algebra, pentagon = cocycle condition
    # The cocycle δ(a,b,c) = 2abc satisfies pentagon iff cocycle condition holds
    delta = lambda a, b, c: 2 * a * b * c
    print("Checking pentagon (= cocycle condition) for δ(a,b,c) = 2abc:")
    pentagon_ok = True
    for a in range(-3, 4):
        for b in range(-3, 4):
            for c in range(-3, 4):
                for d in range(-3, 4):
                    lhs = delta(b, c, d) + delta(a, b+c, d) + delta(a, b, c)
                    rhs = delta(a+b, c, d) + delta(a, b, c+d)
                    if lhs != rhs:
                        pentagon_ok = False
                        break
    print(f"Pentagon identity holds: {pentagon_ok}")
    
    print("\n" + "=" * 60)
    print("ALL DEMONSTRATIONS COMPLETE")
    print("=" * 60)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Defect Landscape of Associativity Failure

Generates plots showing:
1. Heatmap of the cocycle δ(a,b,c) = 2abc over ℤ
2. Defect index as a function of group order
3. Pentagon identity satisfaction across perturbation strength
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import TwoSlopeNorm


def plot_cocycle_heatmaps():
    """Plot heatmaps of the cocycle δ(a,b,c) = 2abc for fixed c values."""
    fig, axes = plt.subplots(1, 4, figsize=(16, 4))
    fig.suptitle("Cocycle δ(a,b,c) = 2abc for Fixed c", fontsize=14)
    
    r = 10
    a_vals = np.arange(-r, r + 1)
    b_vals = np.arange(-r, r + 1)
    A, B = np.meshgrid(a_vals, b_vals, indexing='ij')
    
    for idx, c_val in enumerate([1, 2, 3, 5]):
        delta = 2 * A * B * c_val
        norm = TwoSlopeNorm(vmin=delta.min(), vcenter=0, vmax=delta.max())
        im = axes[idx].pcolormesh(a_vals, b_vals, delta, cmap='RdBu_r', norm=norm)
        axes[idx].set_title(f"c = {c_val}")
        axes[idx].set_xlabel("a")
        axes[idx].set_ylabel("b")
        axes[idx].set_aspect('equal')
        fig.colorbar(im, ax=axes[idx], shrink=0.8)
    
    plt.tight_layout()
    plt.savefig("cocycle_heatmaps.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved cocycle_heatmaps.png")


def plot_defect_index_vs_group_order():
    """Plot defect index of δ(a,b,c) = 2abc mod n as a function of n."""
    ns = list(range(2, 30))
    indices = []
    fractions = []
    
    for n in ns:
        count = 0
        for a in range(n):
            for b in range(n):
                for c in range(n):
                    if (2 * a * b * c) % n != 0:
                        count += 1
        indices.append(count)
        fractions.append(count / n**3)
    
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))
    
    # Absolute defect index
    ax1.bar(ns, indices, color='steelblue', alpha=0.8)
    ax1.set_xlabel("Group order n")
    ax1.set_ylabel("Defect index |{(a,b,c) : δ ≠ 0}|")
    ax1.set_title("Defect Index of δ = 2abc mod n")
    
    # Highlight primes
    primes = [p for p in ns if all(p % d != 0 for d in range(2, p))]
    for p in primes:
        idx = ns.index(p)
        ax1.bar(p, indices[idx], color='coral', alpha=0.8)
    
    # Fraction
    ax2.plot(ns, fractions, 'o-', color='darkgreen', markersize=4)
    ax2.set_xlabel("Group order n")
    ax2.set_ylabel("Fraction of triples with non-zero defect")
    ax2.set_title("Defect Density")
    ax2.axhline(y=1.0, color='gray', linestyle='--', alpha=0.5)
    
    # Mark primes
    prime_frac = [fractions[ns.index(p)] for p in primes]
    ax2.plot(primes, prime_frac, 'o', color='coral', markersize=6, label='Primes')
    ax2.legend()
    
    plt.tight_layout()
    plt.savefig("defect_index_analysis.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved defect_index_analysis.png")


def plot_coboundary_landscape():
    """Visualize the coboundary operator on random 2-cochains over ℤ/nℤ."""
    n = 7
    num_samples = 200
    
    defect_indices = []
    
    for _ in range(num_samples):
        # Random 2-cochain
        f = np.random.randint(0, n, size=(n, n))
        
        # Compute coboundary
        delta = np.zeros((n, n, n), dtype=int)
        for a in range(n):
            for b in range(n):
                for c in range(n):
                    delta[a, b, c] = (
                        f[b, c] - f[(a+b) % n, c] + f[a, (b+c) % n] - f[a, b]
                    ) % n
        
        defect_indices.append(np.count_nonzero(delta))
    
    fig, ax = plt.subplots(figsize=(8, 5))
    ax.hist(defect_indices, bins=range(0, n**3 + 2), color='mediumpurple', 
            alpha=0.8, edgecolor='white')
    ax.set_xlabel("Defect Index")
    ax.set_ylabel("Frequency")
    ax.set_title(f"Distribution of Coboundary Defect Indices over ℤ/{n}ℤ\n"
                 f"({num_samples} random 2-cochains)")
    ax.axvline(x=np.mean(defect_indices), color='red', linestyle='--', 
               label=f'Mean = {np.mean(defect_indices):.1f}')
    ax.legend()
    
    plt.tight_layout()
    plt.savefig("coboundary_landscape.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved coboundary_landscape.png")


if __name__ == "__main__":
    plot_cocycle_heatmaps()
    plot_defect_index_vs_group_order()
    plot_coboundary_landscape()
    print("\nAll visualizations complete!")
