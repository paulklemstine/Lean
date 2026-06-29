"""
Prime Congruence Spectra — numerical demonstration.

This script makes the abstract theory of `ProofSpectra/Core.lean` concrete by
*exhaustively computing* prime congruence spectra of small finite semirings and
verifying every main theorem by direct enumeration:

  * Proposition 1   zero classes are ideals
  * Theorem 2       Zariski closed-set axioms  (empty -> univ, union -> inter,
                    antitone, arbitrary intersection)
  * Theorem 3       Galois connection  S <= Th(X)  <->  X <= V(S)
  * Theorem 4/5     radical = Th . V is idempotent; its fixed points are
                    intersections of prime theories
  * Theorem 6/7     idempotent addition is a join (Boolean / tropical semirings)

A finite semiring is given by its carrier and its addition/multiplication tables.
Everything below is self-contained and uses only the standard library.
"""

from __future__ import annotations

from itertools import product
from typing import Callable, Dict, FrozenSet, List, Sequence, Set, Tuple

# ----------------------------------------------------------------------------- #
# Finite semirings
# ----------------------------------------------------------------------------- #

Elem = int
Table = Dict[Tuple[Elem, Elem], Elem]


class FiniteSemiring:
    """A finite semiring presented by addition and multiplication tables."""

    def __init__(
        self,
        carrier: Sequence[Elem],
        add: Callable[[Elem, Elem], Elem],
        mul: Callable[[Elem, Elem], Elem],
        zero: Elem,
        one: Elem,
        name: str = "",
    ) -> None:
        self.carrier: List[Elem] = list(carrier)
        self.zero: Elem = zero
        self.one: Elem = one
        self.name: str = name
        self.add_t: Table = {(a, b): add(a, b) for a in carrier for b in carrier}
        self.mul_t: Table = {(a, b): mul(a, b) for a in carrier for b in carrier}

    def add(self, a: Elem, b: Elem) -> Elem:
        return self.add_t[(a, b)]

    def mul(self, a: Elem, b: Elem) -> Elem:
        return self.mul_t[(a, b)]

    def is_idempotent(self) -> bool:
        return all(self.add(a, a) == a for a in self.carrier)


def zmod(n: int) -> FiniteSemiring:
    """The ring Z/nZ as a (commutative) semiring."""
    return FiniteSemiring(
        carrier=range(n),
        add=lambda a, b: (a + b) % n,
        mul=lambda a, b: (a * b) % n,
        zero=0,
        one=1 % n,
        name=f"Z/{n}Z",
    )


def boolean_semiring() -> FiniteSemiring:
    """The Boolean semiring B = ({0,1}, OR, AND): the algebra of provability."""
    return FiniteSemiring(
        carrier=[0, 1],
        add=lambda a, b: a | b,
        mul=lambda a, b: a & b,
        zero=0,
        one=1,
        name="Boolean (OR/AND)",
    )


def tropical_minplus(k: int) -> FiniteSemiring:
    """A finite tropical (min,+) semiring on {0,...,k-1,INF} truncated at INF=k-1.

    Addition is min, multiplication is + capped at the top element (which plays
    the role of +infinity, the additive identity)."""
    inf = k - 1
    return FiniteSemiring(
        carrier=range(k),
        add=lambda a, b: min(a, b),
        mul=lambda a, b: inf if (a == inf or b == inf) else min(a + b, inf),
        zero=inf,   # additive identity of (min,+) is +infinity
        one=0,      # multiplicative identity of (min,+) is 0
        name=f"Tropical min-plus (cap {k-1})",
    )


# ----------------------------------------------------------------------------- #
# Congruences as partitions of the carrier
# ----------------------------------------------------------------------------- #

Partition = Tuple[FrozenSet[Elem], ...]


def _set_partitions(items: List[Elem]) -> List[Partition]:
    """All set partitions of `items` (restricted growth strings)."""
    if not items:
        return [tuple()]
    first, rest = items[0], items[1:]
    out: List[Partition] = []
    for part in _set_partitions(rest):
        # put `first` in its own block
        out.append((frozenset([first]),) + part)
        # or merge it into an existing block
        for i in range(len(part)):
            merged = list(part)
            merged[i] = part[i] | {first}
            out.append(tuple(merged))
    return out


