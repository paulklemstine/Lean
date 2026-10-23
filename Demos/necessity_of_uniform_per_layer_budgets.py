#!/usr/bin/env python3
"""
Necessity of Uniform Per-Layer Budgets -- numerical companion.

Everything is exact rational arithmetic (fractions.Fraction), so every
equality printed below is an identity, not a floating-point coincidence.

Setting
-------
* A finite state space {0, ..., k-1}.
* A *law* is a probability vector of length k.
* A *channel* (layer) K is a row-stochastic k x k matrix: row a is the law K(a).
* push(K, mu) = mu K  (run one layer on an input law).
* A *stack* is a list of channels applied left to right.
* tv(mu, nu) = (1/2) * sum_b |mu_b - nu_b|  (total variation distance).

Sections
--------
 1. Soundness  <=>  uniform domination      (depth-additivity and its converse)
 2. Single-state certificates fail          (blind pairs for any non-spanning probe set)
 3. The probe-budget dichotomy              (spanning probe sets, probe count >= k)
 4. Masking suffixes                        (every pruning hides from solo probing)
 5. Trajectory costs and window extrapolation
 6. Design budgets and their amplification

Run:  python3 demo.py
"""
from __future__ import annotations

import random
from fractions import Fraction
from typing import List, Optional, Sequence, Tuple

Law = List[Fraction]
Channel = List[Law]          # row a = law K(a)
Stack = List[Channel]

# ---------------------------------------------------------------------------
# Basic objects
# ---------------------------------------------------------------------------


def dirac(k: int, a: int) -> Law:
    """Point mass at state a."""
    return [Fraction(1) if b == a else Fraction(0) for b in range(k)]


def bern(t: Fraction) -> Law:
    """Two-state law putting mass t on state 1."""
    return [1 - t, t]


def push(K: Channel, mu: Sequence[Fraction]) -> Law:
    """Push a law (or any signed vector) through a channel: (mu K)_b = sum_a mu_a K(a)_b."""
    k = len(K)
    return [sum((mu[a] * K[a][b] for a in range(k)), Fraction(0)) for b in range(k)]


def chain(L: Stack, mu: Law) -> Law:
    """Run a whole stack on an input law."""
    for K in L:
        mu = push(K, mu)
    return mu


def tv(mu: Sequence[Fraction], nu: Sequence[Fraction]) -> Fraction:
    """Total variation distance (half the l1 distance)."""
    return sum((abs(x - y) for x, y in zip(mu, nu)), Fraction(0)) / 2


def identity(k: int) -> Channel:
    return [dirac(k, a) for a in range(k)]


def const_channel(d: Law) -> Channel:
    """The forgetful layer: every upstream state is sent to the law d."""
    return [list(d) for _ in range(len(d))]


def random_law(k: int, rng: random.Random, denom: int = 12) -> Law:
    w = [rng.randint(0, denom) for _ in range(k)]
    if sum(w) == 0:
        w[rng.randrange(k)] = 1
    s = sum(w)
    return [Fraction(x, s) for x in w]


def random_channel(k: int, rng: random.Random) -> Channel:
    return [random_law(k, rng) for _ in range(k)]


def perturb_channel(K: Channel, rng: random.Random, strength: Fraction) -> Channel:
    """Mix each row of K with a random law: a 'pruned' version of the layer."""
    k = len(K)
    out: Channel = []
    for row in K:
        r = random_law(k, rng)
        lam = strength * Fraction(rng.randint(0, 10), 10)
        out.append([(1 - lam) * x + lam * y for x, y in zip(row, r)])
    return out


def fmt(x: Fraction) -> str:
    return str(x) if x.denominator <= 1000 else f"{float(x):.6f}"


def fmt_law(mu: Sequence[Fraction]) -> str:
    return "(" + ", ".join(fmt(x) for x in mu) + ")"


# ---------------------------------------------------------------------------
# Budgets
# ---------------------------------------------------------------------------


def uniform_budget(f: Channel, p: Channel) -> Fraction:
    """Worst case over upstream states of the per-layer perturbation."""
    return max(tv(f[a], p[a]) for a in range(len(f)))


def single_state_budget(f: Channel, p: Channel, s: Law) -> Fraction:
    """A budget certified only at one probe law s."""
    return tv(push(f, s), push(p, s))


