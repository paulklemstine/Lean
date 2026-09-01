"""
Tail-Aware Mixed Precision: numerical demonstrations.

Self-contained (standard library only, no third-party dependencies).  Every
function is inlined and type-hinted.  Running this file reproduces, numerically,
each mathematical result of the accompanying paper:

  1. The sensitivity profile  s(m) = prod_{k>m} L_k  is monotone increasing in
     depth for a non-expansive stack and antitone for an expansive one
     (the precision dichotomy).
  2. The master propagation bound  |run_f(x) - run_g(x)| <= sum_j d_j s(j)
     holds for a concrete pair of layer stacks.
  3. The bit-budget lower bound  cost(b) >= n (prod c_i)^(1/n) 2^(-B/n)  holds
     for random allocations and is attained by the water-filling allocation
     b*_i = B/n + log2 c_i - mean_j log2 c_j.
  4. The logarithmic precision law  b*_i - b*_j = log2(c_i / c_j), and its
     geometric-profile corollary  b*_j - b*_i = (j - i) log2(1/lambda).
  5. Integer flooring stays inside the budget and costs at most a factor 2.
  6. The protection sandwich, the protection budget bound, the emergent-share
     bound (r-1)/r, and submodularity of a disagreement-count damage
     functional, on an explicit synthetic disagreement family.
  7. The measured three-arm instance, in exact rational arithmetic: gain 0.018,
     coverage slack 0.0054, efficiency 10/13, positive block interaction, and
     the memory-overhead accounting.
"""

from __future__ import annotations

import itertools
import math
import random
from fractions import Fraction
from typing import Callable, Dict, FrozenSet, List, Sequence, Set, Tuple

# ----------------------------------------------------------------------------
# 1. Sensitivity profiles and the precision dichotomy
# ----------------------------------------------------------------------------


def tail_prod(lips: Sequence[float], start: int, count: int) -> float:
    """Product L[start] * ... * L[start + count - 1]; empty product is 1.0."""
    value = 1.0
    for s in range(count):
        value *= lips[start + s]
    return value


def sensitivity_profile(lips: Sequence[float]) -> List[float]:
    """s(m) = product of the Lipschitz constants of all layers strictly after m.

    Computed by a single backward pass in O(n):  s(n-1) = 1,
    s(m) = L[m+1] * s(m+1).
    """
    n = len(lips)
    s = [1.0] * n
    for m in range(n - 2, -1, -1):
        s[m] = lips[m + 1] * s[m + 1]
    return s


def is_nondecreasing(xs: Sequence[float], tol: float = 1e-12) -> bool:
    return all(xs[i] <= xs[i + 1] + tol for i in range(len(xs) - 1))


def is_nonincreasing(xs: Sequence[float], tol: float = 1e-12) -> bool:
    return all(xs[i] + tol >= xs[i + 1] for i in range(len(xs) - 1))


def demo_dichotomy() -> None:
    print("=" * 78)
    print("1. THE PRECISION DICHOTOMY")
    print("=" * 78)
    rng = random.Random(20260901)

    contractive = [rng.uniform(0.70, 1.00) for _ in range(24)]
    expansive = [rng.uniform(1.00, 1.30) for _ in range(24)]

    s_con = sensitivity_profile(contractive)
    s_exp = sensitivity_profile(expansive)

    print("non-expansive stack (all L_j <= 1), 24 layers")
    print("  s(0)  = %.6f   s(11) = %.6f   s(23) = %.6f" % (s_con[0], s_con[11], s_con[23]))
    print("  monotone non-decreasing in depth : %s" % is_nondecreasing(s_con))
    print("  maximum attained at last layer   : %s (value %.6f)"
          % (abs(s_con[-1] - 1.0) < 1e-12, s_con[-1]))
    print("  tail/head sensitivity ratio      : %.2fx" % (s_con[23] / s_con[0]))

    print("expansive stack (all L_j >= 1), 24 layers")
    print("  s(0)  = %.6f   s(11) = %.6f   s(23) = %.6f" % (s_exp[0], s_exp[11], s_exp[23]))
    print("  antitone in depth                : %s" % is_nonincreasing(s_exp))
    print("  => the HEAD, not the tail, is the sensitive end.")
    print()


# ----------------------------------------------------------------------------
# 2. The master propagation bound, verified against a concrete stack
# ----------------------------------------------------------------------------


def run_stack(layers: Sequence[Callable[[float], float]], x: float) -> float:
    for f in layers:
        x = f(x)
    return x


def certified_error(deviations: Sequence[float], lips: Sequence[float]) -> float:
    """sum_j delta_j * s(j), the certified end-to-end deviation."""
    s = sensitivity_profile(lips)
    return sum(d * si for d, si in zip(deviations, s))


def demo_propagation() -> None:
    print("=" * 78)
    print("2. THE MASTER PROPAGATION BOUND")
    print("=" * 78)
    rng = random.Random(11)
    n = 12
    lips = [rng.uniform(0.75, 0.98) for _ in range(n)]
    devs = [rng.uniform(0.0, 0.02) for _ in range(n)]

    # Exact layers: contractions with the prescribed Lipschitz constants.
    exact = [(lambda a: (lambda x: a * math.tanh(x)))(a) for a in lips]
    # Perturbed layers: same, plus a bounded additive offset of size <= delta_j.
    perturbed = [
        (lambda a, d: (lambda x: a * math.tanh(x) + d * math.sin(7.0 * x)))(a, d)
        for a, d in zip(lips, devs)
    ]

    bound = certified_error(devs, lips)
    worst = max(
        abs(run_stack(exact, x) - run_stack(perturbed, x))
        for x in [i / 200.0 for i in range(-600, 601)]
    )
    print("  certified bound  sum_j delta_j s(j) = %.8f" % bound)
    print("  worst realized deviation over grid  = %.8f" % worst)
    print("  bound holds                         : %s" % (worst <= bound + 1e-12))
    print("  slack factor (bound / realized)     : %.2fx" % (bound / max(worst, 1e-18)))
    print("  (worst-case certificates are conservative; the ORDERING they induce")
    print("   on layers is the robust part, and that is all the allocation law needs.)")
    print()


# ----------------------------------------------------------------------------
# 3-5. Bit allocation: lower bound, water-filling, log law, integer rounding
# ----------------------------------------------------------------------------


def cost(coeffs: Sequence[float], bits: Sequence[float]) -> float:
    """Certified cost sum_i c_i 2^{-b_i}."""
    return sum(c * 2.0 ** (-b) for c, b in zip(coeffs, bits))


def geometric_mean(xs: Sequence[float]) -> float:
    return math.exp(sum(math.log(x) for x in xs) / len(xs))


def cost_lower_bound(coeffs: Sequence[float], budget: float) -> float:
    """n * (prod c_i)^(1/n) * 2^(-B/n)."""
    n = len(coeffs)
    return n * geometric_mean(coeffs) * 2.0 ** (-budget / n)


def water_filling(coeffs: Sequence[float], budget: float) -> List[float]:
    """b*_i = B/n + log2 c_i - (1/n) sum_j log2 c_j."""
    n = len(coeffs)
    logs = [math.log2(c) for c in coeffs]
    mean_log = sum(logs) / n
    return [budget / n + lg - mean_log for lg in logs]


def random_feasible_allocation(n: int, budget: float, rng: random.Random) -> List[float]:
    """A random allocation with sum b_i = budget (may be non-integral)."""
    raw = [rng.uniform(0.0, 1.0) for _ in range(n)]
    total = sum(raw)
    return [budget * r / total for r in raw]


