"""
The magma monoid Bin(X) as a transformation semigroup: numerical demonstrations.
================================================================================

For a finite set X = {0, 1, ..., n-1}, a binary operation is a table
f : X x X -> X.  The magma monoid Bin(X) is the set of all n^(n^2) such tables
under the associative product

        (f * g)(a, b) = g( f(a, b), f(b, a) ),

with identity the left projection l(a, b) = a.  The whole theory rests on the
*unfolding*

        fhat(a, b) = ( f(a, b), f(b, a) ),

which turns the product into composition:  (f*g)^ = ghat o fhat.  Unfoldings are
exactly the self-maps of X x X commuting with reversal sigma(a, b) = (b, a).

This script verifies, by exhaustive computation:

  1. associativity of *, the identity l, the central involution r;
  2. the representation theorem  (f*g)^ = ghat o fhat  and the bijection between
     operations and reversal-equivariant maps of X x X;
  3. the regularity criterion:  f is regular  <=>  every commutative value
     f(x,y) = f(y,x) is attained on the diagonal as some f(z,z);
     for n = 2 exactly 14 of 16 operations are regular (XOR and XNOR fail);
  4. explicit construction of pseudo-inverses via equivariant selection;
  5. failure of closure: two regular operations whose product is XOR;
  6. Green's relations L, R, H, D and the fact that regularity is a D-invariant;
  7. the centre  Z(Bin(X)) = {l, r}  for |X| >= 2;
  8. the unit group order  n! * 2^m * m!  with m = n(n-1)/2  (4 for n = 2,
     288 for n = 3), checked against brute force for n = 2 and n = 3;
  9. tropical facts: {min, max} is a left-zero band generating {l, min, max};
     tropical multiplication a + b is regular iff the value monoid is
     2-divisible (regular over Q/R, not over Z).

Pure standard library; no dependencies.
"""

from __future__ import annotations

from fractions import Fraction
from itertools import product as iterprod
from math import factorial
from typing import Dict, FrozenSet, Iterable, List, Set, Tuple

Op = Tuple[int, ...]  # flattened n x n table: f(a, b) = table[a * n + b]
Pair = Tuple[int, int]


# ---------------------------------------------------------------------------
# 1.  The monoid operation
# ---------------------------------------------------------------------------

def apply_op(f: Op, n: int, a: int, b: int) -> int:
    """Evaluate the binary operation f at (a, b)."""
    return f[a * n + b]


def magma_product(f: Op, g: Op, n: int) -> Op:
    """(f * g)(a, b) = g(f(a, b), f(b, a))."""
    return tuple(
        apply_op(g, n, apply_op(f, n, a, b), apply_op(f, n, b, a))
        for a in range(n)
        for b in range(n)
    )


def left_projection(n: int) -> Op:
    """The identity of the magma monoid: l(a, b) = a."""
    return tuple(a for a in range(n) for _ in range(n))


def right_projection(n: int) -> Op:
    """The central involution: r(a, b) = b."""
    return tuple(b for _ in range(n) for b in range(n))


def all_ops(n: int) -> List[Op]:
    """All n^(n^2) binary operations on an n-element set."""
    return [tuple(t) for t in iterprod(range(n), repeat=n * n)]


# ---------------------------------------------------------------------------
# 2.  Unfolding: the transformation picture
# ---------------------------------------------------------------------------

def unfold(f: Op, n: int) -> Dict[Pair, Pair]:
    """fhat(a, b) = (f(a, b), f(b, a)), a self-map of X x X."""
    return {(a, b): (apply_op(f, n, a, b), apply_op(f, n, b, a))
            for a in range(n) for b in range(n)}


def is_pairmorph(T: Dict[Pair, Pair]) -> bool:
    """Does T commute with reversal sigma(a, b) = (b, a)?"""
    return all(T[(b, a)] == (T[(a, b)][1], T[(a, b)][0]) for (a, b) in T)


