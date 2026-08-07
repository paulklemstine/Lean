"""
Exact numerical demonstrations of the complete p-biased Fourier expansion on the
discrete cube, and of the exact defects in the two classical influence
inequalities for monotone events.

Everything is computed in exact rational arithmetic (fractions.Fraction), so the
identities below are verified *exactly*, with no floating-point tolerance.

Setting
-------
Sites are 0, 1, ..., N-1.  A configuration is an int whose bit v is 1 iff site v
is "open".  A frequency (a set of sites) is likewise an int bitmask.

    w_p(eta)   = prod_v ( p if eta_v else q ),          q = 1 - p
    E_p[f]     = sum_eta w_p(eta) f(eta)
    psi_v(eta) = q if eta_v else -p          (equivalently eta_v - p)
    psi_S      = prod_{v in S} psi_v
    fhat(S)    = E_p[f psi_S] / (pq)^{|S|}
    E_S(f)     = (pq)^{|S|} fhat(S)^2                   ("level energy")

Results verified
----------------
  1. Orthogonality        E_p[psi_S psi_T] = [S=T] (pq)^{|S|}
  2. Completeness         f = sum_S fhat(S) psi_S
  3. Parseval             E_p[f g] = sum_S (pq)^{|S|} fhat(S) ghat(S)
  4. Plancherel (Boolean) sum_S E_S(g) = 1 for a +/-1 indicator g
  5. Margulis-Russo       ghat({v}) = 2 I_v for an increasing event
  6. Energy decomposition 4 P(1-P) = 4pq sum_v I_v^2 + sum_{|S|>=2} E_S
  7. Site energy          sum_{S ni v} E_S(f) = pq E_p[(D_v f)^2]
  8. Efron-Stein defect   pq sum_v E_p[(D_v f)^2] - Var(f)
                              = sum_{S != 0} (|S|-1) E_S(f)
  9. Poincare defect      4pq sum_v I_v - 4 P(1-P)
                              = sum_{S != 0} (|S|-1) E_S(g)
 10. Equality criterion   both inequalities are tight exactly for events of
                          Fourier degree <= 1
 11. Fast transform       an O(N 2^N) division-free biased butterfly agrees with
                          the O(N 4^N) definition
"""

from __future__ import annotations

import random
from fractions import Fraction
from itertools import product
from typing import Callable, Dict, List, Sequence, Tuple

Rat = Fraction
Config = int      # bitmask: bit v set  <=>  site v open
Freq = int        # bitmask: bit v set  <=>  v belongs to the frequency set S


# --------------------------------------------------------------------------- #
# Basic measure-theoretic objects                                             #
# --------------------------------------------------------------------------- #

def popcount(x: int) -> int:
    """Number of set bits (the cardinality |S| of a frequency)."""
    return bin(x).count("1")


def weight(p: Rat, n: int, eta: Config) -> Rat:
    """Probability w_p(eta) of a single configuration under the product measure."""
    q = 1 - p
    w = Rat(1)
    for v in range(n):
        w *= p if (eta >> v) & 1 else q
    return w


def all_configs(n: int) -> List[Config]:
    """All 2^n configurations."""
    return list(range(1 << n))


def expectation(p: Rat, n: int, f: Sequence[Rat]) -> Rat:
    """E_p[f] where f is given as a table indexed by configuration."""
    return sum(weight(p, n, eta) * f[eta] for eta in all_configs(n))


def psi_site(p: Rat, eta: Config, v: int) -> Rat:
    """Single-site centred character psi_v(eta) = eta_v - p."""
    return (1 - p) if (eta >> v) & 1 else -p


def psi_set(p: Rat, n: int, eta: Config, s: Freq) -> Rat:
    """Character psi_S(eta) = prod_{v in S} psi_v(eta)."""
    out = Rat(1)
    for v in range(n):
        if (s >> v) & 1:
            out *= psi_site(p, eta, v)
    return out


# --------------------------------------------------------------------------- #
# The biased Fourier transform                                                #
# --------------------------------------------------------------------------- #

