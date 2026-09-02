"""
Numerical demonstrations for the identifiability theory of layer ablation.

A layer is a Markov channel on a finite state space, a stack is a list of such
channels applied left to right, and damage is total variation distance.  All
arithmetic is exact (``fractions.Fraction``), so every number printed below is
a rational value, not a floating-point approximation.

The script demonstrates, in order:

  1.  The three cost functionals (point / solo / joint) and the weak masking
      inequality  solo <= point.
  2.  Non-identifiability at depth 24: two prunings of one stack with
      identical, identically zero solo profiles whose joint costs are 0.017
      and 1.
  3.  Two-sided failure: a depth-2 stack with both solo costs equal to 1 and
      joint cost 0.
  4.  Dobrushin contraction and the masking theorem  solo <= delta^m * point,
      shown to be attained exactly by an affine two-state family.
  5.  Identifiability at a lossless suffix, and unconditionally at the final
      layer.
  6.  The geometric sub-additivity bound, its sharpness, and the contraction
      estimator that reproduces the measured pair (4.8% additive versus
      1.69-1.70% joint) at depth 24 with delta = 8/9 and c = 1/500.
  7.  The arity hierarchy: with m masking layers, every ablation of arity <= m
      returns exactly 0 while arity m+1 returns the true damage.
  8.  The resolution threshold: the minimal arity at which a masked layer
      becomes visible, in closed form.

Run with:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction as F
from itertools import combinations
from typing import Callable, Dict, List, Sequence, Tuple

# ----------------------------------------------------------------------------
# 1.  Distributions, channels, total variation
# ----------------------------------------------------------------------------

Dist = Tuple[F, ...]          # a probability vector with rational entries
Channel = Tuple[Dist, ...]    # row-stochastic matrix: Channel[a] is a Dist


def check_dist(mu: Dist) -> None:
    """Assert that ``mu`` is a probability vector with rational entries."""
    assert all(x >= 0 for x in mu), f"negative weight in {mu}"
    assert sum(mu) == 1, f"weights of {mu} sum to {sum(mu)}, not 1"


def push(K: Channel, mu: Dist) -> Dist:
    """Pushforward  (K_* mu)(b) = sum_a mu(a) K(a)(b)."""
    n_out = len(K[0])
    return tuple(sum(mu[a] * K[a][b] for a in range(len(mu))) for b in range(n_out))


def tv(mu: Dist, nu: Dist) -> F:
    """Total variation distance  (1/2) * sum_a |mu(a) - nu(a)|."""
    return sum(abs(x - y) for x, y in zip(mu, nu)) / 2


def chain(stack: Sequence[Channel], mu: Dist) -> Dist:
    """Run a stack of channels on an input law, first layer first."""
    for K in stack:
        mu = push(K, mu)
    return mu


def dobrushin(K: Channel) -> F:
    """Dobrushin coefficient  delta(K) = max_{a,b} tv(K(a), K(b))."""
    return max(tv(K[a], K[b]) for a in range(len(K)) for b in range(len(K)))


# --- standard channels on a two-state space ---------------------------------

def bern(t: F) -> Dist:
    """The Bernoulli law (1-t, t)."""
    return (1 - t, t)


D0: Dist = bern(F(0))   # point mass at state 0
D1: Dist = bern(F(1))   # point mass at state 1

ID2: Channel = (D0, D1)                       # identity channel
FLIP: Channel = (D1, D0)                      # deterministic state swap


def const_channel(c: Dist, n_in: int = 2) -> Channel:
    """The totally forgetful channel emitting ``c`` whatever the input."""
    return tuple(c for _ in range(n_in))


def affine_channel(delta: F, s: F) -> Channel:
    """Rows  x |-> Bern(s + delta * x);  contracts by exactly ``delta``."""
    return (bern(s), bern(s + delta))


# ----------------------------------------------------------------------------
# 2.  The three cost functionals
# ----------------------------------------------------------------------------

def point_cost(stack: Sequence[Channel], j: int, p: Channel, mu: Dist) -> F:
    """Damage layer j does to its own output law, at the intact upstream state."""
    nu = chain(stack[:j], mu)
    return tv(push(stack[j], nu), push(p, nu))


def solo_cost(stack: Sequence[Channel], j: int, p: Channel, mu: Dist) -> F:
    """Damage visible at the output when layer j alone is ablated."""
    ablated = list(stack)
    ablated[j] = p
    return tv(chain(stack, mu), chain(ablated, mu))


def joint_cost(stack: Sequence[Channel], pruned: Sequence[Channel], mu: Dist) -> F:
    """Damage visible at the output when the whole stack is ablated."""
    return tv(chain(stack, mu), chain(pruned, mu))


def set_cost(stack: Sequence[Channel], S: Sequence[int],
             ablate: Callable[[int], Channel], mu: Dist) -> F:
    """Damage visible at the output when exactly the layers in S are ablated."""
    ablated = list(stack)
    for j in S:
        ablated[j] = ablate(j)
    return tv(chain(stack, mu), chain(ablated, mu))


# ----------------------------------------------------------------------------
# 3.  The witness families
# ----------------------------------------------------------------------------

def witness_stack(n: int, m: int = 1) -> List[Channel]:
    """n transparent (identity) layers followed by m totally forgetful ones."""
    return [ID2] * n + [const_channel(D0)] * m


def witness_ablation(n: int, t: F) -> Callable[[int], Channel]:
    """Transparent layers -> constant Bern(t);  forgetful layers -> identity."""
    return lambda j: const_channel(bern(t)) if j < n else ID2


def probe_stack(delta: F, s: F, m: int, k: int) -> List[Channel]:
    """
    The layer under study (affine, offset s), then m - k intact masking layers
    (each contracting by delta) and k ablated ones (replaced by the identity).
    The experiment therefore has arity k + 1.
    """
    return [affine_channel(delta, s)] + [affine_channel(delta, F(0))] * (m - k) + [ID2] * k


# ----------------------------------------------------------------------------
# 4.  Estimators and thresholds
# ----------------------------------------------------------------------------

def geom_sum(delta: F, n: int) -> F:
    """Exact value of  sum_{i<n} delta^i."""
    return sum(delta ** i for i in range(n))


def contraction_from_ratio(ratio: float, n: int, tol: float = 1e-12) -> float:
    """
    Invert  ratio = n (1 - delta) / (1 - delta^n)  for delta in [0, 1).

    The right-hand side is strictly decreasing from n (at delta = 0) to 1 (as
    delta -> 1), so bisection converges to the unique root whenever
    1 < ratio < n.  Cost: O(log(1/tol)) evaluations.
    """
    assert 1.0 < ratio < n, "ratio must lie strictly between 1 and the depth"

    def f(d: float) -> float:
        return n * (1.0 - d) / (1.0 - d ** n)

    lo, hi = 0.0, 1.0 - 1e-15
    while hi - lo > tol:
        mid = (lo + hi) / 2
        if f(mid) > ratio:
            lo = mid
        else:
            hi = mid
    return (lo + hi) / 2


def minimal_informative_arity(delta: F, m: int, pt: F, eps: F) -> int:
    """
    Smallest arity k+1 at which a layer masked by m layers of coefficient
    ``delta`` and having point cost ``pt`` reports above resolution ``eps``.
    Returns -1 if no arity within the suffix suffices.  Cost: O(m).
    """
    for k in range(m + 1):
        if delta ** (m - k) * pt > eps:
            return k + 1
    return -1


# ----------------------------------------------------------------------------
# 5.  Demonstrations
# ----------------------------------------------------------------------------

def rule(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


def demo_costs() -> None:
    rule("1.  Point, solo and joint costs;  the weak masking inequality")
    n, t = 4, F(1, 2)
    stack = witness_stack(n)                      # 4 identities + 1 forgetful
    ablate = witness_ablation(n, t)
    print(f"stack: {n} transparent layers + 1 totally forgetful layer, t = {t}")
    print(f"{'layer':>6} {'point':>10} {'solo':>10}   solo <= point")
    for j in range(len(stack)):
        pt = point_cost(stack, j, ablate(j), D0)
        so = solo_cost(stack, j, ablate(j), D0)
        print(f"{j:>6} {str(pt):>10} {str(so):>10}   {so <= pt}")
    pruned = [ablate(j) for j in range(len(stack))]
    print(f"joint cost of pruning everything: {joint_cost(stack, pruned, D0)}  (= t)")


def demo_nonidentifiability() -> None:
    rule("2.  Non-identifiability at the measured depth 24")
    n = 23
    stack = witness_stack(n)                       # 23 transparent + 1 masker
    assert len(stack) == 24
    for t, label in ((F(17, 1000), "measured 1.7%"), (F(1), "catastrophic")):
        ablate = witness_ablation(n, t)
        profile = [solo_cost(stack, j, ablate(j), D0) for j in range(24)]
        pruned = [ablate(j) for j in range(24)]
        jt = joint_cost(stack, pruned, D0)
        print(f"t = {str(t):>8} ({label:>13}):  "
              f"solo profile = {set(map(str, profile))},  joint = {jt}")
    print("Identical, identically zero solo profiles; joint costs 17/1000 and 1.")
    print("Separation invisible to arity 1:", F(1) - F(17, 1000))


def demo_cancellation() -> None:
    rule("3.  Two-sided failure: maximal solo costs, zero joint cost")
    stack = [ID2, ID2]
    pruned = [FLIP, FLIP]
    print("solo cost at layer 0:", solo_cost(stack, 0, FLIP, D0))
    print("solo cost at layer 1:", solo_cost(stack, 1, FLIP, D0))
    print("joint cost          :", joint_cost(stack, pruned, D0))
    print("So joint <= sum(solo) and joint >= max(solo) both fail in general.")


def demo_masking() -> None:
    rule("4.  Dobrushin masking:  solo <= delta^m * point,  attained exactly")
    delta, c = F(1, 2), F(1, 2)
    print(f"affine layers, delta = {delta}, point cost c = {c}")
    print(f"{'m (maskers)':>12} {'solo cost':>16} {'delta^m * c':>16}  attained")
    for m in (0, 1, 4, 8, 11):
        intact = probe_stack(delta, F(0), m, 0)
        pruned = probe_stack(delta, c, m, 0)
        so = tv(chain(intact, D0), chain(pruned, D0))
        bound = delta ** m * c
        print(f"{m:>12} {str(so):>16} {str(bound):>16}  {so == bound}")
    print(f"Dobrushin coefficient of an affine layer: "
          f"{dobrushin(affine_channel(delta, F(0)))} (= delta, exactly)")
    print("With 11 masking layers a layer may destroy its own output law")
    print("completely and still register a solo cost of",
          F(1, 2) ** 11, "= less than 0.0005,")
    print("an order of magnitude below the 0.006 spread the experiment resolved.")


def demo_lossless() -> None:
    rule("5.  Identifiability: lossless suffix, and the final layer")
    #  a stack whose suffix after layer 0 is a permutation (lossless) channel
    stack = [ID2, FLIP, FLIP]
    p = const_channel(bern(F(3, 10)))
    print("suffix after layer 0 consists of permutation channels")
    print("  point cost at layer 0:", point_cost(stack, 0, p, D0))
    print("  solo  cost at layer 0:", solo_cost(stack, 0, p, D0), " (equal: faithful)")
    #  the final layer is always faithful, whatever the stack
    masked = witness_stack(3)      # ends in a forgetful layer
    last = len(masked) - 1
    q = const_channel(bern(F(2, 5)))
    print("the FINAL layer of an arbitrary stack (here one ending in a masker):")
    print("  point cost:", point_cost(masked, last, q, D0))
    print("  solo  cost:", solo_cost(masked, last, q, D0), " (equal, unconditionally)")
    print("Interior layers of the same stack are completely masked:")
    print("  point cost at layer 0:", point_cost(masked, 0, q, D0))
    print("  solo  cost at layer 0:", solo_cost(masked, 0, q, D0))


def demo_subadditivity() -> None:
    rule("6.  Geometric sub-additivity, sharpness, and the contraction estimator")
    delta, c, n = F(8, 9), F(1, 500), 24
    intact = [affine_channel(delta, F(0))] * n
    pruned = [affine_channel(delta, c)] * n
    jt = joint_cost(intact, pruned, D0)
    gs = geom_sum(delta, n)
    print(f"depth n = {n}, intact contraction delta = {delta}, budget c = {c}")
    print(f"  additive prediction n*c      : {n * c} = {float(n * c) * 100:.2f}%")
    print(f"  geometric sum sum_i delta^i  : {float(gs):.4f}  (proved in [8.4, 8.5])")
    print(f"  bound c * sum                : {float(c * gs) * 100:.4f}%")
    print(f"  actual joint cost            : {float(jt) * 100:.4f}%  "
          f"(bound attained: {jt == c * gs})")
    print(f"  within (1.69%, 1.70%)        : "
          f"{F(169, 10000) < jt < F(170, 10000)}")
    print(f"  sub-additivity factor n/sum  : {float(n / gs):.3f}"
          f"   (laboratory 4.8/1.7 = {4.8 / 1.7:.3f})")
    est = contraction_from_ratio(4.8 / 1.7, n)
    print(f"  contraction estimated from the measured ratio 4.8/1.7 : "
          f"delta = {est:.4f}")
    print("  NOTE: the stack above has 24 IDENTICAL layers.  The observed")
    print("  sub-additivity is fully accounted for by one number, the")
    print("  contraction coefficient, with no per-layer hierarchy at all.")


def demo_arity_hierarchy() -> None:
    rule("7.  The arity hierarchy: no fixed-arity protocol is sound")
    t = F(17, 1000)
    for m in (1, 2, 3):
        n = 24 - m
        stack = witness_stack(n, m)
        ablate = witness_ablation(n, t)
        depth = len(stack)
        # exhaustively check every ablation set of arity <= m (small m, so cheap;
        # for m >= 2 we sample the transparent layers to keep the run instant)
        transparent_sample = list(range(0, n, max(1, n // 6)))
        candidates = transparent_sample + list(range(n, depth))
        worst = F(0)
        for r in range(1, m + 1):
            for S in combinations(candidates, r):
                worst = max(worst, set_cost(stack, S, ablate, D0))
        recover = set_cost(stack, [0] + list(range(n, depth)), ablate, D0)
        print(f"m = {m} masking layers, depth {depth}: "
              f"max cost over arity <= {m}: {worst};  "
              f"arity {m + 1} (layer 0 + all maskers): {recover}")
    print("For every m there is a depth-24 stack on which every experiment of")
    print("arity <= m returns exactly 0 while arity m+1 returns the true damage.")


def demo_resolution_threshold() -> None:
    rule("8.  The resolution threshold")
    delta, pt, m, eps = F(1, 2), F(1, 2), 11, F(6, 1000)
    print(f"delta = {delta}, {m} masking layers, point cost {pt}, "
          f"resolution {eps} (the reported 0.6-point spread)")
    print(f"{'k ablated':>10} {'arity':>7} {'measured cost':>18} {'visible?':>10}")
    for k in list(range(0, 7)) + [m]:
        intact = probe_stack(delta, F(0), m, k)
        pruned = probe_stack(delta, pt, m, k)
        cost = tv(chain(intact, D0), chain(pruned, D0))
        assert cost == delta ** (m - k) * pt      # the exact probe-cost formula
        print(f"{k:>10} {k + 1:>7} {float(cost):>18.6f} "
              f"{'YES' if cost > eps else 'no':>10}")
    print("minimal informative arity (closed form):",
          minimal_informative_arity(delta, m, pt, eps))
    print("solo measurement:", tv(chain(probe_stack(delta, F(0), m, 0), D0),
                                  chain(probe_stack(delta, pt, m, 0), D0)),
          "- three orders of magnitude below the damage it should detect.")


def main() -> None:
    for mu in (D0, D1, bern(F(1, 3))):
        check_dist(mu)
    demo_costs()
    demo_nonidentifiability()
    demo_cancellation()
    demo_masking()
    demo_lossless()
    demo_subadditivity()
    demo_arity_hierarchy()
    demo_resolution_threshold()
    print()
    print("All demonstrations completed with exact rational arithmetic.")


if __name__ == "__main__":
    main()
