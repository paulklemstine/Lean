#!/usr/bin/env python3
"""
Hypergraph Ramsey Theory: Numerical Demonstrations

Demonstrates the key quantitative results:
1. Tower function growth rates
2. Probabilistic lower bounds for hypergraph Ramsey numbers
3. Comparison of growth across uniformity levels
4. Known values and bounds for small cases
"""
from math import comb, log2, ceil

# === Tower Function ===
def tower(k: int, n: int) -> int:
    """Iterated exponential: tower(0, n) = n, tower(k+1, n) = 2^tower(k, n)."""
    if k == 0:
        return n
    prev = tower(k - 1, n)
    if prev > 1000:  # prevent astronomical numbers
        return float('inf')
    return 2 ** prev

print("=" * 60)
print("TOWER FUNCTION GROWTH")
print("=" * 60)
print(f"{'k':>3} {'tower(k,2)':>25} {'tower(k,3)':>25}")
print("-" * 55)
for k in range(6):
    t2 = tower(k, 2)
    t2_str = str(t2) if t2 < 10**15 else f"~2^{log2(t2):.0f}" if t2 < float('inf') else "too large"
    t3 = tower(k, 3) if k <= 3 else float('inf')
    t3_str = str(t3) if isinstance(t3, int) and t3 < 10**15 else f"~2^{ceil(log2(t3))}" if isinstance(t3, (int, float)) and t3 < float('inf') and t3 > 0 else "too large"
    print(f"{k:>3} {t2_str:>25} {t3_str:>25}")

# === Probabilistic Lower Bound ===
print("\n" + "=" * 60)
print("PROBABILISTIC LOWER BOUND: R_r(k,k)")
print("=" * 60)
print("\nCondition: 2 * C(n,k) < 2^C(k,r) implies R_r(k,k) > n")
print()

for r in [2, 3, 4]:
    print(f"\n--- Uniformity r = {r} ---")
    for k in range(max(r, 3), min(r + 8, 15)):
        ckr = comb(k, r)
        # Find largest n such that 2 * C(n,k) < 2^C(k,r)
        threshold = 2 ** ckr // 2  # = 2^(C(k,r)-1)
        # Binary search for max n
        lo, hi = k, 2 ** ckr
        while lo < hi:
            mid = (lo + hi + 1) // 2
            if 2 * comb(mid, k) < 2 ** ckr:
                lo = mid
            else:
                hi = mid - 1
        n_max = lo
        print(f"  k={k:>2}: C(k,{r})={ckr:>6}, "
              f"2^C(k,{r})={2**ckr if ckr < 50 else '2^'+str(ckr):>15}, "
              f"R_{r}({k},{k}) > {n_max}")

# === Tower Squaring Property ===
print("\n" + "=" * 60)
print("TOWER SQUARING: tower(k,n)^2 ≤ tower(k+1,n) for k≥1, n≥2")
print("=" * 60)
for n in [2, 3, 4, 5]:
    print(f"\nn = {n}:")
    for k in range(1, 5):
        tk = tower(k, n)
        tk1 = tower(k + 1, n) if k <= 2 else "too large"
        sq = tk ** 2
        if isinstance(tk1, int):
            print(f"  k={k}: tower({k},{n})^2 = {sq}, "
                  f"tower({k+1},{n}) = {tk1}, ratio = {tk1/sq:.1f}")
        else:
            print(f"  k={k}: tower({k},{n})^2 = {sq}, tower({k+1},{n}) = {tk1}")

# === Known Hypergraph Ramsey Numbers ===
print("\n" + "=" * 60)
print("KNOWN HYPERGRAPH RAMSEY NUMBERS")
print("=" * 60)
known = {
    (2, 3, 3): 6,    # R(3,3) = 6
    (2, 4, 4): 18,   # R(4,4) = 18
    (2, 5, 5): None,  # 43 ≤ R(5,5) ≤ 48
    (3, 3, 3): 4,     # R_3(3,3) = 4 (trivial: any coloring of triples of 4 vertices)
    (3, 4, 4): 13,    # R_3(4,4) = 13
}
bounds = {
    (2, 5, 5): (43, 48),
    (3, 5, 5): (34, 55),
    (3, 6, 6): (None, None),
    (4, 5, 5): (None, None),
}

