"""
Thermodynamic Jacobson Countermodel Compression — Concrete Demonstration

This script demonstrates the core mathematical ideas formalized in the Lean file
ThermodynamicJacobsonCountermodelCompression.lean with concrete numerical examples.

We illustrate:
1. A finite "prime spectrum" with evaluation functions
2. The thermodynamic gap computation
3. Canonical countermodel extraction via argmax
4. Visualization of the compression theorem
"""

import numpy as np
import matplotlib.pyplot as plt
from dataclasses import dataclass
from typing import Callable, List, Tuple, Optional


# ──────────────────────────────────────────────────────────────────────────────
# 1. Core Data Structures
# ──────────────────────────────────────────────────────────────────────────────

@dataclass
class PrimePoint:
    """A prime point in the spectrum, identified by index and name."""
    index: int
    name: str


@dataclass
class ThermoWitness:
    """A thermodynamic witness: a prime point with non-negative temperature."""
    prime: PrimePoint
    temperature: float

    def __post_init__(self):
        assert self.temperature >= 0, "Temperature must be non-negative"


def thermo_gap(eval_fn, witness: ThermoWitness, x: int, y: int) -> float:
    """
    Compute the thermodynamic gap:
        thermoGap(w, x, y) = w.temperature * (eval(w.prime, y) - eval(w.prime, x))
    """
    return witness.temperature * (eval_fn(witness.prime, y) - eval_fn(witness.prime, x))


def raw_gap(eval_fn, prime: PrimePoint, x: int, y: int) -> float:
    """Raw evaluation gap: eval(p, y) - eval(p, x)."""
    return eval_fn(prime, y) - eval_fn(prime, x)


# ──────────────────────────────────────────────────────────────────────────────
# 2. Example: A Semiring with 5 Prime Points
# ──────────────────────────────────────────────────────────────────────────────

# Create a finite prime spectrum
primes = [PrimePoint(i, f"p{i}") for i in range(5)]

# Evaluation function: eval(p, x) is a "valuation" of element x at prime p
# We use a random but fixed evaluation matrix for reproducibility
np.random.seed(42)
NUM_ELEMENTS = 8
eval_matrix = np.random.randn(len(primes), NUM_ELEMENTS)


def eval_fn(p: PrimePoint, x: int) -> float:
    """Evaluation of element x at prime point p."""
    return eval_matrix[p.index, x]


# ──────────────────────────────────────────────────────────────────────────────
# 3. Canonical Countermodel Extraction
# ──────────────────────────────────────────────────────────────────────────────

def canonical_countermodel(eval_fn, primes: List[PrimePoint],
                           x: int, y: int) -> PrimePoint:
    """
    Extract the canonical countermodel: the prime maximizing eval(p,y) - eval(p,x).
    This is the argmax over the finite spectrum.
    """
    best_prime = primes[0]
    best_gap = raw_gap(eval_fn, primes[0], x, y)
    for p in primes[1:]:
        g = raw_gap(eval_fn, p, x, y)
        if g > best_gap:
            best_gap = g
            best_prime = p
    return best_prime


def is_derivable(eval_fn, primes: List[PrimePoint],
                 x: int, y: int) -> bool:
    """
    Stone completeness: x derives y iff no prime has positive gap.
    Derivable(x,y) ↔ ∀ p, eval(p,y) - eval(p,x) ≤ 0
    """
    return all(raw_gap(eval_fn, p, x, y) <= 1e-12 for p in primes)


# ──────────────────────────────────────────────────────────────────────────────
# 4. Demonstration
# ──────────────────────────────────────────────────────────────────────────────

print("=" * 70)
print("THERMODYNAMIC JACOBSON COUNTERMODEL COMPRESSION — DEMO")
print("=" * 70)
print()

# Show the evaluation matrix
print("Evaluation matrix (rows = primes, cols = elements):")
print(np.round(eval_matrix, 3))
print()

# Test all pairs and show compression results
print("-" * 70)
print("Testing all element pairs for derivability and countermodels:")
print("-" * 70)

derivable_pairs = []
non_derivable_pairs = []

for x in range(NUM_ELEMENTS):
    for y in range(NUM_ELEMENTS):
        if x == y:
            continue
        if is_derivable(eval_fn, primes, x, y):
            derivable_pairs.append((x, y))
        else:
            cc = canonical_countermodel(eval_fn, primes, x, y)
            gap = raw_gap(eval_fn, cc, x, y)

            # Verify compression theorem: all gaps ≤ canonical gap
            all_gaps = [raw_gap(eval_fn, p, x, y) for p in primes]
            assert all(g <= gap + 1e-12 for g in all_gaps), "Compression violated!"

            non_derivable_pairs.append((x, y, cc, gap, all_gaps))

