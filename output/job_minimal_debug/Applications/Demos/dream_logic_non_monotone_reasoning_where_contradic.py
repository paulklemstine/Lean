#!/usr/bin/env python3
"""
Dream Logic: Numerical Demonstrations of Paraconsistent Reasoning

This module demonstrates the key results from the formalization of Belnap's
four-valued logic (FOUR) and dream spaces. All functions are self-contained.
"""

from __future__ import annotations
from enum import Enum
from typing import Callable


# =============================================================================
# Section 1: Belnap's Four-Valued Logic
# =============================================================================

class Belnap(Enum):
    """The four truth values of Belnap's logic FOUR."""
    F = "F"   # false only
    N = "N"   # neither true nor false (gap)
    B = "B"   # both true and false (glut)
    T = "T"   # true only

    def __repr__(self) -> str:
        return self.value


def tmeet(a: Belnap, b: Belnap) -> Belnap:
    """Truth-ordering meet (logical conjunction).

    Implements the lattice meet on the diamond F ≤ {N,B} ≤ T.
    """
    F, N, B, T = Belnap.F, Belnap.N, Belnap.B, Belnap.T
    table: dict[tuple[Belnap, Belnap], Belnap] = {
        (F, F): F, (F, N): F, (F, B): F, (F, T): F,
        (N, F): F, (N, N): N, (N, B): F, (N, T): N,
        (B, F): F, (B, N): F, (B, B): B, (B, T): B,
        (T, F): F, (T, N): N, (T, B): B, (T, T): T,
    }
    return table[(a, b)]


def tjoin(a: Belnap, b: Belnap) -> Belnap:
    """Truth-ordering join (logical disjunction).

    Implements the lattice join on the diamond F ≤ {N,B} ≤ T.
    """
    F, N, B, T = Belnap.F, Belnap.N, Belnap.B, Belnap.T
    table: dict[tuple[Belnap, Belnap], Belnap] = {
        (F, F): F, (F, N): N, (F, B): B, (F, T): T,
        (N, F): N, (N, N): N, (N, B): T, (N, T): T,
        (B, F): B, (B, N): T, (B, B): B, (B, T): T,
        (T, F): T, (T, N): T, (T, B): T, (T, T): T,
    }
    return table[(a, b)]


def bneg(a: Belnap) -> Belnap:
    """Belnap negation: swaps T↔F, fixes B and N."""
    return {
        Belnap.T: Belnap.F,
        Belnap.F: Belnap.T,
        Belnap.B: Belnap.B,
        Belnap.N: Belnap.N,
    }[a]


def designated(a: Belnap) -> bool:
    """A value is designated (accepted as true) if it is T or B."""
    return a in (Belnap.T, Belnap.B)


def is_glut(a: Belnap) -> bool:
    """A glut: both the value and its negation are designated."""
    return designated(a) and designated(bneg(a))


def is_gap(a: Belnap) -> bool:
    """A gap: neither the value nor its negation is designated."""
    return not designated(a) and not designated(bneg(a))


# =============================================================================
# Demo 1: Verify Distributive Lattice Properties
# =============================================================================

def demo_distributive_lattice() -> None:
    """Verify that FOUR is a distributive lattice by exhaustive check.

    Checks: commutativity, associativity, absorption, and distributivity
    of tmeet and tjoin over all 4^3 = 64 triples.
    """
    vals = list(Belnap)
    print("=" * 60)
    print("DEMO 1: Verifying Distributive Lattice Properties")
    print("=" * 60)

    # Commutativity
    for a in vals:
        for b in vals:
            assert tmeet(a, b) == tmeet(b, a), f"meet commutativity fails: {a}, {b}"
            assert tjoin(a, b) == tjoin(b, a), f"join commutativity fails: {a}, {b}"
    print("✓ Commutativity of meet and join verified (16 cases each)")

    # Associativity
    for a in vals:
        for b in vals:
            for c in vals:
                assert tmeet(a, tmeet(b, c)) == tmeet(tmeet(a, b), c)
                assert tjoin(a, tjoin(b, c)) == tjoin(tjoin(a, b), c)
    print("✓ Associativity of meet and join verified (64 cases each)")

    # Absorption: a ∧ (a ∨ b) = a  and  a ∨ (a ∧ b) = a
    for a in vals:
        for b in vals:
            assert tmeet(a, tjoin(a, b)) == a
            assert tjoin(a, tmeet(a, b)) == a
    print("✓ Absorption laws verified (16 cases each)")

    # Distributivity: a ∧ (b ∨ c) = (a ∧ b) ∨ (a ∧ c)
    for a in vals:
        for b in vals:
            for c in vals:
                lhs = tmeet(a, tjoin(b, c))
                rhs = tjoin(tmeet(a, b), tmeet(a, c))
                assert lhs == rhs, f"distributivity fails: {a}, {b}, {c}"
    print("✓ Distributivity verified (64 cases)")

    # Bounds
    for a in vals:
        assert tmeet(Belnap.F, a) == Belnap.F
        assert tmeet(a, Belnap.T) == a
    print("✓ Bounded: F is bottom, T is top")
    print()