print(f"\n{'(r, k, l)':>12} {'Value':>10} {'Notes':>30}")
print("-" * 55)
for (r, k, l), val in known.items():
    note = ""
    if val is None:
        lo, hi = bounds.get((r, k, l), (None, None))
        val_str = f"[{lo}, {hi}]"
        note = "bounds only"
    else:
        val_str = str(val)
    print(f"  ({r},{k},{l}){' ':>6} {val_str:>10} {note:>30}")

for (r, k, l), (lo, hi) in bounds.items():
    if (r, k, l) not in known:
        print(f"  ({r},{k},{l}){' ':>6} {'?':>10} "
              f"{'['+str(lo)+','+str(hi)+']' if lo else 'unknown':>30}")

# === Growth Rate Comparison ===
print("\n" + "=" * 60)
print("GROWTH RATE COMPARISON ACROSS UNIFORMITIES")
print("=" * 60)
print("\nLower bounds from probabilistic method:")
print(f"{'k':>3} {'R_2(k,k) >':>15} {'R_3(k,k) >':>15} {'R_4(k,k) >':>15}")
print("-" * 50)
for k in range(3, 10):
    bounds_by_r = []
    for r in [2, 3, 4]:
        if k < r:
            bounds_by_r.append("-")
            continue
        ckr = comb(k, r)
        lo, hi = k, min(2 ** ckr, 10**15)
        while lo < hi:
            mid = (lo + hi + 1) // 2
            if 2 * comb(mid, k) < 2 ** ckr:
                lo = mid
            else:
                hi = mid - 1
        bounds_by_r.append(str(lo))
    print(f"{k:>3} {bounds_by_r[0]:>15} {bounds_by_r[1]:>15} {bounds_by_r[2]:>15}")

print("\n" + "=" * 60)
print("STEPPING-UP PHENOMENON")
print("=" * 60)
print("""
The stepping-up lemma connects Ramsey numbers across uniformity levels:
  R_{r+1}(k+1, l+1) ≤ R_r(R_{r+1}(k, l+1), R_{r+1}(k+1, l)) + 1

This means:
  - Graph Ramsey numbers (r=2) grow like 2^{Θ(k)} (single exponential)
  - 3-uniform Ramsey numbers grow like tower(1, Θ(k²)) = 2^{Θ(k²)}
  - 4-uniform numbers grow like tower(2, Θ(k)) = 2^{2^{Θ(k)}}
  - r-uniform numbers grow like tower(r-2, Θ(k))

Each level of uniformity adds one level to the tower!
""")

# Verify tower squaring for small cases
print("Verification of tower squaring (tower(k,n)^2 ≤ 2^tower(k,n)):")
for k in range(1, 4):
    for n in range(2, 6):
        tk = tower(k, n)
        if tk < 100:
            print(f"  tower({k},{n}) = {tk}, "
                  f"{tk}^2 = {tk**2}, 2^{tk} = {2**tk}, "
                  f"holds: {tk**2 <= 2**tk}")


#!/usr/bin/env python3
"""
Visualization: Tower Function Growth and Hypergraph Ramsey Number Bounds

Plots the dramatic growth rate differences between graph and hypergraph
Ramsey numbers, illustrating the tower-type growth phenomenon.
"""
import matplotlib.pyplot as plt
import numpy as np
from math import comb, log2


def tower(k, n):
    if k == 0:
        return n
    prev = tower(k - 1, n)
    if prev > 1000:
        return float('inf')
    return 2 ** prev


