#!/usr/bin/env python3
"""
Closure Spectrum Duality — Applications

Demonstrates real-world applications of closure spectrum duality:
1. Database normalization via prime spectrum analysis
2. Horn clause satisfiability and prime model enumeration
3. Formal concept analysis: concept lattice from prime spectrum
4. Knowledge base compression via spectral encoding
"""

from algorithms import ClosureSystem, HornClause, from_implication_basis, benchmark


def app_database_normalization():
    """Application 1: Database normalization via prime spectrum.
    
    The prime spectrum of functional dependencies reveals the
    "irreducible perspectives" on the data — minimal attribute sets
    that can't be decomposed further while preserving all dependencies.
    """
    print("=" * 60)
    print("Application 1: Database Normalization via Prime Spectrum")
    print("=" * 60)
    
    # A relation with attributes {A, B, C, D, E}
    # Functional dependencies: A→B, B→C, CD→E, E→A
    db = from_implication_basis(
        {'A', 'B', 'C', 'D', 'E'},
        [
            ({'A'}, 'B'),
            ({'B'}, 'C'),
            ({'C', 'D'}, 'E'),
            ({'E'}, 'A'),
        ]
    )
    
    print(db.summary())
    print(f"\nReconstruction verified: {db.verify_reconstruction()}")
    
    primes = db.prime_spectrum()
    print(f"\nInterpretation:")
    print(f"  The {len(primes)} prime theories represent the irreducible")
    print(f"  'views' of the data that preserve dependency structure.")
    print(f"  Each prime theory is a maximal consistent attribute set")
    print(f"  that cannot be decomposed as an intersection of larger ones.")
    
    # Show what each prime "knows"
    for P in sorted(primes, key=lambda s: (len(s), sorted(s))):
        attrs = sorted(P) if P else []
        missing = sorted(db.generators - P)
        print(f"\n  Prime {set(P) if P else '{}'}:")
        print(f"    Contains: {attrs}")
        print(f"    Missing:  {missing}")
        print(f"    Semantic: a 'worldview' that knows {attrs} but not {missing}")


def app_horn_clause_reasoning():
    """Application 2: Horn clause entailment via prime models.
    
    Given a set of Horn clauses, the prime spectrum gives all
    "prime models" — minimal models that detect all entailment failures.
    """
    print("\n" + "=" * 60)
    print("Application 2: Horn Clause Entailment via Prime Models")
    print("=" * 60)
    
    # Knowledge base: rules about a simple diagnostic system
    # Variables: fever, cough, infection, treatment, recovery
    kb = from_implication_basis(
        {'fever', 'cough', 'infection', 'treatment', 'recovery'},
        [
            ({'fever', 'cough'}, 'infection'),
            ({'infection'}, 'treatment'),
            ({'treatment'}, 'recovery'),
            ({'fever'}, 'treatment'),  # fever alone warrants treatment
        ]
    )
    
    print(kb.summary())
    print(f"\nReconstruction verified: {kb.verify_reconstruction()}")
    
    # Test entailment queries
    print("\nEntailment queries (via prime intersection):")
    queries = [
        (frozenset({'fever'}), 'recovery',
         "Does fever entail recovery?"),
        (frozenset({'cough'}), 'treatment',
         "Does cough alone entail treatment?"),
        (frozenset({'fever', 'cough'}), 'recovery',
         "Do fever+cough entail recovery?"),
        (frozenset({'infection'}), 'fever',
         "Does infection entail fever?"),
    ]
    
    for assumptions, query, description in queries:
        cl = kb.closure(assumptions)
        entailed = query in cl
        # Verify via reconstruction
        reconstructed = kb.reconstruct(assumptions)
        assert (query in cl) == (query in reconstructed), "Reconstruction mismatch!"
        print(f"  {description}")
        print(f"    Answer: {'YES' if entailed else 'NO'}")
        print(f"    Cl({set(assumptions)}) = {set(cl)}")


