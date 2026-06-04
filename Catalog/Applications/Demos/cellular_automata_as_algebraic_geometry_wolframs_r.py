#!/usr/bin/env python3
"""
Cellular Automata as Algebraic Geometry over GF(2) — Demonstrations

Computes fixed-point varieties for all 256 ECA rules on cyclic arrays,
verifies the complementation duality theorem, and analyzes the correlation
between ANF degree and fixed-point variety dimension.
"""

import itertools
from typing import List, Tuple, Dict


def eca_local_rule(rule_num: int, a: int, b: int, c: int) -> int:
    """Evaluate ECA rule on three binary inputs."""
    index = 4 * a + 2 * b + c
    return (rule_num >> index) & 1


def eca_global_update(rule_num: int, state: Tuple[int, ...]) -> Tuple[int, ...]:
    """Apply ECA rule to cyclic state."""
    n = len(state)
    return tuple(
        eca_local_rule(rule_num, state[(i - 1) % n], state[i], state[(i + 1) % n])
        for i in range(n)
    )


def find_fixed_points(rule_num: int, n: int) -> List[Tuple[int, ...]]:
    """Find all fixed points of an ECA rule on a cycle of length n."""
    fixed = []
    for state in itertools.product([0, 1], repeat=n):
        if eca_global_update(rule_num, state) == state:
            fixed.append(state)
    return fixed


def anf_coefficients(rule_num: int) -> Dict[str, int]:
    """Compute algebraic normal form coefficients over GF(2)."""
    # Truth table values
    f = {}
    for a, b, c in itertools.product([0, 1], repeat=3):
        f[(a, b, c)] = eca_local_rule(rule_num, a, b, c)

    # Möbius inversion for ANF
    a0 = f[(0, 0, 0)]
    a_c = f[(0, 0, 0)] ^ f[(0, 0, 1)]
    a_b = f[(0, 0, 0)] ^ f[(0, 1, 0)]
    a_bc = f[(0, 0, 0)] ^ f[(0, 0, 1)] ^ f[(0, 1, 0)] ^ f[(0, 1, 1)]
    a_a = f[(0, 0, 0)] ^ f[(1, 0, 0)]
    a_ac = f[(0, 0, 0)] ^ f[(0, 0, 1)] ^ f[(1, 0, 0)] ^ f[(1, 0, 1)]
    a_ab = f[(0, 0, 0)] ^ f[(0, 1, 0)] ^ f[(1, 0, 0)] ^ f[(1, 1, 0)]
    a_abc = (f[(0, 0, 0)] ^ f[(0, 0, 1)] ^ f[(0, 1, 0)] ^ f[(0, 1, 1)] ^
             f[(1, 0, 0)] ^ f[(1, 0, 1)] ^ f[(1, 1, 0)] ^ f[(1, 1, 1)])

    return {
        '1': a0, 'c': a_c, 'b': a_b, 'bc': a_bc,
        'a': a_a, 'ac': a_ac, 'ab': a_ab, 'abc': a_abc
    }


def anf_degree(rule_num: int) -> int:
    """Compute the algebraic degree of the rule's ANF."""
    coeffs = anf_coefficients(rule_num)
    deg = -1  # for the zero polynomial
    if coeffs['abc']:
        deg = 3
    elif coeffs['ab'] or coeffs['ac'] or coeffs['bc']:
        deg = 2
    elif coeffs['a'] or coeffs['b'] or coeffs['c']:
        deg = 1
    elif coeffs['1']:
        deg = 0
    return deg


def complement_rule(rule_num: int) -> int:
    """Compute the complement rule number."""
    result = 0
    for a, b, c in itertools.product([0, 1], repeat=3):
        idx = 4 * a + 2 * b + c
        comp_val = 1 ^ eca_local_rule(rule_num, 1 ^ a, 1 ^ b, 1 ^ c)
        result |= (comp_val << idx)
    return result


def is_linear_rule(rule_num: int) -> bool:
    """Check if the rule is GF(2)-linear."""
    if eca_local_rule(rule_num, 0, 0, 0) != 0:
        return False
    for a1, a2, b1, b2, c1, c2 in itertools.product([0, 1], repeat=6):
        lhs = eca_local_rule(rule_num, a1 ^ a2, b1 ^ b2, c1 ^ c2)
        rhs = eca_local_rule(rule_num, a1, b1, c1) ^ eca_local_rule(rule_num, a2, b2, c2)
        if lhs != rhs:
            return False
    return True


def log2_or_none(x: int) -> str:
    """Return log2 if x is a power of 2, else the count."""
    if x == 0:
        return "∅"
    import math
    if x & (x - 1) == 0:
        return f"2^{int(math.log2(x))}"
    return str(x)


# ============================
# DEMONSTRATIONS
# ============================

print("=" * 70)
print("CELLULAR AUTOMATA AS ALGEBRAIC GEOMETRY OVER GF(2)")
print("=" * 70)

