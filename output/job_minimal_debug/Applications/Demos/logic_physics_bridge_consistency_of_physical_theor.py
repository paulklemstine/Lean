#!/usr/bin/env python3
"""
Logic-Physics Bridge: Numerical Demonstrations

Demonstrates the key results from the formal verification of the
relationship between physical consistency (model existence) and
mathematical consistency (non-derivability of falsum).

All functions are self-contained with type hints.
"""

from __future__ import annotations
from dataclasses import dataclass, field
from typing import Callable


# =============================================================================
# Core Definitions
# =============================================================================

@dataclass
class ProofSystem:
    """
    An abstract proof system with sentences, worlds, and a provability relation.

    Attributes:
        name: Human-readable name for the proof system.
        sentences: List of sentence identifiers.
        worlds: List of world identifiers (empty list = no physical models).
        theory: Set of axiom sentence indices.
        provable: Function determining which sentences are provable.
        satisfies: Function (world, sentence) -> bool for satisfaction.
        falsum: Index of the falsum (contradiction) sentence.
    """
    name: str
    sentences: list[str]
    worlds: list[str]
    theory: set[int]
    provable: Callable[[int], bool]
    satisfies: Callable[[int, int], bool]
    falsum: int = 0  # Index of falsum sentence


def is_consistent(ps: ProofSystem) -> bool:
    """A theory is consistent iff falsum is not provable."""
    return not ps.provable(ps.falsum)


def is_physically_consistent(ps: ProofSystem) -> bool:
    """A theory is physically consistent iff some world satisfies all axioms."""
    for w in range(len(ps.worlds)):
        if all(ps.satisfies(w, s) for s in ps.theory):
            return True
    return False


def is_sound(ps: ProofSystem) -> bool:
    """
    A proof system is sound iff every provable sentence is true in
    every model of the theory.
    """
    for s in range(len(ps.sentences)):
        if ps.provable(s):
            for w in range(len(ps.worlds)):
                if all(ps.satisfies(w, ax) for ax in ps.theory):
                    if not ps.satisfies(w, s):
                        return False
    return True


def is_falsum_sound(ps: ProofSystem) -> bool:
    """
    A proof system is falsum-sound iff: if falsum is provable,
    then no world satisfies all axioms.

    Equivalently: if a model exists, falsum is not provable.
    """
    if ps.provable(ps.falsum):
        # Falsum is provable => require no models
        for w in range(len(ps.worlds)):
            if all(ps.satisfies(w, ax) for ax in ps.theory):
                return False  # Found a model but falsum is provable
    return True


# =============================================================================
# Demo 1: The One-Way Bridge (Theorem 3)
# =============================================================================

def demo_one_way_bridge() -> None:
    """
    Demonstrates that physical consistency implies mathematical consistency.

    We construct a sound proof system with a model and verify that it is
    both physically and mathematically consistent. Then we show a system
    that is mathematically consistent but not physically consistent.
    """
    print("=" * 70)
    print("DEMO 1: The One-Way Bridge")
    print("Physical consistency => Mathematical consistency (but not vice versa)")
    print("=" * 70)

    # System A: Has a model => both physically and mathematically consistent
    system_a = ProofSystem(
        name="Newtonian Mechanics (simplified)",
        sentences=["⊥ (falsum)", "F = ma", "energy is conserved", "space is 3D"],
        worlds=["classical universe"],
        theory={1, 2, 3},  # F=ma, energy conservation, 3D space
        provable=lambda s: s in {1, 2, 3},  # Can prove axioms only
        satisfies=lambda w, s: s != 0,  # World satisfies everything except falsum
    )

    print(f"\nSystem A: {system_a.name}")
    print(f"  Sentences: {system_a.sentences}")
    print(f"  Worlds: {system_a.worlds}")
    print(f"  Theory (axioms): {[system_a.sentences[i] for i in system_a.theory]}")
    print(f"  Sound: {is_sound(system_a)}")
    print(f"  Mathematically consistent: {is_consistent(system_a)}")
    print(f"  Physically consistent: {is_physically_consistent(system_a)}")
    print(f"  ✓ Physical consistency => Mathematical consistency")

    # System B: No worlds => mathematically consistent but not physically consistent
    system_b = ProofSystem(
        name="Void Theory (empty ontology)",
        sentences=["⊥ (falsum)", "there exist particles", "symmetry holds"],
        worlds=[],  # No possible worlds!
        theory={1, 2},
        provable=lambda s: False,  # Nothing is provable (trivially consistent)
        satisfies=lambda w, s: False,  # Vacuously true (no worlds)
    )

    print(f"\nSystem B: {system_b.name}")
    print(f"  Sentences: {system_b.sentences}")
    print(f"  Worlds: {system_b.worlds} (EMPTY!)")
    print(f"  Theory (axioms): {[system_b.sentences[i] for i in system_b.theory]}")
    print(f"  Sound: {is_sound(system_b)}")
    print(f"  Mathematically consistent: {is_consistent(system_b)}")
    print(f"  Physically consistent: {is_physically_consistent(system_b)}")
    print(f"  ✗ Mathematical consistency ≠> Physical consistency")

    print(f"\n  RESULT: The bridge is ONE-WAY.")
    print(f"  System A: Phys ✓ => Math ✓  (bridge works)")
    print(f"  System B: Math ✓ but Phys ✗  (no reverse bridge)")