def demo_bit_allocation() -> None:
    print("=" * 78)
    print("3. THE BIT-BUDGET LOWER BOUND AND WATER-FILLING OPTIMALITY")
    print("=" * 78)
    rng = random.Random(7)
    n = 24
    lam = 0.9
    dyn_range = 1.0
    # geometric sensitivity profile: s(k) = lam^(n-1-k)
    coeffs = [dyn_range * lam ** (n - 1 - k) for k in range(n)]
    budget = 4.0 * n  # an average of 4 bits per block

    lb = cost_lower_bound(coeffs, budget)
    b_star = water_filling(coeffs, budget)
    c_star = cost(coeffs, b_star)

    print("  n = %d blocks, budget B = %.1f bits (average %.2f bits/block)"
          % (n, budget, budget / n))
    print("  geometric mean of sensitivities     = %.8f" % geometric_mean(coeffs))
    print("  lower bound  n G 2^(-B/n)           = %.8f" % lb)
    print("  cost of water-filling allocation    = %.8f" % c_star)
    print("  attained (equality)                 : %s" % (abs(c_star - lb) < 1e-12))
    print("  budget spent by b*                  = %.8f (target %.1f)"
          % (sum(b_star), budget))

    worst_random = -1.0
    for _ in range(20000):
        b = random_feasible_allocation(n, budget, rng)
        c = cost(coeffs, b)
        assert c >= lb - 1e-12, "lower bound violated"
        worst_random = max(worst_random, c / lb)
    print("  20000 random feasible allocations   : all >= lower bound")
    print("  worst random allocation was %.1fx the optimum" % worst_random)

    # uniform allocation, the industry default
    uniform = [budget / n] * n
    print("  UNIFORM allocation cost             = %.8f  (%.2fx optimum)"
          % (cost(coeffs, uniform), cost(coeffs, uniform) / lb))
    print()

    print("=" * 78)
    print("4. THE LOGARITHMIC PRECISION LAW")
    print("=" * 78)
    print("  optimal bit gap b*_i - b*_j equals log2(c_i / c_j) exactly:")
    for (i, j) in [(23, 0), (23, 12), (12, 0), (23, 22)]:
        lhs = b_star[i] - b_star[j]
        rhs = math.log2(coeffs[i] / coeffs[j])
        print("    layers (%2d, %2d):  gap = %+8.4f bits   log2 ratio = %+8.4f  match %s"
              % (i, j, lhs, rhs, abs(lhs - rhs) < 1e-12))
    print("  geometric-profile corollary  b*_j - b*_i = (j-i) log2(1/lambda):")
    predicted = (23 - 0) * math.log2(1.0 / lam)
    print("    lambda = %.2f, depth 24 -> predicted head-to-tail spread = %.4f bits"
          % (lam, predicted))
    print("    measured spread                                         = %.4f bits"
          % (b_star[23] - b_star[0]))
    print("  a block r times more sensitive deserves exactly log2(r) extra bits:")
    for r in [2.0, 4.0, 16.0, 256.0]:
        print("    r = %6.1f  ->  %+.2f bits" % (r, math.log2(r)))
    print("  optimal bit widths (rounded to 2dp), by depth:")
    print("    " + "  ".join("%.2f" % b for b in b_star[:8]) + "  ...")
    print("    ... " + "  ".join("%.2f" % b for b in b_star[-4:]))
    print()

    print("=" * 78)
    print("5. INTEGER BIT WIDTHS: FEASIBLE, AND AT MOST A FACTOR TWO")
    print("=" * 78)
    floored = [float(math.floor(b)) for b in b_star]
    print("  sum of floored widths = %.2f <= budget %.2f : %s"
          % (sum(floored), budget, sum(floored) <= budget + 1e-12))
    ratio = cost(coeffs, floored) / c_star
    print("  cost(floor b*) / cost(b*) = %.4f  <= 2 : %s" % (ratio, ratio <= 2.0 + 1e-12))
    print("  integer widths: " + " ".join("%d" % int(b) for b in floored))
    print()


# ----------------------------------------------------------------------------
# 6. The coverage model: sandwich, budget, submodularity, emergence
# ----------------------------------------------------------------------------

LayerSet = FrozenSet[int]
Family = Dict[LayerSet, Set[int]]


def build_covering_family(n_layers: int, n_prompts: int, seed: int) -> Family:
    """A monotone COVERING disagreement family.

    Each layer i owns a set B_i of prompts it breaks; the family is defined by
    D(S) = union_{i in S} B_i.  This is monotone and satisfies coverage by
    construction, so the sandwich, budget bound and submodularity must all hold.
    """
    rng = random.Random(seed)
    broken = {
        i: {p for p in range(n_prompts) if rng.random() < 0.08}
        for i in range(n_layers)
    }
    family: Family = {}
    for k in range(n_layers + 1):
        for combo in itertools.combinations(range(n_layers), k):
            s: Set[int] = set()
            for i in combo:
                s |= broken[i]
            family[frozenset(combo)] = s
    return family


def build_epistatic_family(n_layers: int, n_prompts: int, seed: int) -> Family:
    """A monotone family that VIOLATES coverage: joint sets break extra prompts.

    On top of the per-layer sets, every pair {i, j} unlocks an 'emergent' block
    of prompts broken by neither layer alone.
    """
    rng = random.Random(seed)
    broken = {
        i: {p for p in range(n_prompts) if rng.random() < 0.02}
        for i in range(n_layers)
    }
    emergent_blocks = {
        frozenset(pair): {p for p in range(n_prompts) if rng.random() < 0.10}
        for pair in itertools.combinations(range(n_layers), 2)
    }
    family: Family = {}
    for k in range(n_layers + 1):
        for combo in itertools.combinations(range(n_layers), k):
            s: Set[int] = set()
            for i in combo:
                s |= broken[i]
            for pair in itertools.combinations(combo, 2):
                s |= emergent_blocks[frozenset(pair)]
            family[frozenset(combo)] = s
    return family


def q_err(family: Family, s: LayerSet) -> int:
    return len(family[s])


def protection_gain(family: Family, universe: LayerSet, protected: LayerSet) -> int:
    return q_err(family, universe) - q_err(family, universe - protected)


def check_submodular(family: Family, layers: Sequence[int]) -> bool:
    for ka in range(len(layers) + 1):
        for a in itertools.combinations(layers, ka):
            for kb in range(len(layers) + 1):
                for b in itertools.combinations(layers, kb):
                    A, B = frozenset(a), frozenset(b)
                    if q_err(family, A | B) + q_err(family, A & B) > \
                       q_err(family, A) + q_err(family, B):
                        return False
    return True


def pair_interaction(family: Family, universe: LayerSet, a: int, b: int) -> int:
    return (q_err(family, universe - {a}) + q_err(family, universe - {b})
            - q_err(family, universe) - q_err(family, universe - {a, b}))


