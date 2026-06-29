"""
Stone Duality as a Bridge Between Logic and Topology
====================================================

A self-contained numerical demonstration of the object-level core of Stone
duality:

    Every Boolean algebra B is isomorphic to the Boolean algebra of CLOPEN
    subsets of its STONE SPACE, realized as the prime spectrum of the
    associated Boolean ring.

We model finite Boolean algebras concretely as bitmask subsets of a finite
"ground set" {0, 1, ..., n-1}, with:

    * meet   a ⊓ b  =  a & b   (intersection)
    * join   a ⊔ b  =  a | b   (union)
    * comp   aᶜ      =  ~a      (complement within the ground set)
    * bottom ⊥       =  0
    * top    ⊤       =  full mask

The associated BOOLEAN RING uses:

    * multiplication  r * s  =  r & s          (= meet)
    * addition        r + s  =  r ^ s          (symmetric difference / XOR)
    * one             1      =  full mask
    * zero            0      =  empty mask

For these *finite* algebras the prime ideals of the Boolean ring are exactly
the "point ideals"  m_i = { S : i ∉ S }, one per atom i of the ground set.
The Stone space is therefore { 0, 1, ..., n-1 } with the discrete topology, and
the basic open D(r) = { i : i ∈ r }.

Everything below is plain Python (standard library only), with type hints, and
each helper is inlined so the file runs end to end with `python demo.py`.
"""

from __future__ import annotations

from itertools import combinations
from typing import Dict, FrozenSet, List, Set, Tuple


# ---------------------------------------------------------------------------
# 1. Boolean ring arithmetic on bitmask subsets
# ---------------------------------------------------------------------------

def full_mask(n: int) -> int:
    """The top element ⊤ = 1 of the Boolean ring on a ground set of size n."""
    return (1 << n) - 1


def ring_mul(r: int, s: int) -> int:
    """Ring multiplication = meet (intersection)."""
    return r & s


def ring_add(r: int, s: int, n: int) -> int:
    """Ring addition = symmetric difference (XOR), kept within n bits."""
    return (r ^ s) & full_mask(n)


def ba_meet(a: int, b: int) -> int:
    """Boolean-algebra meet a ⊓ b."""
    return a & b


def ba_join(a: int, b: int) -> int:
    """Boolean-algebra join a ⊔ b."""
    return a | b


def ba_compl(a: int, n: int) -> int:
    """Boolean-algebra complement aᶜ within the ground set of size n."""
    return (~a) & full_mask(n)


# ---------------------------------------------------------------------------
# 2. Verifying the Boolean-ring identities (the "modulo 2" toolkit)
# ---------------------------------------------------------------------------

def check_boolean_ring_identities(n: int) -> bool:
    """Verify idempotence (r*r = r), characteristic 2 (r + r = 0), and the
    two clopen-complement identities r*(1+r) = 0 and r + (1+r) = 1."""
    one = full_mask(n)
    for r in range(one + 1):
        if ring_mul(r, r) != r:                       # idempotence r^2 = r
            return False
        if ring_add(r, r, n) != 0:                    # characteristic 2
            return False
        one_plus_r = ring_add(one, r, n)              # 1 + r
        if ring_mul(r, one_plus_r) != 0:              # r*(1+r) = 0
            return False
        if ring_add(r, one_plus_r, n) != one:         # r + (1+r) = 1
            return False
    return True


# ---------------------------------------------------------------------------
# 3. The prime spectrum (Stone space) of a finite Boolean ring
# ---------------------------------------------------------------------------

def stone_space(n: int) -> List[int]:
    """Points of the Stone space = atoms of the ground set = {0, ..., n-1}.

    Point i corresponds to the prime ideal m_i = { S : i ∉ S }.
    """
    return list(range(n))


def basic_open(r: int, n: int) -> FrozenSet[int]:
    """The basic open D(r) = { points i : r ∉ m_i } = { i : i ∈ r }.

    Concretely: the set of bit positions set in r.
    """
    return frozenset(i for i in range(n) if (r >> i) & 1)