def budget_sum(budget, F: Stack, P: Stack) -> Fraction:
    return sum((budget(f, p) for f, p in zip(F, P)), Fraction(0))


def hybrid_cost(F: Stack, P: Stack, mu: Law) -> Fraction:
    """Per-layer perturbations measured along the *pruned* trajectory."""
    total = Fraction(0)
    for f, p in zip(F, P):
        total += tv(push(f, mu), push(p, mu))
        mu = push(p, mu)
    return total


def trajectory_cost(F: Stack, P: Stack, mu: Law) -> Fraction:
    """Per-layer perturbations measured along the *intact* trajectory."""
    total = Fraction(0)
    for f, p in zip(F, P):
        total += tv(push(f, mu), push(p, mu))
        mu = push(f, mu)
    return total


# ---------------------------------------------------------------------------
# Exact linear algebra over Q
# ---------------------------------------------------------------------------


def rank(rows: List[Law]) -> int:
    M = [list(r) for r in rows]
    if not M:
        return 0
    n_cols = len(M[0])
    r = 0
    for c in range(n_cols):
        piv = next((i for i in range(r, len(M)) if M[i][c] != 0), None)
        if piv is None:
            continue
        M[r], M[piv] = M[piv], M[r]
        for i in range(len(M)):
            if i != r and M[i][c] != 0:
                fac = M[i][c] / M[r][c]
                M[i] = [x - fac * y for x, y in zip(M[i], M[r])]
        r += 1
    return r


def annihilator(rows: List[Law], k: int) -> Optional[Law]:
    """A nonzero w with sum_a s_a w_a = 0 for every row s, or None if the rows span Q^k."""
    M = [list(r) for r in rows]
    pivots: List[int] = []
    r = 0
    for c in range(k):
        piv = next((i for i in range(r, len(M)) if M[i][c] != 0), None)
        if piv is None:
            continue
        M[r], M[piv] = M[piv], M[r]
        lead = M[r][c]
        M[r] = [x / lead for x in M[r]]
        for i in range(len(M)):
            if i != r and M[i][c] != 0:
                fac = M[i][c]
                M[i] = [x - fac * y for x, y in zip(M[i], M[r])]
        pivots.append(c)
        r += 1
    free = [c for c in range(k) if c not in pivots]
    if not free:
        return None
    fc = free[0]
    w = [Fraction(0)] * k
    w[fc] = Fraction(1)
    for i, pc in enumerate(pivots):
        w[pc] = -M[i][fc]
    return w


def solve_dirac_coefficients(probes: List[Law]) -> List[List[Fraction]]:
    """For k linearly independent probes, return c with dirac(a) = sum_i c[a][i] probes[i]."""
    k = len(probes)
    # Solve c S = I where S has the probes as rows: c = S^{-1}.
    A = [list(probes[i]) + dirac(k, i) for i in range(k)]   # augment [S | I], invert S
    for c in range(k):
        piv = next(i for i in range(c, k) if A[i][c] != 0)
        A[c], A[piv] = A[piv], A[c]
        lead = A[c][c]
        A[c] = [x / lead for x in A[c]]
        for i in range(k):
            if i != c and A[i][c] != 0:
                fac = A[i][c]
                A[i] = [x - fac * y for x, y in zip(A[i], A[c])]
    Sinv = [row[k:] for row in A]
    return Sinv  # row a of S^{-1} expresses dirac(a)


# ---------------------------------------------------------------------------
# Algorithm: witness interpolation (the blind pair)
# ---------------------------------------------------------------------------


def blind_pair(probes: List[Law], k: int, x: int = 0, y: int = 1
               ) -> Optional[Tuple[Channel, Channel, int]]:
    """
    If the probe vectors do not span Q^k (and k >= 2), build two channels g, q that
    respond identically to every probe but whose outputs at some state a0 are
    mutually singular (tv = 1).  Returns (g, q, a0) or None if the probes span.
    """
    w = annihilator(probes, k)
    if w is None:
        return None
    a0 = max(range(k), key=lambda a: abs(w[a]))
    M = abs(w[a0])
    u = [wa / M for wa in w]                 # |u_a| <= 1, |u_{a0}| = 1
    dx, dy = dirac(k, x), dirac(k, y)
    g = [[(1 + u[a]) / 2 * dx[b] + (1 - u[a]) / 2 * dy[b] for b in range(k)] for a in range(k)]
    q = [[(1 - u[a]) / 2 * dx[b] + (1 + u[a]) / 2 * dy[b] for b in range(k)] for a in range(k)]
    return g, q, a0


