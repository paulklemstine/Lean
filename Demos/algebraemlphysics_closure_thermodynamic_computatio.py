#!/usr/bin/env python3
"""Build PACKAGE.json from all deliverables."""

import json
import os

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

# Read all components
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
lean_proofs = read_file('Catalog/Bridges/AlgebraEMLPhysics/ClosureThermodynamicComputationDuality.lean')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')

# Load visualizations
with open('viz_data.json', 'r') as f:
    vizs = json.load(f)

package = {
    "title": "Closure-Thermodynamic Computation Duality via Idempotent Dissipation Semimodules",
    "domain": "Bridges (Algebra × EML × Physics)",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Thermodynamic Computation Duality Demonstrations",
            "code": demo_code
        }
    ],
    "algorithms": [
        {
            "name": "Canonical Realization Construction",
            "pseudocode": """INPUT:  n generators, m profile vectors D[0..m-1] ∈ ℕⁿ (all distinct)
OUTPUT: ThermoComp T on Fin(m) realizing D

CONSTRUCT:
  States: S = {0, 1, ..., m-1}
  Closure: cl(A) = {x ∈ S | x ≤ max(A)} for A ≠ ∅; cl(∅) = {0}
  Energy: energy(A) = |A|
  Dissipation: dissip(i, A) = D[max(A)][i] for A ≠ ∅; dissip(i, ∅) = D[0][i]

VERIFY:
  Closed sets = {[0..k] | k = 0, ..., m-1}  (m closed sets)
  Profile([0..k]) = D[k] for all k
  Separation: D injective → profiles injective

Time: O(m·n)  Space: O(m·n)""",
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {
            "name": "Profile Injectivity: The Thermodynamic Nerode Property",
            "data": vizs["profile_injectivity"]
        },
        {
            "name": "Chain Closure and Energy Monotonicity",
            "data": vizs["chain_closure"]
        },
        {
            "name": "Reversible/Irreversible Generator Decomposition",
            "data": vizs["reversible_split"]
        },
        {
            "name": "Thermodynamic Realization Duality Diagram",
            "data": vizs["duality_diagram"]
        }
    ],
    "lean_proofs": lean_proofs
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2)

print(f"PACKAGE.json written: {os.path.getsize('PACKAGE.json')} bytes")


#!/usr/bin/env python3
"""
Closure-Thermodynamic Computation Duality: Demonstrations

This script demonstrates the key concepts from the formalized theory:
1. Closure operators and closed sets
2. Dissipation profiles and separation
3. Canonical realization construction
4. Reversible/irreversible decomposition
5. Minimal realization verification
"""

import itertools
from typing import Callable

# =============================================================================
# Core Data Structures
# =============================================================================

class ClosureOp:
    """A closure operator on subsets of a finite set."""

    def __init__(self, n: int, cl_fn: Callable[[frozenset], frozenset]):
        self.n = n
        self.elements = set(range(n))
        self.cl = cl_fn
        self._verify()

    def _verify(self):
        """Verify closure axioms on all subsets."""
        for s in self._all_subsets():
            fs = frozenset(s)
            cl_s = self.cl(fs)
            # Extensive
            assert fs <= cl_s, f"Not extensive: {fs} ⊄ {cl_s}"
            # Idempotent
            assert self.cl(cl_s) == cl_s, f"Not idempotent: cl(cl({fs})) ≠ cl({fs})"
        # Monotone (check a sample)
        for s1 in self._all_subsets():
            for s2 in self._all_subsets():
                fs1, fs2 = frozenset(s1), frozenset(s2)
                if fs1 <= fs2:
                    assert self.cl(fs1) <= self.cl(fs2), \
                        f"Not monotone: {fs1} ⊆ {fs2} but cl({fs1}) ⊄ cl({fs2})"

    def _all_subsets(self):
        for r in range(self.n + 1):
            for s in itertools.combinations(range(self.n), r):
                yield set(s)

    def closed_sets(self) -> list[frozenset]:
        """Return all closed sets (fixpoints of cl)."""
        result = []
        for s in self._all_subsets():
            fs = frozenset(s)
            if self.cl(fs) == fs:
                result.append(fs)
        return sorted(result, key=lambda x: (len(x), sorted(x)))