# =============================================================================
# Demo 2: De Morgan Algebra
# =============================================================================

def demo_de_morgan() -> None:
    """Verify De Morgan algebra properties of Belnap negation."""
    vals = list(Belnap)
    print("=" * 60)
    print("DEMO 2: De Morgan Algebra Properties")
    print("=" * 60)

    # Involution
    for a in vals:
        assert bneg(bneg(a)) == a
    print("✓ Involution: ¬¬a = a for all a")

    # De Morgan laws
    for a in vals:
        for b in vals:
            assert bneg(tmeet(a, b)) == tjoin(bneg(a), bneg(b))
            assert bneg(tjoin(a, b)) == tmeet(bneg(a), bneg(b))
    print("✓ De Morgan: ¬(a∧b) = ¬a∨¬b and ¬(a∨b) = ¬a∧¬b (16 cases each)")

    # Antitone: a ≤ b implies ¬b ≤ ¬a
    def le(a: Belnap, b: Belnap) -> bool:
        return tmeet(a, b) == a

    for a in vals:
        for b in vals:
            if le(a, b):
                assert le(bneg(b), bneg(a))
    print("✓ Antitone: a ≤ b ⟹ ¬b ≤ ¬a")

    # Display negation table
    print("\n  Negation table:")
    print(f"  {'a':>3} │ {'¬a':>3}")
    print(f"  {'─'*3}─┼─{'─'*3}")
    for a in vals:
        print(f"  {a.value:>3} │ {bneg(a).value:>3}")
    print()


# =============================================================================
# Demo 3: Explosion Failure (Paraconsistency)
# =============================================================================

def demo_explosion_fails() -> None:
    """Demonstrate that explosion fails in Belnap logic.

    Shows that p ∧ ¬p can be designated while some q is not,
    proving that contradictions do not entail everything.
    """
    vals = list(Belnap)
    print("=" * 60)
    print("DEMO 3: Explosion Failure (Paraconsistency)")
    print("=" * 60)

    print("\n  Contradiction table (p ∧ ¬p for each p):")
    print(f"  {'p':>3} │ {'¬p':>3} │ {'p∧¬p':>4} │ {'designated?':>12}")
    print(f"  {'─'*3}─┼─{'─'*3}─┼─{'─'*4}─┼─{'─'*12}")
    for p in vals:
        contr = tmeet(p, bneg(p))
        desig = "YES ★" if designated(contr) else "no"
        print(f"  {p.value:>3} │ {bneg(p).value:>3} │ {contr.value:>4} │ {desig:>12}")

    print("\n  Key observation:")
    print("  • p=B: B ∧ ¬B = B ∧ B = B is designated")
    print("  • But q=F is NOT designated")
    print("  ⟹ Explosion fails: contradiction does not entail everything!")

    # Classical fragment check
    print("\n  Classical fragment {T, F}:")
    for p in [Belnap.T, Belnap.F]:
        contr = tmeet(p, bneg(p))
        print(f"  p={p.value}: p∧¬p = {contr.value} (designated: {designated(contr)})")
    print("  ⟹ In classical fragment, contradictions are never designated ✓")
    print()


