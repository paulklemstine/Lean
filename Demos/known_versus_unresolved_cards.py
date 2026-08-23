"""Adaptive Betting-System Valuation by Backward Induction on the History Tree.

A betting system is an arbitrary map from finite histories of fair +/-1 tosses
to a rational stake.  Negative stakes switch sides, unbounded stakes are allowed,
and a stake of 0 encodes 'quit', so optional stopping is subsumed.  The expected
net gain over a horizon of n further tosses is defined by

    G(0, h)     = 0
    G(n+1, h)   = [ (stake(h) + G(n, h+H)) + (-stake(h) + G(n, h+T)) ] / 2.

Backward induction over the binary history tree evaluates G exactly in O(2^n)
node visits -- and proves, by the same induction, that G(n, h) = 0 identically:
the two stake terms cancel and both subtrees are worth zero.
"""

from __future__ import annotations

from fractions import Fraction
from typing import Callable, Dict, List, Tuple

History = Tuple[bool, ...]
System = Callable[[History], Fraction]


def expected_gain(stake: System, n: int, history: History = ()) -> Fraction:
    """Exact expected net gain over n further tosses.  Always 0."""
    if n == 0:
        return Fraction(0)
    s: Fraction = stake(history)
    win: Fraction = s + expected_gain(stake, n - 1, history + (True,))
    lose: Fraction = -s + expected_gain(stake, n - 1, history + (False,))
    return (win + lose) / 2


def stopped(stop: Callable[[History], bool], bet: System) -> System:
    """Bet `bet(h)` until the stopping rule fires, then stake nothing."""
    return lambda h: Fraction(0) if stop(h) else bet(h)


def terminal_wealth_law(stake: System, n: int) -> Dict[Fraction, Fraction]:
    """Exact law of the terminal net wealth after n tosses: {wealth: probability}."""
    law: Dict[Fraction, Fraction] = {}

    def walk(h: History, wealth: Fraction, prob: Fraction) -> None:
        if len(h) == n:
            law[wealth] = law.get(wealth, Fraction(0)) + prob
            return
        s: Fraction = stake(h)
        walk(h + (True,), wealth + s, prob / 2)
        walk(h + (False,), wealth - s, prob / 2)

    walk((), Fraction(0), Fraction(1))
    return dict(sorted(law.items()))


DOUBLING: System = lambda h: Fraction(0) if any(h) else Fraction(2 ** len(h))


if __name__ == "__main__":
    systems: Dict[str, System] = {
        "flat 1": lambda h: Fraction(1),
        "doubling": DOUBLING,
        "quit after first win": stopped(lambda h: any(h), lambda h: Fraction(3)),
        "alternate sides": lambda h: Fraction((-1) ** len(h)) * 5,
        "wildly history dependent": lambda h: Fraction(sum(h) * 7 - 3),
    }
    print("Expected net gain of adaptive systems at fair odds:\n")
    for name, sys_fn in systems.items():
        gains: List[Fraction] = [expected_gain(sys_fn, n) for n in range(0, 9)]
        assert all(g == 0 for g in gains)
        print(f"  {name:<26} horizons 0..8 -> all exactly 0")

    print("\nTerminal wealth law of the doubling system:\n")
    print(f"  {'n':>3}  {'law (wealth: probability)':<44}{'mean':>8}{'P[win]':>12}")
    for n in range(1, 9):
        law: Dict[Fraction, Fraction] = terminal_wealth_law(DOUBLING, n)
        mean: Fraction = sum((w * p for w, p in law.items()), Fraction(0))
        p_win: Fraction = sum((p for w, p in law.items() if w > 0), Fraction(0))
        rendered: str = ", ".join(f"{w}: {p}" for w, p in law.items())
        assert mean == 0
        assert p_win == 1 - Fraction(1, 2 ** n)
        print(f"  {n:>3}  {rendered:<44}{str(mean):>8}{float(p_win):>12.6f}")
    print("\n  The rare loss -(2^n - 1) exactly finances the frequent gain +1.")


"""Linear-Time Collision Profile and Exact Variance Evaluation.

The variance of the hit count of an arbitrary calling strategy g on an
unresolved block of size u is exactly

        Var[hits] = D(g) / (u (u - 1)),

where D(g) = #{(i, j) : g(i) != g(j)} is the number of ordered pairs of slots
receiving distinct calls.  Tallying call multiplicities m_1, ..., m_r gives

        D(g) = u^2 - sum_t m_t^2,

so the exact variance is available in O(u) time and O(r) space, replacing the
O(u! * u) enumeration.  The mean is always exactly 1, whatever g.
"""

from __future__ import annotations

from fractions import Fraction
from typing import Dict, List, Sequence, Tuple


def call_multiplicities(g: Sequence[int]) -> List[int]:
    """Multiplicities of the distinct cards named by g, in descending order.
    This is the fibre partition of g, an integer partition of u."""
    counts: Dict[int, int] = {}
    for a in g:
        counts[a] = counts.get(a, 0) + 1
    return sorted(counts.values(), reverse=True)


def collision_profile(g: Sequence[int]) -> int:
    """D(g) = u^2 - sum_t m_t^2, computed in O(u) time."""
    u: int = len(g)
    return u * u - sum(m * m for m in call_multiplicities(g))


def exact_variance(g: Sequence[int]) -> Fraction:
    """Var[hits] = D(g) / (u(u-1)), exact.  Requires u >= 2."""
    u: int = len(g)
    if u < 2:
        raise ValueError("the collision formula requires u >= 2")
    return Fraction(collision_profile(g), u * (u - 1))


def exact_mean(g: Sequence[int]) -> Fraction:
    """E[hits] = 1 for every strategy, injective or not."""
    return Fraction(1)


def variance_from_partition(partition: Sequence[int]) -> Fraction:
    """Exact variance directly from a fibre partition m_1 + ... + m_r = u."""
    u: int = sum(partition)
    d: int = u * u - sum(m * m for m in partition)
    return Fraction(d, u * (u - 1))


def achievable_variances(u: int) -> List[Tuple[Tuple[int, ...], Fraction]]:
    """All variances achievable on a block of size u, indexed by fibre partition.
    Enumerates the integer partitions of u; the variance is monotone in how
    finely the calls are spread."""

    def partitions(n: int, cap: int) -> List[Tuple[int, ...]]:
        if n == 0:
            return [()]
        out: List[Tuple[int, ...]] = []
        for first in range(min(n, cap), 0, -1):
            for rest in partitions(n - first, first):
                out.append((first,) + rest)
        return out

    return [(p, variance_from_partition(p)) for p in partitions(u, u)]


if __name__ == "__main__":
    u: int = 6
    print(f"All achievable risk profiles on an unresolved block of size u = {u}")
    print(f"  (the mean is exactly 1 in every row)\n")
    print(f"  {'fibre partition':<24}{'D(g)':>7}{'Var[hits]':>12}{'decimal':>12}")
    for part, var in achievable_variances(u):
        d: int = u * u - sum(m * m for m in part)
        label: str = "+".join(str(m) for m in part)
        print(f"  {label:<24}{d:>7}{str(var):>12}{float(var):>12.5f}")
    print("\n  Constant strategy -> variance 0 (certainty of exactly one hit).")
    print("  Injective strategy -> variance 1 (Poisson-like fluctuation).")


"""Exact Moment Enumeration over the Symmetric Group.

Ground-truth oracle for the blind deck game: enumerate all u! arrangements and
accumulate the exact rational moments of the hit count of a given strategy.
"""

from __future__ import annotations

from fractions import Fraction
from itertools import permutations
from typing import Dict, List, Sequence, Tuple


def hit_count(g: Sequence[int], sigma: Sequence[int]) -> int:
    """Number of slots i with sigma(i) == g(i)."""
    return sum(1 for i in range(len(g)) if sigma[i] == g[i])


def exact_hit_distribution(g: Sequence[int]) -> Dict[int, Fraction]:
    """Exact law of the hit count of strategy g under a uniform random
    arrangement.  Returns {k: P[hits = k]} with rational probabilities.

    Complexity: O(u! * u) time, O(u) space.  Practical to u ~ 9.
    """
    u: int = len(g)
    tally: Dict[int, int] = {}
    total: int = 0
    for sigma in permutations(range(u)):
        k: int = hit_count(g, sigma)
        tally[k] = tally.get(k, 0) + 1
        total += 1
    return {k: Fraction(c, total) for k, c in sorted(tally.items())}


def exact_moments(g: Sequence[int], order: int = 2) -> List[Fraction]:
    """Exact moments E[hits^1], ..., E[hits^order] of strategy g."""
    law: Dict[int, Fraction] = exact_hit_distribution(g)
    return [
        sum((p * Fraction(k) ** r for k, p in law.items()), Fraction(0))
        for r in range(1, order + 1)
    ]


def exact_block_value(g: Sequence[int], w: Fraction, l: Fraction) -> Fraction:
    """Exact expected score of the unresolved block, paying w per hit and l per
    miss.  Equals (w - l) + l * u for every strategy g."""
    u: int = len(g)
    mean_hits: Fraction = exact_moments(g, 1)[0]
    return w * mean_hits + l * (Fraction(u) - mean_hits)


def report(u: int, strategies: Dict[str, List[int]], w: Fraction, l: Fraction) -> None:
    """Print exact means, variances, block values and hit laws."""
    print(f"block size u = {u},  payoffs (w, l) = ({w}, {l})")
    print(f"  fair-odds condition:  w = l(1 - u)  ->  w should be {l * (1 - u)}")
    for name, g in strategies.items():
        m1, m2 = exact_moments(g, 2)
        var: Fraction = m2 - m1 * m1
        law: Dict[int, Fraction] = exact_hit_distribution(g)
        print(f"  {name:<18} E[hits]={m1}  Var[hits]={var}  "
              f"E[block]={exact_block_value(g, w, l)}")
        print(f"      law: {{" + ", ".join(f"{k}: {p}" for k, p in law.items()) + "}")


if __name__ == "__main__":
    u_demo: int = 5
    strats: Dict[str, List[int]] = {
        "injective": [0, 1, 2, 3, 4],
        "one repeat": [0, 0, 2, 3, 4],
        "two pairs": [0, 0, 1, 1, 4],
        "constant": [0, 0, 0, 0, 0],
    }
    report(u_demo, strats, Fraction(u_demo - 1), Fraction(-1))
    print()
    report(u_demo, strats, Fraction(1), Fraction(0))


"""Stagewise Feedback Valuation by Collapsed Backward Recursion.

In the feedback game the predictor calls one card at a time and sees it turned
face up; the state is the set S of still-unseen cards.  For any *admissible*
strategy (one that never names an already-seen card) the value obeys

    V(S) = [ |S| * miss(|S|) + hit(|S|) - miss(|S|) + sum_{a in S} V(S - a) ] / |S|.

Because exactly one of the |S| equally likely cards is the called one, the value
depends on S only through |S|, and the set-indexed recursion (which would cost
O(u!) evaluations) collapses to the scalar iteration

    V(m) = [ m*miss(m) + hit(m) - miss(m) ] / m  +  V(m-1),    V(0) = 0,

costing O(u) exact rational operations.  Two instantiations:

    hit = 1, miss = 0        ->  V(u) = H_u        (unbounded value of feedback)
    hit(m) = m-1, miss = -1  ->  V(u) = 0          (fair odds are information-proof)
"""

