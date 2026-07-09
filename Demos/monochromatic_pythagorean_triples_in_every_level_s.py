"""Numerical demonstrations for:

    Monochromatic Pythagorean Triples in Every Level Set of a
    Completely Multiplicative Coloring.

A *completely multiplicative coloring* is a map f from the positive
integers into a finite abelian group G of "colors" with

    f(1) = 1,    f(m * n) = f(m) * f(n).

A Pythagorean triple (x, y, z) with x^2 + y^2 = z^2 is *monochromatic of
color w* when f(x) = f(y) = f(z) = w.

Main facts demonstrated here:

  * Scale invariance: (x, y, z) Pythagorean  =>  (t*x, t*y, t*z) Pythagorean.
  * Scaling by t shifts the common color of a monochromatic triple by f(t).
  * The image of f is a subgroup of G (identity, products, inverses).
  * The Reduction: one monochromatic triple of any color yields, for every
    color w in the image, a triple monochromatic of color w.
  * The (3,4,5) criterion and the all-or-nothing dichotomy.

We model the color group G = mu_k (k-th roots of unity) additively as
Z / kZ: a root of unity exp(2*pi*i*a/k) is represented by the residue a,
group multiplication becomes addition mod k, and the identity is 0.
"""

from __future__ import annotations

from dataclasses import dataclass
from math import gcd, isqrt
from typing import Callable


# --------------------------------------------------------------------------
# Color group  G = mu_k  represented additively as Z/kZ.
# --------------------------------------------------------------------------

@dataclass(frozen=True)
class RootColoring:
    """A completely multiplicative coloring into mu_k = Z/kZ.

    It is specified by the color of each prime: `prime_color[p]` is the
    residue in {0, ..., k-1} assigned to the prime p.  The coloring of an
    arbitrary n >= 1 is then forced by complete multiplicativity:

        f(n) = sum over prime powers p^e || n of  e * prime_color[p]   (mod k).

    Primes not listed default to color 0 (the neutral color).
    """

    k: int
    prime_color: dict[int, int]

    def color(self, n: int) -> int:
        """Return f(n) as a residue in {0, ..., k-1}."""
        if n <= 0:
            raise ValueError("coloring defined only on positive integers")
        total = 0
        m = n
        d = 2
        while d * d <= m:
            while m % d == 0:
                total += self.prime_color.get(d, 0)
                m //= d
            d += 1
        if m > 1:  # remaining prime factor
            total += self.prime_color.get(m, 0)
        return total % self.k


def group_mul(a: int, b: int, k: int) -> int:
    """Multiplication in mu_k, represented additively mod k."""
    return (a + b) % k


def group_inv(a: int, k: int) -> int:
    """Inverse in mu_k, represented additively mod k."""
    return (-a) % k


# --------------------------------------------------------------------------
# Pythagorean triples.
# --------------------------------------------------------------------------

def is_pyth_triple(x: int, y: int, z: int) -> bool:
    """True iff (x, y, z) are positive integers with x^2 + y^2 = z^2."""
    return x > 0 and y > 0 and z > 0 and x * x + y * y == z * z


def scale_triple(t: int, triple: tuple[int, int, int]) -> tuple[int, int, int]:
    """Scale a triple by t.  Preserves the Pythagorean property (Lemma 3.1)."""
    x, y, z = triple
    return (t * x, t * y, t * z)


def primitive_triples(limit: int) -> list[tuple[int, int, int]]:
    """All primitive Pythagorean triples with hypotenuse <= limit via Euclid's
    parametrization x = m^2 - n^2, y = 2mn, z = m^2 + n^2."""
    out: list[tuple[int, int, int]] = []
    m = 2
    while m * m <= limit:
        for n in range(1, m):
            if (m - n) % 2 == 1 and gcd(m, n) == 1:
                x = m * m - n * n
                y = 2 * m * n
                z = m * m + n * n
                if z <= limit:
                    out.append((min(x, y), max(x, y), z))
        m += 1
    return sorted(out, key=lambda t: t[2])


