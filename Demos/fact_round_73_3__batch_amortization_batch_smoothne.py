"""
Batch smoothness testing: exactness, cost dichotomy, and the Amdahl ceiling.

Numerical demonstration of every quantitative claim in the accompanying paper.

Contents
--------
1. Exactness of the batch criterion:  for 0 < n < 2^t,
       n is B-smooth   <=>   n | P_B^t,
   where P_B is the product of the primes <= B.  Verified exhaustively against
   trial division, in the plain form, the remainder-tree form and the
   repeated-squaring form.
2. Sharpness of the exponent:  2^t | P_B^s  <=>  t <= s.
3. Shape independence of product trees.
4. Flat cost model:  saving(k) = (s-c)/s - A/(s k)  -- monotone, no crossover.
5. Word cost model:  tree cost = w^2 (4^L - 2^L) / 2 -- quadratic reversal, and
   the unique crossover M* = 1 + (s1-c1)/q calibrated to M* = 1715.
6. Unified block cost A/k + c + q(k-1): optimum at k* = sqrt(A/q).
7. Amdahl ceiling and the phase-residual inversion 29/289.
8. Relation quota: > pi(B) smooth relations force a square sub-product.

Pure standard library; no dependencies.  Run:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction
from itertools import combinations
from math import isqrt, prod, sqrt
from typing import Dict, Iterable, List, Sequence, Set, Tuple


# ----------------------------------------------------------------------------
# 0.  Elementary number theory
# ----------------------------------------------------------------------------

def primes_up_to(bound: int) -> List[int]:
    """All primes p with p <= bound, by a simple sieve of Eratosthenes."""
    if bound < 2:
        return []
    sieve: List[bool] = [True] * (bound + 1)
    sieve[0] = sieve[1] = False
    for p in range(2, isqrt(bound) + 1):
        if sieve[p]:
            for m in range(p * p, bound + 1, p):
                sieve[m] = False
    return [p for p in range(bound + 1) if sieve[p]]


def primorial_up_to(bound: int) -> int:
    """P_B = product of all primes <= B.  The batch modulus."""
    return prod(primes_up_to(bound))


def factorization(n: int) -> Dict[int, int]:
    """Prime factorization of n >= 1 as {prime: exponent}."""
    assert n >= 1
    out: Dict[int, int] = {}
    m = n
    d = 2
    while d * d <= m:
        while m % d == 0:
            out[d] = out.get(d, 0) + 1
            m //= d
        d += 1 if d == 2 else 2
    if m > 1:
        out[m] = out.get(m, 0) + 1
    return out


def is_smooth_by_trial_division(bound: int, n: int) -> bool:
    """Solo trial division: strip all primes <= B and check nothing remains."""
    assert n >= 1
    m = n
    for p in primes_up_to(bound):
        while m % p == 0:
            m //= p
        if m == 1:
            return True
    return m == 1


# ----------------------------------------------------------------------------
# 1.  The batch criterion, in its three equivalent forms
# ----------------------------------------------------------------------------

def batch_criterion_plain(modulus: int, exponent: int, n: int) -> bool:
    """n | P^t, computed naively (only usable for small parameters)."""
    return pow(modulus, exponent) % n == 0


def batch_criterion_remainder_tree(modulus: int, exponent: int, n: int) -> bool:
    """(P mod n)^t mod n == 0 -- what the remainder tree actually evaluates."""
    return pow(modulus % n, exponent, n) == 0


def batch_criterion_repeated_squaring(modulus: int, squarings: int, n: int) -> bool:
    """Square the residue `squarings` times mod n; smooth iff the result is 0.

    Exact whenever 2 ** squarings >= t, the candidate bit length.
    """
    r = modulus % n
    for _ in range(squarings):
        r = (r * r) % n
    return r == 0


def demo_exactness(bound: int = 100, t: int = 9, hi: int = 500) -> None:
    """Exhaustive exactness check on {1, ..., hi}, all candidates < 2^t."""
    print("=" * 74)
    print(f"1. EXACTNESS  (B = {bound}, t = {t}, candidates 1..{hi} < 2^{t} = {2**t})")
    print("=" * 74)
    assert hi < 2 ** t, "the criterion needs every candidate below 2^t"

    P = primorial_up_to(bound)
    e = 0
    while 2 ** e < t:
        e += 1

    print(f"   batch modulus P has {P.bit_length()} bits; squarings e = {e} "
          f"(2^{e} = {2**e} >= t = {t})")

    trial: Set[int] = set()
    tree: Set[int] = set()
    plain: Set[int] = set()
    squaring: Set[int] = set()
    for n in range(1, hi + 1):
        if is_smooth_by_trial_division(bound, n):
            trial.add(n)
        if batch_criterion_remainder_tree(P, t, n):
            tree.add(n)
        if batch_criterion_plain(P, t, n):
            plain.add(n)
        if batch_criterion_repeated_squaring(P, e, n):
            squaring.add(n)

    print(f"   trial division            : {len(trial):4d} smooth")
    print(f"   batch, plain form         : {len(plain):4d} smooth  "
          f"mismatches = {len(trial ^ plain)}")
    print(f"   batch, remainder tree     : {len(tree):4d} smooth  "
          f"mismatches = {len(trial ^ tree)}")
    print(f"   batch, repeated squaring  : {len(squaring):4d} smooth  "
          f"mismatches = {len(trial ^ squaring)}")
    assert trial == plain == tree == squaring
    print("   => the four filters are EQUAL as sets (not merely on a sample).")

    # The same statement over a 40-bit-like window, sampled sparsely for speed.
    t40 = 40
    e40 = 6  # 2^6 = 64 >= 40
    P40 = P
    bad = 0
    for n in range(2 ** 39, 2 ** 39 + 4000):
        if is_smooth_by_trial_division(bound, n) != \
           batch_criterion_repeated_squaring(P40, e40, n):
            bad += 1
    print(f"   40-bit window (4000 consecutive candidates, e = {e40}): "
          f"{bad} mismatches")
    assert bad == 0
    print()


def demo_sharpness(bound: int = 100, t_max: int = 6) -> None:
    """2^t | P^s  <=>  t <= s.  In particular 4 is smooth but 4 does not divide P."""
    print("=" * 74)
    print(f"2. SHARPNESS OF THE EXPONENT  (B = {bound})")
    print("=" * 74)
    P = primorial_up_to(bound)
    print("      t\\s " + "".join(f"{s:>4d}" for s in range(t_max + 1)))
    for t in range(t_max + 1):
        row = []
        for s in range(t_max + 1):
            holds = pow(P, s) % (2 ** t) == 0
            assert holds == (t <= s)
            row.append(" Y" if holds else " .")
        print(f"      {t:<3d} " + "".join(f"{c:>4s}" for c in row))
    print("   'Y' exactly on t <= s: the exponent must equal the bit length.")
    print(f"   Counterexample without the size bound: 4 is {bound}-smooth, "
          f"but 4 | P^1 is {pow(P,1) % 4 == 0}.")
    print()


# ----------------------------------------------------------------------------
# 3.  Product trees: shape independence
# ----------------------------------------------------------------------------

Tree = Tuple[object, ...]  # ('leaf', n) | ('node', left, right)


def tree_leaf(n: int) -> Tree:
    return ("leaf", n)


def tree_node(left: Tree, right: Tree) -> Tree:
    return ("node", left, right)


def tree_value(t: Tree) -> int:
    """Root value: multiply children bottom-up."""
    if t[0] == "leaf":
        return int(t[1])  # type: ignore[arg-type]
    return tree_value(t[1]) * tree_value(t[2])  # type: ignore[arg-type]


def tree_leaves(t: Tree) -> List[int]:
    if t[0] == "leaf":
        return [int(t[1])]  # type: ignore[arg-type]
    return tree_leaves(t[1]) + tree_leaves(t[2])  # type: ignore[arg-type]


def balanced_tree(xs: Sequence[int]) -> Tree:
    """A balanced product tree over xs."""
    assert xs
    if len(xs) == 1:
        return tree_leaf(xs[0])
    mid = len(xs) // 2
    return tree_node(balanced_tree(xs[:mid]), balanced_tree(xs[mid:]))


def left_spine_tree(xs: Sequence[int]) -> Tree:
    """The maximally unbalanced (left-leaning) product tree over xs."""
    assert xs
    t = tree_leaf(xs[0])
    for x in xs[1:]:
        t = tree_node(t, tree_leaf(x))
    return t


def remainder_tree(t: Tree, value: int) -> List[int]:
    """All residues `value mod leaf` in one cascade down the product tree."""
    reduced = value % tree_value(t)
    if t[0] == "leaf":
        return [reduced]
    return (remainder_tree(t[1], reduced) +      # type: ignore[arg-type]
            remainder_tree(t[2], reduced))       # type: ignore[arg-type]


def demo_tree_shape(bound: int = 100) -> None:
    print("=" * 74)
    print(f"3. PRODUCT TREES: SHAPE INDEPENDENCE AND THE REMAINDER CASCADE "
          f"(B = {bound})")
    print("=" * 74)
    ps = primes_up_to(bound)
    P = primorial_up_to(bound)
    bal = balanced_tree(ps)
    spine = left_spine_tree(ps)
    rev = balanced_tree(list(reversed(ps)))
    print(f"   balanced tree value == P      : {tree_value(bal) == P}")
    print(f"   left-spine tree value == P    : {tree_value(spine) == P}")
    print(f"   reversed-order tree value == P: {tree_value(rev) == P}")
    assert tree_value(bal) == tree_value(spine) == tree_value(rev) == P
    print("   => 'tree' and 'direct' arms test literally the same divisibility.")

    pool = [n for n in range(400, 420)]
    cand_tree = balanced_tree(pool)
    residues = remainder_tree(cand_tree, P)
    direct = [P % n for n in pool]
    print(f"   remainder tree over a pool of {len(pool)} candidates matches "
          f"{len(pool)} direct reductions: {residues == direct}")
    assert residues == direct
    print()


# ----------------------------------------------------------------------------
# 4-5.  Cost models
# ----------------------------------------------------------------------------

def flat_saving(A: Fraction, c: Fraction, s: Fraction, k: Fraction) -> Fraction:
    """1 - (A + c k)/(s k) = (s-c)/s - A/(s k)."""
    return Fraction(1) - (A + c * k) / (s * k)


def tree_flat_ops(L: int) -> int:
    """Multiplications in a balanced product tree over 2^L leaves: 2^L - 1."""
    return 0 if L == 0 else 2 * tree_flat_ops(L - 1) + 1


def tree_word_cost(w: int, L: int) -> int:
    """Schoolbook word cost of a balanced product tree over 2^L leaves of w words."""
    return 0 if L == 0 else 2 * tree_word_cost(w, L - 1) + (2 ** (L - 1) * w) ** 2


def demo_flat_model(A: float = 0.05, c: float = 0.8955, s: float = 1.0) -> None:
    print("=" * 74)
    print(f"4. FLAT OP MODEL  (setup A = {A}, batch per-candidate c = {c}, "
          f"solo s = {s})")
    print("=" * 74)
    Af, cf, sf = Fraction(A), Fraction(c), Fraction(s)
    ceiling = (sf - cf) / sf
    print(f"   ceiling (s-c)/s = {float(ceiling):.4f};  "
          f"no-crossover condition A < s - c is {Af < sf - cf}")
    print("      k      batch      solo    saving   ceiling - saving")
    prev = None
    for k in (1, 8, 64, 512, 4096):
        kf = Fraction(k)
        sav = flat_saving(Af, cf, sf, kf)
        print(f"   {k:5d}  {float(Af + cf*kf):9.2f} {float(sf*kf):9.2f}  "
              f"{float(sav):+8.4f}   {float(ceiling - sav):.6f}")
        if prev is not None:
            assert sav > prev, "the saving must be strictly increasing in k"
        prev = sav
        assert sav < ceiling
        assert sav > 0, "with A < s - c the batch arm wins at every pool size"
    print("   => strictly increasing, always below the ceiling, no crossover:")
    print("      the calibration reproduces the measured +0.104 at k = 512.")

    # Contrast: the very same algorithm with an expensive setup HAS a crossover.
    A2 = Fraction(3)
    print(f"\n   contrast, setup A = {A2} (so A > s - c = {float(sf-cf):.4f}): "
          f"a crossover appears")
    for k in (1, 8, 64, 512):
        kf = Fraction(k)
        sav = flat_saving(A2, cf, sf, kf)
        verdict = "batch wins" if sav > 0 else "batch loses"
        print(f"      k = {k:5d}:  saving = {float(sav):+8.4f}   {verdict}")
    print("      => 'batch always wins' is the calibration A < s - c, "
          "not a law of batching.")
    print(f"   tree internal nodes: 2^L - 1 for L = 0..6 -> "
          f"{[tree_flat_ops(L) for L in range(7)]}  (linear in the pool)")
    print()


def demo_word_model(w: int = 8, solo_word: int = 1000) -> None:
    print("=" * 74)
    print(f"5. WORD MODEL  (w = {w} words per leaf, solo cost {solo_word} "
          f"word ops/candidate)")
    print("=" * 74)
    print("      L   pool   tree word cost   solo word cost   closed form ok")
    for L in range(0, 9):
        pool = 2 ** L
        tw = tree_word_cost(w, L)
        closed = w * w * (4 ** L - 2 ** L) // 2
        flag = "BATCH LOSES" if tw > solo_word * pool else "batch ok"
        print(f"   {L:4d} {pool:6d} {tw:16d} {solo_word*pool:16d}   "
              f"{tw == closed!s:5s}  {flag}")
        assert tw == closed
    print("   => the tree is quadratic in the pool; the sign reverses.")

    # Continuous two-parameter model, calibrated to M* = 1715.
    q = Fraction(1, 1000)
    c1 = Fraction(1, 2)
    s1 = c1 + 1714 * q            # calibration: (s1 - c1)/q = 1714
    crossover = 1 + (s1 - c1) / q
    print(f"\n   continuous model: batch q k(k-1) + c1 k  vs  solo s1 k, "
          f"q = {q}, c1 = {c1}, s1 = {s1}")
    print(f"   crossover M* = 1 + (s1-c1)/q = {crossover}")
    for k in (1, 8, 64, 512, 1715, 1716, 4096):
        kf = Fraction(k)
        batch = q * kf * (kf - 1) + c1 * kf
        solo = s1 * kf
        verdict = "batch <= solo" if batch <= solo else "batch >  solo"
        assert (batch <= solo) == (kf <= crossover)
        print(f"      k = {k:5d}:  batch = {float(batch):10.2f}  "
              f"solo = {float(solo):10.2f}   {verdict}")
    print("   => a single sign change, exactly at M* = 1715.")
    print()


def block_cost(A: float, c: float, q: float, k: float) -> float:
    """Per-candidate cost of processing a stream in blocks of size k."""
    return A / k + c + q * (k - 1)


def demo_block_cost(A: float = 1000.0, c: float = 0.5, q: float = 0.001) -> None:
    print("=" * 74)
    print(f"6. UNIFIED BLOCK COST  A/k + c + q(k-1)   (A = {A}, c = {c}, q = {q})")
    print("=" * 74)
    k_star = sqrt(A / q)
    opt = c - q + 2 * sqrt(A * q)
    print(f"   predicted optimum k* = sqrt(A/q) = {k_star:.1f}, "
          f"value c - q + 2 sqrt(Aq) = {opt:.6f}")
    print("        k     block cost      excess over the AM-GM bound")
    for k in (1, 10, 100, 500, k_star, 2000, 10000, 100000):
        val = block_cost(A, c, q, k)
        print(f"   {k:8.1f} {val:14.6f}      {val - opt:.6f}")
        assert val >= opt - 1e-12
    assert abs(block_cost(A, c, q, k_star) - opt) < 1e-12
    print("   => the bound is attained exactly at k*, and only there.")

    print("\n   degenerate case q = 0 (the flat model): strictly decreasing, "
          "no optimum")
    prev = None
    for k in (1, 10, 100, 1000, 10000):
        val = block_cost(A, c, 0.0, k)
        print(f"      k = {k:6d}:  cost = {val:.6f}")
        if prev is not None:
            assert val < prev
        prev = val
    print()


# ----------------------------------------------------------------------------
# 7.  The Amdahl ceiling
# ----------------------------------------------------------------------------

def overall_saving(F: Fraction, S: Fraction, S_new: Fraction) -> Fraction:
    """Relative end-to-end saving from replacing testing cost S by S_new."""
    return ((F + S) - (F + S_new)) / (F + S)


def phase_residual(share: Fraction, delta: Fraction) -> Fraction:
    """S'/S = 1 - delta/share: the surviving testing cost, from aggregates only."""
    return Fraction(1) - delta / share