from __future__ import annotations

from fractions import Fraction
from typing import Callable, Dict, List, Tuple

Schedule = Callable[[int], Fraction]


def feedback_value(u: int, hit: Schedule, miss: Schedule) -> Fraction:
    """Exact value of the feedback game on u live cards, for any admissible
    strategy.  O(u) time, O(1) space."""
    v: Fraction = Fraction(0)
    for m in range(1, u + 1):
        v += (m * miss(m) + hit(m) - miss(m)) / m
    return v


def feedback_value_by_state(
    live: Tuple[int, ...],
    strategy: Callable[[Tuple[int, ...]], int],
    hit: Schedule,
    miss: Schedule,
    memo: Dict[Tuple[int, ...], Fraction] | None = None,
) -> Fraction:
    """Full set-indexed recursion, used as an independent check.  Exponential in
    u without memoisation; memoised it is O(2^u) states."""
    if memo is None:
        memo = {}
    if not live:
        return Fraction(0)
    if live in memo:
        return memo[live]
    m: int = len(live)
    call: int = strategy(live)
    total: Fraction = Fraction(0)
    for a in live:
        payoff: Fraction = hit(m) if call == a else miss(m)
        rest: Tuple[int, ...] = tuple(x for x in live if x != a)
        total += payoff + feedback_value_by_state(rest, strategy, hit, miss, memo)
    memo[live] = total / m
    return memo[live]


def harmonic(n: int) -> Fraction:
    """H_n = 1 + 1/2 + ... + 1/n."""
    return sum((Fraction(1, j) for j in range(1, n + 1)), Fraction(0))


UNIT_HIT: Schedule = lambda m: Fraction(1)
UNIT_MISS: Schedule = lambda m: Fraction(0)
FAIR_HIT: Schedule = lambda m: Fraction(m - 1)
FAIR_MISS: Schedule = lambda m: Fraction(-1)


if __name__ == "__main__":
    print(f"{'u':>4}{'blind (unit)':>15}{'feedback H_u':>16}{'gain':>14}"
          f"{'blind (fair)':>15}{'feedback (fair)':>18}")
    for u in range(1, 13):
        h: Fraction = harmonic(u)
        assert feedback_value(u, UNIT_HIT, UNIT_MISS) == h
        assert feedback_value(u, FAIR_HIT, FAIR_MISS) == Fraction(0)
        print(f"{u:>4}{1:>15}{float(h):>16.6f}{float(h - 1):>14.6f}"
              f"{0:>15}{0:>18}")

    # Independent verification against the full set-indexed recursion.
    for u in range(1, 9):
        live: Tuple[int, ...] = tuple(range(u))
        for name, strat in {
            "call smallest": (lambda S: min(S)),
            "call largest": (lambda S: max(S)),
        }.items():
            assert feedback_value_by_state(live, strat, UNIT_HIT, UNIT_MISS) == harmonic(u)
            assert feedback_value_by_state(live, strat, FAIR_HIT, FAIR_MISS) == Fraction(0)
    print("\nSet-indexed recursion agrees with the collapsed iteration for u <= 8,")
    print("for every admissible strategy tested: the value is strategy-free.")


"""Visualization: What Information Is Worth, and Why a High Win Rate Is Not an Edge.

LEFT — the feedback dichotomy.  Under naive unit scoring a blind pass through an
unresolved block of u cards scores exactly 1, while any admissible feedback
strategy scores the harmonic number H_u, which grows like log u without bound
(Oresme's staircase 1 + n/2 <= H_{2^n} is drawn as a lower envelope).  Under
stagewise fair odds BOTH curves are identically zero: information changes the
price, not the edge.

RIGHT — the doubling paradox.  The win probability 1 - 2^{-n} races to
certainty while the expected net gain stays pinned at exactly 0, because the
single catastrophic outcome costs -(2^n - 1).  The loss magnitude is drawn on a
logarithmic twin axis.

Requires: numpy, matplotlib.  Produces information_and_doubling.png.
"""

from __future__ import annotations

from fractions import Fraction
from typing import List

import matplotlib.pyplot as plt
import numpy as np


def harmonic(n: int) -> Fraction:
    return sum((Fraction(1, j) for j in range(1, n + 1)), Fraction(0))


def main() -> None:
    fig, (ax_info, ax_doub) = plt.subplots(1, 2, figsize=(13.5, 5.2))

    # ---- left panel: the value of feedback -------------------------------
    us: List[int] = list(range(1, 65))
    hs: List[float] = [float(harmonic(u)) for u in us]
    ax_info.plot(us, hs, color="#2b5d8a", linewidth=2.2,
                 label=r"feedback, unit scoring:  $H_u$")
    ax_info.plot(us, [1.0] * len(us), color="#c9772f", linewidth=2.2,
                 label="blind, unit scoring:  exactly 1")
    ax_info.plot(us, [0.0] * len(us), color="crimson", linewidth=2.4,
                 linestyle="--",
                 label="both games at fair odds:  exactly 0")

    oresme_x: List[int] = [2 ** n for n in range(0, 7)]
    oresme_y: List[float] = [1 + n / 2 for n in range(0, 7)]
    ax_info.step(oresme_x, oresme_y, where="post", color="#7a7a7a",
                 linewidth=1.2, linestyle=":",
                 label=r"Oresme bound  $1 + n/2 \leq H_{2^n}$")
    ax_info.scatter(oresme_x, oresme_y, s=22, color="#7a7a7a", zorder=4)

    ax_info.fill_between(us, [1.0] * len(us), hs, color="#2b5d8a", alpha=0.12)
    ax_info.annotate(r"the value of information: $H_u - 1 \approx \log u$",
                     xy=(34, (1 + float(harmonic(34))) / 2),
                     xytext=(1.6, 3.4), fontsize=9.5, color="#2b5d8a",
                     arrowprops=dict(arrowstyle="->", color="#2b5d8a", lw=1.1))

    ax_info.set_xscale("log", base=2)
    ax_info.set_xlabel("size u of the unresolved block (log scale)")
    ax_info.set_ylabel("expected score")
    ax_info.set_title("Feedback is worth an unbounded amount against a stale\n"
                      "book, and exactly nothing against a live one")
    ax_info.legend(fontsize=8.5, frameon=False, loc="upper left")
    ax_info.spines[["top", "right"]].set_visible(False)

    # ---- right panel: the doubling paradox -------------------------------
    ns: np.ndarray = np.arange(1, 21)
    p_win: np.ndarray = 1 - 2.0 ** (-ns.astype(float))
    loss: np.ndarray = 2.0 ** ns.astype(float) - 1

    ax_doub.plot(ns, p_win, color="#2b7a4b", linewidth=2.4, marker="o",
                 markersize=4, label=r"$\mathbb{P}[\mathrm{net\ gain} > 0] = 1 - 2^{-n}$")
    ax_doub.plot(ns, np.zeros_like(p_win), color="crimson", linewidth=2.4,
                 linestyle="--", label=r"$\mathbb{E}[\mathrm{net\ gain}] = 0$ exactly")
    ax_doub.axhline(1.0, color="#bbbbbb", linewidth=0.9)
    ax_doub.set_xlabel("horizon n (number of fair tosses)")
    ax_doub.set_ylabel("probability  /  expected gain")
    ax_doub.set_ylim(-0.12, 1.12)
    ax_doub.set_xticks(list(range(2, 21, 2)))
    ax_doub.set_title("The doubling paradox: near-certain wins,\n"
                      "zero expectation")
    ax_doub.spines[["top"]].set_visible(False)

    ax_twin = ax_doub.twinx()
    ax_twin.plot(ns, loss, color="#8a2b5d", linewidth=1.8, linestyle="-.",
                 label=r"size of the rare loss  $2^n - 1$")
    ax_twin.set_yscale("log")
    ax_twin.set_ylabel("magnitude of the losing outcome (log scale)",
                       color="#8a2b5d")
    ax_twin.tick_params(axis="y", colors="#8a2b5d")
    ax_twin.spines[["top"]].set_visible(False)

    handles_a, labels_a = ax_doub.get_legend_handles_labels()
    handles_b, labels_b = ax_twin.get_legend_handles_labels()
    ax_doub.legend(handles_a + handles_b, labels_a + labels_b,
                   fontsize=8.5, frameon=False, loc="center right")

    fig.suptitle("Uncertainty supplies no positive edge — in two different disguises",
                 fontsize=13)
    fig.tight_layout()
    fig.savefig("information_and_doubling.png", dpi=170)
    print("wrote information_and_doubling.png")


if __name__ == "__main__":
    main()


"""Visualization: The Risk Frontier of a Fairly Priced Blind Prediction Game.

Two panels.

LEFT — the exact hit-count distributions of several calling strategies on an
unresolved block of u = 6 cards, obtained by enumerating all 720 arrangements.
Every distribution has mean exactly 1 (marked by the dashed line), but they
range from a point mass at 1 (constant strategy) to a Poisson-like spread
(injective strategy).

RIGHT — every achievable risk profile on the same block, one point per fibre
partition of u, plotted as variance against the normalised collision profile
D(g)/(u(u-1)).  The points lie exactly on the diagonal, which is the collision
formula Var[hits] = D(g)/(u(u-1)).

Requires: numpy, matplotlib.  Produces risk_frontier.png.
"""

from __future__ import annotations

from fractions import Fraction
from itertools import permutations
from typing import Dict, List, Sequence, Tuple

import matplotlib.pyplot as plt
import numpy as np

U: int = 6


def hit_law(g: Sequence[int]) -> Dict[int, float]:
    """Exact law of the hit count, as floats for plotting."""
    tally: Dict[int, int] = {}
    total: int = 0
    for sigma in permutations(range(len(g))):
        k: int = sum(1 for i in range(len(g)) if sigma[i] == g[i])
        tally[k] = tally.get(k, 0) + 1
        total += 1
    return {k: c / total for k, c in sorted(tally.items())}


def collision_profile(g: Sequence[int]) -> int:
    counts: Dict[int, int] = {}
    for a in g:
        counts[a] = counts.get(a, 0) + 1
    return len(g) ** 2 - sum(m * m for m in counts.values())


def integer_partitions(n: int, cap: int) -> List[Tuple[int, ...]]:
    if n == 0:
        return [()]
    out: List[Tuple[int, ...]] = []
    for first in range(min(n, cap), 0, -1):
        for rest in integer_partitions(n - first, first):
            out.append((first,) + rest)
    return out


def strategy_from_partition(part: Sequence[int]) -> List[int]:
    """A calling strategy whose fibre sizes are exactly `part`."""
    g: List[int] = []
    for card, mult in enumerate(part):
        g.extend([card] * mult)
    return g