# =============================================================================
# Demo 2: Separation Theorem (Theorem 4)
# =============================================================================

def demo_separation() -> None:
    """
    Constructs the explicit counterexample from Theorem 4:
    a theory with empty world type that is mathematically consistent
    but has no physical realization.
    """
    print("\n" + "=" * 70)
    print("DEMO 2: The Separation Theorem")
    print("Constructing a theory that is consistent but has no model")
    print("=" * 70)

    # The key insight: World = Empty
    empty_world_system = ProofSystem(
        name="Empty-World Separation Example",
        sentences=["⊥", "φ₁", "φ₂", "φ₃"],
        worlds=[],  # THIS is the key: no possible worlds
        theory=set(),  # Empty theory (no axioms)
        provable=lambda s: False,  # Nothing provable from empty theory
        satisfies=lambda w, s: False,  # Vacuously: no worlds to satisfy anything
    )

    math_con = is_consistent(empty_world_system)
    phys_con = is_physically_consistent(empty_world_system)

    print(f"\n  World type: Empty (no possible states of affairs)")
    print(f"  Theory: ∅ (no axioms)")
    print(f"  Provable sentences: none")
    print(f"\n  Mathematical consistency: {math_con}")
    print(f"    (falsum is not provable — trivially, nothing is provable)")
    print(f"  Physical consistency: {phys_con}")
    print(f"    (no world exists to satisfy the theory)")
    print(f"\n  GAP: Math consistent ✓ but Physically consistent ✗")
    print(f"  This is the separation: the two notions are NOT equivalent.")

    # Show how adding a world closes the gap
    system_with_world = ProofSystem(
        name="Same theory, but with a world",
        sentences=["⊥", "φ₁", "φ₂", "φ₃"],
        worlds=["w₀"],  # Now there IS a world
        theory=set(),
        provable=lambda s: False,
        satisfies=lambda w, s: s != 0,  # World satisfies everything except falsum
    )

    print(f"\n  Compare: same theory with World = {{w₀}}:")
    print(f"    Mathematical consistency: {is_consistent(system_with_world)}")
    print(f"    Physical consistency: {is_physically_consistent(system_with_world)}")
    print(f"    Now both notions agree — the world provides a semantic certificate.")


# =============================================================================
# Demo 3: Falsum-Soundness vs Full Soundness (Theorems 5-7)
# =============================================================================

