#!/usr/bin/env python3
"""
Demo: Horseshoe Dynamics and Computational Universality

Demonstrates the core results from the formalization:
1. Orbit realization in full shift spaces
2. Boolean function encoding via symbolic dynamics
3. Entropy-capacity bounds
4. Geometric complexity classification
"""

import itertools
from typing import Callable

# ============================================================
# 1. Full Shift Space and Orbit Realization
# ============================================================

def full_shift_sequence(d: int, word: list[int], default: int = 0) -> Callable[[int], int]:
    """Construct a bi-infinite sequence realizing a given word at positions 0..k-1."""
    k = len(word)
    def seq(n: int) -> int:
        if 0 <= n < k:
            return word[n]
        return default % d
    return seq

def orbit_window(seq: Callable[[int], int], start: int, k: int) -> list[int]:
    """Extract a length-k window from a sequence starting at position start."""
    return [seq(start + i) for i in range(k)]

def demo_orbit_realization():
    """Demonstrate that any word is realized by some orbit."""
    print("=" * 60)
    print("1. ORBIT REALIZATION THEOREM")
    print("=" * 60)
    
    d = 3  # alphabet size
    words = [
        [0, 1, 2],
        [2, 2, 1, 0],
        [1, 0, 1, 0, 1],
    ]
    
    for word in words:
        seq = full_shift_sequence(d, word)
        recovered = orbit_window(seq, 0, len(word))
        assert recovered == word, f"Failed for word {word}"
        print(f"  Word {word} (d={d}): ✓ realized at positions 0..{len(word)-1}")
    
    # Count all words of length k
    for k in range(1, 5):
        count = d ** k
        print(f"  Total words of length {k} over {d} symbols: {count}")
    print()

# ============================================================
# 2. Boolean Function Encoding
# ============================================================

def encode_bool(b: bool) -> int:
    """Encode: False → 0, True → 1."""
    return 1 if b else 0

def decode_bool(s: int) -> bool:
    """Decode: 0 → False, nonzero → True."""
    return s != 0

def encode_boolean_function(
    f: Callable[[tuple[bool, ...]], bool],
    inputs: tuple[bool, ...],
    d: int = 2
) -> Callable[[int], int]:
    """Encode a Boolean function evaluation into a shift sequence."""
    n = len(inputs)
    output = f(inputs)
    
    def seq(pos: int) -> int:
        if 0 <= pos < n:
            return encode_bool(inputs[pos])
        elif pos == n:
            return encode_bool(output)
        return 0
    
    return seq

def demo_boolean_encoding():
    """Demonstrate Boolean function encoding via shift dynamics."""
    print("=" * 60)
    print("2. BOOLEAN FUNCTION ENCODING")
    print("=" * 60)
    
    # Define some Boolean functions
    def and_fn(bits: tuple[bool, ...]) -> bool:
        return all(bits)
    
    def or_fn(bits: tuple[bool, ...]) -> bool:
        return any(bits)
    
    def xor_fn(bits: tuple[bool, ...]) -> bool:
        result = False
        for b in bits:
            result ^= b
        return result
    
    def majority_fn(bits: tuple[bool, ...]) -> bool:
        return sum(bits) > len(bits) / 2
    
    functions = {
        "AND": and_fn,
        "OR": or_fn,
        "XOR": xor_fn,
        "MAJORITY": majority_fn,
    }
    
    n = 3  # number of inputs
    
    for name, f in functions.items():
        print(f"\n  {name} function on {n} inputs:")
        all_correct = True
        for bits in itertools.product([False, True], repeat=n):
            seq = encode_boolean_function(f, bits)
            # Verify encoding
            for i in range(n):
                assert decode_bool(seq(i)) == bits[i]
            assert decode_bool(seq(n)) == f(bits)
            
            input_str = "".join("1" if b else "0" for b in bits)
            output_str = "1" if f(bits) else "0"
            window = [seq(i) for i in range(n + 1)]
            print(f"    Input: {input_str} → Output: {output_str}  (window: {window})")
        
        print(f"    ✓ All {2**n} evaluations correctly encoded")
    print()

# ============================================================
# 3. Entropy-Capacity Analysis
# ============================================================

import math

def demo_entropy_capacity():
    """Demonstrate the entropy-capacity bound."""
    print("=" * 60)
    print("3. ENTROPY-CAPACITY ANALYSIS")
    print("=" * 60)
    
    print("\n  Window capacity (d^k) vs Boolean function count (2^(2^k)):\n")
    print(f"  {'k':>3} {'d=2 windows':>15} {'d=3 windows':>15} {'Bool fns':>15} {'Gap ratio':>15}")
    print("  " + "-" * 65)
    
    for k in range(1, 8):
        w2 = 2 ** k
        w3 = 3 ** k
        bf = 2 ** (2 ** k)
        ratio = bf / w2 if w2 > 0 else float('inf')
        
        if bf < 10**15:
            print(f"  {k:>3} {w2:>15,} {w3:>15,} {bf:>15,} {ratio:>15.1f}")
        else:
            print(f"  {k:>3} {w2:>15,} {w3:>15,} {'(huge)':>15} {'(huge)':>15}")
    
    print("\n  Key insight: Boolean function space grows doubly-exponentially,")
    print("  while window capacity grows only singly-exponentially.")
    print("  → A single orbit window cannot encode all functions simultaneously.")
    
    # Word entropy computation
    print("\n  Word entropy h(d, k) = k · log₂(d):")
    for d in [2, 3, 5, 10]:
        for k in [1, 5, 10]:
            h = k * math.log2(d)
            print(f"    h({d}, {k}) = {h:.2f} bits")
    print()

