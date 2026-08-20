"""
Min-Plus (Tropical) Digests: Numerical Demonstration of the Collision Geometry
==============================================================================

Self-contained numerical companion to the paper

    "The Recession Geometry of Min-Plus Digests: Exact Collision Cones,
     Hitting-Set Duality, and the Collapse of Tropical Hashing".

Setting.  A key is a matrix A of shape r x k.  A message is a vector m of length
k.  The min-plus digest is

    D(m)_i = min_j ( m_j + A_ij ),      i = 1, ..., r.

The demonstrations below verify, on explicit and randomised instances, the five
groups of results of the paper:

  1. Universal collision cone:   dim span C_A(m) >= k - r, for every A and m.
  2. Exact cone in general position:  C_A(m) = { v >= 0 : v_{p(i)} = 0 },
     of dimension exactly k - r when the minimizers p(i) are unique and distinct.
  3. Hitting-set duality:  S is raisable  iff  every component keeps an active
     coordinate off S  iff  the complement of S is a hitting set of the active
     family.  The maximal coordinate cone has dimension exactly k - tau.
     Transversals (systems of distinct representatives) do NOT govern this.
  4. No bounded-alphabet threshold: a two-letter alphabet already collides, for
     every key with r < k; and r = k admits keys injective on a box.
  5. One-shot inversion: the fiber over y is nonempty iff the canonical
     candidate m*_j = max_i (y_i - A_ij) lies in it; likewise under box
     constraints with the shifted candidate max(m*, L).

No third-party dependencies are used.
"""

from __future__ import annotations

import itertools
import random
from typing import Iterable, Iterator, List, Optional, Sequence, Set, Tuple

Matrix = List[List[float]]
Vector = List[float]


# ----------------------------------------------------------------------------
# Core min-plus primitives
# ----------------------------------------------------------------------------

def digest(A: Sequence[Sequence[float]], m: Sequence[float]) -> Vector:
    """Min-plus digest D(m)_i = min_j (m_j + A_ij)."""
    return [min(m[j] + row[j] for j in range(len(m))) for row in A]


def active_sets(A: Sequence[Sequence[float]], m: Sequence[float],
                tol: float = 1e-12) -> List[Set[int]]:
    """Active (minimizing) coordinate set of each digest component."""
    d = digest(A, m)
    return [
        {j for j in range(len(m)) if abs(m[j] + row[j] - d[i]) <= tol}
        for i, row in enumerate(A)
    ]


def is_collision_support(A: Sequence[Sequence[float]], m: Sequence[float],
                         S: Iterable[int]) -> bool:
    """Exact local criterion: every component keeps an active coordinate off S."""
    Sset = set(S)
    return all(bool(act - Sset) for act in active_sets(A, m))


def hitting_number(A: Sequence[Sequence[float]], m: Sequence[float]) -> int:
    """tau(A, m): least size of a coordinate set meeting every active set."""
    acts = active_sets(A, m)
    k = len(m)
    for size in range(k + 1):
        for H in itertools.combinations(range(k), size):
            Hs = set(H)
            if all(act & Hs for act in acts):
                return size
    return k  # unreachable: the full coordinate set is always a hitting set


def max_cone_dimension(A: Sequence[Sequence[float]], m: Sequence[float]) -> int:
    """Largest |S| over all collision supports S (brute force over subsets)."""
    k = len(m)
    best = 0
    for size in range(k, -1, -1):
        for S in itertools.combinations(range(k), size):
            if is_collision_support(A, m, S):
                return size
        _ = best
    return 0


def span_dimension_of_cone(A: Sequence[Sequence[float]],
                           m: Sequence[float]) -> int:
    """Dimension of the span of the collision cone.

    The cone is a polyhedral cone cut out by sign conditions on coordinates, so
    its span is spanned by the standard basis vectors it contains: e_q lies in
    the cone precisely when {q} is a collision support, and these are linearly
    independent.  (Negative directions never lie in the cone, and every cone
    element is supported on such coordinates.)
    """
    return sum(1 for q in range(len(m)) if is_collision_support(A, m, {q}))


def has_transversal(acts: Sequence[Set[int]]) -> bool:
    """Does the family of active sets admit a system of distinct representatives?"""
    for choice in itertools.product(*[sorted(a) for a in acts]):
        if len(set(choice)) == len(choice):
            return True
    return False


def unused_coordinate(A: Sequence[Sequence[float]],
                      m: Sequence[float]) -> Optional[int]:
    """A coordinate q such that every component has an active coordinate != q."""
    acts = active_sets(A, m)
    for q in range(len(m)):
        if all(act - {q} for act in acts):
            return q
    return None


def canonical_preimage(A: Sequence[Sequence[float]], y: Sequence[float]) -> Vector:
    """m*_j = max_i (y_i - A_ij): the coordinatewise least inequality solution."""
    k = len(A[0])
    return [max(y[i] - A[i][j] for i in range(len(A))) for j in range(k)]


# ----------------------------------------------------------------------------
# Helpers
# ----------------------------------------------------------------------------

