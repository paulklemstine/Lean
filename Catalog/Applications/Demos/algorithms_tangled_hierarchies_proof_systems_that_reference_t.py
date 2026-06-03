#!/usr/bin/env python3
"""
Algorithms for Tangled Hierarchies and Provability Logic

Type-hinted implementations of key algorithms for:
1. GL frame construction and validation
2. Modal formula evaluation (model checking)
3. Tangling depth computation
4. Soundness and consistency verification
"""

from __future__ import annotations
from dataclasses import dataclass, field
from enum import Enum, auto
from typing import FrozenSet


class FormulaTag(Enum):
    VAR = auto()
    BOT = auto()
    IMP = auto()
    BOX = auto()


@dataclass(frozen=True)
class Formula:
    """Modal formula in propositional modal logic."""
    tag: FormulaTag
    var_name: str = ""
    left: Formula | None = None
    right: Formula | None = None

    @staticmethod
    def var(name: str) -> Formula:
        return Formula(tag=FormulaTag.VAR, var_name=name)

    @staticmethod
    def bot() -> Formula:
        return Formula(tag=FormulaTag.BOT)

    @staticmethod
    def imp(left: Formula, right: Formula) -> Formula:
        return Formula(tag=FormulaTag.IMP, left=left, right=right)

    @staticmethod
    def box(inner: Formula) -> Formula:
        return Formula(tag=FormulaTag.BOX, left=inner)

    @staticmethod
    def neg(inner: Formula) -> Formula:
        return Formula.imp(inner, Formula.bot())

    @staticmethod
    def top() -> Formula:
        return Formula.neg(Formula.bot())

    @staticmethod
    def con() -> Formula:
        """Consistency formula: ¬□⊥"""
        return Formula.neg(Formula.box(Formula.bot()))

    @staticmethod
    def loeb(phi: Formula) -> Formula:
        """Löb formula: □(□φ → φ) → □φ"""
        return Formula.imp(
            Formula.box(Formula.imp(Formula.box(phi), phi)),
            Formula.box(phi)
        )

    @staticmethod
    def soundness(phi: Formula) -> Formula:
        """Soundness formula for φ: □φ → φ"""
        return Formula.imp(Formula.box(phi), phi)

    def __repr__(self) -> str:
        if self.tag == FormulaTag.VAR:
            return self.var_name
        elif self.tag == FormulaTag.BOT:
            return "⊥"
        elif self.tag == FormulaTag.IMP:
            if self.right and self.right.tag == FormulaTag.BOT:
                return f"¬{self.left}"
            return f"({self.left} → {self.right})"
        elif self.tag == FormulaTag.BOX:
            return f"□{self.left}"
        return "?"


@dataclass
class GLFrame:
    """A GL frame: a finite Kripke frame with transitive, converse well-founded R.

    Attributes:
        worlds: Set of world identifiers
        relation: Set of (w, v) pairs where w R v
    """
    worlds: FrozenSet[int]
    relation: FrozenSet[tuple[int, int]]

    @staticmethod
    def linear(n: int) -> GLFrame:
        """Construct a linear GL frame: 0 < 1 < ... < (n-1)."""
        worlds = frozenset(range(n))
        relation = frozenset((i, j) for i in range(n) for j in range(n) if i < j)
        return GLFrame(worlds=worlds, relation=relation)

    @staticmethod
    def tree(edges: list[tuple[int, int]]) -> GLFrame:
        """Construct a GL frame from edges, computing transitive closure."""
        all_worlds: set[int] = set()
        for u, v in edges:
            all_worlds.add(u)
            all_worlds.add(v)

        # Compute transitive closure
        adj: dict[int, set[int]] = {w: set() for w in all_worlds}
        for u, v in edges:
            adj[u].add(v)

        changed = True
        while changed:
            changed = False
            for u in all_worlds:
                new_succs = set()
                for v in adj[u]:
                    for w in adj[v]:
                        if w not in adj[u]:
                            new_succs.add(w)
                if new_succs:
                    adj[u].update(new_succs)
                    changed = True

        relation = frozenset((u, v) for u in all_worlds for v in adj[u])
        return GLFrame(worlds=frozenset(all_worlds), relation=relation)

    def successors(self, w: int) -> FrozenSet[int]:
        """Get all worlds accessible from w."""
        return frozenset(v for (u, v) in self.relation if u == w)

    def is_transitive(self) -> bool:
        """Check transitivity of R."""
        for u, v in self.relation:
            for w in self.successors(v):
                if (u, w) not in self.relation:
                    return False
        return True

    def is_irreflexive(self) -> bool:
        """Check irreflexivity of R."""
        return all((w, w) not in self.relation for w in self.worlds)

    def is_acyclic(self) -> bool:
        """Check acyclicity (equivalent to converse well-foundedness for finite frames)."""
        visited: set[int] = set()
        in_stack: set[int] = set()

        def dfs(node: int) -> bool:
            if node in in_stack:
                return False  # Cycle found
            if node in visited:
                return True
            visited.add(node)
            in_stack.add(node)
            for succ in self.successors(node):
                if not dfs(succ):
                    return False
            in_stack.discard(node)
            return True

        return all(dfs(w) for w in self.worlds if w not in visited)

    def is_gl_frame(self) -> bool:
        """Verify all GL frame conditions."""
        return self.is_transitive() and self.is_irreflexive() and self.is_acyclic()

    def tangling_depth(self, w: int) -> int:
        """Compute the tangling depth of world w.

        The tangling depth is the length of the longest R-chain from w.
        Uses memoized DFS.
        """
        memo: dict[int, int] = {}

        def depth(v: int) -> int:
            if v in memo:
                return memo[v]
            succs = self.successors(v)
            if not succs:
                memo[v] = 0
            else:
                memo[v] = 1 + max(depth(u) for u in succs)
            return memo[v]

        return depth(w)

    def all_depths(self) -> dict[int, int]:
        """Compute tangling depth for all worlds."""
        return {w: self.tangling_depth(w) for w in sorted(self.worlds)}


