"""
Numerical demonstrations of the Gaussian integer parametrization of Pythagorean
triples.

The norm on the Gaussian integers Z[i] is N(a + b i) = a^2 + b^2.  Squaring a
Gaussian integer z = a + b i gives z^2 = (a^2 - b^2) + (2ab) i, and the identity
N(z^2) = N(z)^2 reads

        (a^2 - b^2)^2 + (2ab)^2 = (a^2 + b^2)^2,

so the map

        P(z) = ( |a^2 - b^2|, 2|ab|, a^2 + b^2 )

always yields a Pythagorean triple.  This module demonstrates the four main
results:

  Theorem 1 (Validity)            -> every P(z) is Pythagorean.
  Theorem 2 (Rigidity)            -> P(z) = P(w) implies z = u w or z = u conj(w).
  Theorem 3 (Completeness)        -> every primitive triple is hit by some seed.
  Theorem 4 (Primitivity)         -> legs coprime iff parts coprime & opposite parity.

Run:  python demo.py
"""

from __future__ import annotations

from math import gcd
from typing import Iterator


# ----------------------------------------------------------------------------- #
#  Core map                                                                      #
# ----------------------------------------------------------------------------- #
def parametrize(a: int, b: int) -> tuple[int, int, int]:
    """Return the Pythagorean triple P(a + b*i) = (|a^2-b^2|, 2|ab|, a^2+b^2)."""
    return (abs(a * a - b * b), 2 * abs(a * b), a * a + b * b)


def is_pythagorean(t: tuple[int, int, int]) -> bool:
    """Check whether (x, y, c) satisfies x^2 + y^2 = c^2."""
    x, y, c = t
    return x * x + y * y == c * c


def is_primitive(t: tuple[int, int, int]) -> bool:
    """Check whether the legs of (x, y, c) are coprime."""
    x, y, _ = t
    return gcd(x, y) == 1


# ----------------------------------------------------------------------------- #
#  Theorem 1 — Validity                                                          #
# ----------------------------------------------------------------------------- #
def demo_validity(bound: int = 8) -> None:
    """Every P(a + b*i) is a valid Pythagorean triple."""
    print("=" * 70)
    print("THEOREM 1 (Validity): P(z) is always a Pythagorean triple")
    print("=" * 70)
    ok = True
    for a in range(0, bound + 1):
        for b in range(0, bound + 1):
            t = parametrize(a, b)
            ok &= is_pythagorean(t)
    print(f"  Checked all 0 <= a,b <= {bound}: all Pythagorean = {ok}")
    print("  Sample seeds:")
    for a, b in [(2, 1), (3, 2), (4, 1), (5, 2), (7, 4)]:
        x, y, c = parametrize(a, b)
        print(f"    z = {a}+{b}i  ->  ({x:>3},{y:>3},{c:>3})   "
              f"{x}^2 + {y}^2 = {x*x + y*y} = {c}^2")
    print()


# ----------------------------------------------------------------------------- #
#  Theorem 2 — Rigidity (injectivity up to units and conjugation)               #
# ----------------------------------------------------------------------------- #
def gaussian_mul(z: tuple[int, int], w: tuple[int, int]) -> tuple[int, int]:
    """Multiply two Gaussian integers (a+bi)(c+di)."""
    a, b = z
    c, d = w
    return (a * c - b * d, a * d + b * c)


def conjugate(z: tuple[int, int]) -> tuple[int, int]:
    """Complex conjugate a - b i of a + b i."""
    a, b = z
    return (a, -b)


UNITS: list[tuple[int, int]] = [(1, 0), (-1, 0), (0, 1), (0, -1)]


def symmetry_orbit(a: int, b: int) -> set[tuple[int, int]]:
    """All u*z and u*conj(z) for units u — the full 8-element symmetry orbit."""
    z = (a, b)
    orbit: set[tuple[int, int]] = set()
    for u in UNITS:
        orbit.add(gaussian_mul(u, z))
        orbit.add(gaussian_mul(u, conjugate(z)))
    return orbit


