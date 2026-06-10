#!/usr/bin/env python3
"""
Birthday-Stratified Surreal Arithmetic — Demonstration

Numerical examples illustrating the key theorems:
1. Dyadic subring closure
2. Birthday-denomination principle
3. Dyadic approximation
4. Surreal counting function
5. Game complexity
"""

from fractions import Fraction
from typing import Optional


def is_dyadic(q: Fraction) -> bool:
    """Check if a rational number is dyadic (denominator is a power of 2)."""
    d = q.denominator
    while d > 1:
        if d % 2 != 0:
            return False
        d //= 2
    return True


def dyadic_val(q: Fraction) -> int:
    """Compute the dyadic valuation (2-adic valuation of the denominator)."""
    d = q.denominator
    v = 0
    while d % 2 == 0:
        v += 1
        d //= 2
    return v


def surreal_count(n: int) -> int:
    """Number of distinct surreal values born by day n."""
    return 2 ** (n + 1) - 1


def new_surreals(n: int) -> int:
    """Number of new surreals born on day n."""
    return 1 if n == 0 else 2 ** n


def dyadic_approx(q: Fraction, n: int) -> Fraction:
    """Best dyadic approximation with denominator 2^n."""
    scaled = q * (2 ** n)
    floored = int(scaled)
    if scaled < 0 and scaled != floored:
        floored -= 1
    return Fraction(floored, 2 ** n)


# ─── Demo 1: Dyadic Subring Closure ───
print("=" * 60)
print("Demo 1: Dyadic Subring Closure")
print("=" * 60)

dyadics = [Fraction(1, 2), Fraction(3, 4), Fraction(7, 8), Fraction(5, 16)]
for p in dyadics:
    for q in dyadics:
        s = p + q
        pr = p * q
        assert is_dyadic(s), f"{p} + {q} = {s} is not dyadic!"
        assert is_dyadic(pr), f"{p} * {q} = {pr} is not dyadic!"
        print(f"  {p} + {q} = {s} (dyadic: ✓, ν₂ = {dyadic_val(s)})")
        print(f"  {p} × {q} = {pr} (dyadic: ✓, ν₂ = {dyadic_val(pr)})")

# ─── Demo 2: Birthday-Denomination Principle ───
print("\n" + "=" * 60)
print("Demo 2: Birthday-Denomination Principle")
print("=" * 60)
print("An odd numerator m in m/2^n cannot simplify to a smaller denominator.\n")

test_cases = [(3, 3), (5, 4), (7, 3), (1, 5), (11, 4)]
for m, n in test_cases:
    q = Fraction(m, 2 ** n)
    v = dyadic_val(q)
    print(f"  {m}/2^{n} = {q} → ν₂ = {v} (birthday = {v})")
    # Verify: cannot simplify
    for k in range(n):
        # Check if m/2^n = a/2^k for any integer a
        a_candidate = m * 2**k / 2**n
        if a_candidate == int(a_candidate):
            print(f"    ERROR: simplifies to {int(a_candidate)}/2^{k}!")
        else:
            pass  # Good: cannot simplify
    print(f"    ✓ Cannot be written as a/2^k for any k < {n}")

# ─── Demo 3: Valuation Subadditivity ───
print("\n" + "=" * 60)
print("Demo 3: Dyadic Valuation Subadditivity")
print("=" * 60)
print("ν₂(p + q) ≤ ν₂(p) + ν₂(q) for all dyadic p, q.\n")

for p in dyadics:
    for q in dyadics:
        vp, vq, vpq = dyadic_val(p), dyadic_val(q), dyadic_val(p + q)
        satisfied = "✓" if vpq <= vp + vq else "✗"
        print(f"  ν₂({p} + {q}) = ν₂({p+q}) = {vpq} ≤ {vp} + {vq} = {vp+vq}  {satisfied}")