def main() -> None:
    fig, (ax_left, ax_right) = plt.subplots(1, 2, figsize=(13.5, 5.2))

    showcase: List[Tuple[str, List[int]]] = [
        ("injective  (Var = 1)", strategy_from_partition([1] * U)),
        ("three pairs  (Var = 4/5)", strategy_from_partition([2, 2, 2])),
        ("two triples  (Var = 3/5)", strategy_from_partition([3, 3])),
        ("constant  (Var = 0)", strategy_from_partition([U])),
    ]
    width: float = 0.2
    colours = plt.cm.viridis(np.linspace(0.1, 0.85, len(showcase)))
    for idx, ((label, g), colour) in enumerate(zip(showcase, colours)):
        law: Dict[int, float] = hit_law(g)
        ks: List[int] = list(range(0, U + 1))
        ps: List[float] = [law.get(k, 0.0) for k in ks]
        offset: float = (idx - (len(showcase) - 1) / 2) * width
        ax_left.bar([k + offset for k in ks], ps, width=width, label=label,
                    color=colour, edgecolor="white", linewidth=0.4)

    ax_left.axvline(1.0, color="crimson", linestyle="--", linewidth=1.6,
                    label="mean = 1 (all strategies)")
    ax_left.set_xlabel("number of correct calls")
    ax_left.set_ylabel("probability")
    ax_left.set_title(f"Exact hit distributions, unresolved block of u = {U}\n"
                      "same mean, wildly different risk")
    ax_left.set_xticks(list(range(0, U + 1)))
    ax_left.legend(fontsize=8.5, frameon=False)
    ax_left.spines[["top", "right"]].set_visible(False)

    xs: List[float] = []
    ys: List[float] = []
    labels: List[str] = []
    for part in integer_partitions(U, U):
        g: List[int] = strategy_from_partition(part)
        d: int = collision_profile(g)
        law = hit_law(g)
        mean: float = sum(k * p for k, p in law.items())
        var: float = sum(k * k * p for k, p in law.items()) - mean ** 2
        xs.append(d / (U * (U - 1)))
        ys.append(var)
        labels.append("+".join(str(m) for m in part))

    ax_right.plot([0, 1], [0, 1], color="crimson", linewidth=1.4, zorder=1,
                  label=r"collision formula  Var $= D(g)/(u(u-1))$")
    ax_right.scatter(xs, ys, s=70, zorder=3, color="#2b5d8a",
                     edgecolor="white", linewidth=1.0,
                     label="exact enumeration, one point per fibre partition")
    for x, y, lab in zip(xs, ys, labels):
        if lab in {"1+1+1+1+1+1", "6", "3+3", "2+2+2"}:
            ax_right.annotate(lab, (x, y), textcoords="offset points",
                              xytext=(8, -10), fontsize=8.5, color="#333333")
    ax_right.set_xlabel(r"normalised collision profile  $D(g)/(u(u-1))$")
    ax_right.set_ylabel(r"$\mathrm{Var}[\mathrm{hits}]$")
    ax_right.set_title("The risk frontier: variance is exactly the fraction of\n"
                       "slot pairs given distinct calls")
    ax_right.legend(fontsize=8.5, frameon=False, loc="upper left")
    ax_right.spines[["top", "right"]].set_visible(False)

    fig.suptitle("A fairly priced game hands the player the risk, never the return",
                 fontsize=13)
    fig.tight_layout()
    fig.savefig("risk_frontier.png", dpi=170)
    print("wrote risk_frontier.png")


if __name__ == "__main__":
    main()


"""Assemble PACKAGE.json from the individual deliverables in this project."""

from __future__ import annotations

import json
import os
from typing import Any, Dict, List

ROOT: str = os.path.dirname(os.path.abspath(__file__))
LEAN_DIR: str = os.path.join(ROOT, "Catalog", "MachineLearning", "KnownUnresolvedCards")
LEAN_ORDER: List[str] = [
    "Basic.lean",
    "PermCount.lean",
    "DeckGame.lean",
    "FeedbackGame.lean",
    "NoFreeLunch.lean",
    "BettingSystem.lean",
    "AxiomAudit.lean",
]


def read(path: str) -> str:
    with open(os.path.join(ROOT, path), "r", encoding="utf-8") as fh:
        return fh.read()


def lean_bundle() -> str:
    chunks: List[str] = []
    for name in LEAN_ORDER:
        rel: str = f"Catalog/MachineLearning/KnownUnresolvedCards/{name}"
        chunks.append(f"-- FILE: {rel}\n\n" + read(rel))
    return "\n\n\n".join(chunks)


FUTURE_DIRECTIONS: str = """# Future Directions — Known versus unresolved cards

The cycle just completed established:

* the **splitting theorem** `E[total payoff] = d` for `d` resolved cards plus any
  number of fair unresolved cards;
* **rigidity**: the fair-odds normalisation is the *unique* scoring that makes
  the unresolved block edge-free, `E = (w - l) + l·u`;
* the **counting anomaly**: naive unit scoring shows a spurious edge of exactly
  `+1`, for every strategy and every block size;
* a **second-moment dichotomy**: the mean score is strategy-invariant while the
  variance is not (`1` for injective, `0` for constant strategies), refined into
  the exact **collision formula** `Var = D/(u(u-1))` with `D` the number of
  ordered slot pairs receiving distinct calls;
* the **feedback dichotomy**: with feedback the unit-scoring value jumps from `1`
  to the harmonic number `H_u` (unbounded), while the fair-odds value stays `0`;
* the **learning-theoretic incarnation** (No Free Lunch) via a flip involution
  and its `ZMod k` generalisation;
* **no betting system**, adaptive or stopped, beats a fair book — including the
  doubling system, which wins with probability `1 - 2^{-n}` and gains `0`.

The directions below are the sharpest open questions these results expose.

---

## 1. Bell-number moment hierarchy for blind card guessing

**Conjecture.** For an injective strategy `g` on an unresolved block of size `u`,
and every `k ≤ u`, the `k`-th moment of the score is *exactly* the Bell number:
`E[hits^k] = B_k`. For non-injective `g` the moments are strictly smaller for
`k ≥ 2`, and the whole moment sequence is determined by the set-partition
statistics of the fibres of `g`.

**The key insight is** that our two counting identities — `|α|·|fiber| = |Perm|`
and `(|α|-1)·|fiber₂| = |fiber|` — are the first two levels of a single
hierarchy: the number of permutations pinned on a `j`-element set of slots is
`|Perm| / (u)_j`, so the `k`-th moment is a sum over set partitions of `{1..k}`,
each contributing exactly `1` when `g` is injective. The moment sequence is then
Poisson(1) *exactly*, not merely asymptotically.

**Why now?** We already possess the `j = 1` and `j = 2` counting lemmas in a
factorial-free, transposition-symmetry form that generalises verbatim to
`j`-fold fibres; only the bookkeeping over set partitions is missing.

## 2. Sequential rigidity of fair odds

*(This slot previously held the collision formula for the variance; that
conjecture was proved inside this cycle, so the slot is now occupied by its
sequential analogue.)*

**Conjecture.** In the feedback game, a *history-dependent* pricing `(w_S, l_S)`
makes the game a zero-expectation bet for **every** admissible strategy if and
only if `w_S = l_S(1 - |S|)` at every reachable state `S`. The one-shot
rigidity theorem propagates verbatim along the whole recursion tree.

## 3. Extremal risk profiles over Young diagrams

The collision profile `D(g)` is a single scalar summarising the fibre structure
of `g`, and the Bell hierarchy suggests the entire moment sequence is a function
of the fibre *partition* of `g`, i.e. of an integer partition of `u`.
Identifying which partitions are extremal for the `k`-th moment — a discrete
optimisation over Young diagrams — would give a complete description of the
achievable risk profiles in a fair blind prediction game.
"""


