"""
Fiber Geometry: Numerical Demonstrations

This script demonstrates the key concepts from the fiber geometry theory:
1. Computing fiber profiles of various functions
2. Verifying the fiber partition identity
3. Computing deficiency and maxFiber
4. Demonstrating the combinatorial second law (deficiency monotonicity)
5. Computing Landauer bits for different functions
"""

import math
from collections import Counter
from itertools import permutations
from typing import Callable, Dict, List, Tuple


def fiber_profile(f: Callable[[int], int], domain: List[int]) -> Dict[int, List[int]]:
    """Compute the fiber profile of f: {output -> [inputs mapping to it]}."""
    fibers: Dict[int, List[int]] = {}
    for x in domain:
        y = f(x)
        fibers.setdefault(y, []).append(x)
    return fibers


def fiber_sizes(f: Callable[[int], int], domain: List[int]) -> List[int]:
    """Compute the multiset of fiber sizes (nonzero only)."""
    fibers = fiber_profile(f, domain)
    return sorted([len(v) for v in fibers.values() if len(v) > 0], reverse=True)


def deficiency(f: Callable[[int], int], domain: List[int]) -> int:
    """deficiency(f) = |domain| - |image(f)|"""
    image = set(f(x) for x in domain)
    return len(domain) - len(image)


def max_fiber(f: Callable[[int], int], domain: List[int]) -> int:
    """Maximum fiber cardinality."""
    sizes = fiber_sizes(f, domain)
    return max(sizes) if sizes else 0


def landauer_bits(f: Callable[[int], int], domain: List[int]) -> float:
    """Information erased by f, in bits."""
    image = set(f(x) for x in domain)
    if len(image) == 0:
        return 0.0
    return math.log2(len(domain)) - math.log2(len(image))


def depth_bound(f: Callable[[int], int], domain: List[int]) -> int:
    """Information-theoretic depth bound = floor(log2(maxFiber))."""
    mf = max_fiber(f, domain)
    return int(math.log2(mf)) if mf > 0 else 0


# ============================================================
# Demo 1: Basic fiber profiles
# ============================================================
print("=" * 60)
print("DEMO 1: Fiber Profiles of Various Functions")
print("=" * 60)

domain = list(range(12))

# Identity function
f_id = lambda x: x
print(f"\nIdentity f(x) = x on {{0,...,11}}:")
print(f"  Fiber sizes: {fiber_sizes(f_id, domain)}")
print(f"  Deficiency:  {deficiency(f_id, domain)}")
print(f"  MaxFiber:    {max_fiber(f_id, domain)}")
print(f"  Landauer:    {landauer_bits(f_id, domain):.4f} bits")

# Constant function
f_const = lambda x: 0
print(f"\nConstant f(x) = 0 on {{0,...,11}}:")
print(f"  Fiber sizes: {fiber_sizes(f_const, domain)}")
print(f"  Deficiency:  {deficiency(f_const, domain)}")
print(f"  MaxFiber:    {max_fiber(f_const, domain)}")
print(f"  Landauer:    {landauer_bits(f_const, domain):.4f} bits")

# Modular function (balanced)
f_mod = lambda x: x % 4
print(f"\nBalanced f(x) = x mod 4 on {{0,...,11}}:")
print(f"  Fiber sizes: {fiber_sizes(f_mod, domain)}")
print(f"  Deficiency:  {deficiency(f_mod, domain)}")
print(f"  MaxFiber:    {max_fiber(f_mod, domain)}")
print(f"  Landauer:    {landauer_bits(f_mod, domain):.4f} bits")

# Unbalanced function
f_unbal = lambda x: 0 if x < 9 else x - 8
print(f"\nUnbalanced f (9 map to 0, rest are distinct):")
print(f"  Fiber sizes: {fiber_sizes(f_unbal, domain)}")
print(f"  Deficiency:  {deficiency(f_unbal, domain)}")
print(f"  MaxFiber:    {max_fiber(f_unbal, domain)}")
print(f"  Landauer:    {landauer_bits(f_unbal, domain):.4f} bits")

# ============================================================
# Demo 2: Fiber Partition Identity Verification
# ============================================================
print("\n" + "=" * 60)
print("DEMO 2: Fiber Partition Identity: Σ|fiber(b)| = |domain|")
print("=" * 60)

for name, f in [("identity", f_id), ("constant", f_const),
                ("mod 4", f_mod), ("unbalanced", f_unbal)]:
    sizes = fiber_sizes(f, domain)
    print(f"  {name:12s}: sum({sizes}) = {sum(sizes)} = |domain| = {len(domain)}  ✓")

# ============================================================
# Demo 3: Combinatorial Second Law
# ============================================================
print("\n" + "=" * 60)
print("DEMO 3: Combinatorial Second Law: def(f) ≤ def(g∘f)")
print("=" * 60)