def prob_lower_bound(k, r):
    """Probabilistic lower bound for R_r(k,k)."""
    if k < r:
        return k
    ckr = comb(k, r)
    if ckr > 60:
        return 2 ** (ckr // k)  # Stirling approximation
    threshold = 2 ** ckr
    lo, hi = k, min(threshold, 10**15)
    while lo < hi:
        mid = (lo + hi + 1) // 2
        try:
            if 2 * comb(mid, k) < threshold:
                lo = mid
            else:
                hi = mid - 1
        except (OverflowError, ValueError):
            hi = mid - 1
    return lo


fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Hypergraph Ramsey Theory: Growth Rates Across Uniformities',
             fontsize=14, fontweight='bold')

# Plot 1: Tower function growth (log scale)
ax1 = axes[0, 0]
ns = list(range(1, 8))
for k in range(4):
    vals = []
    for n in ns:
        v = tower(k, n)
        if v == float('inf'):
            break
        vals.append(np.log2(max(v, 1)))
    ax1.plot(ns[:len(vals)], vals, 'o-', label=f'tower({k}, n)', linewidth=2)
ax1.set_xlabel('n')
ax1.set_ylabel('log₂(tower(k, n))')
ax1.set_title('Tower Function Growth (log scale)')
ax1.legend()
ax1.grid(True, alpha=0.3)

# Plot 2: Probabilistic lower bounds comparison
ax2 = axes[0, 1]
ks = list(range(3, 12))
for r, color, marker in [(2, 'blue', 's'), (3, 'red', 'D'), (4, 'green', '^')]:
    bounds = []
    valid_ks = []
    for k in ks:
        if k >= r:
            lb = prob_lower_bound(k, r)
            if lb < 10**12:
                bounds.append(np.log2(max(lb, 1)))
                valid_ks.append(k)
    ax2.plot(valid_ks, bounds, f'{marker}-', color=color,
             label=f'R_{r}(k,k) lower bound', linewidth=2)
ax2.set_xlabel('k')
ax2.set_ylabel('log₂(lower bound)')
ax2.set_title('Probabilistic Lower Bounds for R_r(k,k)')
ax2.legend()
ax2.grid(True, alpha=0.3)

# Plot 3: C(k,r) growth (number of hyperedges in a clique)
ax3 = axes[1, 0]
ks = list(range(2, 15))
for r in [2, 3, 4, 5]:
    vals = [comb(k, r) if k >= r else 0 for k in ks]
    ax3.plot(ks, vals, 'o-', label=f'C(k,{r})', linewidth=2)
ax3.set_xlabel('k')
ax3.set_ylabel('C(k, r)')
ax3.set_title('Hyperedge Count in Complete Hypergraph')
ax3.legend()
ax3.grid(True, alpha=0.3)
ax3.set_yscale('log')

# Plot 4: Growth rate classification
ax4 = axes[1, 1]
ks = np.arange(3, 10)
# Approximate growth rates
single_exp = 2.0 ** (ks / 2)  # R_2(k,k) ~ 2^{k/2}
double_exp_low = 2.0 ** (ks ** 2 / 6)  # R_3(k,k) lower bound
triple_exp = np.array([tower(2, int(k)) if tower(2, int(k)) < 1e15 else np.nan for k in ks])

ax4.semilogy(ks, single_exp, 'bs-', label='r=2: 2^{k/2} (single exp)', linewidth=2)
ax4.semilogy(ks, double_exp_low, 'rD-', label='r=3: 2^{k²/6} (lower bound)', linewidth=2)
valid = ~np.isnan(triple_exp)
if np.any(valid):
    ax4.semilogy(ks[valid], triple_exp[valid], 'g^-', label='r=4: tower(2,k)', linewidth=2)
ax4.set_xlabel('k')
ax4.set_ylabel('Ramsey number bound')
ax4.set_title('Growth Rate Hierarchy')
ax4.legend(fontsize=8)
ax4.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('hypergraph_ramsey_growth.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: hypergraph_ramsey_growth.png")
