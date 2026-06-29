#!/usr/bin/env python3
"""
Provability Spectral Theory: Interactive Demonstration

This demo illustrates the key theorems of spectral proof theory using
concrete finite Boolean algebras (power sets).

Key concepts demonstrated:
1. GL provability operators on finite Boolean algebras
2. Gödel's second incompleteness theorem (□⊥ ≠ ⊥)
3. Löb's rule (□x ≤ x implies x = ⊤)
4. Unique fixed-point theorem (Fix(□) = {⊤})
5. Empty kernel theorem (Ker(□) = ∅)
6. Ascending iteration chains
"""

import itertools
from typing import Callable, Set, FrozenSet, List, Tuple
import sys

# Type aliases
Element = FrozenSet[int]  # Elements of the power-set Boolean algebra P({0,...,n-1})


class PowerSetBooleanAlgebra:
    """The Boolean algebra P({0, 1, ..., n-1}) of subsets of {0,...,n-1}."""
    
    def __init__(self, n: int):
        self.n = n
        self.universe = frozenset(range(n))
        # Generate all elements (subsets)
        self.elements = []
        for k in range(n + 1):
            for combo in itertools.combinations(range(n), k):
                self.elements.append(frozenset(combo))
        self.top = self.universe
        self.bot = frozenset()
    
    def meet(self, a: Element, b: Element) -> Element:
        """a ⊓ b = a ∩ b"""
        return a & b
    
    def join(self, a: Element, b: Element) -> Element:
        """a ⊔ b = a ∪ b"""
        return a | b
    
    def complement(self, a: Element) -> Element:
        """aᶜ = U \ a"""
        return self.universe - a
    
    def himp(self, a: Element, b: Element) -> Element:
        """a ⇨ b = b ∪ aᶜ (Heyting implication in Boolean algebra)"""
        return b | (self.universe - a)
    
    def le(self, a: Element, b: Element) -> bool:
        """a ≤ b iff a ⊆ b"""
        return a <= b
    
    def __repr__(self):
        return f"P({{{', '.join(map(str, range(self.n)))}}})"


def format_set(s: Element) -> str:
    """Pretty-print a set element."""
    if not s:
        return "∅"
    return "{" + ", ".join(map(str, sorted(s))) + "}"


class GLOperator:
    """A GL provability operator on a power-set Boolean algebra."""
    
    def __init__(self, algebra: PowerSetBooleanAlgebra, 
                 box: Callable[[Element], Element], name: str = "□"):
        self.algebra = algebra
        self.box = box
        self.name = name
    
    def verify_gl_axioms(self) -> dict:
        """Verify all GL axioms and return results."""
        results = {}
        alg = self.algebra
        
        # □⊤ = ⊤
        results["box_top"] = self.box(alg.top) == alg.top
        
        # Monotonicity
        mono = True
        for a in alg.elements:
            for b in alg.elements:
                if alg.le(a, b) and not alg.le(self.box(a), self.box(b)):
                    mono = False
                    break
        results["monotone"] = mono
        
        # □(x ⊓ y) = □x ⊓ □y
        inf_pres = True
        for a in alg.elements:
            for b in alg.elements:
                if self.box(alg.meet(a, b)) != alg.meet(self.box(a), self.box(b)):
                    inf_pres = False
                    break
        results["box_inf"] = inf_pres
        
        # Axiom 4: □x ≤ □□x
        four = True
        for a in alg.elements:
            if not alg.le(self.box(a), self.box(self.box(a))):
                four = False
                break
        results["axiom_4"] = four
        
        # Löb: □(□x ⇨ x) ≤ □x
        lob = True
        for a in alg.elements:
            lhs = self.box(alg.himp(self.box(a), a))
            rhs = self.box(a)
            if not alg.le(lhs, rhs):
                lob = False
                break
        results["lob"] = lob
        
        return results
    
    def find_fixed_points(self) -> List[Element]:
        """Find all fixed points of □."""
        return [x for x in self.algebra.elements if self.box(x) == x]
    
    def find_kernel(self) -> List[Element]:
        """Find all x with □x = ⊥."""
        return [x for x in self.algebra.elements if self.box(x) == self.algebra.bot]
    
    def consistency_strength(self) -> Element:
        """Return □⊥ — the consistency strength."""
        return self.box(self.algebra.bot)
    
    def iterate(self, x: Element, n: int) -> Element:
        """Compute □ⁿ(x)."""
        result = x
        for _ in range(n):
            result = self.box(result)
        return result
    
    def ascending_chain(self, x: Element, max_steps: int = 10) -> List[Element]:
        """Compute the ascending chain □x, □²x, □³x, ..."""
        chain = [x]
        current = x
        for _ in range(max_steps):
            current = self.box(current)
            chain.append(current)
            if current == self.algebra.top:
                break
        return chain