def fold(T: Dict[Pair, Pair], n: int) -> Op:
    """Recover the operation from a reversal-equivariant map: f(a,b) = pi_1 T(a,b)."""
    return tuple(T[(a, b)][0] for a in range(n) for b in range(n))


def pair_image(f: Op, n: int) -> FrozenSet[Pair]:
    """Im(f) = fhat(X x X)."""
    return frozenset(unfold(f, n).values())


def diagonal_image(f: Op, n: int) -> FrozenSet[Pair]:
    """Diag(f) = {(f(z,z), f(z,z))}."""
    return frozenset((apply_op(f, n, z, z), apply_op(f, n, z, z)) for z in range(n))


def commutative_image(f: Op, n: int) -> FrozenSet[Pair]:
    """Com(f) = Im(f) intersected with the diagonal of X x X."""
    return frozenset(p for p in pair_image(f, n) if p[0] == p[1])


def kernel(f: Op, n: int) -> FrozenSet[FrozenSet[Pair]]:
    """The kernel partition of X x X induced by fhat."""
    T = unfold(f, n)
    blocks: Dict[Pair, Set[Pair]] = {}
    for p, q in T.items():
        blocks.setdefault(q, set()).add(p)
    return frozenset(frozenset(b) for b in blocks.values())


# ---------------------------------------------------------------------------
# 3.  Regularity
# ---------------------------------------------------------------------------

def is_regular_criterion(f: Op, n: int) -> bool:
    """f regular <=> every commutative value is attained on the diagonal."""
    diag_values = {apply_op(f, n, z, z) for z in range(n)}
    for a in range(n):
        for b in range(n):
            if apply_op(f, n, a, b) == apply_op(f, n, b, a):
                if apply_op(f, n, a, b) not in diag_values:
                    return False
    return True


def is_regular_bruteforce(f: Op, n: int, ops: List[Op]) -> bool:
    """f regular <=> exists g with f * g * f = f  (exhaustive search)."""
    return any(magma_product(magma_product(f, g, n), f, n) == f for g in ops)


def pseudo_inverse(f: Op, n: int) -> Op:
    """
    Construct a pseudo-inverse of a regular f by equivariant selection:
    diagonal image points get diagonal preimages, off-diagonal orbits get one
    chosen preimage transported across reversal, everything else is fixed.
    """
    if not is_regular_criterion(f, n):
        raise ValueError("operation is not regular")
    T = unfold(f, n)
    U: Dict[Pair, Pair] = {(a, b): (a, b) for a in range(n) for b in range(n)}
    handled: Set[Pair] = set()
    for (a, b), q in T.items():
        if q in handled:
            continue
        if q[0] == q[1]:                      # diagonal image point
            z = next(z for z in range(n) if apply_op(f, n, z, z) == q[0])
            U[q] = (z, z)
            handled.add(q)
        else:                                  # off-diagonal reversal orbit
            U[q] = (a, b)
            U[(q[1], q[0])] = (b, a)
            handled.add(q)
            handled.add((q[1], q[0]))
    return fold(U, n)


# ---------------------------------------------------------------------------
# 4.  Green's relations
# ---------------------------------------------------------------------------

def green_L(f: Op, g: Op, n: int) -> bool:
    """L: same pair image AND same diagonal image."""
    return (pair_image(f, n) == pair_image(g, n)
            and diagonal_image(f, n) == diagonal_image(g, n))


def green_R(f: Op, g: Op, n: int) -> bool:
    """R: same kernel."""
    return kernel(f, n) == kernel(g, n)


def green_H(f: Op, g: Op, n: int) -> bool:
    return green_L(f, g, n) and green_R(f, g, n)


def green_D(f: Op, g: Op, n: int, ops: List[Op]) -> bool:
    """D = L o R: exists h with f L h and h R g."""
    return any(green_L(f, h, n) and green_R(h, g, n) for h in ops)


def classes(ops: List[Op], n: int, rel) -> List[List[Op]]:
    """Group operations into equivalence classes of the given relation."""
    out: List[List[Op]] = []
    for f in ops:
        for cls in out:
            if rel(f, cls[0], n):
                cls.append(f)
                break
        else:
            out.append([f])
    return out


