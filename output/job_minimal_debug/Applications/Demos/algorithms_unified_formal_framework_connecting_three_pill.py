#!/usr/bin/env python3
"""
Algorithms for Provability Logic GL

Type-hinted implementations of the core algorithms for GL frame analysis,
Löb's axiom verification, Gödel element detection, and GL validity checking.
"""

from typing import Set, FrozenSet, Dict, List, Tuple, Optional, Callable
from dataclasses import dataclass


@dataclass
class GLFrame:
    """A GL frame: finite transitive irreflexive Kripke frame.

    Attributes:
        worlds: Set of worlds (integers)
        R: Accessibility relation as set of pairs
    """
    worlds: Set[int]
    R: Set[Tuple[int, int]]

    def verify_irreflexive(self) -> bool:
        """Check that no world sees itself."""
        return all((w, w) not in self.R for w in self.worlds)

    def verify_transitive(self) -> bool:
        """Check transitivity of R."""
        return all(
            (w, u) in self.R
            for w in self.worlds for v in self.worlds for u in self.worlds
            if (w, v) in self.R and (v, u) in self.R
        )

    def is_valid(self) -> bool:
        """Check if this is a valid GL frame."""
        return self.verify_irreflexive() and self.verify_transitive()

    def box(self, S: FrozenSet[int]) -> FrozenSet[int]:
        """Compute □S = {w | ∀v, R(w,v) → v ∈ S}."""
        return frozenset(
            w for w in self.worlds
            if all(v in S for v in self.worlds if (w, v) in self.R)
        )

    def diamond(self, S: FrozenSet[int]) -> FrozenSet[int]:
        """Compute ◇S = {w | ∃v, R(w,v) ∧ v ∈ S}."""
        return frozenset(
            w for w in self.worlds
            if any(v in S and (w, v) in self.R for v in self.worlds)
        )

    def complement(self, S: FrozenSet[int]) -> FrozenSet[int]:
        """Compute Sᶜ."""
        return frozenset(self.worlds - S)

    def successors(self, w: int) -> Set[int]:
        """Get all R-successors of w."""
        return {v for v in self.worlds if (w, v) in self.R}

    def is_maximal(self, w: int) -> bool:
        """Check if w is a maximal (dead-end) world."""
        return len(self.successors(w)) == 0

    def maximal_worlds(self) -> Set[int]:
        """Find all maximal worlds."""
        return {w for w in self.worlds if self.is_maximal(w)}

    def rank(self, w: int) -> int:
        """Compute the rank (height) of world w in the well-founded order.

        rank(w) = 0 if w is maximal, otherwise 1 + max(rank(v) for R(w,v)).
        """
        succs = self.successors(w)
        if not succs:
            return 0
        return 1 + max(self.rank(v) for v in succs)


def verify_loeb_axiom(frame: GLFrame) -> bool:
    """Verify Löb's axiom on a GL frame.

    Checks: □((□S)ᶜ ∪ S) ⊆ □S for all S ⊆ W.

    Time complexity: O(2^|W| · |W|²)

    Args:
        frame: A GL frame

    Returns:
        True if Löb's axiom holds for all subsets S
    """
    world_list = sorted(frame.worlds)
    n = len(world_list)

    for bits in range(2 ** n):
        S = frozenset(world_list[i] for i in range(n) if bits & (1 << i))
        box_S = frame.box(S)
        # (□S)ᶜ ∪ S
        loeb_input = (frame.worlds - box_S) | S
        box_loeb = frame.box(frozenset(loeb_input))

        if not box_loeb.issubset(box_S):
            return False
    return True


@dataclass
class ProvabilityLattice:
    """A finite provability lattice.

    Elements are integers 0..n-1. The lattice order and operations
    are given by lookup tables.

    Attributes:
        n: Number of elements
        le: Partial order (le[i][j] = True iff i ≤ j)
        meet: Meet operation (meet[i][j] = i ⊓ j)
        join: Join operation (join[i][j] = i ⊔ j)
        bot: Bottom element (0)
        top: Top element (n-1)
        box: Provability operator
    """
    n: int
    le: List[List[bool]]
    meet: List[List[int]]
    join: List[List[int]]
    bot: int
    top: int
    box: List[int]

    def is_goedel_element(self, g: int) -> bool:
        """Check if g is a Gödel element: g ⊓ □g = ⊥ and g ⊔ □g = ⊤."""
        bg = self.box[g]
        return self.meet[g][bg] == self.bot and self.join[g][bg] == self.top

    def find_goedel_elements(self) -> List[int]:
        """Find all Gödel elements in the lattice."""
        return [g for g in range(self.n) if self.is_goedel_element(g)]

    def is_independent(self, a: int) -> bool:
        """Check if a is independent: a ≠ ⊥, a ≠ ⊤, □a ≠ ⊤."""
        return a != self.bot and a != self.top and self.box[a] != self.top

    def find_independent_elements(self) -> List[int]:
        """Find all independent elements."""
        return [a for a in range(self.n) if self.is_independent(a)]

    def box_iterate(self, a: int, n: int) -> int:
        """Compute □ⁿa."""
        result = a
        for _ in range(n):
            result = self.box[result]
        return result

    def consistency_hierarchy(self, depth: int) -> List[int]:
        """Compute the consistency hierarchy Con₀, Con₁, ..., Conₙ.

        Con₀ = ⊤, Conₙ₊₁ = complement of □(complement of Conₙ)
        Requires complement operation (only works for Boolean lattices).
        """
        # This is a simplified version; full implementation needs complements
        result = [self.top]
        for _ in range(depth):
            result.append(self.box[result[-1]])
        return result