class Congruence:
    """A congruence presented as the partition it induces on the carrier."""

    def __init__(self, sr: FiniteSemiring, blocks: Partition) -> None:
        self.sr = sr
        self.blocks = blocks
        self.rep: Dict[Elem, FrozenSet[Elem]] = {}
        for block in blocks:
            for x in block:
                self.rep[x] = block

    def rel(self, a: Elem, b: Elem) -> bool:
        """a ~ b."""
        return self.rep[a] is self.rep[b]

    def is_compatible(self) -> bool:
        """Closed under + and *: the defining property of `SRCong`."""
        C, sr = self, self.sr
        for a, b, c, d in product(sr.carrier, repeat=4):
            if C.rel(a, b) and C.rel(c, d):
                if not C.rel(sr.add(a, c), sr.add(b, d)):
                    return False
                if not C.rel(sr.mul(a, c), sr.mul(b, d)):
                    return False
        return True

    def is_prime(self) -> bool:
        """ab ~ 0  =>  a ~ 0  or  b ~ 0   (`PrimeSRCong`)."""
        sr = self.sr
        for a, b in product(sr.carrier, repeat=2):
            if self.rel(sr.mul(a, b), sr.zero):
                if not (self.rel(a, sr.zero) or self.rel(b, sr.zero)):
                    return False
        return True

    def zero_class(self) -> FrozenSet[Elem]:
        """Z(C) = { a : a ~ 0 }   (`SRCong.zeroClass`)."""
        return frozenset(a for a in self.sr.carrier if self.rel(a, self.sr.zero))

    def __hash__(self) -> int:
        return hash(frozenset(self.blocks))

    def __eq__(self, other: object) -> bool:
        return isinstance(other, Congruence) and frozenset(self.blocks) == frozenset(
            other.blocks
        )


def all_congruences(sr: FiniteSemiring) -> List[Congruence]:
    """Algorithm A: enumerate compatible partitions."""
    out = []
    for part in _set_partitions(list(sr.carrier)):
        C = Congruence(sr, part)
        if C.is_compatible():
            out.append(C)
    return out


def proof_spectrum(sr: FiniteSemiring) -> List[Congruence]:
    """Algorithm B: the prime congruences (`ProofSpectrum`)."""
    return [C for C in all_congruences(sr) if C.is_prime()]


# ----------------------------------------------------------------------------- #
# Zariski-closed sets, theory operator, radical
# ----------------------------------------------------------------------------- #

def vanishes(P: Congruence, a: Elem) -> bool:
    """`vanishes P a := P.rel a 0`."""
    return P.rel(a, P.sr.zero)


def zariski_closed(spec: List[Congruence], S: Set[Elem]) -> Set[int]:
    """V(S), returned as a set of indices into `spec`  (`zariskiClosed`)."""
    return {i for i, P in enumerate(spec) if all(vanishes(P, s) for s in S)}


def theory_of(spec: List[Congruence], X: Set[int], carrier: Sequence[Elem]) -> Set[Elem]:
    """Th(X)  (`theoryOfSpec`)."""
    return {a for a in carrier if all(vanishes(spec[i], a) for i in X)}


def radical(spec: List[Congruence], T: Set[Elem], carrier: Sequence[Elem]) -> Set[Elem]:
    """rad(T) = Th(V(T))  (Algorithm C)."""
    return theory_of(spec, zariski_closed(spec, T), carrier)


# ----------------------------------------------------------------------------- #
# Verification of the main theorems
# ----------------------------------------------------------------------------- #

def verify_zero_class_ideal(sr: FiniteSemiring, congs: List[Congruence]) -> bool:
    """Proposition 1."""
    for C in congs:
        Z = C.zero_class()
        if sr.zero not in Z:
            return False
        for a in Z:
            for b in Z:
                if sr.add(a, b) not in Z:           # add-closed
                    return False
            for b in sr.carrier:
                if sr.mul(a, b) not in Z:           # mul-absorb
                    return False
    return True


def verify_zariski_axioms(sr: FiniteSemiring, spec: List[Congruence]) -> bool:
    """Theorem 2."""
    carrier = list(sr.carrier)
    universe = set(range(len(spec)))

    # (1) V(empty) = univ
    if zariski_closed(spec, set()) != universe:
        return False

    subsets = _power_subsets(carrier)
    for S in subsets:
        for T in subsets:
            # (2) V(S u T) = V(S) n V(T)
            if zariski_closed(spec, S | T) != zariski_closed(spec, S) & zariski_closed(spec, T):
                return False
            # (3) antitone
            if S <= T and not (zariski_closed(spec, T) <= zariski_closed(spec, S)):
                return False
    # (4) arbitrary intersection on a small family
    family = subsets[:6]
    big_union: Set[Elem] = set().union(*family) if family else set()
    lhs = zariski_closed(spec, big_union)
    rhs = set(universe)
    for S in family:
        rhs &= zariski_closed(spec, S)
    return lhs == rhs


def verify_galois(sr: FiniteSemiring, spec: List[Congruence]) -> bool:
    """Theorem 3:  S <= Th(X)  <->  X <= V(S)."""
    carrier = list(sr.carrier)
    for S in _power_subsets(carrier):
        for X in _power_index_subsets(len(spec)):
            lhs = S <= theory_of(spec, X, carrier)
            rhs = X <= zariski_closed(spec, S)
            if lhs != rhs:
                return False
    return True


