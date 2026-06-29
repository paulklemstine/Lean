"""
demo.py — The Multiplicative Independence Barrier behind Cobham's Theorem
========================================================================

Numerical demonstrations of the arithmetic core of Cobham's theorem (1972):
the *multiplicative dependence* relation on natural-number bases.

Two bases j, k >= 2 are multiplicatively DEPENDENT when some common positive
power coincides:

        MultDep(j, k)  <=>  there exist a, b > 0 with  j**a == k**b.

This module demonstrates, with concrete numbers, the verified results:

  * multDep_refl          -- every base is dependent with itself
  * multDep_symm          -- dependence is symmetric
  * multDep_trans         -- dependence is transitive
  * multDep_pow_self      -- powers of a fixed base are dependent
  * coprime_not_multDep   -- THE BARRIER: coprime bases are never dependent
  * not_multDep_two_three -- the concrete witness: 2 and 3 are independent

It also illustrates the (conjectural) common-root normal form, the equivalence
to log j / log k in Q, and why Cobham's theorem needs the independence
hypothesis (Thue-Morse is both 2- and 4-automatic).

Run:  python demo.py
"""

from __future__ import annotations

from math import gcd, isqrt, log
from fractions import Fraction
from typing import Optional, Tuple, Dict, List


# ---------------------------------------------------------------------------
# Core arithmetic
# ---------------------------------------------------------------------------
def prime_factorization(n: int) -> Dict[int, int]:
    """Return the prime -> exponent map of n >= 1 by trial division.

    Complexity: O(sqrt(n)) divisions.
    """
    if n < 1:
        raise ValueError("prime_factorization requires n >= 1")
    factors: Dict[int, int] = {}
    d = 2
    while d <= isqrt(n):
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1 if d == 2 else 2
    if n > 1:
        factors[n] = factors.get(n, 0) + 1
    return factors


def mult_dep_witness(j: int, k: int, bound: int = 64) -> Optional[Tuple[int, int]]:
    """Decide MultDep(j, k) exactly via prime signatures; return a witness (a, b).

    j and k (>= 2) are dependent iff they share the same set of prime factors AND
    their exponent vectors are proportional.  When dependent we return the minimal
    positive (a, b) with j**a == k**b; otherwise None.  `bound` guards the
    exact-verification exponents (witnesses for sane inputs are tiny).
    """
    if j < 2 or k < 2:
        # The barrier even rules out k == 1; here we only model bases >= 2,
        # except we still answer truthfully for the degenerate inputs.
        return (1, 1) if j == k else None
    fj, fk = prime_factorization(j), prime_factorization(k)
    if set(fj) != set(fk):
        return None
    # Check proportionality of exponent vectors: vk(p)/vj(p) constant.
    ratio: Optional[Fraction] = None
    for p in fj:
        r = Fraction(fk[p], fj[p])
        if ratio is None:
            ratio = r
        elif r != ratio:
            return None
    assert ratio is not None
    # j**a == k**b  with  a/b == ratio == vk/vj, i.e. a = num, b = den.
    a, b = ratio.numerator, ratio.denominator
    if a <= bound and b <= bound and j ** a == k ** b:
        return (a, b)
    return None  # unreachable for well-formed inputs


def is_mult_dep(j: int, k: int) -> bool:
    """Boolean form of the dependence relation."""
    return mult_dep_witness(j, k) is not None


def coprime(j: int, k: int) -> bool:
    return gcd(j, k) == 1


def common_root(j: int, k: int) -> Optional[Tuple[int, int, int]]:
    """If MultDep(j, k), return (g, p, q) with g >= 2, j == g**p, k == g**q.

    This realizes the conjectural common-root normal form numerically:
    g = product over primes of p ** gcd_of_valuations.
    """
    if not is_mult_dep(j, k):
        return None
    fj, fk = prime_factorization(j), prime_factorization(k)
    g_exponents = {p: gcd(fj[p], fk[p]) for p in fj}
    g = 1
    for p, e in g_exponents.items():
        g *= p ** e
    # p, q are the common multipliers j = g**p, k = g**q.
    pe = next(iter(fj))
    p_exp = fj[pe] // g_exponents[pe]
    q_exp = fk[pe] // g_exponents[pe]
    assert g ** p_exp == j and g ** q_exp == k
    return (g, p_exp, q_exp)


# ---------------------------------------------------------------------------
# Automatic-sequence illustration: Thue-Morse is 2- and 4-automatic
# ---------------------------------------------------------------------------
def thue_morse(n: int) -> int:
    """t_n = parity of the number of 1-bits of n (the Thue-Morse sequence)."""
    return bin(n).count("1") & 1