class ThermoComp:
    """A finite thermodynamic computation object."""

    def __init__(self, n_states: int, n_gens: int,
                 cl_fn: Callable[[frozenset], frozenset],
                 energy_fn: Callable[[frozenset], int],
                 dissip_fn: Callable[[int, frozenset], int]):
        self.n_states = n_states
        self.n_gens = n_gens
        self.closure = ClosureOp(n_states, cl_fn)
        self.energy = energy_fn
        self.dissip = dissip_fn

    def profile(self, A: frozenset) -> tuple:
        """Compute the dissipation profile of a set."""
        cl_A = self.closure.cl(A)
        return tuple(self.dissip(i, cl_A) for i in range(self.n_gens))

    def closed_sets(self) -> list[frozenset]:
        return self.closure.closed_sets()

    def is_separated(self) -> bool:
        """Check if distinct closed sets have distinct profiles."""
        cs = self.closed_sets()
        profiles = [self.profile(s) for s in cs]
        return len(profiles) == len(set(profiles))

    def closed_profiles(self) -> dict[frozenset, tuple]:
        """Map each closed set to its profile."""
        return {s: self.profile(s) for s in self.closed_sets()}

    def reversible_generators(self) -> list[int]:
        """Return indices of reversible generators (zero dissipation everywhere)."""
        cs = self.closed_sets()
        result = []
        for i in range(self.n_gens):
            if all(self.dissip(i, s) == 0 for s in cs):
                result.append(i)
        return result

    def irreversible_generators(self) -> list[int]:
        """Return indices of irreversible generators."""
        cs = self.closed_sets()
        result = []
        for i in range(self.n_gens):
            if any(self.dissip(i, s) != 0 for s in cs):
                result.append(i)
        return result


# =============================================================================
# Canonical Realization Construction
# =============================================================================

def canonical_realization(profiles: list[tuple]) -> ThermoComp:
    """
    Construct the canonical ThermoComp realizing given profile data.
    Uses chain closure: cl(A) = [0..max(A)].

    Args:
        profiles: List of n-tuples, all distinct, representing dissipation profiles.

    Returns:
        A separated ThermoComp on Fin(m) realizing the given profiles.
    """
    m = len(profiles)
    n = len(profiles[0]) if profiles else 0

    assert len(set(profiles)) == m, "Profiles must be distinct"

    def cl(A: frozenset) -> frozenset:
        if not A:
            return frozenset({0})
        max_val = max(A)
        return frozenset(range(max_val + 1))

    def energy(A: frozenset) -> int:
        return len(A)

    def dissip(i: int, A: frozenset) -> int:
        if not A:
            return profiles[0][i]
        max_val = max(A)
        return profiles[max_val][i]

    return ThermoComp(m, n, cl, energy, dissip)


# =============================================================================
# Demonstrations
# =============================================================================

def demo_basic():
    """Demo 1: Basic closure operator and ThermoComp."""
    print("=" * 60)
    print("DEMO 1: Basic Two-State Thermodynamic System")
    print("=" * 60)

    # Identity closure on Fin(2) with indicator dissipation
    T = ThermoComp(
        n_states=2, n_gens=2,
        cl_fn=lambda A: A,  # identity closure
        energy_fn=lambda A: len(A),
        dissip_fn=lambda i, A: 1 if i in A else 0
    )

    print(f"\nState space: {{0, 1}}")
    print(f"Closure: identity (every set is closed)")
    print(f"Generators: 2 (membership indicators)")
    print(f"\nClosed sets and their profiles:")
    for s in T.closed_sets():
        label = str(set(s)) if s else '∅'
        print(f"  {label:>10} → profile = {T.profile(s)}")

    print(f"\nSeparated: {T.is_separated()}")
    print(f"Reversible generators: {T.reversible_generators()}")
    print(f"Irreversible generators: {T.irreversible_generators()}")