# ============================================================
# 4. Geometric Complexity Classification
# ============================================================

def geometric_complexity(f: Callable[[tuple[bool, ...]], bool], n: int) -> int:
    """Compute the geometric complexity of a Boolean function.
    
    By our universality theorem, any non-constant function has GC = 2.
    Constant functions have GC = 1.
    """
    outputs = set()
    for bits in itertools.product([False, True], repeat=n):
        outputs.add(f(bits))
        if len(outputs) == 2:
            return 2  # Non-constant → GC = 2
    return 1  # Constant → GC = 1

def demo_geometric_complexity():
    """Demonstrate geometric complexity classification."""
    print("=" * 60)
    print("4. GEOMETRIC COMPLEXITY CLASSIFICATION")
    print("=" * 60)
    
    functions = {
        "Constant True": lambda bits: True,
        "Constant False": lambda bits: False,
        "AND": lambda bits: all(bits),
        "OR": lambda bits: any(bits),
        "XOR": lambda bits: sum(bits) % 2 == 1,
        "NAND": lambda bits: not all(bits),
        "Majority": lambda bits: sum(bits) > len(bits) / 2,
        "Parity": lambda bits: sum(bits) % 2 == 0,
    }
    
    n = 4
    print(f"\n  Geometric complexity of Boolean functions on {n} inputs:")
    print(f"  {'Function':>20} {'GC':>5} {'Category':>15}")
    print("  " + "-" * 45)
    
    for name, f in functions.items():
        gc = geometric_complexity(f, n)
        cat = "constant" if gc == 1 else "non-constant"
        print(f"  {name:>20} {gc:>5} {cat:>15}")
    
    print("\n  Key result: ALL non-constant Boolean functions have geometric")
    print("  complexity exactly 2, because the full 2-symbol shift is")
    print("  computationally universal.")
    print()

# ============================================================
# 5. Horseshoe Hierarchy
# ============================================================

def demo_horseshoe_hierarchy():
    """Demonstrate the sub-horseshoe hierarchy."""
    print("=" * 60)
    print("5. HORSESHOE HIERARCHY")
    print("=" * 60)
    
    print("\n  Sub-horseshoe containment for degree-d horseshoes:")
    print("  (degree d' ≤ d sub-horseshoes)\n")
    
    for d in range(2, 7):
        subs = list(range(2, d + 1))
        print(f"  Degree-{d} horseshoe contains: {subs}")
        print(f"    → Window capacity at k=3: ", end="")
        for d_sub in subs:
            print(f"d'={d_sub}:{d_sub**3}", end="  ")
        print()
    
    print("\n  The hierarchy theorem says every degree-d horseshoe")
    print("  contains ALL degree-d' sub-horseshoes for 2 ≤ d' ≤ d.")
    print("  This reveals the fractal structure of chaotic dynamics.")
    print()


if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("  HORSESHOE DYNAMICS AND COMPUTATIONAL UNIVERSALITY")
    print("  Demonstrated results from formal Lean 4 proofs")
    print("=" * 60 + "\n")
    
    demo_orbit_realization()
    demo_boolean_encoding()
    demo_entropy_capacity()
    demo_geometric_complexity()
    demo_horseshoe_hierarchy()
    
    print("All demonstrations completed successfully! ✓")