def trivial_gl(algebra: PowerSetBooleanAlgebra) -> GLOperator:
    """The trivial GL operator: □ = const ⊤."""
    return GLOperator(algebra, lambda x: algebra.top, "□_trivial")


def print_header(title: str):
    print(f"\n{'='*70}")
    print(f"  {title}")
    print(f"{'='*70}\n")


def demo_trivial_gl():
    """Demonstrate the trivial GL operator and verify theorems."""
    print_header("Demo 1: Trivial GL Operator on P({0,1,2})")
    
    alg = PowerSetBooleanAlgebra(3)
    op = trivial_gl(alg)
    
    print(f"Boolean algebra: {alg}")
    print(f"Number of elements: {len(alg.elements)}")
    print(f"⊤ = {format_set(alg.top)}")
    print(f"⊥ = {format_set(alg.bot)}")
    print(f"\nOperator: □(x) = ⊤ for all x (trivial/inconsistent)")
    
    # Verify axioms
    print("\n--- GL Axiom Verification ---")
    axioms = op.verify_gl_axioms()
    for name, holds in axioms.items():
        status = "✓" if holds else "✗"
        print(f"  {status} {name}")
    
    # Verify theorems
    print("\n--- Theorem Verification ---")
    
    # Gödel's second: □⊥ ≠ ⊥
    box_bot = op.box(alg.bot)
    print(f"  □⊥ = {format_set(box_bot)}")
    print(f"  □⊥ ≠ ⊥: {'✓ VERIFIED' if box_bot != alg.bot else '✗ FAILED'}")
    print(f"  (Consistency strength = {format_set(box_bot)})")
    
    # Unique fixed point
    fps = op.find_fixed_points()
    print(f"\n  Fixed points of □: {[format_set(fp) for fp in fps]}")
    print(f"  Fix(□) = {{⊤}}: {'✓ VERIFIED' if fps == [alg.top] else '✗ FAILED'}")
    
    # Empty kernel
    ker = op.find_kernel()
    print(f"\n  Kernel of □: {[format_set(k) for k in ker]}")
    print(f"  Ker(□) = ∅: {'✓ VERIFIED' if ker == [] else '✗ FAILED'}")
    
    # Löb's rule
    print("\n  Löb's rule verification (□x ≤ x ⟹ x = ⊤):")
    for x in alg.elements:
        if alg.le(op.box(x), x):
            is_top = (x == alg.top)
            print(f"    □{format_set(x)} ≤ {format_set(x)}: x = ⊤? {'✓' if is_top else '✗'}")


def demo_ascending_chains():
    """Demonstrate ascending iteration chains."""
    print_header("Demo 2: Ascending Chains □ⁿ(x)")
    
    alg = PowerSetBooleanAlgebra(3)
    op = trivial_gl(alg)
    
    print("For the trivial GL operator (□ = const ⊤):\n")
    
    test_elements = [alg.bot, frozenset({0}), frozenset({0, 1}), alg.top]
    for x in test_elements:
        chain = op.ascending_chain(x, 3)
        chain_str = " → ".join(format_set(c) for c in chain)
        print(f"  Starting from {format_set(x)}: {chain_str}")
    
    print("\nObservation: All chains reach ⊤ in exactly one step.")
    print("This is because □ = const ⊤ maps everything to ⊤ immediately.")


