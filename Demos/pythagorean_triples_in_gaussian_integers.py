"""
demo.py — Pythagorean Triples in the Gaussian Integers Z[i]

Self-contained numerical demonstrations of the main results:

  * sq_add_sq_factor     : a^2 + b^2 = (a + i b)(a - i b)
  * gaussian_isotropic   : (s, i s, 0) and (s, -i s, 0) are Pythagorean triples
  * sq_add_sq_eq_zero_iff: x^2 + y^2 = 0 nontrivially  <=>  -1 is a square
  * triple_classification: Euclid-style x = s^2 - t^2, y = 2 s t, z = s^2 + t^2
  * gaussToQuat          : isometric ring embedding Z[i] -> H(Z)

All arithmetic is exact (integer-coordinate Gaussian integers and Lipschitz
quaternions implemented from scratch). Run with:  python demo.py
"""

from __future__ import annotations
from dataclasses import dataclass
from math import gcd
from typing import List, Tuple


# --------------------------------------------------------------------------
# Gaussian integers  Z[i] = { a + b i : a, b in Z },  i^2 = -1
# --------------------------------------------------------------------------
@dataclass(frozen=True)
class Gauss:
    re: int
    im: int

    def __add__(self, other: "Gauss") -> "Gauss":
        return Gauss(self.re + other.re, self.im + other.im)

    def __sub__(self, other: "Gauss") -> "Gauss":
        return Gauss(self.re - other.re, self.im - other.im)

    def __mul__(self, other: "Gauss") -> "Gauss":
        # (a+bi)(c+di) = (ac - bd) + (ad + bc) i
        return Gauss(
            self.re * other.re - self.im * other.im,
            self.re * other.im + self.im * other.re,
        )

    def conj(self) -> "Gauss":
        return Gauss(self.re, -self.im)

    def norm(self) -> int:
        # N(a + b i) = a^2 + b^2
        return self.re * self.re + self.im * self.im

    def __repr__(self) -> str:
        if self.im == 0:
            return f"{self.re}"
        if self.re == 0:
            return f"{self.im}i"
        sign = "+" if self.im >= 0 else "-"
        return f"({self.re} {sign} {abs(self.im)}i)"


I = Gauss(0, 1)        # the imaginary unit, a square root of -1
ONE = Gauss(1, 0)
ZERO = Gauss(0, 0)
UNITS: List[Gauss] = [Gauss(1, 0), Gauss(-1, 0), Gauss(0, 1), Gauss(0, -1)]


# --------------------------------------------------------------------------
# 1.  sq_add_sq_factor :  a^2 + b^2 = (a + i b)(a - i b)
# --------------------------------------------------------------------------
def check_factorization(a: Gauss, b: Gauss) -> bool:
    lhs = a * a + b * b
    rhs = (a + I * b) * (a - I * b)
    return lhs == rhs


# --------------------------------------------------------------------------
# 2.  gaussian_isotropic :  (s, +/- i s, 0) is a Pythagorean triple
# --------------------------------------------------------------------------
def isotropic_triple(s: Gauss, sign: int = 1) -> Tuple[Gauss, Gauss, Gauss]:
    y = (I * s) if sign >= 0 else (Gauss(0, -1) * s)
    return (s, y, ZERO)


def is_pythagorean(x: Gauss, y: Gauss, z: Gauss) -> bool:
    return x * x + y * y == z * z


# --------------------------------------------------------------------------
# 3.  sq_add_sq_eq_zero_iff (illustrated over Z/pZ):
#     x^2 + y^2 = 0 nontrivially  <=>  -1 is a square mod p
# --------------------------------------------------------------------------
def minus_one_is_square_mod(p: int) -> bool:
    return any((r * r) % p == (p - 1) % p for r in range(p))


def form_isotropic_mod(p: int) -> bool:
    for x in range(p):
        for y in range(p):
            if (x, y) != (0, 0) and (x * x + y * y) % p == 0:
                return True
    return False


# --------------------------------------------------------------------------
# 4.  triple_classification : Euclid's recipe over Z[i]
#     x = s^2 - t^2,  y = 2 s t,  z = s^2 + t^2
# --------------------------------------------------------------------------
def euclid_triple(s: Gauss, t: Gauss) -> Tuple[Gauss, Gauss, Gauss]:
    two = Gauss(2, 0)
    x = s * s - t * t
    y = two * s * t
    z = s * s + t * t
    return (x, y, z)


def generate_triples(bound: int) -> List[Tuple[Gauss, Gauss, Gauss]]:
    """All Euclid triples from |re|,|im| <= bound parameters s, t (t != 0)."""
    out: List[Tuple[Gauss, Gauss, Gauss]] = []
    rng = range(-bound, bound + 1)
    for sr in rng:
        for si in rng:
            for tr in rng:
                for ti in rng:
                    s, t = Gauss(sr, si), Gauss(tr, ti)
                    if t == ZERO:
                        continue
                    out.append(euclid_triple(s, t))
    return out