@dataclass
class KripkeModel:
    """A Kripke model: a GL frame with a valuation."""
    frame: GLFrame
    valuation: dict[str, FrozenSet[int]] = field(default_factory=dict)

    def forces(self, world: int, formula: Formula) -> bool:
        """Evaluate whether world forces formula.

        Implements the recursive forcing relation:
        - w ⊨ var(p)   iff  V(p)(w)
        - w ⊨ ⊥        never
        - w ⊨ φ → ψ    iff  w ⊭ φ or w ⊨ ψ
        - w ⊨ □φ       iff  ∀v. wRv → v ⊨ φ

        Time complexity: O(|W|^depth(φ)) in the worst case,
        but O(|W|² · |φ|) with memoization.
        """
        if formula.tag == FormulaTag.VAR:
            return world in self.valuation.get(formula.var_name, frozenset())
        elif formula.tag == FormulaTag.BOT:
            return False
        elif formula.tag == FormulaTag.IMP:
            assert formula.left is not None and formula.right is not None
            return (not self.forces(world, formula.left)) or self.forces(
                world, formula.right
            )
        elif formula.tag == FormulaTag.BOX:
            assert formula.left is not None
            return all(
                self.forces(v, formula.left)
                for v in self.frame.successors(world)
            )
        else:
            raise ValueError(f"Unknown formula tag: {formula.tag}")

    def forcing_set(self, formula: Formula) -> FrozenSet[int]:
        """Compute the set of all worlds that force the formula."""
        return frozenset(w for w in self.frame.worlds if self.forces(w, formula))

    def is_valid(self, formula: Formula) -> bool:
        """Check if formula is valid (forced at every world)."""
        return all(self.forces(w, formula) for w in self.frame.worlds)

    def is_world_sound(self, world: int, formulas: list[Formula]) -> bool:
        """Check if world is sound for a list of formulas.

        A world w is sound for φ if w ⊨ □φ → φ.
        """
        return all(
            self.forces(world, Formula.soundness(phi)) for phi in formulas
        )


def verify_loeb_theorem(frame: GLFrame, max_vars: int = 2) -> bool:
    """Verify Löb's theorem on a frame by checking all valuations.

    For each subset of worlds as the valuation of each variable,
    checks that □(□p → p) → □p holds everywhere.

    Returns True if the Löb formula is valid for all valuations.
    """
    worlds_list = sorted(frame.worlds)
    n = len(worlds_list)

    for mask in range(2**n):
        val_set = frozenset(worlds_list[i] for i in range(n) if (mask >> i) & 1)
        model = KripkeModel(frame=frame, valuation={"p": val_set})
        p = Formula.var("p")
        loeb_p = Formula.loeb(p)

        if not model.is_valid(loeb_p):
            return False
    return True


def verify_second_incompleteness(frame: GLFrame) -> dict[int, dict[str, bool]]:
    """Verify the second incompleteness theorem on each world.

    For each world, checks:
    - Is it sound? (□⊥ → ⊥)
    - Can it prove consistency? (□(□⊥ → ⊥))
    - Does it have successors?

    Returns a report for each world.
    """
    model = KripkeModel(frame=frame)
    con_formula = Formula.con()  # □⊥ → ⊥
    box_con = Formula.box(con_formula)  # □(□⊥ → ⊥)

    report: dict[int, dict[str, bool]] = {}
    for w in sorted(frame.worlds):
        is_sound = model.forces(w, con_formula)
        proves_con = model.forces(w, box_con)
        has_succ = bool(frame.successors(w))
        report[w] = {
            "sound": is_sound,
            "proves_consistency": proves_con,
            "has_successors": has_succ,
            "violates_2nd_incompleteness": is_sound and proves_con and has_succ,
        }
    return report


def find_tangling_witness(
    frame: GLFrame, world: int
) -> Formula | None:
    """Find a formula whose soundness the given world cannot prove.

    If the world has successors and is sound, returns □⊥ → ⊥
    (the consistency formula), which cannot be proved by a sound world.

    Returns None if the world has no successors (trivial case).
    """
    if not frame.successors(world):
        return None
    return Formula.imp(Formula.box(Formula.bot()), Formula.bot())


if __name__ == "__main__":
    # Quick test
    frame = GLFrame.linear(5)
    assert frame.is_gl_frame(), "Linear frame should be GL"
    assert verify_loeb_theorem(frame), "Löb should hold on linear GL frame"

    report = verify_second_incompleteness(frame)
    for w, info in report.items():
        assert not info["violates_2nd_incompleteness"], (
            f"World {w} violates 2nd incompleteness!"
        )

    print("All algorithm tests passed ✓")
    print(f"Frame depths: {frame.all_depths()}")
    print(f"2nd incompleteness report: {report}")
