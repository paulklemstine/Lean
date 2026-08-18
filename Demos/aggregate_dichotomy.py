"""
Numerical demonstrations for the aggregate dichotomy for families of Pythagorean triples.

A Pythagorean triple is a triple of integers (a, b, c) with a^2 + b^2 = c^2 and c >= 0.
Such triples form a commutative monoid under the Brahmagupta-Fibonacci product

    (a, b, c) * (a', b', c') = (a a' - b b', a b' + b a', c c'),

which is multiplication of the Gaussian integer a + b i together with multiplication of
hypotenuses.  This script demonstrates, numerically:

  1. closure of the product and the Gaussian embedding;
  2. permutation invariance of the product, hence its non-injectivity on families;
  3. a multiset collision:  (3+4i)^2 * (5+12i)^2 = ((3+4i)(5+12i))^2;
  4. a collision that also preserves the multiset of hypotenuses (conjugate
     factorisations of 65 = 5 * 13);
  5. nowhere injectivity and the four-fold rotation twist;
  6. the exact identity-fibre count 4^n in length n+1;
  7. injectivity of the interleaved aggregate;
  8. injectivity of the positional aggregate sum_j z_j B^j on balanced families,
     with exact decoding, and sharpness of the balanced bound.

Run:  python3 demo.py
"""

from __future__ import annotations

from itertools import product as iter_product
from math import isqrt
from typing import Dict, Iterable, Iterator, List, Sequence, Tuple

Triple = Tuple[int, int, int]  # (a, b, c) with a^2 + b^2 = c^2, c >= 0

ONE: Triple = (1, 0, 1)
ZERO: Triple = (0, 0, 0)
ROT_I: Triple = (0, 1, 1)  # the quarter turn i


# --------------------------------------------------------------------------------------
# 1. The monoid
# --------------------------------------------------------------------------------------

def is_triple(t: Triple) -> bool:
    """Check the Pythagorean relation and the nonnegativity normalisation."""
    a, b, c = t
    return c >= 0 and a * a + b * b == c * c


def make_triple(a: int, b: int) -> Triple:
    """Build the triple with legs (a, b); requires a^2 + b^2 to be a perfect square."""
    n = a * a + b * b
    c = isqrt(n)
    if c * c != n:
        raise ValueError(f"({a}, {b}) does not have square norm")
    return (a, b, c)


def mul(t: Triple, s: Triple) -> Triple:
    """The Brahmagupta-Fibonacci product of two Pythagorean triples."""
    a, b, c = t
    a2, b2, c2 = s
    return (a * a2 - b * b2, a * b2 + b * a2, c * c2)


def uprod(family: Sequence[Triple]) -> Triple:
    """The unlabeled product of a family: the Brahmagupta product of all its members."""
    acc: Triple = ONE
    for t in family:
        acc = mul(acc, t)
    return acc


def to_gaussian(t: Triple) -> complex:
    """The Gaussian integer of legs attached to a triple (for display only)."""
    return complex(t[0], t[1])


def power(t: Triple, k: int) -> Triple:
    """The k-th power of a triple in the monoid."""
    acc: Triple = ONE
    for _ in range(k):
        acc = mul(acc, t)
    return acc


# --------------------------------------------------------------------------------------
# 2. The interleaved aggregate
# --------------------------------------------------------------------------------------

def int_to_nat(m: int) -> int:
    """A bijection Z -> N: nonnegative m goes to 2m, negative m goes to -2m-1."""
    return 2 * m if m >= 0 else -2 * m - 1


def nat_to_int(n: int) -> int:
    """Inverse of int_to_nat."""
    return n // 2 if n % 2 == 0 else -(n + 1) // 2


def pair(x: int, y: int) -> int:
    """Cantor pairing bijection N x N -> N."""
    s = x + y
    return s * (s + 1) // 2 + y