# ---------------------------------------------------------------------------
# Algorithm: masking suffix
# ---------------------------------------------------------------------------


def mask_stacks(F: Stack, P: Stack, d: Law) -> Tuple[Stack, Stack]:
    """Collapse to d, run the original stack, then forget (intact) / pass through (pruned)."""
    k = len(d)
    Fm = [const_channel(d)] + F + [const_channel(chain(F, d))]
    Pm = [const_channel(d)] + P + [identity(k)]
    return Fm, Pm


def solo_cost(F: Stack, P: Stack, mu: Law, j: int) -> Fraction:
    """Output-level damage of ablating layer j alone (replace F[j] by P[j])."""
    G = list(F)
    G[j] = P[j]
    return tv(chain(F, mu), chain(G, mu))


# ---------------------------------------------------------------------------
# Design budget
# ---------------------------------------------------------------------------


def design_budget(probes: List[Law], coeffs: List[List[Fraction]], f: Channel, p: Channel
                  ) -> Fraction:
    """sum_a sum_i |c[a][i]| * tv(push f s_i, push p s_i): computed from probe responses only."""
    resp = [tv(push(f, s), push(p, s)) for s in probes]
    return sum((abs(coeffs[a][i]) * resp[i]
                for a in range(len(coeffs)) for i in range(len(probes))), Fraction(0))


# ---------------------------------------------------------------------------
# Sections
# ---------------------------------------------------------------------------