def fourier_coefficients(p: Rat, n: int, f: Sequence[Rat]) -> List[Rat]:
    """
    Naive transform, straight from the definition:
        fhat(S) = E_p[f psi_S] / (p q)^{|S|}.
    Complexity O(n 4^n).
    """
    q = 1 - p
    pq = p * q
    out: List[Rat] = []
    for s in range(1 << n):
        acc = Rat(0)
        for eta in all_configs(n):
            acc += weight(p, n, eta) * f[eta] * psi_set(p, n, eta, s)
        out.append(acc / pq ** popcount(s))
    return out


def fast_biased_transform(p: Rat, n: int, f: Sequence[Rat]) -> List[Rat]:
    """
    Division-free O(n 2^n) butterfly computing the same coefficients.

    At each coordinate v the entries split into the v-average
    A_v f = p f(.,v=1) + q f(.,v=0)  -- carrying the frequencies omitting v --
    and the v-derivative D_v f = f(.,v=1) - f(.,v=0) -- whose coefficients are,
    by the identity fhat(S) = (D_v f)^(S \\ v), exactly the coefficients of f at
    the frequencies containing v.  The normalising powers (pq)^{|S|} cancel
    automatically, so no division ever occurs.
    """
    q = 1 - p
    F: List[Rat] = list(f)
    for v in range(n):
        bit = 1 << v
        for eta in range(1 << n):
            if eta & bit:
                continue
            a = F[eta]           # site v closed
            b = F[eta | bit]     # site v open
            F[eta] = p * b + q * a
            F[eta | bit] = b - a
    return F


def level_energies(p: Rat, n: int, fhat: Sequence[Rat]) -> List[Rat]:
    """E_S(f) = (pq)^{|S|} fhat(S)^2 for every frequency S."""
    pq = p * (1 - p)
    return [pq ** popcount(s) * fhat[s] ** 2 for s in range(1 << n)]


# --------------------------------------------------------------------------- #
# Discrete calculus on the cube                                               #
# --------------------------------------------------------------------------- #

def flip_to(eta: Config, v: int, open_: bool) -> Config:
    """The configuration eta with site v reset to open/closed."""
    return (eta | (1 << v)) if open_ else (eta & ~(1 << v))


def derivative(n: int, f: Sequence[Rat], v: int) -> List[Rat]:
    """D_v f (eta) = f(eta with v open) - f(eta with v closed)."""
    return [f[flip_to(eta, v, True)] - f[flip_to(eta, v, False)]
            for eta in all_configs(n)]


def variance(p: Rat, n: int, f: Sequence[Rat]) -> Rat:
    """Var_p(f) = E_p[f^2] - (E_p[f])^2."""
    sq = [x * x for x in f]
    m = expectation(p, n, f)
    return expectation(p, n, sq) - m * m


# --------------------------------------------------------------------------- #
# Events                                                                      #
# --------------------------------------------------------------------------- #

def sign_indicator(n: int, member: Callable[[Config], bool]) -> List[Rat]:
    """The +/-1 indicator g_A of the event A described by `member`."""
    return [Rat(1) if member(eta) else Rat(-1) for eta in all_configs(n)]


def probability(p: Rat, n: int, member: Callable[[Config], bool]) -> Rat:
    """P_p(A)."""
    return sum(weight(p, n, eta) for eta in all_configs(n) if member(eta))


def influence(p: Rat, n: int, member: Callable[[Config], bool], v: int) -> Rat:
    """
    I_v = P_p(site v is pivotal): the probability that opening v puts the
    configuration in A while closing it does not.
    """
    tot = Rat(0)
    for eta in all_configs(n):
        if member(flip_to(eta, v, True)) and not member(flip_to(eta, v, False)):
            tot += weight(p, n, eta)
    return tot


def is_increasing(n: int, member: Callable[[Config], bool]) -> bool:
    """Brute-force monotonicity check: opening a site never destroys the event."""
    for eta in all_configs(n):
        if not member(eta):
            continue
        for v in range(n):
            if not member(eta | (1 << v)):
                return False
    return True


# Concrete increasing events -------------------------------------------------

def dictator(v: int) -> Callable[[Config], bool]:
    return lambda eta: bool((eta >> v) & 1)


def majority(n: int) -> Callable[[Config], bool]:
    return lambda eta: 2 * popcount(eta) > n


def and_all(n: int) -> Callable[[Config], bool]:
    return lambda eta: popcount(eta) == n


def or_all(n: int) -> Callable[[Config], bool]:
    return lambda eta: eta != 0