# ---------------------------------------------------------------------------
# 5.  Centre and units
# ---------------------------------------------------------------------------

def is_central(f: Op, n: int, ops: List[Op]) -> bool:
    return all(magma_product(f, g, n) == magma_product(g, f, n) for g in ops)


def is_unit(f: Op, n: int) -> bool:
    """f is invertible <=> fhat is a bijection of X x X."""
    return len(set(unfold(f, n).values())) == n * n


def predicted_unit_count(n: int) -> int:
    """n! * 2^m * m! with m = n(n-1)/2."""
    m = n * (n - 1) // 2
    return factorial(n) * 2 ** m * factorial(m)


def count_units_bruteforce(n: int) -> int:
    """
    Count the units of Bin(X) directly: a unit is exactly a permutation of
    X x X commuting with reversal, so enumerate all (n^2)! permutations of
    X x X and keep the reversal-equivariant ones.  Feasible up to n = 3.
    """
    from itertools import permutations
    pts = [(a, b) for a in range(n) for b in range(n)]
    count = 0
    for images in permutations(pts):
        T = dict(zip(pts, images))
        if is_pairmorph(T):
            count += 1
    return count


# ---------------------------------------------------------------------------
# 6.  Tropical operations
# ---------------------------------------------------------------------------

def min_op(n: int) -> Op:
    return tuple(min(a, b) for a in range(n) for b in range(n))


def max_op(n: int) -> Op:
    return tuple(max(a, b) for a in range(n) for b in range(n))


def tropical_mul_regular_int(bound: int = 50) -> Tuple[bool, List[int]]:
    """
    Over the integers, tropical multiplication is regular iff every integer is
    a double.  Returns (regular?, list of witnesses that fail).
    """
    doubles = {2 * z for z in range(-2 * bound, 2 * bound + 1)}
    failures = [v for v in range(-bound, bound + 1) if v not in doubles]
    return (not failures), failures[:5]


def tropical_mul_regular_rational(samples: Iterable[Fraction]) -> bool:
    """
    Over the rationals every value r is a double, namely r = r/2 + r/2, so
    tropical multiplication is regular.  Verified on a sample.
    """
    return all(r == r / 2 + r / 2 for r in samples)


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def show(title: str) -> None:
    print("\n" + "=" * 74)
    print(title)
    print("=" * 74)


def demo_basics(n: int = 2) -> None:
    show(f"1. Monoid axioms and the two projections  (n = {n})")
    ops = all_ops(n)
    l, r = left_projection(n), right_projection(n)
    assoc = all(
        magma_product(magma_product(f, g, n), h, n)
        == magma_product(f, magma_product(g, h, n), n)
        for f in ops for g in ops for h in ops
    )
    print(f"|Bin(X)| = n^(n^2) = {len(ops)}   (expected {n ** (n * n)})")
    print(f"associativity of *              : {assoc}")
    print(f"l is a two-sided identity       : "
          f"{all(magma_product(l, f, n) == f and magma_product(f, l, n) == f for f in ops)}")
    print(f"r is central, r * r = l         : "
          f"{all(magma_product(r, f, n) == magma_product(f, r, n) for f in ops)}, "
          f"{magma_product(r, r, n) == l}")


