"""
demo.py — Numerical demonstrations of Gleason's length theorem for binary codes.

Main theorem (proved formally elsewhere):
    Every binary DOUBLY-EVEN SELF-DUAL code C of length n satisfies 8 | n.

The proof rests on a single MASTER IDENTITY over the complex numbers:

        |C|  =  (1 + i)^n

obtained by evaluating one double Gauss sum in two ways:
  (A) via character orthogonality on the self-dual (hence linear) code, and
  (B) via the per-coordinate Fourier factorization of  x |-> i^{wt(x)}.

Because |C| is a POSITIVE REAL while the powers of (1+i) rotate with period 8
((1+i)^4 = -4, (1+i)^8 = 16), positivity forces 8 | n.

This script verifies every link in that chain on explicit codes, with no
external dependencies (pure Python standard library).
"""

from __future__ import annotations

import cmath
import itertools
from typing import Iterable, List, Sequence, Tuple

# A binary vector is a tuple of 0/1 ints; a code is a list of such vectors.
Vector = Tuple[int, ...]
Code = List[Vector]


# ---------------------------------------------------------------------------
# Core combinatorial primitives
# ---------------------------------------------------------------------------

def weight(x: Vector) -> int:
    """Hamming weight: number of nonzero coordinates."""
    return sum(1 for b in x if b == 1)


def overlap(x: Vector, y: Vector) -> int:
    """Number of coordinates where both x and y equal 1."""
    return sum(1 for a, b in zip(x, y) if a == 1 and b == 1)


def inner_product(x: Vector, y: Vector) -> int:
    """Binary inner product <x, y> in F_2 (returns 0 or 1)."""
    return sum(a * b for a, b in zip(x, y)) % 2


def vec_add(x: Vector, y: Vector) -> Vector:
    """Coordinatewise addition modulo 2."""
    return tuple((a + b) % 2 for a, b in zip(x, y))


# ---------------------------------------------------------------------------
# Building codes from a generator matrix
# ---------------------------------------------------------------------------

def span(generators: Sequence[Vector]) -> Code:
    """All 2^k linear combinations (mod 2) of the generator rows."""
    n = len(generators[0])
    k = len(generators)
    code: List[Vector] = []
    for coeffs in itertools.product((0, 1), repeat=k):
        acc: Vector = tuple(0 for _ in range(n))
        for c, g in zip(coeffs, generators):
            if c:
                acc = vec_add(acc, g)
        code.append(acc)
    # de-duplicate while preserving order
    seen = set()
    unique: Code = []
    for v in code:
        if v not in seen:
            seen.add(v)
            unique.append(v)
    return unique


# The extended Hamming code [8,4,4] = RM(1,3): the mod-2 shadow of the E8 lattice.
HAMMING_GEN: List[Vector] = [
    (1, 1, 1, 1, 1, 1, 1, 1),
    (0, 0, 0, 0, 1, 1, 1, 1),
    (0, 0, 1, 1, 0, 0, 1, 1),
    (0, 1, 0, 1, 0, 1, 0, 1),
]


# ---------------------------------------------------------------------------
# Code-theoretic predicates
# ---------------------------------------------------------------------------

def is_doubly_even(code: Code) -> bool:
    """True iff every codeword has weight divisible by 4."""
    return all(weight(v) % 4 == 0 for v in code)


def is_self_dual(code: Code) -> bool:
    """True iff C = C^perp: x in C  <=>  x orthogonal to all of C."""
    n = len(code[0])
    code_set = set(code)
    for x in itertools.product((0, 1), repeat=n):
        orthogonal = all(inner_product(x, c) == 0 for c in code)
        if (x in code_set) != orthogonal:
            return False
    return True


def weight_enumerator(code: Code) -> dict:
    """Map weight -> number of codewords with that weight."""
    enum: dict = {}
    for v in code:
        w = weight(v)
        enum[w] = enum.get(w, 0) + 1
    return dict(sorted(enum.items()))


# ---------------------------------------------------------------------------
# The Gauss sum and the master identity
# ---------------------------------------------------------------------------

I = complex(0, 1)


def gauss_sum(code: Code) -> complex:
    """Sum over codewords of i^{wt(c)}.  Equals |C| when C is doubly-even."""
    return sum(I ** weight(c) for c in code)


def fourier_iwt(y: Vector) -> complex:
    """
    Discrete Fourier transform of x |-> i^{wt(x)} evaluated at y:

        sum_x i^{wt(x)} (-1)^{<x,y>}  =  (1+i)^{n-wt(y)} (1-i)^{wt(y)}.
    """
    n = len(y)
    w = weight(y)
    return (1 + I) ** (n - w) * (1 - I) ** w


def fourier_iwt_bruteforce(y: Vector) -> complex:
    """Same transform computed by literal summation over all 2^n inputs."""
    n = len(y)
    total = 0j
    for x in itertools.product((0, 1), repeat=n):
        total += (I ** weight(x)) * ((-1) ** inner_product(x, y))
    return total


def one_plus_i_power(n: int) -> complex:
    """(1+i)^n."""
    return (1 + I) ** n