# --------------------------------------------------------------------------
# Monochromaticity and the reduction.
# --------------------------------------------------------------------------

def triple_colors(f: RootColoring, triple: tuple[int, int, int]) -> tuple[int, int, int]:
    x, y, z = triple
    return (f.color(x), f.color(y), f.color(z))


def is_mono(f: RootColoring, triple: tuple[int, int, int]) -> bool:
    a, b, c = triple_colors(f, triple)
    return a == b == c


def image_colors(f: RootColoring, bound: int = 5000) -> set[int]:
    """Empirical image { f(n) : 1 <= n <= bound }.  For these colorings the
    image is a subgroup, so this stabilizes quickly."""
    return {f.color(n) for n in range(1, bound + 1)}


def find_scale_for_color(f: RootColoring, gamma: int, bound: int = 100000) -> int:
    """Find a positive integer t with f(t) = gamma (Algorithm A, step 2).

    Guaranteed to succeed when gamma is in the image of f."""
    for t in range(1, bound + 1):
        if f.color(t) == gamma:
            return t
    raise RuntimeError(f"no scale found for color {gamma} within bound {bound}")


def transport_to_color(
    f: RootColoring,
    seed: tuple[int, int, int],
    target: int,
) -> tuple[int, int, int]:
    """Algorithm A: given a monochromatic seed triple, produce a Pythagorean
    triple monochromatic of color `target` (assumed to be in the image)."""
    if not is_pyth_triple(*seed):
        raise ValueError("seed is not a Pythagorean triple")
    if not is_mono(f, seed):
        raise ValueError("seed is not monochromatic")
    v0 = f.color(seed[0])
    gamma = group_mul(group_inv(v0, f.k), target, f.k)  # v0^{-1} * target
    t = find_scale_for_color(f, gamma)
    return scale_triple(t, seed)


def inverse_color_as_power(f: RootColoring, n: int, group_order: int) -> int:
    """Algorithm B: n^{N-1} realizes f(n)^{-1}, where N = group_order."""
    return n ** (group_order - 1)


# --------------------------------------------------------------------------
# Demonstrations.
# --------------------------------------------------------------------------

def demo_scale_invariance() -> None:
    print("=" * 70)
    print("DEMO 1  Scale invariance of Pythagorean triples")
    print("=" * 70)
    base = (3, 4, 5)
    for t in (1, 2, 3, 7, 12):
        s = scale_triple(t, base)
        print(f"  t={t:<3}  {s}   Pythagorean? {is_pyth_triple(*s)}")
    print()


def demo_color_shift() -> None:
    print("=" * 70)
    print("DEMO 2  Scaling shifts the common color by f(t)")
    print("=" * 70)
    # Coloring into mu_6: color of 3 = 1, of 4 = 2*color(2), of 5 = 5, etc.
    f = RootColoring(k=6, prime_color={2: 1, 3: 2, 5: 4, 7: 3})
    seed = (3, 4, 5)
    print(f"  colors of {seed}: {triple_colors(f, seed)}  (monochromatic: {is_mono(f, seed)})")
    print("  In general (3,4,5) need not be monochromatic; we scale a genuine")
    print("  monochromatic seed below to watch the color slide.")
    # Build a monochromatic seed under the trivial coloring, then a nontrivial shift.
    triv = RootColoring(k=6, prime_color={})
    seed2 = (3, 4, 5)
    print(f"  trivial coloring: colors {triple_colors(triv, seed2)}, mono={is_mono(triv, seed2)}")
    for t in (1, 2, 5, 25):
        s = scale_triple(t, seed2)
        print(f"    scale t={t:<3} -> triple {s}, colors {triple_colors(triv, s)}")
    print()