def tribes(groups: Sequence[Sequence[int]]) -> Callable[[Config], bool]:
    """OR of ANDs: at least one group entirely open."""
    masks = [sum(1 << v for v in g) for g in groups]
    return lambda eta: any((eta & m) == m for m in masks)


def grid_row_crossing(n: int) -> Callable[[Config], bool]:
    """
    Horizontal crossing of the n x n grid in the simplest sense: some row is
    entirely open.  Site (i, j) is bit i*n + j.  This event is increasing.
    """
    masks = [sum(1 << (i * n + j) for j in range(n)) for i in range(n)]
    return lambda eta: any((eta & m) == m for m in masks)


# --------------------------------------------------------------------------- #
# Verification routines                                                       #
# --------------------------------------------------------------------------- #

def check(label: str, lhs: Rat, rhs: Rat) -> None:
    status = "OK " if lhs == rhs else "FAIL"
    print(f"    [{status}] {label:<52} {str(lhs):>18} == {str(rhs):>18}")
    assert lhs == rhs, f"{label}: {lhs} != {rhs}"


def verify_orthogonality(p: Rat, n: int) -> None:
    """E_p[psi_S psi_T] = [S=T] (pq)^{|S|}."""
    pq = p * (1 - p)
    bad = 0
    for s in range(1 << n):
        for t in range(1 << n):
            val = sum(weight(p, n, eta) * psi_set(p, n, eta, s) * psi_set(p, n, eta, t)
                      for eta in all_configs(n))
            expect = pq ** popcount(s) if s == t else Rat(0)
            if val != expect:
                bad += 1
    print(f"    [{'OK ' if bad == 0 else 'FAIL'}] orthogonality over all "
          f"{(1 << n) ** 2} pairs of frequencies")
    assert bad == 0


def verify_completeness(p: Rat, n: int, f: Sequence[Rat]) -> None:
    """f(eta) = sum_S fhat(S) psi_S(eta)."""
    fhat = fourier_coefficients(p, n, f)
    for eta in all_configs(n):
        recon = sum(fhat[s] * psi_set(p, n, eta, s) for s in range(1 << n))
        assert recon == f[eta], f"reconstruction failed at {eta}"
    print(f"    [OK ] completeness: f = sum_S fhat(S) psi_S at all {1 << n} points")


def verify_parseval(p: Rat, n: int, f: Sequence[Rat], g: Sequence[Rat]) -> None:
    pq = p * (1 - p)
    fhat = fourier_coefficients(p, n, f)
    ghat = fourier_coefficients(p, n, g)
    lhs = expectation(p, n, [f[e] * g[e] for e in all_configs(n)])
    rhs = sum(pq ** popcount(s) * fhat[s] * ghat[s] for s in range(1 << n))
    check("Parseval  E[fg] = sum_S (pq)^|S| fhat ghat", lhs, rhs)


def verify_site_energy_and_efron_stein(p: Rat, n: int, f: Sequence[Rat]) -> None:
    """
    sum_{S ni v} E_S(f) = pq E[(D_v f)^2]   and the exact Efron-Stein defect.
    """
    pq = p * (1 - p)
    fhat = fourier_coefficients(p, n, f)
    en = level_energies(p, n, fhat)

    for v in range(n):
        lhs = sum(en[s] for s in range(1 << n) if (s >> v) & 1)
        d = derivative(n, f, v)
        rhs = pq * expectation(p, n, [x * x for x in d])
        check(f"site energy identity at site {v}", lhs, rhs)

    total_deriv = sum(expectation(p, n, [x * x for x in derivative(n, f, v)])
                      for v in range(n))
    defect_lhs = pq * total_deriv - variance(p, n, f)
    defect_rhs = sum((Rat(popcount(s)) - 1) * en[s]
                     for s in range(1 << n) if s != 0)
    check("Efron-Stein defect identity", defect_lhs, defect_rhs)
    assert defect_lhs >= 0, "Poincare inequality violated"
    print(f"    [OK ] Poincare inequality Var <= pq sum_v E[(D_v f)^2] "
          f"(slack {defect_lhs})")


