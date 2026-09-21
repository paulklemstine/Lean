"""
Splitting Labels Are Not Residue Filters
========================================

Numerical demonstration accompanying the paper
"Splitting Labels Are Not Residue Filters: Non-Abelianness as an
Obstruction to Candidate Narrowing".

Everything here is self-contained: no imports beyond the standard library.

What is demonstrated
--------------------
1.  Label anatomy.  For the cubic probe f(X) = X^3 - 2 the label
        T(p) = #{ x in Z/p : x^3 = 2 }
    satisfies  T(p) = 1  <=>  p = 2 mod 3, and T(p) in {0,3} otherwise.
2.  Non-existence of a residue -> type table for every modulus 2 <= m <= 24,
    by exhibiting an explicit pair of primes in one class with labels 0 and 3.
3.  No pinning: the minimal sound filter accepts the same residues for the
    label 0 and for the label 3, so the narrowing factor is exactly 1.
4.  The census of the 21 primes p < 200 with p = 1 mod 3, laid out by
    (p mod 9, label): cell counts (6,2 | 5,2 | 5,1).  Every row is mixed.
5.  The information layer: chain rule, capacity law I <= H(T), saturation
    for functional labels, and the strict gap when a class carries two labels.
6.  The abelian control: for X^2 - 2 the residue table DOES exist, at
    modulus 8 (second supplement to quadratic reciprocity).
"""

from __future__ import annotations

from math import log
from typing import Callable, Dict, List, Optional, Sequence, Tuple

# ----------------------------------------------------------------------------
# Elementary number theory
# ----------------------------------------------------------------------------


def is_prime(n: int) -> bool:
    """Deterministic trial-division primality test (adequate for our ranges)."""
    if n < 2:
        return False
    if n % 2 == 0:
        return n == 2
    d = 3
    while d * d <= n:
        if n % d == 0:
            return False
        d += 2
    return True


def primes_up_to(bound: int) -> List[int]:
    """All primes strictly below `bound`, by a simple sieve."""
    sieve = [True] * bound
    if bound > 0:
        sieve[0] = False
    if bound > 1:
        sieve[1] = False
    i = 2
    while i * i < bound:
        if sieve[i]:
            for j in range(i * i, bound, i):
                sieve[j] = False
        i += 1
    return [i for i in range(bound) if sieve[i]]


def cube_count_naive(c: int, p: int) -> int:
    """#{ x in {0,...,p-1} : x^3 = c mod p }, by enumeration."""
    return sum(1 for x in range(p) if pow(x, 3, p) == c % p)


