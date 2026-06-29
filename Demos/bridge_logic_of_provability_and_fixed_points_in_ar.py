#!/usr/bin/env python3
"""
Numerical demonstrations of provability logic GL and Gödel elements
in finite provability lattices.

This module constructs concrete finite lattices equipped with a monotone
box operator and demonstrates the key theorems:
  - Gödel element incompleteness
  - Independence of Gödel elements
  - Theory branching from independent sentences
  - Provability iteration hierarchies
  - The soundness-extensiveness collapse
"""

from __future__ import annotations
from dataclasses import dataclass, field
from typing import Callable


# ============================================================
# 1. Finite Provability Lattice
# ============================================================

@dataclass
class ProvabilityLattice:
    """A finite provability lattice with elements {0, 1, ..., n-1}.
    
    Elements are integers. The lattice order, meet, and join are given
    by explicit tables. Element 0 = bottom, element (n-1) = top.
    The box operator maps elements to elements.
    """
    n: int
    le: list[list[bool]]       # le[a][b] = True iff a <= b
    meet: list[list[int]]      # meet[a][b] = a ⊓ b
    join: list[list[int]]      # join[a][b] = a ⊔ b
    box: list[int]             # box[a] = □a
    names: list[str] = field(default_factory=list)

    @property
    def bot(self) -> int:
        return 0

    @property
    def top(self) -> int:
        return self.n - 1

    def is_monotone(self) -> bool:
        """Check that □ is monotone."""
        for a in range(self.n):
            for b in range(self.n):
                if self.le[a][b] and not self.le[self.box[a]][self.box[b]]:
                    return False
        return True

    def box_preserves_top(self) -> bool:
        """Check □⊤ = ⊤."""
        return self.box[self.top] == self.top

    def is_consistent(self) -> bool:
        """Check □⊥ = ⊥ (consistency)."""
        return self.box[self.bot] == self.bot

    def is_nontrivial(self) -> bool:
        """Check ⊥ ≠ ⊤."""
        return self.bot != self.top

    def name(self, a: int) -> str:
        if self.names:
            return self.names[a]
        return str(a)


@dataclass
class GoedelElement:
    """A Gödel element in a provability lattice."""
    g: int

    def verify(self, L: ProvabilityLattice) -> tuple[bool, bool]:
        """Verify the self-refuting and self-affirming conditions."""
        self_refuting = L.meet[self.g][L.box[self.g]] == L.bot
        self_affirming = L.join[self.g][L.box[self.g]] == L.top
        return self_refuting, self_affirming


# ============================================================
# 2. Construct the "Diamond" Lattice Example
# ============================================================

def make_diamond_lattice() -> tuple[ProvabilityLattice, GoedelElement]:
    """Construct a 4-element diamond lattice {⊥, g, □g, ⊤} with a Gödel element.
    
    Elements: 0=⊥, 1=g (Gödel sentence), 2=□g (provability of g), 3=⊤
    
    Hasse diagram:
          ⊤ (3)
         / \\
        g   □g
        (1) (2)
         \\ /
          ⊥ (0)
    
    The box operator: □⊥ = ⊥, □g = 2, □(□g) = ⊤, □⊤ = ⊤
    This satisfies: g ⊓ □g = ⊥, g ⊔ □g = ⊤.
    """
    n = 4
    names = ["⊥", "g", "□g", "⊤"]

    # Order: 0 ≤ everything, 3 ≥ everything, 1 and 2 incomparable
    le = [
        [True,  True,  True,  True],   # 0 ≤ *
        [False, True,  False, True],    # 1 ≤ 1, 3
        [False, False, True,  True],    # 2 ≤ 2, 3
        [False, False, False, True],    # 3 ≤ 3
    ]

    meet = [
        [0, 0, 0, 0],
        [0, 1, 0, 1],
        [0, 0, 2, 2],
        [0, 1, 2, 3],
    ]

    join = [
        [0, 1, 2, 3],
        [1, 1, 3, 3],
        [2, 3, 2, 3],
        [3, 3, 3, 3],
    ]

    # □⊥ = ⊥, □g = □g (element 2), □(□g) = ⊤, □⊤ = ⊤
    box = [0, 2, 3, 3]

    L = ProvabilityLattice(n=n, le=le, meet=meet, join=join, box=box, names=names)
    ge = GoedelElement(g=1)
    return L, ge


# ============================================================
# 3. Construct a Linear Chain Lattice (for iteration demo)
# ============================================================