INTERACTIVE_LAYOUT: str = r"""
# Known versus Unresolved Cards

### A guided tour of why honest uncertainty is worth exactly nothing

---

Imagine a shuffled deck laid face down. You have been counting, and you are
**certain** about $d$ of the cards. The remaining $u$ are a blur. Someone offers
to pay you for every card you name correctly and charge you for every card you
miss, at odds that are *fair* — set so a blind guess is neither favoured nor
punished.

What is that game worth?

The answer is the single sentence this whole page unpacks:

$$\boxed{\ \mathbb{E}[\text{payoff}] \;=\; d\ }$$

Exactly $d$. Not $d$ plus a correction, not $d$ plus something that grows with
$u$, and not something that depends on how cleverly you guess. **Uncertainty,
honestly priced, supplies no positive edge.**

By the end of this page you will know precisely why, and — much more
interestingly — you will know the three distinct ways that statement *appears*
to fail, and be able to tell them apart.

---

## 1. The one theorem everything rests on

Suppose the world can be in any one of finitely many equally likely states. A
**card** is just a payoff: a rule $p$ giving a rational number in each state.

* A card is **resolved with value $c$** if it pays $c$ in *every* state. You know
  it; you collect $c$ regardless.
* A card is **fair** if its average payoff is zero.

> **Splitting Theorem.** If $K$ is a set of resolved cards with values $c_i$, and
> every card outside $K$ is fair, then
> $$\mathbb{E}\Big[\sum_i p_i\Big] = \sum_{i\in K} c_i .$$
> In particular, $d$ resolved cards each paying one unit, plus any number of fair
> cards, are worth exactly $d$.

<details>
<summary><b>Click to reveal the proof (it is three lines)</b></summary>

Averaging is linear, so the average of the sum is the sum of the averages. Each
resolved term averages to its constant $c_i$. Each fair term averages to $0$ by
definition. Add them up. $\blacksquare$

The interest is entirely in what the hypotheses **don't** say. Nothing about
independence — in a shuffled deck the cards are violently dependent, since
knowing where the ace of spades sits tells you it is nowhere else. Nothing about
how the guesses were chosen. Fairness of each card *individually* is enough.
That is why the same theorem will reappear below in four completely different
costumes.

</details>

A special case worth naming on its own: **a portfolio built entirely out of fair
cards has expected payoff zero**, no matter how you correlate or reweight them.
You cannot manufacture an edge by combining things that individually have none.

---

## 2. Play with the deck yourself

Before any more theory, get your hands on it. Below is a live laboratory. Set the
number of known cards $d$, the size of the unresolved block $u$, and the payoffs
$w$ (hit) and $\ell$ (miss). Then **click the slots** to design a calling strategy
— you are allowed to name the same card in every slot if you like.

Three things to try, in order:

1. Press **Snap to fair odds** and then change the strategy wildly. The expected
   payoff does not move off $d$. Not by a hair.
2. Press **Naive unit scoring**. Suddenly the block is worth $+1$ — and *stays*
   worth exactly $+1$ however large you make $u$. Remember that number.
3. Watch the histogram while you change the strategy. The mean is nailed to $1$,
   but the shape changes completely, from a point mass to a broad spread.

{{interactive_demo:0}}

That third observation is the one most people miss, and we will make it exact in
§5.

---

## 3. Why the mean cannot see your strategy

Model the block honestly: $u$ slots, $u$ cards, and a uniformly random bijection
$\sigma$ from slots to cards. A strategy is *any* function $g$ from slots to
cards.

Everything follows from one counting fact, and it deserves a good proof rather
than a mechanical one.

> Among all $u!$ arrangements, exactly a $1/u$ fraction put a prescribed card $a$
> in a prescribed slot $i$.

<details>
<summary><b>A proof with no factorials in it</b></summary>

For any two cards $a$ and $b$, composing an arrangement with the transposition
that swaps $a$ and $b$ is a bijection between the arrangements putting $a$ in
slot $i$ and those putting $b$ in slot $i$ — and it is its own inverse. So all
$u$ of these classes have the same size. They are disjoint, and every
arrangement belongs to exactly one of them, since $\sigma$ sends $i$ somewhere.
Hence
$$u\cdot\#\{\sigma:\sigma(i)=a\} = u! .$$

The same trick one level down gives the conditional version: for $i\neq j$ and
$a\neq b$, left-composing with the transposition of $b$ and $b'$ (which fixes
$a$) shows
$$(u-1)\cdot\#\{\sigma:\sigma(i)=a,\ \sigma(j)=b\} = \#\{\sigma:\sigma(i)=a\}.$$

These two identities are the first two rungs of a ladder — see §8, where the
ladder is still being climbed. Their factorial-free form is exactly what makes
them generalise.

</details>

Consequently, for every slot and every call,
$$\mathbb{E}[\text{slot score}] = \frac{w-\ell}{u} + \ell,$$
which mentions neither the slot nor the call. Summing over the block:

> **Block Value.** For every strategy $g$, $\ \mathbb{E}[\text{block}] = (w-\ell) + \ell u$.

Set this to zero and you get something stronger than a convention.

> **Rigidity of Fair Odds.** The block is edge-free if and only if $w = \ell(1-u)$
> — and then it is edge-free for *every* strategy.

With the usual normalisation $\ell = -1$ this says $w = u-1$: a hit must pay
$(u-1):1$, exactly the honest quote among $u$ equally likely candidates. So "no
edge" is not a lucky accident of the numbers; it **characterises** the honest
quote. Any other pricing hands every strategy the identical nonzero edge, and
that edge is a property of the book, not of the player.

---

## 4. The phantom edge, and where it comes from

Score the block naively — $1$ for a hit, $0$ for a miss — and the block value
formula gives $(1-0) + 0\cdot u = 1$.

> **The Counting Anomaly.** Under naive unit scoring the expected number of
> correct calls is exactly $1$, for every strategy and every block size.

This is the classical fact that a random permutation has one fixed point on
average, generalised to comparison against an arbitrary and possibly silly guess.
It is real — you *do* get one extra correct call — but it is not an edge, because
unit scoring pays for hits and never charges for misses. Whoever offers it is
making you a gift of exactly one card, and the gift does not grow when you think
harder or when the deck gets bigger.

Here is the machinery that verifies all of this exactly, with no floating point
anywhere: enumerate the symmetric group and accumulate rational moments.

{{algorithm:0}}

---

## 5. What you *can* control: risk

If the mean is the same for everyone, is every strategy the same? Emphatically
not — and the histogram in §2 already told you so.

Define the **collision profile** of a strategy as the number of *ordered* pairs
of slots receiving different calls,
$$D(g) = \#\{(i,j) : g(i)\neq g(j)\},$$
which is $u(u-1)$ for an injective strategy and $0$ for a constant one.

> **Collision Formula.** For every strategy $g$ on a block of $u \ge 2$ cards,
> $$\operatorname{Var}[\text{hits}] = \frac{D(g)}{u(u-1)} \in [0,1].$$

The variance is *exactly* the fraction of slot pairs on which you hedged by
naming distinct cards.

<details>
<summary><b>Click to reveal the proof</b></summary>

Expand the square of the hit count over ordered pairs of slots and sum over
arrangements. Diagonal pairs contribute $1$ in total, by the first counting
identity. An off-diagonal pair $(i,j)$ contributes the probability that both
calls land — which is $0$ if $g(i) = g(j)$, since one card cannot occupy two
slots, and $1/(u(u-1))$ otherwise by the second counting identity. Exactly $D(g)$
off-diagonal pairs survive, so
$$\mathbb{E}[\text{hits}^2] = 1 + \frac{D(g)}{u(u-1)} .$$
Subtract $\mathbb{E}[\text{hits}]^2 = 1$. $\blacksquare$

Two sanity checks. A constant strategy has $D = 0$ and variance $0$: naming the
seven of hearts everywhere gets you exactly one hit, with certainty, because the
seven of hearts is somewhere. An injective strategy has $D = u(u-1)$ and variance
$1$: the Poisson-like fluctuation everyone expects.

</details>

So the first moment cannot see your strategy at all, and the second moment sees
precisely and only its pattern of repeated calls. **In a fair game, choosing a
strategy is choosing a risk profile.** That is a real choice — it is just not a
choice about expected value.

The picture below makes the whole frontier visible: on the left, exact hit
distributions with identical means; on the right, every achievable risk profile,
one point per pattern of repeated calls, landing exactly on the diagonal.

{{visualization:0}}

And here is the linear-time way to compute any of it, without touching the $u!$
enumeration:

{{algorithm:1}}

---

## 6. Now let the player see the cards

Everything above assumed a *blind* player who commits to all $u$ calls in advance.
Give her **feedback** — each card is turned face up after she calls it — and she
need only remember which cards remain unseen. A feedback strategy is a rule from
the live set $S$ to a call $g(S)$, and it is *admissible* if it never names a dead
card.

This is obviously worth something. How much?

> **The Value of Feedback.** Under naive unit scoring, an admissible feedback
> strategy on $u$ cards makes exactly $H_u = 1 + \tfrac12 + \cdots + \tfrac1u$
> correct calls in expectation — against exactly $1$ for any blind strategy. And
> $H_u$ grows without bound, roughly like $\log u$.

<details>
<summary><b>The one-line recursion behind it</b></summary>

With $m$ cards live, the next card is uniform over the live set, so an admissible
call is right with probability exactly $1/m$; then the game continues on $m-1$
cards. Hence $V(m) = 1/m + V(m-1)$ with $V(0) = 0$, which is the definition of
the harmonic number.

That $H_u \to \infty$ is [Oresme's fourteenth-century
argument](https://en.wikipedia.org/wiki/Harmonic_series_(mathematics)): each
doubling of the range adds at least $\tfrac12$, giving $1 + n/2 \le H_{2^n}$.

Notice what the recursion does *not* contain: any reference to which card was
called. Every admissible strategy scores $H_u$. Cleverness is worth nothing;
merely not re-calling a dead card is worth everything.

</details>

**Now the punchline.** Reprice the game honestly at each stage: with $m$
candidates still live, a hit pays $m-1$ and a miss costs $1$.

> **Fair Odds Are Information-Proof.** Under stagewise fair odds the feedback game
> has expected payoff exactly $0$, for every admissible strategy.

Zero — the same zero as the blind game. Information did not create value against
a correctly priced book; it changed the price. This is what feedback was really
beating in the unit-scoring game: a book that had failed to update. **Information
is worth exactly as much as someone else's prices are stale.**

Toggle between the two scoring regimes in the widget below and watch the whole
picture flip. The second half of the same widget then takes on the oldest
objection in the casino — see §7.

{{interactive_demo:1}}

The recursion collapses beautifully in code: the value depends on the live set
only through its size, so an apparently exponential computation becomes $O(u)$.

{{algorithm:2}}

---

## 7. No system, ever

*"Fine, you can't beat a fair bet — but surely you can beat a fair* sequence *of
bets, by choosing how much to stake and when to walk away."*

Let the gambler be maximally adaptive: before each fair $\pm1$ toss she stakes any
rational amount, of either sign, of any size, depending on the entire history. A
stake of $0$ means she has quit, so every stopping rule is included.

> **No Betting System.** For every adaptive stake function, every finite horizon
> and every history, the expected net gain is exactly $0$.

<details>
<summary><b>Click to reveal the proof (induction on the horizon)</b></summary>

At the next toss the stake $s$ contributes $+s$ with probability one half and
$-s$ with probability one half, so it cancels. Whatever the toss does, the
remaining game is worth zero by the inductive hypothesis — which applies to
*every* history, including both extensions of the current one. $\blacksquare$

This is the finite-horizon
[optional stopping theorem](https://en.wikipedia.org/wiki/Optional_stopping_theorem),
obtained with no measure theory at all: the sample space is finite at each
horizon.

</details>

And then the classic apparent counterexample. The **doubling system**: bet one; on
a loss bet two, then four, doubling until you win, then stop. After $k$ losses you
are down $2^k - 1$ and stake $2^k$, so a win nets exactly
$2^k - (2^k - 1) = 1$. Over $n$ tosses you win a unit unless *every single toss*
comes up tails — probability $2^{-n}$.

> **The Doubling Paradox, Resolved.** The system wins with probability
> $1 - 2^{-n}$, which you can push as close to certainty as you like, and its
> expected net gain is nevertheless exactly $0$:
> $$(1-2^{-n})\cdot 1 + 2^{-n}\cdot\big(-(2^n-1)\big) = 0 .$$

The improbable loss is exactly as large as the probable gain is likely. Run the
simulator in the widget above: the running average hugs $+1$ for long stretches,
then a single ruin drags it back to zero. **A high win rate is not an edge** —
and by the theorem, that is not a caution, it is an identity.

{{algorithm:3}}

The two faces of the principle, side by side:

{{visualization:1}}

---

## 8. The same theorem, wearing a lab coat

Change the vocabulary completely and watch it reappear.

Fix a finite domain $X$ and let the **target** $f$, labelling each point true or
false, be uniformly random among all $2^{|X|}$ possibilities. A learner sees the
labels on a training set $T$ and outputs a hypothesis. It is *consistent* (it
reproduces the training labels) and *blind off-sample* (it depends on $f$ only
through the labels on $T$). Score $+1$ per correct prediction and $-1$ per error.

> **No Free Lunch.** The expected total score is exactly $|T|$, for every such
> learner. Equivalently, expected accuracy is $\tfrac{|T| + |X|}{2}$: perfect on
> the training set, and *exactly chance* everywhere else.

<details>
<summary><b>The involution argument — as sharp as proofs get</b></summary>

Fix $x \notin T$ and flip the label of $f$ at $x$ and nowhere else. This is a
fixed-point-free involution of target space. It leaves the training labels
untouched, hence the hypothesis untouched, hence the *prediction* at $x$
untouched — while flipping the *truth* at $x$, and so negating the score there.
Pair each target with its flip and the scores cancel exactly, so an off-training
point is a fair card. Apply the Splitting Theorem: the training points are
resolved, everything else is fair. $\blacksquare$

**The hypotheses are load-bearing.** A "learner" allowed to peek at off-training
labels and copy them scores the maximum $|X|$ with an *empty* training set. The
theorem's content is entirely about what the learner is not allowed to see.

**Beyond binary labels.** With $k$ labels, replace the flip by the free action of
the cyclic group of order $k$ — shifting the label at $x$ by $1,\dots,k-1$ — and
price the card at fair odds $(k-1):1$. Each orbit has exactly one hit, scoring
$k-1$, and $k-1$ misses, scoring $-1$ each; the orbit contributes zero. The
expected score of a consistent learner is exactly $(k-1)|T|$.

</details>

The moral is *not* that learning is impossible. It is that the uniform average
over all targets is precisely an unresolved block, and worth precisely nothing.
Every working algorithm's success is borrowed entirely from the fact that real
targets are not uniformly random — from structure, from smoothness, from
inductive bias, which is itself a form of resolved information. In this page's
vocabulary: real problems have $d > |T|$.

---

## 9. Run everything at once

The script below reproduces every identity on this page in exact rational
arithmetic — no floating point, no sampling, no approximation. Each section ends
in an assertion, so if any identity were off by a hair the script would crash.

{{demo:0}}

---

## 10. Five sentences to keep

1. **Uncertainty priced honestly is worth zero.** The game is worth $d$, the
   number of cards you actually know; correlations, cleverness and block size are
   all irrelevant.
2. **Honest pricing is unique.** The $(u-1):1$ quote is the only one that makes
   the unresolved block edge-free, so "no edge" characterises fairness.
3. **The apparent edge of uncertainty is a scoring artefact of size exactly one.**
4. **Strategy controls risk, not return** — exactly the fraction
   $D(g)/(u(u-1))$ of slot pairs given distinct calls.
5. **Information changes the price, not the edge**, and no adaptive system turns
   a fair sequence of bets into a favourable one.

---

## 11. The ladder that is still being climbed

The two counting identities of §3 are visibly the first two rungs of something
longer. The number of arrangements pinned on a $j$-element set of slots ought to
be $u!/(u)_j$ with $(u)_j = u(u-1)\cdots(u-j+1)$, by the same transposition
argument applied $j$ times. Climbing the ladder should deliver every moment, not
just the first two:

> **Conjecture.** For an injective strategy on a block of $u$ cards and every
> $k \le u$, the $k$-th moment of the hit count is exactly the Bell number $B_k$
> — the number of ways to partition a $k$-element set.

The mean $B_1 = 1$ and the second moment $B_2 = 2$ are exactly the two facts
proved on this page. If the pattern holds, a blind injective strategy's score is
*exactly* [Poisson](https://en.wikipedia.org/wiki/Poisson_distribution) with
parameter $1$ in all moments up to $u$ — not merely asymptotically — and for
non-injective strategies the moments drop, governed entirely by the set-partition
statistics of the repeated calls, exactly as the variance is governed by the
collision profile.

A second open question is the sequential analogue of rigidity: in the feedback
game, is $w_S = \ell_S(1 - |S|)$ at every reachable state the *only* pricing that
is edge-free for every admissible strategy? And a third: since the collision
profile is just one scalar summary of the pattern of repeated calls, which
patterns are extremal for the $k$-th moment? That is a discrete optimisation over
Young diagrams, and answering it would completely describe the achievable risk
profiles of a fair blind prediction game.
"""


