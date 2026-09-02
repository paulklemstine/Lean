"""
The Attention Knee: exact audit, exact power, and the tail mechanism.
=====================================================================

A self-contained numerical companion to the paper
"Where the Knee Lives: Head Statistics, Tail Shape, and the Exact
Small-Sample Calculus of a Five-Domain Attention Study".

Everything below runs in exact arithmetic (``fractions.Fraction``) wherever
exactness is available, so the printed numbers are the theorems, not
floating-point approximations of them.

Contents
--------
1. The five-domain table and the three midrank Spearman coefficients.
2. Robustness: every reading of the censored knee, every tie-break.
3. Exact permutation calculus on five items: the size of a |rho| >= 0.7 bar
   and the one-sided p-value of the strongest column.
4. Capture curves, knees, and the exact tail-reduction identity.
5. Head/knee decoupling via staged profiles: same head, knees arbitrarily
   far apart; both signs of the head-mass/knee association realisable.
6. Quantitative tail shape: geometric upper bound, Pareto lower bound.
7. The l^2 (participation ratio) bound k* >= tau^2 / C, its attainment by
   the uniform profile, and its one-sidedness.

Run with:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction as F
from itertools import permutations
from math import sqrt
from typing import Callable, Dict, Iterable, List, Sequence, Tuple

# ----------------------------------------------------------------------
# 0. Pretty printing helpers
# ----------------------------------------------------------------------


def rule(title: str) -> None:
    print("\n" + "=" * 74)
    print(title)
    print("=" * 74)


def frac(x: F) -> str:
    return f"{x.numerator}/{x.denominator}" if x.denominator != 1 else f"{x.numerator}"


# ----------------------------------------------------------------------
# 1. The five-domain table and midrank Spearman
# ----------------------------------------------------------------------

DOMAINS: List[str] = ["code", "prose-en", "math", "prose-de", "prose-fr"]

ENTROPY: List[F] = [F(3798, 1000), F(3801, 1000), F(3615, 1000),
                    F(3752, 1000), F(3864, 1000)]
TOP8: List[F] = [F(488, 1000), F(488, 1000), F(526, 1000),
                 F(502, 1000), F(473, 1000)]
HEAD_AGR: List[F] = [F(83, 1000), F(82, 1000), F(86, 1000),
                     F(80, 1000), F(79, 1000)]
# prose-fr's knee is recorded as ">24"; 24 is the smallest admissible reading.
KSTAR: List[F] = [F(12), F(16), F(16), F(20), F(24)]


def midranks(x: Sequence[F]) -> List[F]:
    """Average ('midrank') ranks of a column, ties shared equally."""
    out: List[F] = []
    for xi in x:
        smaller = sum(1 for xj in x if xj < xi)
        tied = sum(1 for xj in x if xj == xi)
        out.append(F(1) + smaller + F(tied - 1, 2))
    return out


def rank_cov(x: Sequence[F], y: Sequence[F]) -> F:
    """Rank covariance S_xy = sum (r_x - mean)(r_y - mean)."""
    rx, ry = midranks(x), midranks(y)
    mx, my = sum(rx) / len(rx), sum(ry) / len(ry)
    return sum((a - mx) * (b - my) for a, b in zip(rx, ry))


def spearman(x: Sequence[F], y: Sequence[F]) -> float:
    """Spearman's rho = S_xy / sqrt(S_xx S_yy)  (float; exact parts printed)."""
    return float(rank_cov(x, y)) / sqrt(float(rank_cov(x, x)) * float(rank_cov(y, y)))


