#!/usr/bin/env python3
"""
Faithful-model slackness for the exponent-one-fifth factoring cost model.

Numerical companion to the article and paper.  Everything is self-contained
(standard library only) and every optimum is computed EXACTLY with rational
arithmetic by enumerating the vertices of a small linear program.

Exponent model.  Write r = N^a (pair floor) and m = N^b (baby-step budget).
Up to logarithmic factors the four legs of the faithful cost are

    M-leg      (N/r)^(1/4)            ->  exponent (1 - a)/4
    interior   N^(1/2) / (r^(1/2) m)  ->  exponent 1/2 - a/2 - b
    pair       r                      ->  exponent a
    baby       m                      ->  exponent b

and the running time is N^(max of the exponents).  Minimising the max of
linear functions is a linear program in (a, b, t).
"""
from __future__ import annotations

import itertools
import math
import random
from fractions import Fraction as F
from typing import Dict, List, Optional, Sequence, Tuple

# A "leg" is an affine function of the variables (a, b, c):
#   value = const + ca*a + cb*b + cc*c
Leg = Tuple[F, F, F, F]  # (const, ca, cb, cc)


def leg(const: F | int, ca: F | int = 0, cb: F | int = 0, cc: F | int = 0) -> Leg:
    return (F(const), F(ca), F(cb), F(cc))


def solve_linear(A: List[List[F]], y: List[F]) -> Optional[List[F]]:
    """Exact Gaussian elimination; returns None if the system is singular."""
    n = len(A)
    M = [row[:] + [y[i]] for i, row in enumerate(A)]
    for col in range(n):
        piv = next((r for r in range(col, n) if M[r][col] != 0), None)
        if piv is None:
            return None
        M[col], M[piv] = M[piv], M[col]
        p = M[col][col]
        M[col] = [v / p for v in M[col]]
        for r in range(n):
            if r != col and M[r][col] != 0:
                f = M[r][col]
                M[r] = [vr - f * vc for vr, vc in zip(M[r], M[col])]
    return [M[i][n] for i in range(n)]


def minimax_exponent(legs: Sequence[Leg], use_c: bool = False,
                     box: Tuple[F, F] = (F(0), F(1))) -> Tuple[F, Tuple[F, ...]]:
    """Exact value of  min_{a,b(,c) in box} max_legs  by vertex enumeration.

    Variables x = (a, b, [c], t).  Constraints:  t - leg(x) >= 0 for each leg,
    and lo <= a, b, c <= hi.  The optimum of a bounded LP is attained at a vertex,
    i.e. at a point where dim(x) linearly independent constraints are tight.
    """
    nv = 3 if use_c else 2
    dim = nv + 1
    rows: List[Tuple[List[F], F]] = []  # constraint  row . x >= rhs
    for (k, ca, cb, cc) in legs:
        coeffs = [-ca, -cb] + ([-cc] if use_c else []) + [F(1)]
        rows.append((coeffs, k))
    lo, hi = box
    for i in range(nv):
        e = [F(0)] * dim
        e[i] = F(1)
        rows.append((e, lo))
        rows.append(([-v for v in e], -hi))
    best: Optional[F] = None
    arg: Tuple[F, ...] = ()
    for combo in itertools.combinations(range(len(rows)), dim):
        A = [rows[i][0] for i in combo]
        y = [rows[i][1] for i in combo]
        x = solve_linear(A, y)
        if x is None:
            continue
        if all(sum(c * v for c, v in zip(r, x)) >= rhs for r, rhs in rows):
            if best is None or x[-1] < best:
                best, arg = x[-1], tuple(x[:-1])
    assert best is not None
    return best, arg


# ---------------------------------------------------------------- the models
M_LEG = leg(F(1, 4), F(-1, 4))          # (1-a)/4
INTERIOR = leg(F(1, 2), F(-1, 2), -1)   # 1/2 - a/2 - b
PAIR = leg(0, 1)                        # a
BABY = leg(0, 0, 1)                     # b

FAITHFUL: Dict[str, Leg] = {"M-leg": M_LEG, "interior": INTERIOR,
                            "pair r": PAIR, "baby m": BABY}


def show(title: str) -> None:
    print("\n" + "=" * 74 + f"\n{title}\n" + "=" * 74)