def main() -> None:
    package: Dict[str, Any] = {
        "title": "Known versus Unresolved Cards: An Exact Calculus of Certainty, "
                 "Fair Odds, and the Value of Information",
        "domain": "MachineLearning",
        "description": (
            "An exact, finite, distribution-free calculus for prediction games mixing "
            "cards known with certainty and cards that must be guessed: with d resolved "
            "cards paying one unit each and any number of fairly priced unresolved cards, "
            "the expected payoff is exactly d, whatever the correlations and whatever the "
            "strategy. The development pins down where the principle appears to fail — a "
            "spurious +1 from naive scoring, a strategy-dependent variance given exactly by "
            "a collision profile, and the harmonic value of feedback against a stale book."
        ),
        "authors": ["Aristotle"],
        "date": "2026-08-23",
        "key_results": [
            "Splitting Theorem: d cards resolved with unit value together with any number "
            "of fair unresolved cards have expected total payoff exactly d, with no "
            "independence assumption and for every guessing strategy.",
            "Rigidity of fair odds: an unresolved block of u cards paying w on a hit and l "
            "on a miss is edge-free for one strategy if and only if w = l(1 - u), and then "
            "for all strategies; the (u-1):1 quote is therefore characterised, not assumed.",
            "The counting anomaly: under naive unit scoring the expected number of correct "
            "calls on an unresolved block is exactly 1, for every strategy and every block "
            "size, so the apparent edge of uncertainty is a scoring artefact of size one.",
            "Collision formula for the variance: the hit count of any calling strategy g on "
            "a block of u cards has mean exactly 1 and variance exactly D(g)/(u(u-1)), where "
            "D(g) is the number of ordered slot pairs receiving distinct calls — 0 for a "
            "constant strategy, 1 for an injective one.",
            "Feedback dichotomy: with per-card feedback the unit-scoring value of the block "
            "rises to the harmonic number H_u, unbounded by Oresme's bound 1 + n/2 <= H_{2^n}, "
            "while at stagewise fair odds it remains exactly 0 for every admissible strategy.",
            "No Free Lunch and no betting system: a consistent learner blind off-sample has "
            "expected score exactly |T| (chance level off the training set), by a "
            "fixed-point-free label-flip involution and its k-ary cyclic generalisation; and "
            "every adaptive, stopped staking rule on fair tosses has expected gain exactly 0, "
            "including the doubling system, which wins with probability 1 - 2^{-n}.",
        ],
        "keywords": [
            "fair odds",
            "random permutations",
            "fixed points",
            "No Free Lunch",
            "optional stopping",
            "harmonic numbers",
            "collision profile",
            "variance decomposition",
        ],
        "article": read("ARTICLE.md"),
        "research_paper": read("RESEARCH_PAPER.md"),
        "research_paper_tex": read("RESEARCH_PAPER.tex"),
        "demo": read("demo.py"),
        "demos": [
            {
                "name": "Exact Rational Verification of the Full Known-versus-Unresolved "
                        "Calculus",
                "description": (
                    "A single self-contained script that reproduces every identity of the "
                    "development in exact rational arithmetic, with no floating point and no "
                    "sampling anywhere. It builds three deliberately correlated fair cards on "
                    "a small finite state space and checks that d resolved cards plus those "
                    "fair cards are worth exactly d; brute-forces the symmetric group to "
                    "confirm the master slot formula E[slot] = (w-l)/u + l and the block value "
                    "(w-l) + l*u across four structurally different strategies; verifies that "
                    "the block has zero value precisely when w = l(1-u); exhibits the counting "
                    "anomaly of exactly +1 under unit scoring for every strategy and every "
                    "block size; checks the collision formula Var[hits] = D(g)/(u(u-1)) "
                    "against brute force for a showcase of strategies and then exhaustively "
                    "for all 256 strategies on a block of four; evaluates the feedback game "
                    "both by the collapsed scalar recursion and by the full set-indexed "
                    "recursion, obtaining H_u under unit scoring and 0 at stagewise fair odds; "
                    "confirms Oresme's bound 1 + n/2 <= H_{2^n} up to n = 11; sums the No Free "
                    "Lunch score over all 1024 targets on a ten-point domain for three "
                    "different off-sample rules and four training-set sizes; and evaluates "
                    "five adaptive betting systems by backward induction, closing with the "
                    "exact ledger of the doubling paradox. Every section ends in an assertion, "
                    "so a false identity would abort the run."
                ),
                "code": read("demo.py"),
            }
        ],
        "algorithms": [
            {
                "name": "Exact Moment Enumeration over the Symmetric Group",
                "description": (
                    "The ground-truth oracle for the blind deck game. Enumerating all u! "
                    "arrangements and tallying the number of slots where the strategy's call "
                    "matches the arrangement yields the exact law of the hit count as rational "
                    "probabilities with denominator dividing u!, from which any moment and any "
                    "block value w*E[hits] + l*(u - E[hits]) follows without approximation. "
                    "The routine is deliberately naive: it exists to certify the closed forms "
                    "proved elsewhere — the mean is exactly 1 for every strategy, the block "
                    "value is (w - l) + l*u, the variance is D(g)/(u(u-1)) — rather than to be "
                    "fast. Complexity is O(u! * u) time and O(u) space, which is practical to "
                    "u about 9 (roughly 3.3 million permutations); beyond that the closed "
                    "forms are the only sensible route, which is precisely the point of having "
                    "them. Because the state count u! is exactly the size of the sample space, "
                    "the tallies are integers and the resulting probabilities are exact "
                    "rationals, so the comparison against the closed forms is an equality "
                    "test, not a tolerance test."
                ),
                "pseudocode": (
                    "ALGORITHM ExactMomentEnumeration(g, w, l, order)\n"
                    "INPUT   g[0..u-1]  : calling strategy, g[i] is the card named in slot i\n"
                    "        w, l       : rational payoffs for a hit and for a miss\n"
                    "        order      : highest moment required\n"
                    "OUTPUT  law        : exact distribution of the hit count\n"
                    "        moments    : E[hits^1..order], exact rationals\n"
                    "        block      : exact expected block score\n"
                    "\n"
                    "1  u <- length(g)\n"
                    "2  tally[0..u] <- 0 ;  total <- 0\n"
                    "3  for each permutation sigma of {0,...,u-1} do\n"
                    "4        h <- 0\n"
                    "5        for i <- 0 to u-1 do\n"
                    "6              if sigma[i] = g[i] then h <- h + 1\n"
                    "7        tally[h] <- tally[h] + 1 ;  total <- total + 1\n"
                    "8  law[k] <- tally[k] / total     for k = 0..u        // exact rationals\n"
                    "9  for r <- 1 to order do\n"
                    "10       moments[r] <- SUM over k of law[k] * k^r\n"
                    "11 block <- w * moments[1] + l * (u - moments[1])\n"
                    "12 ASSERT moments[1] = 1                              // strategy invariance\n"
                    "13 ASSERT block = (w - l) + l * u                     // block value formula\n"
                    "14 return (law, moments, block)"
                ),
                "code": read("assets/alg_enumeration.py"),
            },
            {
                "name": "Linear-Time Collision Profile and Exact Variance Evaluation",
                "description": (
                    "Replaces the factorial-cost enumeration by a closed form. The collision "
                    "profile D(g) counts the ordered pairs of slots that receive distinct "
                    "calls, and the variance of the hit count is exactly D(g)/(u(u-1)). "
                    "Computing D(g) by definition would cost O(u^2); tallying the "
                    "multiplicities m_1,...,m_r of the distinct called cards instead gives "
                    "D(g) = u^2 - sum_t m_t^2 in O(u) time and O(r) space, since each of the "
                    "sum_t m_t^2 ordered pairs sharing a call is exactly the complement. The "
                    "quantity depends on g only through its fibre partition, an integer "
                    "partition of u, so the algorithm doubles as an enumerator of every "
                    "achievable risk profile on a block of size u: partition u, evaluate the "
                    "formula, and read off the complete menu of variances available to a "
                    "player whose expected return is fixed at 1 no matter what she does. The "
                    "extreme cases are the all-ones partition (injective calls, variance 1) "
                    "and the single-part partition (constant call, variance 0, i.e. exactly "
                    "one hit with certainty)."
                ),
                "pseudocode": (
                    "ALGORITHM CollisionVariance(g)\n"
                    "INPUT   g[0..u-1] : calling strategy\n"
                    "OUTPUT  D         : collision profile, #{(i,j) : g[i] != g[j]}\n"
                    "        var       : exact variance of the hit count\n"
                    "\n"
                    "1  u <- length(g)\n"
                    "2  counts <- empty map\n"
                    "3  for i <- 0 to u-1 do                       // O(u) tally of fibres\n"
                    "4        counts[g[i]] <- counts[g[i]] + 1\n"
                    "5  same <- SUM over m in values(counts) of m*m // ordered pairs sharing a call\n"
                    "6  D <- u*u - same\n"
                    "7  require u >= 2\n"
                    "8  var <- D / (u * (u - 1))                    // exact rational\n"
                    "9  ASSERT 0 <= var <= 1\n"
                    "10 return (D, var)\n"
                    "\n"
                    "ALGORITHM AchievableRiskProfiles(u)\n"
                    "1  for each integer partition m_1 + ... + m_r = u do\n"
                    "2        D <- u*u - SUM_t m_t^2\n"
                    "3        emit (partition, D, D / (u*(u-1)))\n"
                    "4  // the mean is exactly 1 in every row; only the risk moves"
                ),
                "code": read("assets/alg_collision.py"),
            },
            {
                "name": "Stagewise Feedback Valuation by Collapsed Backward Recursion",
                "description": (
                    "Values the sequential game in which each card is revealed immediately "
                    "after being called. The state is the set S of still-unseen cards, and the "
                    "value obeys a recursion over subsets that would naively require one "
                    "evaluation per subset. Admissibility — never naming a card already seen — "
                    "forces exactly one of the |S| equally likely cards to be the called one, "
                    "so the stage payoff depends on S only through |S|, and the whole "
                    "set-indexed recursion collapses to a scalar iteration costing O(u) exact "
                    "rational operations and O(1) space. Two instantiations bracket the entire "
                    "theory of what information is worth. With hit = 1 and miss = 0 the "
                    "iteration is V(m) = 1/m + V(m-1), giving the harmonic number H_u, which "
                    "diverges: feedback is worth H_u - 1 extra correct calls, an unbounded "
                    "amount. With the stagewise fair schedule hit(m) = m - 1 and miss(m) = -1 "
                    "every stage contributes exactly zero, so V(u) = 0 identically. The module "
                    "also carries the memoised set-indexed recursion (O(2^u) states) as an "
                    "independent check that the collapse is legitimate and that the value is "
                    "genuinely strategy-free."
                ),
                "pseudocode": (
                    "ALGORITHM FeedbackValue(u, hit, miss)\n"
                    "INPUT   u          : number of unresolved cards\n"
                    "        hit, miss  : payoff schedules, functions of the live-set size\n"
                    "OUTPUT  V          : exact value of the feedback game, for EVERY\n"
                    "                     admissible strategy\n"
                    "\n"
                    "1  V <- 0\n"
                    "2  for m <- 1 to u do\n"
                    "3        // with m cards live, exactly one of them is the called card,\n"
                    "4        // so the stage pays miss(m) on all m branches plus the\n"
                    "5        // hit-minus-miss correction on the single winning branch\n"
                    "6        stage <- ( m * miss(m) + hit(m) - miss(m) ) / m\n"
                    "7        V <- V + stage\n"
                    "8  return V\n"
                    "\n"
                    "INSTANTIATION unit scoring:   hit(m) = 1,      miss(m) = 0\n"
                    "              stage = 1/m,  V = H_u            (unbounded)\n"
                    "INSTANTIATION fair odds:      hit(m) = m - 1,  miss(m) = -1\n"
                    "              stage = 0,    V = 0              (information-proof)\n"
                    "\n"
                    "ALGORITHM FeedbackValueByState(S, g, hit, miss)   // O(2^u) check\n"
                    "1  if S is empty then return 0\n"
                    "2  m <- |S| ;  call <- g(S) ;  total <- 0\n"
                    "3  for each a in S do\n"
                    "4        payoff <- hit(m) if call = a else miss(m)\n"
                    "5        total  <- total + payoff + FeedbackValueByState(S - a, g, hit, miss)\n"
                    "6  return total / m"
                ),
                "code": read("assets/alg_feedback.py"),
            },
            {
                "name": "Adaptive Betting-System Valuation by Backward Induction on the "
                        "History Tree",
                "description": (
                    "Values an arbitrary adaptive staking rule against a sequence of fair "
                    "plus-or-minus-one tosses. A system is any map from finite histories to a "
                    "rational stake: negative stakes switch sides, unbounded stakes are "
                    "permitted, and a stake of zero encodes quitting, so every stopping rule "
                    "is subsumed. Backward induction over the binary history tree evaluates "
                    "the expected net gain exactly in O(2^n) node visits — and the same "
                    "induction is the proof that the answer is identically zero, since the "
                    "stake enters the two children with opposite signs and cancels while both "
                    "subtrees are worth zero by hypothesis. This is the finite-horizon optional "
                    "stopping theorem with no measure theory: the sample space at each horizon "
                    "is finite. A companion routine returns the exact law of terminal wealth, "
                    "which makes the doubling system's ledger visible: mass 1 - 2^{-n} on a "
                    "gain of +1 and mass 2^{-n} on a loss of -(2^n - 1), a distribution whose "
                    "win probability tends to one while its mean stays pinned at zero."
                ),
                "pseudocode": (
                    "ALGORITHM ExpectedGain(stake, n, h)\n"
                    "INPUT   stake : arbitrary function from history to a rational stake\n"
                    "                (sign free, magnitude free, 0 encodes 'quit')\n"
                    "        n     : remaining horizon\n"
                    "        h     : history so far\n"
                    "OUTPUT  exact expected net gain over the remaining n tosses\n"
                    "\n"
                    "1  if n = 0 then return 0\n"
                    "2  s     <- stake(h)\n"
                    "3  win   <-  s + ExpectedGain(stake, n-1, h ++ [HEAD])\n"
                    "4  lose  <- -s + ExpectedGain(stake, n-1, h ++ [TAIL])\n"
                    "5  return (win + lose) / 2\n"
                    "6  // the two occurrences of s cancel and, by induction on n, both\n"
                    "7  // recursive calls are 0; hence the return value is identically 0\n"
                    "\n"
                    "ALGORITHM TerminalWealthLaw(stake, n)\n"
                    "1  law <- empty map ;  Walk(empty history, wealth 0, probability 1)\n"
                    "2  procedure Walk(h, wealth, prob)\n"
                    "3        if |h| = n then law[wealth] <- law[wealth] + prob ; return\n"
                    "4        s <- stake(h)\n"
                    "5        Walk(h ++ [HEAD], wealth + s, prob/2)\n"
                    "6        Walk(h ++ [TAIL], wealth - s, prob/2)\n"
                    "7  return law\n"
                    "\n"
                    "DOUBLING SYSTEM: stake(h) = 0 if h contains a head, else 2^{|h|}\n"
                    "  law = { +1 : 1 - 2^{-n},  -(2^n - 1) : 2^{-n} },  mean = 0"
                ),
                "code": read("assets/alg_betting.py"),
            },
        ],
        "visualizations": [
            {
                "name": "The Risk Frontier of a Fairly Priced Blind Prediction Game",
                "description": (
                    "Two panels making the mean/variance dichotomy visible at once. The left "
                    "panel shows the exact hit-count distributions of four calling strategies "
                    "on an unresolved block of six cards, obtained by enumerating all 720 "
                    "arrangements: an injective strategy, three pairs, two triples, and a "
                    "constant call. All four have mean exactly 1 — marked by a dashed vertical "
                    "line that every distribution straddles — yet they range from a broad "
                    "Poisson-like spread down to a single bar of height one at exactly one "
                    "hit. The right panel plots every achievable risk profile on the same "
                    "block, one point per fibre partition of six, as variance against the "
                    "normalised collision profile D(g)/(u(u-1)); the points land exactly on "
                    "the diagonal, which is the collision formula. Together the panels say "
                    "that a fairly priced game hands the player complete control of her risk "
                    "and none whatsoever of her return."
                ),
                "code": read("assets/viz_risk_frontier.py"),
            },
            {
                "name": "What Information Is Worth, and Why a High Win Rate Is Not an Edge",
                "description": (
                    "Two panels for the two hardest-to-believe consequences. The left panel "
                    "draws the feedback dichotomy on a logarithmic block-size axis: the "
                    "harmonic curve H_u climbing without bound for an informed player under "
                    "naive unit scoring, the flat line at 1 for a blind player, the shaded gap "
                    "between them labelled as the value of information, Oresme's staircase 1 + "
                    "n/2 <= H_{2^n} drawn as a lower envelope that certifies the divergence, "
                    "and — crucially — the dashed line at zero on which BOTH games sit once "
                    "the book is repriced at stagewise fair odds. The right panel is the "
                    "doubling paradox in one picture: the win probability 1 - 2^{-n} racing to "
                    "certainty, the expected net gain pinned at exactly zero, and on a "
                    "logarithmic twin axis the magnitude 2^n - 1 of the single catastrophic "
                    "outcome that finances the whole thing."
                ),
                "code": read("assets/viz_information_and_doubling.py"),
            },
        ],
        "interactive_demos": [
            {
                "title": "The Fair-Odds Deck Laboratory",
                "description": (
                    "A hands-on bench for the headline theorem. Sliders set the number of "
                    "resolved cards d, the size u of the unresolved block, and the payoffs w "
                    "on a hit and l on a miss; a row of clickable slots lets you design any "
                    "calling strategy at all, including deliberately foolish ones that name "
                    "the same card in every slot. The panel reports the expected total payoff "
                    "and the expected value of the unresolved block live, and delivers a "
                    "verdict: at w = l(1 - u) it certifies a fair book and states that the "
                    "game is worth exactly d for every strategy; anywhere else it names the "
                    "fair quote you have missed and reports the identical edge that every "
                    "strategy now earns — flagging the special case of naive unit scoring as "
                    "the counting anomaly of exactly +1. Below, the exact law of the hit count "
                    "is computed by enumerating all u! arrangements in the browser and drawn "
                    "as a histogram with the mean marked at 1, alongside the fibre partition "
                    "of your calls, the collision profile D(g), the closed-form variance "
                    "D(g)/(u(u-1)), and an independent brute-force check of both moments. The "
                    "intended discovery is visceral: the mean bar refuses to move while the "
                    "histogram's shape changes completely. Two collapsible sections give the "
                    "transposition-symmetry proof that the mean is always 1 and the pair-"
                    "counting proof of the collision formula."
                ),
                "html": read("assets/widget_deck_lab.html"),
            },
            {
                "title": "The Price of Information and the Martingale Trap",
                "description": (
                    "Two linked experiments on the same principle. The first lets you play the "
                    "unresolved block with feedback — each card turned face up after it is "
                    "called — and toggle between naive unit scoring and stagewise fair odds. "
                    "Under unit scoring the value climbs to the harmonic number H_u and the "
                    "stage-by-stage ledger shows exactly where each 1/m comes from, with a "
                    "chart of the growing gap over the blind player's flat score of 1; flip to "
                    "fair odds and both curves collapse onto zero, making the point that "
                    "information changes the price and not the edge. The second experiment "
                    "runs the doubling system: choose a horizon and read the exact ledger — "
                    "probability 1 - 2^{-n} of finishing one unit ahead, probability 2^{-n} of "
                    "losing 2^n - 1, contributions summing to exactly zero — then press run to "
                    "simulate two thousand sessions and watch the running average hug +1 for "
                    "long stretches before a single ruin drags it back to the dashed zero "
                    "line. Collapsible sections supply the recursion behind the harmonic "
                    "number, the repricing that annihilates it, and the two-line induction "
                    "showing that no adaptive staking rule whatsoever has an edge."
                ),
                "html": read("assets/widget_information_price.html"),
            },
        ],
        "interactive_layout": INTERACTIVE_LAYOUT,
        "lean_proofs": lean_bundle(),
        "future_directions": FUTURE_DIRECTIONS,
        "modules": {
            "demo": read("demo.py"),
            "exact_moment_enumeration": read("assets/alg_enumeration.py"),
            "collision_profile": read("assets/alg_collision.py"),
            "feedback_valuation": read("assets/alg_feedback.py"),
            "betting_system_valuation": read("assets/alg_betting.py"),
            "viz_risk_frontier": read("assets/viz_risk_frontier.py"),
            "viz_information_and_doubling": read("assets/viz_information_and_doubling.py"),
        },
        "lean_files": [
            f"Catalog/MachineLearning/KnownUnresolvedCards/{name}" for name in LEAN_ORDER
        ],
    }

    out: str = os.path.join(ROOT, "PACKAGE.json")
    with open(out, "w", encoding="utf-8") as fh:
        json.dump(package, fh, indent=2, ensure_ascii=False)
    print(f"wrote {out} ({os.path.getsize(out)} bytes)")