def part_one_audit() -> None:
    rule("1. The measured table and the three Spearman coefficients (exact)")
    header = f"{'domain':<10}{'entropy':>10}{'top-8':>10}{'head agr':>11}{'k*@512':>9}"
    print(header)
    print("-" * len(header))
    for i, d in enumerate(DOMAINS):
        k = ">24" if d == "prose-fr" else str(int(KSTAR[i]))
        print(f"{d:<10}{float(ENTROPY[i]):>10.3f}{float(TOP8[i]):>10.3f}"
              f"{float(HEAD_AGR[i]):>11.3f}{k:>9}")

    print("\nMidranks")
    for name, col in (("entropy", ENTROPY), ("top-8", TOP8),
                      ("head agr", HEAD_AGR), ("k*", KSTAR)):
        print(f"  {name:<9}: {[frac(r) for r in midranks(col)]}")

    s_kk = rank_cov(KSTAR, KSTAR)
    print(f"\nS_(k*,k*) = {frac(s_kk)}   S_(ent,ent) = {frac(rank_cov(ENTROPY, ENTROPY))}"
          f"   S_(top8,top8) = {frac(rank_cov(TOP8, TOP8))}"
          f"   S_(head,head) = {frac(rank_cov(HEAD_AGR, HEAD_AGR))}")

    print("\nRank covariances with k* and the resulting rho:")
    reported = {"entropy": -0.60, "top-8 mass": +0.80, "head agreement": -0.40}
    for name, col, exact in (
        ("entropy", ENTROPY, "7/(2*sqrt(95))"),
        ("top-8 mass", TOP8, "-11/38"),
        ("head agreement", HEAD_AGR, "-8/sqrt(95)"),
    ):
        print(f"  {name:<15} S = {frac(rank_cov(col, KSTAR)):>6}"
              f"   rho = {spearman(col, KSTAR):+.4f}  (= {exact})"
              f"   reported: {reported[name]:+.2f}")

    order = sorted((("entropy", abs(spearman(ENTROPY, KSTAR))),
                    ("top-8 mass", abs(spearman(TOP8, KSTAR))),
                    ("head agreement", abs(spearman(HEAD_AGR, KSTAR)))),
                   key=lambda p: -p[1])
    print("\n  |rho| ranking (recomputed): " +
          " > ".join(f"{n} ({v:.3f})" for n, v in order))
    print("  reported ranking:            top-8 mass > entropy > head agreement")
    print("  => the ranking of the three predictors is exactly inverted.")


# ----------------------------------------------------------------------
# 2. Robustness: censoring and tie-breaks
# ----------------------------------------------------------------------


def part_two_robustness() -> None:
    rule("2. Robustness of the audit")
    print("(a) prose-fr's knee is censored at '>24'.  Every reading v > 20 gives")
    print("    the same midranks, hence the same coefficients:")
    for v in (F(21), F(24), F(25), F(64), F(1000)):
        col = [F(12), F(16), F(16), F(20), v]
        print(f"    v = {frac(v):>6}:  S_top8 = {frac(rank_cov(TOP8, col)):>6},"
              f"  S_entropy = {frac(rank_cov(ENTROPY, col)):>4},"
              f"  S_headAgr = {frac(rank_cov(HEAD_AGR, col)):>4}")

    print("\n(b) Ordinal tie-breaks.  The two ties are top-8 (code = prose-en) and")
    print("    k* (prose-en = math).  Enumerate all admissible integer rankings:")

    def ordinal_rankings(col: Sequence[F]) -> Iterable[Tuple[int, ...]]:
        """All bijections onto {1..5} that are strictly monotone in the data."""
        n = len(col)
        for perm in permutations(range(1, n + 1)):
            ok = all((col[i] < col[j]) <= (perm[i] < perm[j]) and
                     (perm[i] < perm[j]) <= (col[i] <= col[j])
                     for i in range(n) for j in range(n) if i != j)
            if ok:
                yield perm

    def zcov(r: Sequence[int], s: Sequence[int]) -> int:
        return sum((a - 3) * (b - 3) for a, b in zip(r, s))

    ks = list(ordinal_rankings(KSTAR))
    for name, col in (("entropy", ENTROPY), ("top-8", TOP8), ("head agr", HEAD_AGR)):
        vals = sorted({zcov(r, s) for r in ordinal_rankings(col) for s in ks})
        rhos = sorted(float(F(v, 10)) for v in vals)  # rho = S / 10 for two full rankings
        print(f"    {name:<9}: rank covariances over all tie-breaks = {vals}"
              f"  -> rho in {rhos}")
    print("\n    top-8/knee is negative under EVERY tie-break (rho <= -0.1);")
    print("    entropy/knee is positive under every tie-break (rho >= +0.2);")
    print("    head-agreement/knee is <= -0.7 under every tie-break.")


# ----------------------------------------------------------------------
# 3. Exact permutation calculus on five items
# ----------------------------------------------------------------------