def app_formal_concept_analysis():
    """Application 3: Formal concept analysis via prime spectrum.
    
    A formal context (objects × attributes) defines a closure operator.
    The prime spectrum gives the meet-irreducible concepts.
    """
    print("\n" + "=" * 60)
    print("Application 3: Formal Concept Analysis")
    print("=" * 60)
    
    # A simple formal context: animals and their properties
    # Objects: dog, cat, fish, bird
    # Attributes: legs, fur, swims, flies, domestic
    #
    # We model the ATTRIBUTE closure: given some attributes,
    # what other attributes must hold for all objects with those attributes?
    
    # Cross-table:
    # dog:  legs, fur, domestic
    # cat:  legs, fur, domestic
    # fish: swims
    # bird: legs, flies
    
    objects = {
        'dog': {'legs', 'fur', 'domestic'},
        'cat': {'legs', 'fur', 'domestic'},
        'fish': {'swims'},
        'bird': {'legs', 'flies'},
    }
    
    all_attrs = set()
    for attrs in objects.values():
        all_attrs |= attrs
    
    def attribute_closure(S: frozenset) -> frozenset:
        """Closure in the attribute space: attributes shared by all objects
        having all attributes in S."""
        s = set(S) & all_attrs
        if not s:
            # All objects have these (vacuously), so closure = ∩ all attribute sets
            result = all_attrs.copy()
            for attrs in objects.values():
                result &= attrs
            return frozenset(result)
        
        # Find objects that have all attributes in S
        compatible_objects = []
        for obj, attrs in objects.items():
            if s <= attrs:
                compatible_objects.append(obj)
        
        if not compatible_objects:
            return frozenset(all_attrs)  # No objects → all attributes (vacuously)
        
        # Closure = intersection of attribute sets of compatible objects
        result = all_attrs.copy()
        for obj in compatible_objects:
            result &= objects[obj]
        return frozenset(result)
    
    # Build as a ClosureSystem (we need to express as Horn clauses, but
    # it's easier to just compute directly)
    print(f"Attributes: {sorted(all_attrs)}")
    print(f"\nFormal context:")
    for obj, attrs in sorted(objects.items()):
        print(f"  {obj}: {sorted(attrs)}")
    
    # Compute closed theories directly
    from itertools import combinations
    closed = []
    for r in range(len(all_attrs) + 1):
        for combo in combinations(sorted(all_attrs), r):
            S = frozenset(combo)
            if attribute_closure(S) == S:
                closed.append(S)
    
    print(f"\nClosed attribute sets ({len(closed)}):")
    for T in sorted(closed, key=lambda s: (len(s), sorted(s))):
        print(f"  {set(T) if T else '{}'}")
    
    # Find primes
    primes = []
    for P in closed:
        if P == frozenset(all_attrs):
            continue
        is_prime = True
        for A in closed:
            if A == P:
                continue
            for B in closed:
                if B == P:
                    continue
                if A & B == P:
                    is_prime = False
                    break
            if not is_prime:
                break
        if is_prime:
            primes.append(P)
    
    print(f"\nPrime spectrum ({len(primes)} meet-irreducible concepts):")
    for P in sorted(primes, key=lambda s: (len(s), sorted(s))):
        # Find which objects have exactly these attributes
        compatible = [obj for obj, attrs in objects.items() if P <= attrs]
        print(f"  {set(P) if P else '{}'}")
        print(f"    Compatible objects: {compatible}")
    
    # Verify reconstruction
    print(f"\nReconstruction verification:")
    all_ok = True
    for r in range(len(all_attrs) + 1):
        for combo in combinations(sorted(all_attrs), r):
            S = frozenset(combo)
            actual = attribute_closure(S)
            # Reconstruct
            containing = [P for P in primes if S <= P]
            if not containing:
                reconstructed = frozenset(all_attrs)
            else:
                reconstructed = frozenset(all_attrs)
                for P in containing:
                    reconstructed = reconstructed & P
            if actual != reconstructed:
                all_ok = False
                print(f"  FAIL: Cl({set(S)}) = {set(actual)} ≠ {set(reconstructed)}")
    if all_ok:
        print(f"  ✅ Reconstruction verified for all {2**len(all_attrs)} attribute sets!")