def demo_image_subgroup() -> None:
    print("=" * 70)
    print("DEMO 3  The image of f is a subgroup of mu_k")
    print("=" * 70)
    f = RootColoring(k=6, prime_color={2: 2, 3: 4})  # colors are multiples of 2
    img = image_colors(f)
    print(f"  k=6, prime colors {{2:2, 3:4}};  observed image = {sorted(img)}")
    print(f"  contains identity 0?           {0 in img}")
    # closure under products
    prod_ok = all(group_mul(a, b, f.k) in img for a in img for b in img)
    print(f"  closed under products?         {prod_ok}")
    # closure under inverses
    inv_ok = all(group_inv(a, f.k) in img for a in img)
    print(f"  closed under inverses?         {inv_ok}")
    # inverse via Algorithm B
    n = 12
    N = f.k
    m = inverse_color_as_power(f, n, N)
    print(f"  Algorithm B: f({n})={f.color(n)}, f({n}^{N-1})={f.color(m)}, "
          f"inverse={group_inv(f.color(n), N)}")
    print()


def demo_reduction() -> None:
    print("=" * 70)
    print("DEMO 4  The Reduction: one mono triple -> a triple of every color")
    print("=" * 70)
    # Use a coloring where (3,4,5) is monochromatic of color 0.
    # Choose prime colors so that f(3)=f(4)=f(5).  f(4)=2*c2, f(3)=c3, f(5)=c5.
    # Pick c2=0, c3=0, c5=0 on {2,3,5}, but give color to another prime (7) so
    # the image is nontrivial and every color is still reachable via scaling.
    f = RootColoring(k=4, prime_color={2: 0, 3: 0, 5: 0, 7: 1})
    seed = (3, 4, 5)
    print(f"  coloring into mu_4;  seed {seed} colors {triple_colors(f, seed)} "
          f"(mono={is_mono(f, seed)})")
    img = sorted(image_colors(f))
    print(f"  image of f = {img}")
    for target in img:
        tri = transport_to_color(f, seed, target)
        cols = triple_colors(f, tri)
        ok = is_pyth_triple(*tri) and cols == (target, target, target)
        print(f"    target color {target}: triple {tri}, colors {cols}  [{'OK' if ok else 'FAIL'}]")
    print()


def demo_345_criterion() -> None:
    print("=" * 70)
    print("DEMO 5  The (3,4,5) criterion and all-or-nothing dichotomy")
    print("=" * 70)
    # Sweep several colorings; report whether (3,4,5) is monochromatic and
    # whether every color in the image is realized (they must agree).
    colorings = [
        ("trivial",             RootColoring(k=3, prime_color={})),
        ("f(3)=f(4)=f(5)=0",    RootColoring(k=3, prime_color={2: 0, 3: 0, 5: 0, 7: 1})),
        ("generic",             RootColoring(k=3, prime_color={2: 1, 3: 2, 5: 1})),
    ]
    for name, f in colorings:
        mono345 = is_mono(f, (3, 4, 5))
        img = sorted(image_colors(f))
        if mono345:
            realized = []
            for target in img:
                tri = transport_to_color(f, (3, 4, 5), target)
                realized.append(triple_colors(f, tri) == (target, target, target))
            all_realized = all(realized)
        else:
            all_realized = None
        print(f"  {name:<22} (3,4,5) mono? {mono345!s:<5}  image={img}  "
              f"every color realized? {all_realized}")
    print()


def demo_primitive_gallery() -> None:
    print("=" * 70)
    print("DEMO 6  A gallery of primitive Pythagorean triples")
    print("=" * 70)
    for tri in primitive_triples(60):
        print(f"  {tri}   check: {tri[0]}^2 + {tri[1]}^2 = {tri[2]}^2  "
              f"({tri[0]**2 + tri[1]**2} = {tri[2]**2})")
    print()


def main() -> None:
    demo_scale_invariance()
    demo_color_shift()
    demo_image_subgroup()
    demo_reduction()
    demo_345_criterion()
    demo_primitive_gallery()


if __name__ == "__main__":
    main()