def analyse_event(name: str, p: Rat, n: int,
                  member: Callable[[Config], bool]) -> Dict[str, Rat]:
    """Full spectral analysis of one increasing event, verifying every identity."""
    q = 1 - p
    pq = p * q
    print(f"\n  --- {name}   (N = {n} sites, p = {p}) ---")
    assert is_increasing(n, member), "event is not increasing"

    g = sign_indicator(n, member)
    ghat = fourier_coefficients(p, n, g)
    ghat_fast = fast_biased_transform(p, n, g)
    check("fast transform agrees with the definition",
          Rat(int(list(ghat) == list(ghat_fast))), Rat(1))

    en = level_energies(p, n, ghat)
    P = probability(p, n, member)
    infl = [influence(p, n, member, v) for v in range(n)]

    print(f"    P = {P},   influences = {[str(i) for i in infl]}")

    # 1. Plancherel for Boolean functions
    check("Plancherel   sum_S E_S = 1", sum(en), Rat(1))

    # 2. degree-0 and degree-1 coefficients
    check("ghat(empty) = 2P - 1", ghat[0], 2 * P - 1)
    for v in range(n):
        check(f"Margulis-Russo  ghat({{{v}}}) = 2 I_{v}", ghat[1 << v], 2 * infl[v])

    # 3. exact energy decomposition (the l^2 influence bound with its defect)
    high = sum(en[s] for s in range(1 << n) if popcount(s) >= 2)
    lhs = 4 * P * (1 - P)
    rhs = 4 * pq * sum(i * i for i in infl) + high
    check("energy decomposition 4P(1-P) = 4pq sum I_v^2 + R", lhs, rhs)
    l2_defect = high / 4
    assert pq * sum(i * i for i in infl) + l2_defect == P * (1 - P)
    print(f"    l^2 bound     pq sum I_v^2 = {pq * sum(i * i for i in infl)}"
          f"  <=  P(1-P) = {P * (1 - P)}   (defect {l2_defect})")

    # 4. exact Poincare defect
    poin_lhs = 4 * pq * sum(infl) - 4 * P * (1 - P)
    poin_rhs = sum((Rat(popcount(s)) - 1) * en[s] for s in range(1 << n) if s != 0)
    check("Poincare defect 4pq sum I_v - 4P(1-P)", poin_lhs, poin_rhs)
    print(f"    Poincare      P(1-P) = {P * (1 - P)}"
          f"  <=  pq sum I_v = {pq * sum(infl)}   (defect {poin_rhs / 4})")

    # 5. total influence in Fourier form
    check("4pq sum I_v = sum_S |S| E_S",
          4 * pq * sum(infl),
          sum(Rat(popcount(s)) * en[s] for s in range(1 << n)))

    # 6. the unified equality criterion
    degree_le_one = all(ghat[s] == 0 for s in range(1 << n) if popcount(s) >= 2)
    l2_tight = (pq * sum(i * i for i in infl) == P * (1 - P))
    poin_tight = (P * (1 - P) == pq * sum(infl))
    check("l^2 tight  <=>  degree <= 1",
          Rat(int(l2_tight)), Rat(int(degree_le_one)))
    check("Poincare tight  <=>  degree <= 1",
          Rat(int(poin_tight)), Rat(int(degree_le_one)))
    print(f"    degree <= 1 : {degree_le_one}   -> both inequalities "
          f"{'are equalities' if degree_le_one else 'are strict'}")

    # spectral profile by degree
    profile = {}
    for s in range(1 << n):
        profile[popcount(s)] = profile.get(popcount(s), Rat(0)) + en[s]
    print("    spectral profile by degree: "
          + ", ".join(f"{k}: {v}" for k, v in sorted(profile.items())))

    return {"P": P, "l2_defect": l2_defect, "poincare_defect": poin_rhs / 4}


# --------------------------------------------------------------------------- #
# Main                                                                        #
# --------------------------------------------------------------------------- #