def demo_amdahl(share: Fraction = Fraction(1156, 10000),
                delta: Fraction = Fraction(104, 1000)) -> None:
    print("=" * 74)
    print(f"7. AMDAHL CEILING  (testing share f = {float(share):.4f}, "
          f"measured overall gain d = {float(delta):.3f})")
    print("=" * 74)
    # Normalise the total to 1: S = f, F = 1 - f.
    S = share
    F = Fraction(1) - share
    print(f"   cap on any testing improvement : {float(share):.4f}  "
          f"(= f, attained only if testing were free)")
    print(f"   cap on the end-to-end speedup  : "
          f"{float(1 / (1 - share)):.4f}x  (= 1/(1-f))")
    print(f"   measured gain {float(delta):.3f} < cap {float(share):.4f}: "
          f"{delta < share}")

    print("\n      S'/S      overall saving     <= f ?")
    for frac in (Fraction(1), Fraction(1, 2), Fraction(29, 289), Fraction(0)):
        d = overall_saving(F, S, S * frac)
        assert d <= share
        print(f"   {float(frac):8.5f} {float(d):18.6f}     {d <= share}")

    residual = phase_residual(share, delta)
    print(f"\n   INVERSION: an overall gain of {float(delta):.3f} against a share "
          f"of {float(share):.4f}")
    print(f"   forces the surviving testing cost to be exactly S'/S = {residual} "
          f"= {float(residual)*100:.2f}%")
    print(f"   i.e. a phase-level speedup of {1/float(residual):.2f}x.")
    assert residual == Fraction(29, 289)
    # Consistency: feeding the residual back reproduces the measured delta.
    assert overall_saving(F, S, S * residual) == delta
    print("   Round trip: feeding S' = (29/289) S back reproduces d = "
          f"{float(overall_saving(F, S, S*residual)):.3f}.  Consistent.")
    print()


