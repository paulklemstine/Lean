"""
Numerical demonstrations for:

    A Functorial Tropical Ultrametric on the Boundary of the Berggren Tree

This self-contained script illustrates, with concrete numbers, every main result
of the accompanying paper:

  * the Berggren ternary tree generating all primitive Pythagorean triples
    from the seed (3, 4, 5) via three Lorentz-invariant child maps;
  * the first-disagreement index on infinite addresses;
  * the tree ultrametric d(x, y) = (1/2) ** firstDiff(x, y);
  * the strong (ultrametric) triangle inequality and the min-plus core;
  * the exact (1/2)-similarity of the branch maps and maximal branch separation;
  * the two-sided depth-hypotenuse window  5 * 3**n <= c <= 5 * 7**n;
  * the Gaussian-integer encoding with multiplicative norm = hypotenuse.

Run:  python demo.py
"""

from __future__ import annotations

from fractions import Fraction
from typing import Callable, Iterator, List, Sequence, Tuple

Triple = Tuple[int, int, int]


# --------------------------------------------------------------------------- #
# 1. The Berggren child maps (Lorentz-invariant generators)                   #
# --------------------------------------------------------------------------- #
def child_a(t: Triple) -> Triple:
    a, b, c = t
    return (a - 2 * b + 2 * c, 2 * a - b + 2 * c, 2 * a - 2 * b + 3 * c)


def child_b(t: Triple) -> Triple:
    a, b, c = t
    return (a + 2 * b + 2 * c, 2 * a + b + 2 * c, 2 * a + 2 * b + 3 * c)


def child_c(t: Triple) -> Triple:
    a, b, c = t
    return (-a + 2 * b + 2 * c, -2 * a + b + 2 * c, -2 * a + 2 * b + 3 * c)


CHILDREN: List[Callable[[Triple], Triple]] = [child_a, child_b, child_c]
SEED: Triple = (3, 4, 5)


def is_pythagorean(t: Triple) -> bool:
    a, b, c = t
    return a * a + b * b == c * c


def lorentz_q(t: Triple) -> int:
    a, b, c = t
    return a * a + b * b - c * c


def descend(word: Sequence[int], seed: Triple = SEED) -> Triple:
    """Apply child maps named by `word` (letters in {0,1,2}) starting at `seed`."""
    t = seed
    for k in word:
        t = CHILDREN[k](t)
    return t


# --------------------------------------------------------------------------- #
# 2. The boundary ultrametric on infinite addresses                           #
# --------------------------------------------------------------------------- #
def first_diff(x: Callable[[int], int], y: Callable[[int], int], horizon: int = 256) -> int:
    """First index where addresses x, y disagree (searched up to `horizon`)."""
    for n in range(horizon):
        if x(n) != y(n):
            return n
    return 0  # treated as equal within the horizon


def ultra_d(x: Callable[[int], int], y: Callable[[int], int], horizon: int = 256) -> Fraction:
    """Tree ultrametric d(x, y) = (1/2) ** firstDiff(x, y); 0 if equal."""
    for n in range(horizon):
        if x(n) != y(n):
            return Fraction(1, 2) ** n
    return Fraction(0)


def cons(k: int, x: Callable[[int], int]) -> Callable[[int], int]:
    """Prepend branch label k to address x."""
    return lambda n: k if n == 0 else x(n - 1)


def address_from_list(prefix: Sequence[int], tail: int = 0) -> Callable[[int], int]:
    """An address equal to `prefix` then constant `tail`."""
    return lambda n: prefix[n] if n < len(prefix) else tail


# --------------------------------------------------------------------------- #
# 3. Gaussian-integer encoding                                                #
# --------------------------------------------------------------------------- #
def gaussian_triple(m: int, n: int) -> Triple:
    """Primitive-shape triple from (m + n i)**2: (m^2 - n^2, 2mn, m^2 + n^2)."""
    return (m * m - n * n, 2 * m * n, m * m + n * n)


def gaussian_norm(m: int, n: int) -> int:
    """N(m + n i) = m^2 + n^2 = hypotenuse of the encoded triple."""
    return m * m + n * n


def gaussian_mul(z: Tuple[int, int], w: Tuple[int, int]) -> Tuple[int, int]:
    a, b = z
    c, d = w
    return (a * c - b * d, a * d + b * c)