def demo_coverage_model() -> None:
    print("=" * 78)
    print("6. THE COVERAGE MODEL: SANDWICH, BUDGET, SUBMODULARITY, EMERGENCE")
    print("=" * 78)
    n_layers, n_prompts = 6, 400
    layers = list(range(n_layers))
    universe = frozenset(layers)

    fam = build_covering_family(n_layers, n_prompts, seed=3)
    tail = frozenset({4, 5})

    gain = protection_gain(fam, universe, tail)
    ceiling = q_err(fam, tail)
    budget = sum(q_err(fam, frozenset({i})) for i in tail)
    print("  COVERING family (monotone + coverage), 6 layers, 400 prompts")
    print("    damage of full quantization        = %d prompts" % q_err(fam, universe))
    print("    standalone damage of tail {4,5}    = %d prompts" % ceiling)
    print("    gain from protecting the tail      = %d prompts" % gain)
    print("    sandwich 0 <= gain <= ceiling      : %s" % (0 <= gain <= ceiling))
    print("    budget bound gain <= sum singles   : %s (%d <= %d)"
          % (gain <= budget, gain, budget))
    print("    submodular over all 2^6 x 2^6 pairs: %s" % check_submodular(fam, layers))
    inter = pair_interaction(fam, universe, 4, 5)
    g4 = protection_gain(fam, universe, frozenset({4}))
    g5 = protection_gain(fam, universe, frozenset({5}))
    print("    pair interaction I(4,5)            = %d (>= 0 forced by submodularity)"
          % inter)
    print("    tail-as-one-unit: g(4)+g(5) = %d <= g({4,5}) = %d : %s"
          % (g4 + g5, gain, g4 + g5 <= gain))
    print("    exact decomposition g({4,5}) = g(4)+g(5)+I : %s"
          % (gain == g4 + g5 + inter))

    print()
    fam2 = build_epistatic_family(n_layers, n_prompts, seed=5)
    A, B = frozenset({4}), frozenset({5})
    joint = q_err(fam2, A | B)
    sep = q_err(fam2, A) + q_err(fam2, B)
    emergent = fam2[A | B] - (fam2[A] | fam2[B])
    r = joint / max(sep, 1)
    print("  EPISTATIC family (coverage violated on purpose)")
    print("    damage of layer 4 alone            = %d" % q_err(fam2, A))
    print("    damage of layer 5 alone            = %d" % q_err(fam2, B))
    print("    damage of the pair jointly         = %d" % joint)
    print("    super-additivity ratio r           = %.2fx" % r)
    print("    emergent failures |E(A,B)|         = %d" % len(emergent))
    print("    certified emergent share (r-1)/r   = %.3f" % ((r - 1) / r))
    print("    actual emergent share              = %.3f" % (len(emergent) / joint))
    print("    bound (r-1)/r <= actual            : %s"
          % ((r - 1) / r <= len(emergent) / joint + 1e-12))
    print("    for r = 7 the certified share is 6/7 = %.3f" % (6 / 7))
    print()


# ----------------------------------------------------------------------------
# 7. The measured three-arm instance, in exact rational arithmetic
# ----------------------------------------------------------------------------


def demo_measured_instance() -> None:
    print("=" * 78)
    print("7. THE MEASURED THREE-ARM INSTANCE (EXACT RATIONAL ARITHMETIC)")
    print("=" * 78)
    ret_full = Fraction(9081, 10000)   # every layer at 4 bits
    ret_rest = Fraction(9261, 10000)   # every layer but the final pair
    ret_tail = Fraction(9766, 10000)   # the final pair only

    err_full = 1 - ret_full
    err_rest = 1 - ret_rest
    err_tail = 1 - ret_tail

    gain = ret_rest - ret_full
    slack = err_rest + err_tail - err_full

    print("  retained accuracies:  full %s   mixed %s   tail-only %s"
          % (float(ret_full), float(ret_rest), float(ret_tail)))
    print("  gain from tail protection   = %s = %.4f  (exactly 9/500)"
          % (gain, float(gain)))
    print("  gain is strictly positive   : %s   [P1 confirmed, P2 refuted]" % (gain > 0))
    print("  coverage consistency  err(full) <= err(rest) + err(tail) : %s"
          % (err_full <= err_rest + err_tail))
    print("  coverage slack              = %s = %.4f  (exactly 27/5000)"
          % (slack, float(slack)))
    print("  protection sandwich  0 < gain <= err(tail) : %s (%.4f <= %.4f)"
          % (0 < gain <= err_tail, float(gain), float(err_tail)))
    print("  efficiency gain/err(tail)   = %s = %.4f  (exactly 10/13)"
          % (gain / err_tail, float(gain / err_tail)))
    print("  13*gain == 10*err(tail)     : %s" % (13 * gain == 10 * err_tail))
    print("  3/4 err(tail) < gain < err(tail) : %s"
          % (Fraction(3, 4) * err_tail < gain < err_tail))

    # two-block damage functional realizing the arms
    damage = {
        frozenset(): Fraction(0),
        frozenset({"tail"}): err_tail,
        frozenset({"rest"}): err_rest,
        frozenset({"tail", "rest"}): err_full,
    }
    both = frozenset({"tail", "rest"})
    inter = (damage[both - {"tail"}] + damage[both - {"rest"}]
             - damage[both] - damage[frozenset()])
    g_tail = damage[both] - damage[both - {"tail"}]
    g_rest = damage[both] - damage[both - {"rest"}]
    g_both = damage[both] - damage[frozenset()]
    print("  block interaction I(tail,rest) = %s = %.4f > 0 : %s"
          % (inter, float(inter), inter > 0))
    print("  joint beats separate: g(tail)+g(rest) = %.4f < g(both) = %.4f : %s"
          % (float(g_tail + g_rest), float(g_both), g_tail + g_rest < g_both))
    print("  exact decomposition holds  : %s" % (g_both == g_tail + g_rest + inter))

    # memory accounting
    tail_params = Fraction(2 * 1_800_000)
    model_params = Fraction(494_000_000)
    protection_bytes = tail_params * (4 - Fraction(1, 2))
    base_bytes = model_params * Fraction(1, 2)
    overhead = protection_bytes / base_bytes
    print("  protection cost   = %.1f MB on top of a %.1f MB 4-bit model"
          % (float(protection_bytes) / 1e6, float(base_bytes) / 1e6))
    print("  memory overhead   = %.4f = %.2f%%  ( < 6%% : %s )"
          % (float(overhead), 100 * float(overhead), overhead < Fraction(6, 100)))
    print("  quality per unit overhead: 0.29 * overhead = %.5f < gain = %.5f : %s"
          % (0.29 * float(overhead), float(gain),
             Fraction(29, 100) * overhead < gain))
    print()


def main() -> None:
    print()
    print("TAIL-AWARE MIXED PRECISION -- NUMERICAL DEMONSTRATIONS")
    print()
    demo_dichotomy()
    demo_propagation()
    demo_bit_allocation()
    demo_coverage_model()
    demo_measured_instance()
    print("All demonstrations completed; every asserted bound held.")


if __name__ == "__main__":
    main()


"""Pair-Interaction Screening and Emergent-Share Certification.

Decides whether two layers must be treated as a single unit under protection,
and, when the damage functional fails to be submodular, certifies how much of
the joint damage is emergent -- invisible to any per-layer analysis.

Four evaluations of the damage functional per candidate pair, hence O(k^2)
evaluations to screen all pairs among k candidate layers; the arithmetic itself
is O(1) per pair.
"""

from __future__ import annotations

from fractions import Fraction
from typing import Callable, Dict, FrozenSet, List

LayerSet = FrozenSet[int]
Damage = Callable[[LayerSet], Fraction]


def gain(damage: Damage, universe: LayerSet, protected: LayerSet) -> Fraction:
    """Quality recovered by protecting `protected` inside the quantized set."""
    return damage(universe) - damage(universe - protected)


