#!/usr/bin/env python3
"""
Functorial Entropy: Demonstration and Computational Examples

This script computes functorial entropy for various functions between
finite sets and verifies the key theoretical results:
1. H(f) = 0 iff f is injective
2. H(g∘f) ≥ H(f) (composition monotonicity)
3. H(f) = log|α| - H_Shannon(fiber distribution)
"""

import math
from collections import Counter
from itertools import product as cartesian_product


def fiber_card(f: dict, b) -> int:
    """Compute |f⁻¹(b)| = number of elements mapping to b."""
    return sum(1 for v in f.values() if v == b)


def functorial_entropy(f: dict) -> float:
    """
    Compute H(f) = Σ_b (|f⁻¹(b)|/|α|) · log(|f⁻¹(b)|).
    
    Args:
        f: dict mapping domain elements to codomain elements
    Returns:
        The functorial entropy H(f)
    """
    n = len(f)
    if n == 0:
        return 0.0
    
    fiber_sizes = Counter(f.values())
    entropy = 0.0
    for b, size in fiber_sizes.items():
        if size > 0:
            entropy += (size / n) * math.log(size)
    return entropy


def shannon_entropy(probs: list[float]) -> float:
    """Compute H_Shannon(p) = -Σ p_i · log(p_i)."""
    return -sum(p * math.log(p) for p in probs if p > 0)


def compose(g: dict, f: dict) -> dict:
    """Compute g ∘ f."""
    return {a: g[f[a]] for a in f}


def print_separator():
    print("=" * 60)