def dsq(perm: Sequence[int]) -> int:
    """Squared rank displacement sum (sigma(i) - i)^2 for a permutation of 0..4."""
    return sum((perm[i] - i) ** 2 for i in range(len(perm)))


def rho_from_D(D: int) -> F:
    """Spearman's rho at n = 5:  rho = 1 - 6D/(n(n^2-1)) = 1 - D/20."""
    return F(1) - F(D, 20)


def part_three_power() -> None:
    rule("3. Exact permutation calculus at n = 5")
    all_perms = list(permutations(range(5)))
    assert len(all_perms) == 120
    dist: Dict[int, int] = {}
    for p in all_perms:
        dist[dsq(p)] = dist.get(dsq(p), 0) + 1
    print("Null distribution of D = sum (sigma(i)-i)^2 over S_5 (120 permutations):")
    print(f"  {'D':>4} {'rho':>9} {'count':>6}")
    for D in sorted(dist):
        print(f"  {D:>4} {float(rho_from_D(D)):>9.2f} {dist[D]:>6}")

    bar = sum(c for D, c in dist.items() if abs(rho_from_D(D)) >= F(7, 10))
    print(f"\n  #{{ |rho| >= 0.7 }} = {bar} of 120  ->  exact size "
          f"{frac(F(bar, 120))} = {float(F(bar,120)):.4f}")
    print("  A pre-registered |rho| >= 0.7 bar is therefore roughly a 23% test,")
    print("  not a 5% test: nearly one random pairing in four clears it.")

    tail34 = sum(c for D, c in dist.items() if D >= 34)
    tail38 = sum(c for D, c in dist.items() if D >= 38)
    print(f"\n  one-sided tails:  #{{D >= 34}} = {tail34} -> p = {frac(F(tail34,120))}"
          f" = {float(F(tail34,120)):.4f}")
    print(f"                    #{{D >= 38}} = {tail38} -> p = {frac(F(tail38,120))}"
          f" = {float(F(tail38,120)):.4f}")

    print("\n  Head agreement vs. the knee, the strongest column in the table:")
    r = (4, 3, 5, 2, 1)
    for label, s in (("tie -> prose-en first", (1, 2, 3, 4, 5)),
                     ("tie -> math first    ", (1, 3, 2, 4, 5))):
        D = sum((a - b) ** 2 for a, b in zip(r, s))
        p = F(sum(c for Dp, c in dist.items() if Dp >= D), 120)
        verdict = "significant at 5%" if p < F(1, 20) else "NOT significant at 5%"
        print(f"    {label}:  D = {D:>3}, rho = {float(rho_from_D(D)):+.2f},"
              f"  p = {frac(p)} = {float(p):.4f}  ({verdict})")
    print("\n  The tie in the data, not the data, decides the verdict.")


# ----------------------------------------------------------------------
# 4. Capture curves, knees, and the exact tail reduction
# ----------------------------------------------------------------------

CaptureCurve = Callable[[int], F]


def knee_at(cum: CaptureCurve, tau: F, bound: int = 100000) -> int:
    """Least k with cum(k) >= tau."""
    for k in range(bound + 1):
        if cum(k) >= tau:
            return k
    raise ValueError("knee not reached within bound")


def tail_knee(cum: CaptureCurve, r: int, tau: F, bound: int = 100000) -> int:
    """Least j with cum(r + j) >= tau: the knee computed inside the residual."""
    for j in range(bound + 1):
        if cum(r + j) >= tau:
            return j
    raise ValueError("tail knee not reached within bound")


def residual(cum: CaptureCurve, r: int) -> F:
    return F(1) - cum(r)


def uniform_profile(tau: F, k: int) -> CaptureCurve:
    """Capture curve rising linearly to tau at key k: cum(n) = min(1, n*tau/k)."""
    return lambda n: min(F(1), F(n) * tau / k)


def staged_profile(c: F, tau: F, r: int, k: int) -> CaptureCurve:
    """Head mass c at key r, then a linear ramp reaching tau exactly at key k."""
    step = (tau - c) / (F(k) - F(r))

    def cum(j: int) -> F:
        if j == 0:
            return F(0)
        return min(F(1), c + F(max(j - r, 0)) * step)

    return cum