# ─── Demo 4: Dyadic Approximation ───
print("\n" + "=" * 60)
print("Demo 4: Dyadic Approximation")
print("=" * 60)
print("Every rational can be approximated by a dyadic to within 1/2^n.\n")

targets = [Fraction(1, 3), Fraction(1, 7), Fraction(22, 7)]
for q in targets:
    print(f"  Approximating {q} ≈ {float(q):.6f}:")
    for n in range(1, 8):
        d = dyadic_approx(q, n)
        err = abs(q - d)
        bound = Fraction(1, 2 ** n)
        ok = "✓" if err <= bound else "✗"
        print(f"    n={n}: d = {d} (={float(d):.6f}), "
              f"|error| = {float(err):.6f} ≤ {float(bound):.6f}  {ok}")

# ─── Demo 5: Surreal Counting ───
print("\n" + "=" * 60)
print("Demo 5: Surreal Counting Function")
print("=" * 60)
print("s(n) = 2^(n+1) - 1 = Σ f(k) for k = 0..n\n")

for n in range(8):
    sc = surreal_count(n)
    ns_list = [new_surreals(k) for k in range(n + 1)]
    total = sum(ns_list)
    print(f"  Day {n}: s({n}) = {sc}, "
          f"new = {new_surreals(n)}, "
          f"Σ = {'+'.join(str(x) for x in ns_list)} = {total}  "
          f"{'✓' if sc == total else '✗'}")

# ─── Demo 6: Recurrence Verification ───
print("\n" + "=" * 60)
print("Demo 6: Recurrence s(n+1) = 2·s(n) + 1")
print("=" * 60)

for n in range(7):
    lhs = surreal_count(n + 1)
    rhs = 2 * surreal_count(n) + 1
    print(f"  s({n+1}) = {lhs} = 2·{surreal_count(n)} + 1 = {rhs}  "
          f"{'✓' if lhs == rhs else '✗'}")

# ─── Demo 7: Dyadic Density ───
print("\n" + "=" * 60)
print("Demo 7: Dyadic Density Between Rationals")
print("=" * 60)

pairs = [(Fraction(1, 3), Fraction(1, 2)),
         (Fraction(0), Fraction(1, 100)),
         (Fraction(99, 100), Fraction(1))]

for a, b in pairs:
    print(f"\n  Between {a} and {b}:")
    found = []
    for n in range(1, 10):
        d = dyadic_approx(Fraction(a + b, 2), n)
        if a < d < b and d not in found:
            found.append(d)
            print(f"    n={n}: d = {d} = {float(d):.6f} (ν₂ = {dyadic_val(d)})")
        if len(found) >= 3:
            break

print("\n" + "=" * 60)
print("All demonstrations completed successfully.")
print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Dyadic Approximation Convergence

