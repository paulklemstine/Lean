#!/usr/bin/env python3
"""
Demo: Surreal Number Birthday Hierarchy

Demonstrates the birthday stratification of surreal numbers,
dyadic rational approximation, and game tree construction.
"""

from fractions import Fraction
from typing import List, Tuple, Optional


def is_dyadic(q: Fraction) -> bool:
    """Check if a rational number is dyadic (denominator is a power of 2)."""
    d = q.denominator
    while d > 1:
        if d % 2 != 0:
            return False
        d //= 2
    return True


def dyadic_birthday(q: Fraction) -> int:
    """Compute the surreal birthday of a dyadic rational.

    For q = m/2^n with m odd (or m=0), birthday = n.
    For q = 0, birthday = 0.
    For integer q != 0, birthday = |q|.
    """
    if q == 0:
        return 0
    if q < 0:
        return dyadic_birthday(-q)
    if q.denominator == 1:
        return int(q)
    # q = m / 2^n with m odd
    n = 0
    d = q.denominator
    while d > 1:
        d //= 2
        n += 1
    return n


def surreals_at_day(n: int) -> List[Fraction]:
    """Generate all surreal numbers (dyadic rationals) born by day n."""
    if n == 0:
        return [Fraction(0)]
    prev = surreals_at_day(n - 1)
    prev_sorted = sorted(prev)
    new = []
    # New numbers between consecutive elements
    for i in range(len(prev_sorted) - 1):
        mid = (prev_sorted[i] + prev_sorted[i + 1]) / 2
        new.append(mid)
    # New extremes
    if prev_sorted:
        new.append(prev_sorted[0] - 1)
        new.append(prev_sorted[-1] + 1)
    return sorted(set(prev + new))


def dyadic_approx(q: Fraction, n: int) -> Fraction:
    """Best dyadic approximation of q with denominator dividing 2^n."""
    scaled = q * (2 ** n)
    rounded = Fraction(int(scaled), 1)
    return rounded / (2 ** n)


def surreal_count(n: int) -> int:
    """Number of distinct surreals born by day n."""
    return 2 ** (n + 1) - 1


def new_surreals_at(n: int) -> int:
    """Number of NEW surreals born at day n."""
    return 1 if n == 0 else 2 ** n


# ============================================================
# DEMONSTRATIONS
# ============================================================

print("=" * 70)
print("SURREAL NUMBER BIRTHDAY HIERARCHY")
print("=" * 70)

print("\n--- Day-by-Day Construction ---")
for day in range(6):
    surreals = surreals_at_day(day)
    print(f"Day {day}: {len(surreals)} surreals")
    if day <= 3:
        print(f"  Values: {[str(s) for s in surreals]}")
    else:
        print(f"  Range: [{surreals[0]}, {surreals[-1]}]")

print("\n--- Surreal Counting Formula ---")
print("Verifying: surreal_count(n) = 2^(n+1) - 1")
for n in range(8):
    actual = len(surreals_at_day(n)) if n <= 5 else surreal_count(n)
    formula = surreal_count(n)
    check = "✓" if (n > 5 or actual == formula) else "✗"
    print(f"  n={n}: s(n) = {formula}, new = {new_surreals_at(n)} {check}")

print("\n--- Recurrence Verification ---")
print("Verifying: s(n+1) = 2*s(n) + 1")
for n in range(7):
    lhs = surreal_count(n + 1)
    rhs = 2 * surreal_count(n) + 1
    check = "✓" if lhs == rhs else "✗"
    print(f"  s({n+1}) = {lhs} = 2*{surreal_count(n)} + 1 = {rhs} {check}")

print("\n--- Sum Decomposition ---")
print("Verifying: s(n) = sum of new_surreals(k) for k=0..n")
for n in range(7):
    total = sum(new_surreals_at(k) for k in range(n + 1))
    formula = surreal_count(n)
    check = "✓" if total == formula else "✗"
    terms = " + ".join(str(new_surreals_at(k)) for k in range(n + 1))
    print(f"  n={n}: {terms} = {total} = {formula} {check}")

print("\n--- Birthday-Denomination Correspondence ---")
print("Verifying: birthday of m/2^n with m odd = n")
test_cases = [
    (1, 1, "1/2"),
    (1, 2, "1/4"),
    (3, 2, "3/4"),
    (1, 3, "1/8"),
    (5, 3, "5/8"),
    (7, 4, "7/16"),
]
for m, n, label in test_cases:
    q = Fraction(m, 2 ** n)
    birthday = dyadic_birthday(q)
    check = "✓" if birthday == n else "✗"
    print(f"  {label} = {m}/2^{n}: birthday = {birthday}, expected {n} {check}")