def part_four_tail_reduction() -> None:
    rule("4. The exact tail reduction  k* = r + (knee of the residual curve)")
    tau = F(9, 10)
    P = staged_profile(F(1, 2), tau, 8, 20)
    r = 8
    print(f"  tolerance tau = {frac(tau)}, head budget r = {r}")
    print(f"  cum(r) = {frac(P(r))} < tau, residual = {frac(residual(P, r))}")
    print(f"  k*        = {knee_at(P, tau)}")
    print(f"  r + tailKnee = {r} + {tail_knee(P, r, tau)} = {r + tail_knee(P, r, tau)}")
    print("  -> the knee splits exactly into head budget + tail knee.")

    print("\n  Two curves that agree from key r on have the same knee, whatever")
    print("  their heads do:")
    Q = staged_profile(F(1, 2), tau, 8, 20)

    def Q_bumped(j: int) -> F:  # same values from r on, different head
        return F(0) if j == 0 else (min(F(4, 10), F(j) * F(1, 10)) if j < r else Q(j))

    print(f"    head values differ:  P(3) = {frac(P(3))} vs Q'(3) = {frac(Q_bumped(3))}")
    print(f"    knees agree:         k*(P) = {knee_at(P, tau)},"
          f"  k*(Q') = {knee_at(Q_bumped, tau)}")


# ----------------------------------------------------------------------
# 5. Head/knee decoupling
# ----------------------------------------------------------------------


def part_five_decoupling() -> None:
    rule("5. Head mass determines nothing about the knee")
    tau = F(9, 10)
    print(f"  tolerance tau = {frac(tau)};  head statistic = top-8 mass cum(8)\n")
    print("  (a) Same head mass, any knee you like:")
    for k in (9, 12, 25, 200):
        P = staged_profile(F(1, 2), tau, 8, k)
        print(f"      cum(8) = {frac(P(8))},  k* = {knee_at(P, tau):>4}  (target {k})")
    print("      => no function g with k* = g(top-8 mass) can exist.")

    print("\n  (b) Both signs of the head-mass/knee association are realisable:")
    P = staged_profile(F(1, 2), tau, 8, 9)
    Q = staged_profile(F(3, 4), tau, 8, 12)
    print(f"      more head mass, later knee:  {frac(P(8))} -> k* = {knee_at(P, tau)}"
          f" ;  {frac(Q(8))} -> k* = {knee_at(Q, tau)}")
    P2 = staged_profile(F(1, 2), tau, 8, 12)
    Q2 = staged_profile(F(3, 4), tau, 8, 9)
    print(f"      more head mass, earlier knee: {frac(P2(8))} -> k* = {knee_at(P2, tau)}"
          f" ;  {frac(Q2(8))} -> k* = {knee_at(Q2, tau)}")
    print("      => the SIGN of a measured head-mass/knee correlation carries no")
    print("         information about the underlying mechanism.")

    print("\n  (c) Tail shape dominates the head: identical first eight keys,")
    print("      knees arbitrarily far apart:")
    for N in (10, 100, 1000):
        A = staged_profile(F(1, 2), tau, 8, 9)
        B = staged_profile(F(1, 2), tau, 8, 9 + N)
        same = all(A(j) == B(j) for j in range(9))
        print(f"      N = {N:>5}: heads identical through key 8? {same};"
              f"  k*(A) = {knee_at(A, tau)}, k*(B) = {knee_at(B, tau)}")


# ----------------------------------------------------------------------
# 6. Quantitative tail shape
# ----------------------------------------------------------------------