# ----------------------------------------------------------------------------
# 8.  The relation quota
# ----------------------------------------------------------------------------

def exponent_vector_mod2(n: int, base: Sequence[int]) -> Tuple[int, ...]:
    """Exponent vector of a B-smooth n over the factor base, reduced mod 2."""
    f = factorization(n)
    return tuple(f.get(p, 0) % 2 for p in base)


def find_square_subproduct(relations: Sequence[int],
                           base: Sequence[int]) -> List[int]:
    """A nonempty sub-family with square product, by Gaussian elimination over F2.

    Guaranteed to exist as soon as len(relations) > len(base).
    """
    # Rows carry (vector, provenance set) with provenance recorded as a bitmask.
    rows: List[Tuple[List[int], int]] = [
        (list(exponent_vector_mod2(n, base)), 1 << i)
        for i, n in enumerate(relations)
    ]
    pivots: Dict[int, Tuple[List[int], int]] = {}
    for vec, prov in rows:
        v, p = vec[:], prov
        for col in range(len(base)):
            if v[col] == 0:
                continue
            if col in pivots:
                pv, pp = pivots[col]
                v = [(a + b) % 2 for a, b in zip(v, pv)]
                p ^= pp
            else:
                pivots[col] = (v, p)
                p = 0
                break
        if p != 0 and all(x == 0 for x in v):
            return [relations[i] for i in range(len(relations)) if p >> i & 1]
    return []