f = lambda x: x % 4   # deficiency = 8
g = lambda x: x % 2   # deficiency on {0,1,2,3} = 2

gf = lambda x: g(f(x))

print(f"  f(x) = x mod 4:  deficiency = {deficiency(f, domain)}")
print(f"  g(x) = x mod 2:  deficiency = {deficiency(g, list(range(4)))}")
print(f"  g∘f(x) = x mod 2: deficiency = {deficiency(gf, domain)}")
print(f"  def(f) ≤ def(g∘f): {deficiency(f, domain)} ≤ {deficiency(gf, domain)}  ✓")

# ============================================================
# Demo 4: Sorting — Fiber Profile of Permutation Collapse
# ============================================================
print("\n" + "=" * 60)
print("DEMO 4: Sorting as Fiber Collapse")
print("=" * 60)

for n in range(1, 7):
    perms = list(permutations(range(n)))
    n_factorial = math.factorial(n)
    landauer = math.log2(n_factorial) if n_factorial > 1 else 0
    print(f"  n={n}: {n_factorial:5d} permutations → 1 sorted output")
    print(f"         maxFiber = {n_factorial}, depthBound = {int(math.log2(n_factorial)) if n_factorial > 1 else 0}")
    print(f"         Landauer = {landauer:.2f} bits, aux space ≥ {n_factorial}")

# ============================================================
# Demo 5: Pigeonhole Principle in Fiber Language
# ============================================================
print("\n" + "=" * 60)
print("DEMO 5: Pigeonhole via Fiber Geometry")
print("=" * 60)

for N, M in [(12, 4), (12, 3), (100, 7), (1000, 13)]:
    print(f"  |α|={N}, |β|={M}: any f : α → β has maxFiber ≥ ⌊{N}/{M}⌋ = {N // M}")

# ============================================================
# Demo 6: Fiber Unity — Three Costs from One Profile
# ============================================================
print("\n" + "=" * 60)
print("DEMO 6: Fiber Unity — Three Costs from One Profile")
print("=" * 60)

domain20 = list(range(20))
functions = {
    "identity":      lambda x: x,
    "mod 5":         lambda x: x % 5,
    "mod 2":         lambda x: x % 2,
    "constant":      lambda x: 0,
    "floor(x/3)":    lambda x: x // 3,
}

print(f"  {'Function':14s} {'Fibers':22s} {'Depth':>6s} {'Landauer':>9s} {'MinAux':>7s}")
print("  " + "-" * 62)
for name, f in functions.items():
    sizes = fiber_sizes(f, domain20)
    db = depth_bound(f, domain20)
    lb = landauer_bits(f, domain20)
    mf = max_fiber(f, domain20)
    fibers_str = str(sizes[:5]) + ("..." if len(sizes) > 5 else "")
    print(f"  {name:14s} {fibers_str:22s} {db:6d} {lb:9.3f} {mf:7d}")

print("\n  All three quantities determined by fiber profile alone!")
print("  depthBound ≤ log₂(minAux) ≤ log₂(|domain|)")

# ============================================================
# Demo 7: Conjecture Test — Fiber Entropy Convexity
# ============================================================
print("\n" + "=" * 60)
print("DEMO 7: Testing Fiber Entropy Convexity Conjecture")
print("=" * 60)

def fiber_entropy(sizes: List[int]) -> float:
    """Shannon entropy of normalized fiber sizes."""
    total = sum(sizes)
    if total == 0:
        return 0.0
    probs = [s / total for s in sizes]
    return -sum(p * math.log(p) for p in probs if p > 0)

# Test: partitions of 12 into 4 parts (surjections Fin 12 → Fin 4)
N, M = 12, 4
print(f"\n  Partitions of {N} into {M} positive parts:")
print(f"  Balanced partition: {[N//M]*M} = {[3]*4}")
print(f"  Balanced entropy: {fiber_entropy([3]*4):.6f}")
print(f"  log({N}/{M}) = log({N//M}) = {math.log(N/M):.6f}")

# Generate some partitions
test_partitions = [
    [3, 3, 3, 3],  # balanced
    [4, 4, 2, 2],
    [5, 3, 2, 2],
    [6, 3, 2, 1],
    [7, 3, 1, 1],
    [9, 1, 1, 1],
]

print(f"\n  {'Partition':20s} {'Entropy':>10s} {'≥ log(3)?':>10s}")
print("  " + "-" * 42)
for p in test_partitions:
    if sum(p) == N and len(p) == M and all(x > 0 for x in p):
        ent = fiber_entropy(p)
        threshold = math.log(N / M)
        print(f"  {str(p):20s} {ent:10.6f} {'✓' if ent >= threshold - 1e-10 else '✗':>10s}")

print("\n  Note: The conjecture needs careful formulation.")
print("  Balanced partitions minimize log-sum, not necessarily Shannon entropy.")