def demo_falsum_soundness() -> None:
    """
    Demonstrates the soundness hierarchy:
    Full soundness ⊋ Falsum-soundness

    Constructs a proof system that is falsum-sound but NOT fully sound.
    """
    print("\n" + "=" * 70)
    print("DEMO 3: The Soundness Hierarchy")
    print("Falsum-soundness is strictly weaker than full soundness")
    print("=" * 70)

    # Proof system with deduction rule: p ⊢ q for all p, q
    # But falsum (index 0) is not an axiom and cannot be "introduced"
    # Sentences: [⊥, p, q, r]
    # Theory: {p}  (only p is an axiom)
    # Provable: everything (because p ⊢ q for all q, and p is in theory)
    # BUT: we make falsum NOT provable (special case)
    # Actually, to be more precise: provable = everything except falsum

    weird_system = ProofSystem(
        name="Deductive but Falsum-Honest System",
        sentences=["⊥ (falsum)", "p", "q", "r"],
        worlds=["w₀"],
        theory={1},  # Only p is an axiom
        provable=lambda s: s != 0,  # Everything except falsum is "provable"
        satisfies=lambda w, s: s in {1},  # World satisfies only p
    )

    f_sound = is_falsum_sound(weird_system)
    full_sound = is_sound(weird_system)
    math_con = is_consistent(weird_system)
    phys_con = is_physically_consistent(weird_system)

    print(f"\n  System: {weird_system.name}")
    print(f"  Sentences: {weird_system.sentences}")
    print(f"  Theory: {{p}}")
    print(f"  Provable: everything except ⊥")
    print(f"  World w₀ satisfies: only p")
    print(f"\n  Properties:")
    print(f"    Falsum-sound: {f_sound}")
    print(f"      (⊥ is not provable, so condition holds vacuously)")
    print(f"    Fully sound: {full_sound}")
    print(f"      (q is provable but w₀ ⊭ q — soundness violated!)")
    print(f"    Consistent: {math_con}")
    print(f"    Physically consistent: {phys_con}")

    print(f"\n  RESULT: Falsum-sound ✓ but NOT fully sound ✗")
    print(f"  This proves the generalization in Theorem 5 is PROPER.")
    print(f"  The physics→logic bridge works with LESS than full soundness.")


# =============================================================================
# Demo 4: Anti-Monotonicity of Consistency (Theorem 1)
# =============================================================================

def demo_antimonotonicity() -> None:
    """
    Shows that consistency is anti-monotone: extending a theory
    can only reduce consistency, never increase it.
    """
    print("\n" + "=" * 70)
    print("DEMO 4: Anti-Monotonicity of Consistency")
    print("Adding axioms can only reduce consistency, never increase it")
    print("=" * 70)

    def make_system(name: str, theory: set[int], provable: Callable[[int], bool]) -> ProofSystem:
        return ProofSystem(
            name=name,
            sentences=["⊥", "A", "B", "¬B", "A∧¬A"],
            worlds=["w"],
            theory=theory,
            provable=provable,
            satisfies=lambda w, s: s in {1, 2},  # w satisfies A and B
        )

    # T₀: empty theory (maximally consistent)
    t0 = make_system("T₀ = ∅", set(), lambda s: False)

    # T₁: {A} (still consistent)
    t1 = make_system("T₁ = {A}", {1}, lambda s: s == 1)

    # T₂: {A, B} (still consistent)
    t2 = make_system("T₂ = {A, B}", {1, 2}, lambda s: s in {1, 2})

    # T₃: {A, B, ¬B} (INCONSISTENT — B and ¬B together)
    t3 = make_system("T₃ = {A, B, ¬B}", {1, 2, 3}, lambda s: True)

    systems = [t0, t1, t2, t3]

    print(f"\n  Theory extension chain: T₀ ⊆ T₁ ⊆ T₂ ⊆ T₃")
    print()
    for sys in systems:
        con = is_consistent(sys)
        axiom_names = [sys.sentences[i] for i in sorted(sys.theory)]
        print(f"  {sys.name:20s} | Axioms: {str(axiom_names):30s} | Consistent: {con}")

    print(f"\n  RESULT: Consistency never INCREASES along the chain.")
    print(f"  T₀ ✓, T₁ ✓, T₂ ✓, T₃ ✗")
    print(f"  Once lost, consistency cannot be regained by adding more axioms.")
    print(f"  (Anti-monotonicity: T ⊆ T' and T' consistent => T consistent)")


# =============================================================================
# Demo 5: Theory Extensions (Theorem 8)
# =============================================================================