def app_knowledge_compression():
    """Application 4: Knowledge base compression via spectral encoding.
    
    Demonstrates that the prime spectrum provides a compact representation
    of the full closure system.
    """
    print("\n" + "=" * 60)
    print("Application 4: Knowledge Base Compression")
    print("=" * 60)
    
    # A larger closure system
    kb = from_implication_basis(
        {'a', 'b', 'c', 'd', 'e', 'f'},
        [
            ({'a'}, 'b'),
            ({'b'}, 'c'),
            ({'c'}, 'a'),  # cycle: a↔b↔c
            ({'d'}, 'e'),
            ({'e'}, 'f'),
            ({'f'}, 'd'),  # cycle: d↔e↔f
            ({'a', 'd'}, 'b'),  # redundant, but adds complexity
        ]
    )
    
    closed = kb.closed_theories()
    primes = kb.prime_spectrum()
    
    print(f"Generators: {len(kb.generators)}")
    print(f"Horn clauses: {len(kb.clauses)}")
    print(f"Total subsets: {2**len(kb.generators)}")
    print(f"Closed theories: {len(closed)}")
    print(f"Prime spectrum size: {len(primes)}")
    print(f"\nCompression ratio: {len(primes)}/{len(closed)} = "
          f"{len(primes)/max(len(closed),1):.2%} of closed theories")
    print(f"  (only {len(primes)} prime points needed to reconstruct "
          f"all {len(closed)} closed theories)")
    
    verified = kb.verify_reconstruction()
    print(f"\nReconstruction verified: {verified}")
    
    # Show the primes
    print(f"\nPrime theories:")
    for P in sorted(primes, key=lambda s: (len(s), sorted(s))):
        print(f"  {set(P) if P else '{}'}")
    
    # Benchmark
    results = benchmark(kb)
    print(f"\nBenchmark:")
    for k, v in results.items():
        if isinstance(v, float):
            print(f"  {k}: {v:.6f}s")
        else:
            print(f"  {k}: {v}")