def unpair(z: int) -> Tuple[int, int]:
    """Inverse of the Cantor pairing."""
    s = (isqrt(8 * z + 1) - 1) // 2
    y = z - s * (s + 1) // 2
    return (s - y, y)


def code_triple(t: Triple) -> int:
    """Encode a triple by its legs only; the hypotenuse is determined by them."""
    return pair(int_to_nat(t[0]), int_to_nat(t[1]))


def decode_triple(n: int) -> Triple:
    """Inverse of code_triple."""
    u, v = unpair(n)
    return make_triple(nat_to_int(u), nat_to_int(v))


def interleave(family: Sequence[Triple]) -> int:
    """The interleaved aggregate: iterated Cantor pairing of the members' codes."""
    acc = 0
    for t in reversed(family):
        acc = pair(code_triple(t), acc)
    return acc


def deinterleave(value: int, length: int) -> List[Triple]:
    """Recover a family of the given length from its interleaved aggregate."""
    out: List[Triple] = []
    for _ in range(length):
        head, value = unpair(value)
        out.append(decode_triple(head))
    return out


# --------------------------------------------------------------------------------------
# 3. The positional aggregate in Z[i]
# --------------------------------------------------------------------------------------

def gaggr(base: int, family: Sequence[Triple]) -> Tuple[int, int]:
    """The positional aggregate sum_j z_j B^j, returned as a pair (real, imaginary)."""
    re = sum(t[0] * base ** j for j, t in enumerate(family))
    im = sum(t[1] * base ** j for j, t in enumerate(family))
    return (re, im)


def is_balanced(base: int, family: Sequence[Triple]) -> bool:
    """A family is B-balanced when 2|a_j| < B and 2|b_j| < B for every member."""
    return all(2 * abs(t[0]) < base and 2 * abs(t[1]) < base for t in family)


def balanced_digit(value: int, base: int) -> int:
    """The unique r with r = value (mod base) and 2|r| < base (base odd)."""
    r = value % base
    if 2 * r > base:
        r -= base
    return r


def gaggr_decode(base: int, agg: Tuple[int, int], length: int) -> List[Triple]:
    """Recover a B-balanced family from its positional aggregate (base odd)."""
    re, im = agg
    out: List[Triple] = []
    for _ in range(length):
        a = balanced_digit(re, base)
        b = balanced_digit(im, base)
        out.append(make_triple(a, b))
        re, im = (re - a) // base, (im - b) // base
    return out


# --------------------------------------------------------------------------------------
# 4. Fibre structure
# --------------------------------------------------------------------------------------

ROTATIONS: List[Triple] = [(1, 0, 1), (0, 1, 1), (-1, 0, 1), (0, -1, 1)]  # rho^0..rho^3


def identity_fibre(length: int) -> Iterator[Tuple[Triple, ...]]:
    """Enumerate all families of the given length whose product is the identity triple.

    Every member of such a family must be a unit, i.e. a power rho^v of the quarter turn,
    and the product condition says exactly that the exponents sum to zero modulo 4.
    """
    if length == 0:
        yield ()
        return
    for head in iter_product(range(4), repeat=length - 1):
        last = (-sum(head)) % 4
        yield tuple(ROTATIONS[v] for v in head + (last,))


def brute_force_identity_fibre(length: int, bound: int = 3) -> List[Tuple[Triple, ...]]:
    """Brute-force check of the fibre over the identity, searching small triples."""
    small = [t for t in
             (make_triple(a, b)
              for a in range(-bound, bound + 1)
              for b in range(-bound, bound + 1)
              if isqrt(a * a + b * b) ** 2 == a * a + b * b)]
    return [f for f in iter_product(small, repeat=length) if uprod(list(f)) == ONE]


# --------------------------------------------------------------------------------------
# 5. Demonstrations
# --------------------------------------------------------------------------------------

def banner(title: str) -> None:
    print("\n" + "=" * 78)
    print(title)
    print("=" * 78)