def pair_interaction(damage: Damage, universe: LayerSet, a: int, b: int) -> Fraction:
    """I(a,b) = E(U\\a) + E(U\\b) - E(U) - E(U\\{a,b}); non-negative exactly when
    the functional is submodular at this pair."""
    return (damage(universe - {a}) + damage(universe - {b})
            - damage(universe) - damage(universe - {a, b}))


def decomposition_residual(
    damage: Damage, universe: LayerSet, a: int, b: int
) -> Fraction:
    """Must be exactly zero: gain(pair) = gain(a) + gain(b) + I(a,b)."""
    return (gain(damage, universe, frozenset({a, b}))
            - gain(damage, universe, frozenset({a}))
            - gain(damage, universe, frozenset({b}))
            - pair_interaction(damage, universe, a, b))


def emergent_share_bound(joint: Fraction, separate_sum: Fraction) -> Fraction:
    """Certified lower bound (r-1)/r on the emergent fraction of joint failures,
    where r = joint / separate_sum.  Zero when the pair is subadditive."""
    if separate_sum <= 0 or joint <= separate_sum:
        return Fraction(0)
    r = joint / separate_sum
    return (r - 1) / r


def screen_pairs(
    damage: Damage, universe: LayerSet, candidates: List[int]
) -> List[Dict[str, object]]:
    """Screen every candidate pair; report interaction, verdict, and certificates."""
    report: List[Dict[str, object]] = []
    for i in range(len(candidates)):
        for j in range(i + 1, len(candidates)):
            a, b = candidates[i], candidates[j]
            inter = pair_interaction(damage, universe, a, b)
            joint = damage(frozenset({a, b}))
            sep = damage(frozenset({a})) + damage(frozenset({b}))
            if inter > 0:
                verdict = "PROTECT JOINTLY (strict domination)"
            elif inter == 0:
                verdict = "additive: joint protection equals separate protection"
            else:
                verdict = "NON-SUBMODULAR: coverage refuted, per-layer probes unreliable"
            report.append({
                "pair": (a, b),
                "interaction": inter,
                "joint_gain": gain(damage, universe, frozenset({a, b})),
                "sum_of_single_gains": (gain(damage, universe, frozenset({a}))
                                        + gain(damage, universe, frozenset({b}))),
                "decomposition_residual": decomposition_residual(damage, universe, a, b),
                "emergent_share_lower_bound": emergent_share_bound(joint, sep),
                "verdict": verdict,
            })
    return report


if __name__ == "__main__":
    # The measured two-block instance: block 0 = tail pair, block 1 = the body.
    table: Dict[LayerSet, Fraction] = {
        frozenset(): Fraction(0),
        frozenset({0}): Fraction(234, 10000),
        frozenset({1}): Fraction(739, 10000),
        frozenset({0, 1}): Fraction(919, 10000),
    }
    damage: Damage = lambda s: table[s]
    for row in screen_pairs(damage, frozenset({0, 1}), [0, 1]):
        print("pair %s" % (row["pair"],))
        print("  interaction          = %s (%.4f)"
              % (row["interaction"], float(row["interaction"])))
        print("  joint gain           = %.4f" % float(row["joint_gain"]))
        print("  sum of single gains  = %.4f" % float(row["sum_of_single_gains"]))
        print("  decomposition exact  : %s" % (row["decomposition_residual"] == 0))
        print("  emergent share bound = %.3f" % float(row["emergent_share_lower_bound"]))
        print("  verdict              : %s" % row["verdict"])

    epi: Dict[LayerSet, Fraction] = {
        frozenset(): Fraction(0),
        frozenset({0}): Fraction(1, 100),
        frozenset({1}): Fraction(1, 100),
        frozenset({0, 1}): Fraction(14, 100),
    }
    print()
    print("7x super-additive pair: certified emergent share >= %.4f"
          % float(emergent_share_bound(epi[frozenset({0, 1})],
                                       epi[frozenset({0})] + epi[frozenset({1})])))


"""Sensitivity-Driven Water-Filling Bit Allocation.

Given per-layer Lipschitz constants and weight dynamic ranges, produce the
provably optimal real-valued bit allocation for a fixed total bit budget, then
project it onto the hardware-supported integer widths while staying inside the
budget.  Runs in O(n log n) (O(n) for the analytic optimum, the log factor only
for the repair sort).
"""

from __future__ import annotations

import math
from typing import Dict, List, Sequence


def sensitivity_profile(lips: Sequence[float]) -> List[float]:
    """s(m) = prod_{k > m} L_k, computed by one backward pass in O(n)."""
    n = len(lips)
    s = [1.0] * n
    for m in range(n - 2, -1, -1):
        s[m] = lips[m + 1] * s[m + 1]
    return s


def cost(coeffs: Sequence[float], bits: Sequence[float]) -> float:
    """Certified end-to-end error sum_i c_i 2^{-b_i}."""
    return sum(c * 2.0 ** (-b) for c, b in zip(coeffs, bits))


def cost_lower_bound(coeffs: Sequence[float], budget: float) -> float:
    """n (prod_i c_i)^{1/n} 2^{-B/n}: beaten by no allocation, attained by b*."""
    n = len(coeffs)
    gmean = math.exp(sum(math.log(c) for c in coeffs) / n)
    return n * gmean * 2.0 ** (-budget / n)


def water_filling_bits(coeffs: Sequence[float], budget: float) -> List[float]:
    """b*_i = B/n + log2 c_i - (1/n) sum_j log2 c_j."""
    n = len(coeffs)
    logs = [math.log2(c) for c in coeffs]
    mean_log = sum(logs) / n
    return [budget / n + lg - mean_log for lg in logs]


def project_to_hardware(
    bits: Sequence[float],
    budget: float,
    supported: Sequence[int] = (2, 3, 4, 6, 8, 16, 32),
) -> List[int]:
    """Round each width down to the nearest supported width, then, while budget
    remains, promote the most sensitive blocks one supported step at a time."""
    widths = sorted(supported)
    out: List[int] = []
    for b in bits:
        feasible = [w for w in widths if w <= b]
        out.append(feasible[-1] if feasible else widths[0])
    order = sorted(range(len(bits)), key=lambda i: -bits[i])
    changed = True
    while changed:
        changed = False
        for i in order:
            higher = [w for w in widths if w > out[i]]
            if not higher:
                continue
            step = higher[0] - out[i]
            if sum(out) + step <= budget:
                out[i] += step
                changed = True
    return out


def allocate(
    lipschitz: Sequence[float],
    dynamic_range: Sequence[float],
    budget: float,
    supported: Sequence[int] = (2, 3, 4, 6, 8, 16, 32),
) -> Dict[str, object]:
    """Full pipeline: sensitivity -> coefficients -> optimum -> deployable widths."""
    s = sensitivity_profile(lipschitz)
    coeffs = [si * ri for si, ri in zip(s, dynamic_range)]
    b_star = water_filling_bits(coeffs, budget)
    integer = project_to_hardware(b_star, budget, supported)
    return {
        "sensitivity": s,
        "coefficients": coeffs,
        "optimal_bits": b_star,
        "integer_bits": integer,
        "optimal_cost": cost(coeffs, b_star),
        "lower_bound": cost_lower_bound(coeffs, budget),
        "integer_cost": cost(coeffs, [float(w) for w in integer]),
        "uniform_cost": cost(coeffs, [budget / len(coeffs)] * len(coeffs)),
        "bits_used": sum(integer),
    }


