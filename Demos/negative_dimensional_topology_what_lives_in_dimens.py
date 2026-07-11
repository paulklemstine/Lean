"""
Negative-Dimensional Topology: Numerical Demonstrations
=======================================================

A self-contained model of virtual graded spaces as Laurent polynomials
Z[t, t^{-1}], where the monomial t^d means "one cell in dimension d" and
negative powers are negative-dimensional cells. The Euler characteristic
is the ring homomorphism chi: t -> -1, i.e. chi(sum b_d t^d) = sum (-1)^d b_d.

This script demonstrates:
  * chi as an additive and multiplicative (Kunneth) invariant,
  * the main formula chi(X) = (-1)^n |pi_0(X)| for dim X = -n,
  * "what lives in dimension -1": chi = -k for k components,
  * suspension/desuspension flipping the sign of chi and being inverse,
  * stabilization returning a (-n)-space to dimension 0,
  * two contrarian facts: chi can be positive in negative dimension, and
    chi is not injective (it only sees parity of the dimension).

Only integer arithmetic is used; there are no external dependencies.
"""

from __future__ import annotations

from collections import defaultdict
from typing import Dict


# A virtual graded space is a finitely supported map dimension -> cell count.
VSpace = Dict[int, int]


def cell(d: int, c: int) -> VSpace:
    """`c` cells placed in dimension `d`: the monomial c * t^d."""
    return {d: c} if c != 0 else {}


def normalize(x: VSpace) -> VSpace:
    """Drop zero coefficients for a canonical representation."""
    return {d: c for d, c in x.items() if c != 0}


def add(x: VSpace, y: VSpace) -> VSpace:
    """Disjoint union / wedge: coefficients accumulate degreewise."""
    out: Dict[int, int] = defaultdict(int)
    for d, c in x.items():
        out[d] += c
    for d, c in y.items():
        out[d] += c
    return normalize(dict(out))


def mul(x: VSpace, y: VSpace) -> VSpace:
    """Product of spaces: t^a * t^b = t^{a+b} (Kunneth-style convolution)."""
    out: Dict[int, int] = defaultdict(int)
    for da, ca in x.items():
        for db, cb in y.items():
            out[da + db] += ca * cb
    return normalize(dict(out))


def chi(x: VSpace) -> int:
    """Euler characteristic: substitute t = -1, i.e. sum (-1)^d b_d."""
    return sum((1 if d % 2 == 0 else -1) * c for d, c in x.items())


def susp(x: VSpace) -> VSpace:
    """Suspension: multiply by t (raise every dimension by one)."""
    return mul(cell(1, 1), x)


def desusp(x: VSpace) -> VSpace:
    """Desuspension: multiply by t^{-1} (lower every dimension by one)."""
    return mul(cell(-1, 1), x)


def susp_iter(n: int, x: VSpace) -> VSpace:
    """Iterated suspension Sigma^n."""
    out = dict(x)
    for _ in range(n):
        out = susp(out)
    return out


def main() -> None:
    print("=" * 68)
    print("Negative-Dimensional Topology  --  numerical demonstrations")
    print("=" * 68)

    # 1. Main theorem: chi(X) = (-1)^n |pi_0(X)| for dim X = -n.
    print("\n[1] Main theorem  chi(cell(-n, k)) = (-1)^n * k")
    for n in range(0, 6):
        for k in (1, 3):
            X = cell(-n, k)
            expected = ((-1) ** n) * k
            got = chi(X)
            flag = "OK" if got == expected else "MISMATCH"
            print(f"    dim=-{n:<2} k={k}:  chi = {got:+d}   "
                  f"(expected {expected:+d})  [{flag}]")

    # 2. What lives in dimension -1.
    print("\n[2] What lives in dimension -1:  chi = -k")
    for k in range(1, 5):
        print(f"    {k}-component (-1)-space:  chi = {chi(cell(-1, k)):+d}")
    print("    The (-1)-sphere (one point in dim -1) has chi =",
          f"{chi(cell(-1, 1)):+d}")

    # 3. chi is a ring homomorphism: additive and multiplicative.
    print("\n[3] chi is a ring homomorphism")
    X = add(cell(0, 1), cell(-1, 2))     # 1 point in dim 0, 2 in dim -1
    Y = add(cell(-2, 1), cell(1, 1))     # 1 in dim -2, 1 in dim 1
    print(f"    chi(X)         = {chi(X):+d}")
    print(f"    chi(Y)         = {chi(Y):+d}")
    print(f"    chi(X + Y)     = {chi(add(X, Y)):+d}"
          f"   vs chi(X)+chi(Y) = {chi(X) + chi(Y):+d}")
    print(f"    chi(X * Y)     = {chi(mul(X, Y)):+d}"
          f"   vs chi(X)*chi(Y) = {chi(X) * chi(Y):+d}")
    print(f"    chi(point=1)   = {chi(cell(0, 1)):+d}")

    # 4. Suspension / desuspension flip the sign; are mutually inverse.
    print("\n[4] Suspension and desuspension")
    print(f"    chi(X)          = {chi(X):+d}")
    print(f"    chi(Sigma X)    = {chi(susp(X)):+d}  (= -chi(X))")
    print(f"    chi(Sigma^-1 X) = {chi(desusp(X)):+d}  (= -chi(X))")
    print(f"    Sigma(Sigma^-1 X) == X ?  {normalize(susp(desusp(X))) == normalize(X)}")
    print(f"    Sigma^-1(Sigma X) == X ?  {normalize(desusp(susp(X))) == normalize(X)}")

    # 5. Stabilization: suspend a (-n)-space n times -> dimension 0.
    print("\n[5] Stabilization  Sigma^n(cell(-n,k)) = cell(0,k)")
    for n in range(1, 5):
        k = 3
        stabilized = susp_iter(n, cell(-n, k))
        print(f"    n={n}: Sigma^{n}(cell(-{n},{k})) = {stabilized}  "
              f"chi = {chi(stabilized):+d}  (= k = {k})")

    # 6. Contrarian result A: negative dimension, positive chi.
    print("\n[6] Contrarian: negative dimension can have chi > 0")
    print(f"    cell(-2, 1):  dim = -2 < 0  but  chi = {chi(cell(-2, 1)):+d}")

    # 7. Contrarian result B: chi is not injective.
    print("\n[7] Contrarian: chi is not injective (only sees parity of dim)")
    a, b = cell(0, 1), cell(2, 1)
    print(f"    cell(0,1) != cell(2,1) as spaces, yet "
          f"chi = {chi(a):+d} = {chi(b):+d}")
    c, d = cell(-1, 1), cell(1, 1)
    print(f"    cell(-1,1) != cell(1,1) as spaces, yet "
          f"chi = {chi(c):+d} = {chi(d):+d}")

    print("\n" + "=" * 68)
    print("All demonstrations complete.")
    print("=" * 68)


if __name__ == "__main__":
    main()