Shows how dyadic approximations converge to target values,
illustrating the density theorem and approximation bounds.
"""

import matplotlib.pyplot as plt
import numpy as np
from fractions import Fraction


def dyadic_approx(q: Fraction, n: int) -> Fraction:
    power = 2 ** n
    scaled = q * power
    floored = int(scaled)
    if Fraction(floored) > scaled:
        floored -= 1
    return Fraction(floored, power)


fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: Approximation convergence for multiple targets
ax1 = axes[0]
targets = [
    (Fraction(1, 3), '1/3', 'steelblue'),
    (Fraction(1, 7), '1/7', 'coral'),
    (Fraction(22, 7), 'π ≈ 22/7', 'forestgreen'),
    (Fraction(17, 12), '√2 ≈ 17/12', 'purple'),
]

ns = list(range(1, 13))
for q, label, color in targets:
    errors = []
    for n in ns:
        d = dyadic_approx(q, n)
        err = abs(float(q) - float(d))
        errors.append(max(err, 1e-15))  # Avoid log(0)
    ax1.semilogy(ns, errors, 'o-', color=color, label=label, markersize=4)

# Plot the bound 1/2^n
bounds = [1.0 / 2 ** n for n in ns]
ax1.semilogy(ns, bounds, 'k--', linewidth=2, label='Bound: 1/2ⁿ', alpha=0.7)

ax1.set_xlabel('Precision level n', fontsize=12)
ax1.set_ylabel('Approximation error |q - d|', fontsize=12)
ax1.set_title('Dyadic Approximation: Exponential Convergence',
              fontsize=14, fontweight='bold')
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.3)

# Right: Density — filling in the interval [0, 1]
ax2 = axes[1]
colors_bday = plt.cm.Set1(np.linspace(0, 0.8, 8))

for n in range(7):
    denom = 2 ** n
    points = []
    for num in range(denom + 1):
        q = Fraction(num, denom)
        from fractions import Fraction as F
        d = q.denominator
        v = 0
        while d % 2 == 0:
            v += 1
            d //= 2
        if v == n:
            points.append(float(q))

    if points:
        y_vals = [n] * len(points)
        ax2.scatter(points, y_vals, c=[colors_bday[n]], s=max(5, 60 - n * 8),
                   zorder=7 - n, alpha=0.8)

ax2.set_xlabel('Position in [0, 1]', fontsize=12)
ax2.set_ylabel('Birthday (day born)', fontsize=12)
ax2.set_title('Dyadic Density: Filling [0,1] by Birthday',
              fontsize=14, fontweight='bold')
ax2.set_yticks(range(7))
ax2.set_yticklabels([f'Day {i}' for i in range(7)])
ax2.set_xlim(-0.05, 1.05)
ax2.grid(True, alpha=0.3, axis='x')

plt.tight_layout()
plt.savefig('approximation_convergence.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: approximation_convergence.png")


#!/usr/bin/env python3
"""
Visualization: Surreal Birthday Hierarchy

Plots the dyadic rationals colored by birthday (2-adic valuation),
showing how each birthday level fills in the number line.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from fractions import Fraction


def dyadic_valuation(q: Fraction) -> int:
    d = q.denominator
    v = 0
    while d % 2 == 0:
        v += 1
        d //= 2
    return v


def generate_dyadics(max_birthday: int, x_range: tuple = (-3, 3)):
    """Generate all dyadic rationals up to a given birthday in a range."""
    results = []
    for n in range(max_birthday + 1):
        denom = 2 ** n
        lo = int(x_range[0] * denom)
        hi = int(x_range[1] * denom)
        for num in range(lo, hi + 1):
            q = Fraction(num, denom)
            v = dyadic_valuation(q)
            if v == n:  # Only include if this is the birth day
                results.append((float(q), n))
    return results


fig, axes = plt.subplots(2, 1, figsize=(14, 8), gridspec_kw={'height_ratios': [3, 1]})

# Top plot: Birthday hierarchy
ax1 = axes[0]
max_bday = 6
colors = plt.cm.viridis(np.linspace(0, 0.9, max_bday + 1))

for bday in range(max_bday + 1):
    points = [(x, b) for x, b in generate_dyadics(max_bday) if b == bday]
    if points:
        xs, bs = zip(*points)
        ax1.scatter(xs, bs, c=[colors[bday]], s=max(10, 80 - bday * 10),
                   label=f'Birthday {bday}', zorder=5 - bday, alpha=0.8)

ax1.set_xlabel('Value on the number line', fontsize=12)
ax1.set_ylabel('Birthday (2-adic valuation)', fontsize=12)
ax1.set_title('Surreal Birthday Hierarchy: Dyadic Rationals by Construction Day',
              fontsize=14, fontweight='bold')
ax1.legend(loc='upper right', fontsize=9)
ax1.set_yticks(range(max_bday + 1))
ax1.grid(True, alpha=0.3)
ax1.set_xlim(-3, 3)

# Bottom plot: Counting function
ax2 = axes[1]
ns = list(range(8))
counts = [2 ** (n + 1) - 1 for n in ns]
new_counts = [1] + [2 ** n for n in range(1, 8)]

