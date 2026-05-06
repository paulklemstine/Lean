"""
Jacobson Adequacy for Closure-Generated Proof Semirings — Interactive Demo

This script demonstrates the core ideas of the Jacobson Adequacy theorem:

    derivable(x, y)  ↔  ∀ admissible evaluation e, e(x) → e(y)

We work with concrete finite bounded distributive lattices equipped with
closure operators, and show:
  1. How derivability is computed via the closure.
  2. How admissible evaluations (from prime ideals) validate derivable pairs.
  3. How non-derivability is witnessed by a separating prime ideal.
  4. Visualization of the evaluation spectrum.

Author: Harmonic / Aristotle
"""

import itertools
from typing import Callable
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


# ── 1. Finite Lattice Infrastructure ─────────────────────────────────────────

class FiniteLattice:
    """A finite bounded distributive lattice represented by its operations."""

    def __init__(self, elements, le, meet, join, bot, top, name="L"):
        self.elements = elements
        self.le = le
        self.meet = meet
        self.join = join
        self.bot = bot
        self.top = top
        self.name = name

    def __repr__(self):
        return f"FiniteLattice({self.name}, |{len(self.elements)}| elements)"


def powerset_lattice(n):
    """The lattice of subsets of {0,...,n-1}, ordered by inclusion."""
    base = list(range(n))
    elements = []
    for r in range(n + 1):
        for s in itertools.combinations(base, r):
            elements.append(frozenset(s))
    elements.sort(key=lambda s: (len(s), sorted(s)))
    return FiniteLattice(
        elements=elements,
        le=lambda a, b: a <= b,
        meet=lambda a, b: a & b,
        join=lambda a, b: a | b,
        bot=frozenset(),
        top=frozenset(base),
        name=f"P({set(base)})"
    )


def chain_lattice(n):
    """The chain lattice {0 < 1 < ... < n-1}."""
    elements = list(range(n))
    return FiniteLattice(
        elements=elements, le=lambda a, b: a <= b,
        meet=min, join=max, bot=0, top=n - 1,
        name=f"Chain({n})"
    )


# ── 2. Closure Operators ─────────────────────────────────────────────────────

def identity_closure(L):
    return lambda x: x

def top_closure(L):
    return lambda x: L.top

def threshold_closure(L, t):
    return lambda x: L.join(x, t)

def union_closure(n, mandatory):
    return lambda s: s | mandatory


# ── 3. Derivability ──────────────────────────────────────────────────────────

def is_derivable(L, cl, x, y):
    """Check derivable(x, y) ↔ cl(x) ≤ cl(y)."""
    return L.le(cl(x), cl(y))


# ── 4. Prime Ideals & Admissible Evaluations ─────────────────────────────────

def is_order_ideal(L, S):
    """Check if S is an order ideal (downward-closed)."""
    return all(
        all(b in S for b in L.elements if L.le(b, a))
        for a in S
    )

def is_prime_ideal(L, I):
    """Check if I is a prime ideal of L."""
    if not is_order_ideal(L, I):
        return False
    if I == set(L.elements):
        return False
    for a in L.elements:
        for b in L.elements:
            if L.meet(a, b) in I and a not in I and b not in I:
                return False
    return True

def find_all_prime_ideals(L):
    """Find all prime ideals of L by brute force."""
    primes = []
    for r in range(len(L.elements)):
        for subset in itertools.combinations(L.elements, r):
            S = set(subset)
            if is_prime_ideal(L, S):
                primes.append(S)
    return primes

def admissible_evaluation(L, cl, J):
    """Construct the admissible evaluation e(z) = (cl(z) ∉ J) from a prime ideal J."""
    return lambda z: cl(z) not in J


# ── 5. Adequacy Verification ─────────────────────────────────────────────────