def demo_modal_spectrum():
    """Demonstrate the modal spectral set."""
    print_header("Demo 3: Modal Spectral Analysis")
    
    alg = PowerSetBooleanAlgebra(3)
    op = trivial_gl(alg)
    
    print("Modal spectrum analysis for □ = const ⊤ on P({0,1,2}):\n")
    
    # Find spectral set: {λ | ∃ x ≠ ⊥, □x = λ ⊓ x}
    spectral_set = set()
    for lam in alg.elements:
        for x in alg.elements:
            if x != alg.bot and op.box(x) == alg.meet(lam, x):
                spectral_set.add(lam)
                break
    
    print(f"  Spectral set: {{{', '.join(format_set(s) for s in sorted(spectral_set, key=lambda s: len(s)))}}}")
    
    # Check ⊤ ∈ spectrum
    top_in = alg.top in spectral_set
    print(f"  ⊤ ∈ spectrum: {'✓' if top_in else '✗'}")
    
    # Check ⊥ ∉ spectrum
    bot_in = alg.bot in spectral_set
    print(f"  ⊥ ∉ spectrum: {'✓' if not bot_in else '✗'}")
    
    print("\nSpectral gap analysis:")
    print(f"  Consistency strength (□⊥): {format_set(op.consistency_strength())}")
    print(f"  This provides a lower bound for all □x values.")
    
    # Show all box values
    print("\n  Complete □ table:")
    for x in alg.elements:
        print(f"    □({format_set(x)}) = {format_set(op.box(x))}")


def demo_lattice_endomorphism():
    """Demonstrate a modal lattice endomorphism (without Löb)."""
    print_header("Demo 4: Modal Lattice Endomorphism (No Löb)")
    
    alg = PowerSetBooleanAlgebra(2)
    
    # Identity endomorphism: □ = id
    id_op = GLOperator(alg, lambda x: x, "□_id")
    
    print(f"Boolean algebra: P({{0,1}}) = {{∅, {{0}}, {{1}}, {{0,1}}}}")
    print(f"\n--- Identity operator □ = id ---")
    
    fps = id_op.find_fixed_points()
    print(f"  Fixed points: {[format_set(fp) for fp in fps]}")
    print(f"  (Every element is a fixed point — maximally degenerate!)")
    
    # Check if id satisfies Löb
    lob_holds = True
    for a in alg.elements:
        lhs = alg.himp(id_op.box(a), a)  # □a ⇨ a = a ⇨ a = ⊤
        box_lhs = id_op.box(lhs)  # □⊤ = ⊤
        rhs = id_op.box(a)  # □a = a
        if not alg.le(box_lhs, rhs):
            lob_holds = False
            print(f"  Löb fails at x = {format_set(a)}: □(□x⇨x) = {format_set(box_lhs)} ≰ □x = {format_set(rhs)}")
            break
    
    if not lob_holds:
        print(f"\n  → The identity does NOT satisfy Löb's axiom!")
        print(f"  → This is why Fix(id) ≠ {{⊤}} — Löb is essential for spectral rigidity.")
    
    print(f"\n--- Constant-⊤ operator □ = const ⊤ ---")
    const_op = trivial_gl(alg)
    fps2 = const_op.find_fixed_points()
    print(f"  Fixed points: {[format_set(fp) for fp in fps2]}")
    print(f"  Löb axiom holds: {const_op.verify_gl_axioms()['lob']}")
    print(f"  → Löb forces Fix(□) = {{⊤}}!")