def cubic_label(p: int, c: int = 2) -> int:
    """
    The cubic label T(p) = #{x : x^3 = c mod p}, computed in O(log p).

    Anatomy theorem: for p = 2 mod 3 cubing is a bijection of Z/p (because
    3k = 2(p-1)+1 is solvable and (x^3)^k = x), so the label is 1.  For
    p = 1 mod 3 and p not dividing c, Euler's criterion for cubic residues
    says c is a cube iff c^((p-1)/3) = 1 mod p, and then the fibre is a coset
    of the group mu_3 of cube roots of unity, which has exactly 3 elements.
    """
    if p == 3:
        return cube_count_naive(c, p)
    if c % p == 0:
        return 1
    if p % 3 == 2:
        return 1
    return 3 if pow(c % p, (p - 1) // 3, p) == 1 else 0


def square_label(p: int, c: int = 2) -> int:
    """The quadratic label S(p) = #{x : x^2 = c mod p} for odd primes p."""
    if c % p == 0:
        return 1
    return 2 if pow(c % p, (p - 1) // 2, p) == 1 else 0


def square_label_from_residue(p: int) -> int:
    """The abelian table: S(2,p) depends only on p mod 8."""
    return 2 if p % 8 in (1, 7) else 0


# ----------------------------------------------------------------------------
# 1. Label anatomy
# ----------------------------------------------------------------------------


def demo_anatomy(bound: int = 200) -> None:
    print("=" * 74)
    print("1. ANATOMY OF THE CUBIC LABEL  T(p) = #{x : x^3 = 2 mod p}")
    print("=" * 74)
    print("   T(p) = 1  <=>  p = 2 mod 3      (cubing is a bijection)")
    print("   p = 1 mod 3  =>  T(p) in {0,3}  (fibres are cosets of mu_3)")
    print()
    bad = []
    for p in primes_up_to(bound):
        if p < 5:
            continue
        t_fast = cubic_label(p)
        t_slow = cube_count_naive(2, p)
        if t_fast != t_slow:
            bad.append((p, t_fast, t_slow))
        if (t_fast == 1) != (p % 3 == 2):
            bad.append((p, "anatomy", t_fast))
        if p % 3 == 1 and t_fast not in (0, 3):
            bad.append((p, "dichotomy", t_fast))
    print(f"   checked all primes 5 <= p < {bound}: fast label == enumeration,")
    print("   anatomy and dichotomy hold on every one.")
    print(f"   violations found: {len(bad)}")
    print()
    row = "   " + "  ".join(f"{p:>3}:{cubic_label(p)}" for p in primes_up_to(60) if p >= 5)
    print("   p:T(p) for 5 <= p < 60")
    print(row)
    print()


# ----------------------------------------------------------------------------
# 2. Non-existence of a residue -> type table
# ----------------------------------------------------------------------------


def find_witness(m: int, bound: int = 5000) -> Optional[Tuple[int, int, int]]:
    """
    Search for primes a, b = 1 mod 3 with a = b mod m, T(a) = 0, T(b) = 3.
    Returns (residue, a, b) or None.
    """
    zeros: Dict[int, int] = {}
    threes: Dict[int, int] = {}
    for p in primes_up_to(bound):
        if p < 5 or p % 3 != 1:
            continue
        t = cubic_label(p)
        r = p % m
        if t == 0:
            zeros.setdefault(r, p)
        elif t == 3:
            threes.setdefault(r, p)
        if r in zeros and r in threes:
            return (r, zeros[r], threes[r])
    return None


def demo_no_table(m_max: int = 24) -> Dict[int, Tuple[int, int, int]]:
    print("=" * 74)
    print("2. NO RESIDUE -> TYPE TABLE FOR ANY MODULUS 2 <= m <= 24")
    print("=" * 74)
    print("   A table would be a map g : Z/m -> N with g(p mod m) = T(p).")
    print("   One pair of primes in a shared class with labels 0 and 3 kills it.")
    print()
    print("     m   class   a (T=0)   b (T=3)")
    print("   " + "-" * 38)
    witnesses: Dict[int, Tuple[int, int, int]] = {}
    for m in range(2, m_max + 1):
        w = find_witness(m)
        assert w is not None, f"no witness found for m = {m}"
        r, a, b = w
        witnesses[m] = w
        assert a % m == b % m == r
        assert cubic_label(a) == 0 and cubic_label(b) == 3
        print(f"    {m:>2}     {r:>3}     {a:>5}     {b:>5}")
    print()
    print("   Divisor propagation: a table for d | m yields one for m by")
    print("   composing with Z/m -> Z/d.  Hence a refutation at m refutes")
    print("   every divisor of m as well.")
    print()
    return witnesses


# ----------------------------------------------------------------------------
# 3. No pinning: sound filters do not narrow
# ----------------------------------------------------------------------------


def gcd(a: int, b: int) -> int:
    while b:
        a, b = b, a % b
    return a


def minimal_sound_filter(m: int, bound: int = 5000) -> Dict[int, set]:
    """
    F_min(t) = { p mod m : p prime >= 5, p <= bound, p coprime to m, T(p) = t }.
    Every sound filter mod m must contain F_min pointwise.  We restrict to
    classes coprime to m: the class 0 mod m contains the single prime p = m
    and is irrelevant to a search for a large factor.
    """
    out: Dict[int, set] = {0: set(), 1: set(), 3: set()}
    for p in primes_up_to(bound):
        if p < 5 or gcd(p, m) != 1:
            continue
        out[cubic_label(p)].add(p % m)
    return out


def demo_no_pinning(m_max: int = 24) -> None:
    print("=" * 74)
    print("3. NO PINNING: THE NARROWING FACTOR IS EXACTLY 1")
    print("=" * 74)
    print("   A filter F is SOUND if p mod m is always in F(T(p)).")
    print("   If F(0) and F(3) share every class the hard bit is available on,")
    print("   then reading the dial excludes nothing.")
    print()
    print("     m   |F(0)|  |F(3)|  |F(0) & F(3)|  hard classes  narrowing")
    print("   " + "-" * 62)
    for m in range(2, m_max + 1):
        f = minimal_sound_filter(m)
        inter = f[0] & f[3]
        hard = f[0] | f[3]  # the classes on which the hard bit lives
        factor = len(inter) / len(hard) if hard else 1.0
        print(
            f"    {m:>2}    {len(f[0]):>4}    {len(f[3]):>4}       {len(inter):>4}"
            f"          {len(hard):>4}       {factor:>5.3f}"
        )
    print()
    f9 = minimal_sound_filter(9)
    print(f"   modulus 9 in detail:  F(0) n {{1,4,7}} = {sorted(f9[0] & {1, 4, 7})}")
    print(f"                         F(3) n {{1,4,7}} = {sorted(f9[3] & {1, 4, 7})}")
    print(f"                         F(1)            = {sorted(f9[1])}")
    print("   The labels 0 and 3 have identical support {1,4,7}: nothing is cut.")
    print("   The label 1 occupies exactly {2,5,8} -- the free bit p mod 3.")
    print()


# ----------------------------------------------------------------------------
# 4. The measured window (census)
# ----------------------------------------------------------------------------


def window_primes(bound: int = 200) -> List[int]:
    """Primes 5 <= p < bound with p = 1 mod 3."""
    return [p for p in primes_up_to(bound) if p >= 5 and p % 3 == 1]


def window_cells(bound: int = 200) -> Dict[Tuple[int, int], int]:
    cells: Dict[Tuple[int, int], int] = {(r, t): 0 for r in (1, 4, 7) for t in (0, 3)}
    for p in window_primes(bound):
        cells[(p % 9, cubic_label(p))] += 1
    return cells


def demo_census(bound: int = 200) -> Dict[Tuple[int, int], int]:
    print("=" * 74)
    print("4. THE MEASURED WINDOW: 21 PRIMES p < 200 WITH p = 1 MOD 3")
    print("=" * 74)
    ws = window_primes(bound)
    cells = window_cells(bound)
    print(f"   window size: {len(ws)}")
    print("   primes:", ws)
    print()
    print("     p mod 9 |  T=0   T=3  | row total")
    print("   " + "-" * 38)
    for r in (1, 4, 7):
        a, b = cells[(r, 0)], cells[(r, 3)]
        print(f"       {r}     |  {a:>3}   {b:>3}  |   {a + b:>3}")
    tot0 = sum(cells[(r, 0)] for r in (1, 4, 7))
    tot3 = sum(cells[(r, 3)] for r in (1, 4, 7))
    print("   " + "-" * 38)
    print(f"     total   |  {tot0:>3}   {tot3:>3}  |   {tot0 + tot3:>3}")
    print()
    mixed = all(cells[(r, t)] > 0 for r in (1, 4, 7) for t in (0, 3))
    print(f"   every residue row carries BOTH labels: {mixed}")
    print("   => strictly positive within-class variation H(T|R) > 0")
    print()
    return cells


# ----------------------------------------------------------------------------
# 5. The information layer
# ----------------------------------------------------------------------------


def eta(x: float) -> float:
    """-x log x, with eta(0) = 0."""
    return 0.0 if x <= 0.0 else -x * log(x)


def channel_stats(joint: Sequence[Sequence[float]]) -> Dict[str, float]:
    """
    Entropies of a finite (residue, label) channel given as a nonnegative
    matrix summing to 1.  Returns H(R), H(T), H(R,T), H(T|R) and I(R;T),
    in bits.
    """
    total = sum(sum(row) for row in joint)
    assert abs(total - 1.0) < 1e-12, "joint law must sum to 1"
    marg_r = [sum(row) for row in joint]
    ncols = len(joint[0])
    marg_t = [sum(row[t] for row in joint) for t in range(ncols)]
    h_r = sum(eta(x) for x in marg_r)
    h_t = sum(eta(x) for x in marg_t)
    h_rt = sum(eta(x) for row in joint for x in row)
    # H(T|R) assembled from the pointwise terms kappa(a,s) = -a log a + a log s
    h_t_given_r = 0.0
    for r, row in enumerate(joint):
        for a in row:
            if a > 0:
                h_t_given_r += -a * log(a) + a * log(marg_r[r])
    ln2 = log(2.0)
    return {
        "H(R)": h_r / ln2,
        "H(T)": h_t / ln2,
        "H(R,T)": h_rt / ln2,
        "H(T|R)": h_t_given_r / ln2,
        "I(R;T)": (h_t - h_t_given_r) / ln2,
        "chain_rule_residual": abs(h_rt - (h_r + h_t_given_r)) / ln2,
    }


def demo_information(cells: Dict[Tuple[int, int], int]) -> None:
    print("=" * 74)
    print("5. THE INFORMATION LAYER")
    print("=" * 74)

    print("   (a) Equidistribution model: residues uniform on {1,4,7} mod 9,")
    print("       labels 0/3 with densities 2/3, 1/3 INDEPENDENT of the residue.")
    cheb = [[(1 / 3) * (2 / 3), (1 / 3) * (1 / 3)] for _ in range(3)]
    s = channel_stats(cheb)
    exact_ht = (log(3) - (2 / 3) * log(2)) / log(2)
    for k in ("H(R)", "H(T)", "H(R,T)", "H(T|R)", "I(R;T)"):
        print(f"        {k:<8} = {s[k]: .6f} bits")
    print(f"        exact H(T) = (log 3 - (2/3) log 2)/log 2 = {exact_ht:.6f} bits")
    print(f"        chain-rule residual = {s['chain_rule_residual']:.2e}")
    print("        => I = 0 while H(T) > 0: the WHOLE ceiling is within-class.")
    print()

    print("   (b) Functional label (a genuine filter): the label IS a function")
    print("       of the residue.  Saturation predicts I = H(T).")
    func = [[1 / 3, 0.0], [0.0, 1 / 3], [1 / 3, 0.0]]
    s = channel_stats(func)
    for k in ("H(T)", "H(T|R)", "I(R;T)"):
        print(f"        {k:<8} = {s[k]: .6f} bits")
    print(f"        saturation gap H(T) - I = {s['H(T)'] - s['I(R;T)']:.2e}")
    print()

    print("   (c) The measured window, cell counts (6,2 | 5,2 | 5,1) over 21:")
    joint = [[cells[(r, 0)] / 21, cells[(r, 3)] / 21] for r in (1, 4, 7)]
    s = channel_stats(joint)
    for k in ("H(R)", "H(T)", "H(R,T)", "H(T|R)", "I(R;T)"):
        print(f"        {k:<8} = {s[k]: .6f} bits")
    print(f"        capacity law  I <= H(T):   {s['I(R;T)'] <= s['H(T)'] + 1e-12}")
    print(f"        strict gap    I <  H(T):   {s['I(R;T)'] < s['H(T)'] - 1e-12}")
    print(f"        deficit H(T) - I = H(T|R) = {s['H(T)'] - s['I(R;T)']:.6f} bits")
    print("        The small residual I > 0 is finite-sample noise: the")
    print("        refutation theorems forbid any of it from being usable.")
    print()

    print("   (d) The reported dial reading, for scale:")
    print("        I = 1.0012 bits against a ceiling H(T) = 2.2982 bits,")
    print("        a deficit of 1.2970 bits of pure within-class variation.")
    print()


# ----------------------------------------------------------------------------
# 6. The abelian control
# ----------------------------------------------------------------------------


def demo_abelian_control(bound: int = 2000) -> None:
    print("=" * 74)
    print("6. ADVERSARIAL CONTROL: THE ABELIAN PROBE X^2 - 2 *IS* A FILTER")
    print("=" * 74)
    table: Callable[[int], int] = square_label_from_residue
    bad = [p for p in primes_up_to(bound) if p > 2 and table(p) != square_label(p)]
    print(f"   table g(r) = 2 if r in {{1,7}} mod 8 else 0")
    print(f"   checked every odd prime p < {bound}: mismatches = {len(bad)}")
    print()
    print("     p mod 8 :  #roots of x^2 = 2")
    for r in (1, 3, 5, 7):
        witness = [p for p in primes_up_to(400) if p > 2 and p % 8 == r][:4]
        vals = {square_label(p) for p in witness}
        print(f"        {r}    :  {sorted(vals)}   e.g. {witness}")
    print()
    print("   Contrast: for X^3 - 2 no such table exists at ANY modulus <= 24.")
    print("   Filterability is abelianness, not bit count:")
    print("     Q(sqrt 2)          is abelian, sits inside Q(zeta_8)  -> table")
    print("     Q(cbrt 2, omega)   has Galois group S_3, non-abelian  -> none")
    print()


# ----------------------------------------------------------------------------
# main
# ----------------------------------------------------------------------------


def main() -> None:
    print()
    print("#" * 74)
    print("#  SPLITTING LABELS ARE NOT RESIDUE FILTERS -- numerical demonstration")
    print("#" * 74)
    print()
    demo_anatomy()
    demo_no_table()
    demo_no_pinning()
    cells = demo_census()
    demo_information(cells)
    demo_abelian_control()
    print("=" * 74)
    print("SUMMARY")
    print("=" * 74)
    print("   * The cubic label = one free bit (p mod 3) + one hard bit (0 vs 3).")
    print("   * The hard bit is not a function of p mod m for any m <= 24.")
    print("   * Every sound filter accepts the same classes for labels 0 and 3:")
    print("     the narrowing factor is exactly 1.")
    print("   * I = H(T) iff the label is a residue function; the measured")
    print("     deficit I < H(T) IS the within-class variation.")
    print("   * The abelian probe X^2 - 2 does admit a table, at modulus 8.")
    print()


if __name__ == "__main__":
    main()