def demo_optimum_and_uniqueness() -> None:
    show("1. Faithful four-leg model and three-leg relaxation: both give 1/5")
    v, x = minimax_exponent(list(FAITHFUL.values()))
    print(f"faithful   max{{(1-a)/4, 1/2-a/2-b, a, b}}  optimum = {v} at (a,b) = {x}")
    v2, x2 = minimax_exponent([INTERIOR, PAIR, BABY])
    print(f"relaxation max{{1/2-a/2-b, a, b}}           optimum = {v2} at (a,b) = {x2}")
    # uniqueness: perturb the minimiser in every direction
    worst = min(
        max(l[0] + l[1] * (F(1, 5) + da) + l[2] * (F(1, 5) + db) for l in FAITHFUL.values())
        for da in (F(-1, 1000), F(0), F(1, 1000)) for db in (F(-1, 1000), F(0), F(1, 1000))
        if (da, db) != (0, 0))
    print(f"smallest cost among 8 perturbations of size 1e-3: {worst} (> 1/5: unique minimiser)")


def demo_slackness() -> None:
    show("2. Slackness: delete legs and recompute the exact optimum")
    print("  (exponents are restricted to the box 0 <= a, b <= 1; values below 1/5 mean")
    print("   the kept legs alone no longer certify the bound)")
    names = list(FAITHFUL)
    certs: List[Tuple[str, ...]] = []
    for k in range(1, 5):
        for subset in itertools.combinations(names, k):
            v, x = minimax_exponent([FAITHFUL[s] for s in subset])
            tag = ""
            if v == F(1, 5):
                if any(set(c) <= set(subset) for c in certs):
                    tag = "  (contains a certificate)"
                else:
                    certs.append(subset)
                    tag = "  <-- MINIMAL CERTIFICATE"
            print(f"  keep {{{', '.join(subset)}}}".ljust(52) + f"optimum {str(v):>5}{tag}")
    print("Minimal certificates: {M-leg, pair r} and {interior, pair r, baby m}.")
    print("They overlap only in the pair floor r, so beating 1/5 needs BOTH broken.")


def demo_deletion_penalties() -> None:
    show("3. Floor deletions (the attribution question)")
    v_m, x_m = minimax_exponent(list(FAITHFUL.values()), box=(F(0), F(1)))
    # delete the baby-step floor: force b = 0
    vals = [(max(F(1, 4) - a / 4, F(1, 2) - a / 2, a), a)
            for a in (F(i, 600) for i in range(601))]
    vm, am = min(vals)
    # delete the pair floor: force a = 0
    vals2 = [(max(F(1, 4), F(1, 2) - b, b), b) for b in (F(i, 600) for i in range(601))]
    vp, bp = min(vals2)
    print(f"  baseline optimum                    {v_m}")
    print(f"  baby-step floor deleted (b = 0):    {vm} at a = {am}   penalty {vm - F(1, 5)}")
    print(f"  pair floor deleted      (a = 0):    {vp} at b = {bp}   penalty {vp - F(1, 5)}")
    print("  => N^(1/20) is the pair-floor deletion; the m-floor deletion costs N^(2/15).")


def demo_fourth_floor() -> None:
    show("4. A fourth search floor c of weight w (interior becomes 1/2-a/2-b-w c)")
    for w in (F(0), F(1, 4), F(1, 2), F(1), F(2)):
        interior_w = leg(F(1, 2), F(-1, 2), -1, -w)
        relax = [leg(0, 1), leg(0, 0, 1), leg(0, 0, 0, 1), interior_w]
        vr, _ = minimax_exponent(relax, use_c=True)
        vf, _ = minimax_exponent(relax + [M_LEG], use_c=True)
        print(f"  w = {str(w):>4}: relaxation optimum {str(vr):>5} (formula 1/(5+2w) = "
              f"{F(1) / (5 + 2 * w)}),  faithful optimum {vf}")
    print("  The lever works in the relaxation only: the M-leg never sees the new floor.")


def demo_mleg_exponent() -> None:
    show("5. Generalised M-leg (N/r)^mu: the {M, r} pair is optimised at mu/(1+mu)")
    for mu in (F(1, 2), F(1, 3), F(1, 4), F(1, 5), F(1, 6)):
        v, x = minimax_exponent([leg(mu, -mu), PAIR])
        print(f"  mu = {str(mu):>4}: optimum {str(v):>5} = mu/(1+mu) = {mu / (1 + mu)}"
              f"   {'reaches 1/6' if v <= F(1, 6) else ''}")
    print("  Harvey's mu = 1/4 gives exactly 1/5; exponent 1/6 needs mu <= 1/5.")