def demo_goedel_second_proof():
    """Walk through the proof of Gödel's second incompleteness theorem."""
    print_header("Demo 5: Gödel's Second Incompleteness — Proof Walkthrough")
    
    alg = PowerSetBooleanAlgebra(2)
    
    print("Proof by contradiction that □⊥ ≠ ⊥ for any GL operator on P({0,1}).\n")
    print("Suppose □⊥ = ⊥ (the system proves its own consistency).\n")
    
    print("Step 1: By Löb's axiom with x = ⊥:")
    print("        □(□⊥ ⇨ ⊥) ≤ □⊥")
    print()
    
    print("Step 2: Since □⊥ = ⊥ (our assumption):")
    bot_himp = alg.himp(alg.bot, alg.bot)
    print(f"        □⊥ ⇨ ⊥ = ⊥ ⇨ ⊥ = {format_set(bot_himp)} = ⊤")
    print()
    
    print("Step 3: So □(⊥ ⇨ ⊥) = □⊤ = ⊤ (by axiom □⊤ = ⊤)")
    print()
    
    print("Step 4: Substituting back: ⊤ ≤ □⊥ = ⊥")
    print("        This gives ⊤ ≤ ⊥, i.e., ⊤ = ⊥")
    print()
    
    print("Step 5: But ⊤ ≠ ⊥ in a non-trivial Boolean algebra! Contradiction. ∎")
    print()
    print("═" * 50)
    print("  GÖDEL'S SECOND INCOMPLETENESS THEOREM:")
    print("  No consistent GL system can prove its own consistency.")
    print("  Equivalently: □⊥ ≠ ⊥ in any non-trivial GL algebra.")
    print("═" * 50)


def demo_spectral_comparison():
    """Compare spectral properties of different operator types."""
    print_header("Demo 6: Spectral Comparison — Why Löb Matters")
    
    print("Comparing operators on P({0,1,2}) = 8-element Boolean algebra:\n")
    
    alg = PowerSetBooleanAlgebra(3)
    
    # Operator 1: Identity (no Löb)
    id_fps = [x for x in alg.elements if x == x]  # All elements
    print(f"  Identity (□ = id):")
    print(f"    Fixed points: ALL {len(id_fps)} elements")
    print(f"    Kernel: {{∅}} (1 element)")
    print(f"    Satisfies Löb: NO")
    print(f"    → Rich spectral structure (full eigenspace)")
    print()
    
    # Operator 2: Trivial GL (with Löb)
    triv = trivial_gl(alg)
    fps = triv.find_fixed_points()
    ker = triv.find_kernel()
    print(f"  Trivial GL (□ = const ⊤):")
    print(f"    Fixed points: {len(fps)} element (only ⊤)")
    print(f"    Kernel: {len(ker)} elements (empty)")
    print(f"    Satisfies Löb: YES")
    print(f"    → Degenerate spectrum (Löb forces rigidity)")
    print()
    
    print("  CONCLUSION: The Löb axiom is the spectral rigidity condition.")
    print("  Without it, the operator can have rich eigenstructure.")
    print("  With it, Fix(□) = {{⊤}} and Ker(□) = ∅ — maximal degeneracy.")


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║     PROVABILITY SPECTRAL THEORY — Interactive Demonstration     ║")
    print("║     Löb Fixed Points & Modal Eigenvalue Decomposition           ║")
    print("╚══════════════════════════════════════════════════════════════════╝")
    
    demo_trivial_gl()
    demo_ascending_chains()
    demo_modal_spectrum()
    demo_lattice_endomorphism()
    demo_goedel_second_proof()
    demo_spectral_comparison()
    
    print("\n" + "="*70)
    print("  All demonstrations complete.")
    print("  See RESEARCH_REPORT.md for the full mathematical treatment.")
    print("  See Catalog/Bridges/ProvabilitySpectralTheory.lean for formal proofs.")
    print("="*70)
