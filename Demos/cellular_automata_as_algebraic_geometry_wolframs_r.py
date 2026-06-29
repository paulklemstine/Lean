#!/usr/bin/env python3
"""
Cellular Automata as Algebraic Geometry over GF(2)
===================================================
Demonstrates the core results: ECA rules as polynomial maps over GF(2),
fixed-point varieties, conjugate duality, and the dimension classification.

Run: python3 demo.py
"""

import numpy as np
from itertools import product

# --- GF(2) Arithmetic ---

def gf2_add(a, b):
    """Addition in GF(2) = XOR."""
    return a ^ b

def gf2_mul(a, b):
    """Multiplication in GF(2) = AND."""
    return a & b

# --- ECA Local Rule ---

def eca_local(rule_num, left, center, right):
    """Apply ECA local rule: extract bit from rule number."""
    idx = (left << 2) | (center << 1) | right
    return (rule_num >> idx) & 1

def eca_step(rule_num, state):
    """Global ECA step with periodic boundary on n cells."""
    n = len(state)
    return np.array([
        eca_local(rule_num, state[(i-1) % n], state[i], state[(i+1) % n])
        for i in range(n)
    ], dtype=int)

# --- Fixed Point Computation ---

def find_fixed_points(rule_num, n):
    """Find all fixed points of an ECA rule on n cells over GF(2)."""
    fixed = []
    for bits in product([0, 1], repeat=n):
        state = np.array(bits, dtype=int)
        if np.array_equal(eca_step(rule_num, state), state):
            fixed.append(state)
    return fixed

def count_fixed_points(rule_num, n):
    """Count fixed points (size of the variety V(f_r - id))."""
    return len(find_fixed_points(rule_num, n))

# --- Polynomial (Algebraic Normal Form) Representation ---

def compute_anf(rule_num):
    """Compute the Algebraic Normal Form coefficients for a rule.
    
    Every function GF(2)^3 -> GF(2) has a unique representation as:
    g(a,b,c) = c0 + c1*a + c2*b + c3*c + c4*ab + c5*ac + c6*bc + c7*abc
    
    This is the content of our polynomial_representation theorem.
    """
    # Evaluate on all 8 inputs
    vals = {}
    for a, b, c in product([0, 1], repeat=3):
        vals[(a, b, c)] = eca_local(rule_num, a, b, c)
    
    # Möbius inversion to get ANF coefficients
    c = [0] * 8
    c[0] = vals[(0,0,0)]
    c[1] = vals[(0,0,0)] ^ vals[(1,0,0)]
    c[2] = vals[(0,0,0)] ^ vals[(0,1,0)]
    c[3] = vals[(0,0,0)] ^ vals[(0,0,1)]
    c[4] = vals[(0,0,0)] ^ vals[(1,0,0)] ^ vals[(0,1,0)] ^ vals[(1,1,0)]
    c[5] = vals[(0,0,0)] ^ vals[(1,0,0)] ^ vals[(0,0,1)] ^ vals[(1,0,1)]
    c[6] = vals[(0,0,0)] ^ vals[(0,1,0)] ^ vals[(0,0,1)] ^ vals[(0,1,1)]
    c[7] = (vals[(0,0,0)] ^ vals[(1,0,0)] ^ vals[(0,1,0)] ^ vals[(0,0,1)] ^
            vals[(1,1,0)] ^ vals[(1,0,1)] ^ vals[(0,1,1)] ^ vals[(1,1,1)])
    return c

def anf_to_string(c):
    """Convert ANF coefficients to a human-readable polynomial string."""
    terms = []
    monomial_names = ['1', 'a', 'b', 'c', 'ab', 'ac', 'bc', 'abc']
    for i, name in enumerate(monomial_names):
        if c[i]:
            terms.append(name)
    return ' + '.join(terms) if terms else '0'

# --- Conjugate Duality ---