if __name__ == "__main__":
    main()


"""
Known versus Unresolved Cards — numerical demonstrations.

Every quantity below is computed in *exact rational arithmetic* (fractions.Fraction),
so the printed values are identities, not approximations.

The demonstrations, in order:

  1. The splitting theorem:  d resolved cards + any number of fair cards  =>  E = d.
  2. The master slot formula E[slot] = (w - l)/u + l, by brute-force enumeration
     of the symmetric group.
  3. Rigidity of fair odds: E[block] = 0  <=>  w = l * (1 - u).
  4. The counting anomaly: naive unit scoring shows a spurious edge of exactly +1.
  5. The collision formula  Var[hits] = D(g) / (u (u - 1)),  verified against
     brute force for many strategies.
  6. Feedback: unit scoring is worth H_u (unbounded); stagewise fair odds is
     worth exactly 0.
  7. No Free Lunch: expected +/-1 score = |T| exactly, over all 2^|X| targets.
  8. Betting systems: the doubling system wins with probability 1 - 2^-n and has
     expected net gain exactly 0.

Run with:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction
from itertools import permutations, product
from typing import Callable, Dict, Iterable, List, Sequence, Tuple

# ---------------------------------------------------------------------------
# Section 0.  Exact uniform expectation
# ---------------------------------------------------------------------------


def expectation(values: Iterable[Fraction]) -> Fraction:
    """Uniform expectation of a finite list of exact rationals."""
    vals: List[Fraction] = list(values)
    if not vals:
        raise ValueError("empty sample space")
    return sum(vals, Fraction(0)) / len(vals)


def variance(values: Iterable[Fraction]) -> Fraction:
    """Uniform variance of a finite list of exact rationals."""
    vals: List[Fraction] = list(values)
    mean: Fraction = expectation(vals)
    return expectation([v * v for v in vals]) - mean * mean


def harmonic(n: int) -> Fraction:
    """H_n = 1 + 1/2 + ... + 1/n, exactly.  H_0 = 0."""
    return sum((Fraction(1, j) for j in range(1, n + 1)), Fraction(0))


# ---------------------------------------------------------------------------
# Section 1.  The splitting theorem
# ---------------------------------------------------------------------------


def demo_splitting_theorem() -> None:
    """d resolved cards paying 1, plus fair cards, correlated arbitrarily.

    The sample space is a small finite set of 'states of the world'.  We build
    three fair cards that are *deliberately* correlated with one another (each
    is a nonlinear function of the state, and their sum is not constant), and
    check that the expected total is exactly the number of resolved cards.
    """
    print("=" * 74)
    print("1.  SPLITTING THEOREM:  E[total] = d, whatever the correlations")
    print("=" * 74)

    states: List[int] = list(range(6))
    d: int = 4

    # Three mutually correlated, individually fair cards.
    fair_cards: List[Callable[[int], Fraction]] = [
        lambda s: Fraction(s - 5, 2) if s < 3 else Fraction(8 - s, 2) - Fraction(1, 2),
        lambda s: Fraction(1) if s % 2 == 0 else Fraction(-1),
        lambda s: Fraction(5) if s == 0 else Fraction(-1),
    ]

    # Re-centre each card so it is exactly fair (mean zero).
    centred: List[Callable[[int], Fraction]] = []
    for p in fair_cards:
        mu: Fraction = expectation([p(s) for s in states])
        centred.append(lambda s, p=p, mu=mu: p(s) - mu)

    for idx, p in enumerate(centred):
        print(f"    fair card {idx}: mean = {expectation([p(s) for s in states])}")

    totals: List[Fraction] = [
        Fraction(d) + sum((p(s) for p in centred), Fraction(0)) for s in states
    ]
    print(f"    resolved cards d              = {d}")
    print(f"    per-state totals              = {[str(t) for t in totals]}")
    print(f"    E[total]                      = {expectation(totals)}   (expected {d})")
    assert expectation(totals) == Fraction(d)

    # No-edge corollary: drop the resolved cards entirely.
    only_fair: List[Fraction] = [
        sum((p(s) for p in centred), Fraction(0)) for s in states
    ]
    print(f"    E[portfolio of fair cards]    = {expectation(only_fair)}   (expected 0)")
    assert expectation(only_fair) == Fraction(0)
    print()


# ---------------------------------------------------------------------------
# Section 2-4.  The blind deck game
# ---------------------------------------------------------------------------


def hits(g: Sequence[int], sigma: Sequence[int]) -> int:
    """Number of slots i with sigma(i) == g(i)."""
    return sum(1 for i in range(len(g)) if sigma[i] == g[i])


def deck_score(g: Sequence[int], sigma: Sequence[int], w: Fraction, l: Fraction) -> Fraction:
    """Total score of strategy g against arrangement sigma: w per hit, l per miss."""
    h: int = hits(g, sigma)
    return w * h + l * (len(g) - h)


def demo_slot_formula_and_block_value() -> None:
    """Brute-force the symmetric group and confirm the master slot formula."""
    print("=" * 74)
    print("2.  MASTER SLOT FORMULA   E[slot] = (w - l)/u + l,  independent of g")
    print("=" * 74)

    for u in (3, 4, 5):
        perms: List[Tuple[int, ...]] = list(permutations(range(u)))
        w, l = Fraction(7), Fraction(-2)
        predicted_slot: Fraction = (w - l) / u + l
        # Every (slot, called card) pair gives the same expectation.
        seen = {
            expectation([w if sigma[i] == a else l for sigma in perms])
            for i in range(u)
            for a in range(u)
        }
        print(f"    u = {u}:  distinct slot expectations = {[str(x) for x in seen]}"
              f"   predicted {predicted_slot}")
        assert seen == {predicted_slot}

        # Block value over several very different strategies.
        strategies: Dict[str, List[int]] = {
            "identity     ": list(range(u)),
            "shift by one ": [(i + 1) % u for i in range(u)],
            "constant 0   ": [0] * u,
            "two blocks   ": [0 if i < u // 2 else 1 for i in range(u)],
        }
        predicted_block: Fraction = (w - l) + l * u
        for name, g in strategies.items():
            got: Fraction = expectation([deck_score(g, s, w, l) for s in perms])
            print(f"        strategy {name} E[block] = {got}   predicted {predicted_block}")
            assert got == predicted_block
    print()


def demo_rigidity_and_anomaly() -> None:
    """Fair odds are forced; unit scoring shows a spurious +1."""
    print("=" * 74)
    print("3.  RIGIDITY OF FAIR ODDS   E[block] = 0  <=>  w = l (1 - u)")
    print("=" * 74)

    u: int = 5
    perms: List[Tuple[int, ...]] = list(permutations(range(u)))
    g: List[int] = list(range(u))

    for (w, l) in [
        (Fraction(u - 1), Fraction(-1)),        # the fair quote
        (Fraction(u), Fraction(-1)),            # generous book
        (Fraction(u - 2), Fraction(-1)),        # stingy book
        (Fraction(2 * (u - 1)), Fraction(-2)),  # fair, rescaled
    ]:
        got: Fraction = expectation([deck_score(g, s, w, l) for s in perms])
        fair: bool = (w == l * (1 - u))
        print(f"    (w, l) = ({w}, {l}):  E[block] = {got:}   "
              f"fair-odds condition holds: {fair}")
        assert (got == 0) == fair

    print()
    print("=" * 74)
    print("4.  COUNTING ANOMALY:  naive unit scoring always shows exactly +1")
    print("=" * 74)
    for u in (2, 3, 4, 5, 6):
        perms = list(permutations(range(u)))
        for name, g in {
            "identity": list(range(u)),
            "constant": [0] * u,
            "lumpy   ": [i % 2 for i in range(u)],
        }.items():
            got = expectation([Fraction(hits(g, s)) for s in perms])
            print(f"    u = {u}, {name}: E[hits] = {got}")
            assert got == Fraction(1)
    print("    ... exactly 1 for every strategy and every block size.")
    print()


# ---------------------------------------------------------------------------
# Section 5.  The collision formula for the variance
# ---------------------------------------------------------------------------


def collision_profile(g: Sequence[int]) -> int:
    """D(g) = #{(i, j) : g(i) != g(j)}, the number of ordered slot pairs
    receiving distinct calls.  Computed in O(u) via  D = u^2 - sum m_t^2,
    where m_t are the multiplicities of the distinct called cards."""
    counts: Dict[int, int] = {}
    for a in g:
        counts[a] = counts.get(a, 0) + 1
    u: int = len(g)
    return u * u - sum(m * m for m in counts.values())


def demo_collision_formula() -> None:
    """Var[hits] = D(g) / (u (u-1)), checked against brute force."""
    print("=" * 74)
    print("5.  COLLISION FORMULA   Var[hits] = D(g) / (u (u - 1))")
    print("=" * 74)

    u: int = 5
    perms: List[Tuple[int, ...]] = list(permutations(range(u)))

    strategies: Dict[str, List[int]] = {
        "injective (identity)   ": [0, 1, 2, 3, 4],
        "one repeat             ": [0, 0, 2, 3, 4],
        "two repeats            ": [0, 0, 1, 1, 4],
        "three of a kind        ": [0, 0, 0, 3, 4],
        "four of a kind         ": [0, 0, 0, 0, 4],
        "constant               ": [0, 0, 0, 0, 0],
    }

    print(f"    block size u = {u}, so u(u-1) = {u * (u - 1)}")
    print(f"    {'strategy':<24}{'D(g)':>6}{'formula':>12}{'brute force':>14}")
    for name, g in strategies.items():
        d_g: int = collision_profile(g)
        formula: Fraction = Fraction(d_g, u * (u - 1))
        brute: Fraction = variance([Fraction(hits(g, s)) for s in perms])
        print(f"    {name:<24}{d_g:>6}{str(formula):>12}{str(brute):>14}")
        assert formula == brute
        # the mean is invariant regardless
        assert expectation([Fraction(hits(g, s)) for s in perms]) == 1

    print("    Same mean (always 1), variance running continuously from 0 to 1.")
    print()

    # Exhaustive check on u = 4: every one of the 4^4 = 256 strategies.
    u = 4
    perms = list(permutations(range(u)))
    checked: int = 0
    for g_tuple in product(range(u), repeat=u):
        g = list(g_tuple)
        assert variance([Fraction(hits(g, s)) for s in perms]) == Fraction(
            collision_profile(g), u * (u - 1)
        )
        checked += 1
    print(f"    Exhaustively verified for all {checked} strategies on u = {u}.")
    print()


# ---------------------------------------------------------------------------
# Section 6.  The feedback game
# ---------------------------------------------------------------------------


def feedback_value(
    m: int, hit: Callable[[int], Fraction], miss: Callable[[int], Fraction]
) -> Fraction:
    """Exact value of the feedback game with m live cards, for any admissible
    strategy.  The value depends on the live set only through its size, so the
    full recursion collapses to a scalar iteration costing O(m) operations:

        V(m) = [ m * miss(m) + hit(m) - miss(m) ] / m  +  V(m - 1),   V(0) = 0.
    """
    v: Fraction = Fraction(0)
    for k in range(1, m + 1):
        v += (k * miss(k) + hit(k) - miss(k)) / k
    return v


def feedback_value_bruteforce(
    live: Tuple[int, ...],
    strategy: Callable[[Tuple[int, ...]], int],
    hit: Callable[[int], Fraction],
    miss: Callable[[int], Fraction],
) -> Fraction:
    """Full set-indexed recursion, to check the collapsed iteration above."""
    if not live:
        return Fraction(0)
    m: int = len(live)
    call: int = strategy(live)
    total: Fraction = Fraction(0)
    for a in live:
        payoff: Fraction = hit(m) if call == a else miss(m)
        rest: Tuple[int, ...] = tuple(x for x in live if x != a)
        total += payoff + feedback_value_bruteforce(rest, strategy, hit, miss)
    return total / m


def demo_feedback() -> None:
    """Feedback is worth H_u under unit scoring, and 0 at stagewise fair odds."""
    print("=" * 74)
    print("6.  FEEDBACK:  unit scoring -> H_u (unbounded);  fair odds -> 0")
    print("=" * 74)

    unit_hit: Callable[[int], Fraction] = lambda m: Fraction(1)
    unit_miss: Callable[[int], Fraction] = lambda m: Fraction(0)
    fair_hit: Callable[[int], Fraction] = lambda m: Fraction(m - 1)
    fair_miss: Callable[[int], Fraction] = lambda m: Fraction(-1)

    # Two very different admissible strategies: smallest live card, largest live card.
    first: Callable[[Tuple[int, ...]], int] = lambda S: min(S)
    last: Callable[[Tuple[int, ...]], int] = lambda S: max(S)

    print(f"    {'u':>3}{'H_u':>12}{'unit (brute)':>16}{'fair (brute)':>16}{'blind':>8}")
    for u in range(1, 8):
        live: Tuple[int, ...] = tuple(range(u))
        h: Fraction = harmonic(u)
        collapsed: Fraction = feedback_value(u, unit_hit, unit_miss)
        assert collapsed == h
        brute_unit: Fraction = (
            feedback_value_bruteforce(live, first, unit_hit, unit_miss) if u <= 7 else h
        )
        brute_fair: Fraction = (
            feedback_value_bruteforce(live, last, fair_hit, fair_miss) if u <= 7 else Fraction(0)
        )
        assert brute_unit == h
        assert brute_fair == Fraction(0)
        assert feedback_value(u, fair_hit, fair_miss) == Fraction(0)
        print(f"    {u:>3}{str(h):>12}{str(brute_unit):>16}{str(brute_fair):>16}{1:>8}")

    print()
    print("    Oresme's bound 1 + n/2 <= H_{2^n}, so the unit-scoring edge is unbounded:")
    for n in range(0, 12):
        lhs: Fraction = 1 + Fraction(n, 2)
        rhs: Fraction = harmonic(2 ** n)
        assert lhs <= rhs
        print(f"        n = {n:>2}:  1 + n/2 = {str(lhs):>6}  <=  H_{{{2**n:>4}}} "
              f"= {float(rhs):.6f}")
    print("    ... while a blind strategy scores exactly 1, forever.")
    print()


# ---------------------------------------------------------------------------
# Section 7.  No Free Lunch
# ---------------------------------------------------------------------------


def demo_no_free_lunch() -> None:
    """Expected +/-1 score of a blind consistent learner is exactly |T|."""
    print("=" * 74)
    print("7.  NO FREE LUNCH:  E[+/-1 score] = |T| exactly, over all 2^|X| targets")
    print("=" * 74)

    n_points: int = 10
    domain: List[int] = list(range(n_points))

    def run(train_size: int, off_sample_rule: Callable[[Tuple[bool, ...], int], bool]) -> None:
        train: List[int] = domain[:train_size]
        train_set = set(train)
        scores: List[Fraction] = []
        correct: List[Fraction] = []
        for f in product([False, True], repeat=n_points):
            # A blind, consistent learner: copy training labels, and use an
            # arbitrary rule -- depending ONLY on the training labels -- elsewhere.
            train_labels: Tuple[bool, ...] = tuple(f[y] for y in train)
            s: Fraction = Fraction(0)
            c: Fraction = Fraction(0)
            for y in domain:
                pred: bool = f[y] if y in train_set else off_sample_rule(train_labels, y)
                s += Fraction(1) if pred == f[y] else Fraction(-1)
                c += Fraction(1) if pred == f[y] else Fraction(0)
            scores.append(s)
            correct.append(c)
        got: Fraction = expectation(scores)
        acc: Fraction = expectation(correct)
        predicted_acc: Fraction = Fraction(train_size + n_points, 2)
        print(f"    |T| = {train_size:>2}:  E[+/-1 score] = {got}  (predicted {train_size});"
              f"  E[#correct] = {acc}  (predicted {predicted_acc})")
        assert got == Fraction(train_size)
        assert acc == predicted_acc

    # Three genuinely different off-sample rules; all give the same answer.
    always_false: Callable[[Tuple[bool, ...], int], bool] = lambda tl, y: False
    majority: Callable[[Tuple[bool, ...], int], bool] = (
        lambda tl, y: sum(tl) * 2 > len(tl)
    )
    parity: Callable[[Tuple[bool, ...], int], bool] = (
        lambda tl, y: (sum(tl) + y) % 2 == 0
    )

    for rule_name, rule in [
        ("constant-false", always_false),
        ("majority vote ", majority),
        ("parity hash   ", parity),
    ]:
        print(f"    off-sample rule: {rule_name}")
        for t in (0, 3, 6, 10):
            run(t, rule)

    print()
    print("    Sharpness: a 'learner' allowed to peek off-sample scores |X| with T empty.")
    peeker_score: Fraction = expectation(
        [Fraction(n_points) for _ in product([False, True], repeat=n_points)]
    )
    print(f"        E[score of the peeking learner] = {peeker_score}  (vs |T| = 0)")
    print()


# ---------------------------------------------------------------------------
# Section 8.  Betting systems
# ---------------------------------------------------------------------------


def expected_gain(stake: Callable[[Tuple[bool, ...]], Fraction], n: int,
                  history: Tuple[bool, ...] = ()) -> Fraction:
    """Expected net gain of an arbitrary adaptive staking rule over n fair
    +/-1 tosses.  Stake 0 encodes 'quit', so optional stopping is included."""
    if n == 0:
        return Fraction(0)
    s: Fraction = stake(history)
    win: Fraction = s + expected_gain(stake, n - 1, history + (True,))
    lose: Fraction = -s + expected_gain(stake, n - 1, history + (False,))
    return (win + lose) / 2


def demo_betting_systems() -> None:
    """No adaptive system has an edge; the doubling system is the sharp example."""
    print("=" * 74)
    print("8.  BETTING SYSTEMS:  every adaptive rule has expected gain exactly 0")
    print("=" * 74)

    systems: Dict[str, Callable[[Tuple[bool, ...]], Fraction]] = {
        "flat 1                     ": lambda h: Fraction(1),
        "doubling after losses      ": lambda h: Fraction(0)
        if any(h)
        else Fraction(2 ** len(h)),
        "quit after first win       ": lambda h: Fraction(0) if any(h) else Fraction(3),
        "switch sides on every toss ": lambda h: Fraction((-1) ** len(h)) * Fraction(5),
        "wild history-dependent     ": lambda h: Fraction(sum(1 for b in h if b) * 7 - 3),
    }
    for name, stake in systems.items():
        for n in (1, 4, 8):
            g: Fraction = expected_gain(stake, n)
            assert g == Fraction(0)
        print(f"    {name}: expected gain = 0 at horizons 1, 4, 8")

    print()
    print("    The doubling paradox, exactly:")
    print(f"    {'n':>3}{'P[win]':>16}{'gain on win':>13}{'loss on ruin':>15}{'E[gain]':>10}")
    for n in range(1, 13):
        p_win: Fraction = 1 - Fraction(1, 2 ** n)
        loss: Fraction = -(Fraction(2 ** n) - 1)
        e_gain: Fraction = p_win * 1 + Fraction(1, 2 ** n) * loss
        assert e_gain == Fraction(0)
        # geometric identity 2^k - (2^k - 1) = 1
        assert Fraction(2 ** n) - sum(Fraction(2 ** j) for j in range(n)) == 1
        print(f"    {n:>3}{float(p_win):>16.9f}{'+1':>13}{str(loss):>15}{str(e_gain):>10}")
    print("    A high win rate is not an edge: the rare loss exactly pays for it.")
    print()


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------


def main() -> None:
    print()
    print("#" * 74)
    print("#  KNOWN VERSUS UNRESOLVED CARDS — exact rational demonstrations")
    print("#  Expected payoff is exactly the number of cards known with certainty.")
    print("#" * 74)
    print()
    demo_splitting_theorem()
    demo_slot_formula_and_block_value()
    demo_rigidity_and_anomaly()
    demo_collision_formula()
    demo_feedback()
    demo_no_free_lunch()
    demo_betting_systems()
    print("=" * 74)
    print("All identities verified exactly.  No approximation was used anywhere.")
    print("=" * 74)


if __name__ == "__main__":
    main()