def demo_representation(n: int = 3) -> None:
    show(f"2. Representation theorem: (f*g)^ = ghat o fhat  (n = {n}, sampled)")
    import random
    random.seed(20260811)
    ok_anti, ok_equiv, ok_fold = True, True, True
    for _ in range(3000):
        f = tuple(random.randrange(n) for _ in range(n * n))
        g = tuple(random.randrange(n) for _ in range(n * n))
        Tf, Tg = unfold(f, n), unfold(g, n)
        Tfg = unfold(magma_product(f, g, n), n)
        ok_anti &= all(Tfg[p] == Tg[Tf[p]] for p in Tf)
        ok_equiv &= is_pairmorph(Tf)
        ok_fold &= fold(Tf, n) == f
    print(f"unfolding is anti-multiplicative : {ok_anti}")
    print(f"every unfolding commutes with reversal : {ok_equiv}")
    print(f"folding recovers the operation   : {ok_fold}")
    # every reversal-equivariant map arises as an unfolding
    pts = [(a, b) for a in range(2) for b in range(2)]
    count = 0
    for vals in iterprod(pts, repeat=4):
        T = dict(zip(pts, vals))
        if is_pairmorph(T):
            count += 1
            assert unfold(fold(T, 2), 2) == T
    print(f"n = 2: reversal-equivariant maps of X x X = {count} = |Bin(X)| = 16")


def demo_regularity(n: int = 2) -> None:
    show(f"3. The regularity criterion and the census for n = {n}")
    ops = all_ops(n)
    crit = [f for f in ops if is_regular_criterion(f, n)]
    brute = [f for f in ops if is_regular_bruteforce(f, n, ops)]
    print(f"regular by criterion : {len(crit)} of {len(ops)}")
    print(f"regular by brute force: {len(brute)}   (agree: {set(crit) == set(brute)})")
    bad = [f for f in ops if not is_regular_criterion(f, n)]
    names = {(0, 1, 1, 0): "XOR", (1, 0, 0, 1): "XNOR"}
    print("non-regular operations:",
          ", ".join(f"{names.get(f, f)} = {f}" for f in bad))
    idem = [f for f in ops if magma_product(f, f, n) == f]
    print(f"idempotents of the magma monoid: {len(idem)}")
    # the diagonal-constant obstruction, in general
    for m in (2, 3, 4):
        d = tuple(0 if a == b else 1 for a in range(m) for b in range(m))
        print(f"  n = {m}: d(x,y) = [0 on diagonal, 1 off] regular? "
              f"{is_regular_criterion(d, m)}")


def demo_pseudo_inverse(n: int = 3) -> None:
    show(f"4. Explicit pseudo-inverses by equivariant selection  (n = {n})")
    import random
    random.seed(7)
    checked = 0
    while checked < 6:
        f = tuple(random.randrange(n) for _ in range(n * n))
        if not is_regular_criterion(f, n):
            continue
        g = pseudo_inverse(f, n)
        assert magma_product(magma_product(f, g, n), f, n) == f
        print(f"  f = {f}  ->  pseudo-inverse g = {g}   f*g*f == f : True")
        checked += 1


def demo_not_closed(n: int = 2) -> None:
    show("5. Regular elements are not closed under the magma product")
    f = (0, 0, 1, 0)   # rows [[0,0],[1,0]]
    g = (0, 1, 1, 1)   # rows [[0,1],[1,1]]
    fg = magma_product(f, g, n)
    print(f"f = {f} regular: {is_regular_criterion(f, n)}")
    print(f"g = {g} regular: {is_regular_criterion(g, n)}")
    print(f"f * g = {fg}  (= XOR)  regular: {is_regular_criterion(fg, n)}")


def demo_green(n: int = 2) -> None:
    show(f"6. Green's relations for n = {n}")
    ops = all_ops(n)
    L = classes(ops, n, green_L)
    R = classes(ops, n, green_R)
    H = classes(ops, n, green_H)
    D = classes(ops, n, lambda a, b, k: green_D(a, b, k, ops))
    print(f"L-classes: {len(L)}   sizes {sorted(len(c) for c in L)}")
    print(f"R-classes: {len(R)}   sizes {sorted(len(c) for c in R)}")
    print(f"H-classes: {len(H)}   sizes {sorted(len(c) for c in H)}")
    print(f"D-classes: {len(D)}   sizes {sorted(len(c) for c in D)}")
    invariant = all(
        len({is_regular_criterion(f, n) for f in cls}) == 1 for cls in D
    )
    print(f"regularity constant on each D-class: {invariant}")
    xor = (0, 1, 1, 0)
    cls = next(c for c in D if xor in c)
    print(f"the D-class of XOR: {cls}  (all non-regular)")