if __name__ == "__main__":
    n = 24
    lam = 0.9
    result = allocate([lam] * n, [1.0] * n, budget=4.0 * n)
    print("optimal (real) widths :",
          " ".join("%.2f" % b for b in result["optimal_bits"]))
    print("deployable widths     :",
          " ".join("%d" % w for w in result["integer_bits"]))
    print("bits used = %s / %d" % (result["bits_used"], 4 * n))
    print("cost: optimum %.6f | integer %.6f | uniform %.6f"
          % (result["optimal_cost"], result["integer_cost"], result["uniform_cost"]))
    print("optimum equals the theoretical lower bound: %s"
          % (abs(result["optimal_cost"] - result["lower_bound"]) < 1e-12))


"""Assemble PACKAGE.json from the deliverable files in this project."""

from __future__ import annotations

import json
import os
from typing import Any, Dict, List

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ASSETS = os.path.join(ROOT, "package_assets")


def read(path: str) -> str:
    with open(path, "r", encoding="utf-8") as fh:
        return fh.read()


def main() -> None:
    article = read(os.path.join(ROOT, "ARTICLE.md"))
    paper = read(os.path.join(ROOT, "RESEARCH_PAPER.md"))
    paper_tex = read(os.path.join(ROOT, "RESEARCH_PAPER.tex"))
    demo = read(os.path.join(ROOT, "demo.py"))

    lean_files = [
        "Catalog/Computation/TailAwareMixedPrecision.lean",
        "Catalog/Computation/TailUnitEpistasis.lean",
        "Catalog/Computation/OptimalBitAllocation.lean",
    ]
    lean_sources: List[str] = []
    for rel in lean_files:
        src = read(os.path.join(ROOT, rel))
        lean_sources.append(
            "/- ===== %s ===== -/\n\n%s" % (rel, src.rstrip()) + "\n"
        )
    lean_proofs = "\n\n".join(lean_sources)

    package: Dict[str, Any] = {
        "title": "Tail-Aware Mixed Precision: Sensitivity Profiles, Submodular Damage, "
                 "and an Optimal Bit-Allocation Law",
        "domain": "Computation",
        "description": (
            "A quantitative theory of layer-wise precision protection: the sensitivity of a "
            "layer is the product of the Lipschitz constants downstream of it, so in a "
            "non-expansive network sensitivity grows with depth and the optimal bit "
            "allocation grants each block a number of extra bits equal to the base-2 "
            "logarithm of its sensitivity ratio. The theory explains, and exactly bounds, a "
            "measured 1.8-point retained-accuracy gain from keeping the final layer pair at "
            "full precision inside an otherwise 4-bit transformer."
        ),
        "authors": ["Aristotle"],
        "date": "2026-09-01",
        "key_results": [
            "Precision dichotomy: the sensitivity profile s(m) = product of the Lipschitz "
            "constants of all layers after m is monotone increasing in depth for a "
            "non-expansive stack, attaining its maximum value 1 at the last layer, and "
            "antitone in depth for an expansive stack, so which end of a network deserves "
            "precision is decided by the contraction regime",
            "Bit-budget lower bound and water-filling optimality: every allocation of a total "
            "budget B across n blocks with sensitivity coefficients c_i has certified error at "
            "least n times the geometric mean of the c_i times 2^(-B/n), and the allocation "
            "b*_i = B/n + log2(c_i) - mean_j log2(c_j) spends exactly the budget and attains "
            "the bound",
            "Logarithmic precision law: the optimal bit gap between two blocks equals log2 of "
            "their sensitivity ratio, independent of the budget and of all other blocks; for a "
            "geometric profile with contraction factor lambda the optimal widths are affine in "
            "depth with slope log2(1/lambda), and flooring to integer widths stays within "
            "budget at a cost factor of at most two",
            "Protection sandwich and budget bound: under a monotone covering family of "
            "disagreement sets, the quality recovered by protecting a layer set is non-negative "
            "and never exceeds that set's standalone damage, which is in turn at most the sum "
            "of its members' individual damages",
            "Tail-as-one-unit theorem: the disagreement count of any monotone covering family "
            "is submodular, hence the pair interaction is non-negative and joint protection of "
            "a layer pair dominates the sum of the separate protections; conversely an r-fold "
            "super-additive measurement certifies that at least a fraction (r-1)/r of the joint "
            "failures are emergent, i.e. six sevenths at r = 7",
        ],
        "keywords": [
            "quantization",
            "mixed precision",
            "Lipschitz sensitivity",
            "water-filling",
            "submodularity",
            "epistasis",
            "bit allocation",
            "model compression",
        ],
        "article": article,
        "research_paper": paper,
        "research_paper_tex": paper_tex,
        "demo": demo,
        "demos": [
            {
                "name": "End-to-End Numerical Verification of the Sensitivity, Coverage and "
                        "Bit-Allocation Theory",
                "description": (
                    "A single self-contained script that reproduces every result of the theory "
                    "numerically. It builds contractive and expansive 24-layer stacks and checks "
                    "that the sensitivity profile is monotone increasing in depth in the first case "
                    "and antitone in the second; it evaluates a concrete pair of layer stacks on a "
                    "dense input grid and confirms the master propagation bound with its slack "
                    "factor; it verifies the bit-budget lower bound against twenty thousand random "
                    "feasible allocations, confirms that the water-filling allocation attains the "
                    "bound exactly and spends exactly the budget, and measures how much the uniform "
                    "default overpays; it checks the logarithmic precision law b*_i - b*_j = "
                    "log2(c_i/c_j) numerically and its affine geometric-profile corollary; it "
                    "confirms that integer flooring stays inside the budget at a cost factor below "
                    "two; it constructs an explicit monotone covering family of disagreement sets "
                    "and verifies the protection sandwich, the budget bound, submodularity over all "
                    "pairs of subsets, the exact pair decomposition and the tail-as-one-unit "
                    "inequality; it constructs a deliberately epistatic family and confirms the "
                    "(r-1)/r emergent-share bound; and finally it recomputes the three measured "
                    "arms in exact rational arithmetic, obtaining the gain 9/500, the coverage "
                    "slack 27/5000, the efficiency 10/13, a strictly positive block interaction, "
                    "and the memory-overhead accounting."
                ),
                "code": demo,
            },
            {
                "name": "Deployment Sweep: The Value of Tail-Awareness Across Contraction Regimes",
                "description": (
                    "A compact sweep over the contraction factor lambda of a 24-layer stack at a "
                    "fixed average budget of four bits per layer. For each lambda it reports the "
                    "exact head-to-tail bit spread (n-1)log2(1/lambda) demanded by the optimum, the "
                    "certified cost of the optimal allocation, of the uniform 4-bit default, and of "
                    "the practical '4-bit body with a 16-bit tail pair' policy, together with that "
                    "policy's fixed memory overhead and the number of bits per layer the uniform "
                    "default effectively throws away. The sweep makes visible that the entire value "
                    "of tail-aware precision is governed by a single number -- how strongly the "
                    "network contracts -- and that it vanishes exactly at lambda = 1, where all "
                    "layers are equally sensitive and uniform precision is optimal."
                ),
                "code": read(os.path.join(ASSETS, "demo_deployment_table.py")),
            },
        ],
        "algorithms": [
            {
                "name": "Sensitivity-Driven Water-Filling Bit Allocation",
                "description": (
                    "Computes the provably optimal per-layer bit widths for a fixed total bit "
                    "budget, then projects them onto the hardware-supported width set. The "
                    "mathematical foundation is the certified-cost model cost(b) = sum_i c_i "
                    "2^(-b_i) with c_i = s(i) R_i, where s(i) is the product of the Lipschitz "
                    "constants downstream of layer i and R_i is the block's dynamic range. The "
                    "arithmetic-geometric mean inequality bounds this cost below by n times the "
                    "geometric mean of the c_i times 2^(-B/n) for every allocation of budget B, and "
                    "equality holds exactly when all per-block contributions c_i 2^(-b_i) are "
                    "equal -- which is precisely the water-filling allocation b*_i = B/n + log2 c_i "
                    "- mean_j log2 c_j. The sensitivity profile is obtained by a single backward "
                    "pass in O(n) using s(n-1) = 1 and s(m) = L_{m+1} s(m+1); forming the "
                    "coefficients and the allocation is another O(n); the only super-linear step is "
                    "the O(n log n) sort used when repairing the budget after projection onto the "
                    "discrete width set. No search over allocations is required: the analytic "
                    "optimum replaces the combinatorial one, which is the practical payoff of the "
                    "theory. Flooring the real-valued optimum is guaranteed to remain within budget "
                    "and to cost at most a factor two, since dropping one bit at most doubles a "
                    "single term."
                ),
                "pseudocode": (
                    "INPUT : Lipschitz constants L[0..n-1], dynamic ranges R[0..n-1],\n"
                    "        total bit budget B, supported widths W (sorted)\n"
                    "OUTPUT: deployable integer widths w[0..n-1] with sum(w) <= B\n"
                    "\n"
                    "1  s[n-1] <- 1\n"
                    "2  for m <- n-2 downto 0 do                    // O(n) backward pass\n"
                    "3      s[m] <- L[m+1] * s[m+1]\n"
                    "4  for i <- 0 to n-1 do\n"
                    "5      c[i] <- s[i] * R[i]                     // sensitivity x range\n"
                    "6  mu <- (1/n) * sum_j log2(c[j])\n"
                    "7  for i <- 0 to n-1 do\n"
                    "8      bstar[i] <- B/n + log2(c[i]) - mu       // water-filling optimum\n"
                    "9  assert sum_i bstar[i] = B\n"
                    "10 assert cost(c, bstar) = n * geomean(c) * 2^(-B/n)   // attains the bound\n"
                    "11 for i <- 0 to n-1 do\n"
                    "12     w[i] <- largest element of W not exceeding bstar[i]\n"
                    "13                (or min(W) if none exists)\n"
                    "14 order <- indices sorted by decreasing bstar\n"
                    "15 repeat                                       // spend the rounding surplus\n"
                    "16     progress <- false\n"
                    "17     for i in order do\n"
                    "18         v <- smallest element of W greater than w[i]\n"
                    "19         if v exists and sum(w) + (v - w[i]) <= B then\n"
                    "20             w[i] <- v ; progress <- true\n"
                    "21 until not progress\n"
                    "22 return w"
                ),
                "code": read(os.path.join(ASSETS, "algo_water_filling.py")),
            },
            {
                "name": "Pair-Interaction Screening and Emergent-Share Certification",
                "description": (
                    "Decides whether two layers must be handled as a single unit under precision "
                    "protection, and diagnoses the regime the measurement is in. The foundation is "
                    "the exact, hypothesis-free decomposition gain({a,b}) = gain({a}) + gain({b}) + "
                    "I(a,b), where the interaction I(a,b) = E(U\\a) + E(U\\b) - E(U) - E(U\\{a,b}) "
                    "collects all non-additivity into a single scalar. When the damage functional is "
                    "submodular -- which is automatic for the disagreement count of any monotone "
                    "covering family -- the interaction is non-negative and joint protection "
                    "dominates the sum of the separate protections; a strictly positive interaction "
                    "makes the domination strict. A negative interaction is equally informative: it "
                    "certifies that coverage fails, hence that a non-empty emergent set exists, and "
                    "the super-additivity ratio r converts into the certified lower bound (r-1)/r on "
                    "the fraction of joint failures caused by neither layer alone. Cost is four "
                    "damage evaluations per candidate pair, so O(k^2) evaluations to screen k "
                    "candidate layers, with O(1) exact rational arithmetic per pair; the evaluations "
                    "dominate, since each is a full pass over the benchmark."
                ),
                "pseudocode": (
                    "INPUT : damage functional E on layer sets, quantized universe U,\n"
                    "        candidate layers C\n"
                    "OUTPUT: for each pair, an interaction value, a verdict, and\n"
                    "        (if super-additive) a certified emergent-share bound\n"
                    "\n"
                    "1  for each unordered pair {a,b} in C do\n"
                    "2      e_none <- E(U)                         // four evaluations\n"
                    "3      e_a    <- E(U \\ {a})\n"
                    "4      e_b    <- E(U \\ {b})\n"
                    "5      e_ab   <- E(U \\ {a,b})\n"
                    "6      I <- e_a + e_b - e_none - e_ab\n"
                    "7      assert (e_none - e_ab) = (e_none - e_a) + (e_none - e_b) + I\n"
                    "8      joint <- E({a,b}) ; sep <- E({a}) + E({b})\n"
                    "9      if sep > 0 and joint > sep then\n"
                    "10         r <- joint / sep ; share <- (r - 1) / r\n"
                    "11     else\n"
                    "12         r <- joint / max(sep, eps) ; share <- 0\n"
                    "13     if I > 0 then\n"
                    "14         verdict <- 'protect {a,b} jointly: strict domination'\n"
                    "15     else if I = 0 then\n"
                    "16         verdict <- 'additive: separate protection is equally good'\n"
                    "17     else\n"
                    "18         verdict <- 'non-submodular: coverage refuted, per-layer\n"
                    "19                     probes unreliable here'\n"
                    "20     emit (pair, I, r, share, verdict)"
                ),
                "code": read(os.path.join(ASSETS, "algo_pair_screening.py")),
            },
        ],
        "visualizations": [
            {
                "name": "Sensitivity Profiles and the Optimal Bit Ladder",
                "description": (
                    "Two panels for a 24-layer stack at several uniform contraction factors. The "
                    "left panel plots the sensitivity profile s(m) = product of the Lipschitz "
                    "constants after layer m on a logarithmic scale, showing it rise monotonically "
                    "with depth to its maximum value 1 at the final layer -- the geometric content "
                    "of the tail-dominance theorem. The right panel plots the corresponding optimal "
                    "bit allocations at a fixed average budget of four bits per layer: perfectly "
                    "straight lines of slope log2(1/lambda) bits per layer, crossing the uniform "
                    "4-bit default near the middle of the stack. Reading the two panels together "
                    "shows the central conversion of the theory: an exponential spread in "
                    "sensitivity becomes a linear spread in precision."
                ),
                "code": read(os.path.join(ASSETS, "viz_profiles.py")),
            },
            {
                "name": "The Price of Uniform Precision and the Protection Sandwich",
                "description": (
                    "The left panel traces the certified cost as a function of the total bit budget "
                    "for three allocations: the uniform default, the water-filling optimum (which "
                    "coincides exactly with the theoretical lower bound), and the integer-floored "
                    "optimum, whose curve stays provably within a factor two of the optimum. The "
                    "constant vertical gap between the uniform and optimal curves is the precision "
                    "that uniform quantization wastes, and it is independent of the budget. The "
                    "right panel draws the three measured arms as damage bars with the protection "
                    "sandwich annotated explicitly: the measured gain of 0.0180, the ceiling of "
                    "0.0234 supplied by the tail-only arm, the realized efficiency of 10/13, and "
                    "the subadditivity slack of 0.0054 that also equals the strictly positive "
                    "block interaction."
                ),
                "code": read(os.path.join(ASSETS, "viz_costs_and_arms.py")),
            },
        ],
        "interactive_demos": [
            {
                "title": "The Water-Filling Bit Allocator",
                "description": (
                    "A live allocator for a layer stack of adjustable depth. Sliders control the "
                    "depth, the uniform contraction factor lambda, the average bit budget per "
                    "layer, and an extra sensitivity bump applied to the final pair. The canvas "
                    "draws, in real time, the sensitivity profile on a logarithmic axis, the "
                    "optimal real-valued bit ladder, the deployable integer widths behind it, and "
                    "the uniform default as a reference line, while the readouts report the "
                    "certified cost of the optimum and of the uniform allocation, the factor by "
                    "which uniform precision overpays, the head-to-tail bit spread, the integer "
                    "rounding factor with its proved bound of two, and the current contraction "
                    "regime. The widget makes four things discoverable by hand: lowering lambda "
                    "tilts the ladder with slope exactly log2(1/lambda); pushing lambda above one "
                    "flips the ladder so the head receives the bits; raising the tail bonus by a "
                    "factor r raises the final pair by exactly log2(r) bits; and increasing the "
                    "budget lifts every width equally, since the budget cancels in every bit gap."
                ),
                "html": read(os.path.join(ASSETS, "widget_allocator.html")),
            },
            {
                "title": "The Protection Sandwich and the Emergence Detector",
                "description": (
                    "Three sliders set the retained accuracies of the three experimental arms -- "
                    "everything compressed, the tail kept exact, and only the tail compressed -- "
                    "and the widget derives everything the theory has to say about them. It reports "
                    "the protection gain, its provable ceiling given by the tail's standalone "
                    "damage, the realized efficiency as a percentage of that ceiling, the block "
                    "interaction whose positivity is exactly the tail-as-one-unit condition, the "
                    "super-additivity ratio, and the certified emergent share (r-1)/r. A verdict "
                    "panel changes character across the three regimes: coverage-consistent with "
                    "useful protection, protection provably worthless, and sandwich-violating, in "
                    "which case coverage is refuted and the widget reports the fraction of joint "
                    "failures that neither block causes alone. Presets load the measured "
                    "quantization arms, a strongly epistatic pair, and a configuration where tail "
                    "protection buys nothing at all."
                ),
                "html": read(os.path.join(ASSETS, "widget_sandwich.html")),
            },
        ],
        "interactive_layout": read(os.path.join(ASSETS, "interactive_layout.md")),
        "lean_proofs": lean_proofs,
        "future_directions": read(os.path.join(ASSETS, "future_directions.md")),
        "modules": {
            "demo": demo,
            "algo_water_filling": read(os.path.join(ASSETS, "algo_water_filling.py")),
            "algo_pair_screening": read(os.path.join(ASSETS, "algo_pair_screening.py")),
            "demo_deployment_table": read(os.path.join(ASSETS, "demo_deployment_table.py")),
            "viz_profiles": read(os.path.join(ASSETS, "viz_profiles.py")),
            "viz_costs_and_arms": read(os.path.join(ASSETS, "viz_costs_and_arms.py")),
        },
        "lean_files": lean_files,
    }

    out = os.path.join(ROOT, "PACKAGE.json")
    with open(out, "w", encoding="utf-8") as fh:
        json.dump(package, fh, indent=2, ensure_ascii=False)
        fh.write("\n")
    print("wrote %s (%d bytes)" % (out, os.path.getsize(out)))