def banner(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


def section_1(rng: random.Random) -> None:
    banner("1. Soundness <=> uniform domination (depth-additivity)")
    k = 3
    worst_ratio = Fraction(0)
    for trial in range(200):
        n = rng.randint(1, 6)
        F = [random_channel(k, rng) for _ in range(n)]
        P = [perturb_channel(f, rng, Fraction(1, 3)) for f in F]
        mu = random_law(k, rng)
        joint = tv(chain(F, mu), chain(P, mu))
        hyb = hybrid_cost(F, P, mu)
        ub = budget_sum(uniform_budget, F, P)
        assert joint <= hyb <= ub, "depth-additivity violated?!"
        if ub > 0:
            worst_ratio = max(worst_ratio, joint / ub)
    print("200 random stack pairs on 3 states, depths 1..6:")
    print("  joint damage <= hybrid cost <= sum of uniform budgets  held in every case.")
    print(f"  largest observed ratio joint / (sum of uniform budgets) = {fmt(worst_ratio)}")

    # Closed form n * eps
    eps = Fraction(1, 20)
    f = identity(2)
    p = [[1 - eps, eps], [eps, 1 - eps]]       # flips with probability eps
    for n in (1, 2, 5, 10):
        F, P = [f] * n, [p] * n
        joint = tv(chain(F, dirac(2, 0)), chain(P, dirac(2, 0)))
        print(f"  depth {n:2d}, each layer eps = 1/20 in the worst case: joint = {fmt(joint):>10}"
              f"  <= n*eps = {fmt(n * eps)}")

    # Necessity: the uniform budget is the least sound budget.
    f, p = random_channel(3, rng), random_channel(3, rng)
    a_star = max(range(3), key=lambda a: tv(f[a], p[a]))
    print(f"  Necessity: depth-one stack fed the Dirac input at state {a_star} has damage"
          f" {fmt(tv(f[a_star], p[a_star]))} = uniform budget {fmt(uniform_budget(f, p))}.")
    print("  So any budget charging less than the worst case is unsound on that one-layer stack.")


def section_2() -> None:
    banner("2. Single-state certificates fail: the blind pair")
    # The balanced probe on two states cannot tell identity from a flip.
    s = bern(Fraction(1, 2))
    idk = identity(2)
    flip = [dirac(2, 1), dirac(2, 0)]
    print(f"Probe s = {fmt_law(s)}.  push(id, s) = {fmt_law(push(idk, s))},"
          f" push(flip, s) = {fmt_law(push(flip, s))}")
    print(f"  but tv(id(0), flip(0)) = {fmt(tv(idk[0], flip[0]))}: a single-state budget charges 0,"
          " the damage at the Dirac input is 1.")

    # Witness interpolation through an arbitrary non-spanning probe set on 4 states.
    k = 4
    probes = [[Fraction(1, 4)] * 4,
              [Fraction(1, 2), Fraction(1, 6), Fraction(1, 6), Fraction(1, 6)],
              [Fraction(1, 10), Fraction(2, 10), Fraction(3, 10), Fraction(4, 10)]]
    print(f"\nNon-spanning probe set on {k} states (rank {rank(probes)} < {k}):")
    for pr in probes:
        print("   ", fmt_law(pr))
    res = blind_pair(probes, k)
    assert res is not None
    g, q, a0 = res
    for i, pr in enumerate(probes):
        rg, rq = push(g, pr), push(q, pr)
        assert rg == rq
        print(f"  probe {i}: g responds {fmt_law(rg)}, q responds {fmt_law(rq)}  (identical)")
    print(f"  but at state a0 = {a0}: g(a0) = {fmt_law(g[a0])}, q(a0) = {fmt_law(q[a0])},"
          f" tv = {fmt(tv(g[a0], q[a0]))}")

    # Any probe-blind budget: total budget 0 at every depth, damage 1.
    for n in (0, 3, 7):
        F = [g] + [identity(k)] * n
        P = [q] + [identity(k)] * n
        dmg = tv(chain(F, dirac(k, a0)), chain(P, dirac(k, a0)))
        print(f"  depth {n + 1}: every calibrated probe-local budget totals 0, joint damage = {fmt(dmg)}")


def section_3() -> None:
    banner("3. The probe-budget dichotomy: spanning is necessary and sufficient")
    k = 3
    families = {
        "one interior probe": [[Fraction(1, 3)] * 3],
        "two probes": [[Fraction(1, 2), Fraction(1, 4), Fraction(1, 4)],
                       [Fraction(1, 5), Fraction(3, 5), Fraction(1, 5)]],
        "three interior probes": [[Fraction(1, 2), Fraction(1, 4), Fraction(1, 4)],
                                  [Fraction(1, 5), Fraction(3, 5), Fraction(1, 5)],
                                  [Fraction(1, 6), Fraction(1, 6), Fraction(2, 3)]],
        "three probes, dependent": [[Fraction(1, 2), Fraction(1, 2), Fraction(0)],
                                    [Fraction(0), Fraction(1, 2), Fraction(1, 2)],
                                    [Fraction(1, 4), Fraction(1, 2), Fraction(1, 4)]],
        "the 3 Dirac probes": [dirac(3, a) for a in range(3)],
    }
    for name, probes in families.items():
        r = rank(probes)
        verdict = "SPANS  -> a sound calibrated probe-local budget exists" if r == k else \
            "fails  -> every calibrated probe-local budget is unsound"
        print(f"  {name:26s} rank {r}/{k}: {verdict}")
        if r < k:
            res = blind_pair(probes, k)
            assert res is not None
            g, q, a0 = res
            assert all(push(g, s) == push(q, s) for s in probes)
            assert tv(g[a0], q[a0]) == 1
    print("  Note the dependent family: three probes are not enough unless they are independent;")
    print("  fewer than k = 3 probes never suffice.")


def section_4(rng: random.Random) -> None:
    banner("4. Masking suffix: every pruning instance hides from solo probing")
    k = 3
    F = [random_channel(k, rng) for _ in range(3)]
    P = [perturb_channel(f, rng, Fraction(1)) for f in F]
    d = random_law(k, rng)
    original = tv(chain(F, d), chain(P, d))
    Fm, Pm = mask_stacks(F, P, d)
    print(f"Original depth-3 pair, probe state d = {fmt_law(d)}: joint damage at d = {fmt(original)}")
    print("  original solo costs at d:",
          ", ".join(fmt(solo_cost(F, P, d, j)) for j in range(3)))
    for trial in range(3):
        mu = random_law(k, rng)
        joint = tv(chain(Fm, mu), chain(Pm, mu))
        solos = [solo_cost(Fm, Pm, mu, j) for j in range(len(Fm))]
        assert joint == original and all(sc == 0 for sc in solos)
        print(f"  masked (depth 5) at input {fmt_law(mu)}: joint = {fmt(joint)},"
              f" solo costs = {[fmt(sc) for sc in solos]}")

    # The NET-59 numbers: two states, probe d0, target 17/1000.
    t = Fraction(17, 1000)
    d0 = dirac(2, 0)
    n = 2
    F = [identity(2)] * (n + 1)
    P = [const_channel(bern(t))] * (n + 1)
    Fm, Pm = mask_stacks(F, P, d0)
    mu = bern(Fraction(2, 3))
    print(f"\n  Witness family on 2 states, depth {len(Fm)}: joint damage at {fmt_law(mu)} ="
          f" {fmt(tv(chain(Fm, mu), chain(Pm, mu)))}, solo profile ="
          f" {[fmt(solo_cost(Fm, Pm, mu, j)) for j in range(len(Fm))]}")


def section_5(rng: random.Random) -> None:
    banner("5. Trajectory costs: sound on the window, extrapolate only through the span")
    k = 3
    viol = 0
    for _ in range(200):
        n = rng.randint(1, 5)
        F = [random_channel(k, rng) for _ in range(n)]
        P = [perturb_channel(f, rng, Fraction(1, 2)) for f in F]
        mu = random_law(k, rng)
        if tv(chain(F, mu), chain(P, mu)) > trajectory_cost(F, P, mu):
            viol += 1
    print(f"  200 random pairs: joint damage <= intact-trajectory cost violated {viol} times.")

    # Window extrapolation on two states, window {bern 1/4, bern 3/4}.
    w1, w2 = bern(Fraction(1, 4)), bern(Fraction(3, 4))
    c = [Fraction(3, 2), Fraction(-1, 2)]
    comb = [c[0] * w1[b] + c[1] * w2[b] for b in range(2)]
    print(f"  d0 = 3/2 * bern(1/4) - 1/2 * bern(3/4) = {fmt_law(comb)}   (l1 amplification 2)")
    worst = Fraction(0)
    for _ in range(200):
        n = rng.randint(1, 5)
        F = [random_channel(2, rng) for _ in range(n)]
        P = [perturb_channel(f, rng, Fraction(1, 2)) for f in F]
        lhs = tv(chain(F, dirac(2, 0)), chain(P, dirac(2, 0)))
        rhs = abs(c[0]) * trajectory_cost(F, P, w1) + abs(c[1]) * trajectory_cost(F, P, w2)
        assert lhs <= rhs
        if rhs > 0:
            worst = max(worst, lhs / rhs)
    print(f"  extrapolated bound held on 200 random pairs; tightest ratio = {fmt(worst)}")


def section_6(rng: random.Random) -> None:
    banner("6. Design budgets: an explicit sound budget from probe measurements")
    probes = [[Fraction(1, 2), Fraction(1, 4), Fraction(1, 4)],
              [Fraction(1, 5), Fraction(3, 5), Fraction(1, 5)],
              [Fraction(1, 6), Fraction(1, 6), Fraction(2, 3)]]
    C = solve_dirac_coefficients(probes)
    for a in range(3):
        recon = [sum((C[a][i] * probes[i][b] for i in range(3)), Fraction(0)) for b in range(3)]
        assert recon == dirac(3, a)
        print(f"  dirac({a}) = " + " + ".join(f"({fmt(C[a][i])})*s{i}" for i in range(3))
              + f"   amplification {fmt(sum(abs(x) for x in C[a]))}")
    for _ in range(300):
        f = random_channel(3, rng)
        p = perturb_channel(f, rng, Fraction(1))
        assert design_budget(probes, C, f, p) >= uniform_budget(f, p)
    print("  design budget >= uniform budget on 300 random layer pairs  (hence sound).")

    print("\n  Amplification of the symmetric two-state design {bern(eta), bern(1-eta)}:")
    for eta in (Fraction(0), Fraction(1, 10), Fraction(1, 4), Fraction(2, 5), Fraction(9, 20)):
        Cd = solve_dirac_coefficients([bern(eta), bern(1 - eta)])
        amp = max(sum(abs(x) for x in row) for row in Cd)
        print(f"    eta = {fmt(eta):>5}: max_a sum_i |c_ai| = {fmt(amp):>4}   (1/(1-2 eta) = {fmt(1 / (1 - 2 * eta))})")


def main() -> None:
    rng = random.Random(59)
    section_1(rng)
    section_2()
    section_3()
    section_4(rng)
    section_5(rng)
    section_6(rng)
    print("\nAll checks passed.")


if __name__ == "__main__":
    main()
