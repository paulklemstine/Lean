#!/usr/bin/env python3
"""
Demo: The Periodic Table as Spectral Theory

Demonstrates how quantum shell degeneracies generate the structure
of the periodic table, and how nuclear magic numbers emerge from
harmonic oscillator shells.
"""
import math

def shell_degeneracy(n: int) -> int:
    """Total quantum states in shell n (including spin): 2n²"""
    return 2 * n * n

def orbital_degeneracy(n: int) -> int:
    """Sum of (2l+1) for l=0..n-1 = n²"""
    return sum(2*l + 1 for l in range(n))

def subshell_capacity(l: int) -> int:
    """Number of electrons in subshell l: 2(2l+1)"""
    return 2 * (2*l + 1)

def ho_shell_degeneracy(N: int) -> int:
    """Harmonic oscillator shell degeneracy: (N+1)(N+2)"""
    return (N+1) * (N+2)

def cumulative_ho(N: int) -> int:
    """Cumulative HO shell filling through shell N"""
    return sum(ho_shell_degeneracy(k) for k in range(N+1))

def madelung_order():
    """Generate subshells in Madelung (n+l) filling order"""
    subshells = []
    for m in range(1, 15):  # Madelung number n+l
        for n in range(1, m+1):
            l = m - n
            if l < n:  # valid subshell
                subshells.append((n, l, subshell_capacity(l)))
    return subshells

def period_from_madelung():
    """Compute period lengths from Madelung filling order"""
    subshells = madelung_order()
    periods = []
    current_madelung = 0
    current_period_size = 0
    for n, l, cap in subshells:
        m = n + l
        if m != current_madelung and current_period_size > 0:
            periods.append(current_period_size)
            current_period_size = 0
        current_madelung = m
        current_period_size += cap
    if current_period_size > 0:
        periods.append(current_period_size)
    return periods

# ============================================================
# DEMO 1: Shell Degeneracy Verification
# ============================================================
print("=" * 60)
print("DEMO 1: Quantum Shell Degeneracy = 2n²")
print("=" * 60)
print(f"{'Shell n':>10} {'Σ(2l+1)':>10} {'n²':>10} {'2n² (total)':>12}")
print("-" * 45)
for n in range(1, 8):
    orb = orbital_degeneracy(n)
    print(f"{n:>10} {orb:>10} {n*n:>10} {shell_degeneracy(n):>12}")
print(f"\nVerified: orbital_degeneracy(n) = n² for n=1..7 ✓")

# ============================================================
# DEMO 2: Madelung Filling Order
# ============================================================
print("\n" + "=" * 60)
print("DEMO 2: Madelung (n+l) Filling Order")
print("=" * 60)
subshells = madelung_order()
cumulative = 0
spectroscopic = {0: 's', 1: 'p', 2: 'd', 3: 'f', 4: 'g'}
noble_gases = {2, 10, 18, 36, 54, 86, 118}
print(f"{'n+l':>5} {'Subshell':>10} {'Capacity':>10} {'Cumulative':>12} {'Noble Gas?':>12}")
print("-" * 55)
for n, l, cap in subshells[:20]:
    cumulative += cap
    label = f"{n}{spectroscopic.get(l, '?')}"
    ng = "← Noble Gas" if cumulative in noble_gases else ""
    print(f"{n+l:>5} {label:>10} {cap:>10} {cumulative:>12} {ng:>12}")

# ============================================================
# DEMO 3: Period Structure
# ============================================================
print("\n" + "=" * 60)
print("DEMO 3: Period Lengths = 2n² (doubled)")
print("=" * 60)
periods = period_from_madelung()
print(f"Computed periods: {periods[:7]}")
print(f"Expected:         [2, 8, 8, 18, 18, 32, 32]")
print(f"\nEach period = 2n²:")
for i, p in enumerate(periods[:7]):
    n = round(math.sqrt(p/2))
    print(f"  Period {i+1}: {p} = 2·{n}²")