def verify_adequacy(L, cl, verbose=True):
    """Verify the adequacy theorem on a concrete lattice with closure."""
    primes = find_all_prime_ideals(L)

    if verbose:
        print(f"\n{'='*60}")
        print(f"Verifying Adequacy for {L.name}")
        print(f"  Elements: {len(L.elements)}")
        print(f"  Prime ideals found: {len(primes)}")
        for i, J in enumerate(primes):
            print(f"    J_{i} = {set(J) if J else '∅'}")
        print(f"{'='*60}")

    all_ok = True
    derivable_count = 0
    non_derivable_examples = []

    for x in L.elements:
        for y in L.elements:
            d = is_derivable(L, cl, x, y)
            all_validate = True
            sep = None
            for J in primes:
                e = admissible_evaluation(L, cl, J)
                if e(x) and not e(y):
                    all_validate = False
                    sep = J
                    break

            if d != all_validate:
                if verbose:
                    print(f"  ✗ MISMATCH: x={x}, y={y}")
                all_ok = False
            elif d:
                derivable_count += 1
            else:
                non_derivable_examples.append((x, y, sep))

    if verbose:
        print(f"\n  Derivable pairs: {derivable_count}")
        print(f"  Non-derivable pairs: {len(non_derivable_examples)}")
        shown = non_derivable_examples[:15]
        for x, y, J in shown:
            print(f"    {x} ⊬ {y}  — separated by J = {set(J) if J else '∅'}")
        if len(non_derivable_examples) > 15:
            print(f"    ... and {len(non_derivable_examples) - 15} more")
        print(f"\n  {'✓ Adequacy verified!' if all_ok else '✗ ADEQUACY FAILED!'}")

    return all_ok


# ── 6. Visualization ─────────────────────────────────────────────────────────