def rule(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


def box_messages(k: int, B: int) -> Iterator[Tuple[int, ...]]:
    """All integer messages in {0, 1, ..., B}^k."""
    return itertools.product(range(B + 1), repeat=k)


def random_key(rng: random.Random, r: int, k: int, lo: int = 0,
               hi: int = 5) -> Matrix:
    return [[float(rng.randint(lo, hi)) for _ in range(k)] for _ in range(r)]


# ----------------------------------------------------------------------------
# Demonstration 1: the universal collision cone, dimension >= k - r
# ----------------------------------------------------------------------------

def demo_universal_cone() -> None:
    rule("1. Universal collision cone: dimension at least k - r")
    A: Matrix = [[0, 3, 5, 2], [4, 1, 7, 6], [9, 8, 2, 3]]
    m: Vector = [0, 0, 0, 0]
    k, r = len(m), len(A)
    print(f"key A (r={r}, k={k}):")
    for row in A:
        print("   ", row)
    print("message m       =", m)
    print("digest  D(m)    =", digest(A, m))
    print("active sets     =", [sorted(a) for a in active_sets(A, m)])
    print(f"tau(A,m)        = {hitting_number(A, m)}")
    print(f"max cone dim    = {max_cone_dimension(A, m)}   (theory: k - tau)")
    print(f"universal bound = k - r = {k - r}")

    # Explicit escape: choose one certificate per component and raise the rest.
    certs = {min(a) for a in active_sets(A, m)}
    free = [j for j in range(k) if j not in certs]
    print("certificates    =", sorted(certs), " free coordinates =", free)
    for scale in (1.0, 10.0, 1000.0):
        mp = list(m)
        for j in free:
            mp[j] += scale
        print(f"   D(m + {scale:7.1f} * 1_free) = {digest(A, mp)}"
              f"   equal: {digest(A, mp) == digest(A, m)}")


# ----------------------------------------------------------------------------
# Demonstration 2: exact cone in general position; ties enlarge it
# ----------------------------------------------------------------------------

def demo_exact_cone() -> None:
    rule("2. Exact cone in general position (and what ties do)")

    # General position: unique, pairwise distinct minimizers.
    A: Matrix = [[0.0, 1.0, 1.0], [1.0, 0.0, 1.0]]
    m: Vector = [0.0, 0.0, 0.0]
    k, r = len(m), len(A)
    acts = active_sets(A, m)
    print("generic key rows:", A, " message:", m)
    print("digest:", digest(A, m), " active sets:", [sorted(a) for a in acts])
    print("unique minimizers:", all(len(a) == 1 for a in acts),
          "  distinct:", len({next(iter(a)) for a in acts}) == r)
    print(f"max cone dim = {max_cone_dimension(A, m)}  (theory k - r = {k - r})")

    # Membership test for the exact cone description {v >= 0, v_{p(i)} = 0}.
    p = [next(iter(a)) for a in acts]
    tests: List[Tuple[Vector, str]] = [
        ([0.0, 0.0, 1.0], "free coordinate raised  -> in cone"),
        ([1.0, 0.0, 0.0], "certified coordinate raised -> NOT in cone"),
        ([0.0, 0.0, -1.0], "free coordinate lowered -> NOT in cone"),
    ]
    for v, label in tests:
        predicted = all(x >= 0 for x in v) and all(v[pi] == 0.0 for pi in p)
        observed = all(
            digest(A, [m[j] + s * v[j] for j in range(k)]) == digest(A, m)
            for s in (0.0, 0.5, 1.0, 5.0, 100.0)
        )
        print(f"   v={v}: predicted in cone={predicted}, observed={observed}"
              f"   [{label}]")

    # Ties: the zero key with k = 2, r = 1 has a two-dimensional cone.
    A2: Matrix = [[0.0, 0.0]]
    m2: Vector = [0.0, 0.0]
    print()
    print("tie example: A =", A2, " m =", m2)
    print("   active set:", sorted(active_sets(A2, m2)[0]))
    print(f"   maximal single coordinate box has size"
          f" {max_cone_dimension(A2, m2)}, but each of e_1, e_2 lies in the"
          f" cone,")
    print(f"   so dim span C_A(m) = {span_dimension_of_cone(A2, m2)}"
          f"   >  k - r = {len(m2) - len(A2)}   (strictness is necessary)")


# ----------------------------------------------------------------------------
# Demonstration 3: hitting sets, not transversals
# ----------------------------------------------------------------------------

def demo_hitting_vs_transversal() -> None:
    rule("3. Hitting-set duality; the transversal criterion is false")

    A: Matrix = [[0.0, 1.0], [0.0, 1.0]]
    m: Vector = [0.0, 0.0]
    acts = active_sets(A, m)
    print("key rows:", A, " message:", m, " digest:", digest(A, m))
    print("active sets:", [sorted(a) for a in acts])
    print("has system of distinct representatives:", has_transversal(acts))
    print("is {1} a collision support:", is_collision_support(A, m, {1}))
    print(f"tau = {hitting_number(A, m)},  max cone dim ="
          f" {max_cone_dimension(A, m)}  =  k - tau"
          f"  (while k - r = {len(m) - len(A)})")
    print("=> a one-dimensional cone exists although no transversal does.")

    print()
    print("randomised check of  max cone dim == k - tau  and  >= k - r:")
    rng = random.Random(20260820)
    k = 4
    bad = 0
    strictly_better = 0
    for _ in range(400):
        r = rng.randint(1, 3)
        A_r = random_key(rng, r, k, 0, 5)
        m_r = [float(rng.randint(0, 3)) for _ in range(k)]
        dim = max_cone_dimension(A_r, m_r)
        tau = hitting_number(A_r, m_r)
        if dim != k - tau or dim < k - r:
            bad += 1
        if k - tau > k - r:
            strictly_better += 1
    print(f"   400 random instances (k={k}, r in 1..3): violations = {bad},"
          f"  instances where k - tau beats k - r = {strictly_better}")


# ----------------------------------------------------------------------------
# Demonstration 4: two-letter collisions, and sharpness at r = k
# ----------------------------------------------------------------------------

def demo_two_letter() -> None:
    rule("4. No bounded-alphabet threshold: two letters already collide")

    rng = random.Random(11235)
    print("random keys, binary messages, r < k:")
    for trial in range(5):
        r = rng.randint(1, 3)
        k = r + rng.randint(1, 3)
        A = [[float(rng.randint(-20, 20)) for _ in range(k)] for _ in range(r)]
        a, b = 0.0, 1.0
        m = [a] * k
        q = unused_coordinate(A, m)
        assert q is not None, "r < k guarantees an unused coordinate"
        mp = list(m)
        mp[q] = b
        spread = max(max(row) for row in A) - min(min(row) for row in A)
        ok = digest(A, m) == digest(A, mp)
        print(f"   trial {trial}: r={r} k={k} key spread={spread:5.1f}"
              f"  bumped coord={q}  digests equal: {ok}")
    print("   (the key spread never enters the construction)")

    print()
    print("sharpness at r = k: the key A_ij = 0 if i=j else B+1 is injective"
          " on the box")
    B = 3
    k = 3
    A_inj: Matrix = [[0.0 if i == j else float(B + 1) for j in range(k)]
                     for i in range(k)]
    seen = {}
    collisions = 0
    for m_t in box_messages(k, B):
        d = tuple(digest(A_inj, [float(x) for x in m_t]))
        if d in seen and seen[d] != m_t:
            collisions += 1
        seen[d] = m_t
    print(f"   k=r={k}, B={B}: distinct messages = {(B + 1) ** k},"
          f" distinct digests = {len(seen)}, collisions = {collisions}")
    print("   the digest is the identity on the box, hence injective")


# ----------------------------------------------------------------------------
# Demonstration 5: one-shot inversion, unconstrained and boxed
# ----------------------------------------------------------------------------

def demo_inversion() -> None:
    rule("5. Inversion is a one-shot test at the canonical candidate")

    A: Matrix = [[0.0, 3.0, 5.0], [4.0, 1.0, 7.0]]
    for y in ([0.0, 1.0], [2.0, 2.0], [0.0, 10.0]):
        star = canonical_preimage(A, y)
        d = digest(A, star)
        print(f"   y = {y}: m* = {star}, D(m*) = {d},"
              f" preimage exists: {d == y}")

    print()
    print("brute-force agreement on boxed instances (k=3, B=12):")
    rng = random.Random(4242)
    k, B = 3, 12
    disagreements = 0
    nonempty = 0
    for _ in range(50):
        r = rng.randint(1, 2)
        A_r = random_key(rng, r, k, 0, 5)
        y = [float(rng.randint(-2, 6)) for _ in range(r)]
        brute = any(
            digest(A_r, [float(x) for x in m_t]) == y
            for m_t in box_messages(k, B)
        )
        star = canonical_preimage(A_r, y)
        w = [max(s, 0.0) for s in star]
        one_shot = all(x <= B for x in w) and digest(A_r, w) == y
        nonempty += int(brute)
        disagreements += int(brute != one_shot)
    print(f"   50 instances: nonempty boxed fibers = {nonempty},"
          f" disagreements between brute force and the one-shot test ="
          f" {disagreements}")

    print()
    print("the canonical candidate is the coordinatewise least preimage:")
    A2: Matrix = [[0.0, 2.0, 1.0], [3.0, 0.0, 2.0]]
    y2 = digest(A2, [1.0, 2.0, 4.0])
    star2 = canonical_preimage(A2, y2)
    print(f"   target y = {y2}, m* = {star2}, D(m*) = {digest(A2, star2)}")
    below = [
        m_t for m_t in box_messages(3, 6)
        if digest(A2, [float(x) for x in m_t]) == y2
        and any(float(m_t[j]) < star2[j] - 1e-12 for j in range(3))
    ]
    print(f"   preimages in the box strictly below m* in some coordinate:"
          f" {len(below)}  (theory: 0)")


# ----------------------------------------------------------------------------

def main() -> None:
    print(__doc__)
    demo_universal_cone()
    demo_exact_cone()
    demo_hitting_vs_transversal()
    demo_two_letter()
    demo_inversion()
    rule("All demonstrations completed.")


if __name__ == "__main__":
    main()