def is_positive_real(z: complex, tol: float = 1e-9) -> bool:
    """True iff z is a positive real number (within numerical tolerance)."""
    return abs(z.imag) < tol and z.real > tol


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def banner(title: str) -> None:
    print("\n" + "=" * 70)
    print(title)
    print("=" * 70)


def demo_hamming_properties() -> None:
    banner("1. The extended Hamming code [8,4,4] is doubly-even and self-dual")
    code = span(HAMMING_GEN)
    print(f"  Length n            = {len(code[0])}")
    print(f"  Number of codewords = {len(code)}  (= 2^4)")
    print(f"  Doubly-even?        = {is_doubly_even(code)}")
    print(f"  Self-dual?          = {is_self_dual(code)}")
    print(f"  Weight enumerator   = {weight_enumerator(code)}")
    print("  -> matches 1 + 14 x^4 + x^8, minimum distance d = 4.")


def demo_fourier_factorization() -> None:
    banner("2. Per-coordinate Fourier factorization of  x |-> i^{wt(x)}")
    print("  Checking  sum_x i^{wt(x)}(-1)^{<x,y>} = (1+i)^{n-w}(1-i)^w  for all y:")
    n = 4
    all_ok = True
    for y in itertools.product((0, 1), repeat=n):
        lhs = fourier_iwt_bruteforce(y)
        rhs = fourier_iwt(y)
        ok = abs(lhs - rhs) < 1e-9
        all_ok = all_ok and ok
    print(f"  All 2^{n} = {2**n} test vectors agree: {all_ok}")
    print("\n  Doubly-even collapse:  for 4 | w,  the value collapses to (1+i)^n.")
    for y in [(0, 0, 0, 0, 0, 0, 0, 0),
              (1, 1, 1, 1, 0, 0, 0, 0),
              (1, 1, 1, 1, 1, 1, 1, 1)]:
        val = fourier_iwt(y)
        target = one_plus_i_power(len(y))
        print(f"    wt(y)={weight(y):>2}:  transform={val:>14.4g}  "
              f"(1+i)^n={target:>14.4g}  equal={abs(val-target)<1e-9}")


def demo_master_identity() -> None:
    banner("3. The master identity  |C| = (1+i)^n  on the Hamming code")
    code = span(HAMMING_GEN)
    n = len(code[0])
    lhs = gauss_sum(code)          # equals |C| for doubly-even C
    rhs = one_plus_i_power(n)
    print(f"  Gauss sum  sum_c i^{{wt(c)}} = {lhs}")
    print(f"  |C|                          = {len(code)}")
    print(f"  (1+i)^{n}                      = {rhs}")
    print(f"  Master identity |C| = (1+i)^n holds: {abs(lhs - rhs) < 1e-9}")


def demo_eight_tower() -> None:
    banner("4. Why 8: the (1+i)-tower is a positive real only when 8 | n")
    print(f"  {'n':>3} | {'(1+i)^n':>20} | positive real? | 8 | n ?")
    print("  " + "-" * 56)
    for n in range(0, 17):
        z = one_plus_i_power(n)
        pos = is_positive_real(z)
        div = (n % 8 == 0)
        zstr = f"{z.real:.0f}{'+' if z.imag >= 0 else '-'}{abs(z.imag):.0f}i"
        flag = "  <-- consistent" if pos == div else "  *** MISMATCH"
        print(f"  {n:>3} | {zstr:>20} | {str(pos):>13} | {str(div):>6}{flag}")
    print("\n  'positive real' and '8 | n' coincide exactly: this IS the theorem.")


def demo_no_length_4() -> None:
    banner("5. Sharpness: no doubly-even self-dual code of length 4 exists")
    print("  Exhaustively searching all linear codes of length 4 ...")
    n = 4
    found = False
    all_vecs = list(itertools.product((0, 1), repeat=n))
    # search over all subsets generated by up to n basis vectors is expensive;
    # instead enumerate all 2^(2^n) subsets is infeasible, so we use the
    # structural fact: a self-dual code has size 2^{n/2}=4 and is linear.
    for gens in itertools.combinations(all_vecs, 2):
        code = span(list(gens))
        if len(code) != 4:
            continue
        if is_doubly_even(code) and is_self_dual(code):
            found = True
            print(f"    (unexpected) found: {code}")
    print(f"  Doubly-even self-dual code of length 4 found: {found}")
    print("  -> Confirms 4 | n is NOT sharp; the true constant is 8.")


def main() -> None:
    print("GLEASON'S LENGTH THEOREM — NUMERICAL DEMONSTRATIONS")
    print("Doubly-even self-dual binary codes have length divisible by 8.")
    demo_hamming_properties()
    demo_fourier_factorization()
    demo_master_identity()
    demo_eight_tower()
    demo_no_length_4()
    banner("Summary")
    print("  * Hamming [8,4,4] is doubly-even, self-dual, enumerator 1+14x^4+x^8.")
    print("  * Fourier transform of i^{wt} factors coordinatewise.")
    print("  * Master identity |C| = (1+i)^n verified numerically.")
    print("  * (1+i)^n is a positive real  <=>  8 | n.")
    print("  * No length-4 example exists: the constant 8 is sharp.")


if __name__ == "__main__":
    main()