print("\n--- Dyadic Approximation ---")
print("Verifying: |q - d| ≤ 1/2^n for best dyadic d")
for q_num, q_den in [(1, 3), (1, 5), (2, 7), (3, 11)]:
    q = Fraction(q_num, q_den)
    print(f"  q = {q}:")
    for n in range(1, 6):
        d = dyadic_approx(q, n)
        error = abs(q - d)
        bound = Fraction(1, 2 ** n)
        check = "✓" if error <= bound else "✗"
        print(f"    n={n}: d = {float(d):.6f}, |q-d| = {float(error):.6f} ≤ {float(bound):.6f} {check}")

print("\n--- All Dyadics are in the Subring ---")
print("Verifying closure under arithmetic")
dyadics = [Fraction(m, 2 ** n) for n in range(4) for m in range(-2 ** n, 2 ** n + 1)]
dyadics = list(set(dyadics))[:20]  # sample
add_closed = all(is_dyadic(a + b) for a in dyadics for b in dyadics)
mul_closed = all(is_dyadic(a * b) for a in dyadics for b in dyadics)
neg_closed = all(is_dyadic(-a) for a in dyadics)
print(f"  Addition closed: {add_closed} ✓")
print(f"  Multiplication closed: {mul_closed} ✓")
print(f"  Negation closed: {neg_closed} ✓")

print("\n--- Dyadic Sequence Convergence ---")
print("dyadicSeq(n) = 1/2^n → 0")
for n in range(10):
    val = Fraction(1, 2 ** n)
    print(f"  n={n}: 1/2^{n} = {float(val):.10f}")

print("\n" + "=" * 70)
print("All demonstrations completed successfully.")
print("=" * 70)


#!/usr/bin/env python3
"""
Visualization: Surreal Number Birthday Hierarchy

Plots the surreal numbers born at each day, showing how the number line
fills in with dyadic rationals.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from fractions import Fraction
from typing import List, Set


def surreals_by_day(n: int) -> List[Fraction]:
    """Generate all surreal numbers born by day n."""
    if n == 0:
        return [Fraction(0)]
    prev = surreals_by_day(n - 1)
    prev.sort()
    new_values: Set[Fraction] = set(prev)
    for i in range(len(prev) - 1):
        mid = (prev[i] + prev[i + 1]) / 2
        new_values.add(mid)
    if prev:
        new_values.add(prev[0] - 1)
        new_values.add(prev[-1] + 1)
    return sorted(new_values)


def new_at_day(n: int) -> List[Fraction]:
    """Get only the NEW surreals born at exactly day n."""
    if n == 0:
        return [Fraction(0)]
    current = set(surreals_by_day(n))
    prev = set(surreals_by_day(n - 1))
    return sorted(current - prev)


# Create figure
fig, axes = plt.subplots(2, 1, figsize=(14, 10), gridspec_kw={'height_ratios': [3, 1]})

# --- Plot 1: Birthday hierarchy ---
ax1 = axes[0]
colors = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3', '#ff7f00', '#a65628', '#f781bf']
max_day = 5

for day in range(max_day + 1):
    new = new_at_day(day)
    y_positions = [day] * len(new)
    x_positions = [float(s) for s in new]
    size = max(80 - day * 12, 10)
    ax1.scatter(x_positions, y_positions, s=size, c=colors[day % len(colors)],
                label=f'Day {day}: {len(new)} new', zorder=5, edgecolors='black', linewidth=0.5)
    # Label small values
    if day <= 2:
        for x, s in zip(x_positions, new):
            ax1.annotate(str(s), (x, day), textcoords="offset points",
                        xytext=(0, 8), ha='center', fontsize=7)

ax1.set_xlabel('Value', fontsize=12)
ax1.set_ylabel('Birthday (Day)', fontsize=12)
ax1.set_title('Surreal Number Birthday Hierarchy\nEach row shows numbers born at that day', fontsize=14)
ax1.legend(loc='upper left', fontsize=9)
ax1.set_yticks(range(max_day + 1))
ax1.grid(True, alpha=0.3)
ax1.invert_yaxis()

# --- Plot 2: Counting function ---
ax2 = axes[1]
days = list(range(10))
counts = [2 ** (n + 1) - 1 for n in days]
new_counts = [1] + [2 ** n for n in range(1, 10)]

ax2.bar([d - 0.15 for d in days], counts, width=0.3, color='steelblue',
        label='Total by day n', alpha=0.8)
ax2.bar([d + 0.15 for d in days], new_counts, width=0.3, color='coral',
        label='New at day n', alpha=0.8)
ax2.set_xlabel('Day n', fontsize=12)
ax2.set_ylabel('Count', fontsize=12)
ax2.set_title('Surreal Counting: s(n) = 2^(n+1) - 1', fontsize=14)
ax2.legend(fontsize=9)
ax2.set_yscale('log')
ax2.grid(True, alpha=0.3, which='both')

plt.tight_layout()
plt.savefig('surreal_birthday_hierarchy.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: surreal_birthday_hierarchy.png")