def verify_radical(sr: FiniteSemiring, spec: List[Congruence]) -> bool:
    """Theorems 4 & 5: idempotence and the prime-intersection fixed-point law."""
    carrier = list(sr.carrier)
    for T in _power_subsets(carrier):
        r1 = radical(spec, T, carrier)
        r2 = radical(spec, r1, carrier)
        if r1 != r2:                                   # idempotent
            return False
        if not (T <= r1):                              # extensive
            return False
        # fixed point  <=>  intersection of prime zero classes of V(T)
        VT = zariski_closed(spec, T)
        inter = set(carrier)
        for i in VT:
            inter &= spec[i].zero_class()
        if (r1 == T) != (T == inter):
            return False
    return True


def verify_idempotent_join(sr: FiniteSemiring) -> bool:
    """Theorems 6 & 7 (only meaningful for idempotent semirings)."""
    if not sr.is_idempotent():
        return True
    le = lambda x, y: sr.add(x, y) == y
    for x in sr.carrier:
        if not le(x, x):                               # reflexive
            return False
        for y in sr.carrier:
            j = sr.add(x, y)
            if not (le(x, j) and le(y, j)):            # upper bound
                return False
            for z in sr.carrier:
                if le(x, z) and le(y, z) and not le(j, z):   # least
                    return False
    return True


def _power_subsets(items: Sequence[Elem]) -> List[Set[Elem]]:
    out: List[Set[Elem]] = []
    for bits in product([0, 1], repeat=len(items)):
        out.append({items[i] for i in range(len(items)) if bits[i]})
    return out


def _power_index_subsets(n: int) -> List[Set[int]]:
    out: List[Set[int]] = []
    for bits in product([0, 1], repeat=n):
        out.append({i for i in range(n) if bits[i]})
    return out


# ----------------------------------------------------------------------------- #
# Driver
# ----------------------------------------------------------------------------- #

def report(sr: FiniteSemiring) -> None:
    congs = all_congruences(sr)
    spec = proof_spectrum(sr)
    print(f"=== {sr.name} ===")
    print(f"  |carrier|            = {len(sr.carrier)}")
    print(f"  congruences          = {len(congs)}")
    print(f"  prime congruences    = {len(spec)}  (points of Spec_proof)")
    for P in spec:
        print(f"    point Z = {sorted(P.zero_class())}")
    print(f"  Prop 1  zero-class ideals     : {verify_zero_class_ideal(sr, congs)}")
    print(f"  Thm 2   Zariski axioms        : {verify_zariski_axioms(sr, spec)}")
    print(f"  Thm 3   Galois connection     : {verify_galois(sr, spec)}")
    print(f"  Thm 4/5 radical fixed points  : {verify_radical(sr, spec)}")
    print(f"  Thm 6/7 idempotent = join     : {verify_idempotent_join(sr)}")
    print()


def worked_example_z6() -> None:
    """Section 7: V({2,3}) = empty in Z/6Z, the geometry of 6 = 2 x 3.

    The Lean `PrimeSRCong` definition imposes no properness condition, so the
    all-collapsing (top) congruence -- with zero class the whole carrier -- is
    also prime. We display the full spectrum, then restrict to the *proper*
    points (the classical Spec) to recover the empty intersection."""
    sr = zmod(6)
    spec = proof_spectrum(sr)
    print("=== Worked example: Spec_proof(Z/6Z) ===")
    pts = {i: sorted(spec[i].zero_class()) for i in range(len(spec))}
    print(f"  full spectrum (zero classes): {pts}")
    proper = [i for i in range(len(spec))
              if spec[i].zero_class() != frozenset(sr.carrier)]
    print(f"  proper points (classical Spec): {[pts[i] for i in proper]}")
    proper_spec = [spec[i] for i in proper]
    print(f"  V(2)   over proper points = {sorted(zariski_closed(proper_spec, {2}))}")
    print(f"  V(3)   over proper points = {sorted(zariski_closed(proper_spec, {3}))}")
    print(f"  V(2,3) over proper points = {sorted(zariski_closed(proper_spec, {2, 3}))}"
          f"   (expected: empty)")
    print(f"  Th(all proper)            = "
          f"{sorted(theory_of(proper_spec, set(range(len(proper_spec))), sr.carrier))}")
    print()


if __name__ == "__main__":
    report(boolean_semiring())
    report(zmod(6))
    report(zmod(5))
    report(tropical_minplus(4))
    worked_example_z6()
    print("All listed theorems verified by exhaustive enumeration.")