ax2.bar([n - 0.15 for n in ns], counts, width=0.3, color='steelblue',
        label='Total: $2^{n+1}-1$', alpha=0.8)
ax2.bar([n + 0.15 for n in ns], new_counts, width=0.3, color='coral',
        label='New at day n', alpha=0.8)

for i, (c, nc) in enumerate(zip(counts, new_counts)):
    ax2.text(i - 0.15, c + 1, str(c), ha='center', va='bottom', fontsize=8)
    ax2.text(i + 0.15, nc + 1, str(nc), ha='center', va='bottom', fontsize=8)

ax2.set_xlabel('Birthday (day n)', fontsize=12)
ax2.set_ylabel('Count', fontsize=12)
ax2.set_title('Surreal Counting: Exponential Growth', fontsize=13, fontweight='bold')
ax2.legend(fontsize=9)
ax2.set_xticks(ns)

plt.tight_layout()
plt.savefig('birthday_hierarchy.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: birthday_hierarchy.png")


#!/usr/bin/env python3
"""
Visualization: Dyadic Valuation Landscape

Shows the dyadic valuation ν₂(q) as a function of q for dyadic rationals,
revealing the fractal-like structure of the birthday function.
"""

import matplotlib.pyplot as plt
import numpy as np
from fractions import Fraction


def dyadic_valuation(q: Fraction) -> int:
    d = q.denominator
    v = 0
    while d % 2 == 0:
        v += 1
        d //= 2
    return v


fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: Valuation landscape
ax1 = axes[0]
max_n = 7
xs, ys = [], []
for n in range(max_n + 1):
    denom = 2 ** n
    for num in range(1, 4 * denom + 1):
        q = Fraction(num, denom)
        v = dyadic_valuation(q)
        xs.append(float(q))
        ys.append(v)

scatter = ax1.scatter(xs, ys, c=ys, cmap='plasma', s=2, alpha=0.6)
ax1.set_xlabel('q (dyadic rational)', fontsize=12)
ax1.set_ylabel('ν₂(q) = padicValNat(2, q.den)', fontsize=12)
ax1.set_title('Dyadic Valuation Landscape', fontsize=14, fontweight='bold')
ax1.set_xlim(0, 4)
ax1.set_ylim(-0.5, max_n + 0.5)
plt.colorbar(scatter, ax=ax1, label='Birthday')

# Right: Subadditivity demonstration
ax2 = axes[1]
dyadics = []
for n in range(6):
    denom = 2 ** n
    for num in range(1, 3 * denom + 1):
        q = Fraction(num, denom)
        if dyadic_valuation(q) == n:
            dyadics.append(q)

# Sample pairs and plot ν₂(p+q) vs ν₂(p) + ν₂(q)
sums_actual = []
sums_bound = []
for i in range(min(200, len(dyadics))):
    for j in range(i, min(200, len(dyadics))):
        p, q = dyadics[i], dyadics[j]
        va = dyadic_valuation(p + q)
        vb = dyadic_valuation(p) + dyadic_valuation(q)
        sums_actual.append(va)
        sums_bound.append(vb)

ax2.scatter(sums_bound, sums_actual, s=3, alpha=0.3, c='steelblue')
max_val = max(max(sums_bound), max(sums_actual)) + 1
ax2.plot([0, max_val], [0, max_val], 'r--', linewidth=1.5, label='ν₂(p+q) = ν₂(p)+ν₂(q)')
ax2.set_xlabel('ν₂(p) + ν₂(q) (upper bound)', fontsize=12)
ax2.set_ylabel('ν₂(p + q) (actual)', fontsize=12)
ax2.set_title('Valuation Subadditivity', fontsize=14, fontweight='bold')
ax2.legend(fontsize=10)
ax2.set_aspect('equal')
ax2.set_xlim(0, max_val)
ax2.set_ylim(0, max_val)

plt.tight_layout()
plt.savefig('valuation_landscape.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: valuation_landscape.png")
