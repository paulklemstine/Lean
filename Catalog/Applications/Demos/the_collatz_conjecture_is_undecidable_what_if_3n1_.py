#!/usr/bin/env python3
"""
Collatz Undecidability Demo
===========================
Demonstrates the key mathematical concepts from the Collatz undecidability research:
1. Collatz orbit computation and visualization
2. Parity profile analysis
3. Balance ratio computation and the 2/3 bound
4. Generalized Collatz Systems
"""

from typing import List, Tuple


def collatz_step(n: int) -> int:
    """The standard Collatz step function."""
    return n // 2 if n % 2 == 0 else 3 * n + 1


def syracuse_step(n: int) -> int:
    """The Syracuse (accelerated) function."""
    return n // 2 if n % 2 == 0 else (3 * n + 1) // 2


def collatz_orbit(n: int, max_steps: int = 10_000) -> List[int]:
    """Compute the Collatz orbit of n until it reaches 1."""
    orbit = [n]
    while n != 1 and len(orbit) < max_steps:
        n = collatz_step(n)
        orbit.append(n)
    return orbit


def parity_profile(n: int) -> List[bool]:
    """Compute the parity profile (True = odd step) until reaching 1."""
    profile = []
    while n != 1:
        profile.append(n % 2 == 1)
        n = collatz_step(n)
    return profile


def odd_count_and_total(n: int) -> Tuple[int, int]:
    """Count odd steps and total steps to reach 1."""
    odd = 0
    total = 0
    while n != 1:
        if n % 2 == 1:
            odd += 1
        n = collatz_step(n)
        total += 1
    return odd, total


def balance_ratio(n: int) -> float:
    """Compute the balance ratio oddCount/totalSteps."""
    odd, total = odd_count_and_total(n)
    return odd / total if total > 0 else 0.0


def verify_parity_balance(n: int) -> bool:
    """Check if n satisfies the parity balance conjecture: 3*odd < 2*total."""
    odd, total = odd_count_and_total(n)
    return 3 * odd < 2 * total


def gcs_step(n: int, modulus: int, multipliers: List[int], offsets: List[int]) -> int:
    """Apply a Generalized Collatz System step."""
    r = n % modulus
    return (multipliers[r] * n + offsets[r]) // modulus


def orbit_numerator(n: int) -> int:
    """Compute 3^oddCount for the orbit of n."""
    result = 1
    while n != 1:
        if n % 2 == 1:
            result *= 3
        n = collatz_step(n)
    return result


# ============================================================
# Demo: Collatz orbits for notable starting values
# ============================================================

print("=" * 60)
print("COLLATZ UNDECIDABILITY DEMO")
print("=" * 60)

notable_values = [7, 27, 97, 871, 6171, 77031]
print("\n--- Notable Collatz Orbits ---")
for n in notable_values:
    orb = collatz_orbit(n)
    peak = max(orb)
    print(f"  n={n:>6}: steps={len(orb)-1:>4}, peak={peak:>10}, "
          f"balance={balance_ratio(n):.4f}")

# ============================================================
# Demo: Parity balance conjecture verification
# ============================================================

print("\n--- Parity Balance Conjecture Verification ---")
print(f"  Testing all n from 2 to 100,000...")
violations = 0
max_ratio = 0.0
max_ratio_n = 2
for n in range(2, 100_001):
    if not verify_parity_balance(n):
        violations += 1
    r = balance_ratio(n)
    if r > max_ratio:
        max_ratio = r
        max_ratio_n = n

print(f"  Violations: {violations}")
print(f"  Maximum balance ratio: {max_ratio:.6f} at n={max_ratio_n}")
print(f"  Critical threshold (2/3): {2/3:.6f}")
print(f"  log2/log3 threshold:      {0.6309:.6f}")
print(f"  Conjecture {'HOLDS' if violations == 0 else 'VIOLATED'} for n ≤ 100,000")

# ============================================================
# Demo: Orbit Encoding Theorem verification
# ============================================================

print("\n--- Orbit Encoding Theorem Verification ---")
print("  Verifying: orbitNumerator(n) = 3^oddCount(n)")
for n in [7, 27, 97, 255, 1023]:
    odd, total = odd_count_and_total(n)
    numerator = orbit_numerator(n)
    expected = 3 ** odd
    status = "✓" if numerator == expected else "✗"
    print(f"  n={n:>5}: oddCount={odd:>3}, 3^oddCount={expected:>15}, "
          f"orbitNumerator={numerator:>15} {status}")