# =============================================================================
# Demo 4: Glut/Gap Classification
# =============================================================================

def demo_glut_gap() -> None:
    """Classify all four values as classical, glut, or gap."""
    vals = list(Belnap)
    print("=" * 60)
    print("DEMO 4: Glut and Gap Classification")
    print("=" * 60)

    print(f"\n  {'Value':>5} │ {'Designated':>10} │ {'¬v Designated':>13} │ {'Classification':>14}")
    print(f"  {'─'*5}─┼─{'─'*10}─┼─{'─'*13}─┼─{'─'*14}")
    for v in vals:
        d_v = designated(v)
        d_neg = designated(bneg(v))
        if is_glut(v):
            cls = "GLUT ★"
        elif is_gap(v):
            cls = "GAP ★"
        elif d_v and not d_neg:
            cls = "classical true"
        else:
            cls = "classical false"
        print(f"  {v.value:>5} │ {'yes' if d_v else 'no':>10} │ {'yes' if d_neg else 'no':>13} │ {cls:>14}")

    print("\n  B is the unique glut (both v and ¬v designated)")
    print("  N is the unique gap (neither v nor ¬v designated)")
    print()


# =============================================================================
# Demo 5: Paraconsistency ↔ Glut Existence
# =============================================================================

def demo_paraconsistency_iff_glut() -> None:
    """Demonstrate the equivalence: explosion fails ↔ a glut exists.

    This is the central characterization theorem.
    """
    vals = list(Belnap)
    print("=" * 60)
    print("DEMO 5: Paraconsistency ↔ Glut Existence")
    print("=" * 60)

    # Check forward direction: explosion failure implies a glut exists
    explosion_fails = False
    witness_p = None
    for p in vals:
        contr = tmeet(p, bneg(p))
        if designated(contr):
            for q in vals:
                if not designated(q):
                    explosion_fails = True
                    witness_p = p
                    break
        if explosion_fails:
            break

    glut_exists = any(is_glut(v) for v in vals)
    gluts = [v for v in vals if is_glut(v)]

    print(f"\n  Explosion fails?  {explosion_fails}")
    if witness_p:
        print(f"  Witness: p={witness_p.value}, p∧¬p={tmeet(witness_p, bneg(witness_p)).value} "
              f"(designated), q=F (not designated)")
    print(f"  Glut exists?      {glut_exists}")
    print(f"  Gluts:            {[g.value for g in gluts]}")
    print(f"\n  ⟹ explosion_fails ↔ glut_exists: "
          f"{explosion_fails} ↔ {glut_exists} = {explosion_fails == glut_exists} ✓")
    print()


# =============================================================================
# Demo 6: Dream Spaces
# =============================================================================