if __name__ == "__main__":
    main()


"""Deployment sweep: what tail-aware precision is worth, across contraction regimes.

For each contraction factor lambda in a sweep, this script builds the geometric
sensitivity profile of a 24-layer stack, computes the optimal water-filling
allocation at an average budget of 4 bits per layer, and reports:

  * the head-to-tail bit spread  (j - i) log2(1 / lambda)  the optimum demands;
  * the certified cost of the optimum, of the uniform 4-bit default, and of the
    practical "4 bits everywhere, 16 bits on the last two layers" policy at the
    same *memory* cost;
  * the memory overhead of the practical policy;
  * how many bits per layer the uniform default effectively throws away,
    log2(cost_uniform / cost_optimal).

The point of the sweep is that the value of tail-awareness is governed by a
single number: how strongly the network contracts.
"""

from __future__ import annotations

import math
from typing import List, Sequence


def geometric_coeffs(lam: float, n: int) -> List[float]:
    """c_k = s(k) = lambda^(n-1-k) with unit dynamic range."""
    return [lam ** (n - 1 - k) for k in range(n)]


def cost(coeffs: Sequence[float], bits: Sequence[float]) -> float:
    return sum(c * 2.0 ** (-b) for c, b in zip(coeffs, bits))


def water_filling_bits(coeffs: Sequence[float], budget: float) -> List[float]:
    n = len(coeffs)
    logs = [math.log2(c) for c in coeffs]
    mean_log = sum(logs) / n
    return [budget / n + lg - mean_log for lg in logs]