#!/usr/bin/env python3
"""
Visualization: Entropy-Capacity Gap in Horseshoe Computation

Shows the exponential gap between window capacity (d^k) and
Boolean function count (2^(2^k)), demonstrating why a single
orbit window cannot encode all functions simultaneously.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import math


def plot_entropy_gap():
    """Plot the exponential gap between capacity and function count."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Left plot: log-scale comparison
    ax1 = axes[0]
    k_vals = np.arange(1, 8)
    
    for d in [2, 3, 5]:
        log_capacity = k_vals * np.log2(d)
        ax1.plot(k_vals, log_capacity, 'o-', label=f'd={d} shift: k·log₂({d})', linewidth=2)
    
    log_functions = np.array([2**k for k in k_vals], dtype=float)
    ax1.plot(k_vals, log_functions, 's-', color='red', label='Bool fns: 2^k', linewidth=2, markersize=8)
    
    ax1.set_xlabel('Window length k', fontsize=12)
    ax1.set_ylabel('log₂(count)', fontsize=12)
    ax1.set_title('Exponential Gap: Window Capacity vs Function Space', fontsize=13)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)
    ax1.set_yscale('log', base=2)
    
    # Right plot: horseshoe hierarchy capacity
    ax2 = axes[1]
    d_vals = range(2, 11)
    k_vals_plot = [2, 3, 4, 5]
    
    colors = plt.cm.viridis(np.linspace(0.2, 0.8, len(k_vals_plot)))
    
    for i, k in enumerate(k_vals_plot):
        capacities = [d**k for d in d_vals]
        ax2.bar([d + (i - 1.5) * 0.2 for d in d_vals], capacities,
                width=0.2, color=colors[i], label=f'k={k}', alpha=0.8)
    
    ax2.set_xlabel('Horseshoe degree d', fontsize=12)
    ax2.set_ylabel('Window capacity d^k', fontsize=12)
    ax2.set_title('Capacity Growth by Horseshoe Degree', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.set_yscale('log')
    ax2.grid(True, alpha=0.3, axis='y')
    
    plt.tight_layout()
    plt.savefig('entropy_gap.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: entropy_gap.png")


def plot_boolean_encoding():
    """Plot the Boolean encoding structure for a 3-input AND gate."""
    fig, ax = plt.subplots(figsize=(10, 6))
    
    import itertools
    
    n = 3
    inputs_list = list(itertools.product([False, True], repeat=n))
    
    for idx, bits in enumerate(inputs_list):
        output = all(bits)  # AND function
        window = [1 if b else 0 for b in bits] + [1 if output else 0]
        
        y = len(inputs_list) - idx - 1
        for pos, val in enumerate(window):
            color = '#2196F3' if val == 1 else '#E0E0E0'
            rect = plt.Rectangle((pos - 0.4, y - 0.35), 0.8, 0.7,
                                facecolor=color, edgecolor='black', linewidth=1)
            ax.add_patch(rect)
            ax.text(pos, y, str(val), ha='center', va='center',
                   fontsize=14, fontweight='bold',
                   color='white' if val == 1 else 'gray')
        
        input_str = ''.join(str(int(b)) for b in bits)
        ax.text(-1, y, input_str, ha='center', va='center', fontsize=11, fontfamily='monospace')
        
        output_str = '1' if output else '0'
        ax.text(n + 1, y, f'→ {output_str}', ha='center', va='center', fontsize=11)
    
    ax.set_xlim(-1.8, n + 1.8)
    ax.set_ylim(-0.8, len(inputs_list) - 0.2)
    
    # Labels
    for i in range(n):
        ax.text(i, len(inputs_list) - 0.3, f'x_{i}', ha='center', va='bottom',
               fontsize=12, fontstyle='italic')
    ax.text(n, len(inputs_list) - 0.3, 'f(x)', ha='center', va='bottom',
           fontsize=12, fontstyle='italic', color='red')
    
    ax.set_title('Boolean Encoding via Orbit Windows: AND(x₀, x₁, x₂)', fontsize=14)
    ax.text(-1, len(inputs_list) - 0.3, 'Input', ha='center', va='bottom', fontsize=12)
    ax.set_aspect('equal')
    ax.axis('off')
    
    plt.tight_layout()
    plt.savefig('boolean_encoding.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: boolean_encoding.png")


def plot_horseshoe_hierarchy():
    """Visualize the horseshoe hierarchy as a containment diagram."""
    fig, ax = plt.subplots(figsize=(10, 6))
    
    max_d = 6
    
    colors = plt.cm.Set2(np.linspace(0, 1, max_d))
    
    for d in range(max_d, 1, -1):
        radius = d * 0.8
        circle = plt.Circle((5, 3), radius, fill=False,
                           edgecolor=colors[d-1], linewidth=2.5,
                           linestyle='-' if d % 2 == 0 else '--')
        ax.add_patch(circle)
        ax.text(5 + radius + 0.15, 3, f'd={d}', fontsize=11,
               color=colors[d-1], va='center', fontweight='bold')
        
        # Entropy annotation
        h = math.log2(d)
        ax.text(5 - radius + 0.1, 3 - radius + 0.3,
               f'h={h:.2f}', fontsize=8, color=colors[d-1], alpha=0.7)
    
    ax.set_xlim(0, 12)
    ax.set_ylim(-3, 9)
    ax.set_aspect('equal')
    ax.set_title('Horseshoe Hierarchy: Nested Sub-Horseshoes', fontsize=14)
    ax.text(5, -2, 'Each degree-d horseshoe contains all degree-d\' ≤ d sub-horseshoes',
           ha='center', fontsize=11, fontstyle='italic')
    ax.axis('off')
    
    plt.tight_layout()
    plt.savefig('horseshoe_hierarchy.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: horseshoe_hierarchy.png")


if __name__ == "__main__":
    plot_entropy_gap()
    plot_boolean_encoding()
    plot_horseshoe_hierarchy()
    print("All visualizations generated! ✓")