def demo_centre() -> None:
    show("7. The centre of the magma monoid")
    for n in (2,):
        ops = all_ops(n)
        centre = [f for f in ops if is_central(f, n, ops)]
        print(f"n = {n}: centre = {centre} "
              f"(= left and right projections: "
              f"{set(centre) == {left_projection(n), right_projection(n)}})")
    # for n = 3 we test centrality against a rich sample instead of all 19683
    n = 3
    import random
    random.seed(1)
    sample = [tuple(random.randrange(n) for _ in range(n * n)) for _ in range(4000)]
    sample += [tuple(c for _ in range(n * n)) for c in range(n)]
    centre = [f for f in all_ops(n) if is_central(f, n, sample)]
    print(f"n = {n}: operations central against a 4003-element test set: "
          f"{len(centre)} -> {centre}")


def demo_units() -> None:
    show("8. The unit group: |Bin(X)^x| = n! * 2^m * m!,  m = n(n-1)/2")
    print(f"{'n':>3} {'|Bin(X)| = n^(n^2)':>22} {'m':>4} {'predicted units':>18} "
          f"{'fraction':>12}")
    for n in range(1, 6):
        total = n ** (n * n)
        m = n * (n - 1) // 2
        u = predicted_unit_count(n)
        print(f"{n:>3} {total:>22} {m:>4} {u:>18} {u / total:>12.3e}")
    for n in (1, 2):
        brute = sum(1 for f in all_ops(n) if is_unit(f, n))
        print(f"brute force n = {n}: {brute} units "
              f"(predicted {predicted_unit_count(n)})")
    print(f"brute force n = 3 (equivariant permutations of X x X): "
          f"{count_units_bruteforce(3)} (predicted {predicted_unit_count(3)})")


def demo_tropical(n: int = 5) -> None:
    show("9. Tropical operations inside the magma monoid")
    mn, mx, l = min_op(n), max_op(n), left_projection(n)
    print(f"min * max = min : {magma_product(mn, mx, n) == mn}")
    print(f"max * min = max : {magma_product(mx, mn, n) == mx}")
    print(f"min * min = min : {magma_product(mn, mn, n) == mn}")
    print(f"max * max = max : {magma_product(mx, mx, n) == mx}")
    print(f"min and max are L-equivalent : {green_L(mn, mx, n)}")
    print(f"both regular : {is_regular_criterion(mn, n)}, {is_regular_criterion(mx, n)}")
    # the generated submonoid
    gen: Set[Op] = {l}
    frontier = {mn, mx}
    while frontier:
        gen |= frontier
        frontier = {magma_product(a, b, n) for a in gen for b in gen} - gen
    print(f"submonoid generated by min and max has {len(gen)} elements "
          f"= {{l, min, max}} : {gen == {l, mn, mx}}")
    # tropical multiplication: regularity = 2-divisibility
    print("\ntropical multiplication a (+) b = a + b:")
    ok_Z, bad = tropical_mul_regular_int()
    print(f"  over Z : is every integer a double?  {ok_Z}   "
          f"first obstructions (odd values): {bad}")
    print("    e.g. 0 (+) 1 = 1 = 1 (+) 0 is a commutative value, but the")
    print("    diagonal values are z (+) z = 2z, never odd  =>  not regular.")
    samples = [Fraction(p, q) for p in range(-6, 7) for q in (1, 2, 3, 5)]
    ok_Q = tropical_mul_regular_rational(samples)
    print(f"  over Q : is every rational a double (r = r/2 + r/2)?  {ok_Q}")
    print("  => tropical multiplication is regular over Q and R, not over Z.")


def main() -> None:
    demo_basics(2)
    demo_representation(3)
    demo_regularity(2)
    demo_pseudo_inverse(3)
    demo_not_closed(2)
    demo_green(2)
    demo_centre()
    demo_units()
    demo_tropical(5)
    print("\nAll demonstrations completed.")


if __name__ == "__main__":
    main()
