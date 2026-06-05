#!/usr/bin/env python3
"""
Cellular Automata as Algebraic Geometry over GF(2)
===================================================
Demonstrates the core results: ANF decomposition, complement conjugation,
and fixed-point variety dimensions for all 256 elementary cellular automata.
"""

import itertools
from typing import Callable, Dict, List, Tuple


def gf2(x: int) -> int:
    """Reduce to GF(2)."""
    return x % 2


def eca_local_rule(rule_num: int) -> Callable[[int, int, int], int]:
    """Return the local rule function for a given ECA rule number (0-255)."""
    def g(a: int, b: int, c: int) -> int:
        idx = a * 4 + b * 2 + c
        return (rule_num >> idx) & 1
    return g


def anf_coefficients(rule_num: int) -> List[int]:
    """Compute the Algebraic Normal Form coefficients via Möbius inversion.
    
    Returns [c0, c1, c2, c3, c4, c5, c6, c7] where:
    g(a,b,c) = c0 + c1*a + c2*b + c3*c + c4*ab + c5*ac + c6*bc + c7*abc  (mod 2)
    """
    g = eca_local_rule(rule_num)
    c = [0] * 8
    c[0] = g(0, 0, 0)
    c[1] = gf2(g(0, 0, 0) + g(1, 0, 0))
    c[2] = gf2(g(0, 0, 0) + g(0, 1, 0))
    c[3] = gf2(g(0, 0, 0) + g(0, 0, 1))
    c[4] = gf2(g(0, 0, 0) + g(1, 0, 0) + g(0, 1, 0) + g(1, 1, 0))
    c[5] = gf2(g(0, 0, 0) + g(1, 0, 0) + g(0, 0, 1) + g(1, 0, 1))
    c[6] = gf2(g(0, 0, 0) + g(0, 1, 0) + g(0, 0, 1) + g(0, 1, 1))
    c[7] = gf2(sum(g(a, b, c) for a, b, c in itertools.product([0, 1], repeat=3)))
    return c


def anf_degree(rule_num: int) -> int:
    """Compute the ANF degree of a rule."""
    c = anf_coefficients(rule_num)
    if c[7] != 0:
        return 3
    if any(c[i] != 0 for i in [4, 5, 6]):
        return 2
    if any(c[i] != 0 for i in [1, 2, 3]):
        return 1
    if c[0] != 0:
        return 0
    return -1  # zero polynomial


def anf_string(rule_num: int) -> str:
    """Pretty-print the ANF of a rule."""
    c = anf_coefficients(rule_num)
    terms = []
    monomials = ["1", "a", "b", "c", "ab", "ac", "bc", "abc"]
    for i, (coeff, mono) in enumerate(zip(c, monomials)):
        if coeff:
            terms.append(mono)
    return " + ".join(terms) if terms else "0"


def is_additive(rule_num: int) -> bool:
    """Check if a rule is additive (linear over GF(2))."""
    c = anf_coefficients(rule_num)
    return c[0] == 0 and c[4] == 0 and c[5] == 0 and c[6] == 0 and c[7] == 0


def complement_conjugate_rule(rule_num: int) -> int:
    """Compute the complement-conjugate rule number."""
    g = eca_local_rule(rule_num)
    new_rule = 0
    for a, b, c in itertools.product([0, 1], repeat=3):
        idx = a * 4 + b * 2 + c
        val = gf2(1 + g(gf2(1 + a), gf2(1 + b), gf2(1 + c)))
        new_rule |= (val << idx)
    return new_rule


def count_fixed_points(rule_num: int, n: int) -> int:
    """Count fixed points of ECA rule_num on a cyclic array of n cells."""
    g = eca_local_rule(rule_num)
    count = 0
    for bits in itertools.product([0, 1], repeat=n):
        is_fixed = True
        for i in range(n):
            left = bits[(i - 1) % n]
            center = bits[i]
            right = bits[(i + 1) % n]
            if g(left, center, right) != center:
                is_fixed = False
                break
        if is_fixed:
            count += 1
    return count