def demo_canonical():
    """Demo 2: Canonical realization construction."""
    print("\n" + "=" * 60)
    print("DEMO 2: Canonical Realization Construction")
    print("=" * 60)

    # 3 distinct profiles with 2 generators
    profiles = [(0, 1), (2, 0), (1, 3)]
    print(f"\nInput profiles: {profiles}")

    T = canonical_realization(profiles)

    print(f"\nConstructed ThermoComp:")
    print(f"  States: Fin({T.n_states}) = {{0, 1, 2}}")
    print(f"  Generators: {T.n_gens}")
    print(f"  Closure: chain closure cl(A) = [0..max(A)]")
    print(f"\n  Closed sets (intervals [0..k]):")
    for s in T.closed_sets():
        p = T.profile(s)
        print(f"    {sorted(s)} → profile = {p}")

    print(f"\n  Separated: {T.is_separated()}")

    # Verify profiles match input
    cs = T.closed_sets()
    for k, prof in enumerate(profiles):
        closed_k = frozenset(range(k + 1))
        assert T.profile(closed_k) == prof, \
            f"Profile mismatch at k={k}: expected {prof}, got {T.profile(closed_k)}"
    print("  ✓ All profiles match input data")


def demo_minimality():
    """Demo 3: Minimality theorem demonstration."""
    print("\n" + "=" * 60)
    print("DEMO 3: Minimal Realization Theorem")
    print("=" * 60)

    profiles = [(1, 0, 0), (0, 1, 0), (0, 0, 1)]
    T_min = canonical_realization(profiles)

    print(f"\nTarget profiles: {profiles}")
    print(f"Minimal realization: {len(T_min.closed_sets())} closed sets")

    # Non-minimal: identity closure on 4 states, mapping to same profiles
    T_big = ThermoComp(
        n_states=4, n_gens=3,
        cl_fn=lambda A: A,
        energy_fn=lambda A: len(A),
        dissip_fn=lambda i, A: (
            1 if (i == 0 and 0 in A) else
            1 if (i == 1 and 1 in A) else
            1 if (i == 2 and 2 in A) else
            0
        )
    )

    print(f"Non-minimal realization: {len(T_big.closed_sets())} closed sets")
    print(f"\n  Minimal closed sets: {len(T_min.closed_sets())}")
    print(f"  Non-minimal closed sets: {len(T_big.closed_sets())}")
    print(f"  Minimal ≤ Non-minimal: {len(T_min.closed_sets()) <= len(T_big.closed_sets())} ✓")


def demo_reversible_irreversible():
    """Demo 4: Reversible/irreversible decomposition."""
    print("\n" + "=" * 60)
    print("DEMO 4: Reversible/Irreversible Decomposition")
    print("=" * 60)

    # 3 generators: gen 0 is reversible (zero everywhere), gen 1,2 irreversible
    T = ThermoComp(
        n_states=3, n_gens=3,
        cl_fn=lambda A: A,  # identity closure
        energy_fn=lambda A: len(A),
        dissip_fn=lambda i, A: (
            0 if i == 0 else  # Generator 0: reversible (zero cost)
            len(A) if i == 1 else  # Generator 1: cost = set size
            (1 if 2 in A else 0)  # Generator 2: detects element 2
        )
    )

    rev = T.reversible_generators()
    irrev = T.irreversible_generators()

    print(f"\n3-state system with 3 generators:")
    print(f"  Generator 0: reversible (zero dissipation always)")
    print(f"  Generator 1: irreversible (cost = set cardinality)")
    print(f"  Generator 2: irreversible (detects element 2)")
    print(f"\n  Reversible generators: {rev}")
    print(f"  Irreversible generators: {irrev}")
    print(f"  Union covers all: {sorted(rev + irrev) == list(range(3))} ✓")
    print(f"  Disjoint: {not set(rev) & set(irrev)} ✓")