# Demo 1: Specific rule analysis
print("\n--- Demo 1: Key Rule Analysis ---\n")
key_rules = [0, 90, 110, 150, 204, 255]
for r in key_rules:
    coeffs = anf_coefficients(r)
    terms = []
    for name in ['1', 'a', 'b', 'c', 'ab', 'ac', 'bc', 'abc']:
        if coeffs[name]:
            terms.append(name)
    anf_str = ' + '.join(terms) if terms else '0'
    deg = anf_degree(r)
    is_lin = is_linear_rule(r)
    comp = complement_rule(r)

    fps = {n: find_fixed_points(r, n) for n in range(1, 9)}
    fp_counts = {n: len(fps[n]) for n in fps}

    print(f"Rule {r:3d}: ANF = {anf_str:20s}  deg = {deg}  linear = {is_lin}  complement = Rule {comp}")
    print(f"         |Fix(n)|: {', '.join(f'n={n}:{log2_or_none(fp_counts[n])}' for n in range(1, 9))}")
    print()

# Demo 2: Complementation duality verification
print("\n--- Demo 2: Complementation Duality Verification ---\n")
duality_verified = True
for r in range(256):
    comp_r = complement_rule(r)
    for n in range(1, 7):
        fps_r = set(find_fixed_points(r, n))
        fps_comp = set(find_fixed_points(comp_r, n))
        # Check: s in Fix(r) iff complement(s) in Fix(comp_r)
        for s in fps_r:
            cs = tuple(1 ^ x for x in s)
            if cs not in fps_comp:
                print(f"DUALITY FAILED: Rule {r}, n={n}, s={s}")
                duality_verified = False
        for t in fps_comp:
            ct = tuple(1 ^ x for x in t)
            if ct not in fps_r:
                print(f"DUALITY FAILED: Rule {comp_r}, n={n}, t={t}")
                duality_verified = False
print(f"Complementation duality verified for all 256 rules, n=1..6: {duality_verified}")

# Demo 3: Linear rules have power-of-2 fixed-point counts
print("\n--- Demo 3: Linear Rules → Power-of-2 Fixed-Point Counts ---\n")
linear_rules = [r for r in range(256) if is_linear_rule(r)]
print(f"Linear rules: {linear_rules}")
all_pow2 = True
for r in linear_rules:
    for n in range(1, 10):
        count = len(find_fixed_points(r, n))
        if count & (count - 1) != 0:  # not a power of 2
            print(f"NOT pow2: Rule {r}, n={n}, |Fix|={count}")
            all_pow2 = False
print(f"All linear rules have power-of-2 fixed-point counts (n=1..9): {all_pow2}")

# Demo 4: Rule 150 fixed-point characterization
print("\n--- Demo 4: Rule 150 Fixed-Point Characterization ---\n")
for n in range(1, 9):
    fps = find_fixed_points(150, n)
    print(f"n={n}: {len(fps)} fixed points: ", end="")
    if n <= 6:
        print([list(s) for s in fps])
    else:
        print(f"(count = {len(fps)})")

print("\nRule 150 fixed points satisfy s[i-1] = s[i+1] for all i:")
print("  n odd  → all entries equal → |Fix| = 2")
print("  n even → evens equal, odds equal → |Fix| = 4")

# Demo 5: ANF degree vs fixed-point dimension correlation
print("\n--- Demo 5: ANF Degree vs Fixed-Point Dimension ---\n")
import math
n_test = 8
degree_to_dims = {0: [], 1: [], 2: [], 3: []}
for r in range(256):
    deg = anf_degree(r)
    if deg < 0:
        continue
    count = len(find_fixed_points(r, n_test))
    dim = math.log2(count) if count > 0 else -1
    degree_to_dims[deg].append((r, count, dim))

for deg in range(4):
    entries = degree_to_dims[deg]
    if entries:
        dims = [e[2] for e in entries]
        avg_dim = sum(d for d in dims if d >= 0) / max(1, len([d for d in dims if d >= 0]))
        print(f"ANF degree {deg}: {len(entries)} rules, avg fixed-point dim (n={n_test}): {avg_dim:.2f}")
        print(f"  dim range: [{min(d for d in dims if d >= 0):.1f}, {max(dims):.1f}]")

# Demo 6: Self-complementary rules
print("\n--- Demo 6: Self-Complementary Rules ---\n")
self_comp = [r for r in range(256) if complement_rule(r) == r]
print(f"Self-complementary rules ({len(self_comp)} total): {self_comp}")
print("\nVerifying fixed-point count is even for n >= 1:")
all_even = True
for r in self_comp:
    for n in range(1, 9):
        count = len(find_fixed_points(r, n))
        if count % 2 != 0:
            print(f"  NOT even: Rule {r}, n={n}, |Fix|={count}")
            all_even = False
print(f"All self-complementary rules have even |Fix| for n=1..8: {all_even}")

print("\n" + "=" * 70)
print("All demonstrations complete.")
print("=" * 70)


#!/usr/bin/env python3
"""
Visualization: ECA Fixed-Point Variety Dimensions across all 256 rules.
Standalone matplotlib script — no local imports.
"""
import itertools
import math
import matplotlib.pyplot as plt
import numpy as np


def eca_local_rule(rule_num, a, b, c):
    return (rule_num >> (4 * a + 2 * b + c)) & 1


