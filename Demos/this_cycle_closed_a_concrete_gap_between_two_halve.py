"""
demo.py — The Fibonacci Law of Apparition as an Arithmetic-Height / Tropical Duality
====================================================================================

Self-contained numerical demonstrations of the results formalised in
`FibonacciApparitionDuality.lean`:

  * Existence of the rank of apparition R(m) via finite-state pure periodicity
    of the Fibonacci state pair (Fib(n), Fib(n+1)) mod m.
  * The duality theorem:  m | Fib(n)  <=>  R(m) | n.
  * The gcd -> AND (min-plus -> Boolean) lattice homomorphism.
  * The p-adic arithmetic-height capstone:  |Fib(n)|_p < 1  <=>  R(p) | n.
  * The classical Pisano/companion-matrix bound  R(p) | p - (5|p).

Every function is inlined and uses only the Python standard library.
Run:  python3 demo.py
"""

from __future__ import annotations

from math import gcd
from fractions import Fraction
from typing import Dict, List, Tuple


# --------------------------------------------------------------------------- #
# Core arithmetic
# --------------------------------------------------------------------------- #
def fib(n: int) -> int:
    """The n-th Fibonacci number, Fib(0)=0, Fib(1)=1 (fast doubling, O(log n))."""
    def _pair(k: int) -> Tuple[int, int]:
        # returns (Fib(k), Fib(k+1))
        if k == 0:
            return (0, 1)
        a, b = _pair(k >> 1)
        c = a * (2 * b - a)          # Fib(2t)
        d = a * a + b * b            # Fib(2t+1)
        if k & 1:
            return (d, c + d)
        return (c, d)
    return _pair(n)[0]


def fib_rank_by_iteration(m: int) -> int:
    """
    Rank of apparition R(m): least k > 0 with m | Fib(k).

    Computed by iterating the transition T(a, b) = (b, a + b) on the reduced
    state pair (Fib(k) mod m, Fib(k+1) mod m), starting from (0, 1).  This is
    the algorithmic shadow of the existence proof: a bijection of the finite
    set (Z/mZ)^2 has purely periodic orbits, so the first coordinate must
    return to 0.  Runs in O(R(m)) steps with O(1) state.
    """
    if m < 1:
        raise ValueError("rank of apparition is defined only for m >= 1")
    if m == 1:
        return 1  # 1 divides Fib(1) = 1
    a, b = 0, 1            # (Fib(0), Fib(1)) mod m
    for k in range(1, m * m + 1):
        a, b = b % m, (a + b) % m   # advance to (Fib(k), Fib(k+1)) mod m
        if a == 0:
            return k
    raise RuntimeError("unreachable: periodicity guarantees a return")


def p_adic_valuation(z: int, p: int) -> int:
    """v_p(z): the exponent of p in z (z != 0)."""
    if z == 0:
        raise ValueError("v_p(0) is undefined (conventionally +infinity)")
    v = 0
    z = abs(z)
    while z % p == 0:
        z //= p
        v += 1
    return v


def p_adic_norm(q: Fraction, p: int) -> Fraction:
    """|q|_p = p^{-v_p(q)}, with |0|_p = 0.  The exponentiated tropical valuation."""
    if q == 0:
        return Fraction(0)
    num_v = p_adic_valuation(q.numerator, p)
    den_v = p_adic_valuation(q.denominator, p)
    v = num_v - den_v
    return Fraction(p) ** (-v)