def demo_energy_chain():
    """Demo 5: Energy chain bound."""
    print("\n" + "=" * 60)
    print("DEMO 5: Energy Chain Bound (Landauer Witness)")
    print("=" * 60)

    # Chain closure with strictly monotone energy
    profiles = [(0,), (1,), (2,), (3,)]
    T = canonical_realization(profiles)

    cs = T.closed_sets()
    print(f"\nChain of 4 closed sets with energies:")
    for s in cs:
        label = str(sorted(s))
        print(f"  {label:>15} → energy = {T.energy(s)}")

    if len(cs) >= 3:
        e1, e2, e3 = T.energy(cs[0]), T.energy(cs[1]), T.energy(cs[2])
        print(f"\n  energy(A₁) = {e1}, energy(A₂) = {e2}, energy(A₃) = {e3}")
        print(f"  energy(A₁) + 2 = {e1 + 2} ≤ energy(A₃) = {e3}: {e1 + 2 <= e3} ✓")


def demo_profile_equivalence():
    """Demo 6: Profile equivalence classes."""
    print("\n" + "=" * 60)
    print("DEMO 6: Profile Equivalence Classes")
    print("=" * 60)

    # Non-separated system: some closed sets have same profile
    T = ThermoComp(
        n_states=3, n_gens=1,
        cl_fn=lambda A: A,
        energy_fn=lambda A: len(A),
        dissip_fn=lambda i, A: len(A)  # Only depends on cardinality
    )

    print(f"\nNon-separated system (profile = cardinality):")
    print(f"  Separated: {T.is_separated()}")
    print(f"\n  Profile equivalence classes:")

    from collections import defaultdict
    classes = defaultdict(list)
    for s in T.closed_sets():
        classes[T.profile(s)].append(s)

    for prof, sets in sorted(classes.items()):
        sets_str = [str(set(s)) if s else "∅" for s in sets]
        print(f"    Profile {prof}: {', '.join(sets_str)}")

    print(f"\n  Number of equivalence classes: {len(classes)}")
    print(f"  Number of closed sets: {len(T.closed_sets())}")
    print(f"  Quotient would give minimal realization with {len(classes)} closed sets")