# --------------------------------------------------------------------------- #
# Demonstrations                                                              #
# --------------------------------------------------------------------------- #
def demo_tree() -> None:
    print("=" * 70)
    print("1. Berggren tree: all children are Pythagorean (Q = 0 preserved)")
    print("=" * 70)
    print(f"seed {SEED}: pythagorean={is_pythagorean(SEED)}, Q={lorentz_q(SEED)}")
    for n in range(3):
        t = SEED
        names = "ABC"
        for k in range(3):
            child = CHILDREN[k](t)
            print(f"  child {names[k]} of {t} = {child}  "
                  f"pythagorean={is_pythagorean(child)}  Q={lorentz_q(child)}")
        break
    # First two generations, count and verify
    gen1 = [CHILDREN[k](SEED) for k in range(3)]
    gen2 = [CHILDREN[j](t) for t in gen1 for j in range(3)]
    print(f"\ngeneration 1: {gen1}")
    print(f"generation 2 ({len(gen2)} triples) all pythagorean: "
          f"{all(is_pythagorean(t) for t in gen2)}")


def demo_ultrametric() -> None:
    print("\n" + "=" * 70)
    print("2. Tree ultrametric and the strong triangle inequality")
    print("=" * 70)
    x = address_from_list([1, 1, 0, 2, 1])
    y = address_from_list([1, 1, 2, 0, 0])
    z = address_from_list([0, 2, 2, 1, 1])
    dxy, dyz, dxz = ultra_d(x, y), ultra_d(y, z), ultra_d(x, z)
    print(f"d(x,y) = {dxy}  (first disagreement at index {first_diff(x, y)})")
    print(f"d(y,z) = {dyz}  (first disagreement at index {first_diff(y, z)})")
    print(f"d(x,z) = {dxz}  (first disagreement at index {first_diff(x, z)})")
    print(f"strong triangle: d(x,z) <= max(d(x,y), d(y,z))? "
          f"{dxz <= max(dxy, dyz)}")
    print(f"min-plus core:  min(fd(x,y),fd(y,z)) <= fd(x,z)? "
          f"{min(first_diff(x, y), first_diff(y, z)) <= first_diff(x, z)}")


def demo_similarity() -> None:
    print("\n" + "=" * 70)
    print("3. Branch maps are exact (1/2)-similarities; distinct branches at d=1")
    print("=" * 70)
    x = address_from_list([2, 0, 1, 1])
    y = address_from_list([2, 1, 0, 2])
    base = ultra_d(x, y)
    for k in range(3):
        scaled = ultra_d(cons(k, x), cons(k, y))
        print(f"  k={k}: d(cons k x, cons k y) = {scaled} = (1/2)*d(x,y)? "
              f"{scaled == base / 2}")
    print(f"distinct first labels: d(cons 0 x, cons 1 y) = "
          f"{ultra_d(cons(0, x), cons(1, y))}  (should be 1)")


def demo_growth() -> None:
    print("\n" + "=" * 70)
    print("4. Two-sided depth-hypotenuse window:  5*3**n <= c <= 5*7**n")
    print("=" * 70)
    t = SEED
    for n in range(7):
        c = t[2]
        lo, hi = 5 * 3 ** n, 5 * 7 ** n
        print(f"  n={n}: c={c:>10}   window [{lo}, {hi}]   inside={lo <= c <= hi}")
        t = child_b(t)


def demo_gaussian() -> None:
    print("\n" + "=" * 70)
    print("5. Gaussian encoding: norm = hypotenuse, and norm is multiplicative")
    print("=" * 70)
    for (m, n) in [(2, 1), (3, 2), (4, 1), (5, 2)]:
        tri = gaussian_triple(m, n)
        print(f"  (m,n)=({m},{n}): triple={tri}  N={gaussian_norm(m, n)}  "
              f"hyp={tri[2]}  match={gaussian_norm(m, n) == tri[2]}")
    z, w = (3, 2), (4, 1)
    prod = gaussian_mul(z, w)
    nz, nw = z[0] ** 2 + z[1] ** 2, w[0] ** 2 + w[1] ** 2
    npr = prod[0] ** 2 + prod[1] ** 2
    print(f"\n  N({z})*N({w}) = {nz * nw};  N({z}*{w}={prod}) = {npr};  "
          f"multiplicative={nz * nw == npr}")


def main() -> None:
    demo_tree()
    demo_ultrametric()
    demo_similarity()
    demo_growth()
    demo_gaussian()
    print("\nAll demonstrations complete.")


if __name__ == "__main__":
    main()