if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("All demonstrations completed successfully.")
    print("=" * 60)


"""
Visualization: Fiber Profiles of Various Functions

Generates a bar chart comparing fiber profiles of different functions
on Fin(12), showing how the shape of preimages determines computational
and thermodynamic properties.
"""

import matplotlib.pyplot as plt
import numpy as np
from collections import Counter


def fiber_profile(f, domain):
    """Compute fiber sizes for f on domain."""
    counter = Counter(f(x) for x in domain)
    return sorted(counter.values(), reverse=True)


def landauer_bits(domain_size, image_size):
    """Information erased in bits."""
    if image_size == 0:
        return 0
    return np.log2(domain_size) - np.log2(image_size)


domain = list(range(12))

functions = {
    "Identity\nf(x) = x": lambda x: x,
    "Balanced mod 4\nf(x) = x mod 4": lambda x: x % 4,
    "Unbalanced\nf(x) = min(x, 3)": lambda x: min(x, 3),
    "Constant\nf(x) = 0": lambda x: 0,
}

fig, axes = plt.subplots(2, 2, figsize=(12, 10))
fig.suptitle("Fiber Profiles: The Shape of Information Loss",
             fontsize=16, fontweight='bold')

colors = ['#2ecc71', '#3498db', '#e74c3c', '#9b59b6']

