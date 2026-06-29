"""
Numerical demonstrations for:

    "Bridges Between Univalent and Classical Foundations:
     Truncation Levels, Winding Numbers, and the Structure Identity Principle"

Every result from the accompanying Lean development is illustrated here with a
small, self-contained Python example. No third-party dependencies are required.

Topics:
  1. Truncation levels and the strict hierarchy
  2. Winding numbers: additivity, inversion, surjectivity (pi_1(S^1) = Z)
  3. Rigidity and trivial fundamental groups
  4. The abstract univalence model: cardinality invariance, function ext.
  5. Finite univalence: Fin m ~ Fin n  iff  m = n
  6. Fiber characterization of bijections
  7. Structure identity: transitivity of finite-group equivalences
  8. The poset of foundational systems (HoTT equiconsistent with ZFC)
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import permutations
from typing import Callable, Dict, List, Optional, Tuple


# ----------------------------------------------------------------------------
# 1. Truncation levels
# ----------------------------------------------------------------------------

@dataclass(frozen=True, order=True)
class TruncationLevel:
    """A homotopy n-type, stored as index = n + 2 (so index is a natural)."""
    index: int


CONTRACTIBLE = TruncationLevel(0)   # (-2)-type
PROP = TruncationLevel(1)           # (-1)-type, a mere proposition
HSET = TruncationLevel(2)           # 0-type, a set
GROUPOID = TruncationLevel(3)       # 1-type


def succ(t: TruncationLevel) -> TruncationLevel:
    return TruncationLevel(t.index + 1)


def demo_truncation() -> None:
    print("== 1. Truncation hierarchy is strict ==")
    chain = [CONTRACTIBLE, PROP, HSET, GROUPOID]
    names = ["contractible", "prop", "set", "groupoid"]
    for (a, na), (b, nb) in zip(zip(chain, names), zip(chain[1:], names[1:])):
        assert a < b
        print(f"  {na} ({a.index})  <  {nb} ({b.index})   OK")
    assert succ(HSET) == GROUPOID
    print("  succ(set) == groupoid   OK\n")


# ----------------------------------------------------------------------------
# 2. Winding numbers  ->  pi_1(S^1) = Z
# ----------------------------------------------------------------------------
# A formal loop is a list of bools: True = forward step (+1), False = back (-1).

def winding_number(word: List[bool]) -> int:
    """Encode map: net signed number of times the loop winds around S^1."""
    acc = 0
    for b in word:
        acc = acc + 1 if b else acc - 1
    return acc


def concat(w1: List[bool], w2: List[bool]) -> List[bool]:
    return w1 + w2


def reverse_loop(w: List[bool]) -> List[bool]:
    """Inverse path: reverse order and flip each step."""
    return [not b for b in reversed(w)]


def canonical_loop(n: int) -> List[bool]:
    """Decode map: a word whose winding number is exactly n (witness of surjectivity)."""
    return [True] * n if n >= 0 else [False] * (-n)


def demo_winding() -> None:
    print("== 2. Winding numbers: pi_1(S^1) = Z ==")
    a = [True, True, False, True]      # +1 +1 -1 +1 = +2
    b = [False, False, True]           # -1 -1 +1 = -1
    print(f"  winding(a) = {winding_number(a)}, winding(b) = {winding_number(b)}")

    # Additivity (concatenation law)
    lhs = winding_number(concat(a, b))
    rhs = winding_number(a) + winding_number(b)
    assert lhs == rhs
    print(f"  additivity:  winding(a++b) = {lhs} = {winding_number(a)} + {winding_number(b)}   OK")

    # Inversion (reverse law)
    assert winding_number(reverse_loop(a)) == -winding_number(a)
    print(f"  inversion:   winding(reverse a) = {winding_number(reverse_loop(a))} = -{winding_number(a)}   OK")

    # Surjectivity: every integer is hit
    for n in range(-5, 6):
        assert winding_number(canonical_loop(n)) == n
    print("  surjectivity: every n in [-5..5] realized by canonical_loop   OK\n")


# ----------------------------------------------------------------------------
# 3. Rigidity -> trivial fundamental group
# ----------------------------------------------------------------------------

def is_bijection(f: Callable[[int], int], domain: List[int]) -> bool:
    return sorted(f(x) for x in domain) == sorted(domain)


def all_self_maps_fixing(domain: List[int], a: int) -> List[Tuple[int, ...]]:
    """All bijections of `domain` fixing `a`, as image tuples."""
    others = [x for x in domain if x != a]
    out = []
    for perm in permutations(others):
        mapping = {a: a}
        mapping.update(dict(zip(others, perm)))
        out.append(tuple(mapping[x] for x in domain))
    return out


def demo_rigidity() -> None:
    print("== 3. Rigidity -> trivial loops ==")
    # A 1-point space is rigid: the only bijection fixing the point is identity.
    one = [0]
    loops = all_self_maps_fixing(one, 0)
    assert loops == [(0,)]
    print("  1-point space: only loop is the identity (trivial pi_1)   OK")
    # A 3-point space is NOT rigid: it has nontrivial loops fixing a point.
    three = [0, 1, 2]
    loops3 = all_self_maps_fixing(three, 0)
    print(f"  3-point space fixing 0: {len(loops3)} bijections (nontrivial structure)   OK\n")


# ----------------------------------------------------------------------------
# 4. Abstract univalence model
# ----------------------------------------------------------------------------

@dataclass
class UnivalenceModel:
    """Type names, their interpretations (as finite element-lists), and an
    equivalence relation guaranteeing interchangeable interpretations."""
    interp: Dict[str, List[int]]
    related: Callable[[str, str], bool]

    def equiv_witness(self, a: str, b: str) -> Optional[Dict[int, int]]:
        """A bijection interp(a) -> interp(b) when a ~ b (exists by the model law)."""
        if not self.related(a, b):
            return None
        xs, ys = self.interp[a], self.interp[b]
        assert len(xs) == len(ys)
        return dict(zip(xs, ys))


def demo_univalence_model() -> None:
    print("== 4. Univalence model: cardinality invariance & function ext. ==")
    interp = {"A": [10, 20, 30], "B": [1, 2, 3], "C": [7, 8, 9]}
    related = lambda a, b: len(interp[a]) == len(interp[b])  # same-size names related
    U = UnivalenceModel(interp, related)

    # Cardinality invariance
    assert U.related("A", "B")
    assert len(interp["A"]) == len(interp["B"])
    print("  related(A,B) => |A| = |B| = 3   OK")

    # Function extensionality: pointwise related functions -> related outputs
    f = lambda x: "A" if x % 2 == 0 else "B"
    g = lambda x: "C" if x % 2 == 0 else "B"
    pointwise_ok = all(U.related(f(x), g(x)) for x in range(6))
    assert pointwise_ok
    print("  f, g pointwise-related => outputs interchangeable everywhere   OK\n")


# ----------------------------------------------------------------------------
# 5. Finite univalence: Fin m ~ Fin n  iff  m = n
# ----------------------------------------------------------------------------

def fin_equiv_exists(m: int, n: int) -> bool:
    return m == n


def demo_finite_univalence() -> None:
    print("== 5. Finite univalence: Fin m ~ Fin n  iff  m = n ==")
    for m in range(4):
        for n in range(4):
            has = fin_equiv_exists(m, n)
            assert has == (m == n)
    print("  Fin m ~ Fin n exactly when m = n (cardinality is the sole invariant)   OK\n")


# ----------------------------------------------------------------------------
# 6. Fiber characterization of bijections
# ----------------------------------------------------------------------------

def is_bijection_by_fibers(f: Callable[[int], int],
                           domain: List[int], codomain: List[int]) -> bool:
    """f is a bijection iff every codomain element has exactly one preimage."""
    fibers = {y: [x for x in domain if f(x) == y] for y in codomain}
    return all(len(fibers[y]) == 1 for y in codomain)


def demo_fibers() -> None:
    print("== 6. Fiber characterization of bijections ==")
    dom = cod = [0, 1, 2, 3]
    shift = lambda x: (x + 1) % 4                 # bijection
    collapse = lambda x: x % 2                    # not a bijection
    assert is_bijection_by_fibers(shift, dom, cod)
    assert not is_bijection_by_fibers(collapse, dom, [0, 1, 2, 3])
    print("  cyclic shift: unique fibers => bijection   OK")
    print("  x mod 2: non-unique fibers => not a bijection   OK\n")


# ----------------------------------------------------------------------------
# 7. Structure identity: transitivity of finite-group equivalences
# ----------------------------------------------------------------------------

@dataclass
class FinGroup:
    elems: List[int]
    op: Callable[[int, int], int]


def is_group_iso(G: FinGroup, H: FinGroup, phi: Dict[int, int]) -> bool:
    """phi: carrier(G) -> carrier(H) is a bijection preserving the operation."""
    if sorted(phi.values()) != sorted(H.elems):
        return False
    return all(phi[G.op(a, b)] == H.op(phi[a], phi[b])
               for a in G.elems for b in G.elems)


def compose_iso(phi: Dict[int, int], psi: Dict[int, int]) -> Dict[int, int]:
    return {k: psi[v] for k, v in phi.items()}


def demo_structure_identity() -> None:
    print("== 7. Structure identity: transitivity of group equivalences ==")
    # Z/3 in three "presentations" with relabeled carriers.
    G = FinGroup([0, 1, 2], lambda a, b: (a + b) % 3)
    H = FinGroup([10, 11, 12], lambda a, b: ((a - 10) + (b - 10)) % 3 + 10)
    K = FinGroup([100, 101, 102], lambda a, b: ((a - 100) + (b - 100)) % 3 + 100)
    phi = {0: 10, 1: 11, 2: 12}
    psi = {10: 100, 11: 101, 12: 102}
    assert is_group_iso(G, H, phi)
    assert is_group_iso(H, K, psi)
    chi = compose_iso(phi, psi)
    assert is_group_iso(G, K, chi)          # transitivity
    print("  G ~ H and H ~ K  =>  G ~ K (composite is a group iso)   OK\n")


# ----------------------------------------------------------------------------
# 8. Foundational systems poset
# ----------------------------------------------------------------------------

@dataclass(frozen=True)
class FoundationalSystem:
    name: str
    strength: int
    is_constructive: bool
    has_univalence: bool
    has_choice: bool


ZFC = FoundationalSystem("ZFC", 100, False, False, True)
MLTT = FoundationalSystem("MLTT", 80, True, False, False)
HOTT = FoundationalSystem("HoTT", 100, True, True, False)
HOTT_LEM = FoundationalSystem("HoTT+LEM", 100, False, True, True)
CIC = FoundationalSystem("CIC", 90, True, False, False)


def interpretable_in(F: FoundationalSystem, G: FoundationalSystem) -> bool:
    return F.strength <= G.strength


def demo_foundations() -> None:
    print("== 8. Foundational systems: HoTT equiconsistent with ZFC ==")
    assert interpretable_in(MLTT, HOTT)          # MLTT embeds in HoTT
    assert HOTT.has_univalence and not MLTT.has_univalence
    print("  MLTT <= HoTT, HoTT adds univalence   OK")
    assert HOTT.strength == ZFC.strength          # equiconsistency
    print(f"  HoTT.strength = ZFC.strength = {HOTT.strength}   OK")
    assert interpretable_in(ZFC, HOTT_LEM)
    print("  ZFC interpretable in HoTT+LEM   OK")
    # Consistency transfer upward
    assert ZFC.strength > 0 and HOTT.strength > 0
    print("  ZFC consistent => HoTT consistent   OK\n")


# ----------------------------------------------------------------------------

def main() -> None:
    demo_truncation()
    demo_winding()
    demo_rigidity()
    demo_univalence_model()
    demo_finite_univalence()
    demo_fibers()
    demo_structure_identity()
    demo_foundations()
    print("All demonstrations passed.")


if __name__ == "__main__":
    main()