def part_six_tail_shape() -> None:
    rule("6. Tail shape, quantitatively: geometric vs. Pareto residuals")
    r = 8

    print("  Geometric residual  1 - cum(r+j) <= R * rho^j:")
    print(f"  {'tau':>7} {'R':>5} {'rho':>5} {'least j with R rho^j <= 1-tau':>32} {'bound k* <=':>12}")
    R, rr = F(1, 2), F(1, 2)
    for tau in (F(9, 10), F(99, 100), F(999, 1000)):
        j = 0
        while R * rr ** j > F(1) - tau:
            j += 1
        print(f"  {float(tau):>7.3f} {frac(R):>5} {frac(rr):>5} {j:>32} {r + j:>12}")
    print("  -> a geometric tail gives a LOGARITHMIC knee: k* <= r + log(R/(1-tau))/log(1/rho).")

    print("\n  Pareto (heavy) residual  1 - cum(r+j) >= R/(j+1):")
    print(f"  {'tau':>7} {'R':>5} {'forced k* - r + 1 >= R/(1-tau)':>34}")
    R = F(1, 2)
    for tau in (F(9, 10), F(99, 100), F(999, 1000)):
        print(f"  {float(tau):>7.3f} {frac(R):>5} {float(R / (1 - tau)):>34.1f}")
    print("  -> a Pareto tail gives a LINEAR-in-1/(1-tau) knee, diverging as tau -> 1.")
    print("  The same head can sit above either tail: only the tail decides.")


# ----------------------------------------------------------------------
# 7. The participation ratio (l^2) bound
# ----------------------------------------------------------------------


def key_masses(cum: CaptureCurve, k: int) -> List[F]:
    return [cum(j + 1) - cum(j) for j in range(k)]


def collision_mass(cum: CaptureCurve, k: int) -> F:
    """Inverse participation ratio of the k heaviest keys: sum of squared masses."""
    return sum(m * m for m in key_masses(cum, k))


def part_seven_participation() -> None:
    rule("7. The participation bound  k* >= tau^2 / C")
    tau = F(9, 10)
    print(f"  tolerance tau = {frac(tau)}\n")
    print("  Cauchy-Schwarz on the capture curve:  cum(k)^2 <= k * C(k).")
    for k in (5, 10, 40):
        P = uniform_profile(tau, k)
        C = collision_mass(P, k)
        lhs = P(k) ** 2
        print(f"    uniform over {k:>2} keys: cum(k)^2 = {frac(lhs):>12},"
              f"  k*C(k) = {frac(F(k) * C):>12},  C(k) = {frac(C):>10} (= tau^2/k)")
    print("    -> equality for the uniform profile: the bound is attained.")

    print("\n  Consequence: if the collision mass never exceeds C then k* >= tau^2/C.")
    print(f"  {'C':>10} {'tau^2/C':>10} {'a witness profile':>26} {'its k*':>8}")
    for k in (5, 20, 100):
        P = uniform_profile(tau, k)
        C = max(collision_mass(P, n) for n in range(1, k + 2))
        print(f"  {float(C):>10.5f} {float(tau ** 2 / C):>10.3f}"
              f" {'uniform over ' + str(k) + ' keys':>26} {knee_at(P, tau):>8}")

    print("\n  One-sidedness: for any collision budget C > 0 and any target N there")
    print("  is a profile with collision mass <= C at every prefix and k* >= N.")
    C = F(1, 100)
    for N in (50, 500):
        k = max(N, int(tau / C) + 1)
        P = uniform_profile(tau, k)
        worst = max(collision_mass(P, n) for n in range(1, k + 2))
        print(f"    C = {frac(C)}, N = {N:>4}:  uniform over {k} keys has"
              f" max collision {float(worst):.6f} <= {float(C)} and k* = {knee_at(P, tau)}")
    print("\n  So the participation ratio pins the knee from below and not at all")
    print("  from above -- the generic shape of every scalar head statistic.")


# ----------------------------------------------------------------------
# main
# ----------------------------------------------------------------------


def main() -> None:
    part_one_audit()
    part_two_robustness()
    part_three_power()
    part_four_tail_reduction()
    part_five_decoupling()
    part_six_tail_shape()
    part_seven_participation()
    rule("Summary")
    print("""  * The three reported coefficients (-0.60 / +0.80 / -0.40) are not what
    the tabulated numbers give: exactly, +7/(2*sqrt 95), -11/38, -8/sqrt 95.
  * At five domains a |rho| >= 0.7 bar has exact size 7/30 ~ 0.233.
  * The knee is a functional of the tail alone; head mass constrains it not
    at all, and the sign of any head/knee correlation is free.
  * Concentration statistics bound the knee from below only: k* >= tau^2/C,
    attained by the uniform profile, with no upper bound of any kind.""")


if __name__ == "__main__":
    main()