def conjugate_rule(rule_num):
    """Compute the conjugate rule: ḡ(a,b,c) = 1 + g(1+a, 1+b, 1+c) over GF(2)."""
    conj = 0
    for a, b, c in product([0, 1], repeat=3):
        idx = (a << 2) | (b << 1) | c
        val = 1 ^ eca_local(rule_num, 1^a, 1^b, 1^c)
        conj |= (val << idx)
    return conj

# --- Linearity Check ---

def is_additive_rule(rule_num):
    """Check if a rule's local function is additive (linear) over GF(2)."""
    # g(0,0,0) must be 0
    if eca_local(rule_num, 0, 0, 0) != 0:
        return False
    # Check additivity: g(a+a', b+b', c+c') = g(a,b,c) + g(a',b',c')
    for a, a_, b, b_, c, c_ in product([0, 1], repeat=6):
        lhs = eca_local(rule_num, a^a_, b^b_, c^c_)
        rhs = eca_local(rule_num, a, b, c) ^ eca_local(rule_num, a_, b_, c_)
        if lhs != rhs:
            return False
    return True

# --- Main Demo ---

def main():
    print("=" * 70)
    print("CELLULAR AUTOMATA AS ALGEBRAIC GEOMETRY OVER GF(2)")
    print("=" * 70)
    
    # Demo 1: Polynomial representation
    print("\n--- Demo 1: Polynomial Representation (ANF) ---")
    print("Every ECA rule is a polynomial over GF(2).\n")
    demo_rules = [0, 51, 90, 102, 110, 150, 170, 204, 255]
    for r in demo_rules:
        c = compute_anf(r)
        print(f"  Rule {r:>3}: g(a,b,c) = {anf_to_string(c)}")
    
    # Demo 2: Fixed point counts
    print("\n--- Demo 2: Fixed Point Counts (Variety Size) ---")
    print("Number of fixed points |V(f_r - id)| for n cells:\n")
    print(f"  {'Rule':>6} | {'n=3':>4} {'n=4':>4} {'n=5':>4} {'n=6':>4} {'n=7':>4} {'n=8':>4} | {'Linear?':>8} | Polynomial")
    print("  " + "-" * 65)
    
    interesting_rules = [0, 51, 60, 90, 102, 110, 150, 170, 204, 255]
    for r in interesting_rules:
        counts = [count_fixed_points(r, n) for n in range(3, 9)]
        linear = "Yes" if is_additive_rule(r) else "No"
        poly = anf_to_string(compute_anf(r))
        counts_str = " ".join(f"{c:>4}" for c in counts)
        print(f"  Rule {r:>3} | {counts_str} | {linear:>8} | {poly}")
    
    # Demo 3: Conjugate duality
    print("\n--- Demo 3: Conjugate Duality ---")
    print("Rules come in conjugate pairs (g, ḡ) with isomorphic fixed-point varieties.\n")
    seen = set()
    pairs = []
    for r in range(256):
        if r not in seen:
            c = conjugate_rule(r)
            seen.add(r)
            seen.add(c)
            if r != c:
                pairs.append((r, c))
    
    print(f"  Self-conjugate rules: {sum(1 for r in range(256) if conjugate_rule(r) == r)}")
    print(f"  Conjugate pairs: {len(pairs)}")
    print(f"\n  Sample pairs (rule, conjugate, n=6 fixed points):")
    for r, c in pairs[:8]:
        fp_r = count_fixed_points(r, 6)
        fp_c = count_fixed_points(c, 6)
        print(f"    Rule {r:>3} ↔ Rule {c:>3}  |  |V_r| = {fp_r:>2}, |V_ḡ| = {fp_c:>2}")
    
    # Demo 4: Linear rules and submodule dimensions
    print("\n--- Demo 4: Linear Rules (Fixed Points Form a Submodule) ---")
    linear_rules = [r for r in range(256) if is_additive_rule(r)]
    print(f"\n  {len(linear_rules)} linear rules found: {linear_rules}")
    print(f"\n  For linear rules, fixed points form a subspace of GF(2)^n.")
    print(f"  Dimension = log₂(|fixed points|):\n")
    print(f"  {'Rule':>6} | {'dim(n=4)':>8} {'dim(n=6)':>8} {'dim(n=8)':>8} | Polynomial")
    print("  " + "-" * 55)
    for r in linear_rules:
        dims = []
        for n in [4, 6, 8]:
            fp = count_fixed_points(r, n)
            dim = int(np.log2(fp)) if fp > 0 else -1
            dims.append(dim)
        poly = anf_to_string(compute_anf(r))
        dims_str = " ".join(f"{d:>8}" for d in dims)
        print(f"  Rule {r:>3} | {dims_str} | {poly}")
    
    # Demo 5: Rule 150 characterization
    print("\n--- Demo 5: Rule 150 Fixed Point Characterization ---")
    print("Theorem: s is fixed by Rule 150 iff s_{i-1} = s_{i+1} for all i.\n")
    for n in range(3, 9):
        fps = find_fixed_points(150, n)
        print(f"  n={n}: {len(fps)} fixed points")
        for fp in fps:
            print(f"    {''.join(map(str, fp))}")
    
    # Demo 6: Rule 51 has no fixed points
    print("\n--- Demo 6: Rule 51 Obstruction (Empty Variety) ---")
    print("Theorem: Rule 51 has no fixed points for any n.")
    for n in range(3, 12):
        fp = count_fixed_points(51, n)
        print(f"  n={n}: {fp} fixed points {'✓ (V = ∅)' if fp == 0 else '✗ ERROR'}")
    
    # Demo 7: Full 256-rule census
    print("\n--- Demo 7: Fixed Point Census (All 256 Rules, n=6) ---")
    census = {}
    for r in range(256):
        fp = count_fixed_points(r, 6)
        census.setdefault(fp, []).append(r)
    
    print(f"\n  Distribution of |V(f_r - id)| for n=6:")
    for fp_count in sorted(census.keys()):
        rules = census[fp_count]
        print(f"    |V| = {fp_count:>3}: {len(rules)} rules  (e.g., {rules[:5]}{'...' if len(rules)>5 else ''})")
    
    print("\n" + "=" * 70)
    print("KEY INSIGHT: Every ECA is a polynomial dynamical system over GF(2).")
    print("The fixed-point variety V(f_r - id) encodes the rule's static structure.")
    print("For linear rules, V is a subspace whose dimension is a complexity measure.")
    print("Conjugate duality pairs rules with isomorphic varieties (256 → 128).")
    print("=" * 70)