def demo_certificate_law() -> None:
    show("6. Independent certificate law: optimum = max(mu/(1+mu), gamma/(2+alpha))")
    rng = random.Random(2026)
    for _ in range(8):
        mu = F(rng.randint(1, 12), rng.randint(2, 12))
        gamma = F(rng.randint(1, 12), rng.randint(2, 12))
        alpha = F(rng.randint(0, 6), rng.randint(1, 6))
        legs = [leg(mu, -mu), leg(gamma, -alpha, -1), PAIR, BABY]
        v, _ = minimax_exponent(legs, box=(F(-5), F(5)))
        pred = max(mu / (1 + mu), gamma / (2 + alpha))
        print(f"  mu={str(mu):>5} gamma={str(gamma):>5} alpha={str(alpha):>4}:"
              f"  LP {str(v):>7}  law {str(pred):>7}  {'OK' if v == pred else 'MISMATCH'}")


def demo_coupling() -> None:
    show("7. Coupling the M-leg to the baby steps: (1-a)/4 - theta*b")
    for theta in (F(0), F(1, 8), F(1, 5), F(1, 4), F(1, 3), F(1)):
        coupled = leg(F(1, 4), F(-1, 4), -theta)
        alone, _ = minimax_exponent([coupled, INTERIOR, PAIR, BABY])
        with_floor, _ = minimax_exponent(
            [coupled, leg(F(1, 2), F(-1, 2), -1, F(-1, 2)), PAIR, BABY, leg(0, 0, 0, 1)],
            use_c=True)
        print(f"  theta = {str(theta):>4}: coupling alone {alone};  with weight-1/2 floor "
              f"{str(with_floor):>6}  {'<= 1/6' if with_floor <= F(1, 6) else ''}")
    print("  Exponent 1/6 is reached exactly when theta >= 1/4 (sharp threshold).")


def demo_partition_lemma() -> None:
    show("8. Partition lemma: sum(L_i + T_i) >= 2 sqrt(sum S_i)")
    rng = random.Random(7)
    worst_ratio = math.inf
    for _ in range(20000):
        k = rng.randint(1, 6)
        S = [rng.uniform(0, 100) for _ in range(k)]
        L = [rng.uniform(0.01, 30) for _ in range(k)]
        T = [max(s / l, 0.0) * rng.uniform(1.0, 1.5) for s, l in zip(S, L)]
        ratio = sum(L) + sum(T)
        ratio /= 2 * math.sqrt(sum(S)) if sum(S) > 0 else 1
        worst_ratio = min(worst_ratio, ratio)
    print(f"  20000 random multi-level structures: min cost / (2 sqrt S) = {worst_ratio:.4f} >= 1")
    S = 10 ** 6
    print(f"  pool S = {S}: single level cost 2 sqrt S = {2 * math.sqrt(S):.1f}")
    for k in (1, 2, 4, 9, 16):
        cost = k * 2 * math.sqrt(S / k)
        print(f"    uniform {k:>2}-way split: cost {cost:9.1f} = sqrt({k}) * 2 sqrt S"
              f"  (ratio {cost / (2 * math.sqrt(S)):.3f})")


def demo_real_powers() -> None:
    show("9. Real-power slackness: max{(N/r)^(1/4), r} >= N^(1/5) for every r > 0")
    for N in (10.0 ** 12, 10.0 ** 30, 2.0 ** 200):
        rs = [N ** (i / 400) for i in range(401)]
        best = min(max((N / r) ** 0.25, r) for r in rs)
        print(f"  N = {N:.3e}: min over r of max{{(N/r)^(1/4), r}} = {best:.6e},"
              f"  N^(1/5) = {N ** 0.2:.6e}")
    print("  The interior and the m-leg do not appear at all: they are slack.")


if __name__ == "__main__":
    demo_optimum_and_uniqueness()
    demo_slackness()
    demo_deletion_penalties()
    demo_fourth_floor()
    demo_mleg_exponent()
    demo_certificate_law()
    demo_coupling()
    demo_partition_lemma()
    demo_real_powers()