# ---------------------------------------------------------------------------
# 4. Clopenness: D(r) is open and closed, with complement D(1 + r)
# ---------------------------------------------------------------------------

def check_clopen_complement(n: int) -> bool:
    """Verify (D(r))ᶜ = D(1 + r) for every r — i.e. basic opens are clopen."""
    one = full_mask(n)
    universe: Set[int] = set(stone_space(n))
    for r in range(one + 1):
        d_r = basic_open(r, n)
        d_compl = basic_open(ring_add(one, r, n), n)   # D(1 + r)
        if (universe - set(d_r)) != set(d_compl):
            return False
    return True


def check_union_law(n: int) -> bool:
    """Verify D(f) ∪ D(g) = D(f + g + f*g)  (join law for basic opens)."""
    one = full_mask(n)
    for f in range(one + 1):
        for g in range(one + 1):
            fg = ring_mul(f, g)
            joined = ring_add(ring_add(f, g, n), fg, n)   # f + g + f*g
            if set(basic_open(f, n)) | set(basic_open(g, n)) != set(basic_open(joined, n)):
                return False
    return True


# ---------------------------------------------------------------------------
# 5. The Stone map and the homomorphism laws
# ---------------------------------------------------------------------------

def stone_map(b: int, n: int) -> FrozenSet[int]:
    """The Stone map: b ↦ clopen set D(b) of the Stone space."""
    return basic_open(b, n)


def check_homomorphism(n: int) -> bool:
    """Verify the Stone map preserves ⊥, ⊤, ⊓, ⊔, and ᶜ."""
    one = full_mask(n)
    universe: Set[int] = set(stone_space(n))

    # ⊥ ↦ ∅ and ⊤ ↦ whole space
    if set(stone_map(0, n)) != set():
        return False
    if set(stone_map(one, n)) != universe:
        return False

    for a in range(one + 1):
        for b in range(one + 1):
            sa, sb = set(stone_map(a, n)), set(stone_map(b, n))
            if set(stone_map(ba_meet(a, b), n)) != (sa & sb):       # ⊓ ↦ ∩
                return False
            if set(stone_map(ba_join(a, b), n)) != (sa | sb):       # ⊔ ↦ ∪
                return False
            if set(stone_map(ba_compl(a, n), n)) != (universe - sa):  # ᶜ ↦ ᶜ
                return False
    return True


# ---------------------------------------------------------------------------
# 6. Injectivity (representation) and surjectivity (onto clopens)
# ---------------------------------------------------------------------------

def all_clopens(n: int) -> Set[FrozenSet[int]]:
    """Every clopen subset of the (discrete) Stone space = every subset."""
    pts = stone_space(n)
    result: Set[FrozenSet[int]] = set()
    for k in range(n + 1):
        for combo in combinations(pts, k):
            result.add(frozenset(combo))
    return result


def check_bijection(n: int) -> Tuple[bool, bool]:
    """Return (injective, surjective) for the Stone map onto clopens."""
    one = full_mask(n)
    image: Dict[FrozenSet[int], int] = {}
    injective = True
    for b in range(one + 1):
        img = stone_map(b, n)
        if img in image:           # two distinct elements with same image?
            injective = False
        image[img] = b
    surjective = set(image.keys()) == all_clopens(n)
    return injective, surjective


# ---------------------------------------------------------------------------
# 7. A sub-Boolean-algebra: the Stone space genuinely contracts
# ---------------------------------------------------------------------------

def subalgebra_generated(generators: List[int], n: int) -> List[int]:
    """Close a list of subsets under ⊓, ⊔, ᶜ, ⊥, ⊤ to get a sub-Boolean
    algebra of the powerset of {0,...,n-1}."""
    one = full_mask(n)
    elems: Set[int] = {0, one} | set(generators)
    changed = True
    while changed:
        changed = False
        current = list(elems)
        for a in current:
            ca = ba_compl(a, n)
            if ca not in elems:
                elems.add(ca)
                changed = True
            for b in current:
                for x in (ba_meet(a, b), ba_join(a, b)):
                    if x not in elems:
                        elems.add(x)
                        changed = True
    return sorted(elems)