# --------------------------------------------------------------------------
# 5.  gaussToQuat : isometric ring embedding  Z[i] -> H(Z)
# --------------------------------------------------------------------------
@dataclass(frozen=True)
class Quat:
    a: int
    b: int
    c: int
    d: int  # a + b i + c j + d k

    def __add__(self, o: "Quat") -> "Quat":
        return Quat(self.a + o.a, self.b + o.b, self.c + o.c, self.d + o.d)

    def __mul__(self, o: "Quat") -> "Quat":
        a1, b1, c1, d1 = self.a, self.b, self.c, self.d
        a2, b2, c2, d2 = o.a, o.b, o.c, o.d
        # Hamilton product (i^2=j^2=k^2=ijk=-1)
        return Quat(
            a1 * a2 - b1 * b2 - c1 * c2 - d1 * d2,
            a1 * b2 + b1 * a2 + c1 * d2 - d1 * c2,
            a1 * c2 - b1 * d2 + c1 * a2 + d1 * b2,
            a1 * d2 + b1 * c2 - c1 * b2 + d1 * a2,
        )

    def norm(self) -> int:
        return self.a ** 2 + self.b ** 2 + self.c ** 2 + self.d ** 2


def gauss_to_quat(g: Gauss) -> Quat:
    return Quat(g.re, g.im, 0, 0)


# --------------------------------------------------------------------------
# Driver
# --------------------------------------------------------------------------
def main() -> None:
    print("=" * 68)
    print("Pythagorean Triples in the Gaussian Integers  Z[i]")
    print("=" * 68)

    print("\n[1] Factorization  a^2 + b^2 = (a + i b)(a - i b)")
    samples = [(Gauss(3, 1), Gauss(2, -4)), (Gauss(5, 0), Gauss(0, 7)),
               (Gauss(-2, 3), Gauss(1, 1))]
    for a, b in samples:
        ok = check_factorization(a, b)
        print(f"    a={a}, b={b}:  N-form factors correctly -> {ok}")

    print("\n[2] Isotropic 'ghost' triples  (s, +/- i s, 0)  with z = 0")
    for s in [Gauss(1, 0), Gauss(2, 1), Gauss(0, 3)]:
        x, y, z = isotropic_triple(s, +1)
        print(f"    s={s}:  ({x})^2 + ({y})^2 = ({z})^2   ->  "
              f"{is_pythagorean(x, y, z)}")
    x, y, z = isotropic_triple(ONE, +1)
    print(f"    canonical ghost triple (1, i, 0): "
          f"1^2 + i^2 = {(x*x + y*y).re} = 0^2")

    print("\n[3] Root cause:  x^2+y^2=0 nontrivially  <=>  -1 is a square")
    for p in [2, 3, 5, 7, 11, 13, 17]:
        iso = form_isotropic_mod(p)
        sq = minus_one_is_square_mod(p)
        tag = "p=1 mod 4" if p % 4 == 1 else ("p=2" if p == 2 else "p=3 mod 4")
        print(f"    mod {p:>2} ({tag:>9}): isotropic={iso!s:>5}  "
              f"-1 is square={sq!s:>5}  agree={iso == sq}")

    print("\n[4] Euclid classification  x=s^2-t^2, y=2st, z=s^2+t^2")
    demo_params = [(Gauss(2, 0), Gauss(1, 0)),       # classical (3,4,5)
                   (Gauss(3, 0), Gauss(2, 0)),       # classical (5,12,13)
                   (Gauss(1, 1), Gauss(1, 0)),       # genuinely Gaussian
                   (Gauss(2, 1), Gauss(1, -1))]      # genuinely Gaussian
    for s, t in demo_params:
        x, y, z = euclid_triple(s, t)
        print(f"    s={s}, t={t}:  x={x}, y={y}, z={z}  ->  "
              f"valid={is_pythagorean(x, y, z)}")

    triples = generate_triples(bound=2)
    allok = all(is_pythagorean(*tr) for tr in triples)
    print(f"    swept {len(triples)} generated triples (|coords| <= 2): "
          f"all valid = {allok}")

    print("\n[5] Quaternion embedding  Phi: Z[i] -> H(Z)  (isometric ring hom)")
    alpha, beta = Gauss(3, 4), Gauss(2, -1)
    # norm preserved
    npres = gauss_to_quat(alpha).norm() == alpha.norm()
    # ring hom: Phi(ab) = Phi(a)Phi(b)
    hom = gauss_to_quat(alpha * beta) == gauss_to_quat(alpha) * gauss_to_quat(beta)
    print(f"    N_H(Phi({alpha})) = {gauss_to_quat(alpha).norm()} = "
          f"N({alpha}) = {alpha.norm()}  ->  isometry={npres}")
    print(f"    Phi(ab) = Phi(a)Phi(b) for a={alpha}, b={beta}  ->  "
          f"ring-hom={hom}")

    print("\n[6] Two-square (Brahmagupta-Fibonacci) identity / multiplicativity")
    a, b, c, d = 3, 4, 2, 7
    lhs = (a * a + b * b) * (c * c + d * d)
    rhs = (a * c - b * d) ** 2 + (a * d + b * c) ** 2
    print(f"    ({a}^2+{b}^2)({c}^2+{d}^2) = {lhs} = "
          f"({a*c-b*d})^2 + ({a*d+b*c})^2 = {rhs}  ->  {lhs == rhs}")

    print("\nAll demonstrations complete.")


if __name__ == "__main__":
    main()