def visualize_evaluation_spectrum(L, cl, figsize=(12, 6)):
    """Visualize the evaluation spectrum heatmap and derivability matrix."""
    primes = find_all_prime_ideals(L)
    n_p = len(primes)
    n_e = len(L.elements)
    if n_p == 0 or n_e == 0:
        return

    matrix = np.zeros((n_e, n_p), dtype=int)
    for i, x in enumerate(L.elements):
        for j, J in enumerate(primes):
            e = admissible_evaluation(L, cl, J)
            matrix[i, j] = 1 if e(x) else 0

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=figsize)

    ax1.imshow(matrix, cmap='YlGn', aspect='auto', interpolation='nearest')
    ax1.set_xlabel('Prime Ideal Index', fontsize=11)
    ax1.set_ylabel('Element', fontsize=11)
    ax1.set_title(f'Evaluation Spectrum of {L.name}', fontsize=13, fontweight='bold')
    ax1.set_xticks(range(n_p))
    ax1.set_xticklabels([f'J_{j}' for j in range(n_p)], fontsize=9)
    labels = [str(x) for x in L.elements]
    if n_e <= 16:
        ax1.set_yticks(range(n_e))
        ax1.set_yticklabels(labels, fontsize=8)
    for i in range(n_e):
        for j in range(n_p):
            ax1.text(j, i, str(matrix[i, j]), ha='center', va='center',
                     color='white' if matrix[i, j] else 'gray', fontsize=8)

    dm = np.zeros((n_e, n_e), dtype=int)
    for i, x in enumerate(L.elements):
        for j, y in enumerate(L.elements):
            dm[i, j] = 1 if is_derivable(L, cl, x, y) else 0

    ax2.imshow(dm, cmap='Blues', aspect='auto', interpolation='nearest')
    ax2.set_xlabel('y', fontsize=11)
    ax2.set_ylabel('x', fontsize=11)
    ax2.set_title('Derivability Matrix', fontsize=13, fontweight='bold')
    if n_e <= 10:
        ax2.set_xticks(range(n_e))
        ax2.set_xticklabels(labels, fontsize=8, rotation=45)
        ax2.set_yticks(range(n_e))
        ax2.set_yticklabels(labels, fontsize=8)

    plt.tight_layout()
    plt.savefig('demos/evaluation_spectrum.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("\n  → Saved demos/evaluation_spectrum.png")


def visualize_countermodel(L, cl, x, y, figsize=(8, 5)):
    """Visualize countermodel extraction for a non-derivable pair."""
    if is_derivable(L, cl, x, y):
        print(f"  {x} derives {y} — no countermodel needed.")
        return

    primes = find_all_prime_ideals(L)
    fig, ax = plt.subplots(figsize=figsize)

    bar_colors = []
    labels = []
    for j, J in enumerate(primes):
        e = admissible_evaluation(L, cl, J)
        ex, ey = e(x), e(y)
        if ex and not ey:
            bar_colors.append('#E53935')
            labels.append(f'J_{j}\ne(x)=T, e(y)=F\n✗ SEPARATES')
        elif ex and ey:
            bar_colors.append('#4CAF50')
            labels.append(f'J_{j}\ne(x)=T, e(y)=T\n✓')
        else:
            bar_colors.append('#90CAF9')
            labels.append(f'J_{j}\ne(x)=F\n✓ (vacuous)')

    ax.bar(range(len(primes)), [1]*len(primes), color=bar_colors,
           edgecolor='black', linewidth=0.5)
    ax.set_xticks(range(len(primes)))
    ax.set_xticklabels(labels, fontsize=8)
    ax.set_yticks([])
    ax.set_title(f'Countermodel Extraction: {x} ⊬ {y}\n'
                 f'cl({x}) = {cl(x)}, cl({y}) = {cl(y)}',
                 fontsize=12, fontweight='bold')

    legend = [
        mpatches.Patch(facecolor='#E53935', label='Separating (countermodel)'),
        mpatches.Patch(facecolor='#4CAF50', label='Validates e(x)→e(y)'),
        mpatches.Patch(facecolor='#90CAF9', label='Vacuously true'),
    ]
    ax.legend(handles=legend, loc='upper right', fontsize=9)
    plt.tight_layout()
    plt.savefig('demos/countermodel_extraction.png', dpi=150, bbox_inches='tight')
    plt.close()
    print(f"  → Saved demos/countermodel_extraction.png")


# ── 7. Main ──────────────────────────────────────────────────────────────────

def main():
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║  Jacobson Adequacy for Closure-Generated Proof Semirings    ║")
    print("║  Computational Demonstration                                ║")
    print("╚══════════════════════════════════════════════════════════════╝")

    # Demo 1: Chain with identity
    print("\n" + "─"*60)
    print("Demo 1: Chain(5) with identity closure")
    print("  cl(x) = x, so derivable(x,y) ↔ x ≤ y")
    L1 = chain_lattice(5)
    verify_adequacy(L1, identity_closure(L1))

    # Demo 2: Chain with threshold
    print("\n" + "─"*60)
    print("Demo 2: Chain(5) with threshold closure at t=2")
    print("  cl(x) = max(x, 2)")
    L2 = chain_lattice(5)
    cl2 = threshold_closure(L2, 2)
    verify_adequacy(L2, cl2)

    # Demo 3: Powerset with union closure
    print("\n" + "─"*60)
    print("Demo 3: P({0,1,2}) with closure cl(S) = S ∪ {0}")
    L3 = powerset_lattice(3)
    cl3 = union_closure(3, frozenset({0}))
    verify_adequacy(L3, cl3)

    # Demo 4: Top closure
    print("\n" + "─"*60)
    print("Demo 4: Chain(4) with top closure — everything derives everything")
    L4 = chain_lattice(4)
    verify_adequacy(L4, top_closure(L4))

    # Demo 5: Powerset(2)
    print("\n" + "─"*60)
    print("Demo 5: P({0,1}) with identity — full prime spectrum")
    L5 = powerset_lattice(2)
    verify_adequacy(L5, identity_closure(L5))

    # Visualizations
    print("\n" + "─"*60)
    print("Generating visualizations...")
    visualize_evaluation_spectrum(L2, cl2)

    for x in L2.elements:
        for y in L2.elements:
            if not is_derivable(L2, cl2, x, y):
                visualize_countermodel(L2, cl2, x, y)
                break
        else:
            continue
        break

    print("\n" + "═"*60)
    print("All demos complete. The Jacobson Adequacy theorem is verified")
    print("computationally on all examples above.")
    print("═"*60)


if __name__ == "__main__":
    main()