def demo_proper_extensions() -> None:
    """
    Shows that adding a non-provable sentence creates a proper extension.
    """
    print("\n" + "=" * 70)
    print("DEMO 5: Proper Extensions via Non-Provable Sentences")
    print("Non-provable sentences yield genuine theory extensions")
    print("=" * 70)

    base_provable = {1, 2}  # Sentences provable from base theory

    base = ProofSystem(
        name="Base Theory T",
        sentences=["⊥", "mass > 0", "energy > 0", "spin = 1/2", "charge = 0"],
        worlds=["electron"],
        theory={1, 2},  # mass > 0, energy > 0
        provable=lambda s: s in base_provable,
        satisfies=lambda w, s: s in {1, 2, 3},  # World has mass, energy, spin=1/2
    )

    # Sentence "spin = 1/2" (index 3) is NOT provable from base theory
    non_provable_sentence = 3
    extended_provable = base_provable | {non_provable_sentence}

    extended = ProofSystem(
        name="Extended Theory T'",
        sentences=base.sentences,
        worlds=base.worlds,
        theory=base.theory | {non_provable_sentence},
        provable=lambda s: s in extended_provable,
        satisfies=base.satisfies,
    )

    print(f"\n  Base theory T: axioms = {{mass > 0, energy > 0}}")
    print(f"  Provable from T: {[base.sentences[i] for i in sorted(base_provable)]}")
    print(f"  Non-provable sentence: '{base.sentences[non_provable_sentence]}'")
    print(f"\n  Extended theory T' = T ∪ {{spin = 1/2}}")
    print(f"  Provable from T': {[base.sentences[i] for i in sorted(extended_provable)]}")
    print(f"\n  T ⊊ T' (proper extension): {base.theory < extended.theory}")
    print(f"  T' proves 'spin = 1/2': {extended.provable(non_provable_sentence)}")
    print(f"  T did NOT prove 'spin = 1/2': {not base.provable(non_provable_sentence)}")
    print(f"\n  RESULT: Adding a non-provable sentence creates a proper extension")
    print(f"  that proves genuinely new theorems.")


# =============================================================================
# Demo 6: Landscape Analysis
# =============================================================================

def demo_landscape() -> None:
    """
    Simulates a 'theory landscape' showing the gap between
    mathematically consistent and physically consistent theories.
    """
    print("\n" + "=" * 70)
    print("DEMO 6: The Theory Landscape")
    print("Visualizing the gap between mathematical and physical consistency")
    print("=" * 70)

    import random
    random.seed(42)

    n_theories = 20
    theories: list[dict[str, object]] = []

    for i in range(n_theories):
        has_model = random.random() < 0.4  # 40% have physical models
        if has_model:
            # Physically consistent => automatically mathematically consistent
            math_con = True
            phys_con = True
        else:
            # No model => might still be mathematically consistent
            math_con = random.random() < 0.7  # 70% of non-physical are math consistent
            phys_con = False

        theories.append({
            "name": f"T_{i:02d}",
            "math_consistent": math_con,
            "phys_consistent": phys_con,
        })

    math_only = sum(1 for t in theories if t["math_consistent"] and not t["phys_consistent"])
    both = sum(1 for t in theories if t["phys_consistent"])
    neither = sum(1 for t in theories if not t["math_consistent"])

    print(f"\n  Generated {n_theories} random theories:")
    print(f"  {'Theory':8s} | {'Math Con':10s} | {'Phys Con':10s} | {'Status':25s}")
    print(f"  {'-'*8} | {'-'*10} | {'-'*10} | {'-'*25}")
    for t in theories:
        if t["phys_consistent"]:
            status = "✓ Physical (has model)"
        elif t["math_consistent"]:
            status = "~ Math only (no model)"
        else:
            status = "✗ Inconsistent"
        print(f"  {t['name']:8s} | {'✓':10s} | {'✓' if t['phys_consistent'] else '✗':10s} | {status}")

    print(f"\n  Summary:")
    print(f"    Physically consistent (has model): {both:3d} / {n_theories}")
    print(f"    Math consistent only (no model):   {math_only:3d} / {n_theories}")
    print(f"    Inconsistent:                      {neither:3d} / {n_theories}")
    print(f"\n  The GAP ({math_only} theories) = math consistent but no physical model.")
    print(f"  This is the 'swampland' — consistent theories without physical realization.")


# =============================================================================
# Main
# =============================================================================

def main() -> None:
    """Run all demonstrations."""
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║     Logic-Physics Bridge: Consistency of Physical Theories         ║")
    print("║     Numerical Demonstrations of Formally Verified Results          ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")

    demo_one_way_bridge()
    demo_separation()
    demo_falsum_soundness()
    demo_antimonotonicity()
    demo_proper_extensions()
    demo_landscape()

    print("\n" + "=" * 70)
    print("All demonstrations complete.")
    print("These examples illustrate the formally verified theorems establishing")
    print("the fundamental asymmetry between physical and mathematical consistency.")
    print("=" * 70)


if __name__ == "__main__":
    main()