def main():
    print("=" * 70)
    print("CELLULAR AUTOMATA AS ALGEBRAIC GEOMETRY OVER GF(2)")
    print("=" * 70)

    # Demo 1: ANF representation
    print("\n--- Algebraic Normal Form (ANF) Examples ---")
    showcase_rules = [0, 90, 110, 150, 204, 255]
    for r in showcase_rules:
        c = anf_coefficients(r)
        print(f"  Rule {r:3d}: g(a,b,c) = {anf_string(r):20s}  degree={anf_degree(r)}  additive={is_additive(r)}")

    # Demo 2: Complement conjugation pairs
    print("\n--- Complement-Conjugate Pairs (Involution on Rule Space) ---")
    seen = set()
    pairs = []
    for r in range(256):
        rc = complement_conjugate_rule(r)
        if r not in seen:
            seen.add(r)
            seen.add(rc)
            if r != rc:
                pairs.append((r, rc))
    
    self_conjugate = [r for r in range(256) if complement_conjugate_rule(r) == r]
    print(f"  Self-conjugate rules: {len(self_conjugate)} (fixed points of involution)")
    print(f"  Conjugate pairs: {len(pairs)}")
    print(f"  Total orbits: {len(self_conjugate) + len(pairs)} (= {len(self_conjugate)} + {len(pairs)})")
    print(f"  First 10 self-conjugate: {self_conjugate[:10]}")
    print(f"  First 5 pairs: {pairs[:5]}")

    # Demo 3: Fixed-point counts for small n
    print("\n--- Fixed-Point Variety Dimensions (n=6 cells) ---")
    n = 6
    print(f"  {'Rule':>6s} | {'ANF':>25s} | {'Degree':>6s} | {'|Fix|':>6s} | {'dim':>4s} | {'Additive':>8s}")
    print("  " + "-" * 68)
    
    for r in [0, 51, 90, 105, 150, 170, 204, 255]:
        fp = count_fixed_points(r, n)
        # For additive rules, |Fix| = 2^d
        import math
        dim = math.log2(fp) if fp > 0 else -1
        print(f"  {r:6d} | {anf_string(r):>25s} | {anf_degree(r):6d} | {fp:6d} | {dim:4.1f} | {is_additive(r)!s:>8s}")

    # Demo 4: Verify complement bijection
    print("\n--- Complement Bijection Verification (n=5) ---")
    n = 5
    for r in [0, 30, 90, 110, 150]:
        rc = complement_conjugate_rule(r)
        fp_r = count_fixed_points(r, n)
        fp_rc = count_fixed_points(rc, n)
        print(f"  Rule {r:3d} <-> Rule {rc:3d}: |Fix(r)|={fp_r}, |Fix(r̃)|={fp_rc}  {'✓' if fp_r == fp_rc else '✗'}")

    # Demo 5: Additive rules => power-of-2 fixed points
    print("\n--- Additive Rules: Fixed-Point Count is Always 2^d ---")
    additive_rules = [r for r in range(256) if is_additive(r)]
    print(f"  Number of additive rules: {len(additive_rules)}")
    print(f"  Additive rules: {additive_rules}")
    
    n = 7
    print(f"\n  Verification for n={n}:")
    all_power_of_two = True
    for r in additive_rules:
        fp = count_fixed_points(r, n)
        is_pow2 = fp > 0 and (fp & (fp - 1)) == 0
        if not is_pow2:
            all_power_of_two = False
        import math
        d = int(math.log2(fp)) if fp > 0 else -1
        print(f"    Rule {r:3d}: g(a,b,c) = {anf_string(r):12s}  |Fix| = {fp:4d} = 2^{d}")
    
    print(f"  All additive rules have power-of-2 fixed points: {all_power_of_two}")

    # Demo 6: ANF degree distribution
    print("\n--- ANF Degree Distribution Across All 256 Rules ---")
    degree_counts = {-1: 0, 0: 0, 1: 0, 2: 0, 3: 0}
    for r in range(256):
        degree_counts[anf_degree(r)] += 1
    for d in sorted(degree_counts.keys()):
        label = f"degree {d}" if d >= 0 else "zero   "
        print(f"  {label}: {degree_counts[d]:3d} rules")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Fixed-Point Variety Dimensions for All 256 ECAs
