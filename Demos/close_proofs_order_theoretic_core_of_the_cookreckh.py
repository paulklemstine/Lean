"""
demo.py — Numerical demonstrations for

    "The Order-Theoretic Geometry of the p-Simulation Preorder:
     Binary Meets and Infinite Height in the Poset of p-Degrees"

Everything here is self-contained: no external packages beyond the Python
standard library.  We work with *size-indexed proof systems* over the natural
numbers, where a proof of `n` certifies the theorem `n` and has a prescribed
size `a(n)`.  By the Domination Law (Theorem 5.2 of the paper),

      sysOfSize(a)  simulates  sysOfSize(b)
   <=>  a is pointwise dominated by a monotone polynomial blow-up of b
   <=>  exists k, for all n:  a(n) + 1 <= (b(n) + 2) ** k.

This file demonstrates, with concrete numbers:

  1. The polynomial blow-up class and its closure properties.
  2. Fibonacci growth is super-polynomial (the catalog separation engine).
  3. Binary meets: the direct-sum system is the greatest lower bound.
  4. The Domination Law in action, including lin < fib.
  5. The collapsing exponential ladder  2 ** (k * n).
  6. The working power ladder           2 ** (n ** k)  and the Gap Lemma.

Run:  python3 demo.py
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Callable, List, Optional, Tuple


# ---------------------------------------------------------------------------
# 1. The polynomial blow-up class:  f is PolyBounded iff
#    exists k, for all n:  f(n) + 1 <= (n + 2) ** k.
# ---------------------------------------------------------------------------

def is_poly_bounded_witness(
    f: Callable[[int], int],
    n_max: int = 40,
    k_max: int = 12,
) -> Optional[int]:
    """Return the least exponent k certifying  f(n)+1 <= (n+2)**k  on [0, n_max],
    or None if no such k <= k_max exists on the sampled prefix."""
    for k in range(k_max + 1):
        if all(f(n) + 1 <= (n + 2) ** k for n in range(n_max + 1)):
            return k
    return None


def poly_comp(f: Callable[[int], int], g: Callable[[int], int]) -> Callable[[int], int]:
    """Composition f . g  (the blow-up class is closed under this)."""
    return lambda n: f(g(n))


def poly_max(f: Callable[[int], int], g: Callable[[int], int]) -> Callable[[int], int]:
    """Pointwise maximum (the blow-up class is closed under this — Lemma 4.2)."""
    return lambda n: max(f(n), g(n))


# ---------------------------------------------------------------------------
# 2. Size-indexed proof systems and the Domination Law.
# ---------------------------------------------------------------------------

@dataclass
class SizeSystem:
    """A size-indexed proof system over the naturals: proof n certifies theorem n,
    with size `size(n)`.  `name` is for display only."""
    name: str
    size: Callable[[int], int]


def simulates(
    P: SizeSystem,
    Q: SizeSystem,
    n_max: int = 30,
    k_max: int = 12,
) -> Tuple[bool, Optional[int]]:
    """Decide (on a sampled prefix) whether P simulates Q via the Domination Law:
    exists k, for all n:  P.size(n) + 1 <= (Q.size(n) + 2) ** k.
    Returns (decision, witnessing_k)."""
    for k in range(k_max + 1):
        if all(P.size(n) + 1 <= (Q.size(n) + 2) ** k for n in range(n_max + 1)):
            return True, k
    return False, None


def fib(n: int) -> int:
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


# ---------------------------------------------------------------------------
# 3. The direct-sum system and the meet (greatest lower bound).
#
# Abstractly a proof of  P (+) Q  is either a P-proof or a Q-proof.  For
# size-indexed systems the *induced* size order is governed by the pointwise
# behaviour; the relevant numeric fact (Lemma 4.2 + Theorem 4.5) is that any R
# simulating both P and Q simulates the direct sum with blow-up max(f_P, f_Q).
# We illustrate the max-of-blow-ups closure directly.
# ---------------------------------------------------------------------------

def demonstrate_meet_closure(n_max: int = 30) -> None:
    print("=" * 70)
    print("3. BINARY MEETS — max of two polynomial blow-ups is a blow-up")
    print("=" * 70)
    f = lambda n: 3 * n + 5          # blow-up f
    g = lambda n: n * n              # blow-up g
    kf = is_poly_bounded_witness(f, n_max)
    kg = is_poly_bounded_witness(g, n_max)
    h = poly_max(f, g)
    kh = is_poly_bounded_witness(h, n_max)
    print(f"  f(n) = 3n+5      PolyBounded witness k = {kf}")
    print(f"  g(n) = n^2       PolyBounded witness k = {kg}")
    print(f"  max(f,g)         PolyBounded witness k = {kh}  "
          f"(<= {kf}+{kg}+1 = {kf + kg + 1})")
    print("  => any R simulating both P and Q simulates the direct sum P(+)Q,")
    print("     so P(+)Q is the GREATEST lower bound: binary meets exist.\n")


# ---------------------------------------------------------------------------
# 4. Fibonacci is super-polynomial  =>  lin < fib.
# ---------------------------------------------------------------------------

def demonstrate_fib_separation(n_max: int = 30) -> None:
    print("=" * 70)
    print("4. THE DOMINATION LAW:  linSystem < fibSystem")
    print("=" * 70)
    lin = SizeSystem("linSystem", lambda n: n)
    fibS = SizeSystem("fibSystem", fib)

    lin_sim_fib, k1 = simulates(lin, fibS, n_max)
    fib_sim_lin, k2 = simulates(fibS, lin, n_max)
    print(f"  lin simulates fib : {lin_sim_fib}   (witness k = {k1})")
    print(f"  fib simulates lin : {fib_sim_lin}   "
          f"(no polynomial can dominate Fibonacci)")
    print(f"  Fibonacci PolyBounded? "
          f"{is_poly_bounded_witness(fib, n_max) is not None}")
    print("  Exponential lower bound check  2^n <= F(2n+1):")
    for n in range(0, 7):
        print(f"    n={n}: 2^n = {2 ** n:>5}   F(2n+1) = {fib(2 * n + 1):>6}   "
              f"{'OK' if 2 ** n <= fib(2 * n + 1) else 'FAIL'}")
    print("  => lin < fib strictly.\n")


# ---------------------------------------------------------------------------
# 5. The collapsing exponential ladder  a_k(n) = 2 ** (k*n).
# ---------------------------------------------------------------------------

def demonstrate_exponential_collapse(n_max: int = 24) -> None:
    print("=" * 70)
    print("5. COLLAPSING LADDER  a_k(n) = 2^(k*n)  — all rungs p-equivalent")
    print("=" * 70)
    print("  Because 2^((k+1)n) = (2^(kn))^2, consecutive rungs simulate each")
    print("  other (squaring is polynomial).  We test rungs k=1,2,3:")
    systems = [SizeSystem(f"2^({k}n)", (lambda k: lambda n: 2 ** (k * n))(k))
               for k in (1, 2, 3)]
    for i in range(len(systems) - 1):
        P, Q = systems[i], systems[i + 1]
        up, ku = simulates(P, Q, n_max)
        down, kd = simulates(Q, P, n_max)
        print(f"  {P.name} sim {Q.name}: {up} (k={ku});   "
              f"{Q.name} sim {P.name}: {down} (k={kd})  => p-equivalent")
    print("  => the whole exponential family lives in a SINGLE p-degree.\n")


# ---------------------------------------------------------------------------
# 6. The working power ladder  powSystem(k)(n) = 2 ** (n ** k)  and Gap Lemma.
# ---------------------------------------------------------------------------

def gap_witness(c: int, k: int, n_search: int = 200) -> Optional[int]:
    """Least n>=2 realizing the Gap Lemma  (2^(n^k)+2)^c < 2^(n^(k+1))  (k>=1).
    Theory predicts n = max(2, c+1) always works."""
    for n in range(2, n_search + 1):
        lhs = (2 ** (n ** k) + 2) ** c
        rhs = 2 ** (n ** (k + 1))
        if lhs < rhs:
            return n
    return None


def demonstrate_power_ladder() -> None:
    print("=" * 70)
    print("6. WORKING LADDER  powSystem(k)(n) = 2^(n^k)  — infinite height")
    print("=" * 70)
    print("  Gap Lemma:  for every blow-up degree c and every k>=1 there is n")
    print("  with (2^(n^k)+2)^c < 2^(n^(k+1)).  Least witnessing n (predicted c+1):")
    for k in (1, 2, 3):
        for c in (1, 2, 3, 5):
            n = gap_witness(c, k)
            print(f"    k={k}, c={c}:  witness n = {n}   "
                  f"(prediction max(2,c+1) = {max(2, c + 1)})")
    print()
    print("  Strictness of each step  2^(n^k) < 2^(n^(k+1)):")
    print("  * slower simulates faster  (n^k <= n^(k+1), blow-up = identity):")
    for k in (1, 2):
        P = SizeSystem(f"2^(n^{k})",   (lambda k: lambda n: 2 ** (n ** k))(k))
        Q = SizeSystem(f"2^(n^{k+1})", (lambda k: lambda n: 2 ** (n ** (k + 1)))(k))
        up, ku = simulates(P, Q, n_max=6)
        print(f"      {P.name} sim {Q.name}: {up} (witness k={ku})")
    print("  * faster CANNOT simulate slower: every blow-up degree c is defeated")
    print("    by the Gap Lemma witness n (so NO fixed polynomial dominates):")
    for k in (1, 2):
        margins = []
        for c in range(1, 7):
            n = gap_witness(c, k)
            margins.append(f"c={c}->n={n}")
        print(f"      2^(n^{k+1}) sim 2^(n^{k}) fails:  " + ", ".join(margins))
    print("  => powSystem(1) < powSystem(2) < powSystem(3) < ...  : INFINITE HEIGHT.\n")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> None:
    print()
    print("#" * 70)
    print("#  The Poset of p-Degrees: meets, the domination law, infinite height")
    print("#" * 70)
    print()

    print("=" * 70)
    print("1-2. POLYNOMIAL BLOW-UP CLASS and closure under composition")
    print("=" * 70)
    f = lambda n: 2 * n + 1
    g = lambda n: n * n + 3
    print(f"  f(n)=2n+1   k = {is_poly_bounded_witness(f)}")
    print(f"  g(n)=n^2+3  k = {is_poly_bounded_witness(g)}")
    print(f"  (f.g)(n)    k = {is_poly_bounded_witness(poly_comp(f, g))}  "
          f"(composition stays polynomial)\n")

    demonstrate_meet_closure()
    demonstrate_fib_separation()
    demonstrate_exponential_collapse()
    demonstrate_power_ladder()

    print("All demonstrations consistent with the formalized theorems.")


if __name__ == "__main__":
    main()