print(f"\nDerivable pairs: {len(derivable_pairs)}")
print(f"Non-derivable pairs: {len(non_derivable_pairs)}")
print()

# Show a few non-derivable examples
print("Sample non-derivable pairs with canonical countermodels:")
print(f"{'x':>3} {'y':>3} | {'Canonical Prime':>15} | {'Max Gap':>8} | {'All Gaps'}")
print("-" * 70)
for x, y, cc, gap, all_gaps in non_derivable_pairs[:10]:
    gaps_str = ", ".join(f"{g:.3f}" for g in all_gaps)
    print(f"{x:>3} {y:>3} | {cc.name:>15} | {gap:>8.3f} | [{gaps_str}]")

# ──────────────────────────────────────────────────────────────────────────────
# 5. Visualization: Gap Landscape
# ──────────────────────────────────────────────────────────────────────────────

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Pick 4 interesting non-derivable pairs
examples = non_derivable_pairs[:4]

for idx, (x, y, cc, max_gap, all_gaps) in enumerate(examples):
    ax = axes[idx // 2][idx % 2]

    prime_names = [p.name for p in primes]
    colors = ['#e74c3c' if p.index == cc.index else '#3498db' for p in primes]

    bars = ax.bar(prime_names, all_gaps, color=colors, edgecolor='black', linewidth=0.5)
    ax.axhline(y=0, color='black', linewidth=0.5, linestyle='-')
    ax.axhline(y=max_gap, color='#e74c3c', linewidth=1, linestyle='--', alpha=0.7,
               label=f'Max gap = {max_gap:.3f}')

    ax.set_title(f'Gap landscape: x={x}, y={y}\n'
                 f'Canonical countermodel: {cc.name}',
                 fontsize=11, fontweight='bold')
    ax.set_ylabel('eval(p,y) − eval(p,x)', fontsize=10)
    ax.set_xlabel('Prime point', fontsize=10)
    ax.legend(fontsize=9)

    # Highlight positive gaps
    for bar, gap_val in zip(bars, all_gaps):
        if gap_val > 0:
            bar.set_edgecolor('#e74c3c')
            bar.set_linewidth(2)

plt.suptitle('Countermodel Compression: Canonical Prime Maximizes Gap',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('/workspace/request-project/Bridges/AutoResearch/gap_landscape.png',
            dpi=150, bbox_inches='tight')
plt.close()
print("\n✓ Gap landscape visualization saved to gap_landscape.png")

# ──────────────────────────────────────────────────────────────────────────────
# 6. Visualization: Temperature Irrelevance
# ──────────────────────────────────────────────────────────────────────────────

fig, axes = plt.subplots(1, 2, figsize=(14, 5))

# Pick one non-derivable pair
x, y, cc, max_gap, all_gaps = non_derivable_pairs[0]
temperatures = np.linspace(0, 3, 100)

# Left: thermoGap vs temperature for each prime
ax = axes[0]
for p in primes:
    gaps = [t * raw_gap(eval_fn, p, x, y) for t in temperatures]
    style = '-' if p.index == cc.index else '--'
    width = 2.5 if p.index == cc.index else 1
    ax.plot(temperatures, gaps, style, linewidth=width,
            label=f'{p.name} (gap={raw_gap(eval_fn, p, x, y):.3f})')

ax.axhline(y=0, color='black', linewidth=0.5)
ax.set_xlabel('Temperature T', fontsize=11)
ax.set_ylabel('thermoGap = T · (eval(p,y) − eval(p,x))', fontsize=11)
ax.set_title(f'Thermodynamic Gap vs Temperature (x={x}, y={y})',
             fontsize=12, fontweight='bold')
ax.legend(fontsize=9)

# Right: Sign of gap is independent of temperature (for T > 0)
ax = axes[1]
for p in primes:
    rg = raw_gap(eval_fn, p, x, y)
    signs = [1 if t * rg > 0 else (0 if abs(t * rg) < 1e-12 else -1)
             for t in temperatures[1:]]  # skip T=0
    ax.plot(temperatures[1:], signs, '-', linewidth=1.5,
            label=f'{p.name}', alpha=0.8)

ax.set_xlabel('Temperature T > 0', fontsize=11)
ax.set_ylabel('sign(thermoGap)', fontsize=11)
ax.set_title('Temperature Irrelevance: Sign Independent of T > 0',
             fontsize=12, fontweight='bold')
ax.set_yticks([-1, 0, 1])
ax.set_yticklabels(['negative', 'zero', 'positive'])
ax.legend(fontsize=9)

plt.tight_layout()
plt.savefig('/workspace/request-project/Bridges/AutoResearch/temperature_irrelevance.png',
            dpi=150, bbox_inches='tight')
plt.close()
print("✓ Temperature irrelevance visualization saved to temperature_irrelevance.png")

# ──────────────────────────────────────────────────────────────────────────────
# 7. Visualization: Compression Theorem in Action
# ──────────────────────────────────────────────────────────────────────────────

fig, ax = plt.subplots(figsize=(12, 6))

# For each non-derivable pair, plot the max gap and show it's positive
max_gaps = []
pair_labels = []
for x, y, cc, gap, _ in non_derivable_pairs[:20]:
    max_gaps.append(gap)
    pair_labels.append(f'({x},{y})')

colors = ['#2ecc71' if g > 0 else '#e74c3c' for g in max_gaps]
ax.bar(range(len(max_gaps)), max_gaps, color=colors, edgecolor='black', linewidth=0.5)
ax.axhline(y=0, color='black', linewidth=1)
ax.set_xticks(range(len(max_gaps)))
ax.set_xticklabels(pair_labels, rotation=45, fontsize=8)
ax.set_xlabel('Element pair (x, y)', fontsize=11)
ax.set_ylabel('Canonical countermodel gap', fontsize=11)
ax.set_title('Compression Theorem: Every Non-Derivable Pair Has Positive Canonical Gap',
             fontsize=13, fontweight='bold')
ax.annotate('All bars are positive ↔ non-derivability',
            xy=(len(max_gaps) // 2, max(max_gaps) * 0.9),
            fontsize=11, ha='center',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='#f0f0f0'))

plt.tight_layout()
plt.savefig('/workspace/request-project/Bridges/AutoResearch/compression_theorem.png',
            dpi=150, bbox_inches='tight')
plt.close()
print("✓ Compression theorem visualization saved to compression_theorem.png")

# ──────────────────────────────────────────────────────────────────────────────
# 8. Heatmap: Full Derivability Matrix
# ──────────────────────────────────────────────────────────────────────────────

fig, axes = plt.subplots(1, 2, figsize=(14, 5.5))

# Left: Derivability matrix
deriv_matrix = np.zeros((NUM_ELEMENTS, NUM_ELEMENTS))
gap_matrix = np.zeros((NUM_ELEMENTS, NUM_ELEMENTS))
for x in range(NUM_ELEMENTS):
    for y in range(NUM_ELEMENTS):
        deriv_matrix[x, y] = 1 if is_derivable(eval_fn, primes, x, y) else 0
        cc = canonical_countermodel(eval_fn, primes, x, y)
        gap_matrix[x, y] = raw_gap(eval_fn, cc, x, y)

ax = axes[0]
im = ax.imshow(deriv_matrix, cmap='RdYlGn', aspect='equal', vmin=0, vmax=1)
ax.set_title('Derivability Matrix\n(green = derivable, red = not)', fontsize=12, fontweight='bold')
ax.set_xlabel('y (target)', fontsize=11)
ax.set_ylabel('x (source)', fontsize=11)
ax.set_xticks(range(NUM_ELEMENTS))
ax.set_yticks(range(NUM_ELEMENTS))
plt.colorbar(im, ax=ax, shrink=0.8)

# Right: Canonical gap matrix
ax = axes[1]
im = ax.imshow(gap_matrix, cmap='coolwarm', aspect='equal')
ax.set_title('Canonical Countermodel Gap\n(blue = derivable, red = non-derivable)',
             fontsize=12, fontweight='bold')
ax.set_xlabel('y (target)', fontsize=11)
ax.set_ylabel('x (source)', fontsize=11)
ax.set_xticks(range(NUM_ELEMENTS))
ax.set_yticks(range(NUM_ELEMENTS))
plt.colorbar(im, ax=ax, shrink=0.8)

plt.tight_layout()
plt.savefig('/workspace/request-project/Bridges/AutoResearch/derivability_heatmap.png',
            dpi=150, bbox_inches='tight')
plt.close()
print("✓ Derivability heatmap saved to derivability_heatmap.png")

print()
print("=" * 70)
print("SUMMARY OF COMPRESSION THEOREM VERIFICATION")
print("=" * 70)
print()
print(f"Spectrum size: {len(primes)} primes")
print(f"Element count: {NUM_ELEMENTS}")
print(f"Total pairs tested: {NUM_ELEMENTS * (NUM_ELEMENTS - 1)}")
print(f"Derivable pairs: {len(derivable_pairs)}")
print(f"Non-derivable pairs: {len(non_derivable_pairs)}")
print()
print("For EVERY non-derivable pair (x,y):")
print("  ✓ The canonical countermodel has strictly positive gap")
print("  ✓ The canonical gap is maximal among all primes")
print("  ✓ Temperature scaling preserves the sign of separation")
print()
print("This confirms the Finite Spectrum Countermodel Compression Theorem:")
print("  ¬Derivable(x,y) ↔ 0 < gap(canonicalCountermodel(x,y))")