def demo_monoid() -> None:
    banner("1. The Brahmagupta product and the Gaussian embedding")
    t345 = make_triple(3, 4)
    t51213 = make_triple(5, 12)
    p = mul(t345, t51213)
    print(f"  (3,4,5) * (5,12,13) = {p}   [as Gaussian integers: "
          f"{to_gaussian(t345)} * {to_gaussian(t51213)} = {to_gaussian(p)}]")
    print(f"  closure check: {is_triple(p)}")
    print(f"  hypotenuses multiply: 5 * 13 = {5 * 13} = {p[2]}")
    print(f"  units (hypotenuse 1) are the four rotations: {ROTATIONS}")
    print(f"  quarter turn has order 4:  rho^4 = {power(ROT_I, 4)}")


def demo_symmetry() -> None:
    banner("2. Permutation invariance forces non-injectivity")
    t345 = make_triple(3, 4)
    f = [t345, ONE]
    g = [ONE, t345]
    print(f"  family f = {f}")
    print(f"  family g = {g}   (a permutation of f, and f != g)")
    print(f"  product of f = {uprod(f)}")
    print(f"  product of g = {uprod(g)}   -> equal, so the product is not injective")


def demo_multiset_collision() -> None:
    banner("3. Collision of distinct multisets:  z^2 w^2 = (z w)^2")
    A = make_triple(-7, 24)      # (3+4i)^2
    B = make_triple(-119, 120)   # (5+12i)^2
    C = make_triple(-33, 56)     # (3+4i)(5+12i)
    print(f"  A = {A}   B = {B}   C = {C}")
    print(f"  A * B = {mul(A, B)}")
    print(f"  C * C = {mul(C, C)}")
    print(f"  equal: {mul(A, B) == mul(C, C)};  multisets differ: "
          f"{sorted([A, B]) != sorted([C, C])}")


def demo_hypotenuse_collision() -> None:
    banner("4. Even the multiset of hypotenuses does not rigidify")
    w1 = make_triple(63, -16)   # (3+4i)(5-12i)
    w2 = make_triple(63, 16)    # (3-4i)(5+12i)
    w3 = make_triple(-33, 56)   # (3+4i)(5+12i)
    w4 = make_triple(-33, -56)  # (3-4i)(5-12i)
    M, N = [w1, w2], [w3, w4]
    print(f"  M = {M}")
    print(f"  N = {N}")
    print(f"  products:    {uprod(M)}  vs  {uprod(N)}")
    print(f"  hypotenuses: {sorted(t[2] for t in M)}  vs  {sorted(t[2] for t in N)}")
    print(f"  all legs nonzero: {all(t[0] and t[1] for t in M + N)}")
    print(f"  distinct multisets with identical data: {sorted(M) != sorted(N)}")


def demo_twist_and_nowhere_injectivity() -> None:
    banner("5. Rotation twists: four families with one product; nowhere injectivity")
    f = [make_triple(3, 4), make_triple(5, 12)]
    print(f"  base family f = {f}, product {uprod(f)}")
    for k in range(4):
        rho_k = ROTATIONS[k]
        rho_inv = ROTATIONS[(-k) % 4]
        twisted = [mul(rho_k, f[0]), mul(rho_inv, f[1])]
        print(f"    k={k}: {twisted}  -> product {uprod(twisted)}")
    print("  every length-two family collides with another one; e.g. twisting by rho^2:")
    g = [mul(ROTATIONS[2], f[0]), mul(ROTATIONS[2], f[1])]
    print(f"    g = {g}, product {uprod(g)}, g != f: {g != f}")


def demo_fibre_count() -> None:
    banner("6. The identity fibre has exactly 4^n elements in length n+1")
    for length in range(1, 5):
        fibre = list(identity_fibre(length))
        distinct = len(set(fibre))
        print(f"  length {length}: enumerated {distinct} families, predicted "
              f"4^{length - 1} = {4 ** (length - 1)}, all products equal 1: "
              f"{all(uprod(list(f)) == ONE for f in fibre)}")
    brute = brute_force_identity_fibre(2, bound=3)
    print(f"  brute-force check in length 2 over all triples with |legs| <= 3: "
          f"{len(brute)} families -> {sorted(brute)}")