def legendre_symbol(a: int, p: int) -> int:
    """(a | p) for odd prime p: +1 if QR, -1 if non-residue, 0 if p | a."""
    a %= p
    if a == 0:
        return 0
    ls = pow(a, (p - 1) // 2, p)
    return -1 if ls == p - 1 else ls


def is_prime(n: int) -> bool:
    if n < 2:
        return False
    i = 2
    while i * i <= n:
        if n % i == 0:
            return False
        i += 1
    return True


# --------------------------------------------------------------------------- #
# Demonstration 1: existence and table of ranks
# --------------------------------------------------------------------------- #
def demo_existence_and_ranks() -> None:
    print("=" * 72)
    print("DEMO 1 — Existence of the rank of apparition R(m)")
    print("=" * 72)
    print("The Fibonacci sequence:")
    print("  " + ", ".join(str(fib(n)) for n in range(16)) + ", ...")
    print()
    print(f"{'m':>4} | {'R(m)':>5} | first Fibonacci multiple")
    print("-" * 50)
    for m in range(1, 16):
        r = fib_rank_by_iteration(m)
        print(f"{m:>4} | {r:>5} | Fib({r}) = {fib(r)}  ({fib(r)} = {m}*{fib(r)//m})")
    print()


# --------------------------------------------------------------------------- #
# Demonstration 2: the duality theorem  m | Fib(n) <=> R(m) | n
# --------------------------------------------------------------------------- #
def demo_duality() -> None:
    print("=" * 72)
    print("DEMO 2 — Duality:  m | Fib(n)  <=>  R(m) | n")
    print("=" * 72)
    for m in (7, 11, 13):
        r = fib_rank_by_iteration(m)
        print(f"\n  m = {m},  R(m) = {r}")
        hits_value: List[int] = []
        hits_index: List[int] = []
        for n in range(0, 41):
            if fib(n) % m == 0:
                hits_value.append(n)
            if n % r == 0:
                hits_index.append(n)
        print(f"    indices n<=40 with m | Fib(n):  {hits_value}")
        print(f"    indices n<=40 with R(m) | n  :  {hits_index}")
        assert hits_value == hits_index, "duality FAILED"
        print("    -> the two sets coincide  (duality verified)")
    print()


# --------------------------------------------------------------------------- #
# Demonstration 3: gcd -> AND (min-plus -> Boolean) homomorphism
# --------------------------------------------------------------------------- #
def demo_homomorphism() -> None:
    print("=" * 72)
    print("DEMO 3 — gcd -> AND homomorphism:")
    print("         m | Fib(gcd(a,b))  <=>  (m | Fib(a)) and (m | Fib(b))")
    print("=" * 72)
    m = 7
    print(f"  m = {m}  (R(m) = {fib_rank_by_iteration(m)})\n")
    print(f"  {'a':>3} {'b':>3} | {'lhs: m|Fib(gcd)':>16} | {'rhs: both':>10}")
    print("  " + "-" * 40)
    for (a, b) in [(8, 16), (8, 12), (16, 24), (10, 15), (24, 40)]:
        lhs = (fib(gcd(a, b)) % m == 0)
        rhs = (fib(a) % m == 0) and (fib(b) % m == 0)
        print(f"  {a:>3} {b:>3} | {str(lhs):>16} | {str(rhs):>10}")
        assert lhs == rhs, "homomorphism FAILED"
    print("\n  -> tropical 'min' (gcd of indices) maps to logical AND.\n")


# --------------------------------------------------------------------------- #
# Demonstration 4: p-adic arithmetic-height capstone
# --------------------------------------------------------------------------- #
def demo_height() -> None:
    print("=" * 72)
    print("DEMO 4 — p-adic height capstone:  |Fib(n)|_p < 1  <=>  R(p) | n")
    print("=" * 72)
    p = 7
    r = fib_rank_by_iteration(p)
    print(f"  p = {p},  R(p) = {r}\n")
    print(f"  {'n':>3} | {'Fib(n)':>8} | {'|Fib(n)|_7':>12} | {'< 1?':>5} | {'R(p)|n?':>7}")
    print("  " + "-" * 50)
    for n in range(1, 25):
        f = fib(n)
        norm = p_adic_norm(Fraction(f), p)
        lt1 = norm < 1
        divides = (n % r == 0)
        print(f"  {n:>3} | {f:>8} | {str(norm):>12} | {str(lt1):>5} | {str(divides):>7}")
        assert lt1 == divides, "height capstone FAILED"
    print("\n  -> the non-archimedean size dips below 1 exactly on multiples of R(p).\n")


# --------------------------------------------------------------------------- #
# Demonstration 5: the Pisano / companion-matrix bound R(p) | p - (5|p)
# --------------------------------------------------------------------------- #
def demo_pisano_bound() -> None:
    print("=" * 72)
    print("DEMO 5 — Pisano bound:  R(p) | p - (5|p)   for odd primes p != 5")
    print("=" * 72)
    print(f"  {'p':>4} | {'R(p)':>5} | {'(5|p)':>6} | {'p-(5|p)':>8} | divides?")
    print("  " + "-" * 48)
    for p in [pr for pr in range(3, 60) if is_prime(pr) and pr != 5]:
        r = fib_rank_by_iteration(p)
        ls = legendre_symbol(5, p)
        bound = p - ls
        ok = (bound % r == 0)
        print(f"  {p:>4} | {r:>5} | {ls:>6} | {bound:>8} | {ok}")
        assert ok, "Pisano bound FAILED"
    print("\n  -> the apparition clock never ticks slower than p + 1.\n")


# --------------------------------------------------------------------------- #
# Demonstration 6: huge-index divisibility WITHOUT computing Fib(n)
# --------------------------------------------------------------------------- #
def demo_large_index() -> None:
    print("=" * 72)
    print("DEMO 6 — Deciding m | Fib(n) for astronomically large n")
    print("=" * 72)
    m = 13
    r = fib_rank_by_iteration(m)
    big_n = 7 ** 50           # ~42 digit index; Fib(big_n) is unthinkably large
    decision = (big_n % r == 0)
    print(f"  m = {m},  R(m) = {r}")
    print(f"  n = 7^50 = {big_n}")
    print(f"  R(m) | n ?  ->  {big_n} mod {r} = {big_n % r}")
    print(f"  Conclusion: {m} {'DIVIDES' if decision else 'does NOT divide'} Fib(n)")
    print("  (decided by a single modular reduction; Fib(n) never computed)\n")


def main() -> None:
    demo_existence_and_ranks()
    demo_duality()
    demo_homomorphism()
    demo_height()
    demo_pisano_bound()
    demo_large_index()
    print("All demonstrations completed and all assertions passed.")


if __name__ == "__main__":
    main()


"""
Visualization: the apparition lattice and the p-adic height profile of Fibonacci.

Produces two panels:
  (left)  a divisibility heatmap: cell (m, n) shaded when m | Fib(n), revealing
          the perfectly periodic vertical stripes spaced by R(m);
  (right) the 7-adic height |Fib(n)|_7 as a stem plot, dipping below 1 exactly
          on multiples of R(7) = 8.

Requires: matplotlib, numpy.  Run:  python3 visualization.py
"""
from __future__ import annotations
from fractions import Fraction
import numpy as np
import matplotlib.pyplot as plt


def fib(n: int) -> int:
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def fib_rank(m: int) -> int:
    if m == 1:
        return 1
    a, b = 0, 1
    for k in range(1, m * m + 1):
        a, b = b % m, (a + b) % m
        if a == 0:
            return k
    raise RuntimeError


def p_adic_norm(z: int, p: int) -> float:
    if z == 0:
        return 0.0
    v = 0
    z = abs(z)
    while z % p == 0:
        z //= p
        v += 1
    return float(Fraction(p) ** (-v))


M, N = 12, 40
grid = np.zeros((M, N + 1))
for m in range(1, M + 1):
    for n in range(0, N + 1):
        grid[m - 1, n] = 1.0 if (n > 0 and fib(n) % m == 0) else 0.0

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

ax1.imshow(grid, aspect="auto", cmap="viridis", origin="lower",
           extent=[0, N, 1, M + 1])
ax1.set_xlabel("index n")
ax1.set_ylabel("modulus m")
ax1.set_title("Apparition lattice:  m | Fib(n)\n(stripes spaced by the rank R(m))")
for m in range(1, M + 1):
    r = fib_rank(m)
    ax1.text(N + 0.5, m + 0.5, f"R={r}", va="center", fontsize=7)

p = 7
ns = list(range(1, N + 1))
heights = [p_adic_norm(fib(n), p) for n in ns]
ax2.stem(ns, heights, basefmt=" ")
ax2.axhline(1.0, color="red", ls="--", lw=1, label="height = 1")
r7 = fib_rank(p)
for n in ns:
    if n % r7 == 0:
        ax2.axvline(n, color="green", alpha=0.25)
ax2.set_xlabel("index n")
ax2.set_ylabel(r"$|Fib(n)|_7$")
ax2.set_title(f"7-adic height of Fib(n)\n(dips below 1 exactly on multiples of R(7)={r7})")
ax2.legend()

plt.tight_layout()
plt.savefig("fibonacci_apparition.png", dpi=150)
print("wrote fibonacci_apparition.png")