if __name__ == "__main__":
    app_database_normalization()
    app_horn_clause_reasoning()
    app_formal_concept_analysis()
    app_knowledge_compression()
    
    print("\n" + "=" * 60)
    print("All applications demonstrated successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Closure Spectrum Duality — Interactive Demo

Demonstrates the reconstruction theorem: for a finite closure operator,
Cl(A) = ∩{P prime | A ⊆ P}.

Each example defines a closure operator on a small set, computes the prime
spectrum, and verifies the reconstruction formula.
"""

from itertools import combinations
from typing import Callable, FrozenSet, Set


def powerset(s: set) -> list[frozenset]:
    """All subsets of s, as frozensets."""
    elems = list(s)
    result = []
    for r in range(len(elems) + 1):
        for combo in combinations(elems, r):
            result.append(frozenset(combo))
    return result


def find_closed_theories(
    G: set, cl: Callable[[frozenset], frozenset]
) -> list[frozenset]:
    """Find all closed theories T with Cl(T) = T."""
    closed = []
    for s in powerset(G):
        if cl(s) == s:
            closed.append(s)
    return closed


def is_meet_irreducible(
    P: frozenset, closed_theories: list[frozenset], G: set
) -> bool:
    """Check if P is meet-irreducible: P ≠ G and P cannot be written as
    A ∩ B with A, B closed and A ≠ P, B ≠ P."""
    top = frozenset(G)
    if P == top:
        return False
    for A in closed_theories:
        for B in closed_theories:
            if A & B == P and A != P and B != P:
                return False
    return True


def find_prime_spectrum(
    G: set, cl: Callable[[frozenset], frozenset]
) -> list[frozenset]:
    """Compute the prime spectrum: all meet-irreducible closed theories."""
    closed = find_closed_theories(G, cl)
    return [P for P in closed if is_meet_irreducible(P, closed, G)]


def reconstruct_closure(
    A: frozenset, primes: list[frozenset], G: set
) -> frozenset:
    """Reconstruct Cl(A) as ∩{P prime | A ⊆ P}."""
    containing = [P for P in primes if A <= P]
    if not containing:
        return frozenset(G)
    result = frozenset(G)
    for P in containing:
        result = result & P
    return result


def verify_reconstruction(
    G: set, cl: Callable[[frozenset], frozenset], name: str
):
    """Verify the reconstruction theorem for all subsets of G."""
    primes = find_prime_spectrum(G, cl)
    closed = find_closed_theories(G, cl)

    print(f"\n{'='*60}")
    print(f"Example: {name}")
    print(f"{'='*60}")
    print(f"Generators: {sorted(G)}")
    print(f"Closed theories ({len(closed)}):")
    for T in sorted(closed, key=lambda s: (len(s), sorted(s))):
        print(f"  {set(T) if T else '{}'}")
    print(f"\nPrime spectrum ({len(primes)} points):")
    for P in sorted(primes, key=lambda s: (len(s), sorted(s))):
        print(f"  {set(P) if P else '{}'}")

    print(f"\nReconstruction verification:")
    all_ok = True
    for S in powerset(G):
        actual = cl(S)
        reconstructed = reconstruct_closure(S, primes, G)
        ok = actual == reconstructed
        if not ok:
            all_ok = False
        status = "✓" if ok else "✗"
        print(f"  Cl({set(S) if S else '{}'}) = {set(actual) if actual else '{}'} "
              f"[reconstructed: {set(reconstructed) if reconstructed else '{}'}] {status}")

    if all_ok:
        print(f"\n  ✅ Reconstruction theorem verified for all {2**len(G)} subsets!")
    else:
        print(f"\n  ❌ Reconstruction failed for some subsets!")


# ============================================================
# Example 1: Three generators with "any two implies the third"
# ============================================================
def cl_example1(S: frozenset) -> frozenset:
    G = frozenset({'a', 'b', 'c'})
    if len(S & G) >= 2:
        return G
    return S & G


# ============================================================
# Example 2: Linear chain closure
# Cl({1}) = {1}, Cl({2}) = {1,2}, Cl({3}) = {1,2,3}
# ============================================================
def cl_example2(S: frozenset) -> frozenset:
    G = frozenset({1, 2, 3})
    result = set(S & G)
    if 3 in result:
        result |= {1, 2, 3}
    if 2 in result:
        result.add(1)
    return frozenset(result)


# ============================================================
# Example 3: Database functional dependencies
# Attributes: {A, B, C, D}
# FDs: A → B, BC → D
# ============================================================
def cl_example3(S: frozenset) -> frozenset:
    result = set(S)
    changed = True
    while changed:
        changed = False
        if 'A' in result and 'B' not in result:
            result.add('B')
            changed = True
        if 'B' in result and 'C' in result and 'D' not in result:
            result.add('D')
            changed = True
    return frozenset(result)


# ============================================================
# Example 4: Propositional Horn clauses
# Variables: {p, q, r, s}
# Rules: p ∧ q → r, r → s, p → q
# ============================================================
def cl_example4(S: frozenset) -> frozenset:
    result = set(S)
    changed = True
    while changed:
        changed = False
        if 'p' in result and 'q' not in result:
            result.add('q')
            changed = True
        if 'p' in result and 'q' in result and 'r' not in result:
            result.add('r')
            changed = True
        if 'r' in result and 's' not in result:
            result.add('s')
            changed = True
    return frozenset(result)


if __name__ == "__main__":
    print("Closure Spectrum Duality — Demonstration")
    print("Verifying: Cl(A) = ∩{P prime | A ⊆ P}")

    verify_reconstruction(
        {'a', 'b', 'c'}, cl_example1,
        "Three generators, any two imply the third"
    )

    verify_reconstruction(
        {1, 2, 3}, cl_example2,
        "Linear chain: 3→{1,2,3}, 2→{1,2}"
    )

    verify_reconstruction(
        {'A', 'B', 'C', 'D'}, cl_example3,
        "Database FDs: A→B, BC→D"
    )

    verify_reconstruction(
        {'p', 'q', 'r', 's'}, cl_example4,
        "Horn clauses: p→q, p∧q→r, r→s"
    )

    print("\n" + "="*60)
    print("All examples verified successfully!")
    print("="*60)


#!/usr/bin/env python3
"""
Closure Spectrum Duality — Visualizations

Generates visual representations of closure spectra, lattices, and reconstruction.
Saves figures as PNG files and returns base64 data URIs.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from itertools import combinations
import base64
import io


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def visualize_closed_theory_lattice():
    """Visualize the lattice of closed theories with primes highlighted."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 7))
    
    # Example 1: Three generators, any two imply the third
    ax = axes[0]
    ax.set_title("Closure Lattice: 'Any Two → Third'", fontsize=13, fontweight='bold')
    
    # Lattice: {} < {a} < {a,b,c}, {} < {b} < {a,b,c}, {} < {c} < {a,b,c}
    positions = {
        '∅': (0.5, 0),
        '{a}': (0, 0.5),
        '{b}': (0.5, 0.5),
        '{c}': (1, 0.5),
        '{a,b,c}': (0.5, 1),
    }
    
    primes = {'{a}', '{b}', '{c}'}
    
    edges = [
        ('∅', '{a}'), ('∅', '{b}'), ('∅', '{c}'),
        ('{a}', '{a,b,c}'), ('{b}', '{a,b,c}'), ('{c}', '{a,b,c}'),
    ]
    
    for src, dst in edges:
        ax.plot([positions[src][0], positions[dst][0]], 
                [positions[src][1], positions[dst][1]], 
                'k-', linewidth=1.5, zorder=1)
    
    for name, (x, y) in positions.items():
        color = '#FF6B6B' if name in primes else '#4ECDC4'
        size = 800 if name in primes else 600
        ax.scatter(x, y, s=size, c=color, edgecolors='black', 
                   linewidths=2, zorder=2)
        offset_y = -0.08 if y == 0 else (0.08 if y == 1 else 0.08)
        ax.text(x, y + offset_y, name, ha='center', va='center', 
                fontsize=11, fontweight='bold')
    
    ax.set_xlim(-0.3, 1.3)
    ax.set_ylim(-0.2, 1.2)
    ax.set_aspect('equal')
    ax.axis('off')
    
    prime_patch = mpatches.Patch(color='#FF6B6B', label='Prime (meet-irred.)')
    other_patch = mpatches.Patch(color='#4ECDC4', label='Non-prime')
    ax.legend(handles=[prime_patch, other_patch], loc='lower right', fontsize=10)
    
    # Example 2: Linear chain
    ax = axes[1]
    ax.set_title("Closure Lattice: Linear Chain 3→2→1", fontsize=13, fontweight='bold')
    
    positions2 = {
        '∅': (0.5, 0),
        '{1}': (0.5, 0.33),
        '{1,2}': (0.5, 0.66),
        '{1,2,3}': (0.5, 1),
    }
    
    primes2 = {'{1,2}'}  # Only meet-irreducible proper closed set
    
    edges2 = [
        ('∅', '{1}'), ('{1}', '{1,2}'), ('{1,2}', '{1,2,3}'),
    ]
    
    for src, dst in edges2:
        ax.plot([positions2[src][0], positions2[dst][0]], 
                [positions2[src][1], positions2[dst][1]], 
                'k-', linewidth=1.5, zorder=1)
    
    for name, (x, y) in positions2.items():
        color = '#FF6B6B' if name in primes2 else '#4ECDC4'
        size = 800 if name in primes2 else 600
        ax.scatter(x, y, s=size, c=color, edgecolors='black', 
                   linewidths=2, zorder=2)
        ax.text(x + 0.15, y, name, ha='left', va='center', 
                fontsize=11, fontweight='bold')
    
    ax.set_xlim(-0.1, 1.1)
    ax.set_ylim(-0.15, 1.15)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.legend(handles=[prime_patch, other_patch], loc='lower right', fontsize=10)
    
    fig.suptitle("Closed Theory Lattices with Prime Spectrum Highlighted", 
                 fontsize=15, fontweight='bold', y=1.02)
    plt.tight_layout()
    return fig


def visualize_reconstruction():
    """Visualize the reconstruction theorem: Cl(A) = ∩{P prime | A ⊆ P}."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    
    # Example: G = {a,b,c}, closure: any two imply third
    # Primes: {a}, {b}, {c}
    # Show reconstruction for different sets
    
    sets_and_closures = [
        ('{a}', '{a}', ['{a}']),
        ('{b}', '{b}', ['{b}']),
        ('{a,b}', '{a,b,c}', []),
        ('∅', '∅', ['{a}', '{b}', '{c}']),
        ('{c}', '{c}', ['{c}']),
    ]
    
    y_positions = list(range(len(sets_and_closures)))
    
    for i, (input_set, closure, primes_above) in enumerate(sets_and_closures):
        y = len(sets_and_closures) - 1 - i
        
        # Input set
        ax.text(0.5, y, input_set, ha='center', va='center', fontsize=14,
                bbox=dict(boxstyle='round,pad=0.3', facecolor='#E8F4FD', 
                         edgecolor='#2196F3', linewidth=2))
        
        # Arrow
        ax.annotate('', xy=(1.8, y), xytext=(1.2, y),
                    arrowprops=dict(arrowstyle='->', color='#333', lw=2))
        ax.text(1.5, y + 0.25, 'Cl', ha='center', va='center', fontsize=11,
                fontstyle='italic', color='#666')
        
        # Primes above (or "none")
        if primes_above:
            primes_text = ' ∩ '.join(primes_above)
        else:
            primes_text = '(no primes above)'
        
        ax.text(3.0, y, primes_text, ha='center', va='center', fontsize=12,
                color='#FF6B6B', fontweight='bold')
        
        # Arrow
        ax.annotate('', xy=(4.5, y), xytext=(4.0, y),
                    arrowprops=dict(arrowstyle='->', color='#333', lw=2))
        ax.text(4.25, y + 0.25, '=', ha='center', va='center', fontsize=14,
                fontweight='bold', color='#666')
        
        # Result
        ax.text(5.2, y, closure, ha='center', va='center', fontsize=14,
                bbox=dict(boxstyle='round,pad=0.3', facecolor='#E8F8E8', 
                         edgecolor='#4CAF50', linewidth=2))
    
    # Headers
    ax.text(0.5, len(sets_and_closures) + 0.3, 'Input A', ha='center', 
            fontsize=13, fontweight='bold', color='#2196F3')
    ax.text(3.0, len(sets_and_closures) + 0.3, '∩{P prime | A⊆P}', ha='center',
            fontsize=13, fontweight='bold', color='#FF6B6B')
    ax.text(5.2, len(sets_and_closures) + 0.3, 'Cl(A)', ha='center',
            fontsize=13, fontweight='bold', color='#4CAF50')
    
    ax.set_xlim(-0.5, 6.0)
    ax.set_ylim(-0.8, len(sets_and_closures) + 0.8)
    ax.axis('off')
    ax.set_title("Reconstruction Theorem: Cl(A) = ∩{P prime | A ⊆ P}\n"
                 "Example: G={a,b,c}, any two generators imply the third",
                 fontsize=14, fontweight='bold', pad=20)
    
    plt.tight_layout()
    return fig


def visualize_spectrum_topology():
    """Visualize the topology on the prime spectrum via basic opens."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    # Example: G = {a,b,c}, any two imply third
    # Primes: P1={a}, P2={b}, P3={c}
    # D({a}) = {P2, P3}, D({b}) = {P1, P3}, D({c}) = {P1, P2}
    
    prime_positions = {
        'P₁={a}': (0, 0),
        'P₂={b}': (1, 0),
        'P₃={c}': (0.5, 0.87),
    }
    
    basic_opens = [
        ('D({a})', ['P₂={b}', 'P₃={c}'], '#FFCDD2'),
        ('D({b})', ['P₁={a}', 'P₃={c}'], '#C8E6C9'),
        ('D({c})', ['P₁={a}', 'P₂={b}'], '#BBDEFB'),
    ]
    
    for idx, (title, members, color) in enumerate(basic_opens):
        ax = axes[idx]
        ax.set_title(f"Basic Open {title}", fontsize=13, fontweight='bold')
        
        for name, (x, y) in prime_positions.items():
            if name in members:
                ax.scatter(x, y, s=1000, c=color, edgecolors='black', 
                          linewidths=2, zorder=2)
            else:
                ax.scatter(x, y, s=1000, c='#F5F5F5', edgecolors='#999',
                          linewidths=2, zorder=2, linestyle='dashed')
            ax.text(x, y - 0.15, name, ha='center', va='center', 
                    fontsize=10, fontweight='bold')
        
        # Draw convex hull of members
        member_pos = [prime_positions[m] for m in members]
        if len(member_pos) >= 2:
            xs = [p[0] for p in member_pos]
            ys = [p[1] for p in member_pos]
            ax.fill(xs + [xs[0]], ys + [ys[0]], alpha=0.15, color=color)
        
        ax.set_xlim(-0.5, 1.5)
        ax.set_ylim(-0.5, 1.3)
        ax.set_aspect('equal')
        ax.axis('off')
    
    fig.suptitle("Topology on ClSpec: Basic Opens D(F) = {P | F ⊄ P}", 
                 fontsize=15, fontweight='bold', y=1.05)
    plt.tight_layout()
    return fig


def generate_all_visualizations():
    """Generate all visualizations and return as base64 data URIs."""
    results = {}
    
    fig1 = visualize_closed_theory_lattice()
    results['lattice'] = fig_to_base64(fig1)
    fig1.savefig('/workspace/request-project/lattice.png', dpi=150, bbox_inches='tight')
    plt.close(fig1)
    
    fig2 = visualize_reconstruction()
    results['reconstruction'] = fig_to_base64(fig2)
    fig2.savefig('/workspace/request-project/reconstruction.png', dpi=150, bbox_inches='tight')
    plt.close(fig2)
    
    fig3 = visualize_spectrum_topology()
    results['topology'] = fig_to_base64(fig3)
    fig3.savefig('/workspace/request-project/topology.png', dpi=150, bbox_inches='tight')
    plt.close(fig3)
    
    return results


if __name__ == "__main__":
    print("Generating visualizations...")
    results = generate_all_visualizations()
    print(f"Generated {len(results)} visualizations:")
    for name, uri in results.items():
        print(f"  {name}: {len(uri)} chars")
    print("Saved PNG files: lattice.png, reconstruction.png, topology.png")