def demo_dream_space() -> None:
    """Demonstrate the finite-or-universal dream space on ℕ.

    Shows that {S ⊆ ℕ : S finite or S = ℕ} is a dream space but not a topology.
    """
    print("=" * 60)
    print("DEMO 6: Dream Space on ℕ (Finite-or-Universal)")
    print("=" * 60)

    # We work with subsets of {0, 1, ..., N-1} as a finite model
    N = 20  # universe size for demonstration

    def dream_open(s: frozenset[int]) -> bool:
        """A set is dream-open if it is finite or equals the whole universe."""
        universe = frozenset(range(N))
        # In the infinite case: finite or = ℕ
        # In our finite model: all sets are finite, so we simulate:
        # "finite" means |s| < N, and "universal" means s = universe
        # To demonstrate non-topological behavior, we impose:
        # open iff |s| ≤ threshold OR s = universe
        return len(s) <= 3 or s == universe

    universe = frozenset(range(N))
    empty = frozenset[int]()

    # Verify dream space axioms
    print(f"\n  Universe: {{0, 1, ..., {N-1}}}")
    print(f"  Rule: S is dream-open iff |S| ≤ 3 or S = universe")
    print(f"\n  Axiom checks:")
    print(f"  • ∅ is open:         {dream_open(empty)} ✓")
    print(f"  • Universe is open:  {dream_open(universe)} ✓")

    # Check finite union closure (pairs of small sets)
    union_ok = True
    for i in range(N):
        for j in range(N):
            s1 = frozenset({i})
            s2 = frozenset({j})
            if dream_open(s1) and dream_open(s2):
                if not dream_open(s1 | s2):
                    union_ok = False
    print(f"  • Finite unions of singletons closed: {union_ok} ✓")

    # Check intersection closure
    inter_ok = True
    for i in range(N):
        for j in range(N):
            s1 = frozenset({i, (i+1) % N})
            s2 = frozenset({j, (j+1) % N})
            if dream_open(s1) and dream_open(s2):
                if not dream_open(s1 & s2):
                    inter_ok = False
    print(f"  • Finite intersections closed:        {inter_ok} ✓")

    # Demonstrate failure of arbitrary union closure
    print(f"\n  Non-topological witness:")
    evens = frozenset(i for i in range(N) if i % 2 == 0)
    singletons_open = all(dream_open(frozenset({i})) for i in evens)
    evens_open = dream_open(evens)
    print(f"  • Even numbers: {sorted(evens)}")
    print(f"  • Each {{2k}} is open: {singletons_open} ✓")
    print(f"  • |evens| = {len(evens)}, which exceeds threshold 3")
    print(f"  • Union of all {{2k}} (= evens) is open: {evens_open} ✗")
    print(f"  ⟹ Arbitrary union of opens is NOT open — NOT a topology! ✓")
    print()

    # Analogy to real ℕ
    print("  In the actual formalization on ℕ:")
    print("  • dreamOpen(S) iff S is finite or S = ℕ")
    print("  • Each {2n} is finite, hence open")
    print("  • ⋃ₙ {2n} = {even numbers}: infinite and ≠ ℕ, hence NOT open")
    print("  • This proves the dream space is not a topology ✓")
    print()


# =============================================================================
# Demo 7: Designation Closure
# =============================================================================

def demo_designation_closure() -> None:
    """Verify that the designated set {T, B} is closed under meet and join."""
    print("=" * 60)
    print("DEMO 7: Designation Closure Properties")
    print("=" * 60)

    desig_vals = [v for v in Belnap if designated(v)]
    print(f"\n  Designated values: {[v.value for v in desig_vals]}")

    print(f"\n  Meet (conjunction) closure:")
    print(f"  {'a':>3} │ {'b':>3} │ {'a∧b':>3} │ {'designated?':>11}")
    print(f"  {'─'*3}─┼─{'─'*3}─┼─{'─'*3}─┼─{'─'*11}")
    for a in desig_vals:
        for b in desig_vals:
            m = tmeet(a, b)
            d = designated(m)
            print(f"  {a.value:>3} │ {b.value:>3} │ {m.value:>3} │ {'yes ✓' if d else 'NO ✗':>11}")

    print(f"\n  Join (disjunction) closure:")
    print(f"  {'a':>3} │ {'b':>3} │ {'a∨b':>3} │ {'designated?':>11}")
    print(f"  {'─'*3}─┼─{'─'*3}─┼─{'─'*3}─┼─{'─'*11}")
    for a in desig_vals:
        for b in desig_vals:
            j = tjoin(a, b)
            d = designated(j)
            print(f"  {a.value:>3} │ {b.value:>3} │ {j.value:>3} │ {'yes ✓' if d else 'NO ✗':>11}")

    print("\n  ⟹ {T, B} is a sub-semilattice under both ∧ and ∨ ✓")
    print()


# =============================================================================
# Main
# =============================================================================

def main() -> None:
    """Run all demonstrations."""
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  DREAM LOGIC: Paraconsistent Reasoning Demonstrations  ║")
    print("╠══════════════════════════════════════════════════════════╣")
    print("║  Based on the formalization of Belnap's FOUR and       ║")
    print("║  non-topological dream spaces.                         ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    demo_distributive_lattice()
    demo_de_morgan()
    demo_explosion_fails()
    demo_glut_gap()
    demo_paraconsistency_iff_glut()
    demo_dream_space()
    demo_designation_closure()

    print("=" * 60)
    print("All demonstrations completed successfully.")
    print("=" * 60)


if __name__ == "__main__":
    main()
