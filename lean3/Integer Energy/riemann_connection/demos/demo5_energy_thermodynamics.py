#!/usr/bin/env python3
"""
Demo 5: The Thermodynamics of Integer Energy
==============================================

Visualizes the "thermodynamic" analogy:
- Integers as physical systems with microstates (divisors)
- Energy = σ(n)/n as a partition function ratio
- The Robin bound as a "critical temperature"
- Phase transition at n = 5040

Also shows the "grand unified energy" combining multiple measures.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.colors import LogNorm
from math import log, exp, sqrt, pi
import os

output_dir = os.path.join(os.path.dirname(__file__), '..', 'visuals')
os.makedirs(output_dir, exist_ok=True)

EULER_GAMMA = 0.5772156649015329
E_GAMMA = exp(EULER_GAMMA)

# --- Functions ---

def sigma(n):
    if n <= 0: return 0
    s = 0
    for d in range(1, int(n**0.5) + 1):
        if n % d == 0:
            s += d
            if d != n // d:
                s += n // d
    return s

def divisor_count(n):
    if n <= 0: return 0
    c = 0
    for d in range(1, int(n**0.5) + 1):
        if n % d == 0:
            c += 1
            if d != n // d:
                c += 1
    return c

def factorize(n):
    if n <= 1: return {}
    factors = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1
    if n > 1:
        factors[n] = factors.get(n, 0) + 1
    return factors

def omega(n):
    """Number of distinct prime factors."""
    return len(factorize(n))

def big_omega(n):
    """Number of prime factors with multiplicity."""
    return sum(factorize(n).values())

def factorization_entropy(n):
    if n <= 1: return 0
    factors = factorize(n)
    exponents = list(factors.values())
    total = sum(exponents)
    if total <= 1: return 0
    probs = [e / total for e in exponents]
    entropy = -sum(p * log(p) for p in probs if p > 0)
    return entropy

def arithmetic_derivative(n):
    if n <= 1: return 0
    factors = factorize(n)
    return sum(n * e // p for p, e in factors.items())

def robin_ratio(n):
    if n < 3: return 0
    lln = log(log(n))
    if lln <= 0: return 0
    return sigma(n) / (E_GAMMA * n * lln)

# --- Compute unified energy landscape ---

N_MAX = 8000
print(f"Computing unified energy landscape for n = 2 to {N_MAX}...")

data = []
for n in range(2, N_MAX + 1):
    s = sigma(n)
    dc = divisor_count(n)
    ab = s / n
    ent = factorization_entropy(n)
    ad = arithmetic_derivative(n)
    ad_norm = ad / n
    om = omega(n)
    bom = big_omega(n)
    rr = robin_ratio(n)
    
    # Grand Unified Energy (GUE — a playful name)
    # Weighted geometric mean of normalized energy measures
    E1 = ab                          # abundance
    E2 = ent + 0.01                  # entropy (avoid zero)
    E3 = ad_norm + 0.01             # arithmetic derivative
    E4 = dc / (n ** 0.3)            # normalized divisor count
    
    GUE = (E1 ** 2) * (E2 ** 0.5) * (E4 ** 1.5)
    
    data.append({
        'n': n, 'sigma': s, 'div_count': dc, 'abundance': ab,
        'entropy': ent, 'ad_norm': ad_norm, 'omega': om,
        'big_omega': bom, 'robin_ratio': rr, 'GUE': GUE
    })

# --- Figure 1: The Thermodynamic Dashboard ---

fig, axes = plt.subplots(2, 3, figsize=(20, 12))
fig.suptitle("The Thermodynamics of Integer Energy\n"
             "Integers as Statistical Systems with Divisors as Microstates",
             fontsize=16, fontweight='bold')

ns = np.array([d['n'] for d in data])

# Panel 1: "Microstate count" = d(n) vs n
ax1 = axes[0, 0]
dc_arr = np.array([d['div_count'] for d in data])
ax1.scatter(ns, dc_arr, s=0.3, alpha=0.3, c='navy', edgecolors='none')

# Highlight record-setters
record = 0
records_n, records_d = [], []
for d in data:
    if d['div_count'] > record:
        record = d['div_count']
        records_n.append(d['n'])
        records_d.append(d['div_count'])

ax1.plot(records_n, records_d, 'ro-', markersize=5, linewidth=1.5,
         label='HCN staircase', zorder=5)
ax1.set_xlabel('n', fontsize=11)
ax1.set_ylabel('d(n) — "microstates"', fontsize=11)
ax1.set_title('Microstate Count (Divisors)', fontsize=12)
ax1.legend(fontsize=10)

# Panel 2: "Temperature" = σ(n)/n vs n
ax2 = axes[0, 1]
ab_arr = np.array([d['abundance'] for d in data])
ax2.scatter(ns, ab_arr, s=0.3, alpha=0.3, c='darkred', edgecolors='none')

record_ab = 0
rec_ab_n, rec_ab_v = [], []
for d in data:
    if d['abundance'] > record_ab:
        record_ab = d['abundance']
        rec_ab_n.append(d['n'])
        rec_ab_v.append(d['abundance'])

ax2.plot(rec_ab_n, rec_ab_v, 'go-', markersize=5, linewidth=1.5,
         label='SA staircase', zorder=5)

# The Robin ceiling
ns_ceil = np.linspace(16, N_MAX, 500)
ceil_vals = [E_GAMMA * log(log(n)) for n in ns_ceil]
ax2.plot(ns_ceil, ceil_vals, 'k--', linewidth=2, alpha=0.5,
         label=r'$e^\gamma \ln\ln n$ (ceiling)')

ax2.set_xlabel('n', fontsize=11)
ax2.set_ylabel(r'$\sigma(n)/n$ — "temperature"', fontsize=11)
ax2.set_title('Temperature (Abundance Ratio)', fontsize=12)
ax2.legend(fontsize=10)

# Panel 3: "Entropy" of factorization
ax3 = axes[0, 2]
ent_arr = np.array([d['entropy'] for d in data])
colors_omega = np.array([d['omega'] for d in data])
sc3 = ax3.scatter(ns, ent_arr, s=0.5, alpha=0.4, c=colors_omega,
                   cmap='tab10', edgecolors='none', vmin=1, vmax=7)
plt.colorbar(sc3, ax=ax3, label='ω(n) (distinct primes)')
ax3.set_xlabel('n', fontsize=11)
ax3.set_ylabel('Factorization entropy', fontsize=11)
ax3.set_title('Factorization Entropy', fontsize=12)

# Panel 4: "Free energy" = GUE vs n
ax4 = axes[1, 0]
gue_arr = np.array([d['GUE'] for d in data])
ax4.scatter(ns, gue_arr, s=0.5, alpha=0.3, c='purple', edgecolors='none')

# Top GUE numbers
gue_sorted = sorted(data, key=lambda d: -d['GUE'])[:20]
for d in gue_sorted[:10]:
    ax4.scatter([d['n']], [d['GUE']], s=60, c='gold', edgecolors='black', zorder=5)
    ax4.annotate(str(d['n']), (d['n'], d['GUE']),
                 textcoords='offset points', xytext=(5, 5), fontsize=7)

ax4.set_xlabel('n', fontsize=11)
ax4.set_ylabel('Grand Unified Energy', fontsize=11)
ax4.set_title('GUE: Combined Energy Measure', fontsize=12)

# Panel 5: Phase diagram — abundance vs omega
ax5 = axes[1, 1]
om_arr = np.array([d['omega'] for d in data])
sc5 = ax5.scatter(om_arr + np.random.normal(0, 0.08, len(om_arr)),
                   ab_arr, s=1, alpha=0.2, c=np.log(ns), cmap='viridis',
                   edgecolors='none')
plt.colorbar(sc5, ax=ax5, label='ln(n)')

# Highlight special numbers
for n_special in [6, 12, 24, 60, 120, 360, 720, 2520, 5040]:
    idx = n_special - 2
    if idx < len(data):
        d = data[idx]
        ax5.scatter([d['omega']], [d['abundance']], s=80, c='red',
                    edgecolors='black', zorder=5)
        ax5.annotate(str(n_special), (d['omega'], d['abundance']),
                     textcoords='offset points', xytext=(5, 5), fontsize=8)

ax5.set_xlabel('ω(n) — number of distinct prime factors', fontsize=11)
ax5.set_ylabel(r'$\sigma(n)/n$ — abundance', fontsize=11)
ax5.set_title('Phase Diagram: Abundance vs Prime Complexity', fontsize=12)

# Panel 6: The "energy spectrum" — histogram of robin ratios
ax6 = axes[1, 2]
rr_arr = np.array([d['robin_ratio'] for d in data if d['robin_ratio'] > 0])

ax6.hist(rr_arr, bins=100, color='steelblue', alpha=0.7, edgecolor='navy',
         density=True)
ax6.axvline(x=1.0, color='red', linewidth=2, linestyle='--',
            label='Robin bound (R = 1)')
ax6.set_xlabel('Robin Ratio R(n)', fontsize=11)
ax6.set_ylabel('Density', fontsize=11)
ax6.set_title('Distribution of Robin Ratios', fontsize=12)
ax6.legend(fontsize=10)

plt.tight_layout()
plt.savefig(os.path.join(output_dir, 'energy_thermodynamics.png'), dpi=150, bbox_inches='tight')
plt.close()
print(f"✅ Saved: energy_thermodynamics.png")

# --- Figure 2: Top Energy Champions Table ---

fig2, ax_table = plt.subplots(figsize=(14, 8))
fig2.suptitle("The 20 Highest-Energy Integers (by Grand Unified Energy)\n"
              "These are the numbers with the richest internal structure",
              fontsize=14, fontweight='bold')
ax_table.axis('off')

top20 = sorted(data, key=lambda d: -d['GUE'])[:20]
table_data = []
for rank, d in enumerate(top20, 1):
    factors = factorize(d['n'])
    fact_str = ' · '.join(f"{p}^{e}" if e > 1 else str(p) for p, e in sorted(factors.items()))
    table_data.append([
        rank, d['n'], fact_str, d['div_count'],
        f"{d['abundance']:.4f}", f"{d['robin_ratio']:.6f}", f"{d['GUE']:.4f}"
    ])

table = ax_table.table(
    cellText=table_data,
    colLabels=['Rank', 'n', 'Factorization', 'd(n)', 'σ(n)/n', 'Robin R(n)', 'GUE'],
    loc='center',
    cellLoc='center'
)
table.auto_set_font_size(False)
table.set_fontsize(9)
table.scale(1.0, 1.5)

# Color the Robin ratio cells
for i in range(len(table_data)):
    cell = table[i+1, 5]  # Robin ratio column
    rr = float(table_data[i][5])
    if rr > 1.0:
        cell.set_facecolor('#ffcccc')
    elif rr > 0.95:
        cell.set_facecolor('#ffffcc')
    else:
        cell.set_facecolor('#ccffcc')

plt.tight_layout()
plt.savefig(os.path.join(output_dir, 'top_energy_champions.png'), dpi=150, bbox_inches='tight')
plt.close()
print(f"✅ Saved: top_energy_champions.png")

# --- Print the top 20 ---
print("\n" + "="*80)
print("TOP 20 ENERGY CHAMPIONS")
print("="*80)
print(f"{'Rank':>4} {'n':>8} {'Factorization':<25} {'d(n)':>5} {'σ/n':>8} {'R(n)':>10} {'GUE':>8}")
print("-"*80)
for row in table_data:
    print(f"{row[0]:>4} {row[1]:>8} {row[2]:<25} {row[3]:>5} {row[4]:>8} {row[5]:>10} {row[6]:>8}")

print("\n✅ All thermodynamic visualizations complete!")
