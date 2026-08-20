"""
Reflective Type Theory and the Modal Fixed-Point Language
=========================================================

Numerical / symbolic demonstrations of the results:

  1. Retraction:      decode(include(A)) == A for every core proposition A,
                      hence the inclusion is injective and Box(p) is outside its image.
  2. Isomorphism:     from_mu(to_mu(A)) == A and to_mu(from_mu(f)) == f,
                      constructor for constructor, compatible with iterated Box.
  3. Finite witness:  in the chain frame 2 -> 1 -> 0 the middle proposition M = {1}
                      satisfies  2 in Box M  but  2 not in Box Box M.
  4. Obstruction:     on every transitive frame, Box P is a subset of Box Box P,
                      so no reflection witness exists (verified exhaustively for n <= 3).
  5. Diagonal:        soundness plus a diagonal sentence forces a true unprovable sentence
                      (verified over all finite truth/provability assignments).
  6. Refutation:      unrestricted fixed points need not have monotone semantics;
                      the operator of  mu X. (X -> false)  is antitone and fixed-point free.

Self-contained: standard library only.  Run with `python demo.py`.
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import product
from typing import Callable, Dict, FrozenSet, Iterable, Iterator, List, Optional, Set, Tuple

# ---------------------------------------------------------------------------
# 1. Syntax: the non-reflective core and the reflective extension
# ---------------------------------------------------------------------------


@dataclass(frozen=True)
class Core:
    """A core (non-reflective) proposition.

    kind in {"atom", "bot", "top", "and", "arr"}.
    """

    kind: str
    atom: Optional[str] = None
    left: Optional["Core"] = None
    right: Optional["Core"] = None

    def __str__(self) -> str:
        if self.kind == "atom":
            return str(self.atom)
        if self.kind == "bot":
            return "⊥"
        if self.kind == "top":
            return "⊤"
        if self.kind == "and":
            return f"({self.left} ∧ {self.right})"
        return f"({self.left} → {self.right})"


@dataclass(frozen=True)
class RProp:
    """A reflective proposition.

    kind in {"atom", "var", "bot", "top", "and", "arr", "box", "mu"}.
    "var" carries a de Bruijn index; "mu" binds the next index.
    """

    kind: str
    atom: Optional[str] = None
    index: Optional[int] = None
    left: Optional["RProp"] = None
    right: Optional["RProp"] = None

    def __str__(self) -> str:
        if self.kind == "atom":
            return str(self.atom)
        if self.kind == "var":
            return f"X{self.index}"
        if self.kind == "bot":
            return "⊥"
        if self.kind == "top":
            return "⊤"
        if self.kind == "and":
            return f"({self.left} ∧ {self.right})"
        if self.kind == "arr":
            return f"({self.left} → {self.right})"
        if self.kind == "box":
            return f"□{self.left}"
        return f"μ.{self.left}"


@dataclass(frozen=True)
class MuFormula:
    """A modal fixed-point formula.

    kind in {"atom", "var", "falsum", "verum", "conj", "impl", "box", "mu"}.
    """

    kind: str
    atom: Optional[str] = None
    index: Optional[int] = None
    left: Optional["MuFormula"] = None
    right: Optional["MuFormula"] = None

    def __str__(self) -> str:
        if self.kind == "atom":
            return str(self.atom)
        if self.kind == "var":
            return f"Z{self.index}"
        if self.kind == "falsum":
            return "f"
        if self.kind == "verum":
            return "t"
        if self.kind == "conj":
            return f"({self.left} ∧ {self.right})"
        if self.kind == "impl":
            return f"({self.left} ⇒ {self.right})"
        if self.kind == "box":
            return f"□{self.left}"
        return f"μ.{self.left}"


# ---------------------------------------------------------------------------
# 2. Inclusion, partial decoding, and the retraction theorem
# ---------------------------------------------------------------------------


def include(a: Core) -> RProp:
    """Canonical inclusion of the non-reflective core into reflective syntax."""
    if a.kind == "atom":
        return RProp("atom", atom=a.atom)
    if a.kind == "bot":
        return RProp("bot")
    if a.kind == "top":
        return RProp("top")
    if a.kind == "and":
        return RProp("and", left=include(a.left), right=include(a.right))
    return RProp("arr", left=include(a.left), right=include(a.right))


def decode(r: RProp) -> Optional[Core]:
    """Partial decoder back to the core.  Fails (None) on var, box, mu."""
    if r.kind == "atom":
        return Core("atom", atom=r.atom)
    if r.kind == "bot":
        return Core("bot")
    if r.kind == "top":
        return Core("top")
    if r.kind in ("and", "arr"):
        left = decode(r.left)
        right = decode(r.right)
        if left is None or right is None:
            return None
        return Core(r.kind, left=left, right=right)
    return None  # var, box, mu


def enumerate_core(size: int, atoms: Tuple[str, ...]) -> Iterator[Core]:
    """All core propositions with exactly `size` constructor nodes."""
    if size <= 0:
        return
    if size == 1:
        for p in atoms:
            yield Core("atom", atom=p)
        yield Core("bot")
        yield Core("top")
        return
    for split in range(1, size):
        for left in enumerate_core(split, atoms):
            for right in enumerate_core(size - split, atoms):
                yield Core("and", left=left, right=right)
                yield Core("arr", left=left, right=right)


# ---------------------------------------------------------------------------
# 3. The grammar isomorphism
# ---------------------------------------------------------------------------

_TO_MU: Dict[str, str] = {
    "atom": "atom",
    "var": "var",
    "bot": "falsum",
    "top": "verum",
    "and": "conj",
    "arr": "impl",
    "box": "box",
    "mu": "mu",
}
_FROM_MU: Dict[str, str] = {v: k for k, v in _TO_MU.items()}


def to_mu(r: RProp) -> MuFormula:
    """Read a reflective proposition as a modal fixed-point formula."""
    kind = _TO_MU[r.kind]
    if r.kind == "atom":
        return MuFormula(kind, atom=r.atom)
    if r.kind == "var":
        return MuFormula(kind, index=r.index)
    if r.kind in ("bot", "top"):
        return MuFormula(kind)
    if r.kind in ("and", "arr"):
        return MuFormula(kind, left=to_mu(r.left), right=to_mu(r.right))
    return MuFormula(kind, left=to_mu(r.left))  # box, mu


def from_mu(f: MuFormula) -> RProp:
    """Read a modal fixed-point formula as a reflective proposition."""
    kind = _FROM_MU[f.kind]
    if f.kind == "atom":
        return RProp(kind, atom=f.atom)
    if f.kind == "var":
        return RProp(kind, index=f.index)
    if f.kind in ("falsum", "verum"):
        return RProp(kind)
    if f.kind in ("conj", "impl"):
        return RProp(kind, left=from_mu(f.left), right=from_mu(f.right))
    return RProp(kind, left=from_mu(f.left))  # box, mu


def enumerate_rprop(size: int, atoms: Tuple[str, ...], max_index: int = 1) -> Iterator[RProp]:
    """All reflective propositions with exactly `size` constructor nodes."""
    if size <= 0:
        return
    if size == 1:
        for p in atoms:
            yield RProp("atom", atom=p)
        for n in range(max_index):
            yield RProp("var", index=n)
        yield RProp("bot")
        yield RProp("top")
        return
    for sub in enumerate_rprop(size - 1, atoms, max_index):
        yield RProp("box", left=sub)
        yield RProp("mu", left=sub)
    for split in range(1, size - 1):
        for left in enumerate_rprop(split, atoms, max_index):
            for right in enumerate_rprop(size - 1 - split, atoms, max_index):
                yield RProp("and", left=left, right=right)
                yield RProp("arr", left=left, right=right)


def iterate_box_rprop(n: int, a: RProp) -> RProp:
    """n-fold reflection on the reflective side."""
    out = a
    for _ in range(n):
        out = RProp("box", left=out)
    return out


def iterate_box_mu(n: int, f: MuFormula) -> MuFormula:
    """n-fold necessity on the modal side."""
    out = f
    for _ in range(n):
        out = MuFormula("box", left=out)
    return out


# ---------------------------------------------------------------------------
# 4. Finite Kripke frames, the box operator, and reflection witnesses
# ---------------------------------------------------------------------------

Frame = Dict[int, FrozenSet[int]]  # world -> set of successors


def box(frame: Frame, prop: FrozenSet[int]) -> FrozenSet[int]:
    """Box P = { w : every successor of w lies in P }.  O(n^2)."""
    return frozenset(w for w, succ in frame.items() if succ <= prop)


def is_transitive(frame: Frame) -> bool:
    """Does a -> b and b -> c imply a -> c?"""
    return all(
        c in frame[a]
        for a in frame
        for b in frame[a]
        for c in frame[b]
    )


def reflection_witnesses(frame: Frame, prop: FrozenSet[int]) -> FrozenSet[int]:
    """Worlds where P is provable but not provably provable."""
    b1 = box(frame, prop)
    b2 = box(frame, b1)
    return frozenset(b1 - b2)


def all_frames(n: int) -> Iterator[Frame]:
    """All 2^(n^2) frames on the world set {0, ..., n-1}."""
    worlds = list(range(n))
    for bits in product([False, True], repeat=n * n):
        frame: Frame = {
            w: frozenset(v for v in worlds if bits[w * n + v]) for w in worlds
        }
        yield frame


def all_props(n: int) -> Iterator[FrozenSet[int]]:
    """All 2^n propositions on {0, ..., n-1}."""
    for bits in product([False, True], repeat=n):
        yield frozenset(w for w in range(n) if bits[w])


CHAIN_FRAME: Frame = {2: frozenset({1}), 1: frozenset({0}), 0: frozenset()}
MIDDLE: FrozenSet[int] = frozenset({1})


# ---------------------------------------------------------------------------
# 5. Abstract diagonal theories
# ---------------------------------------------------------------------------


def diagonal_conclusion(
    sentences: List[str],
    provable: Set[str],
    true: Set[str],
    diagonal: str,
) -> Optional[Tuple[bool, bool]]:
    """Return (True(D), not Prov(D)) if the data form a diagonal theory, else None.

    A diagonal theory requires soundness (Prov subset of True) and the diagonal
    specification  True(D) <-> not Prov(D).
    """
    sound = all(s in true for s in provable)
    spec = (diagonal in true) == (diagonal not in provable)
    if not (sound and spec):
        return None
    return (diagonal in true, diagonal not in provable)


# ---------------------------------------------------------------------------
# 6. Fixed-point semantics: polarity and the monotonicity refutation
# ---------------------------------------------------------------------------


def is_guarded(body: RProp, depth: int = 0, positive: bool = True) -> bool:
    """Does every occurrence of the variable bound at `depth` occur positively?"""
    if body.kind == "var":
        return positive if body.index == depth else True
    if body.kind in ("atom", "bot", "top"):
        return True
    if body.kind == "and":
        return is_guarded(body.left, depth, positive) and is_guarded(
            body.right, depth, positive
        )
    if body.kind == "arr":
        return is_guarded(body.left, depth, not positive) and is_guarded(
            body.right, depth, positive
        )
    if body.kind == "box":
        return is_guarded(body.left, depth, positive)
    return is_guarded(body.left, depth + 1, positive)  # mu


def is_monotone(
    operator: Callable[[FrozenSet[int]], FrozenSet[int]], universe: Iterable[int]
) -> bool:
    """Check monotonicity of a set operator by exhaustive comparison."""
    subsets = list(all_props(len(list(universe))))
    return all(
        operator(s) <= operator(t) for s in subsets for t in subsets if s <= t
    )


def fixed_points(
    operator: Callable[[FrozenSet[int]], FrozenSet[int]], n: int
) -> List[FrozenSet[int]]:
    """All fixed points of a set operator on {0, ..., n-1}."""
    return [s for s in all_props(n) if operator(s) == s]


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------


def demo_retraction() -> None:
    print("=" * 74)
    print("1. RETRACTION AND PROPERNESS OF REFLECTION")
    print("=" * 74)
    atoms = ("p", "q")
    total = 0
    for size in range(1, 5):
        for a in enumerate_core(size, atoms):
            total += 1
            assert decode(include(a)) == a, a
    print(f"  decode(include(A)) == A verified on all {total} core propositions "
          f"of size <= 4 over atoms {atoms}.")

    # Injectivity follows: distinct cores have distinct images.
    images = {str(include(a)) for size in range(1, 5) for a in enumerate_core(size, atoms)}
    print(f"  Distinct images: {len(images)} == {total}  ->  inclusion is injective.")

    boxed_atom = RProp("box", left=RProp("atom", atom="p"))
    print(f"  decode({boxed_atom}) = {decode(boxed_atom)}  ->  □p is outside the image:")
    print("     no core proposition maps to it, so reflection is a proper extension.")
    print()


def demo_isomorphism() -> None:
    print("=" * 74)
    print("2. GRAMMAR ISOMORPHISM WITH THE MODAL FIXED-POINT LANGUAGE")
    print("=" * 74)
    atoms = ("p",)
    count = 0
    for size in range(1, 6):
        for r in enumerate_rprop(size, atoms):
            count += 1
            assert from_mu(to_mu(r)) == r, r
            f = to_mu(r)
            assert to_mu(from_mu(f)) == f, f
    print(f"  Round trips verified on all {count} reflective codes of size <= 5.")

    sample = RProp("mu", left=RProp("box", left=RProp("var", index=0)))
    print(f"  Example:  reflective  {sample}   <->   modal  {to_mu(sample)}")
    print("     i.e.  μX.□X  ('provable all the way down')  is the well-foundedness")
    print("     formula  μZ.□Z  of the modal fixed-point calculus.")

    base = RProp("atom", atom="p")
    for n in range(4):
        lhs = to_mu(iterate_box_rprop(n, base))
        rhs = iterate_box_mu(n, to_mu(base))
        assert lhs == rhs
    print("  Compatibility with iteration verified: τ(□^n A) = □^n τ(A) for n <= 3.")
    print()


def demo_chain_witness() -> None:
    print("=" * 74)
    print("3. THE THREE-WORLD REFLECTION WITNESS")
    print("=" * 74)
    b1 = box(CHAIN_FRAME, MIDDLE)
    b2 = box(CHAIN_FRAME, b1)
    print("  Frame:  2 -> 1 -> 0     Proposition M = {1}")
    print(f"  Box M       = {sorted(b1)}      (world 2 is here: M is provable at 2)")
    print(f"  Box Box M   = {sorted(b2)}      (world 2 is NOT here)")
    print(f"  Witnesses   = {sorted(reflection_witnesses(CHAIN_FRAME, MIDDLE))}")
    assert 2 in b1 and 2 not in b2
    print(f"  Transitive? {is_transitive(CHAIN_FRAME)}   "
          "(2->1 and 1->0 but no 2->0)")
    print("  Conclusion: □M ∧ ¬□□M is inhabited at world 2.")
    print()


def demo_transitive_obstruction() -> None:
    print("=" * 74)
    print("4. TRANSITIVITY IS EXACTLY THE OBSTRUCTION")
    print("=" * 74)
    for n in (1, 2, 3):
        trans_total = 0
        trans_with_witness = 0
        nontrans_with_witness = 0
        for frame in all_frames(n):
            transitive = is_transitive(frame)
            has_witness = any(
                reflection_witnesses(frame, p) for p in all_props(n)
            )
            if transitive:
                trans_total += 1
                if has_witness:
                    trans_with_witness += 1
            elif has_witness:
                nontrans_with_witness += 1
        print(f"  n = {n}:  {2 ** (n * n):5d} frames,  {trans_total:5d} transitive.")
        print(f"          transitive frames admitting a witness: {trans_with_witness}")
        print(f"          non-transitive frames admitting a witness: "
              f"{nontrans_with_witness}")
        assert trans_with_witness == 0
    print("  No transitive frame of size <= 3 admits a reflection witness,")
    print("  matching the theorem: transitivity implies Box P ⊆ Box Box P.")
    print("  Witnesses first appear at n = 2, and there only on cyclic frames such as")
    print("  0 -> 1 -> 0; the three-world chain is the smallest loop-free witness.")
    print()


def demo_diagonal() -> None:
    print("=" * 74)
    print("5. DIAGONAL INCOMPLETENESS")
    print("=" * 74)
    sentences = ["A", "D"]
    checked = 0
    for prov_bits in product([False, True], repeat=len(sentences)):
        for true_bits in product([False, True], repeat=len(sentences)):
            provable = {s for s, b in zip(sentences, prov_bits) if b}
            true = {s for s, b in zip(sentences, true_bits) if b}
            result = diagonal_conclusion(sentences, provable, true, "D")
            if result is None:
                continue
            checked += 1
            assert result == (True, True), (provable, true, result)
    print(f"  Over all {2 ** 4} truth/provability assignments on two sentences,")
    print(f"  {checked} satisfy soundness plus the diagonal specification,")
    print("  and in every one of them D is true and D is not provable.")
    print()


def demo_monotonicity_refutation() -> None:
    print("=" * 74)
    print("6. UNRESTRICTED FIXED POINTS LACK MONOTONE SEMANTICS")
    print("=" * 74)
    body = RProp("arr", left=RProp("var", index=0), right=RProp("bot"))
    guarded = is_guarded(body)
    print(f"  Code:  μX.{body}      guarded (all occurrences positive)? {guarded}")

    universe = [0]  # a one-world frame

    def phi(s: FrozenSet[int]) -> FrozenSet[int]:
        """Interpretation of X -> ⊥ : complement of the valuation of X."""
        return frozenset(set(universe) - set(s))

    print(f"  Operator Φ(S) = W \\ S on W = {universe}:")
    print(f"     Φ(∅) = {sorted(phi(frozenset()))},  Φ(W) = {sorted(phi(frozenset(universe)))}")
    print(f"     monotone? {is_monotone(phi, universe)}")
    print(f"     fixed points: {[sorted(s) for s in fixed_points(phi, len(universe))]}")
    print("  No fixed point exists, so μX.(X → ⊥) has no least-fixed-point meaning.")

    good = RProp("box", left=RProp("var", index=0))
    print(f"  By contrast μX.{good} is guarded? {is_guarded(good)}  -- Box is monotone,")
    print("  so Knaster-Tarski applies and the least fixed point exists.")

    # exhibit the least fixed point of Box on the chain frame
    def box_op(s: FrozenSet[int]) -> FrozenSet[int]:
        return box(CHAIN_FRAME, s)

    current: FrozenSet[int] = frozenset()
    for _ in range(5):
        nxt = box_op(current)
        if nxt == current:
            break
        current = nxt
    print(f"  Least fixed point of Box on the chain 2->1->0: {sorted(current)}")
    print("  (all worlds: every accessibility path terminates, so μX.□X holds everywhere)")
    print()


def main() -> None:
    print()
    print("REFLECTIVE TYPE THEORY AND THE MODAL FIXED-POINT LANGUAGE")
    print("Numerical demonstrations")
    print()
    demo_retraction()
    demo_isomorphism()
    demo_chain_witness()
    demo_transitive_obstruction()
    demo_diagonal()
    demo_monotonicity_refutation()
    print("All demonstrations completed successfully.")


if __name__ == "__main__":
    main()