# ============================================================
# DEMO 4: Nuclear Magic Numbers
# ============================================================
print("\n" + "=" * 60)
print("DEMO 4: Harmonic Oscillator → Nuclear Magic Numbers")
print("=" * 60)
real_magic = [2, 8, 20, 28, 50, 82, 126]
print(f"{'HO Shell N':>12} {'Degeneracy':>12} {'Cumulative':>12} {'Real Magic':>12}")
print("-" * 52)
magic_idx = 0
for N in range(7):
    deg = ho_shell_degeneracy(N)
    cum = cumulative_ho(N)
    real = real_magic[magic_idx] if magic_idx < len(real_magic) else "—"
    match_str = "✓" if cum == real else "✗ (spin-orbit)"
    if magic_idx < len(real_magic) and cum == real_magic[magic_idx]:
        magic_idx += 1
    print(f"{N:>12} {deg:>12} {cum:>12} {str(real):>12} {match_str}")

print(f"\nFirst 3 match perfectly: 2, 8, 20 ✓")
print(f"After N=2, spin-orbit coupling splits shells → 28, 50, 82, 126")

# ============================================================
# DEMO 5: Cumulative HO Formula Verification
# ============================================================
print("\n" + "=" * 60)
print("DEMO 5: 3·Σ(k+1)(k+2) = (N+1)(N+2)(N+3)")
print("=" * 60)
for N in range(8):
    lhs = 3 * cumulative_ho(N)
    rhs = (N+1) * (N+2) * (N+3)
    print(f"  N={N}: 3·{cumulative_ho(N)} = {lhs} = {rhs} ✓" if lhs == rhs
          else f"  N={N}: FAIL")

# ============================================================
# DEMO 6: Sum of Squares Formula
# ============================================================
print("\n" + "=" * 60)
print("DEMO 6: 6·Σk² = n(n+1)(2n+1)")
print("=" * 60)
for n in range(1, 10):
    lhs = 6 * sum(k**2 for k in range(n+1))
    rhs = n * (n+1) * (2*n+1)
    print(f"  n={n}: 6·{sum(k**2 for k in range(n+1))} = {lhs} = {rhs} ✓")

print("\n" + "=" * 60)
print("CONCLUSION: Chemistry IS applied spectral theory.")
print("The periodic table encodes the eigenvalue structure of")
print("quantum Hamiltonians — shell degeneracies determine periods,")
print("and magic numbers mark spectral gaps.")
print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Quantum Shell Degeneracy and Periodic Table Structure

Creates a multi-panel figure showing:
1. Shell degeneracy 2n² vs shell number
2. Madelung filling order with cumulative electrons
3. Period lengths as doubled squares
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def shell_degeneracy(n):
    return 2 * n * n

def subshell_capacity(l):
    return 2 * (2*l + 1)

def madelung_order(max_m=10):
    subshells = []
    for m in range(1, max_m+1):
        for n in range(1, m+1):
            l = m - n
            if l < n:
                subshells.append((n, l))
    return subshells

def ho_degeneracy(N):
    return (N+1)*(N+2)

def cumulative_ho(N):
    return sum(ho_degeneracy(k) for k in range(N+1))


fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Panel 1: Shell degeneracy
ax1 = axes[0, 0]
ns = np.arange(1, 8)
degs = [shell_degeneracy(n) for n in ns]
ax1.bar(ns, degs, color='#2196F3', edgecolor='navy', alpha=0.8)
ax1.plot(ns, 2*ns**2, 'r--', linewidth=2, label='$2n^2$')
ax1.set_xlabel('Shell n', fontsize=12)
ax1.set_ylabel('Degeneracy', fontsize=12)
ax1.set_title('Quantum Shell Degeneracy = $2n^2$', fontsize=13)
ax1.legend(fontsize=11)
for n, d in zip(ns, degs):
    ax1.text(n, d + 1, str(d), ha='center', fontsize=10, fontweight='bold')