def demo_rigidity(bound: int = 6) -> None:
    """If P(z) = P(w) then z and w lie in the same 8-element symmetry orbit."""
    print("=" * 70)
    print("THEOREM 2 (Rigidity): P(z)=P(w)  =>  z = u w  or  z = u conj(w)")
    print("=" * 70)
    # Group all seeds by their triple, then confirm each fiber is one orbit.
    fibers: dict[tuple[int, int, int], list[tuple[int, int]]] = {}
    for a in range(-bound, bound + 1):
        for b in range(-bound, bound + 1):
            fibers.setdefault(parametrize(a, b), []).append((a, b))

    all_ok = True
    shown = 0
    for triple, seeds in fibers.items():
        if triple[2] == 0:
            continue  # skip the degenerate (0,0,0)
        orbit = symmetry_orbit(*seeds[0])
        fiber_ok = all(s in orbit for s in seeds)
        all_ok &= fiber_ok
        if shown < 4 and len(seeds) > 1:
            reps = sorted(seeds)[:8]
            print(f"  triple {triple}: fiber = {reps}  single orbit = {fiber_ok}")
            shown += 1
    print(f"  Every fiber (|a|,|b| <= {bound}) is a single symmetry orbit = {all_ok}")
    # Explicit example that conjugation is NOT a unit multiple:
    z = (1, 2)
    print(f"  Note conj(1+2i) = 1-2i, and P(1,2)=P(1,-2)={parametrize(1,2)};")
    print("  1-2i is not any unit times 1+2i, so conjugation is a genuine symmetry.")
    print()


# ----------------------------------------------------------------------------- #
#  Theorem 3 — Completeness (surjectivity onto primitive triples)               #
# ----------------------------------------------------------------------------- #
def primitive_seeds(bound: int) -> Iterator[tuple[int, int]]:
    """Seeds m>n>0, coprime, opposite parity, with m^2+n^2 <= bound."""
    m = 2
    while m * m + 1 <= bound:
        for n in range(1, m):
            if gcd(m, n) == 1 and (m - n) % 2 == 1 and m * m + n * n <= bound:
                yield (m, n)
        m += 1


def all_primitive_triples_bruteforce(bound: int) -> set[tuple[int, int, int]]:
    """All primitive (x,y,c) with odd x, even y, 0<x,y, c<=bound, by brute force."""
    found: set[tuple[int, int, int]] = set()
    for c in range(1, bound + 1):
        for x in range(1, c):
            y2 = c * c - x * x
            y = int(round(y2 ** 0.5))
            if y > 0 and y * y == y2 and gcd(x, y) == 1:
                # normalize: odd leg first
                if x % 2 == 1:
                    found.add((x, y, c))
    return found


def demo_completeness(bound: int = 200) -> None:
    """Every primitive triple with odd first leg is produced by some seed."""
    print("=" * 70)
    print("THEOREM 3 (Completeness): seeds hit every primitive triple")
    print("=" * 70)
    generated: set[tuple[int, int, int]] = set()
    for m, n in primitive_seeds(bound):
        x, y, c = parametrize(m, n)  # x = m^2-n^2 (odd), y = 2mn (even)
        generated.add((x, y, c))
    brute = all_primitive_triples_bruteforce(bound)
    missing = brute - generated
    print(f"  hypotenuse bound c <= {bound}")
    print(f"  primitive triples found by brute force : {len(brute)}")
    print(f"  primitive triples produced by seeds    : {len(generated & brute)}")
    print(f"  missing (should be empty)              : {sorted(missing)}")
    print(f"  completeness verified                  : {missing == set()}")
    print()


# ----------------------------------------------------------------------------- #
#  Theorem 4 — Primitivity criterion                                            #
# ----------------------------------------------------------------------------- #
def demo_primitivity(bound: int = 30) -> None:
    """Legs coprime  iff  gcd(a,b)=1 and a,b have opposite parity."""
    print("=" * 70)
    print("THEOREM 4 (Primitivity): legs coprime <=> gcd(a,b)=1 & opposite parity")
    print("=" * 70)
    all_ok = True
    counterexample_shown = False
    for a in range(1, bound + 1):
        for b in range(0, a):
            legs_coprime = is_primitive(parametrize(a, b))
            criterion = (gcd(a, b) == 1) and ((a - b) % 2 == 1)
            all_ok &= (legs_coprime == criterion)
            if not counterexample_shown and a == 3 and b == 1:
                x, y, c = parametrize(a, b)
                print(f"  Folklore trap: z=3+i has gcd(3,1)=1 but P=({x},{y},{c}), "
                      f"gcd(legs)={gcd(x, y)} -> NOT primitive (both odd).")
                counterexample_shown = True
    print(f"  Criterion matches actual leg-coprimality for all "
          f"1<=a<={bound}, 0<=b<a : {all_ok}")
    print()


if __name__ == "__main__":
    demo_validity()
    demo_rigidity()
    demo_completeness()
    demo_primitivity()
    print("All demonstrations completed.")