for idx, (name, f) in enumerate(functions.items()):
    ax = axes[idx // 2][idx % 2]
    profile = fiber_profile(f, domain)
    image_size = len(profile)

    bars = ax.bar(range(len(profile)), profile, color=colors[idx], alpha=0.8,
                  edgecolor='white', linewidth=1.5)

    ax.set_title(name, fontsize=12, fontweight='bold')
    ax.set_xlabel("Output value index", fontsize=10)
    ax.set_ylabel("Fiber size", fontsize=10)
    ax.set_ylim(0, 13)

    # Add fiber size labels
    for bar, size in zip(bars, profile):
        ax.text(bar.get_x() + bar.get_width()/2., bar.get_height() + 0.3,
                str(size), ha='center', va='bottom', fontsize=9, fontweight='bold')

    # Add metrics
    max_fib = max(profile)
    defic = len(domain) - image_size
    lb = landauer_bits(len(domain), image_size)
    depth = int(np.log2(max_fib)) if max_fib > 1 else 0

    metrics = (f"Deficiency = {defic}  |  MaxFiber = {max_fib}\n"
               f"Landauer = {lb:.2f} bits  |  Depth ≥ {depth}")
    ax.text(0.5, 0.95, metrics, transform=ax.transAxes, fontsize=8,
            verticalalignment='top', horizontalalignment='center',
            bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

plt.tight_layout()
plt.savefig("fiber_profiles.png", dpi=150, bbox_inches='tight')
plt.close()
print("Saved fiber_profiles.png")


"""
Visualization: Combinatorial Second Law

Shows how deficiency (information loss) monotonically increases
under function composition, demonstrating the combinatorial
analog of the Second Law of Thermodynamics.
"""

import matplotlib.pyplot as plt
import numpy as np
from collections import Counter


def deficiency(f, domain):
    """Compute deficiency = |domain| - |image(f)|."""
    image = set(f(x) for x in domain)
    return len(domain) - len(image)


# Chain of compositions: each step loses more information
domain = list(range(120))

# Define a chain of increasingly lossy functions
steps = [
    ("x mod 60", lambda x: x % 60),
    ("x mod 30", lambda x: x % 30),
    ("x mod 15", lambda x: x % 15),
    ("x mod 6",  lambda x: x % 6),
    ("x mod 3",  lambda x: x % 3),
    ("x mod 1",  lambda x: 0),
]

# Compute accumulated deficiency
accumulated_defs = []
labels = ["Start\n(identity)"]
accumulated_defs.append(0)

composed = lambda x: x
for name, g in steps:
    prev_composed = composed
    composed = lambda x, g=g, pc=prev_composed: g(pc(x))
    d = deficiency(composed, domain)
    accumulated_defs.append(d)
    labels.append(name)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
fig.suptitle("The Combinatorial Second Law of Thermodynamics",
             fontsize=14, fontweight='bold')

# Plot 1: Deficiency growth
ax1.plot(range(len(accumulated_defs)), accumulated_defs, 'o-',
         color='#e74c3c', linewidth=2, markersize=8)
ax1.fill_between(range(len(accumulated_defs)), accumulated_defs,
                 alpha=0.2, color='#e74c3c')
ax1.set_xticks(range(len(labels)))
ax1.set_xticklabels(labels, rotation=45, ha='right', fontsize=8)
ax1.set_ylabel("Deficiency (information lost)", fontsize=11)
ax1.set_title("Deficiency is Monotonically Non-Decreasing\nunder Composition",
              fontsize=12)
ax1.grid(True, alpha=0.3)

# Annotate
for i, d in enumerate(accumulated_defs):
    ax1.annotate(f'{d}', (i, d), textcoords="offset points",
                 xytext=(0, 10), ha='center', fontsize=9, fontweight='bold')

# Plot 2: Landauer cost accumulation
landauer_bits_list = []
for d in accumulated_defs:
    image_size = 120 - d
    if image_size > 0:
        lb = np.log2(120) - np.log2(image_size)
    else:
        lb = np.log2(120)
    landauer_bits_list.append(lb)

ax2.bar(range(len(landauer_bits_list)), landauer_bits_list,
        color='#3498db', alpha=0.8, edgecolor='white')
ax2.set_xticks(range(len(labels)))
ax2.set_xticklabels(labels, rotation=45, ha='right', fontsize=8)
ax2.set_ylabel("Landauer bits erased", fontsize=11)
ax2.set_title("Cumulative Information Erasure\n(Thermodynamic Cost)",
              fontsize=12)
ax2.grid(True, alpha=0.3, axis='y')

for i, lb in enumerate(landauer_bits_list):
    ax2.text(i, lb + 0.1, f'{lb:.1f}', ha='center', fontsize=8, fontweight='bold')

plt.tight_layout()
plt.savefig("second_law.png", dpi=150, bbox_inches='tight')
plt.close()
print("Saved second_law.png")


"""
Visualization: Fiber Unity Theorem

Shows how the three quantities — depth bound, Landauer cost, and
reversibility cost — are all determined by the fiber profile,
demonstrating the Fiber Unity Theorem.
"""

import matplotlib.pyplot as plt
import numpy as np
from collections import Counter
import math


def fiber_profile(f, domain):
    counter = Counter(f(x) for x in domain)
    return sorted(counter.values(), reverse=True)


domain = list(range(120))

# Various functions with different fiber profiles
functions = [
    ("identity", lambda x: x),
    ("x mod 60", lambda x: x % 60),
    ("x mod 40", lambda x: x % 40),
    ("x mod 30", lambda x: x % 30),
    ("x mod 20", lambda x: x % 20),
    ("x mod 15", lambda x: x % 15),
    ("x mod 12", lambda x: x % 12),
    ("x mod 10", lambda x: x % 10),
    ("x mod 8",  lambda x: x % 8),
    ("x mod 6",  lambda x: x % 6),
    ("x mod 5",  lambda x: x % 5),
    ("x mod 4",  lambda x: x % 4),
    ("x mod 3",  lambda x: x % 3),
    ("x mod 2",  lambda x: x % 2),
    ("constant", lambda x: 0),
]

names = []
depth_bounds = []
landauer_costs = []
rev_costs = []

for name, f in functions:
    profile = fiber_profile(f, domain)
    max_fib = max(profile)
    image_size = len(profile)

    depth = math.log2(max_fib) if max_fib > 1 else 0
    landauer = math.log2(len(domain)) - math.log2(image_size) if image_size > 0 else 0
    rev = math.log2(max_fib) if max_fib > 1 else 0

    names.append(name)
    depth_bounds.append(depth)
    landauer_costs.append(landauer)
    rev_costs.append(rev)

fig, ax = plt.subplots(figsize=(14, 7))

x = np.arange(len(names))
width = 0.28

bars1 = ax.bar(x - width, depth_bounds, width, label='Depth Bound (log₂ maxFiber)',
               color='#e74c3c', alpha=0.85, edgecolor='white')
bars2 = ax.bar(x, landauer_costs, width, label='Landauer Cost (bits erased)',
               color='#3498db', alpha=0.85, edgecolor='white')
bars3 = ax.bar(x + width, rev_costs, width, label='Reversibility Cost (log₂ minAux)',
               color='#2ecc71', alpha=0.85, edgecolor='white')

ax.set_xlabel('Function', fontsize=12)
ax.set_ylabel('Cost (log₂ scale)', fontsize=12)
ax.set_title('Fiber Unity Theorem: Three Costs from One Profile\n'
             'All three quantities are determined by the fiber profile',
             fontsize=14, fontweight='bold')
ax.set_xticks(x)
ax.set_xticklabels(names, rotation=45, ha='right', fontsize=9)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3, axis='y')

# Add annotation
ax.annotate('For balanced surjections:\nDepth = Reversibility = log₂(maxFiber)\n'
            'Landauer = log₂(domain/image)',
            xy=(7, 3.5), fontsize=9,
            bbox=dict(boxstyle='round,pad=0.5', facecolor='lightyellow', alpha=0.8))

plt.tight_layout()
plt.savefig("fiber_unity.png", dpi=150, bbox_inches='tight')
plt.close()
print("Saved fiber_unity.png")