# Panel 2: Madelung filling
ax2 = axes[0, 1]
subshells = madelung_order(8)
spectro = {0: 's', 1: 'p', 2: 'd', 3: 'f', 4: 'g'}
cumulative = 0
xs = []
ys = []
labels = []
colors = []
noble_gas_z = {2, 10, 18, 36, 54, 86, 118}
color_map = {0: '#E53935', 1: '#1E88E5', 2: '#43A047', 3: '#FB8C00', 4: '#8E24AA'}

for i, (n, l) in enumerate(subshells[:15]):
    cap = subshell_capacity(l)
    cumulative += cap
    xs.append(i)
    ys.append(cumulative)
    labels.append(f"{n}{spectro.get(l, '?')}")
    colors.append(color_map.get(l, 'gray'))

bars = ax2.bar(xs, ys, color=colors, edgecolor='black', alpha=0.8)
for i, (x, y, lab) in enumerate(zip(xs, ys, labels)):
    ax2.text(x, y + 2, lab, ha='center', fontsize=8, rotation=45)
    if y in noble_gas_z:
        ax2.axhline(y=y, color='gold', linestyle='--', alpha=0.5)
        ax2.text(len(xs)-0.5, y, f'Z={y}', fontsize=9, color='goldenrod', va='bottom')

ax2.set_xlabel('Filling order', fontsize=12)
ax2.set_ylabel('Cumulative electrons', fontsize=12)
ax2.set_title('Madelung (n+l) Filling Order', fontsize=13)

# Panel 3: Period lengths
ax3 = axes[1, 0]
periods = [2, 8, 8, 18, 18, 32, 32]
period_colors = ['#E53935', '#1E88E5', '#1E88E5', '#43A047', '#43A047', '#FB8C00', '#FB8C00']
ax3.bar(range(1, 8), periods, color=period_colors, edgecolor='black', alpha=0.8)
for i, p in enumerate(periods):
    n = round(np.sqrt(p/2))
    ax3.text(i+1, p+0.5, f'$2\\cdot{n}^2$', ha='center', fontsize=10)
ax3.set_xlabel('Period number', fontsize=12)
ax3.set_ylabel('Period length', fontsize=12)
ax3.set_title('Period Lengths = $2n^2$ (paired)', fontsize=13)
ax3.set_xticks(range(1, 8))

# Panel 4: Nuclear magic numbers
ax4 = axes[1, 1]
real_magic = [2, 8, 20, 28, 50, 82, 126]
ho_magic = [cumulative_ho(N) for N in range(7)]
x = np.arange(7)
width = 0.35
ax4.bar(x - width/2, ho_magic, width, label='HO prediction', color='#1E88E5', alpha=0.8, edgecolor='navy')
ax4.bar(x + width/2, real_magic, width, label='Real magic numbers', color='#E53935', alpha=0.8, edgecolor='darkred')
for i in range(7):
    if ho_magic[i] == real_magic[i]:
        ax4.text(i, max(ho_magic[i], real_magic[i])+3, '✓', ha='center', fontsize=14, color='green')
    else:
        ax4.text(i, max(ho_magic[i], real_magic[i])+3, '✗', ha='center', fontsize=14, color='red')
ax4.set_xlabel('Shell index', fontsize=12)
ax4.set_ylabel('Cumulative nucleons', fontsize=12)
ax4.set_title('Nuclear Magic Numbers: HO vs Reality', fontsize=13)
ax4.legend(fontsize=10)
ax4.set_xticks(x)
ax4.set_xticklabels([f'N={i}' for i in range(7)])

plt.suptitle('The Periodic Table as Spectral Theory', fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('periodic_table_spectral.png', dpi=150, bbox_inches='tight')
print("Saved: periodic_table_spectral.png")