def demo_basic():
    """Demonstrate basic entropy computations."""
    print_separator()
    print("BASIC ENTROPY COMPUTATIONS")
    print_separator()
    
    # Identity function: should have H = 0
    f_id = {0: 0, 1: 1, 2: 2, 3: 3}
    h = functorial_entropy(f_id)
    print(f"Identity on {{0,1,2,3}}: H = {h:.6f} (expected: 0)")
    
    # Constant function: should have H = log(n)
    f_const = {0: 0, 1: 0, 2: 0, 3: 0}
    h = functorial_entropy(f_const)
    print(f"Constant on {{0,1,2,3}}: H = {h:.6f} (expected: log(4) = {math.log(4):.6f})")
    
    # Mod 2 on {0,..,5}: fibers of size 3, H = log(3)
    f_mod2 = {i: i % 2 for i in range(6)}
    h = functorial_entropy(f_mod2)
    print(f"Mod 2 on {{0,..,5}}: H = {h:.6f} (expected: log(3) = {math.log(3):.6f})")
    
    # Floor division by 2: fibers of size 2, H = log(2)
    f_floor = {i: i // 2 for i in range(6)}
    h = functorial_entropy(f_floor)
    print(f"Floor÷2 on {{0,..,5}}: H = {h:.6f} (expected: log(2) = {math.log(2):.6f})")
    
    # Non-uniform: f(0)=0, f(1)=f(2)=1
    f_nonunif = {0: 0, 1: 1, 2: 1}
    h = functorial_entropy(f_nonunif)
    print(f"Non-uniform {{0→0, 1→1, 2→1}}: H = {h:.6f}")
    print()


def demo_zero_characterization():
    """Verify: H(f) = 0 iff f is injective."""
    print_separator()
    print("ZERO CHARACTERIZATION: H(f)=0 ↔ f injective")
    print_separator()
    
    n = 4
    domain = list(range(n))
    codomain = list(range(n + 1))  # larger codomain
    
    injective_count = 0
    non_injective_count = 0
    
    for values in cartesian_product(codomain, repeat=n):
        f = dict(zip(domain, values))
        h = functorial_entropy(f)
        is_inj = len(set(values)) == n
        
        if is_inj:
            assert abs(h) < 1e-10, f"Injective f has H={h} ≠ 0"
            injective_count += 1
        else:
            assert h > 1e-10, f"Non-injective f has H={h} = 0"
            non_injective_count += 1
    
    print(f"Checked all functions Fin({n}) → Fin({len(codomain)}):")
    print(f"  Injective: {injective_count} (all have H=0 ✓)")
    print(f"  Non-injective: {non_injective_count} (all have H>0 ✓)")
    print()


def demo_composition_monotonicity():
    """Verify: H(g∘f) ≥ H(f) for all f, g."""
    print_separator()
    print("COMPOSITION MONOTONICITY: H(g∘f) ≥ H(f)")
    print_separator()
    
    sizes = [(3, 3, 2), (3, 2, 2), (4, 3, 2), (4, 2, 2)]
    total_checked = 0
    
    for na, nb, nc in sizes:
        violations = 0
        for f_vals in cartesian_product(range(nb), repeat=na):
            f = dict(zip(range(na), f_vals))
            for g_vals in cartesian_product(range(nc), repeat=nb):
                g = dict(zip(range(nb), g_vals))
                gf = compose(g, f)
                
                h_f = functorial_entropy(f)
                h_gf = functorial_entropy(gf)
                
                if h_gf < h_f - 1e-10:
                    violations += 1
                total_checked += 1
        
        status = "✓" if violations == 0 else f"✗ ({violations} violations)"
        print(f"  Fin({na})→Fin({nb})→Fin({nc}): {status}")
    
    print(f"Total function pairs checked: {total_checked}")
    print()


def demo_surjective_composition():
    """Verify conjecture: H(g) ≤ H(g∘f) when f is surjective."""
    print_separator()
    print("CONJECTURE: H(g) ≤ H(g∘f) when f surjective")
    print_separator()
    
    sizes = [(3, 2, 2), (4, 2, 2), (4, 3, 2), (4, 3, 3), (5, 3, 2)]
    total_checked = 0
    
    for na, nb, nc in sizes:
        violations = 0
        surj_count = 0
        for f_vals in cartesian_product(range(nb), repeat=na):
            f = dict(zip(range(na), f_vals))
            # Check surjectivity
            if len(set(f_vals)) < nb:
                continue
            surj_count += 1
            
            for g_vals in cartesian_product(range(nc), repeat=nb):
                g = dict(zip(range(nb), g_vals))
                gf = compose(g, f)
                
                h_g = functorial_entropy(g)
                h_gf = functorial_entropy(gf)
                
                if h_gf < h_g - 1e-10:
                    violations += 1
                total_checked += 1
        
        status = "✓" if violations == 0 else f"✗ ({violations} violations)"
        print(f"  Fin({na})→Fin({nb})→Fin({nc}) [{surj_count} surj.]: {status}")
    
    print(f"Total (surj f, g) pairs checked: {total_checked}")
    print()


def demo_shannon_bridge():
    """Verify: H(f) = log|α| - H_Shannon(fiber dist)."""
    print_separator()
    print("ENTROPY-SHANNON BRIDGE: H(f) = log|α| - H_Shannon(q)")
    print_separator()
    
    test_functions = [
        ("Identity", {0: 0, 1: 1, 2: 2, 3: 3}),
        ("Constant", {0: 0, 1: 0, 2: 0, 3: 0}),
        ("Mod 2", {0: 0, 1: 1, 2: 0, 3: 1}),
        ("Collapse", {0: 0, 1: 0, 2: 1, 3: 1}),
        ("Asymmetric", {0: 0, 1: 1, 2: 1, 3: 1}),
    ]
    
    for name, f in test_functions:
        n = len(f)
        h_f = functorial_entropy(f)
        
        # Compute fiber distribution
        fiber_sizes = Counter(f.values())
        all_outputs = set(f.values())
        probs = [fiber_sizes.get(b, 0) / n for b in range(max(f.values()) + 1)]
        probs = [p for p in probs if True]  # keep zeros
        
        h_shannon = shannon_entropy([p for p in probs if p > 0])
        bridge = math.log(n) - h_shannon
        
        match = abs(h_f - bridge) < 1e-10
        print(f"  {name:12s}: H={h_f:.6f}, log|α|-S={bridge:.6f} {'✓' if match else '✗'}")
    
    print()


def demo_landauer():
    """Demonstrate the Landauer cost computation."""
    print_separator()
    print("LANDAUER COST: Cost = kT · H(f)")
    print_separator()
    
    kT = 1.0  # normalized
    
    functions = [
        ("Reversible (permutation)", {0: 1, 1: 2, 2: 0}),
        ("Erase 1 bit (mod 2)", {0: 0, 1: 1, 2: 0, 3: 1}),
        ("Total erasure (constant)", {0: 0, 1: 0, 2: 0, 3: 0}),
    ]
    
    for name, f in functions:
        h = functorial_entropy(f)
        cost = kT * h
        print(f"  {name:35s}: H={h:.4f}, Cost={cost:.4f} kT")
    
    print()
    print("At room temperature (T=300K):")
    kB = 1.380649e-23  # J/K
    T = 300  # K
    kT_real = kB * T
    
    f_erase = {0: 0, 1: 0}  # erase 1 bit
    h = functorial_entropy(f_erase)
    cost = kT_real * h
    print(f"  Erasing 1 bit: {cost:.4e} J = {cost*1e21:.2f} zJ")
    print(f"  (Landauer limit: kT·ln(2) = {kT_real * math.log(2):.4e} J)")
    print()


if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║    FUNCTORIAL ENTROPY: Measuring Information Loss       ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()
    
    demo_basic()
    demo_zero_characterization()
    demo_composition_monotonicity()
    demo_surjective_composition()
    demo_shannon_bridge()
    demo_landauer()
    
    print_separator()
    print("All demonstrations completed successfully!")
    print_separator()


#!/usr/bin/env python3
"""
Visualization: Composition monotonicity of functorial entropy.

Shows that H(g∘f) ≥ H(f) for all function pairs, with scatter plots
colored by the entropy gain.
"""

import math
from collections import Counter
from itertools import product as cartesian_product
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def functorial_entropy(f_values: tuple, n: int) -> float:
    if n == 0:
        return 0.0
    sizes = Counter(f_values)
    return sum((s / n) * math.log(s) for s in sizes.values() if s > 0)


def main():
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))
    fig.suptitle('Composition Monotonicity: H(g∘f) ≥ H(f)\n'
                 'Every point lies on or above the diagonal',
                 fontsize=14, fontweight='bold')
    
    configs = [
        (3, 3, 2, 'Fin(3)→Fin(3)→Fin(2)'),
        (4, 3, 2, 'Fin(4)→Fin(3)→Fin(2)'),
        (4, 4, 3, 'Fin(4)→Fin(4)→Fin(3)'),
    ]
    
    for ax, (na, nb, nc, title) in zip(axes, configs):
        h_f_list = []
        h_gf_list = []
        
        for f_vals in cartesian_product(range(nb), repeat=na):
            h_f = functorial_entropy(f_vals, na)
            for g_vals in cartesian_product(range(nc), repeat=nb):
                gf_vals = tuple(g_vals[f_vals[i]] for i in range(na))
                h_gf = functorial_entropy(gf_vals, na)
                h_f_list.append(h_f)
                h_gf_list.append(h_gf)
        
        h_f_arr = np.array(h_f_list)
        h_gf_arr = np.array(h_gf_list)
        gain = h_gf_arr - h_f_arr
        
        sc = ax.scatter(h_f_arr, h_gf_arr, c=gain, cmap='viridis',
                       s=1, alpha=0.3, rasterized=True)
        
        max_val = max(h_f_arr.max(), h_gf_arr.max()) * 1.1
        ax.plot([0, max_val], [0, max_val], 'r--', linewidth=1, label='H(g∘f) = H(f)')
        
        ax.set_xlabel('H(f)')
        ax.set_ylabel('H(g∘f)')
        ax.set_title(title)
        ax.set_aspect('equal')
        ax.legend(fontsize=8)
        
        plt.colorbar(sc, ax=ax, label='Entropy gain H(g∘f) - H(f)')
        
        # Verify monotonicity
        violations = np.sum(gain < -1e-10)
        ax.text(0.02, 0.98, f'Violations: {violations}',
                transform=ax.transAxes, verticalalignment='top',
                fontsize=9, color='green' if violations == 0 else 'red')
    
    plt.tight_layout()
    plt.savefig('composition_monotonicity.png', dpi=150, bbox_inches='tight')
    print("Saved composition_monotonicity.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Entropy landscape of all functions Fin(n) → Fin(m).

Creates a histogram showing the distribution of functorial entropy values
across all possible functions between small finite sets.
"""

import math
from collections import Counter
from itertools import product as cartesian_product
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def functorial_entropy(f_values: tuple, n: int) -> float:
    """Compute H(f) from a tuple of output values."""
    if n == 0:
        return 0.0
    sizes = Counter(f_values)
    return sum((s / n) * math.log(s) for s in sizes.values() if s > 0)


def compute_all_entropies(n: int, m: int) -> list[float]:
    """Compute H(f) for all functions f : Fin(n) → Fin(m)."""
    entropies = []
    for vals in cartesian_product(range(m), repeat=n):
        entropies.append(functorial_entropy(vals, n))
    return entropies


def main():
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))
    fig.suptitle('Functorial Entropy Landscape\nDistribution of H(f) across all functions f : Fin(n) → Fin(m)',
                 fontsize=14, fontweight='bold')
    
    configs = [(4, 4), (4, 3), (4, 2), (5, 3)]
    
    for ax, (n, m) in zip(axes.flat, configs):
        entropies = compute_all_entropies(n, m)
        
        # Count injective (H=0) and non-injective
        n_injective = sum(1 for h in entropies if abs(h) < 1e-10)
        n_total = len(entropies)
        
        ax.hist(entropies, bins=50, color='steelblue', edgecolor='white',
                alpha=0.8, density=True)
        
        # Mark log(n) upper bound
        ax.axvline(x=math.log(n), color='red', linestyle='--', linewidth=1.5,
                   label=f'log({n}) = {math.log(n):.2f}')
        
        # Mark H=0
        if n_injective > 0:
            ax.axvline(x=0, color='green', linestyle=':', linewidth=1.5,
                       label=f'H=0 ({n_injective}/{n_total} injective)')
        
        ax.set_xlabel('Functorial Entropy H(f)')
        ax.set_ylabel('Density')
        ax.set_title(f'Fin({n}) → Fin({m})  ({n_total} functions)')
        ax.legend(fontsize=8)
        ax.set_xlim(-0.1, math.log(n) + 0.3)
    
    plt.tight_layout()
    plt.savefig('entropy_landscape.png', dpi=150, bbox_inches='tight')
    print("Saved entropy_landscape.png")


if __name__ == "__main__":
    main()