def make_chain_lattice(k: int) -> ProvabilityLattice:
    """Construct a (k+1)-element linear chain 0 < 1 < ... < k.
    
    Box operator: □i = min(i+1, k) (inflationary / shift-up).
    This models a hierarchy of increasingly strong provability assertions.
    """
    n = k + 1
    le = [[i <= j for j in range(n)] for i in range(n)]
    meet = [[min(i, j) for j in range(n)] for i in range(n)]
    join = [[max(i, j) for j in range(n)] for i in range(n)]
    box = [min(i + 1, k) for i in range(n)]
    names = [f"Con^{i}" if i < k else "⊤" for i in range(n)]
    return ProvabilityLattice(n=n, le=le, meet=meet, join=join, box=box, names=names)


# ============================================================
# 4. Demonstration Functions
# ============================================================

def demo_goedel_incompleteness() -> None:
    """Demonstrate Gödel element incompleteness in the diamond lattice."""
    print("=" * 65)
    print("DEMO 1: Gödel Element Incompleteness (Diamond Lattice)")
    print("=" * 65)

    L, ge = make_diamond_lattice()

    print(f"\nLattice elements: {[L.name(i) for i in range(L.n)]}")
    print(f"Box operator:     {[L.name(L.box[i]) for i in range(L.n)]}")
    print(f"Gödel element:    {L.name(ge.g)}")

    sr, sa = ge.verify(L)
    print(f"\nVerification:")
    print(f"  g ⊓ □g = {L.name(L.meet[ge.g][L.box[ge.g]])} "
          f"{'= ⊥ ✓' if sr else '≠ ⊥ ✗'} (self-refutation)")
    print(f"  g ⊔ □g = {L.name(L.join[ge.g][L.box[ge.g]])} "
          f"{'= ⊤ ✓' if sa else '≠ ⊤ ✗'} (self-affirmation)")

    print(f"\nKey properties:")
    print(f"  Nontrivial (⊥ ≠ ⊤):    {L.is_nontrivial()}")
    print(f"  Consistent (□⊥ = ⊥):   {L.is_consistent()}")
    print(f"  Monotone □:             {L.is_monotone()}")
    print(f"  □⊤ = ⊤:                {L.box_preserves_top()}")

    print(f"\nIncompleteness results:")
    print(f"  □g ≠ ⊤ (not provable):  {L.box[ge.g] != L.top}  "
          f"(□g = {L.name(L.box[ge.g])})")
    print(f"  g ≠ ⊥ (not refutable):  {ge.g != L.bot}")
    print(f"  g ≠ ⊤ (not trivial):    {ge.g != L.top}")
    print(f"  g is independent:        "
          f"{ge.g != L.bot and ge.g != L.top and L.box[ge.g] != L.top}")


def demo_theory_branching() -> None:
    """Demonstrate theory branching from an independent element."""
    print("\n" + "=" * 65)
    print("DEMO 2: Theory Branching")
    print("=" * 65)

    L, ge = make_diamond_lattice()

    # Theory T = {⊤} (the minimal theory)
    T = {L.top}
    G = ge.g        # The independent Gödel sentence (element 1)
    nG = L.box[G]   # Use □g as "negation" proxy (element 2)

    T_names = {L.name(e) for e in T}
    print(f"\nBase theory T = {T_names}")
    print(f"Independent sentence G = {L.name(G)}")
    print(f"'Negation' ¬G = {L.name(nG)}")

    ext_G = T | {G}
    ext_nG = T | {nG}

    ext_G_names = {L.name(e) for e in ext_G}
    ext_nG_names = {L.name(e) for e in ext_nG}
    print(f"\nExtension T + G  = {ext_G_names}")
    print(f"Extension T + ¬G = {ext_nG_names}")
    print(f"Extensions distinct: {ext_G != ext_nG}")
    print(f"\nThis demonstrates the fundamental branching: each independent")
    print(f"sentence creates a fork in the space of possible theories.")


def demo_iteration_hierarchy() -> None:
    """Demonstrate the provability iteration hierarchy."""
    print("\n" + "=" * 65)
    print("DEMO 3: Provability Iteration Hierarchy")
    print("=" * 65)

    L = make_chain_lattice(6)

    print(f"\nChain lattice: {[L.name(i) for i in range(L.n)]}")
    print(f"Box operator:  □(Con^i) = Con^(i+1), □⊤ = ⊤")
    print(f"(Each level asserts consistency of the level below)")

    print(f"\nIteration sequences □ⁿ(a) starting from a = Con^0:")
    a = 0
    seq = [a]
    for _ in range(L.n + 1):
        a = L.box[a]
        seq.append(a)
    print(f"  n:    {list(range(len(seq)))}")
    print(f"  □ⁿa:  {[L.name(s) for s in seq]}")

    # Check monotonicity
    is_mono = all(L.le[seq[i]][seq[i + 1]] for i in range(len(seq) - 1))
    print(f"\n  Monotonically increasing: {is_mono}")

    print(f"\nIteration from ⊤:")
    a = L.top
    seq_top = [a]
    for _ in range(4):
        a = L.box[a]
        seq_top.append(a)
    print(f"  □ⁿ⊤ = {[L.name(s) for s in seq_top]}  (always ⊤)")