def demo_relation_quota(bound: int = 100) -> None:
    print("=" * 74)
    print(f"8. RELATION QUOTA  (B = {bound})")
    print("=" * 74)
    base = primes_up_to(bound)
    pi_B = len(base)
    print(f"   pi({bound}) = {pi_B}, so any {pi_B + 1} smooth relations force a "
          f"square sub-product.")

    smooth = [n for n in range(2, 20000) if is_smooth_by_trial_division(bound, n)]
    print(f"   {len(smooth)} smooth numbers below 20000; density "
          f"{len(smooth)/20000:.4f}")

    # Use squarefree relations, so that no single relation is already a square
    # and the sub-family produced is genuinely a combination.
    squarefree = [n for n in smooth
                  if all(e == 1 for e in factorization(n).values())]
    print(f"   restricting to squarefree relations ({len(squarefree)} of them) "
          f"so no single relation is already a square")
    smooth = squarefree

    relations = smooth[:pi_B + 1]
    subset = find_square_subproduct(relations, base)
    p = prod(subset)
    r = isqrt(p)
    print(f"   from the first {len(relations)} relations, a square sub-family of "
          f"size {len(subset)}:")
    print(f"      {subset}")
    print(f"      product = {p} = {r}^2 : {r*r == p}")
    assert subset and r * r == p

    # The quota is tight in the sense that it always succeeds; try random-ish slices.
    failures = 0
    for start in range(0, 300, 13):
        rels = smooth[start:start + pi_B + 1]
        if len(rels) < pi_B + 1:
            break
        sub = find_square_subproduct(rels, base)
        q = prod(sub)
        if not sub or isqrt(q) ** 2 != q:
            failures += 1
    print(f"   repeated over many windows of {pi_B + 1} relations: "
          f"{failures} failures")
    assert failures == 0

    print("\n   Why the experiment split nothing at 40 bits with B = 100:")
    window = 20000
    hits = sum(1 for n in range(2 ** 39, 2 ** 39 + window)
               if is_smooth_by_trial_division(bound, n))
    print(f"      {hits} smooth candidates in {window} consecutive 40-bit "
          f"integers (density ~ {hits/window:.5f})")
    print(f"      => reaching the quota of {pi_B + 1} relations needs on the "
          f"order of {int((pi_B+1) / max(hits/window, 1e-9)):,} candidates.")
    print("      A faster test does not manufacture relations.")
    print()


# ----------------------------------------------------------------------------

def main() -> None:
    print()
    print("BATCH SMOOTHNESS TESTING -- NUMERICAL DEMONSTRATION")
    print()
    demo_exactness()
    demo_sharpness()
    demo_tree_shape()
    demo_flat_model()
    demo_word_model()
    demo_block_cost()
    demo_amdahl()
    demo_relation_quota()
    print("=" * 74)
    print("All assertions passed.")
    print("=" * 74)


if __name__ == "__main__":
    main()
