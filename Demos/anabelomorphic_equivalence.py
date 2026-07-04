"""
Residue-Anabelomorphic Equivalence — numerical demonstrations.

This self-contained script illustrates the main results on the GL(1)
residue torus of a local field:

  * The residue torus of a residue datum (p, f) is the multiplicative
    group of the finite field with p^f elements; it is cyclic of order
    p^f - 1.

  * Rigidity Theorem: two residue tori are isomorphic (equivalently the
    data are residue-anabelomorphic) if and only if p = p' and f = f'.

  * Degree Non-Rigidity Theorem: fixing the residue characteristic p and
    the total field degree e * f does NOT determine the residue torus.

  * L-factor / character count: the number of tame characters of order
    dividing n equals gcd(n, p^f - 1).

No external dependencies; standard library only.
"""

from __future__ import annotations

from dataclasses import dataclass
from math import gcd
from typing import List, Tuple


# --------------------------------------------------------------------------
# Core model
# --------------------------------------------------------------------------
@dataclass(frozen=True)
class ResidueDatum:
    """A residue datum (p, f): residue characteristic p (prime) and
    residue degree f >= 1. Models a local field with residue field of
    order p^f."""

    p: int
    f: int

    def __post_init__(self) -> None:
        if not _is_prime(self.p):
            raise ValueError(f"residue characteristic {self.p} is not prime")
        if self.f < 1:
            raise ValueError(f"residue degree {self.f} must be >= 1")

    def residue_cardinality(self) -> int:
        """q = p^f, the order of the residue field."""
        return self.p ** self.f

    def torus_order(self) -> int:
        """|k^x| = p^f - 1, the order of the residue torus."""
        return self.residue_cardinality() - 1


def _is_prime(n: int) -> bool:
    """Deterministic trial-division primality test."""
    if n < 2:
        return False
    d = 2
    while d * d <= n:
        if n % d == 0:
            return False
        d += 1
    return True


# --------------------------------------------------------------------------
# Result 1: the residue torus is cyclic of order p^f - 1
# --------------------------------------------------------------------------
def torus_order_report(data: List[ResidueDatum]) -> List[Tuple[str, int, int]]:
    """For each datum, return (label, residue cardinality q, torus order q-1)."""
    rows: List[Tuple[str, int, int]] = []
    for d in data:
        label = f"(p={d.p}, f={d.f})"
        rows.append((label, d.residue_cardinality(), d.torus_order()))
    return rows


# --------------------------------------------------------------------------
# Result 2: Rigidity Theorem
# --------------------------------------------------------------------------
def tori_isomorphic(d1: ResidueDatum, d2: ResidueDatum) -> bool:
    """Two finite cyclic groups are isomorphic iff they have equal order.
    Here the torus orders are p^f - 1, so this tests the abstract group
    isomorphism directly."""
    return d1.torus_order() == d2.torus_order()


def anabelomorphic(d1: ResidueDatum, d2: ResidueDatum) -> bool:
    """Residue-anabelomorphic: residue tori isomorphic as abstract groups."""
    return tori_isomorphic(d1, d2)


def rigidity_holds(d1: ResidueDatum, d2: ResidueDatum) -> bool:
    """Verify the Rigidity Theorem for a pair:
    (tori isomorphic)  <=>  (p = p' and f = f')."""
    lhs = anabelomorphic(d1, d2)
    rhs = (d1.p == d2.p) and (d1.f == d2.f)
    return lhs == rhs


# --------------------------------------------------------------------------
# Result 3: Degree Non-Rigidity Theorem
# --------------------------------------------------------------------------
@dataclass(frozen=True)
class LocalDatum:
    """A local extension of Q_p described by (p, e, f): residue
    characteristic p, ramification index e, residue degree f. Total degree
    over Q_p is e * f."""

    p: int
    e: int
    f: int

    def total_degree(self) -> int:
        return self.e * self.f

    def residue_datum(self) -> ResidueDatum:
        return ResidueDatum(self.p, self.f)

    def torus_order(self) -> int:
        return self.residue_datum().torus_order()


def degree_non_rigidity_witness() -> Tuple[LocalDatum, LocalDatum]:
    """The minimal witnesses over Q_2: the unramified quadratic extension
    (e,f)=(1,2) and a totally ramified quadratic extension (e,f)=(2,1).
    Both have total degree 2, but torus orders 3 and 1."""
    unramified = LocalDatum(p=2, e=1, f=2)   # residue datum (2,2), torus order 3
    ramified = LocalDatum(p=2, e=2, f=1)     # residue datum (2,1), torus order 1
    return unramified, ramified