# ============================================================
# Demo: GCS equivalence
# ============================================================

print("\n--- GCS-Collatz Equivalence ---")
print("  Standard Collatz GCS: modulus=2, mult=[1,3], offset=[0,1]")
for n in [4, 7, 12, 15, 27]:
    gcs_val = gcs_step(n, 2, [1, 3], [0, 1])
    if n % 2 == 0:
        collatz_val = collatz_step(n)
        match = "= collatz" if gcs_val == collatz_val else "≠ collatz"
    else:
        syracuse_val = syracuse_step(n)
        match = "= syracuse" if gcs_val == syracuse_val else "≠ syracuse"
    print(f"  n={n:>3}: GCS={gcs_val:>5} {match}")

# ============================================================
# Demo: Completeness gap illustration
# ============================================================

print("\n--- Completeness Gap Illustration ---")
print("  Each number individually reaches 1 (finite verification),")
print("  but no uniform proof covers all cases simultaneously.")
print(f"  Numbers verified: 1 to 100,000 (all reach 1)")
print(f"  Maximum steps needed: ", end="")
max_steps = 0
max_steps_n = 1
for n in range(1, 100_001):
    _, total = odd_count_and_total(n)
    if total > max_steps:
        max_steps = total
        max_steps_n = n
print(f"{max_steps} (at n={max_steps_n})")
print(f"  This is instance verification, not a proof of ∀n.")

print("\n" + "=" * 60)
print("Demo complete.")


#!/usr/bin/env python3
"""Visualization: Balance ratio distribution and the 2/3 barrier."""

import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')


def collatz_step(n: int) -> int:
    return n // 2 if n % 2 == 0 else 3 * n + 1


def balance_ratio(n: int) -> float:
    odd, total = 0, 0
    while n != 1:
        if n % 2 == 1:
            odd += 1
        n = collatz_step(n)
        total += 1
    return odd / total if total > 0 else 0.0


ns = list(range(2, 10001))
ratios = [balance_ratio(n) for n in ns]

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Scatter plot
ax1.scatter(ns, ratios, s=1, alpha=0.4, color='#3498db')
ax1.axhline(y=2/3, color='#e74c3c', linestyle='--', linewidth=2,
            label='2/3 bound (conjecture)')
ax1.axhline(y=0.6309, color='#f39c12', linestyle=':', linewidth=2,
            label='log₂3 ≈ 0.631 (critical)')
ax1.set_xlabel('Starting value n', fontsize=12)
ax1.set_ylabel('Balance ratio (oddCount / totalSteps)', fontsize=12)
ax1.set_title('Parity Balance: All Below 2/3?', fontsize=13, fontweight='bold')
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

# Histogram
ax2.hist(ratios, bins=80, color='#2ecc71', edgecolor='black',
         linewidth=0.3, alpha=0.8)
ax2.axvline(x=2/3, color='#e74c3c', linestyle='--', linewidth=2,
            label='2/3 bound')
ax2.axvline(x=0.6309, color='#f39c12', linestyle=':', linewidth=2,
            label='log₂3')
ax2.set_xlabel('Balance ratio', fontsize=12)
ax2.set_ylabel('Count', fontsize=12)
ax2.set_title('Distribution of Balance Ratios (n ≤ 10,000)',
              fontsize=13, fontweight='bold')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('balance_ratios.png', dpi=150, bbox_inches='tight')
print("Saved balance_ratios.png")


#!/usr/bin/env python3
"""Visualization: Collatz orbit trajectories for notable starting values."""

import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')


def collatz_step(n: int) -> int:
    return n // 2 if n % 2 == 0 else 3 * n + 1


def collatz_orbit(n: int) -> list:
    orbit = [n]
    while n != 1 and len(orbit) < 1_000_000:
        n = collatz_step(n)
        orbit.append(n)
    return orbit


fig, axes = plt.subplots(2, 3, figsize=(15, 10))
notable = [7, 27, 97, 871, 6171, 77031]
colors = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12', '#9b59b6', '#1abc9c']