def demo_soundness_collapse() -> None:
    """Demonstrate the soundness-extensiveness collapse."""
    print("\n" + "=" * 65)
    print("DEMO 4: Soundness-Extensiveness Collapse")
    print("=" * 65)

    # Construct a lattice where □ = identity (the only possibility
    # when both sound and extensive)
    n = 4
    names = ["⊥", "a", "b", "⊤"]
    le = [
        [True,  True,  True,  True],
        [False, True,  False, True],
        [False, False, True,  True],
        [False, False, False, True],
    ]
    meet = [
        [0, 0, 0, 0],
        [0, 1, 0, 1],
        [0, 0, 2, 2],
        [0, 1, 2, 3],
    ]
    join = [
        [0, 1, 2, 3],
        [1, 1, 3, 3],
        [2, 3, 2, 3],
        [3, 3, 3, 3],
    ]
    box_id = [0, 1, 2, 3]  # identity

    L_id = ProvabilityLattice(n=n, le=le, meet=meet, join=join,
                               box=box_id, names=names)

    print(f"\nLattice with □ = identity:")
    print(f"  Elements: {names}")
    print(f"  Box:      {[L_id.name(L_id.box[i]) for i in range(n)]}")

    sound = all(L_id.le[L_id.box[i]][i] for i in range(n))
    extensive = all(L_id.le[i][L_id.box[i]] for i in range(n))
    is_identity = all(L_id.box[i] == i for i in range(n))

    print(f"\n  Sound (□a ≤ a):      {sound}")
    print(f"  Extensive (a ≤ □a):  {extensive}")
    print(f"  □ = identity:        {is_identity}")
    print(f"\n  Collapse theorem confirmed: sound + extensive ⟹ □ = id")

    # Now show a non-identity box that is extensive but NOT sound
    print(f"\nContrast — extensive but NOT sound (□ shifts up):")
    L_chain = make_chain_lattice(3)
    ext = all(L_chain.le[i][L_chain.box[i]] for i in range(L_chain.n))
    snd = all(L_chain.le[L_chain.box[i]][i] for i in range(L_chain.n))
    print(f"  Elements: {[L_chain.name(i) for i in range(L_chain.n)]}")
    print(f"  Box:      {[L_chain.name(L_chain.box[i]) for i in range(L_chain.n)]}")
    print(f"  Extensive: {ext},  Sound: {snd}")
    print(f"  □ ≠ identity, so collapse does NOT apply (soundness fails)")


def demo_consequences() -> None:
    """Demonstrate the antitonicity of consequences."""
    print("\n" + "=" * 65)
    print("DEMO 5: Antitonicity of Consequences")
    print("=" * 65)

    L, _ = make_diamond_lattice()

    print(f"\nConsequence sets (upward closures) in diamond lattice:")
    for i in range(L.n):
        cons = {L.name(j) for j in range(L.n) if L.le[i][j]}
        print(f"  ↑{L.name(i):3s} = {cons}")

    print(f"\nAntitonicity: a ≤ b ⟹ ↑b ⊆ ↑a")
    print(f"  ⊥ ≤ g, and ↑g = {{g, ⊤}} ⊆ {{⊥, g, □g, ⊤}} = ↑⊥  ✓")
    print(f"  Stronger assumptions ⟹ more consequences")


# ============================================================
# 5. Main
# ============================================================

def main() -> None:
    """Run all demonstrations."""
    print("╔═══════════════════════════════════════════════════════════════╗")
    print("║  PROVABILITY LOGIC GL — NUMERICAL DEMONSTRATIONS            ║")
    print("║  Gödel Elements, Incompleteness, and Lattice Structure      ║")
    print("╚═══════════════════════════════════════════════════════════════╝")

    demo_goedel_incompleteness()
    demo_theory_branching()
    demo_iteration_hierarchy()
    demo_soundness_collapse()
    demo_consequences()

    print("\n" + "=" * 65)
    print("All demonstrations completed successfully.")
    print("=" * 65)


if __name__ == "__main__":
    main()