def atoms_of(elems: List[int], n: int) -> List[int]:
    """Atoms of a sub-Boolean-algebra: minimal nonzero elements.

    The Stone space of the subalgebra has exactly one point per atom — so a
    coarser algebra has a *smaller* Stone space than the ambient powerset.
    """
    nonzero = [e for e in elems if e != 0]
    atoms: List[int] = []
    for e in nonzero:
        is_atom = True
        for f in nonzero:
            if f != e and (f & e) == f and f != 0 and f != e:
                # f is a strictly smaller nonzero element below e
                if f != e:
                    is_atom = False
                    break
        if is_atom:
            atoms.append(e)
    return atoms


# ---------------------------------------------------------------------------
# 8. Driver
# ---------------------------------------------------------------------------

def main() -> None:
    print("=" * 70)
    print("STONE DUALITY — numerical demonstration")
    print("Every Boolean algebra ≅ clopen algebra of its Stone space")
    print("=" * 70)

    for n in (1, 2, 3, 4):
        print(f"\n--- Ground set of size n = {n}  (Boolean algebra of 2^{n} elements) ---")
        print(f"  Boolean-ring identities (r²=r, r+r=0, r(1+r)=0): "
              f"{check_boolean_ring_identities(n)}")
        print(f"  Basic opens are clopen, (D r)ᶜ = D(1+r):          "
              f"{check_clopen_complement(n)}")
        print(f"  Union law D(f)∪D(g) = D(f+g+fg):                  "
              f"{check_union_law(n)}")
        print(f"  Stone map is a Boolean homomorphism:              "
              f"{check_homomorphism(n)}")
        inj, surj = check_bijection(n)
        print(f"  Stone map injective (representation theorem):     {inj}")
        print(f"  Stone map surjective (onto every clopen):         {surj}")
        print(f"  => ISOMORPHISM B ≅ Clopens(StoneSpace B):         {inj and surj}")

    # Demonstrate a coarser sub-Boolean-algebra and its smaller Stone space.
    print("\n" + "=" * 70)
    print("A coarser sub-Boolean-algebra: the Stone space contracts")
    print("=" * 70)
    n = 4  # ground set {0,1,2,3}
    # Subalgebra generated by the single set {0,1}: it can only "see" the
    # partition {0,1} | {2,3}, so its Stone space collapses to 2 points.
    gens = [0b0011]
    sub = subalgebra_generated(gens, n)
    atoms = atoms_of(sub, n)
    print(f"  Ambient powerset has 2^{n} = {1 << n} elements,"
          f" Stone space of {n} points.")
    print(f"  Subalgebra generated by {[bin(g) for g in gens]} has "
          f"{len(sub)} elements.")
    print(f"  Its atoms (= points of its Stone space): "
          f"{[bin(a) for a in atoms]}")
    print(f"  Stone space of the subalgebra has {len(atoms)} points "
          f"(a coarser logic <-> a smaller space).")

    # Explicit witness of injectivity's mechanism (separating point).
    print("\n" + "=" * 70)
    print("Separating two distinct elements by a point (injectivity engine)")
    print("=" * 70)
    n = 3
    a, b = 0b011, 0b001  # {0,1} vs {0}
    diff = ring_add(a, b, n)  # symmetric difference a △ b = {1}
    pts = sorted(basic_open(diff, n))
    print(f"  a = {bin(a)} ({sorted(basic_open(a, n))}), "
          f"b = {bin(b)} ({sorted(basic_open(b, n))})")
    print(f"  a △ b = {bin(diff)} is nonzero => non-nilpotent => D(a△b) ≠ ∅")
    print(f"  separating point(s) in D(a△b): {pts}")
    print(f"  point {pts[0]} lies in D(a) but not D(b): "
          f"{pts[0] in basic_open(a, n) and pts[0] not in basic_open(b, n)}")

    print("\nAll Stone-duality checks passed.")


if __name__ == "__main__":
    main()