def main() -> None:
    print("=" * 78)
    print("  THE COMPLETE p-BIASED FOURIER EXPANSION ON THE DISCRETE CUBE")
    print("  exact rational verification of every identity")
    print("=" * 78)

    # ---- Part 1: the basis itself ----------------------------------------- #
    print("\n[1] Orthogonality and completeness of the biased characters")
    for p in (Rat(1, 2), Rat(1, 3), Rat(2, 5)):
        print(f"\n  p = {p}")
        verify_orthogonality(p, 3)
        rng = random.Random(20260807)
        f = [Rat(rng.randint(-9, 9), rng.randint(1, 5)) for _ in range(1 << 3)]
        verify_completeness(p, 3, f)
        g = [Rat(rng.randint(-9, 9), rng.randint(1, 5)) for _ in range(1 << 3)]
        verify_parseval(p, 3, f, g)

    # ---- Part 2: Efron-Stein for arbitrary (non-Boolean) functions --------- #
    print("\n[2] The exact Efron-Stein / Poincare defect for arbitrary functions")
    rng = random.Random(11235)
    for p in (Rat(1, 2), Rat(1, 4)):
        print(f"\n  random rational function on 3 sites, p = {p}")
        f = [Rat(rng.randint(-6, 6), rng.randint(1, 4)) for _ in range(1 << 3)]
        verify_site_energy_and_efron_stein(p, 3, f)

    # ---- Part 3: increasing events ---------------------------------------- #
    print("\n[3] Increasing events: both influence inequalities and their defects")

    summary: List[Tuple[str, Rat, Rat]] = []

    r = analyse_event("Dictatorship on site 0", Rat(1, 3), 3, dictator(0))
    summary.append(("Dictatorship (p=1/3)", r["l2_defect"], r["poincare_defect"]))

    r = analyse_event("Majority of 3", Rat(1, 2), 3, majority(3))
    summary.append(("Majority-3 (p=1/2)", r["l2_defect"], r["poincare_defect"]))

    r = analyse_event("AND of 3", Rat(1, 2), 3, and_all(3))
    summary.append(("AND-3 (p=1/2)", r["l2_defect"], r["poincare_defect"]))

    r = analyse_event("OR of 3", Rat(1, 2), 3, or_all(3))
    summary.append(("OR-3 (p=1/2)", r["l2_defect"], r["poincare_defect"]))

    r = analyse_event("Tribes: (0 AND 1) OR (2 AND 3)", Rat(1, 2), 4,
                      tribes([[0, 1], [2, 3]]))
    summary.append(("Tribes 2x2 (p=1/2)", r["l2_defect"], r["poincare_defect"]))

    r = analyse_event("2x2 grid: some row entirely open", Rat(1, 2), 4,
                      grid_row_crossing(2))
    summary.append(("2x2 crossing (p=1/2)", r["l2_defect"], r["poincare_defect"]))

    r = analyse_event("Majority of 5", Rat(1, 2), 5, majority(5))
    summary.append(("Majority-5 (p=1/2)", r["l2_defect"], r["poincare_defect"]))

    # ---- Part 4: the density sweep ---------------------------------------- #
    print("\n[4] Density sweep: how the two defects move with p (Majority of 3)")
    print(f"    {'p':>7} {'P':>12} {'P(1-P)':>14} {'l^2 defect':>14} "
          f"{'Poincare defect':>18}")
    for num in range(1, 10):
        p = Rat(num, 10)
        member = majority(3)
        g = sign_indicator(3, member)
        ghat = fourier_coefficients(p, 3, g)
        en = level_energies(p, 3, ghat)
        P = probability(p, 3, member)
        l2d = sum(en[s] for s in range(8) if popcount(s) >= 2) / 4
        pod = sum((Rat(popcount(s)) - 1) * en[s] for s in range(1, 8)) / 4
        print(f"    {str(p):>7} {str(P):>12} {str(P * (1 - P)):>14} "
              f"{str(l2d):>14} {str(pod):>18}")

    # ---- Part 5: summary --------------------------------------------------- #
    print("\n[5] Summary of exact defects")
    print(f"    {'event':<28} {'l^2 defect':>16} {'Poincare defect':>18} "
          f"{'ratio':>10}")
    for name, l2d, pod in summary:
        ratio = "inf" if l2d == 0 and pod > 0 else (
            "0/0" if l2d == 0 else str(pod / l2d))
        print(f"    {name:<28} {str(l2d):>16} {str(pod):>18} {ratio:>10}")
    print("\n    Note: the Poincare defect always dominates the l^2 defect,")
    print("    since 1[|S| >= 2] <= |S| - 1 for every nonempty S; they coincide")
    print("    exactly when all high-degree energy sits at degree 2.")

    print("\n" + "=" * 78)
    print("  All identities verified exactly in rational arithmetic.")
    print("=" * 78)


if __name__ == "__main__":
    main()