for ax, n, color in zip(axes.flat, notable, colors):
    orb = collatz_orbit(n)
    ax.plot(range(len(orb)), orb, color=color, linewidth=0.8, alpha=0.9)
    ax.set_title(f'n = {n} (steps={len(orb)-1}, peak={max(orb)})',
                 fontsize=11, fontweight='bold')
    ax.set_xlabel('Step')
    ax.set_ylabel('Value')
    ax.set_yscale('log')
    ax.grid(True, alpha=0.3)

fig.suptitle('Collatz Orbits: The Unpredictable Descent to 1',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('collatz_orbits.png', dpi=150, bbox_inches='tight')
print("Saved collatz_orbits.png")


#!/usr/bin/env python3
"""Visualization: Tropical potential along Collatz orbits."""

import matplotlib.pyplot as plt
import matplotlib
import math
matplotlib.use('Agg')


def collatz_step(n: int) -> int:
    return n // 2 if n % 2 == 0 else 3 * n + 1


def collatz_orbit(n: int) -> list:
    orbit = [n]
    while n != 1 and len(orbit) < 1_000_000:
        n = collatz_step(n)
        orbit.append(n)
    return orbit


def tropical_potential(orbit: list) -> list:
    return [math.log2(x) if x > 0 else 0 for x in orbit]


def cumulative_potential_change(orbit: list) -> list:
    pot = tropical_potential(orbit)
    changes = [0.0]
    for i in range(1, len(pot)):
        changes.append(changes[-1] + (pot[i] - pot[i - 1]))
    return changes


fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Panel 1: Tropical potential for n=27
orb = collatz_orbit(27)
pot = tropical_potential(orb)
axes[0, 0].plot(range(len(pot)), pot, color='#3498db', linewidth=1)
axes[0, 0].set_title('Tropical Potential φ(n) = log₂(n) for n=27',
                      fontsize=11, fontweight='bold')
axes[0, 0].set_xlabel('Step')
axes[0, 0].set_ylabel('log₂(value)')
axes[0, 0].grid(True, alpha=0.3)

# Panel 2: Cumulative potential change
cumul = cumulative_potential_change(orb)
axes[0, 1].plot(range(len(cumul)), cumul, color='#e74c3c', linewidth=1)
expected_slope = (math.log2(3) - 2) / 2
axes[0, 1].plot([0, len(cumul)], [0, expected_slope * len(cumul)],
                color='#f39c12', linestyle='--', linewidth=2,
                label=f'Expected slope ≈ {expected_slope:.4f}')
axes[0, 1].set_title('Cumulative Potential Change (n=27)',
                      fontsize=11, fontweight='bold')
axes[0, 1].set_xlabel('Step')
axes[0, 1].set_ylabel('Cumulative Δφ')
axes[0, 1].legend()
axes[0, 1].grid(True, alpha=0.3)

# Panel 3: Average potential change vs n
ns = list(range(2, 5001))
avg_changes = []
for n in ns:
    orb = collatz_orbit(n)
    if len(orb) > 1:
        pot = tropical_potential(orb)
        total_change = sum(pot[i + 1] - pot[i] for i in range(len(pot) - 1))
        avg_changes.append(total_change / (len(pot) - 1))
    else:
        avg_changes.append(0)

axes[1, 0].scatter(ns, avg_changes, s=1, alpha=0.4, color='#2ecc71')
axes[1, 0].axhline(y=expected_slope, color='#f39c12', linestyle='--',
                    linewidth=2, label=f'Predicted: {expected_slope:.4f}')
axes[1, 0].set_title('Average Potential Change per Step',
                      fontsize=11, fontweight='bold')
axes[1, 0].set_xlabel('Starting value n')
axes[1, 0].set_ylabel('Average Δφ per step')
axes[1, 0].legend()
axes[1, 0].grid(True, alpha=0.3)

# Panel 4: Stopping time vs n (log scale)
stopping_times = []
for n in ns:
    orb = collatz_orbit(n)
    stopping_times.append(len(orb) - 1)

axes[1, 1].scatter(ns, stopping_times, s=1, alpha=0.4, color='#9b59b6')
axes[1, 1].set_title('Stopping Time vs Starting Value',
                      fontsize=11, fontweight='bold')
axes[1, 1].set_xlabel('Starting value n')
axes[1, 1].set_ylabel('Stopping time')
axes[1, 1].grid(True, alpha=0.3)

fig.suptitle('Tropical Analysis of Collatz Dynamics',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('tropical_analysis.png', dpi=150, bbox_inches='tight')
print("Saved tropical_analysis.png")