def lattice_from_gl_frame(frame: GLFrame) -> ProvabilityLattice:
    """Construct the provability lattice of upward-closed sets from a GL frame.

    The elements are the upward-closed subsets of the frame, ordered by inclusion.
    The box operator is the GL box on subsets.

    Args:
        frame: A GL frame

    Returns:
        The induced provability lattice
    """
    world_list = sorted(frame.worlds)
    n_worlds = len(world_list)

    # Find all upward-closed subsets
    upward_closed: List[FrozenSet[int]] = []
    for bits in range(2 ** n_worlds):
        S = frozenset(world_list[i] for i in range(n_worlds) if bits & (1 << i))
        is_uc = all(
            v in S
            for w in S for v in frame.worlds
            if (w, v) in frame.R
        )
        if is_uc:
            upward_closed.append(S)

    # Sort by inclusion for a nice ordering
    upward_closed.sort(key=lambda s: (len(s), sorted(s)))
    n = len(upward_closed)
    idx = {s: i for i, s in enumerate(upward_closed)}

    # Build lattice operations
    le = [[upward_closed[i].issubset(upward_closed[j])
           for j in range(n)] for i in range(n)]
    meet = [[idx[upward_closed[i] & upward_closed[j]]
             for j in range(n)] for i in range(n)]
    join = [[idx[upward_closed[i] | upward_closed[j]]
             for j in range(n)] for i in range(n)]

    bot = idx[frozenset()]
    top = idx[frozenset(frame.worlds)]

    # Box operator
    box_list = [idx[frame.box(upward_closed[i])] for i in range(n)]

    return ProvabilityLattice(
        n=n, le=le, meet=meet, join=join,
        bot=bot, top=top, box=box_list
    )


def gl_validity_check(
    n_vars: int,
    formula: Callable[..., FrozenSet[int]],
    max_worlds: int = 8
) -> bool:
    """Check if a modal formula is valid in all GL frames up to a given size.

    This is a brute-force checker exploiting the finite model property of GL.

    Args:
        n_vars: Number of propositional variables
        formula: A function that takes a GLFrame and n_vars valuations
                 (each a FrozenSet[int]) and returns the truth set of the formula
        max_worlds: Maximum number of worlds to check

    Returns:
        True if the formula is valid in all checked GL frames
    """
    for n_worlds in range(1, max_worlds + 1):
        worlds = set(range(n_worlds))
        world_list = list(range(n_worlds))

        # Enumerate all transitive irreflexive relations
        possible_edges = [(i, j) for i in range(n_worlds)
                          for j in range(n_worlds) if i != j]

        for edge_bits in range(2 ** len(possible_edges)):
            R = set()
            for k, (i, j) in enumerate(possible_edges):
                if edge_bits & (1 << k):
                    R.add((i, j))

            frame = GLFrame(worlds, R)
            if not frame.is_valid():
                continue

            # Check all valuations
            for val_bits in range(2 ** (n_vars * n_worlds)):
                valuations = []
                for v in range(n_vars):
                    val = frozenset(
                        w for w in world_list
                        if val_bits & (1 << (v * n_worlds + w))
                    )
                    valuations.append(val)

                truth_set = formula(frame, *valuations)
                if truth_set != frozenset(worlds):
                    return False

    return True


# Example usage
if __name__ == "__main__":
    # Build a GL frame
    frame = GLFrame(
        worlds={0, 1, 2, 3},
        R={(0, 1), (0, 2), (0, 3), (1, 3), (2, 3)}
    )
    print(f"Frame valid: {frame.is_valid()}")
    print(f"Löb's axiom holds: {verify_loeb_axiom(frame)}")

    # Build provability lattice
    lattice = lattice_from_gl_frame(frame)
    print(f"Lattice size: {lattice.n}")
    print(f"Gödel elements: {lattice.find_goedel_elements()}")
    print(f"Independent elements: {lattice.find_independent_elements()}")

    # World ranks
    for w in sorted(frame.worlds):
        print(f"  World {w}: rank={frame.rank(w)}, "
              f"maximal={frame.is_maximal(w)}, "
              f"successors={frame.successors(w)}")