def demo_interleave() -> None:
    banner("7. The interleaved aggregate is injective and invertible")
    families: List[List[Triple]] = [
        [make_triple(3, 4), make_triple(5, 12)],
        [make_triple(5, 12), make_triple(3, 4)],
        [make_triple(-7, 24), make_triple(-119, 120)],
        [make_triple(-33, 56), make_triple(-33, 56)],
    ]
    seen: Dict[int, List[Triple]] = {}
    for f in families:
        v = interleave(f)
        print(f"  {str(f):48s} -> {v}")
        assert deinterleave(v, len(f)) == f, "decoding must round-trip"
        seen.setdefault(v, f)
    print(f"  distinct aggregates: {len(seen)} of {len(families)} -> injective")
    print(f"  products, by contrast: "
          f"{len({uprod(f) for f in families})} distinct of {len(families)}")


def demo_positional() -> None:
    banner("8. The positional aggregate in Z[i], its decoding, and sharpness")
    base = 101  # odd, so balanced digits are unique and decoding is exact
    f = [make_triple(3, 4), make_triple(5, 12)]
    g = [make_triple(5, 12), make_triple(3, 4)]
    print(f"  base B = {base}; both families balanced: "
          f"{is_balanced(base, f) and is_balanced(base, g)}")
    print(f"  products agree:  {uprod(f)} == {uprod(g)}  -> {uprod(f) == uprod(g)}")
    af, ag = gaggr(base, f), gaggr(base, g)
    print(f"  G_B(f) = {af[0]} + {af[1]}i")
    print(f"  G_B(g) = {ag[0]} + {ag[1]}i     -> separated: {af != ag}")
    print(f"  decoding recovers f exactly: {gaggr_decode(base, af, 2) == f}")
    print(f"  decoding recovers g exactly: {gaggr_decode(base, ag, 2) == g}")
    print("  in base 100 (the example of the text):")
    print(f"    G_100(f) = {gaggr(100, f)},  G_100(g) = {gaggr(100, g)}")
    print("  sharpness of the balanced bound (B = 2, where only 2|.| <= B holds):")
    u = [ONE, ZERO]
    v = [(-1, 0, 1), ONE]
    print(f"    G_2({u}) = {gaggr(2, u)}")
    print(f"    G_2({v}) = {gaggr(2, v)}   -> collide, and u != v: {u != v}")


def demo_search_collisions(limit: int = 40) -> None:
    banner("9. A search for further two-element multiset collisions")
    triples: List[Triple] = []
    for a in range(-limit, limit + 1):
        for b in range(-limit, limit + 1):
            n = a * a + b * b
            if n and isqrt(n) ** 2 == n:
                triples.append((a, b, isqrt(n)))
    buckets: Dict[Triple, List[Tuple[Triple, Triple]]] = {}
    for i, t in enumerate(triples):
        for s in triples[i:]:
            buckets.setdefault(mul(t, s), []).append((t, s))
    collisions = [(p, fs) for p, fs in buckets.items() if len(fs) > 1]
    collisions.sort(key=lambda kv: kv[0][2])
    print(f"  scanned {len(triples)} triples with |legs| <= {limit}")
    print(f"  products realised by more than one unordered pair: {len(collisions)}")
    for p, fs in collisions[:3]:
        print(f"    product {p} from {len(fs)} pairs, e.g. {fs[0]} and {fs[1]}")


def main() -> None:
    demo_monoid()
    demo_symmetry()
    demo_multiset_collision()
    demo_hypotenuse_collision()
    demo_twist_and_nowhere_injectivity()
    demo_fibre_count()
    demo_interleave()
    demo_positional()
    demo_search_collisions()
    print("\nAll demonstrations completed.\n")


if __name__ == "__main__":
    main()