if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Dimension Spectrum of ECA Fixed-Point Varieties
================================================================
For linear rules, plot the dimension of the fixed-point subspace
as a function of n, revealing number-theoretic patterns.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import product
import math


def eca_local_rule(rule_num, left, center, right):
    idx = (left << 2) | (center << 1) | right
    return (rule_num >> idx) & 1

def eca_global_step(rule_num, state):
    n = len(state)
    return [
        eca_local_rule(rule_num, state[(i-1) % n], state[i], state[(i+1) % n])
        for i in range(n)
    ]

def count_fixed_points(rule_num, n):
    count = 0
    for bits in product([0, 1], repeat=n):
        state = list(bits)
        if eca_global_step(rule_num, state) == state:
            count += 1
    return count

def is_linear_rule(rule_num):
    if eca_local_rule(rule_num, 0, 0, 0) != 0:
        return False
    for a, ap, b, bp, c, cp in product([0, 1], repeat=6):
        lhs = eca_local_rule(rule_num, a^ap, b^bp, c^cp)
        rhs = eca_local_rule(rule_num, a, b, c) ^ eca_local_rule(rule_num, ap, bp, cp)
        if lhs != rhs:
            return False
    return True


def main():
    linear_rules = [r for r in range(256) if is_linear_rule(r)]
    rule_names = {0: '0', 60: 'a⊕b', 90: 'a⊕c', 102: 'b⊕c', 
                  150: 'a⊕b⊕c', 170: 'c', 204: 'b', 240: 'a'}
    
    ns = list(range(3, 17))
    
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    
    # Plot 1: Dimension vs n for each linear rule
    ax1 = axes[0, 0]
    colors = plt.cm.tab10(np.linspace(0, 1, len(linear_rules)))
    for idx, r in enumerate(linear_rules):
        dims = []
        for n in ns:
            fp = count_fixed_points(r, n)
            dim = int(math.log2(fp)) if fp > 0 else -1
            dims.append(dim)
        label = f"Rule {r} ({rule_names.get(r, '?')})"
        ax1.plot(ns, dims, 'o-', label=label, color=colors[idx], markersize=4)
    
    ax1.set_xlabel('Number of cells n')
    ax1.set_ylabel('dim(V) = dim ker(T - I)')
    ax1.set_title('Fixed-Point Subspace Dimension\n(Linear Rules over GF(2))')
    ax1.legend(fontsize=7, ncol=2)
    ax1.grid(True, alpha=0.3)
    
    # Plot 2: Rule 90 (Sierpinski) dimension spectrum
    ax2 = axes[0, 1]
    dims_90 = []
    for n in ns:
        fp = count_fixed_points(90, n)
        dim = int(math.log2(fp)) if fp > 0 else -1
        dims_90.append(dim)
    
    colors_90 = ['red' if n % 3 == 0 else 'blue' for n in ns]
    ax2.bar(ns, dims_90, color=colors_90, alpha=0.7)
    ax2.set_xlabel('n')
    ax2.set_ylabel('dim ker(T₉₀ - I)')
    ax2.set_title('Rule 90 Fixed-Point Dimension\nRed: n ≡ 0 (mod 3), Blue: otherwise')
    ax2.grid(True, alpha=0.3)
    
    # Plot 3: Fixed point count distribution for all 256 rules
    ax3 = axes[1, 0]
    n_test = 8
    all_fp_counts = [count_fixed_points(r, n_test) for r in range(256)]
    unique_counts = sorted(set(all_fp_counts))
    freq = [all_fp_counts.count(c) for c in unique_counts]
    
    # Color bars: power-of-2 counts in blue, others in orange
    bar_colors = ['steelblue' if (c & (c-1) == 0 and c > 0) else 'darkorange' 
                  for c in unique_counts]
    
    ax3.bar(range(len(unique_counts)), freq, color=bar_colors, alpha=0.8)
    ax3.set_xticks(range(len(unique_counts)))
    ax3.set_xticklabels([str(c) for c in unique_counts], rotation=45, fontsize=7)
    ax3.set_xlabel(f'|V(f_r - id)| (n={n_test})')
    ax3.set_ylabel('Number of rules')
    ax3.set_title(f'Fixed-Point Count Distribution (n={n_test})\nBlue: power of 2, Orange: not power of 2')
    
    # Plot 4: Rule 150 even/odd bifurcation
    ax4 = axes[1, 1]
    dims_150_even = []
    dims_150_odd = []
    ns_even = [n for n in ns if n % 2 == 0]
    ns_odd = [n for n in ns if n % 2 == 1]
    
    for n in ns_even:
        fp = count_fixed_points(150, n)
        dims_150_even.append(int(math.log2(fp)) if fp > 0 else -1)
    for n in ns_odd:
        fp = count_fixed_points(150, n)
        dims_150_odd.append(int(math.log2(fp)) if fp > 0 else -1)
    
    ax4.plot(ns_even, dims_150_even, 'rs-', label='n even: dim = 2', markersize=8)
    ax4.plot(ns_odd, dims_150_odd, 'bo-', label='n odd: dim = 1', markersize=8)
    ax4.set_xlabel('n')
    ax4.set_ylabel('dim ker(T₁₅₀ - I)')
    ax4.set_title('Rule 150: Even/Odd Parity Bifurcation\nof Fixed-Point Dimension')
    ax4.legend()
    ax4.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('eca_dimension_spectrum.png', dpi=150, bbox_inches='tight')
    print("Saved: eca_dimension_spectrum.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Fixed-Point Variety Dimensions for All 256 ECA Rules
====================================================================
Produces a heatmap showing the fixed-point count for each rule,
organized to reveal the conjugate duality structure.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import product


def eca_local_rule(rule_num, left, center, right):
    idx = (left << 2) | (center << 1) | right
    return (rule_num >> idx) & 1

def eca_global_step(rule_num, state):
    n = len(state)
    return [
        eca_local_rule(rule_num, state[(i-1) % n], state[i], state[(i+1) % n])
        for i in range(n)
    ]

def count_fixed_points(rule_num, n):
    count = 0
    for bits in product([0, 1], repeat=n):
        state = list(bits)
        if eca_global_step(rule_num, state) == state:
            count += 1
    return count

def compute_conjugate(rule_num):
    conj = 0
    for a, b, c in product([0, 1], repeat=3):
        idx = (a << 2) | (b << 1) | c
        val = 1 ^ eca_local_rule(rule_num, 1^a, 1^b, 1^c)
        conj |= (val << idx)
    return conj


def main():
    n = 8  # Use 8 cells for meaningful variety structure
    
    # Compute fixed point counts for all 256 rules
    fp_counts = np.array([count_fixed_points(r, n) for r in range(256)])
    
    # Reshape into 16x16 grid
    fp_grid = fp_counts.reshape(16, 16)
    
    fig, axes = plt.subplots(1, 2, figsize=(16, 7))
    
    # Plot 1: Heatmap of fixed point counts
    ax1 = axes[0]
    im = ax1.imshow(np.log2(fp_grid + 1), cmap='viridis', aspect='auto')
    ax1.set_title(f'Fixed-Point Variety Size (n={n} cells)\nlog₂(|V(f_r - id)| + 1)', fontsize=13)
    ax1.set_xlabel('Rule number (low nibble)')
    ax1.set_ylabel('Rule number (high nibble)')
    
    # Add colorbar
    cbar = plt.colorbar(im, ax=ax1, label='log₂(count + 1)')
    
    # Add annotations for notable rules
    notable = {204: 'Id', 0: '0', 51: '¬b', 110: 'TC', 150: 'Σ', 90: 'XOR'}
    for rule, label in notable.items():
        row, col = rule // 16, rule % 16
        ax1.annotate(label, (col, row), fontsize=7, ha='center', va='center',
                    color='white', fontweight='bold')
    
    # Plot 2: Conjugate duality verification
    ax2 = axes[1]
    rules = list(range(256))
    fp_r = fp_counts
    fp_conj = np.array([count_fixed_points(compute_conjugate(r), n) for r in range(256)])
    
    ax2.scatter(fp_r, fp_conj, alpha=0.5, s=15, c='steelblue')
    ax2.plot([0, max(fp_r)], [0, max(fp_r)], 'r--', alpha=0.5, label='|V(g)| = |V(ḡ)|')
    ax2.set_xlabel('|V(g)| (fixed points of rule g)')
    ax2.set_ylabel('|V(ḡ)| (fixed points of conjugate)')
    ax2.set_title('Conjugate Duality Theorem\n|V(g)| = |V(ḡ)| for all rules', fontsize=13)
    ax2.legend()
    ax2.set_aspect('equal')
    
    plt.tight_layout()
    plt.savefig('eca_variety_dimensions.png', dpi=150, bbox_inches='tight')
    print("Saved: eca_variety_dimensions.png")


if __name__ == "__main__":
    main()