def eca_update(rule_num, state):
    n = len(state)
    return tuple(
        eca_local_rule(rule_num, state[(i-1)%n], state[i], state[(i+1)%n])
        for i in range(n)
    )


def count_fixed_points(rule_num, n):
    count = 0
    for state in itertools.product([0, 1], repeat=n):
        if eca_update(rule_num, state) == state:
            count += 1
    return count


def anf_degree(rule_num):
    tt = {}
    for a, b, c in itertools.product([0, 1], repeat=3):
        tt[(a,b,c)] = eca_local_rule(rule_num, a, b, c)
    a0 = tt[(0,0,0)]
    ac = tt[(0,0,0)] ^ tt[(0,0,1)]
    ab_ = tt[(0,0,0)] ^ tt[(0,1,0)]
    abc_c = tt[(0,0,0)] ^ tt[(0,0,1)] ^ tt[(0,1,0)] ^ tt[(0,1,1)]
    aa = tt[(0,0,0)] ^ tt[(1,0,0)]
    aac = tt[(0,0,0)] ^ tt[(0,0,1)] ^ tt[(1,0,0)] ^ tt[(1,0,1)]
    aab = tt[(0,0,0)] ^ tt[(0,1,0)] ^ tt[(1,0,0)] ^ tt[(1,1,0)]
    aabc = (tt[(0,0,0)] ^ tt[(0,0,1)] ^ tt[(0,1,0)] ^ tt[(0,1,1)] ^
            tt[(1,0,0)] ^ tt[(1,0,1)] ^ tt[(1,1,0)] ^ tt[(1,1,1)])
    if aabc: return 3
    if aab or aac or abc_c: return 2
    if aa or ab_ or ac: return 1
    if a0: return 0
    return -1


# Compute data
n = 8
rules = list(range(256))
fp_counts = [count_fixed_points(r, n) for r in rules]
fp_dims = [math.log2(c) if c > 0 else -0.5 for c in fp_counts]
degrees = [anf_degree(r) for r in rules]

# Color map by ANF degree
colors = {-1: '#333333', 0: '#e74c3c', 1: '#3498db', 2: '#2ecc71', 3: '#f39c12'}
rule_colors = [colors[d] for d in degrees]

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('ECA Fixed-Point Varieties over GF(2)', fontsize=16, fontweight='bold')

# Plot 1: Fixed-point dimension for all 256 rules
ax1 = axes[0, 0]
ax1.bar(rules, fp_dims, color=rule_colors, width=1.0, edgecolor='none')
ax1.set_xlabel('Rule Number')
ax1.set_ylabel(f'dim(Fix), n={n}')
ax1.set_title(f'Fixed-Point Variety Dimension (n={n})')
ax1.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
# Legend
from matplotlib.patches import Patch
legend_elements = [Patch(facecolor=colors[d], label=f'deg {d}') for d in [-1, 0, 1, 2, 3]]
ax1.legend(handles=legend_elements, loc='upper right', fontsize=8)

# Plot 2: Distribution of fixed-point counts
ax2 = axes[0, 1]
unique_counts = sorted(set(fp_counts))
count_freq = [fp_counts.count(c) for c in unique_counts]
ax2.bar([math.log2(c) if c > 0 else -0.5 for c in unique_counts],
        count_freq, width=0.3, color='#8e44ad', edgecolor='white')
ax2.set_xlabel(f'log₂|Fix|, n={n}')
ax2.set_ylabel('Number of Rules')
ax2.set_title('Distribution of Fixed-Point Counts')

# Plot 3: Average dim by ANF degree
ax3 = axes[1, 0]
for d in range(4):
    d_dims = [fp_dims[r] for r in range(256) if degrees[r] == d and fp_dims[r] >= 0]
    if d_dims:
        ax3.bar(d, np.mean(d_dims), yerr=np.std(d_dims) if len(d_dims) > 1 else 0,
                color=colors[d], capsize=5, edgecolor='white', linewidth=1.5)
ax3.set_xlabel('ANF Degree')
ax3.set_ylabel(f'Mean dim(Fix), n={n}')
ax3.set_title('ANF Degree vs Mean Fixed-Point Dimension')
ax3.set_xticks([0, 1, 2, 3])

# Plot 4: Fixed-point counts for key rules across n
ax4 = axes[1, 1]
key_rules = [(90, 'Rule 90 (XOR)'), (110, 'Rule 110 (Turing-complete)'),
             (150, 'Rule 150 (total XOR)'), (204, 'Rule 204 (identity)')]
ns = range(1, 11)
for r, label in key_rules:
    counts = [count_fixed_points(r, n_) for n_ in ns]
    dims = [math.log2(c) if c > 0 else 0 for c in counts]
    ax4.plot(list(ns), dims, 'o-', label=label, markersize=5)
ax4.set_xlabel('Cycle Length n')
ax4.set_ylabel('dim(Fix)')
ax4.set_title('Fixed-Point Dimension vs Cycle Length')
ax4.legend(fontsize=8)

plt.tight_layout()
plt.savefig('eca_varieties.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved eca_varieties.png")