if __name__ == "__main__":
    demo_basic()
    demo_canonical()
    demo_minimality()
    demo_reversible_irreversible()
    demo_energy_chain()
    demo_profile_equivalence()
    print("\n" + "=" * 60)
    print("All demonstrations completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""Generate visualizations for the Closure-Thermodynamic Computation Duality."""

import base64
import io
import json

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def fig_to_base64(fig) -> str:
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    encoded = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{encoded}"


def viz_profile_injectivity():
    """Visualize profile injectivity on closed sets."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    # Left: Separated system
    closed_sets = ['∅', '{0}', '{1}', '{0,1}']
    profiles = [(0, 0), (1, 0), (0, 1), (1, 1)]

    ax1.set_title('Separated System\n(Injective Profile Map)', fontsize=13, fontweight='bold')
    for i, (cs, p) in enumerate(zip(closed_sets, profiles)):
        y = 3 - i
        ax1.annotate('', xy=(3.5, y), xytext=(1.5, y),
                     arrowprops=dict(arrowstyle='->', color='steelblue', lw=2))
        ax1.text(0.5, y, cs, ha='center', va='center', fontsize=12,
                bbox=dict(boxstyle='round,pad=0.3', facecolor='lightblue'))
        ax1.text(4.5, y, str(p), ha='center', va='center', fontsize=12,
                bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow'))

    ax1.text(0.5, 4.2, 'Closed Sets', ha='center', fontsize=11, fontweight='bold')
    ax1.text(4.5, 4.2, 'Profiles', ha='center', fontsize=11, fontweight='bold')
    ax1.set_xlim(-0.5, 5.5)
    ax1.set_ylim(-0.5, 5)
    ax1.axis('off')

    # Right: Non-separated system
    closed_sets_ns = ['∅', '{0}', '{1}', '{2}', '{0,1}', '{0,2}', '{1,2}', '{0,1,2}']
    profiles_ns = [(0,), (1,), (1,), (1,), (2,), (2,), (2,), (3,)]

    ax2.set_title('Non-Separated System\n(Non-Injective Profile Map)', fontsize=13, fontweight='bold')
    unique_profs = [(0,), (1,), (2,), (3,)]
    for i, p in enumerate(unique_profs):
        y = 3 - i
        matching = [cs for cs, pr in zip(closed_sets_ns, profiles_ns) if pr == p]
        label = ', '.join(matching)
        color = 'salmon' if len(matching) > 1 else 'lightblue'
        ax2.text(0.8, y, label, ha='center', va='center', fontsize=9,
                bbox=dict(boxstyle='round,pad=0.3', facecolor=color))
        ax2.annotate('', xy=(3.5, y), xytext=(2.2, y),
                     arrowprops=dict(arrowstyle='->', color='gray', lw=1.5))
        ax2.text(4.3, y, str(p), ha='center', va='center', fontsize=12,
                bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow'))

    ax2.text(0.8, 4.2, 'Closed Sets', ha='center', fontsize=11, fontweight='bold')
    ax2.text(4.3, 4.2, 'Profiles', ha='center', fontsize=11, fontweight='bold')
    ax2.set_xlim(-1, 5.5)
    ax2.set_ylim(-0.5, 5)
    ax2.axis('off')

    fig.suptitle('Profile Injectivity: The Thermodynamic Nerode Property', fontsize=14, fontweight='bold', y=1.02)
    return fig_to_base64(fig)


def viz_chain_closure():
    """Visualize the chain closure operator and energy monotonicity."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    # Left: Chain closure lattice
    ax1.set_title('Chain Closure: Closed Sets\nForm a Total Order', fontsize=13, fontweight='bold')
    levels = ['{0}', '{0,1}', '{0,1,2}', '{0,1,2,3}']
    for i, lbl in enumerate(levels):
        y = i * 1.5
        ax1.add_patch(mpatches.FancyBboxPatch(
            (1.5, y - 0.3), 3, 0.6, boxstyle='round,pad=0.1',
            facecolor=plt.cm.Blues(0.3 + 0.15 * i), edgecolor='navy', linewidth=2))
        ax1.text(3, y, lbl, ha='center', va='center', fontsize=12, fontweight='bold')
        if i > 0:
            ax1.annotate('', xy=(3, y - 0.3), xytext=(3, (i-1)*1.5 + 0.3),
                         arrowprops=dict(arrowstyle='->', color='navy', lw=2))
            ax1.text(5, (y + (i-1)*1.5)/2, '⊂', fontsize=16, ha='center', va='center')

    ax1.set_xlim(0, 6)
    ax1.set_ylim(-1, 5.5)
    ax1.axis('off')

    # Right: Energy monotonicity
    ax2.set_title('Energy Along Closure Chain\n(Strictly Monotone)', fontsize=13, fontweight='bold')
    k_vals = [1, 2, 3, 4]
    energies = [1, 2, 3, 4]
    ax2.bar(k_vals, energies, color=[plt.cm.Reds(0.3 + 0.15*i) for i in range(4)],
            edgecolor='darkred', linewidth=2)
    ax2.set_xlabel('Closed Set [0..k]', fontsize=12)
    ax2.set_ylabel('Energy', fontsize=12)
    ax2.set_xticks(k_vals)
    ax2.set_xticklabels(['{0}', '{0,1}', '{0,1,2}', '{0,1,2,3}'], fontsize=10)

    # Add the chain bound annotation
    ax2.annotate('', xy=(1, 1), xytext=(3, 3),
                 arrowprops=dict(arrowstyle='<->', color='green', lw=2))
    ax2.text(2.3, 2.3, 'gap ≥ 2', fontsize=11, color='green', fontweight='bold',
             bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

    fig.tight_layout()
    return fig_to_base64(fig)


def viz_reversible_split():
    """Visualize reversible/irreversible generator decomposition."""
    fig, ax = plt.subplots(figsize=(10, 4))

    ax.set_title('Generator Decomposition:\nReversible vs Irreversible', fontsize=14, fontweight='bold')

    # Draw generators as colored blocks
    n_gens = 6
    rev = [0, 3]  # reversible indices
    irrev = [1, 2, 4, 5]  # irreversible

    for i in range(n_gens):
        color = '#4CAF50' if i in rev else '#F44336'
        label = 'Rev' if i in rev else 'Irrev'
        ax.add_patch(mpatches.FancyBboxPatch(
            (i * 1.6, 0), 1.2, 1.5, boxstyle='round,pad=0.1',
            facecolor=color, edgecolor='black', linewidth=2, alpha=0.8))
        ax.text(i * 1.6 + 0.6, 0.75, f'Gen {i}\n{label}',
               ha='center', va='center', fontsize=10, fontweight='bold', color='white')
        cost_str = '0' if i in rev else '> 0'
        ax.text(i * 1.6 + 0.6, -0.3, f'cost = {cost_str}',
               ha='center', va='center', fontsize=9)

    # Legend
    rev_patch = mpatches.Patch(color='#4CAF50', label='Reversible (zero dissipation)')
    irrev_patch = mpatches.Patch(color='#F44336', label='Irreversible (positive witness)')
    ax.legend(handles=[rev_patch, irrev_patch], loc='upper right', fontsize=11)

    ax.set_xlim(-0.5, n_gens * 1.6)
    ax.set_ylim(-0.8, 2.5)
    ax.axis('off')

    return fig_to_base64(fig)


def viz_duality_diagram():
    """Visualize the overall duality structure."""
    fig, ax = plt.subplots(figsize=(10, 6))
    ax.set_title('Thermodynamic Realization Duality\n(Myhill–Nerode for Irreversible Physics)',
                 fontsize=14, fontweight='bold')

    # Three boxes
    boxes = [
        (0.5, 3, 'ThermoComp T₁\n(Separated)', 'lightblue'),
        (4, 3, 'Dissipation Data D\n(Profile Vectors)', 'lightyellow'),
        (7.5, 3, 'ThermoComp T₂\n(Separated)', 'lightgreen'),
    ]
    for x, y, label, color in boxes:
        ax.add_patch(mpatches.FancyBboxPatch(
            (x, y), 2.5, 1.5, boxstyle='round,pad=0.2',
            facecolor=color, edgecolor='black', linewidth=2))
        ax.text(x + 1.25, y + 0.75, label, ha='center', va='center',
               fontsize=11, fontweight='bold')

    # Arrows
    ax.annotate('', xy=(4, 3.75), xytext=(3, 3.75),
                arrowprops=dict(arrowstyle='->', color='navy', lw=2))
    ax.annotate('', xy=(7.5, 3.75), xytext=(6.5, 3.75),
                arrowprops=dict(arrowstyle='<-', color='navy', lw=2))
    ax.text(3.5, 4.1, 'realizes', ha='center', fontsize=10, style='italic')
    ax.text(7, 4.1, 'realizes', ha='center', fontsize=10, style='italic')

    # Bijection arrow below
    ax.annotate('', xy=(7.5, 2.5), xytext=(3, 2.5),
                arrowprops=dict(arrowstyle='<->', color='red', lw=2.5))
    ax.text(5.25, 2, '≅ profile-preserving bijection', ha='center', fontsize=11,
           fontweight='bold', color='red',
           bbox=dict(boxstyle='round', facecolor='mistyrose', alpha=0.8))

    # Key results below
    results = [
        '• |ClosedSets(T₁)| = |ClosedSets(T₂)| = D.numProfs',
        '• Minimal among all realizations',
        '• Unique up to profile-preserving bijection',
    ]
    for i, r in enumerate(results):
        ax.text(5.25, 1.2 - i * 0.5, r, ha='center', fontsize=10)

    ax.set_xlim(-0.5, 10.5)
    ax.set_ylim(-0.5, 5.5)
    ax.axis('off')

    return fig_to_base64(fig)


if __name__ == "__main__":
    vizs = {
        'profile_injectivity': viz_profile_injectivity(),
        'chain_closure': viz_chain_closure(),
        'reversible_split': viz_reversible_split(),
        'duality_diagram': viz_duality_diagram(),
    }

    print(f"Generated {len(vizs)} visualizations")
    for name, data in vizs.items():
        print(f"  {name}: {len(data)} chars")

    # Save for PACKAGE.json
    with open('/workspace/request-project/viz_data.json', 'w') as f:
        json.dump(vizs, f)