# --------------------------------------------------------------------------
# Result 4: character / L-factor count
# --------------------------------------------------------------------------
def tame_character_count(d: ResidueDatum, n: int) -> int:
    """Number of characters of the residue torus whose order divides n.
    For a cyclic group of order m = p^f - 1 this is gcd(n, m)."""
    return gcd(n, d.torus_order())


# --------------------------------------------------------------------------
# Driver
# --------------------------------------------------------------------------
def main() -> None:
    print("=" * 66)
    print("RESIDUE-ANABELOMORPHIC EQUIVALENCE — NUMERICAL DEMONSTRATIONS")
    print("=" * 66)

    # ---- Result 1 -------------------------------------------------------
    print("\n[1] Residue torus is cyclic of order p^f - 1")
    print("-" * 66)
    sample = [
        ResidueDatum(2, 1), ResidueDatum(2, 2), ResidueDatum(2, 3),
        ResidueDatum(3, 1), ResidueDatum(3, 2), ResidueDatum(5, 2),
        ResidueDatum(7, 1),
    ]
    for label, q, order in torus_order_report(sample):
        print(f"  {label:<14}  residue field order q = {q:<5}  "
              f"torus order q-1 = {order}")

    # ---- Result 2 -------------------------------------------------------
    print("\n[2] Rigidity Theorem: tori isomorphic  <=>  (p,f) equal")
    print("-" * 66)
    pairs = [
        (ResidueDatum(2, 2), ResidueDatum(2, 2)),   # equal -> iso
        (ResidueDatum(2, 2), ResidueDatum(3, 2)),   # diff p
        (ResidueDatum(2, 2), ResidueDatum(2, 3)),   # diff f
        (ResidueDatum(2, 4), ResidueDatum(2, 4)),   # equal -> iso
        (ResidueDatum(3, 2), ResidueDatum(2, 3)),   # 8 vs 7 tori
    ]
    all_ok = True
    for d1, d2 in pairs:
        iso = anabelomorphic(d1, d2)
        eq = (d1.p == d2.p and d1.f == d2.f)
        ok = rigidity_holds(d1, d2)
        all_ok = all_ok and ok
        print(f"  (p={d1.p},f={d1.f}) vs (p={d2.p},f={d2.f}): "
              f"iso={str(iso):<5}  equal-data={str(eq):<5}  "
              f"theorem-holds={ok}")
    print(f"\n  Rigidity Theorem verified on all sample pairs: {all_ok}")

    # A larger random-free exhaustive check
    exhaustive_ok = True
    primes = [2, 3, 5, 7]
    for p1 in primes:
        for f1 in range(1, 5):
            for p2 in primes:
                for f2 in range(1, 5):
                    if not rigidity_holds(ResidueDatum(p1, f1),
                                          ResidueDatum(p2, f2)):
                        exhaustive_ok = False
    print(f"  Exhaustive check over p in {primes}, f in 1..4: "
          f"{exhaustive_ok}")

    # ---- Result 3 -------------------------------------------------------
    print("\n[3] Degree Non-Rigidity: same p, same total degree, "
          "different torus")
    print("-" * 66)
    unram, ram = degree_non_rigidity_witness()
    print(f"  Unramified  : p={unram.p}, (e,f)=({unram.e},{unram.f}), "
          f"[K:Q_p]={unram.total_degree()}, torus order={unram.torus_order()}")
    print(f"  Tot.ramified: p={ram.p}, (e,f)=({ram.e},{ram.f}), "
          f"[K:Q_p]={ram.total_degree()}, torus order={ram.torus_order()}")
    same_p = unram.p == ram.p
    same_deg = unram.total_degree() == ram.total_degree()
    not_iso = not anabelomorphic(unram.residue_datum(), ram.residue_datum())
    print(f"\n  same characteristic p : {same_p}")
    print(f"  same total degree e*f : {same_deg}")
    print(f"  residue tori NOT iso  : {not_iso}")
    print(f"  => degree non-rigidity witnessed: "
          f"{same_p and same_deg and not_iso}")

    # ---- Result 4 -------------------------------------------------------
    print("\n[4] Tame character count = gcd(n, p^f - 1)")
    print("-" * 66)
    d = ResidueDatum(5, 2)   # torus order 24
    print(f"  residue datum (p={d.p}, f={d.f}), torus order = {d.torus_order()}")
    for n in [1, 2, 3, 4, 6, 8, 12, 24, 25]:
        print(f"    characters of order dividing {n:<3}: "
              f"{tame_character_count(d, n)}")

    print("\n" + "=" * 66)
    print("All demonstrations complete.")
    print("=" * 66)


if __name__ == "__main__":
    main()