def is_eventually_periodic(seq: List[int], max_period: int = 32) -> bool:
    """Heuristic check: does seq look eventually periodic within the window?"""
    L = len(seq)
    for pre in range(L // 2):
        for per in range(1, max_period + 1):
            if pre + 2 * per > L:
                continue
            tail = seq[pre:]
            if all(tail[i] == tail[i % per] for i in range(len(tail))):
                return True
    return False


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------
def demo_equivalence_relation() -> None:
    print("=" * 70)
    print("1. MultDep is an equivalence relation")
    print("=" * 70)
    # Reflexivity
    for j in (2, 3, 6, 12):
        assert is_mult_dep(j, j)
    print("  reflexive : MultDep(j, j) holds for 2,3,6,12  (witness a=b=1)")

    # Symmetry
    pairs = [(4, 8), (8, 32), (9, 27)]
    for j, k in pairs:
        assert is_mult_dep(j, k) == is_mult_dep(k, j)
    print(f"  symmetric : MultDep(j,k) == MultDep(k,j) for {pairs}")

    # Transitivity: 4 ~ 8 and 8 ~ 32  ==>  4 ~ 32
    assert is_mult_dep(4, 8) and is_mult_dep(8, 32) and is_mult_dep(4, 32)
    print("  transitive: 4~8 and 8~32  =>  4~32")
    print(f"              4**{mult_dep_witness(4,32)[0]} == 32**{mult_dep_witness(4,32)[1]} "
          f"== {4**mult_dep_witness(4,32)[0]}")
    print()


def demo_powers() -> None:
    print("=" * 70)
    print("2. Powers of a fixed base are always dependent")
    print("=" * 70)
    base = 2
    for m, n in [(1, 3), (2, 5), (3, 4)]:
        j, k = base ** m, base ** n
        w = mult_dep_witness(j, k)
        assert w is not None
        print(f"  MultDep(2**{m}={j}, 2**{n}={k})  witness (a,b)={w}: "
              f"{j}**{w[0]} == {k}**{w[1]} == {j**w[0]}")
    print()


def demo_barrier() -> None:
    print("=" * 70)
    print("3. THE BARRIER: coprime bases are never multiplicatively dependent")
    print("=" * 70)
    coprime_pairs = [(2, 3), (3, 10), (6, 35), (4, 9), (5, 8)]
    for j, k in coprime_pairs:
        cp = coprime(j, k)
        dep = is_mult_dep(j, k)
        status = "OK" if (cp and not dep) else "??"
        print(f"  [{status}] gcd({j},{k})={gcd(j,k)} coprime={str(cp):>5}  "
              f"MultDep={dep}")
        if cp:
            assert not dep
    print()
    print("  Concrete witness  ¬MultDep(2,3):")
    print("    Suppose 2**a == 3**b.  Mod 2: LHS even (0), RHS odd (1). 0 != 1.")
    # brute-force sanity check over a generous window
    assert all(2 ** a != 3 ** b for a in range(1, 40) for b in range(1, 40))
    print("    Verified: no 2**a == 3**b for 1 <= a,b < 40.")
    print()


def demo_common_root() -> None:
    print("=" * 70)
    print("4. Common-root normal form (conjectural classification)")
    print("=" * 70)
    for j, k in [(8, 32), (9, 27), (16, 64), (1000, 100)]:
        cr = common_root(j, k)
        if cr is None:
            print(f"  {j}, {k}: independent (no common root)")
        else:
            g, p, q = cr
            print(f"  {j} = {g}**{p},  {k} = {g}**{q}   (common root g={g})")
            assert g ** p == j and g ** q == k
    print()


def demo_log_ratio() -> None:
    print("=" * 70)
    print("5. Equivalence to rationality of log j / log k")
    print("=" * 70)
    for j, k in [(4, 8), (2, 3)]:
        r = log(j) / log(k)
        frac = Fraction(r).limit_denominator(50)
        dep = is_mult_dep(j, k)
        print(f"  log {j}/log {k} = {r:.6f} ~ {frac}   MultDep={dep}")
    print("  (dependent <=> the ratio is exactly rational)")
    print()


def demo_cobham_needs_independence() -> None:
    print("=" * 70)
    print("6. Why Cobham's theorem needs independence (Thue-Morse)")
    print("=" * 70)
    tm = [thue_morse(n) for n in range(32)]
    print("  Thue-Morse t =", "".join(map(str, tm[:24])), "...")
    print(f"  eventually periodic? {is_eventually_periodic(tm)}")
    print("  It is 2-automatic AND 4-automatic (since MultDep(2,4):",
          is_mult_dep(2, 4), ") yet NOT periodic.")
    print("  Cobham's theorem does NOT apply to (2,4): they are dependent.")
    print("  For the independent pair (2,3), no such aperiodic sequence can be")
    print("  both 2- and 3-automatic -- that is Cobham's theorem.")
    print()


def main() -> None:
    print()
    print("#" * 70)
    print("# The Multiplicative Independence Barrier behind Cobham's Theorem")
    print("#" * 70)
    print()
    demo_equivalence_relation()
    demo_powers()
    demo_barrier()
    demo_common_root()
    demo_log_ratio()
    demo_cobham_needs_independence()
    print("All demonstrations completed and assertions passed.")


if __name__ == "__main__":
    main()
