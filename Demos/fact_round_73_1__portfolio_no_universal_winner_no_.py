"""
Portfolio scheduling over an invisible channel: exact numerical demonstrations.

Everything below is computed in exact rational arithmetic (``fractions.Fraction``),
so every printed number is the exact value of the corresponding theorem, not a
floating-point approximation.

Contents
--------
1.  Core objects: expectation, oracle, best static member, fiber table, dial value.
2.  The exact model of the measured five-member factoring cell: winner shares,
    static regret 3.117, the null dial, the strictly-worse learned rule, the
    probe threshold, and the forced 0.42 tail mass.
3.  The dial-edge criterion: a portfolio where routing helps and one where it
    cannot.
4.  Sharpness of the stability constant 2: the anti-diagonal family with gap
    2n/(n+1) under 1-invisibility.
5.  Null-dial diagnostics: fiberwise regret, the fiberwise-champion criterion,
    two-member swap masses, and a swap hidden by a third member.
6.  Irredundance does not bound pairwise structure.
7.  Median blindness and the reverse Markov tail bound.
8.  Elimination discipline: pointwise-safe versus mean-unsafe.
9.  The number-theoretic channel: powersmoothness, the invisible 21-bit pair,
    and the capped p-1 probe.
10. Threshold schedules under decreasing differences.

Run with:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction
from math import gcd
from typing import Callable, Dict, Hashable, List, Sequence, Tuple

Q = Fraction

# ---------------------------------------------------------------------------
# 1.  Core objects
# ---------------------------------------------------------------------------

Instance = Hashable
Member = Hashable
Obs = Hashable


def expectation(weights: Dict[Instance, Q], f: Callable[[Instance], Q]) -> Q:
    """E[f] = sum_w w(omega) f(omega)."""
    return sum((w * f(om) for om, w in weights.items()), Q(0))


def oracle_cost(cost: Dict[Instance, Dict[Member, Q]], omega: Instance) -> Q:
    """min_s c(omega, s): the member chosen with hindsight."""
    return min(cost[omega].values())


def expected_oracle(weights: Dict[Instance, Q],
                    cost: Dict[Instance, Dict[Member, Q]]) -> Q:
    return expectation(weights, lambda om: oracle_cost(cost, om))


def member_mean(weights: Dict[Instance, Q],
                cost: Dict[Instance, Dict[Member, Q]], s: Member) -> Q:
    return expectation(weights, lambda om: cost[om][s])


def best_constant(weights: Dict[Instance, Q],
                  cost: Dict[Instance, Dict[Member, Q]],
                  members: Sequence[Member]) -> Q:
    """B = min_s E[c(., s)], the do-nothing baseline."""
    return min(member_mean(weights, cost, s) for s in members)


def fiber_mass(weights: Dict[Instance, Q],
               obs: Callable[[Instance], Obs]) -> Dict[Obs, Q]:
    mu: Dict[Obs, Q] = {}
    for om, w in weights.items():
        mu[obs(om)] = mu.get(obs(om), Q(0)) + w
    return mu


def fiber_table(weights: Dict[Instance, Q],
                cost: Dict[Instance, Dict[Member, Q]],
                obs: Callable[[Instance], Obs],
                members: Sequence[Member]) -> Dict[Obs, Dict[Member, Q]]:
    """V(o, s) = sum over the fiber over o of w(omega) c(omega, s)."""
    table: Dict[Obs, Dict[Member, Q]] = {}
    for om, w in weights.items():
        row = table.setdefault(obs(om), {s: Q(0) for s in members})
        for s in members:
            row[s] += w * cost[om][s]
    return table


def dial_value(weights: Dict[Instance, Q],
               cost: Dict[Instance, Dict[Member, Q]],
               obs: Callable[[Instance], Obs],
               members: Sequence[Member]) -> Q:
    """D(phi) = sum_o min_s V(o, s): the value of the best rule reading `obs`."""
    table = fiber_table(weights, cost, obs, members)
    return sum((min(row.values()) for row in table.values()), Q(0))


def optimal_rule(weights: Dict[Instance, Q],
                 cost: Dict[Instance, Dict[Member, Q]],
                 obs: Callable[[Instance], Obs],
                 members: Sequence[Member]) -> Dict[Obs, Member]:
    """An explicit rule attaining the dial value (least fiberwise minimiser)."""
    table = fiber_table(weights, cost, obs, members)
    return {o: min(members, key=lambda s: (row[s], members.index(s)))
            for o, row in table.items()}


def policy_cost(weights: Dict[Instance, Q],
                cost: Dict[Instance, Dict[Member, Q]],
                obs: Callable[[Instance], Obs],
                rule: Dict[Obs, Member]) -> Q:
    return expectation(weights, lambda om: cost[om][rule[obs(om)]])


def fiberwise_regret(weights: Dict[Instance, Q],
                     cost: Dict[Instance, Dict[Member, Q]],
                     obs: Callable[[Instance], Obs],
                     members: Sequence[Member], s: Member) -> Q:
    table = fiber_table(weights, cost, obs, members)
    return sum((row[s] - min(row.values()) for row in table.values()), Q(0))


def swap_mass(f: Dict[Obs, Q], g: Dict[Obs, Q]) -> Q:
    """Total excess of f over g on the fibers where f loses."""
    return sum((max(f[o] - g[o], Q(0)) for o in f), Q(0))


def show(label: str, value: Q, width: int = 46) -> None:
    print(f"  {label:<{width}} {str(value):>18}  = {float(value):.6f}")


def rule_str(rule: Dict[Obs, Member]) -> str:
    return "{" + ", ".join(f"{o} -> {s}" for o, s in sorted(rule.items(),
                                                            key=str)) + "}"


# ---------------------------------------------------------------------------
# 2.  The measured five-member factoring cell, exactly
# ---------------------------------------------------------------------------

MEMBERS_560: List[str] = ["rho", "p-1@256", "p-1@1024", "Fermat", "TD"]
SHARES_560: List[Q] = [Q(58, 100), Q(345, 1000), Q(45, 1000), Q(28, 1000), Q(1, 500)]
PENALTY_560: Q = Q(1179, 140)


def build_exp560() -> Tuple[Dict[Instance, Q], Dict[Instance, Dict[Member, Q]],
                            Callable[[Instance], Obs]]:
    """Instances are (hidden smoothness class, visible bit); the bit is a fair coin.

    A member costs 1 on the class it owns and the common penalty elsewhere.
    """
    weights: Dict[Instance, Q] = {}
    cost: Dict[Instance, Dict[Member, Q]] = {}
    for c_idx, share in enumerate(SHARES_560):
        for bit in (0, 1):
            om = (c_idx, bit)
            weights[om] = share / 2
            cost[om] = {s: (Q(1) if k == c_idx else PENALTY_560)
                        for k, s in enumerate(MEMBERS_560)}
    return weights, cost, (lambda om: om[1])


def demo_exp560() -> None:
    print("=" * 78)
    print("2.  THE MEASURED CELL: five factoring methods, one invisible channel")
    print("=" * 78)
    weights, cost, obs = build_exp560()

    print("\n  Oracle winner shares (member is uniquely cheapest):")
    for k, s in enumerate(MEMBERS_560):
        share = sum((w for om, w in weights.items()
                     if cost[om][s] == oracle_cost(cost, om)), Q(0))
        print(f"    {s:<10} {str(share):>10}  = {float(share):.3f}")

    b = best_constant(weights, cost, MEMBERS_560)
    orc = expected_oracle(weights, cost)
    d = dial_value(weights, cost, obs, MEMBERS_560)
    print()
    show("E[oracle]", orc)
    show("dial value D(visible bit)", d)
    show("best static member B", b)
    show("dial gain  B - D  (measured Delta = 0.000)", b - d)
    show("static regret R = B - E[oracle]", b - orc)

    print("\n  Invisibility check: conditional mean cost per fiber")
    mu = fiber_mass(weights, obs)
    table = fiber_table(weights, cost, obs, MEMBERS_560)
    for s in MEMBERS_560:
        conds = [table[o][s] / mu[o] for o in sorted(mu)]
        flat = "identical across fibers" if conds[0] == conds[1] else "DIFFERENT"
        print(f"    {s:<10} " + "  ".join(f"{float(c):.6f}" for c in conds)
              + f"   ({flat})")

    print("\n  The 'learned' two-armed rule (rho on bit 0, p-1@256 on bit 1):")
    ml = {0: "rho", 1: "p-1@256"}
    ml_cost = policy_cost(weights, cost, obs, ml)
    show("E[learned rule]", ml_cost)
    print(f"    strictly worse than doing nothing: {ml_cost > b}"
          f"   (excess {float(ml_cost - b):.6f})")

    print("\n  Optimal rule found by exhaustive fiberwise minimisation:")
    print("   ", rule_str(optimal_rule(weights, cost, obs, MEMBERS_560)),
          "-- the do-nothing dial")

    print("\n  Paid probe economics (probe reveals the hidden class):")
    for kappa in (Q(1), Q(3), Q(3117, 1000), Q(4)):
        pays = orc + kappa < b
        print(f"    price {float(kappa):.3f}: worth buying? {pays}")

    print("\n  Reverse Markov: mean 4.117, cap 1179/140, threshold t = 1")
    forced = (b - 1) / (PENALTY_560 - 1)
    show("forced tail mass on the losing set", forced)
    actual = sum((w for om, w in weights.items() if cost[om]["rho"] > 1), Q(0))
    show("actual mass where rho loses", actual)


# ---------------------------------------------------------------------------
# 3.  The dial-edge criterion
# ---------------------------------------------------------------------------

def dial_edge_criterion(weights: Dict[Instance, Q],
                        cost: Dict[Instance, Dict[Member, Q]],
                        obs: Callable[[Instance], Obs],
                        members: Sequence[Member]) -> bool:
    """True iff every member is strictly beaten on at least one fiber."""
    table = fiber_table(weights, cost, obs, members)
    return all(any(min(row.values()) < row[s] for row in table.values())
               for s in members)


def demo_dial_edge() -> None:
    print("\n" + "=" * 78)
    print("3.  DIAL-EDGE CRITERION: routing helps iff every member loses a fiber")
    print("=" * 78)

    # (a) genuine edge: two members trade places across two fibers.
    w_a = {0: Q(1, 2), 1: Q(1, 2)}
    c_a = {0: {"A": Q(1), "B": Q(4)}, 1: {"A": Q(4), "B": Q(1)}}
    # (b) no edge: member A is fiberwise unbeatable although B swings wildly.
    w_b = {0: Q(1, 2), 1: Q(1, 2)}
    c_b = {0: {"A": Q(1), "B": Q(2)}, 1: {"A": Q(1), "B": Q(9)}}

    for name, w, c in (("(a) members trade places", w_a, c_a),
                       ("(b) A is a fiberwise champion", w_b, c_b)):
        members = ["A", "B"]
        ident = (lambda om: om)
        b = best_constant(w, c, members)
        d = dial_value(w, c, ident, members)
        crit = dial_edge_criterion(w, c, ident, members)
        print(f"\n  {name}")
        show("best static B", b)
        show("dial value D", d)
        show("gain B - D", b - d)
        print(f"    criterion 'every member beaten somewhere': {crit}"
              f"   (matches D < B: {d < b})")


# ---------------------------------------------------------------------------
# 4.  Sharpness of the stability constant 2
# ---------------------------------------------------------------------------

def spread_portfolio(n: int) -> Tuple[Dict[Instance, Q],
                                      Dict[Instance, Dict[Member, Q]],
                                      List[Member]]:
    """n+1 instances, n+1 members, cost -1 on the diagonal and +1 off it."""
    members = list(range(n + 1))
    weights = {i: Q(1, n + 1) for i in members}
    cost = {i: {s: (Q(-1) if i == s else Q(1)) for s in members} for i in members}
    return weights, cost, members


def eps_invisibility(weights: Dict[Instance, Q],
                     cost: Dict[Instance, Dict[Member, Q]],
                     obs: Callable[[Instance], Obs],
                     members: Sequence[Member],
                     profile: Dict[Member, Q]) -> Q:
    """Smallest eps for which |V(o,s) - mu(o) m(s)| <= eps mu(o) holds."""
    mu = fiber_mass(weights, obs)
    table = fiber_table(weights, cost, obs, members)
    return max((abs(table[o][s] - mu[o] * profile[s]) / mu[o]
                for o in mu for s in members), default=Q(0))


def demo_stability() -> None:
    print("\n" + "=" * 78)
    print("4.  STABILITY:  eps-invisibility forces gain <= 2 eps, and 2 is sharp")
    print("=" * 78)
    print("\n   n    eps    best static B      dial D     gap = 2n/(n+1)   bound 2eps")
    for n in (1, 2, 3, 5, 10, 50, 200):
        w, c, members = spread_portfolio(n)
        ident = (lambda om: om)
        eps = eps_invisibility(w, c, ident, members, {s: Q(0) for s in members})
        b = best_constant(w, c, members)
        d = dial_value(w, c, ident, members)
        gap = b - d
        assert gap == Q(2 * n, n + 1)
        assert gap <= 2 * eps
        print(f"  {n:>3}  {float(eps):>5.2f}  {float(b):>13.6f}  {float(d):>10.6f}"
              f"  {float(gap):>14.6f}  {float(2 * eps):>10.2f}")
    print("\n  Gap -> 2 as n -> infinity: the constant 2 cannot be lowered.")

    print("\n  The naive converse fails: identical members, zero gain,")
    print("  yet not eps-invisible for any eps < 1.")
    w2 = {0: Q(1, 2), 1: Q(1, 2)}
    c2 = {0: {"A": Q(0), "B": Q(0)}, 1: {"A": Q(2), "B": Q(2)}}
    ident = (lambda om: om)
    b2 = best_constant(w2, c2, ["A", "B"])
    d2 = dial_value(w2, c2, ident, ["A", "B"])
    show("gap on the finest observation", b2 - d2)
    best_eps = min(eps_invisibility(w2, c2, ident, ["A", "B"],
                                    {"A": m, "B": m})
                   for m in (Q(k, 4) for k in range(0, 17)))
    show("smallest achievable eps over profiles m", best_eps)


# ---------------------------------------------------------------------------
# 5.  Null-dial diagnostics
# ---------------------------------------------------------------------------

def demo_null_dial() -> None:
    print("\n" + "=" * 78)
    print("5.  WHAT A NULL DIAL CERTIFIES: a fiberwise champion, nothing more")
    print("=" * 78)

    # Three members on three singleton fibers; member C is optimal everywhere,
    # while A and B swap with positive mass.
    members = ["A", "B", "C"]
    weights = {0: Q(1, 3), 1: Q(1, 3), 2: Q(1, 3)}
    cost = {
        0: {"A": Q(0), "B": Q(3), "C": Q(0)},
        1: {"A": Q(3), "B": Q(0), "C": Q(0)},
        2: {"A": Q(3), "B": Q(3), "C": Q(0)},
    }
    ident = (lambda om: om)
    b = best_constant(weights, cost, members)
    d = dial_value(weights, cost, ident, members)
    show("best static B", b)
    show("dial value D", d)
    show("gain B - D", b - d)
    print("\n  Fiberwise regret of each member (gain = the smallest one):")
    for s in members:
        show(f"  FR({s})", fiberwise_regret(weights, cost, ident, members, s))
    table = fiber_table(weights, cost, ident, members)
    champs = [s for s in members
              if all(table[o][s] == min(table[o].values()) for o in table)]
    print(f"\n  Fiberwise champions: {champs}  "
          f"(gap is zero iff this list is nonempty)")

    f = {o: table[o]["A"] for o in table}
    g = {o: table[o]["B"] for o in table}
    print("\n  Yet members A and B swap with positive mass in both directions:")
    show("  swap mass A over B", swap_mass(f, g))
    show("  swap mass B over A", swap_mass(g, f))
    print("  For the PAIR {A, B} alone the gain would be the minimum of these:")
    pair_members = ["A", "B"]
    show("  pairwise gain",
         best_constant(weights, cost, pair_members)
         - dial_value(weights, cost, ident, pair_members))


# ---------------------------------------------------------------------------
# 6.  Irredundance does not bound pairwise structure
# ---------------------------------------------------------------------------

def irredundant_family(e: Q) -> Tuple[Dict[Instance, Q],
                                      Dict[Instance, Dict[Member, Q]],
                                      List[Member]]:
    members = [0, 1, 2]
    weights = {0: Q(1, 3), 1: Q(1, 3), 2: Q(1, 3)}
    rows = [[Q(0), Q(10), e], [Q(10), Q(0), e], [Q(10), Q(10), Q(0)]]
    cost = {o: {s: rows[o][s] for s in members} for o in members}
    return weights, cost, members


def is_irredundant(weights: Dict[Instance, Q],
                   cost: Dict[Instance, Dict[Member, Q]],
                   obs: Callable[[Instance], Obs],
                   members: Sequence[Member]) -> bool:
    table = fiber_table(weights, cost, obs, members)
    return all(any(table[o][t] < table[o][s] for o in table)
               for s in members for t in members if s != t)


def demo_irredundant() -> None:
    print("\n" + "=" * 78)
    print("6.  IRREDUNDANCE DOES NOT BOUND PAIRWISE STRUCTURE")
    print("=" * 78)
    print("\n      e      irredundant   gain = 2e/3    swap mass    ratio swap/gain")
    ident = (lambda om: om)
    for e in (Q(1), Q(1, 10), Q(1, 100), Q(1, 1000)):
        w, c, members = irredundant_family(e)
        gap = best_constant(w, c, members) - dial_value(w, c, ident, members)
        table = fiber_table(w, c, ident, members)
        f = {o: table[o][0] for o in table}
        g = {o: table[o][1] for o in table}
        sw = min(swap_mass(f, g), swap_mass(g, f))
        assert gap == 2 * e / 3 and sw == Q(10, 3)
        print(f"  {float(e):>7.4f}   {str(is_irredundant(w, c, ident, members)):<11}"
              f"  {float(gap):>10.6f}  {float(sw):>11.6f}   {float(sw / gap):>12.1f}")
    print("\n  The ratio is unbounded: no constant, and no function of the number")
    print("  of members, bounds pairwise swaps by the portfolio-level gain.")


# ---------------------------------------------------------------------------
# 7.  Median blindness and the reverse Markov bound
# ---------------------------------------------------------------------------

def demo_median_and_tail() -> None:
    print("\n" + "=" * 78)
    print("7.  MEDIAN BLINDNESS AND THE FORCED TAIL")
    print("=" * 78)
    print("\n       M    median ratio   mean ratio of the OPTIMAL static member")
    for M in (Q(0), Q(1), Q(10), Q(100), Q(1000)):
        weights = {0: Q(3, 4), 1: Q(1, 4)}
        cost = {0: {"A": Q(1), "B": 8 * M + 8},
                1: {"A": 4 * M + 4, "B": Q(1)}}
        members = ["A", "B"]
        means = {s: member_mean(weights, cost, s) for s in members}
        best = min(members, key=lambda s: means[s])
        tie_mass = sum((w for om, w in weights.items()
                        if cost[om][best] == oracle_cost(cost, om)), Q(0))
        median_ratio = Q(1) if tie_mass >= Q(1, 2) else None
        mean_ratio = expectation(weights,
                                 lambda om: cost[om][best] / oracle_cost(cost, om))
        assert mean_ratio > M and median_ratio == 1
        print(f"  {float(M):>7.1f}   {str(median_ratio):>12}"
              f"   {float(mean_ratio):>12.4f}   (tie mass {float(tie_mass):.2f})")
    print("\n  Median regret ratio 1 is compatible with arbitrarily large mean.")

    print("\n  Reverse Markov bound  Pr[X > t] >= (E[X] - t) / (K - t):")
    print("       E[X]      K       t    forced tail mass")
    for ex, K, t in ((Q(4117, 1000), Q(1179, 140), Q(1)),
                     (Q(2), Q(5), Q(1)),
                     (Q(3), Q(4), Q(2))):
        show_val = (ex - t) / (K - t)
        print(f"   {float(ex):>8.4f} {float(K):>7.4f} {float(t):>6.2f}"
              f"    {float(show_val):>10.6f}")


# ---------------------------------------------------------------------------
# 8.  Elimination discipline
# ---------------------------------------------------------------------------

def demo_elimination() -> None:
    print("\n" + "=" * 78)
    print("8.  ELIMINATION: pointwise dominance safe, mean comparison unsafe")
    print("=" * 78)

    weights = {0: Q(3, 4), 1: Q(1, 4)}
    cost = {0: {"A": Q(1), "B": Q(5)}, 1: {"A": Q(5), "B": Q(1)}}
    members = ["A", "B"]
    show("E[cost of A]", member_mean(weights, cost, "A"))
    show("E[cost of B]  (twice as expensive)", member_mean(weights, cost, "B"))
    show("E[oracle] with both members", expected_oracle(weights, cost))
    sub = {om: {"A": cost[om]["A"]} for om in cost}
    show("E[oracle] after deleting B", expected_oracle(weights, sub))
    print("  Deleting the mean-worse member DOUBLES the oracle cost.\n")

    print("  Stochastic dominance implies a mean inequality; the converse fails:")
    w2 = {0: Q(1, 2), 1: Q(1, 2)}
    X = {0: 0, 1: 10}
    Y = {0: 6, 1: 6}
    ex = expectation(w2, lambda om: Q(X[om]))
    ey = expectation(w2, lambda om: Q(Y[om]))
    show("  E[X]", ex)
    show("  E[Y]", ey)
    for t in (5, 6, 9):
        px = sum((w for om, w in w2.items() if X[om] > t), Q(0))
        py = sum((w for om, w in w2.items() if Y[om] > t), Q(0))
        print(f"    Pr[X > {t:>2}] = {str(px):>4}   Pr[Y > {t:>2}] = {str(py):>4}"
              f"   dominance at this t: {px <= py}")
    layer = sum((sum((w for om, w in w2.items() if X[om] > t), Q(0))
                 for t in range(10)), Q(0))
    show("  layer-cake sum_t Pr[X > t] (equals E[X])", layer)


# ---------------------------------------------------------------------------
# 9.  The number-theoretic channel
# ---------------------------------------------------------------------------

def prime_factorisation(n: int) -> Dict[int, int]:
    factors: Dict[int, int] = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1
    if n > 1:
        factors[n] = factors.get(n, 0) + 1
    return factors


def is_powersmooth(bound: int, n: int) -> bool:
    """Every prime power dividing n is at most `bound`."""
    return all(p ** k <= bound for p, k in prime_factorisation(n).items())


def lcm_up_to(bound: int) -> int:
    L = 1
    for k in range(1, bound + 1):
        L = L * k // gcd(L, k)
    return L


def capped_pminus1_probe(N: int, bound: int, base: int = 2) -> Tuple[int, int]:
    """A p-1 probe capped at `bound`, run incrementally.

    Returns ``(factor, k)`` where ``factor`` is a nontrivial factor of ``N``
    discovered once the accumulated exponent ``lcm(1..k)`` is a multiple of
    ``p-1`` for some prime factor ``p``, and ``k <= bound`` is the stage at which
    it appeared; ``(1, 0)`` if the probe finds nothing within the budget.  By the
    probe guarantee, success is certain (for at least one factor) as soon as some
    ``p-1`` is ``bound``-powersmooth and the other factor's order is not swept at
    the same stage.
    """
    L = 1
    for k in range(2, bound + 1):
        L = L * k // gcd(L, k)
        g = gcd(pow(base, L, N) - 1, N)
        if 1 < g < N:
            return g, k
        if g == N:
            return 1, 0
    return 1, 0


def demo_channel() -> None:
    print("\n" + "=" * 78)
    print("9.  THE HIDDEN CHANNEL IS NUMBER-THEORETIC AND INVISIBLE")
    print("=" * 78)
    pairs = [(1051, 1033), (1319, 1307)]
    print("\n  Two balanced semiprimes with identical visible profile:")
    for p, q in pairs:
        N = p * q
        print(f"    N = {p} * {q} = {N}")
        print(f"      bit length of N = {N.bit_length()},"
              f"  factor bit lengths = {p.bit_length()}, {q.bit_length()}")
        print(f"      p-1 = {p - 1} = "
              + " * ".join(f"{a}^{b}" if b > 1 else f"{a}"
                           for a, b in sorted(prime_factorisation(p - 1).items())))
        print(f"      q-1 = {q - 1} = "
              + " * ".join(f"{a}^{b}" if b > 1 else f"{a}"
                           for a, b in sorted(prime_factorisation(q - 1).items())))
        smooth = is_powersmooth(256, p - 1) and is_powersmooth(256, q - 1)
        print(f"      both 256-powersmooth: {smooth}")
        found, stage = capped_pminus1_probe(N, 256)
        print(f"      capped p-1 probe at B = 256 returns: "
              + (f"factor {found} at stage k = {stage}" if found > 1
                 else "no factor"))
    print(f"\n  Probe exponent L = lcm(1, ..., 25) = {lcm_up_to(25)}"
          f"  (a multiple of 1050 = p-1: {lcm_up_to(25) % 1050 == 0})")
    print("\n  Same visible profile, opposite hidden class, opposite winner:")
    print("  the organising channel is invisible in N.")


# ---------------------------------------------------------------------------
# 10.  Threshold schedules under decreasing differences
# ---------------------------------------------------------------------------

def has_decreasing_differences(table: Dict[Obs, Dict[Member, Q]],
                               obs_order: Sequence[Obs],
                               member_order: Sequence[Member]) -> bool:
    for i, o in enumerate(obs_order):
        for op in obs_order[i:]:
            for j, s in enumerate(member_order):
                for sp in member_order[j:]:
                    if table[op][sp] - table[op][s] > table[o][sp] - table[o][s]:
                        return False
    return True


def least_argmin(row: Dict[Member, Q], member_order: Sequence[Member]) -> Member:
    return min(member_order, key=lambda s: (row[s], member_order.index(s)))


def demo_threshold() -> None:
    print("\n" + "=" * 78)
    print("10.  ORDERED PROBES: decreasing differences give a threshold schedule")
    print("=" * 78)

    # A smoothness-quantile probe: five quantiles, three members.  The later
    # members become relatively cheaper as the quantile rises.
    quantiles = [0, 1, 2, 3, 4]
    members = [0, 1, 2]
    table = {o: {s: Q(10) - Q(2 * o * s) + Q(s) for s in members} for o in quantiles}
    dd = has_decreasing_differences(table, quantiles, members)
    print(f"\n  Decreasing differences hold: {dd}")
    rule = {o: least_argmin(table[o], members) for o in quantiles}
    print("  Optimal schedule by quantile:", rule_str(rule))
    monotone = all(rule[quantiles[i]] <= rule[quantiles[i + 1]]
                   for i in range(len(quantiles) - 1))
    print(f"  Monotone (hence a threshold rule): {monotone}")

    print("\n  Without decreasing differences the optimal schedule need not be"
          " monotone:")
    bad = {0: {0: Q(1), 1: Q(0)}, 1: {0: Q(0), 1: Q(1)}}
    print(f"    decreasing differences: "
          f"{has_decreasing_differences(bad, [0, 1], [0, 1])}")
    bad_rule = {o: least_argmin(bad[o], [0, 1]) for o in (0, 1)}
    print("    optimal schedule:", rule_str(bad_rule),
          "-- decreasing, not monotone")


# ---------------------------------------------------------------------------

def main() -> None:
    print("PORTFOLIO SCHEDULING OVER AN INVISIBLE CHANNEL")
    print("Exact rational demonstrations of the main theorems\n")
    demo_exp560()
    demo_dial_edge()
    demo_stability()
    demo_null_dial()
    demo_irredundant()
    demo_median_and_tail()
    demo_elimination()
    demo_channel()
    demo_threshold()
    print("\n" + "=" * 78)
    print("All demonstrations completed; every assertion above held exactly.")
    print("=" * 78)


if __name__ == "__main__":
    main()