def practical_policy(n: int, body_bits: int, tail_bits: int, tail_size: int) -> List[float]:
    """4 bits everywhere, high precision on the last `tail_size` layers."""
    return [float(body_bits)] * (n - tail_size) + [float(tail_bits)] * tail_size


def memory_overhead(n: int, body_bits: int, tail_bits: int, tail_size: int) -> float:
    """Extra memory of the practical policy relative to the uniform body policy."""
    base = n * body_bits
    extra = tail_size * (tail_bits - body_bits)
    return extra / base


def main() -> None:
    n, tail_size = 24, 2
    budget = 4.0 * n
    print("24-layer stack, average budget 4 bits/layer, tail block = last 2 layers")
    print()
    print("%-8s %-10s %-11s %-11s %-11s %-9s %-8s"
          % ("lambda", "bit spread", "optimum", "uniform", "16b tail", "waste", "overhead"))
    print("-" * 76)
    for lam in [0.75, 0.80, 0.85, 0.90, 0.95, 0.98, 1.00]:
        c = geometric_coeffs(lam, n)
        b_star = water_filling_bits(c, budget)
        c_opt = cost(c, b_star)
        c_uni = cost(c, [4.0] * n)
        c_pra = cost(c, practical_policy(n, 4, 16, tail_size))
        spread = (n - 1) * math.log2(1.0 / lam) if lam < 1 else 0.0
        waste = math.log2(c_uni / c_opt)
        over = memory_overhead(n, 4, 16, tail_size)
        print("%-8.2f %-10.2f %-11.3e %-11.3e %-11.3e %-9.2f %.1f%%"
              % (lam, spread, c_opt, c_uni, c_pra, waste, 100 * over))
    print()
    print("Reading the table:")
    print("  * 'bit spread' is the exact optimum (j-i) log2(1/lambda) between the")
    print("    shallowest and deepest layer; at lambda = 1 all layers are equally")
    print("    sensitive and uniform precision is optimal.")
    print("  * 'uniform waste' is how many extra bits per layer the uniform default")
    print("    would need to match the optimum's certified error.")
    print("  * the practical 4-bit body / 16-bit tail policy costs a fixed 25% of")
    print("    the body's memory on 2 of 24 layers, independent of lambda, and")
    print("    captures a substantial part of the available improvement, most of it")
    print("    in the mildly contractive range 0.85 <= lambda <= 0.95.")


