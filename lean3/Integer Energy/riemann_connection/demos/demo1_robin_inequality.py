#!/usr/bin/env python3
"""
Demo 1: Robin's Inequality — The Energy Ceiling
================================================

Visualizes σ(n) / (e^γ · n · ln(ln(n))) for integers n, showing:
- The Robin ratio R(n) approaching but never exceeding 1 for n ≥ 5041
- The special role of highly composite / superabundant numbers as "spikes"
- The critical boundary at n = 5040

The Riemann Hypothesis is equivalent to: R(n) < 1 for all n ≥ 5041.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from math import exp, log, gcd
from collections import defaultdict
import os

# --- Number-theoretic functions ---

def sigma(n):
    """Sum of divisors of n."""
    if n <= 0:
        return 0
    s = 0
    for d in range(1, int(n**0.5) + 1):
        if n % d == 0:
            s += d
            if d != n // d:
                s += n // d
    return s

def divisor_count(n):
    """Number of divisors of n."""
    if n <= 0:
        return 0
    count = 0
    for d in range(1, int(n**0.5) + 1):
        if n % d == 0:
            count += 1
            if d != n // d:
                count += 1
    return count

EULER_GAMMA = 0.5772156649015329
E_GAMMA = exp(EULER_GAMMA)

def robin_bound(n):
    """The Robin bound: e^γ · n · ln(ln(n))."""
    if n < 3:
        return float('inf')
    lln = log(log(n))
    if lln <= 0:
        return float('inf')
    return E_GAMMA * n * lln

def robin_ratio(n):
    """R(n) = σ(n) / (e^γ · n · ln(ln(n)))."""
    rb = robin_bound(n)
    if rb == float('inf') or rb <= 0:
        return None
    return sigma(n) / rb

# --- Computation ---

print("Computing Robin ratios for n = 1 to 20,000...")
N_MAX = 20000

ns = list(range(3, N_MAX + 1))
ratios = []
for n in ns:
    r = robin_ratio(n)
    if r is not None:
        ratios.append((n, r))

ns_arr = np.array([x[0] for x in ratios])
rs_arr = np.array([x[1] for x in ratios])

# Find all n where R(n) > 1
violations = [(n, r) for n, r in ratios if r > 1.0]
print(f"\nNumbers with R(n) > 1: {len(violations)}")
print(f"Largest violation: n = {violations[-1][0]}, R(n) = {violations[-1][1]:.8f}")

# Find the top energy champions for n >= 5041
above_5040 = [(n, r) for n, r in ratios if n > 5040]
above_5040_sorted = sorted(above_5040, key=lambda x: -x[1])[:15]
print(f"\nTop 15 Robin ratios for n > 5040:")
for n, r in above_5040_sorted:
    print(f"  n = {n:>8}, R(n) = {r:.8f}, σ(n) = {sigma(n)}, d(n) = {divisor_count(n)}")

# --- Figure 1: Full Robin Ratio Landscape ---

output_dir = os.path.join(os.path.dirname(__file__), '..', 'visuals')
os.makedirs(output_dir, exist_ok=True)

fig, axes = plt.subplots(2, 2, figsize=(16, 12))
fig.suptitle("Robin's Inequality and the Riemann Hypothesis\n"
             r"$R(n) = \sigma(n) \,/\, (e^\gamma \cdot n \cdot \ln\ln n)$",
             fontsize=16, fontweight='bold')

# Panel 1: Full landscape
ax1 = axes[0, 0]
ax1.scatter(ns_arr, rs_arr, s=0.3, alpha=0.4, c='steelblue', edgecolors='none')
ax1.axhline(y=1.0, color='red', linewidth=2, linestyle='--', label=r'$R(n) = 1$ (Robin bound)')
ax1.axvline(x=5040, color='darkgreen', linewidth=1.5, linestyle=':', label='n = 5040')
ax1.set_xlabel('n', fontsize=12)
ax1.set_ylabel('R(n)', fontsize=12)
ax1.set_title('Robin Ratio for n = 3 to 20,000', fontsize=13)
ax1.legend(fontsize=10)
ax1.set_ylim(0, 1.8)

# Panel 2: Zoom on the critical region around 5040
ax2 = axes[0, 1]
mask_zoom = (ns_arr >= 4000) & (ns_arr <= 7000)
ax2.scatter(ns_arr[mask_zoom], rs_arr[mask_zoom], s=2, alpha=0.6, c='steelblue', edgecolors='none')
ax2.axhline(y=1.0, color='red', linewidth=2, linestyle='--')
ax2.axvline(x=5040, color='darkgreen', linewidth=1.5, linestyle=':')

# Highlight 5040
idx_5040 = list(ns_arr).index(5040) if 5040 in ns_arr else None
if idx_5040 is not None:
    ax2.scatter([5040], [rs_arr[idx_5040]], s=100, c='gold', edgecolors='black',
                zorder=5, label=f'5040: R = {rs_arr[idx_5040]:.6f}')
ax2.set_xlabel('n', fontsize=12)
ax2.set_ylabel('R(n)', fontsize=12)
ax2.set_title('Zoom: The Critical Boundary at 5040', fontsize=13)
ax2.legend(fontsize=10)
ax2.set_ylim(0.5, 1.15)

# Panel 3: Violations histogram (all n with R(n) > 1)
ax3 = axes[1, 0]
viol_ns = [n for n, r in violations]
ax3.hist(viol_ns, bins=50, color='crimson', alpha=0.7, edgecolor='darkred')
ax3.axvline(x=5040, color='darkgreen', linewidth=2, linestyle=':', label='n = 5040')
ax3.set_xlabel('n', fontsize=12)
ax3.set_ylabel('Count', fontsize=12)
ax3.set_title('Distribution of Robin Violations (R(n) > 1)', fontsize=13)
ax3.legend(fontsize=10)

# Panel 4: Running maximum of R(n) for n >= 5041
ax4 = axes[1, 1]
above = [(n, r) for n, r in ratios if n >= 5041]
running_max = []
current_max = 0
for n, r in above:
    current_max = max(current_max, r)
    running_max.append((n, current_max))

rm_ns = np.array([x[0] for x in running_max])
rm_rs = np.array([x[1] for x in running_max])
ax4.plot(rm_ns, rm_rs, color='darkblue', linewidth=1.5)
ax4.axhline(y=1.0, color='red', linewidth=2, linestyle='--', label='Robin bound')
ax4.set_xlabel('n', fontsize=12)
ax4.set_ylabel('Running max R(n)', fontsize=12)
ax4.set_title('Running Maximum of R(n) for n ≥ 5041', fontsize=13)
ax4.legend(fontsize=10)
ax4.set_ylim(0.99, 1.01)

plt.tight_layout()
plt.savefig(os.path.join(output_dir, 'robin_inequality_landscape.png'), dpi=150, bbox_inches='tight')
plt.close()
print(f"\n✅ Saved: robin_inequality_landscape.png")

# --- Figure 2: The Energy Champions ---

# Identify superabundant numbers (σ(n)/n record-setters)
print("\nFinding superabundant numbers up to 20,000...")
record = 0
superabundants = []
for n in range(1, N_MAX + 1):
    ratio = sigma(n) / n
    if ratio > record:
        record = ratio
        superabundants.append((n, ratio, divisor_count(n)))

print(f"Found {len(superabundants)} superabundant numbers")
for n, r, d in superabundants:
    rr = robin_ratio(n)
    rr_str = f"{rr:.6f}" if rr is not None else "N/A"
    print(f"  n = {n:>6}, σ(n)/n = {r:.6f}, d(n) = {d:>3}, R(n) = {rr_str}")

fig2, (ax_top, ax_bot) = plt.subplots(2, 1, figsize=(14, 10))
fig2.suptitle("The Energy Champions: Superabundant Numbers\n"
              r"Numbers that set records for $\sigma(n)/n$",
              fontsize=15, fontweight='bold')

sa_ns = [x[0] for x in superabundants if x[0] >= 3]
sa_ratios = [robin_ratio(x[0]) for x in superabundants if x[0] >= 3]
sa_ratios = [r for r in sa_ratios if r is not None]
sa_ns_valid = sa_ns[:len(sa_ratios)]

ax_top.bar(range(len(sa_ns_valid)), sa_ratios, color=['crimson' if r > 1 else 'steelblue' for r in sa_ratios],
           alpha=0.8, edgecolor='black', linewidth=0.5)
ax_top.axhline(y=1.0, color='red', linewidth=2, linestyle='--', label='Robin bound')
ax_top.set_xticks(range(len(sa_ns_valid)))
ax_top.set_xticklabels([str(n) for n in sa_ns_valid], rotation=45, ha='right', fontsize=8)
ax_top.set_ylabel('Robin Ratio R(n)', fontsize=12)
ax_top.set_title('Robin Ratio at Each Superabundant Number', fontsize=13)
ax_top.legend(fontsize=10)

# Abundance ratio σ(n)/n for champions
sa_all_ns = [x[0] for x in superabundants]
sa_all_abund = [x[1] for x in superabundants]

ax_bot.plot(sa_all_ns, sa_all_abund, 'o-', color='darkgreen', markersize=6, linewidth=1.5)
ax_bot.set_xlabel('n (superabundant)', fontsize=12)
ax_bot.set_ylabel(r'$\sigma(n)/n$ (abundance)', fontsize=12)
ax_bot.set_title('Abundance Ratio at Superabundant Numbers', fontsize=13)

for n, r, d in superabundants:
    if n in [6, 12, 60, 120, 360, 2520, 5040]:
        ax_bot.annotate(f'{n}\n({d} div)', (n, r), textcoords='offset points',
                        xytext=(10, 10), fontsize=8, fontweight='bold',
                        arrowprops=dict(arrowstyle='->', color='gray'))

plt.tight_layout()
plt.savefig(os.path.join(output_dir, 'energy_champions.png'), dpi=150, bbox_inches='tight')
plt.close()
print(f"✅ Saved: energy_champions.png")

# --- Figure 3: Why 5040 is special ---

fig3, axes3 = plt.subplots(1, 3, figsize=(18, 6))
fig3.suptitle("Why 5040 = 7! Is Special", fontsize=15, fontweight='bold')

# Left: Factorization comparison
special_numbers = [
    (5040, "5040 = 7!"),
    (5041, "5041 (prime)"),
    (7920, "7920 = 2⁴·3²·5·11"),
    (10080, "10080 = 2⁵·3²·5·7"),
    (2520, "2520 = 2³·3²·5·7"),
    (720, "720 = 2⁴·3²·5"),
]

labels = [s[1] for s in special_numbers]
sigmas = [sigma(s[0]) for s in special_numbers]
divs = [divisor_count(s[0]) for s in special_numbers]
robins = [robin_ratio(s[0]) or 0 for s in special_numbers]

x_pos = np.arange(len(special_numbers))
ax3l = axes3[0]
bars = ax3l.barh(x_pos, robins, color=['gold' if r > 1 else 'steelblue' for r in robins],
                 edgecolor='black', linewidth=0.5)
ax3l.axvline(x=1.0, color='red', linewidth=2, linestyle='--')
ax3l.set_yticks(x_pos)
ax3l.set_yticklabels(labels, fontsize=9)
ax3l.set_xlabel('Robin Ratio R(n)', fontsize=11)
ax3l.set_title('Robin Ratio Comparison', fontsize=12)

# Middle: Divisor count comparison  
ax3m = axes3[1]
ax3m.barh(x_pos, divs, color='mediumseagreen', edgecolor='black', linewidth=0.5)
ax3m.set_yticks(x_pos)
ax3m.set_yticklabels(labels, fontsize=9)
ax3m.set_xlabel('Number of Divisors d(n)', fontsize=11)
ax3m.set_title('Divisor Count Comparison', fontsize=12)

for i, (d, r) in enumerate(zip(divs, robins)):
    ax3m.text(d + 1, i, str(d), va='center', fontsize=10, fontweight='bold')

# Right: σ(n)/n (abundance)
ax3r = axes3[2]
abunds = [sigma(s[0])/s[0] for s in special_numbers]
ax3r.barh(x_pos, abunds, color='coral', edgecolor='black', linewidth=0.5)
ax3r.set_yticks(x_pos)
ax3r.set_yticklabels(labels, fontsize=9)
ax3r.set_xlabel(r'$\sigma(n)/n$ (Abundance)', fontsize=11)
ax3r.set_title('Abundance Comparison', fontsize=12)

plt.tight_layout()
plt.savefig(os.path.join(output_dir, 'why_5040_is_special.png'), dpi=150, bbox_inches='tight')
plt.close()
print(f"✅ Saved: why_5040_is_special.png")

# --- Summary Statistics ---
print("\n" + "="*60)
print("SUMMARY: Robin's Inequality Verification")
print("="*60)
print(f"Range checked: n = 3 to {N_MAX}")
print(f"Total violations (R(n) > 1): {len(violations)}")
print(f"All violations satisfy n ≤ 5040: {all(n <= 5040 for n, _ in violations)}")
print(f"Maximum R(n) for n ≥ 5041: {max(r for n, r in ratios if n >= 5041):.8f}")
print(f"R(5040) = {robin_ratio(5040):.10f}")
print(f"σ(5040) = {sigma(5040)}")
print(f"d(5040) = {divisor_count(5040)}")
print(f"\n✅ Robin's inequality holds for all n in [5041, {N_MAX}]")
print(f"   Consistent with the Riemann Hypothesis.")