"""

import itertools
import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def eca_truth_table(rule_num):
    return [(rule_num >> i) & 1 for i in range(8)]


def anf_coefficients(rule_num):
    g = lambda a, b, c: eca_truth_table(rule_num)[a*4 + b*2 + c]
    c = [0]*8
    c[0] = g(0,0,0)
    c[1] = (g(0,0,0)+g(1,0,0))%2
    c[2] = (g(0,0,0)+g(0,1,0))%2
    c[3] = (g(0,0,0)+g(0,0,1))%2
    c[4] = (g(0,0,0)+g(1,0,0)+g(0,1,0)+g(1,1,0))%2
    c[5] = (g(0,0,0)+g(1,0,0)+g(0,0,1)+g(1,0,1))%2
    c[6] = (g(0,0,0)+g(0,1,0)+g(0,0,1)+g(0,1,1))%2
    c[7] = sum(g(a,b,c) for a,b,c in itertools.product([0,1],repeat=3))%2
    return c


def anf_degree(rule_num):
    c = anf_coefficients(rule_num)
    if c[7]: return 3
    if any(c[i] for i in [4,5,6]): return 2
    if any(c[i] for i in [1,2,3]): return 1
    if c[0]: return 0
    return -1


def count_fixed_points(rule_num, n):
    tt = eca_truth_table(rule_num)
    count = 0
    for bits in itertools.product([0,1], repeat=n):
        ok = True
        for i in range(n):
            idx = bits[(i-1)%n]*4 + bits[i]*2 + bits[(i+1)%n]
            if tt[idx] != bits[i]:
                ok = False
                break
        if ok:
            count += 1
    return count


def complement_conjugate(rule_num):
    tt = eca_truth_table(rule_num)
    new = 0
    for a,b,c in itertools.product([0,1], repeat=3):
        idx = a*4 + b*2 + c
        val = (1 + tt[(1-a)*4 + (1-b)*2 + (1-c)]) % 2
        new |= (val << idx)
    return new


# === Figure 1: Fixed-point count heatmap ===
n = 8
fp_counts = [count_fixed_points(r, n) for r in range(256)]

fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# Heatmap
grid = np.array(fp_counts).reshape(16, 16)
im = axes[0].imshow(grid, cmap='viridis', aspect='auto')
axes[0].set_title(f'Fixed-Point Count |V(f)| for n={n} cells', fontsize=12)
axes[0].set_xlabel('Rule number (low nibble)')
axes[0].set_ylabel('Rule number (high nibble)')
plt.colorbar(im, ax=axes[0], label='Number of fixed points')

# Degree vs fixed points
degrees = [anf_degree(r) for r in range(256)]
for deg in [-1, 0, 1, 2, 3]:
    idx = [r for r in range(256) if degrees[r] == deg]
    fps = [fp_counts[r] for r in idx]
    label = f'deg={deg}' if deg >= 0 else 'zero'
    axes[1].scatter([deg + np.random.uniform(-0.2, 0.2) for _ in idx], 
                    [math.log2(fp + 0.5) for fp in fps],
                    alpha=0.5, s=15, label=label)
axes[1].set_xlabel('ANF Polynomial Degree')
axes[1].set_ylabel('log₂(|Fix| + 0.5)')
axes[1].set_title('ANF Degree vs Fixed-Point Count', fontsize=12)
axes[1].legend()

# Complement conjugation verification
fp_orig = []
fp_conj = []
for r in range(256):
    rc = complement_conjugate(r)
    fp_orig.append(fp_counts[r])
    fp_conj.append(fp_counts[rc])
axes[2].scatter(fp_orig, fp_conj, alpha=0.4, s=10, c='crimson')
axes[2].plot([0, max(fp_counts)], [0, max(fp_counts)], 'k--', alpha=0.5, label='y=x')
axes[2].set_xlabel('|Fix(g)|')
axes[2].set_ylabel('|Fix(g̃)|')
axes[2].set_title('Complement Bijection: |Fix(g)| = |Fix(g̃)|', fontsize=12)
axes[2].legend()

plt.tight_layout()
plt.savefig('eca_algebraic_geometry.png', dpi=150)
print("Saved eca_algebraic_geometry.png")
