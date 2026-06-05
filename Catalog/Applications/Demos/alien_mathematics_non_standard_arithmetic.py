#!/usr/bin/env python3
"""
Non-Standard Arithmetic: Demonstration of Ultrapower Constructions

Demonstrates the key concepts from the formalized theory:
1. Ultrafilter approximation on finite sets
2. Non-standard number arithmetic
3. Overspill principle illustration
4. Transfer of polynomial identities
"""

from typing import FrozenSet, Set, List, Optional
import random


# =============================================================================
# 1. Finite Ultrafilter Approximation
# =============================================================================

class FiniteUltrafilter:
    """
    Approximation of a free ultrafilter on {0, 1, ..., N-1}.

    For finite sets, a free ultrafilter doesn't exist (every ultrafilter on
    a finite set is principal). We simulate a "pseudo-free" filter by choosing
    a random "generic" element and declaring sets large if they contain it.
    This captures the ultrafilter dichotomy property.
    """

    def __init__(self, N: int, seed: int = 42):
        self.N = N
        self.universe = frozenset(range(N))
        # For finite approximation, use a random principal point
        # (In the limit N → ∞, this approximates freeness)
        rng = random.Random(seed)
        self.principal_point = rng.randint(0, N - 1)

    def is_large(self, S: FrozenSet[int]) -> bool:
        """Check if S is in the ultrafilter."""
        return self.principal_point in S

    def complement(self, S: FrozenSet[int]) -> FrozenSet[int]:
        return self.universe - S

    def demonstrate_dichotomy(self):
        """Show that every set or its complement is large."""
        print(f"\n=== Ultrafilter Dichotomy (N={self.N}) ===")
        for _ in range(5):
            S = frozenset(random.sample(range(self.N), self.N // 2))
            S_large = self.is_large(S)
            Sc_large = self.is_large(self.complement(S))
            print(f"  S={sorted(S)[:5]}..., |S|={len(S)}: "
                  f"S large={S_large}, Sᶜ large={Sc_large}, "
                  f"exactly one={S_large != Sc_large}")


# =============================================================================
# 2. Non-Standard Number Representation
# =============================================================================

class NonstandardNat:
    """
    Representation of a non-standard natural number as a finite
    truncation of a sequence.

    In the full theory, a non-standard number is an equivalence class
    [f] where f : I → ℕ. We represent it by its first N values.
    """

    def __init__(self, sequence: List[int], name: str = ""):
        self.sequence = list(sequence)
        self.name = name

    @staticmethod
    def standard(n: int, length: int = 20) -> 'NonstandardNat':
        """The standard embedding: constant sequence."""
        return NonstandardNat([n] * length, f"std({n})")

    @staticmethod
    def omega(length: int = 20) -> 'NonstandardNat':
        """The canonical infinite element: identity sequence."""
        return NonstandardNat(list(range(length)), "ω")

    def __add__(self, other: 'NonstandardNat') -> 'NonstandardNat':
        n = min(len(self.sequence), len(other.sequence))
        return NonstandardNat(
            [self.sequence[i] + other.sequence[i] for i in range(n)],
            f"({self.name}+{other.name})"
        )

    def __mul__(self, other: 'NonstandardNat') -> 'NonstandardNat':
        n = min(len(self.sequence), len(other.sequence))
        return NonstandardNat(
            [self.sequence[i] * other.sequence[i] for i in range(n)],
            f"({self.name}*{other.name})"
        )

    def le_on(self, other: 'NonstandardNat') -> Set[int]:
        """Return the set of indices where self ≤ other."""
        n = min(len(self.sequence), len(other.sequence))
        return {i for i in range(n) if self.sequence[i] <= other.sequence[i]}

    def eq_on(self, other: 'NonstandardNat') -> Set[int]:
        """Return the set of indices where self = other."""
        n = min(len(self.sequence), len(other.sequence))
        return {i for i in range(n) if self.sequence[i] == other.sequence[i]}

    def __repr__(self):
        prefix = self.sequence[:8]
        return f"{self.name} = [{', '.join(map(str, prefix))}, ...]"


# =============================================================================
# 3. Demonstrations
# =============================================================================

def demo_infinite_element():
    """Demonstrate that ω exceeds every standard element."""
    print("\n" + "=" * 60)
    print("THEOREM 1: ω exceeds every standard element")
    print("=" * 60)

    N = 20
    w = NonstandardNat.omega(N)
    print(f"\nω = {w}")

    for n in [3, 10, 15]:
        s = NonstandardNat.standard(n, N)
        agree = w.le_on(s)  # indices where ω ≤ std(n)
        cofinite = set(range(N)) - agree  # indices where ω > std(n)
        print(f"\n  std({n}) = {s}")
        print(f"  {{i | ω(i) > {n}}} = {sorted(cofinite)} (size {len(cofinite)}/{N})")
        print(f"  This set is cofinite → in any free ultrafilter")


def demo_transfer():
    """Demonstrate transfer of arithmetic identities."""
    print("\n" + "=" * 60)
    print("THEOREM 3: Transfer of Arithmetic Identities")
    print("=" * 60)

    N = 15
    f = NonstandardNat(list(range(1, N + 1)), "f")
    g = NonstandardNat([i * i for i in range(N)], "g")

    print(f"\n  f = {f}")
    print(f"  g = {g}")

    # Commutativity: f + g = g + f
    fg = f + g
    gf = g + f
    agree = fg.eq_on(gf)
    print(f"\n  f + g = {fg}")
    print(f"  g + f = {gf}")
    print(f"  Agree on {len(agree)}/{N} indices (all): commutativity transfers ✓")

    # Commutativity: f * g = g * f
    fg_mul = f * g
    gf_mul = g * f
    agree_mul = fg_mul.eq_on(gf_mul)
    print(f"\n  f * g = {fg_mul}")
    print(f"  g * f = {gf_mul}")
    print(f"  Agree on {len(agree_mul)}/{N} indices (all): mul commutativity transfers ✓")


def demo_overspill():
    """Demonstrate the overspill principle."""
    print("\n" + "=" * 60)
    print("THEOREM 2: Overspill Principle")
    print("=" * 60)

    N = 30
    print(f"\nProperty P(n) = 'n² > 100'")
    print(f"P holds for all n ≥ 11 (standard)")

    satisfying = {i for i in range(N) if i * i > 100}
    print(f"  {{i | P(i)}} = {sorted(satisfying)}")
    print(f"  This is a cofinite set (missing only {{0,...,10}})")
    print(f"  → In any free ultrafilter on ℕ")
    print(f"  → By overspill, P also holds for non-standard numbers")


def demo_composites_unbounded():
    """Demonstrate that composites are unbounded in the ultrapower."""
    print("\n" + "=" * 60)
    print("THEOREM 4: Composites are Unbounded")
    print("=" * 60)

    N = 20
    f = NonstandardNat.omega(N)
    print(f"\n  Given: f = {f}")

    # For each i, find a composite > f(i)
    def next_composite(n):
        return 4 * (n + 2)  # Always composite: 2 * 2*(n+2)

    g_seq = [next_composite(f.sequence[i]) for i in range(N)]
    g = NonstandardNat(g_seq, "g")
    print(f"  Witness: g(i) = 4*(f(i)+2) = {g}")

    exceeds = {i for i in range(N) if f.sequence[i] < g_seq[i]}
    composite = {i for i in range(N)
                 if g_seq[i] >= 4 and any(g_seq[i] % d == 0
                                          for d in range(2, g_seq[i])
                                          if d * d <= g_seq[i])}
    print(f"  {{i | f(i) < g(i)}} has size {len(exceeds)}/{N} (all indices)")
    print(f"  {{i | g(i) composite}} has size {len(composite)}/{N}")
    print(f"  Both are univ → both in U → [g] is a composite element > [f] ✓")


def demo_integral_domain():
    """Demonstrate integral domain transfer."""
    print("\n" + "=" * 60)
    print("THEOREM 5: Integral Domain Transfer")
    print("=" * 60)

    N = 15
    # Two sequences with f*g = 0 pointwise
    f = [0, 3, 0, 5, 0, 7, 0, 9, 0, 11, 0, 13, 0, 15, 0]
    g = [2, 0, 4, 0, 6, 0, 8, 0, 10, 0, 12, 0, 14, 0, 16]

    product = [f[i] * g[i] for i in range(N)]
    f_zero = {i for i in range(N) if f[i] == 0}
    g_zero = {i for i in range(N) if g[i] == 0}

    print(f"\n  f = {f}")
    print(f"  g = {g}")
    print(f"  f*g = {product} (all zeros)")
    print(f"  {{i | f(i)=0}} = {sorted(f_zero)} (size {len(f_zero)})")
    print(f"  {{i | g(i)=0}} = {sorted(g_zero)} (size {len(g_zero)})")
    print(f"  Union covers all indices → ultrafilter selects one")
    print(f"  → [f]=0 or [g]=0 in the ultraproduct ✓")


if __name__ == "__main__":
    print("=" * 60)
    print("NON-STANDARD ARITHMETIC: ULTRAPOWER DEMONSTRATIONS")
    print("=" * 60)

    demo_infinite_element()
    demo_transfer()
    demo_overspill()
    demo_composites_unbounded()
    demo_integral_domain()

    uf = FiniteUltrafilter(20)
    uf.demonstrate_dichotomy()

    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Non-Standard Arithmetic — The Ultrapower Number Line

Shows how the ultrapower ℕ*/U extends ℕ with infinite elements,
and visualizes the overspill principle.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def plot_ultrapower_number_line():
    """Visualize the extended number line ℕ ⊂ ℕ*."""
    fig, axes = plt.subplots(3, 1, figsize=(14, 10))

    # Panel 1: Standard vs Non-Standard Number Line
    ax = axes[0]
    ax.set_title("The Ultrapower Number Line: ℕ ⊂ ℕ*/U", fontsize=14, fontweight='bold')

    # Standard part
    for n in range(11):
        ax.plot(n, 0, 'bo', markersize=8)
        ax.annotate(str(n), (n, -0.15), ha='center', fontsize=9)

    ax.annotate('...', (11.5, 0), ha='center', fontsize=14)

    # Gap
    ax.axvspan(13, 15, alpha=0.1, color='gray')
    ax.annotate('gap', (14, 0.15), ha='center', fontsize=10, color='gray')

    # Non-standard elements
    for i, (x, label) in enumerate([(16, 'ω-1'), (17, 'ω'), (18, 'ω+1'),
                                     (19.5, '2ω'), (21, 'ω²')]):
        ax.plot(x, 0, 'r*', markersize=12)
        ax.annotate(label, (x, -0.15), ha='center', fontsize=9, color='red')

    ax.set_xlim(-0.5, 22)
    ax.set_ylim(-0.4, 0.4)
    ax.axhline(y=0, color='black', linewidth=0.5)
    ax.set_yticks([])

    blue_patch = mpatches.Patch(color='blue', label='Standard (finite)')
    red_patch = mpatches.Patch(color='red', label='Non-standard (infinite)')
    ax.legend(handles=[blue_patch, red_patch], loc='upper left')

    # Panel 2: ω exceeds every standard element
    ax = axes[1]
    ax.set_title("Theorem 1: ω = [id] exceeds every std(n)", fontsize=14, fontweight='bold')

    N = 30
    indices = np.arange(N)

    # Plot std(n) for various n
    for n in [5, 10, 15, 20]:
        ax.axhline(y=n, color='blue', alpha=0.3, linestyle='--')
        ax.annotate(f'std({n})', (0.5, n + 0.5), color='blue', fontsize=9)

    # Plot ω = id
    ax.plot(indices, indices, 'r-', linewidth=2, label='ω(i) = i')

    # Shade cofinite region for n=10
    n_val = 10
    exceed = indices >= n_val
    ax.fill_between(indices, 0, indices, where=exceed, alpha=0.15, color='green')
    ax.annotate(f'{{i | ω(i) ≥ {n_val}}} = cofinite → in U',
                (20, 5), fontsize=10, color='green',
                bbox=dict(boxstyle='round', facecolor='lightgreen', alpha=0.8))

    ax.set_xlabel('Index i')
    ax.set_ylabel('Value')
    ax.legend()

    # Panel 3: Overspill Principle
    ax = axes[2]
    ax.set_title("Theorem 2: Overspill — Properties Leak from Standard to Non-Standard",
                 fontsize=14, fontweight='bold')

    N = 40
    indices = np.arange(N)

    # Property: n² > 100
    values = indices ** 2
    threshold = 100
    satisfies = values > threshold

    ax.bar(indices[satisfies], values[satisfies], color='green', alpha=0.6, label='P(n) = "n² > 100" TRUE')
    ax.bar(indices[~satisfies], values[~satisfies], color='red', alpha=0.6, label='P(n) FALSE')
    ax.axhline(y=threshold, color='orange', linewidth=2, linestyle='--', label=f'Threshold = {threshold}')

    # Mark the boundary
    boundary = int(np.sqrt(threshold)) + 1
    ax.axvline(x=boundary - 0.5, color='purple', linewidth=2, linestyle=':')
    ax.annotate(f'n ≥ {boundary}: P always holds\n→ overspills to ℕ*',
                (boundary + 1, max(values) * 0.7), fontsize=10,
                bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

    ax.set_xlabel('n')
    ax.set_ylabel('n²')
    ax.set_ylim(0, max(values) * 1.1)
    ax.legend(loc='upper left')

    plt.tight_layout()
    plt.savefig('ultrapower_visualization.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: ultrapower_visualization.png")


def plot_transfer_and_domain():
    """Visualize transfer of identities and integral domain property."""
    fig, axes = plt.subplots(2, 1, figsize=(14, 8))

    # Panel 1: Transfer of (a+b)² = a² + 2ab + b²
    ax = axes[0]
    ax.set_title("Theorem 3: Transfer of Arithmetic Identities to ℕ*/U",
                 fontsize=14, fontweight='bold')

    N = 25
    indices = np.arange(N)
    a = indices + 1
    b = indices * 2 + 1

    lhs = (a + b) ** 2
    rhs = a ** 2 + 2 * a * b + b ** 2

    ax.plot(indices, lhs, 'bo-', markersize=4, label='(a+b)²', alpha=0.7)
    ax.plot(indices, rhs, 'r+', markersize=8, label='a² + 2ab + b²', alpha=0.7)

    agree = np.array([1 if lhs[i] == rhs[i] else 0 for i in range(N)])
    ax.annotate(f'Agreement: {sum(agree)}/{N} indices (all)\n'
                f'→ Identity transfers to ℕ*/U ✓',
                (N * 0.6, max(lhs) * 0.3), fontsize=11,
                bbox=dict(boxstyle='round', facecolor='lightblue', alpha=0.8))

    ax.set_xlabel('Index i')
    ax.set_ylabel('Value')
    ax.legend()

    # Panel 2: Integral Domain Transfer
    ax = axes[1]
    ax.set_title("Theorem 5: Integral Domain Transfer — Zero Product Property",
                 fontsize=14, fontweight='bold')

    N = 20
    indices = np.arange(N)

    # f(i) = 0 for even i, nonzero for odd
    f = np.array([0 if i % 2 == 0 else i * 3 + 1 for i in range(N)])
    g = np.array([i * 2 + 1 if i % 2 == 0 else 0 for i in range(N)])
    product = f * g

    width = 0.25
    ax.bar(indices - width, f, width, label='f(i)', color='blue', alpha=0.6)
    ax.bar(indices, g, width, label='g(i)', color='red', alpha=0.6)
    ax.bar(indices + width, product, width, label='f(i)·g(i)', color='green', alpha=0.6)

    f_zero = set(i for i in range(N) if f[i] == 0)
    g_zero = set(i for i in range(N) if g[i] == 0)

    ax.annotate(f'{{i|f(i)=0}} = {sorted(f_zero)}\n'
                f'{{i|g(i)=0}} = {sorted(g_zero)}\n'
                f'Union = all indices\n'
                f'Ultrafilter selects one → [f]=0 or [g]=0',
                (N * 0.55, max(max(f), max(g)) * 0.5), fontsize=10,
                bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

    ax.set_xlabel('Index i')
    ax.set_ylabel('Value')
    ax.legend()

    plt.tight_layout()
    plt.savefig('transfer_visualization.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: transfer_visualization.png")


if __name__ == "__main__":
    plot_ultrapower_number_line()
    plot_transfer_and_domain()