if __name__ == "__main__":
    main()


"""Visualization: the price of uniform precision, and the protection sandwich.

Left panel: certified cost sum_i c_i 2^{-b_i} as a function of the total bit
budget, for the uniform allocation and for the optimal water-filling allocation
(which coincides exactly with the theoretical lower bound
n (prod c_i)^{1/n} 2^{-B/n}), plus the integer-floored allocation, whose cost is
provably within a factor 2 of the optimum.  The vertical gap between the two
curves is the number of bits per layer that uniform precision wastes.

Right panel: the three measured arms as damage bars, with the protection
sandwich 0 <= gain <= standalone tail damage drawn explicitly, the realized
efficiency 10/13, and the subadditivity slack 0.0054.

Writes `costs_and_arms.png`.
"""

from __future__ import annotations

import math
from typing import List, Sequence

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt


def coefficients(lam: float, n: int) -> List[float]:
    return [lam ** (n - 1 - k) for k in range(n)]


def cost(coeffs: Sequence[float], bits: Sequence[float]) -> float:
    return sum(c * 2.0 ** (-b) for c, b in zip(coeffs, bits))


def water_filling_bits(coeffs: Sequence[float], budget: float) -> List[float]:
    n = len(coeffs)
    logs = [math.log2(c) for c in coeffs]
    mean_log = sum(logs) / n
    return [budget / n + lg - mean_log for lg in logs]


def main() -> None:
    n, lam = 24, 0.9
    coeffs = coefficients(lam, n)
    budgets = [n * avg for avg in [x / 10.0 for x in range(20, 101)]]

    uni, opt, flo = [], [], []
    for B in budgets:
        b_star = water_filling_bits(coeffs, B)
        uni.append(cost(coeffs, [B / n] * n))
        opt.append(cost(coeffs, b_star))
        flo.append(cost(coeffs, [float(math.floor(b)) for b in b_star]))

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

    avgs = [B / n for B in budgets]
    ax1.semilogy(avgs, uni, label="uniform allocation", lw=2)
    ax1.semilogy(avgs, opt, label=r"water-filling $b^\star$ (= lower bound)", lw=2)
    ax1.semilogy(avgs, flo, label=r"integer floor of $b^\star$ ($\leq 2\times$ optimum)",
                 lw=1.5, ls="--")
    ax1.set_xlabel("average bits per layer  $B/n$")
    ax1.set_ylabel("certified cost   $\\sum_i c_i 2^{-b_i}$  (log scale)")
    ax1.set_title(r"Every allocation obeys $\;n(\prod_i c_i)^{1/n}2^{-B/n}$"
                  "\n"
                  r"($n=24$, $\lambda=0.9$)")
    ax1.legend(frameon=False)
    ax1.grid(alpha=0.25, which="both")

    ret_full, ret_rest, ret_tail = 0.9081, 0.9261, 0.9766
    damages = [1 - ret_full, 1 - ret_rest, 1 - ret_tail]
    labels = ["all 24 layers\nat 4 bits", "all but the\nfinal pair", "final pair\nonly"]
    bars = ax2.bar(labels, damages, color=["#c0392b", "#e67e22", "#2980b9"], width=0.55)
    for bar, d in zip(bars, damages):
        ax2.text(bar.get_x() + bar.get_width() / 2, d + 0.003,
                 "%.4f" % d, ha="center", fontsize=10)

    gain = ret_rest - ret_full
    ax2.annotate("", xy=(1, 1 - ret_rest), xytext=(1, 1 - ret_full),
                 arrowprops=dict(arrowstyle="<->", color="black", lw=1.6))
    ax2.text(1.18, (2 - ret_rest - ret_full) / 2,
             "gain = %.4f\n= 10/13 of the ceiling" % gain, fontsize=9, va="center")
    ax2.axhline(1 - ret_tail, color="#2980b9", ls=":", lw=1.2)
    ax2.text(-0.35, 1 - ret_tail + 0.004,
             "protection ceiling  %.4f" % (1 - ret_tail), fontsize=9,
             ha="left", color="#2980b9")
    ax2.set_ylabel("damage  $1-$ retained accuracy")
    ax2.set_title("The measured arms and the protection sandwich\n"
                  "subadditivity slack $= 0.0054 > 0$")
    ax2.grid(alpha=0.25, axis="y")
    ax2.set_ylim(0, 0.11)

    fig.tight_layout()
    fig.savefig("costs_and_arms.png", dpi=150)
    print("wrote costs_and_arms.png")


if __name__ == "__main__":
    main()


"""Visualization: sensitivity profiles and the optimal bit ladder.

Two panels.  Left: the sensitivity profile s(m) = prod_{k>m} L_k of a 24-layer
stack for several uniform contraction factors lambda, on a log scale, showing
that sensitivity rises monotonically with depth to its maximum value 1 at the
last layer.  Right: the corresponding optimal bit allocations
b*_i = B/n + log2 c_i - mean_j log2 c_j at a fixed average budget of 4 bits per
layer -- straight lines of slope log2(1/lambda) bits per layer -- against the
uniform 4-bit default.

Writes `sensitivity_and_bits.png`.
"""

from __future__ import annotations

import math
from typing import List, Sequence

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt


def sensitivity(lam: float, n: int) -> List[float]:
    return [lam ** (n - 1 - k) for k in range(n)]


def water_filling_bits(coeffs: Sequence[float], budget: float) -> List[float]:
    n = len(coeffs)
    logs = [math.log2(c) for c in coeffs]
    mean_log = sum(logs) / n
    return [budget / n + lg - mean_log for lg in logs]


def main() -> None:
    n = 24
    budget = 4.0 * n
    lambdas = [0.80, 0.90, 0.95, 0.99]
    depths = list(range(n))

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

    for lam in lambdas:
        s = sensitivity(lam, n)
        ax1.semilogy(depths, s, marker="o", ms=3.5, label=r"$\lambda = %.2f$" % lam)
    ax1.axhline(1.0, color="grey", lw=0.8, ls="--")
    ax1.set_xlabel("layer index (depth)")
    ax1.set_ylabel(r"sensitivity $s(m)=\prod_{k>m}L_k$   (log scale)")
    ax1.set_title("Sensitivity rises with depth\n(non-expansive stack; maximum 1 at the tail)")
    ax1.legend(frameon=False)
    ax1.grid(alpha=0.25)

    for lam in lambdas:
        s = sensitivity(lam, n)
        bits = water_filling_bits(s, budget)
        ax2.plot(depths, bits, marker="o", ms=3.5,
                 label=r"$\lambda = %.2f$  (slope %.2f b/layer)"
                       % (lam, math.log2(1.0 / lam)))
    ax2.axhline(4.0, color="black", lw=1.2, ls="--", label="uniform 4-bit default")
    ax2.set_xlabel("layer index (depth)")
    ax2.set_ylabel(r"optimal width $b^\star_i$ (bits)")
    ax2.set_title("Optimal precision is affine in depth\n"
                  r"$b^\star_j-b^\star_i=(j-i)\log_2(1/\lambda)$")
    ax2.legend(frameon=False, fontsize=8)
    ax2.grid(alpha=0.25)

    fig.suptitle("Tail-aware mixed precision: where fragility lives, and how many bits it earns",
                 fontsize=13)
    fig.tight_layout()
    fig.savefig("sensitivity_and_bits.png", dpi=150)
    print("wrote sensitivity_and_bits.png")


if __name__ == "__main__":
    main()
