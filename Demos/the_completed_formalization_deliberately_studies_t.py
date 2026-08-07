"""
Two Laws of Delayed Generalization -- numerical demonstrations.
==============================================================

Self-contained Python (standard library only) verifying, numerically, every
quantitative claim of the accompanying paper:

  1. Sharp threshold of a two-layer ReLU network probed along a ray, and the
     delay sandwich   |c|/S  <=  tau  <=  (|c|/a_j0 - b_j0)/g_j0.
  2. The exact zero-bias delay   tau = |c| / S   and the 1/m width law,
     including the almost-sure (law-of-large-numbers) version.
  3. Tropical rigidity: with non-negative output weights the failure set is an
     interval; with signed output weights a width-3k "comb" network has at
     least k+1 failure components.
  4. Weight-decayed gradient flow: the exact crossing time
     tau(lam) = log((s/lam - w0)/(s/lam - theta)) / lam,
     the critical decay lam_c = s/theta, and the discrete gradient-descent
     analogue.
  5. LAW I (relaxation):  tau(lam) / log(1/mu)  ->  1/lam_c   as lam -> lam_c-.
  6. LAW II (bottleneck): sqrt(-mu) * T(sqrt(-mu), A)  ->  pi   as mu -> 0-,
     independently of the observation level A.
  7. The dichotomy: the logarithmic delay is negligible against, and eventually
     strictly smaller than, the bottleneck passage time.
  8. The exact grokking window (1/2, 2] and the unbounded grokking ratio.
  9. Robustness: the threshold displacement of a uniform eps-perturbation is
     exactly eps/kappa.

Run:  python3 demo.py
"""

from __future__ import annotations

import math
import random
from typing import Callable, List, Sequence, Tuple

# --------------------------------------------------------------------------- #
# Core model                                                                    #
# --------------------------------------------------------------------------- #


def relu(u: float) -> float:
    """The rectifier max(u, 0)."""
    return u if u > 0.0 else 0.0


def ramped_output(
    signals: Sequence[float],
    hidden_biases: Sequence[float],
    output_weights: Sequence[float],
    output_bias: float,
    t: float,
) -> float:
    """
    Two-layer ReLU network probed along a ray:

        R(t) = c + sum_j a_j * relu(t * g_j + b_j).

    `signals[j]` is g_j = <W_j, p>, the signal that the probe direction p
    delivers to hidden unit j.
    """
    total = output_bias
    for g, b, a in zip(signals, hidden_biases, output_weights):
        total += a * relu(t * g + b)
    return total


def sharp_threshold(
    f: Callable[[float], float],
    lo: float = 0.0,
    hi: float = 1.0,
    tol: float = 1e-13,
) -> float:
    """
    Locate the sharp threshold of a monotone function f with f(lo) <= 0 by
    bracket expansion followed by bisection.  Returns tau with f <= 0 on
    (-inf, tau] and f > 0 on (tau, inf).
    """
    while f(hi) <= 0.0:
        hi *= 2.0
        if hi > 1e18:
            raise ValueError("function never becomes positive")
    for _ in range(200):
        mid = 0.5 * (lo + hi)
        if f(mid) > 0.0:
            hi = mid
        else:
            lo = mid
        if hi - lo < tol * max(1.0, abs(hi)):
            break
    return 0.5 * (lo + hi)


def delay_sandwich(
    signals: Sequence[float],
    hidden_biases: Sequence[float],
    output_weights: Sequence[float],
    output_bias: float,
) -> Tuple[float, float]:
    """
    Return (lower, upper) bounds on the sharp delay:

        |c| / sum_j a_j g_j   <=   tau   <=   min_j (|c|/a_j - b_j) / g_j,

    the minimum being over active units (a_j > 0, g_j > 0).
    """
    c_abs = abs(output_bias)
    total_signal = sum(a * g for a, g in zip(output_weights, signals))
    lower = c_abs / total_signal
    upper = min(
        (c_abs / a - b) / g
        for g, b, a in zip(signals, hidden_biases, output_weights)
        if a > 0.0 and g > 0.0
    )
    return lower, upper


def exact_zero_bias_delay(
    signals: Sequence[float], output_weights: Sequence[float], output_bias: float
) -> float:
    """Exact delay |c| / S of a zero-hidden-bias network."""
    return abs(output_bias) / sum(a * g for a, g in zip(output_weights, signals))


# --------------------------------------------------------------------------- #
# Training dynamics                                                             #
# --------------------------------------------------------------------------- #


def wd_flow(lam: float, s: float, w0: float, t: float) -> float:
    """Weight-decayed gradient flow  w(t) = s/lam + (w0 - s/lam) e^{-lam t}."""
    return s / lam + (w0 - s / lam) * math.exp(-lam * t)


def cross_time(lam: float, s: float, w0: float, theta: float) -> float:
    """Exact crossing time  tau(lam) = log((s/lam - w0)/(s/lam - theta)) / lam."""
    return math.log((s / lam - w0) / (s / lam - theta)) / lam


def critical_decay(s: float, theta: float) -> float:
    """lam_c = s / theta: above this weight decay the threshold is never crossed."""
    return s / theta


def bif_param(lam: float, s: float, theta: float) -> float:
    """mu(lam) = s/lam - theta, the saddle-node unfolding parameter."""
    return s / lam - theta


def gd_sequence(eta: float, lam: float, s: float, w0: float, k: int) -> float:
    """Weight-decayed gradient descent, closed form after k steps."""
    return s / lam + (w0 - s / lam) * (1.0 - eta * lam) ** k


# --------------------------------------------------------------------------- #
# Saddle-node bottleneck                                                        #
# --------------------------------------------------------------------------- #


def passage_time(k: float, level: float) -> float:
    """Time for  x' = -k^2 - x^2  to fall from +A to -A:  2 arctan(A/k) / k."""
    return 2.0 * math.atan(level / k) / k


def bottleneck_trajectory(k: float, t: float) -> float:
    """Exact solution x(t) = -k tan(k t) of  x' = -k^2 - x^2."""
    return -k * math.tan(k * t)


# --------------------------------------------------------------------------- #
# Demonstrations                                                                #
# --------------------------------------------------------------------------- #


def demo_sharp_threshold_and_sandwich() -> None:
    print("=" * 74)
    print("1.  SHARP THRESHOLD AND THE DELAY SANDWICH")
    print("=" * 74)
    signals = [1.0, 0.5, 2.0, 0.25]
    hidden_biases = [0.0, -0.3, -1.0, -0.1]
    output_weights = [0.4, 1.2, 0.7, 2.0]
    output_bias = -3.0

    f = lambda t: ramped_output(signals, hidden_biases, output_weights, output_bias, t)
    tau = sharp_threshold(f)
    lo, hi = delay_sandwich(signals, hidden_biases, output_weights, output_bias)

    print(f"  signals g       = {signals}")
    print(f"  hidden biases b = {hidden_biases}")
    print(f"  output weights a= {output_weights},  output bias c = {output_bias}")
    print(f"\n  measured sharp threshold tau = {tau:.10f}")
    print(f"  sandwich  |c|/S = {lo:.10f}  <=  tau  <=  {hi:.10f}  (single unit)")
    assert lo - 1e-9 <= tau <= hi + 1e-9
    print("  -> sandwich verified.")

    print("\n  before/after check (sharpness):")
    for t in (tau - 1e-6, tau, tau + 1e-6):
        print(f"    R({t:.8f}) = {f(t):+.3e}")
    assert f(tau - 1e-6) <= 0.0 < f(tau + 1e-6)
    print("  -> transition happens exactly once, at tau.")


def demo_exact_delay_and_width_law() -> None:
    print()
    print("=" * 74)
    print("2.  EXACT ZERO-BIAS DELAY AND THE 1/m WIDTH LAW")
    print("=" * 74)
    c = -1.0
    A, g = 0.8, 1.5
    print(f"  symmetric network: output bias c = {c}, unit weight A = {A}, signal g = {g}")
    print(f"\n  {'m':>5} {'measured tau':>16} {'|c|/(m A g)':>16} {'m * tau':>14}")
    for m in (1, 2, 5, 10, 50, 200):
        signals = [g] * m
        biases = [0.0] * m
        weights = [A] * m
        f = lambda t, s=signals, b=biases, w=weights: ramped_output(s, b, w, c, t)
        tau_num = sharp_threshold(f)
        tau_exact = exact_zero_bias_delay(signals, weights, c)
        print(f"  {m:>5} {tau_num:>16.10f} {tau_exact:>16.10f} {m * tau_num:>14.10f}")
        assert abs(tau_num - tau_exact) < 1e-9
    print(f"\n  m * tau is constant = |c|/(A g) = {abs(c) / (A * g):.10f}  -> exact 1/m law.")

    print("\n  Almost-sure width law (i.i.d. units, strong law of large numbers):")
    random.seed(20260807)
    mean_signal = 1.0  # Exp(1) per-unit signal a_j g_j
    print(f"  per-unit signals ~ Exp(1), so E[Y] = {mean_signal};  predicted limit "
          f"|c|/E[Y] = {abs(c) / mean_signal:.6f}")
    draws = [random.expovariate(1.0) for _ in range(200_000)]
    print(f"  {'m':>8} {'m * tau_m':>14}")
    for m in (10, 100, 1_000, 10_000, 100_000, 200_000):
        total = sum(draws[:m])
        tau_m = abs(c) / total
        print(f"  {m:>8} {m * tau_m:>14.6f}")


def demo_tropical_rigidity() -> None:
    print()
    print("=" * 74)
    print("3.  TROPICAL RIGIDITY, AND HOW SIGNED WEIGHTS BREAK IT")
    print("=" * 74)
    print("  (a) non-negative output weights => failure set is an interval")
    signals = [1.0, 2.0, 0.5]
    biases = [0.0, -1.0, -0.5]
    weights = [1.0, 1.0, 1.0]
    c = -1.0
    grid = [i * 0.001 for i in range(-2000, 6001)]
    fail = [t for t in grid if ramped_output(signals, biases, weights, c, t) <= 0.0]
    blocks = count_blocks(grid, fail)
    print(f"      failure set has {blocks} maximal block(s) on the sampled grid "
          f"-> convex (an interval).")
    assert blocks == 1

    print("\n  (b) the width-3 'hat' network H(t) = -1/2 + relu(t) - 2 relu(t-1) + relu(t-2)")
    hat = lambda t: ramped_output([1.0, 1.0, 1.0], [0.0, -1.0, -2.0],
                                  [1.0, -2.0, 1.0], -0.5, t)
    for t in (0.0, 0.5, 1.0, 1.5, 2.0, 3.0):
        print(f"      H({t:>3.1f}) = {hat(t):+.3f}")
    print("      failure set is exactly (-inf, 1/2] U [3/2, inf): the network groks")
    print("      at t = 1/2 and un-groks at t = 3/2.  Not convex.")
    assert hat(0.5) <= 0 < hat(1.0) and hat(1.5) <= 0

    print("\n  (c) the comb network C_k: width 3k, at least k+1 failure components")
    print(f"      {'k':>4} {'width':>7} {'components found':>18}")
    for k in (1, 2, 3, 5, 8):
        sig, bias, wts = comb_network(k)
        f = lambda t, s=sig, b=bias, w=wts: ramped_output(s, b, w, -0.5, t)
        grid = [i * 0.002 for i in range(-500, int(2 * k / 0.002) + 501)]
        fail = [t for t in grid if f(t) <= 0.0]
        comps = count_blocks(grid, fail)
        print(f"      {k:>4} {3 * k:>7} {comps:>18}")
        assert comps >= k + 1


def comb_network(k: int) -> Tuple[List[float], List[float], List[float]]:
    """Width-3k comb: k triangular tents, tent i supported on [2i, 2i+2]."""
    signals: List[float] = []
    biases: List[float] = []
    weights: List[float] = []
    for i in range(k):
        signals += [1.0, 1.0, 1.0]
        biases += [-2.0 * i, -(2.0 * i + 1.0), -(2.0 * i + 2.0)]
        weights += [1.0, -2.0, 1.0]
    return signals, biases, weights


def count_blocks(grid: Sequence[float], subset: Sequence[float]) -> int:
    """Count maximal runs of consecutive grid points belonging to `subset`."""
    member = set(subset)
    blocks = 0
    inside = False
    for t in grid:
        if t in member:
            if not inside:
                blocks += 1
                inside = True
        else:
            inside = False
    return blocks


def demo_training_dynamics() -> None:
    print()
    print("=" * 74)
    print("4.  DERIVED DELAY: WEIGHT-DECAYED GRADIENT FLOW AND DESCENT")
    print("=" * 74)
    s, theta, w0 = 1.0, 0.5, 0.0
    lam_c = critical_decay(s, theta)
    print(f"  s = {s}, theta = {theta}, w0 = {w0}   =>   critical decay lam_c = {lam_c}")
    print(f"\n  {'lam':>8} {'mu = s/lam - theta':>20} {'tau(lam)':>14} {'crosses?':>10}")
    for lam in (0.2, 0.5, 1.0, 1.5, 1.9, 1.99, 2.0, 2.5):
        mu = bif_param(lam, s, theta)
        if mu > 0:
            tau = cross_time(lam, s, w0, theta)
            crosses = "yes"
            # verify the exact crossing law numerically
            assert wd_flow(lam, s, w0, tau * (1 - 1e-9)) <= theta + 1e-12
            assert wd_flow(lam, s, w0, tau * (1 + 1e-9) + 1e-9) > theta
            print(f"  {lam:>8.3f} {mu:>20.6f} {tau:>14.6f} {crosses:>10}")
        else:
            print(f"  {lam:>8.3f} {mu:>20.6f} {'--':>14} {'NEVER':>10}")
    print("\n  -> the threshold is crossed iff lam < lam_c (connection theorem).")

    print("\n  Discrete gradient descent, eta = 0.1:")
    eta, lam = 0.1, 1.0
    k_star = next(k for k in range(10_000) if gd_sequence(eta, lam, s, w0, k) > theta)
    bound = math.log((s / lam - theta) / (s / lam - w0)) / math.log(1 - eta * lam)
    print(f"      first step with w_k > theta: k = {k_star}")
    print(f"      logarithmic lower bound      : {bound:.6f}")
    assert k_star > bound


def demo_law_one_sharp_constant() -> None:
    print()
    print("=" * 74)
    print("5.  LAW I -- RELAXATION:  tau(lam) / log(1/mu)  ->  1/lam_c")
    print("=" * 74)
    s, theta, w0 = 1.0, 0.5, 0.0
    lam_c = critical_decay(s, theta)
    target = theta / s
    print(f"  lam_c = {lam_c},  predicted limit  theta/s = 1/lam_c = {target}")
    print(f"\n  {'lam_c - lam':>14} {'mu':>14} {'tau':>14} {'tau/log(1/mu)':>16}")
    gap = 1e-1
    for _ in range(9):
        lam = lam_c - gap
        mu = bif_param(lam, s, theta)
        tau = cross_time(lam, s, w0, theta)
        ratio = tau / math.log(1.0 / mu)
        print(f"  {gap:>14.2e} {mu:>14.4e} {tau:>14.5f} {ratio:>16.10f}")
        gap /= 10.0
    print(f"\n  -> ratio converges to {target} : tau ~ lam_c^{{-1}} log(1/mu).")


def demo_law_two_sharp_constant() -> None:
    print()
    print("=" * 74)
    print("6.  LAW II -- BOTTLENECK:  sqrt(-mu) * T  ->  pi,  for every level A")
    print("=" * 74)
    print(f"  predicted limit = pi = {math.pi:.12f}")
    print(f"\n  {'-mu':>12}", end="")
    levels = [0.1, 1.0, 10.0, 1000.0]
    for A in levels:
        print(f" {'A=' + str(A):>18}", end="")
    print()
    neg_mu = 1e-1
    for _ in range(8):
        k = math.sqrt(neg_mu)
        print(f"  {neg_mu:>12.2e}", end="")
        for A in levels:
            print(f" {k * passage_time(k, A):>18.10f}", end="")
        print()
        neg_mu /= 10.0
    print("\n  -> every column converges to pi: the constant does NOT depend on the")
    print("     observation level A.  All the time is spent inside the bottleneck.")

    print("\n  Sanity check of the exact Riccati solution x(t) = -k tan(k t):")
    k, A = 0.05, 2.0
    t0 = -math.atan(A / k) / k
    t1 = math.atan(A / k) / k
    print(f"      k = {k}, A = {A}")
    print(f"      x(t0) = {bottleneck_trajectory(k, t0):+.10f}   (should be +{A})")
    print(f"      x(t1) = {bottleneck_trajectory(k, t1):+.10f}   (should be -{A})")
    print(f"      passage time t1 - t0 = {t1 - t0:.6f} = T(k,A) = {passage_time(k, A):.6f}")
    print(f"      lower bound pi/(2k) = {math.pi / (2 * k):.6f}")
    assert passage_time(k, A) >= math.pi / (2 * k)


def demo_dichotomy() -> None:
    print()
    print("=" * 74)
    print("7.  THE DICHOTOMY: THE BOTTLENECK EXPONENT WINS")
    print("=" * 74)
    K, D, A = 10.0, 1.0, 1.0
    print(f"  comparing  K log(D/mu)  with  T(sqrt(mu), A),  K = {K}, D = {D}, A = {A}")
    print(f"\n  {'mu':>12} {'K log(D/mu)':>16} {'T(sqrt(mu),A)':>18} {'ratio':>12} {'winner':>10}")
    mu = 1e-1
    for _ in range(9):
        log_delay = K * math.log(D / mu)
        bott = passage_time(math.sqrt(mu), A)
        ratio = log_delay / bott
        winner = "bottleneck" if bott > log_delay else "log"
        print(f"  {mu:>12.2e} {log_delay:>16.4f} {bott:>18.4f} {ratio:>12.6f} {winner:>10}")
        mu /= 10.0
    print("\n  -> the ratio tends to 0: the logarithmic delay is asymptotically")
    print("     negligible, and is eventually strictly dominated.")
    print(f"     Empirical log-log slopes near mu = 1e-9:")
    for name, fn in (("logarithmic", lambda m: K * math.log(D / m)),
                     ("bottleneck ", lambda m: passage_time(math.sqrt(m), A))):
        m1, m2 = 1e-9, 1e-10
        slope = (math.log(fn(m2)) - math.log(fn(m1))) / (math.log(m2) - math.log(m1))
        print(f"       {name}: d log(delay) / d log(mu) = {slope:+.5f}")
    print("     -> bottleneck slope -0.5 (power law); relaxation slope ~ 0 (log law).")


def demo_grokking_window() -> None:
    print()
    print("=" * 74)
    print("8.  THE EXACT GROKKING WINDOW AND THE UNBOUNDED GROKKING RATIO")
    print("=" * 74)
    net = lambda p, t: -1.0 + relu(t * p)
    train_perfect = lambda t: net(2.0, t) > 0.0 and -net(-1.0, t) > 0.0
    test_correct = lambda t: net(0.5, t) > 0.0
    print("  network  E(p,t) = -1 + relu(t p);  train signals 2 and -1; test signal 1/2")
    print(f"\n  {'t':>7} {'train perfect':>16} {'test correct':>15} {'in window':>12}")
    for t in (0.25, 0.5, 0.51, 1.0, 1.9, 2.0, 2.01, 3.0):
        tp, tc = train_perfect(t), test_correct(t)
        inw = tp and not tc
        print(f"  {t:>7.2f} {str(tp):>16} {str(tc):>15} {str(inw):>12}")
    assert not train_perfect(0.5) and train_perfect(0.51)
    assert not test_correct(2.0) and test_correct(2.01)
    print("\n  -> the window {train perfect and test wrong} is exactly (1/2, 2].")

    print("\n  Unbounded grokking ratio (single unit, threshold 1/sigma):")
    sigma_train = 1.0
    print(f"  {'sigma_test':>12} {'train delay':>14} {'test delay':>14} {'ratio':>12}")
    for sigma_test in (0.5, 0.1, 0.01, 1e-3, 1e-4):
        print(f"  {sigma_test:>12.0e} {1 / sigma_train:>14.4f} "
              f"{1 / sigma_test:>14.1f} {sigma_train / sigma_test:>12.1f}")
    print("  -> the (test delay)/(train delay) ratio exceeds any prescribed R.")


def demo_robustness() -> None:
    print()
    print("=" * 74)
    print("9.  ROBUSTNESS: THE eps/kappa DISPLACEMENT IS EXACT")
    print("=" * 74)
    kappa, tau = 2.0, 3.0
    print(f"  clean trajectory f(t) = kappa (t - tau) with kappa = {kappa}, tau = {tau}")
    print(f"\n  {'eps':>10} {'predicted tau + eps/kappa':>28} {'measured threshold':>22}")
    for eps in (0.0, 0.1, 0.5, 1.0, 2.0):
        g = lambda t, e=eps: kappa * (t - tau) - e
        predicted = tau + eps / kappa
        measured = sharp_threshold(g, lo=0.0, hi=1.0)
        print(f"  {eps:>10.2f} {predicted:>28.10f} {measured:>22.10f}")
        assert abs(predicted - measured) < 1e-8
    print("\n  -> the perturbed threshold is exactly tau + eps/kappa: the bound is sharp.")
    print("     Noise delays grokking by a computable amount; it never abolishes it.")


def main() -> None:
    print()
    print("#" * 74)
    print("#  TWO LAWS OF DELAYED GENERALIZATION -- NUMERICAL DEMONSTRATIONS".ljust(73) + "#")
    print("#" * 74)
    demo_sharp_threshold_and_sandwich()
    demo_exact_delay_and_width_law()
    demo_tropical_rigidity()
    demo_training_dynamics()
    demo_law_one_sharp_constant()
    demo_law_two_sharp_constant()
    demo_dichotomy()
    demo_grokking_window()
    demo_robustness()
    print()
    print("=" * 74)
    print("All demonstrations completed; every assertion passed.")
    print("=" * 74)


if __name__ == "__main__":
    main()


"""
Algorithm: Criticality Test and Closed-Form Crossing Time for Weight-Decayed Training.

Decide whether a weight-decayed gradient flow ever activates a downstream
rectifier, and if so return the exact activation time in closed form, together
with the leading-order asymptotic prediction near the critical weight decay.
"""

from __future__ import annotations

import math
from dataclasses import dataclass
from typing import List, Optional, Tuple


@dataclass(frozen=True)
class CriticalityReport:
    """Verdict of the criticality test for one weight-decay strength."""

    critical_decay: float          # lam_c = s / theta
    bif_param: float               # mu(lam) = s/lam - theta
    subcritical: bool              # True iff lam < lam_c
    crossing_time: Optional[float] # exact tau(lam), or None if no crossing
    asymptotic: Optional[float]    # lam_c^{-1} log(1/mu), the sharp prediction
    relative_error: Optional[float]


def criticality_report(
    weight_decay: float,
    data_drive: float,
    initial_weight: float,
    activation_threshold: float,
) -> CriticalityReport:
    """
    For the ridge loss L(w) = (lam/2) w^2 - s w, gradient flow gives

        w(t) = s/lam + (w0 - s/lam) exp(-lam t),

    which increases strictly toward s/lam without reaching it.  Hence the
    activation threshold theta is crossed at some forward time if and only if
    s/lam > theta, i.e. iff mu(lam) = s/lam - theta > 0, i.e. iff
    lam < lam_c = s/theta.  In that case the crossing time is exactly

        tau(lam) = log((s/lam - w0) / (s/lam - theta)) / lam,

    and as lam increases to lam_c one has the sharp asymptotic
    tau(lam) ~ lam_c^{-1} log(1/mu).

    Complexity: O(1).
    """
    lam, s, w0, theta = (
        weight_decay, data_drive, initial_weight, activation_threshold,
    )
    if lam <= 0.0 or s <= 0.0 or theta <= 0.0:
        raise ValueError("weight decay, drive and threshold must be positive")
    if w0 >= theta:
        raise ValueError("the initial weight must lie below the threshold")

    lam_c = s / theta
    mu = s / lam - theta
    if mu <= 0.0:
        return CriticalityReport(lam_c, mu, False, None, None, None)

    tau = math.log((s / lam - w0) / mu) / lam
    asym = math.log(1.0 / mu) / lam_c if mu < 1.0 else None
    rel = abs(tau - asym) / tau if (asym is not None and tau > 0) else None
    return CriticalityReport(lam_c, mu, True, tau, asym, rel)


def gd_steps_to_cross(
    learning_rate: float,
    weight_decay: float,
    data_drive: float,
    initial_weight: float,
    activation_threshold: float,
    max_steps: int = 10_000_000,
) -> Tuple[Optional[int], float]:
    """
    Discrete counterpart: weight-decayed gradient descent
    w_{k+1} = w_k - eta (lam w_k - s) has the closed form
    w_k = s/lam + (w0 - s/lam)(1 - eta lam)^k.  Return the first step index k
    at which w_k exceeds theta, together with the logarithmic lower bound

        k > log((s/lam - theta)/(s/lam - w0)) / log(1 - eta lam).

    Complexity: O(1) via the closed form (the bound is evaluated directly and
    the exact step index is obtained by rounding it upward and verifying).
    """
    eta, lam, s, w0, theta = (
        learning_rate, weight_decay, data_drive, initial_weight,
        activation_threshold,
    )
    if not (0.0 < eta * lam < 1.0):
        raise ValueError("require 0 < eta * lam < 1 for a contracting iteration")
    opt = s / lam
    if opt <= theta:
        return None, math.inf
    bound = math.log((opt - theta) / (opt - w0)) / math.log(1.0 - eta * lam)
    k = max(0, int(math.floor(bound)))
    while k <= max_steps:
        w_k = opt + (w0 - opt) * (1.0 - eta * lam) ** k
        if w_k > theta:
            return k, bound
        k += 1
    return None, bound


def sweep_weight_decay(
    data_drive: float,
    initial_weight: float,
    activation_threshold: float,
    gaps: Tuple[float, ...] = (1e-1, 1e-2, 1e-3, 1e-4, 1e-5, 1e-6),
) -> List[CriticalityReport]:
    """Sweep lam upward toward lam_c and report the delay at each distance."""
    lam_c = data_drive / activation_threshold
    return [
        criticality_report(lam_c - g, data_drive, initial_weight, activation_threshold)
        for g in gaps
    ]


if __name__ == "__main__":
    s, theta, w0 = 1.0, 0.5, 0.0
    for rep in sweep_weight_decay(s, w0, theta):
        print(f"mu={rep.bif_param:.3e}  tau={rep.crossing_time:.6f}  "
              f"asymptotic={rep.asymptotic:.6f}  rel.err={rep.relative_error:.4%}")
    print(criticality_report(3.0, s, w0, theta))       # supercritical: no crossing
    print(gd_steps_to_cross(0.1, 1.0, s, w0, theta))


"""
Algorithm: Exact Delay and Two-Sided Delay Certificate for a Ramped ReLU Network.

Given a two-layer rectifier network probed along a ray, compute a certified
interval containing its sharp transition threshold, and return the exact value
whenever the certificate is tight.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import List, Optional, Sequence, Tuple


@dataclass(frozen=True)
class DelayCertificate:
    """A two-sided certificate for the sharp threshold of a ramped network."""

    lower: float               # |c| / S,  the total-signal bound
    upper: float               # min over active units of (|c|/a_j - b_j)/g_j
    total_signal: float        # S = sum_j a_j g_j
    exact: Optional[float]     # the exact delay, when it is determined
    tight: bool                # True iff the exact delay is determined


def delay_certificate(
    signals: Sequence[float],
    hidden_biases: Sequence[float],
    output_weights: Sequence[float],
    output_bias: float,
    tol: float = 1e-12,
) -> DelayCertificate:
    """
    Certify the sharp delay of

        R(t) = c + sum_j a_j * max(t * g_j + b_j, 0),

    under the structural hypotheses  c < 0,  a_j >= 0,  b_j <= 0,  g_j >= 0,
    with total signal S = sum_j a_j g_j > 0.

    Lower bound: R is dominated by its linearization c + tS for t >= 0, so the
    output cannot be positive before |c|/S.
    Upper bound: a single active unit j0 already forces positivity by
    (|c|/a_j0 - b_j0)/g_j0; minimizing over active units sharpens it.
    When every hidden bias vanishes the lower bound is attained and the delay is
    exactly |c|/S; the certificate then reports the exact value.  (For a single
    active unit the two bounds coincide as well.)

    Complexity: O(m) time, O(1) extra space, for hidden width m.
    """
    if output_bias >= 0.0:
        raise ValueError("the output bias must be strictly negative")
    if any(a < 0.0 for a in output_weights):
        raise ValueError("all output weights must be non-negative")
    if any(b > 0.0 for b in hidden_biases):
        raise ValueError("all hidden biases must be non-positive")
    if any(g < 0.0 for g in signals):
        raise ValueError("all signals must be non-negative")

    c_abs = abs(output_bias)
    total = sum(a * g for a, g in zip(output_weights, signals))
    if total <= 0.0:
        raise ValueError("the total signal must be strictly positive")

    lower = c_abs / total
    candidates: List[float] = [
        (c_abs / a - b) / g
        for g, b, a in zip(signals, hidden_biases, output_weights)
        if a > 0.0 and g > 0.0
    ]
    if not candidates:
        raise ValueError("no active hidden unit: the network never transitions")
    upper = min(candidates)

    zero_bias = all(abs(b) <= tol for b in hidden_biases)
    tight = zero_bias or abs(upper - lower) <= tol * max(1.0, abs(lower))
    return DelayCertificate(
        lower=lower,
        upper=upper,
        total_signal=total,
        exact=lower if tight else None,
        tight=tight,
    )


def exact_zero_bias_delay(
    signals: Sequence[float],
    output_weights: Sequence[float],
    output_bias: float,
) -> float:
    """Sharp delay |c| / S of a network whose hidden biases all vanish."""
    total = sum(a * g for a, g in zip(output_weights, signals))
    if total <= 0.0:
        raise ValueError("the total signal must be strictly positive")
    return abs(output_bias) / total


def symmetric_width_law(width: int, unit_weight: float, unit_signal: float,
                        output_bias: float) -> Tuple[float, float]:
    """
    Delay tau(m) = |c| / (m * A * g) of the symmetric width-m network, together
    with the width-invariant product m * tau(m) = |c| / (A * g).
    """
    if width <= 0:
        raise ValueError("width must be positive")
    tau = abs(output_bias) / (width * unit_weight * unit_signal)
    return tau, width * tau


if __name__ == "__main__":
    cert = delay_certificate(
        signals=[1.0, 0.5, 2.0, 0.25],
        hidden_biases=[0.0, -0.3, -1.0, -0.1],
        output_weights=[0.4, 1.2, 0.7, 2.0],
        output_bias=-3.0,
    )
    print(cert)

    tight = delay_certificate(
        signals=[1.5] * 8,
        hidden_biases=[0.0] * 8,
        output_weights=[0.8] * 8,
        output_bias=-1.0,
    )
    print(tight)
    print("width law:", symmetric_width_law(8, 0.8, 1.5, -1.0))


"""
Algorithm: Calibrated Mechanism Classifier for an Observed Grokking Delay.

Given delays measured at a sequence of control-parameter values approaching a
critical point, decide whether the divergence is logarithmic (threshold
relaxation) or an inverse square root (saddle-node bottleneck), and estimate the
corresponding leading constant.
"""

from __future__ import annotations

import math
from dataclasses import dataclass
from typing import Dict, List, Sequence, Tuple


@dataclass(frozen=True)
class MechanismVerdict:
    """Outcome of the two-hypothesis fit."""

    verdict: str                 # "bottleneck", "relaxation" or "inconclusive"
    log_log_slope: float         # d log(delay) / d log(mu), estimated
    log_constant: float          # best K in  delay ~ K log(1/mu)
    log_residual: float          # relative RMS residual of that fit
    sqrt_constant: float         # best C in  delay ~ C mu^{-1/2}
    sqrt_residual: float         # relative RMS residual of that fit
    predicted_pi: float          # sqrt_constant, to be compared with pi
    predicted_inv_lambda_c: float  # log_constant, to be compared with 1/lam_c


def _least_squares_scale(xs: Sequence[float], ys: Sequence[float]) -> Tuple[float, float]:
    """
    Fit  y ~ k * x  with no intercept, returning (k, relative RMS residual).
    The optimal scale is k = <x,y>/<x,x>.
    """
    num = sum(x * y for x, y in zip(xs, ys))
    den = sum(x * x for x in xs)
    if den == 0.0:
        return 0.0, math.inf
    k = num / den
    ss = sum((y - k * x) ** 2 for x, y in zip(xs, ys))
    norm = sum(y * y for y in ys)
    return k, math.sqrt(ss / norm) if norm > 0 else math.inf


def _log_log_slope(mus: Sequence[float], delays: Sequence[float]) -> float:
    """Ordinary least-squares slope of log(delay) against log(mu)."""
    lx = [math.log(m) for m in mus]
    ly = [math.log(d) for d in delays]
    n = len(lx)
    mx, my = sum(lx) / n, sum(ly) / n
    sxy = sum((a - mx) * (b - my) for a, b in zip(lx, ly))
    sxx = sum((a - mx) ** 2 for a in lx)
    return sxy / sxx if sxx > 0 else float("nan")


def classify_mechanism(
    mus: Sequence[float],
    delays: Sequence[float],
    slope_tolerance: float = 0.12,
) -> MechanismVerdict:
    """
    Two competing hypotheses for a delay diverging as the control parameter
    mu tends to 0 from above:

        H_relax :  delay ~ K * log(1/mu)          (log-log slope 0)
        H_bottle:  delay ~ C * mu^{-1/2}          (log-log slope -1/2)

    The routine (i) estimates the log-log slope, (ii) fits both one-parameter
    models by least squares through the origin, and (iii) returns a verdict.
    The theory predicts C = pi for a saddle-node bottleneck (independently of
    where the passage is observed) and K = 1/lam_c for threshold relaxation
    under weight decay with critical value lam_c, so the fitted constants are
    directly interpretable rather than nuisance parameters.

    Complexity: O(n) time, O(n) space, for n samples.
    """
    if len(mus) != len(delays) or len(mus) < 3:
        raise ValueError("need at least three matched (mu, delay) samples")
    if any(m <= 0.0 for m in mus) or any(d <= 0.0 for d in delays):
        raise ValueError("all mu and delay values must be strictly positive")

    slope = _log_log_slope(mus, delays)
    k_log, r_log = _least_squares_scale([math.log(1.0 / m) for m in mus], delays)
    c_sqrt, r_sqrt = _least_squares_scale([m ** -0.5 for m in mus], delays)

    if abs(slope + 0.5) < slope_tolerance and r_sqrt < r_log:
        verdict = "bottleneck"
    elif abs(slope) < slope_tolerance and r_log < r_sqrt:
        verdict = "relaxation"
    else:
        verdict = "bottleneck" if r_sqrt < r_log else "relaxation"
        if abs(r_sqrt - r_log) < 1e-3:
            verdict = "inconclusive"

    return MechanismVerdict(
        verdict=verdict,
        log_log_slope=slope,
        log_constant=k_log,
        log_residual=r_log,
        sqrt_constant=c_sqrt,
        sqrt_residual=r_sqrt,
        predicted_pi=c_sqrt,
        predicted_inv_lambda_c=k_log,
    )


def synthetic_samples(mechanism: str, n: int = 12,
                      level: float = 1.0, lam_c: float = 2.0) -> Tuple[List[float], List[float]]:
    """Generate exact synthetic data from either mechanism, for validation."""
    mus = [10.0 ** (-1 - 0.7 * i) for i in range(n)]
    if mechanism == "bottleneck":
        delays = [2.0 * math.atan(level / math.sqrt(m)) / math.sqrt(m) for m in mus]
    elif mechanism == "relaxation":
        # tau(lam) with s = 1, theta = 1/lam_c, w0 = 0 and mu = s/lam - theta
        theta = 1.0 / lam_c
        delays = []
        for m in mus:
            lam = 1.0 / (theta + m)
            delays.append(math.log((1.0 / lam) / m) / lam)
    else:
        raise ValueError("mechanism must be 'bottleneck' or 'relaxation'")
    return mus, delays


if __name__ == "__main__":
    for mech in ("bottleneck", "relaxation"):
        mus, delays = synthetic_samples(mech)
        v = classify_mechanism(mus, delays)
        print(f"--- truth: {mech}")
        print(f"    verdict           : {v.verdict}")
        print(f"    log-log slope     : {v.log_log_slope:+.4f}   (expect "
              f"{-0.5 if mech == 'bottleneck' else 0.0:+.1f})")
        print(f"    fitted C (vs pi)  : {v.sqrt_constant:.5f}   residual {v.sqrt_residual:.2e}")
        print(f"    fitted K (vs 1/lc): {v.log_constant:.5f}   residual {v.log_residual:.2e}")


"""Assemble PACKAGE.json from the project's prose, code and asset files."""

from __future__ import annotations

import json
import os
from typing import Any, Dict, List

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ASSETS = os.path.join(ROOT, "package_assets")

LEAN_FILES = [
    "Catalog/MachineLearning/GrokkingDelayedTransition/VectorMargin.lean",
    "Catalog/MachineLearning/GrokkingDelayedTransition/SaddleNodeLocal.lean",
    "Catalog/MachineLearning/GrokkingDelayedTransition/GradientFlowThreshold.lean",
    "Catalog/MachineLearning/GrokkingDelayedTransition/NextCycle.lean",
    "Catalog/MachineLearning/GrokkingDelayedTransition/WidthLawsAndRelapses.lean",
    "Catalog/MachineLearning/GrokkingDelayedTransition/DelayExponents.lean",
]

FUTURE_DIRECTIONS = """\
# Future directions

Everything asserted as *proved* below is fully established; the conjectures are open.

## What this cycle established (in one paragraph)

The earlier scalar model has been replaced by (i) a genuinely vector-valued two-layer ReLU
network with finite hidden width and a finite two-class test set, whose worst-case margin has a
**sharp, unique** delay; (ii) a **derived** rather than prescribed delay, namely the crossing
time of a weight-decayed gradient flow and its discrete counterpart; (iii) a **connection
theorem** making the bifurcation parameter an explicit function of the regularization strength,
`mu(lambda) = s/lambda - theta`, with crossing possible iff `lambda < lambda_c = s/theta`; and
(iv) full local bifurcation theory for the normal form -- nondegeneracy, exchange of stability,
Lyapunov (nonlinear) attraction/repulsion, robustness under uniform perturbations, and the cubic
reduced loss whose critical points are the two branches. Two *distinct delay scaling laws* were
proved: logarithmic in the distance to the critical weight decay, and inverse-square-root in the
distance below the saddle node. This cycle pinned down the **leading constants** of both laws,
turning the qualitative dichotomy into two exact asymptotics: the relaxation delay satisfies
`crossTime / log(1/mu) -> 1/lambda_c`, and the bottleneck passage time satisfies
`sqrt(|mu|) * passageTime -> pi`, independently of the observation level. Combining the two, the
relaxation delay is negligible against the bottleneck delay near criticality.

---

## Conjecture 1 (Exponent dichotomy for grokking delays)

*For a one-parameter family of two-layer networks trained by weight-decayed gradient flow, the
delay `tau(mu)` as the control parameter `mu` approaches its critical value diverges either like
`log(1/mu)` (relaxation/threshold-crossing mechanism) or like `mu^{-1/2}` (saddle-node bottleneck
mechanism); no other exponent occurs for generic one-dimensional reductions.*

**The key insight is** that the two mechanisms formalized here -- an exponential relaxation
crossing a fixed threshold, and a Riccati flow squeezing through the ghost of an annihilated
equilibrium pair -- are the only two codimension-one ways a smooth scalar reduction can be slow,
and they leave *different, measurable* fingerprints.

**Why now?** Both mechanisms are now fully worked out side by side with explicit constants, so
the conjecture is a statement about *classifying* the proved bounds rather than about producing
new ones; and the exponent is directly measurable in a grokking experiment by sweeping weight
decay.

**Falsifiable by:** exhibiting a smooth family whose delay grows like `mu^{-1}` or `exp(1/mu)` and
whose one-dimensional reduction is smooth and nondegenerate.

## Conjecture 2 (Width law for the delay)

*For hidden units drawn from a fixed distribution, the delay of the width-`m` network satisfies
`m * tau_m -> |c| / E[a g]`; extending this beyond independence -- to weakly dependent or trained
(hence correlated) hidden units, where the normalized total signal need not converge to a
deterministic limit -- is open.*

## Further directions

1. **Vector-valued training dynamics.** Derive the ramp from gradient flow in the full weight
   space of a finite-width network, rather than for a scalar weight, and prove delayed margin
   positivity along the derived trajectory.
2. **Train/test separation at scale.** Extend the exact grokking window to datasets whose
   train/test signal gap is produced by a learned feature map rather than prescribed.
3. **From loss landscape to normal form.** Derive the saddle-node normal form as the reduced
   dynamics of a concrete trained network near a degenerate critical point, making the
   bifurcation parameter an optimizer or regularization parameter by *derivation* rather than by
   parameter identification.
4. **Counting relapses exactly.** The comb construction gives at least `k+1` failure components at
   width `3k`; determine the exact maximal number of connected components of the failure set of a
   width-`m` two-layer ReLU network along a ray.
5. **Robustness in the bottleneck regime.** Show that the sharp constant `pi`, and not merely the
   exponent `-1/2`, persists under sufficiently small uniform perturbations of the network
   trajectory and the vector field.
6. **Local dynamical bifurcation theory beyond one dimension.** Extend the nondegeneracy,
   branch-existence and stability-exchange results to reductions of dimension greater than one.
"""


def read(path: str) -> str:
    with open(os.path.join(ROOT, path), "r", encoding="utf-8") as fh:
        return fh.read()


def asset(name: str) -> str:
    with open(os.path.join(ASSETS, name), "r", encoding="utf-8") as fh:
        return fh.read()


def main() -> None:
    lean_sources: List[str] = []
    for path in LEAN_FILES:
        lean_sources.append(
            f"-- ===== {path} =====\n\n{read(path)}"
        )
    lean_blob = "\n\n".join(lean_sources)

    demo_src = read("demo.py")

    package: Dict[str, Any] = {
        "title": "Two Laws of Delayed Generalization: Sharp Constants for "
                 "Relaxation and Saddle-Node Bottleneck Grokking",
        "domain": "MachineLearning",
        "description": (
            "A complete theory of delayed transitions in two-layer ReLU networks: the "
            "worst-case test margin has a unique sharp threshold equal to |c|/S (prejudice "
            "over evidence), and the length of the delay obeys exactly two divergence laws "
            "whose leading constants are determined here to be 1/lambda_c for threshold "
            "relaxation and pi for the saddle-node bottleneck, with the bottleneck law always "
            "dominating near criticality."
        ),
        "authors": ["Aristotle"],
        "date": "2026-08-07",
        "key_results": [
            "Delayed Margin Positivity Theorem: for a two-layer ReLU network with negative "
            "output bias, non-positive hidden biases and non-negative output weights, the "
            "worst-case classification margin over a finite two-class test set has a unique "
            "sharp threshold -- non-positive before it, strictly positive after it.",
            "Exact delay formula and delay sandwich: any sharp threshold obeys "
            "|c|/S <= tau <= (|c|/a_j - b_j)/g_j with S the total signal, collapsing to the "
            "exact identity tau = |c|/S when the hidden biases vanish; hence the exact 1/m "
            "width law m*tau(m) = |c|/(A g), and almost surely m*tau_m -> |c|/E[Y] for i.i.d. "
            "hidden units.",
            "Connection theorem for weight decay: gradient flow on the ridge loss crosses the "
            "activation threshold if and only if the decay is subcritical, lambda < lambda_c = "
            "s/theta, with exact crossing time tau(lambda) = log((s/lambda - w0)/(s/lambda - "
            "theta))/lambda.",
            "Sharp constant of the relaxation law: tau(lambda)/log(1/mu(lambda)) converges to "
            "theta/s = 1/lambda_c as the weight decay increases to its critical value, so the "
            "delay is asymptotic to lambda_c^{-1} log(1/mu).",
            "Sharp constant of the bottleneck law: the saddle-node passage time satisfies "
            "sqrt(|mu|) * T -> pi as the parameter approaches the bifurcation, independently of "
            "the observation level; consequently every logarithmic delay is eventually strictly "
            "dominated by the inverse-square-root delay near criticality.",
            "Tropical rigidity and its failure: with non-negative output weights the ramped "
            "output is convex, so the failure set is an interval and the transition is "
            "permanent, whereas an explicit width-3k network with signed output weights has a "
            "failure set with at least k+1 connected components.",
        ],
        "keywords": [
            "grokking",
            "delayed generalization",
            "ReLU networks",
            "saddle-node bifurcation",
            "weight decay",
            "scaling laws",
            "tropical geometry",
            "Riccati bottleneck",
        ],
        "article": read("ARTICLE.md"),
        "research_paper": read("RESEARCH_PAPER.md"),
        "research_paper_tex": read("RESEARCH_PAPER.tex"),
        "demo": demo_src,
        "demos": [
            {
                "name": "Complete Numerical Verification of the Delayed-Transition Theory",
                "description": (
                    "A single self-contained program that checks, numerically and with "
                    "assertions, every quantitative claim of the theory: the existence and "
                    "uniqueness of the sharp threshold of a ramped two-layer ReLU network and "
                    "the two-sided delay sandwich |c|/S <= tau <= (|c|/a_j - b_j)/g_j; the exact "
                    "zero-bias delay tau = |c|/S together with the exact 1/m width law and its "
                    "almost-sure form under i.i.d. hidden units; tropical rigidity (a "
                    "positively-weighted layer has an interval failure set) and its failure for "
                    "the hat and comb networks, whose failure components are counted directly; "
                    "the exact crossing law of weight-decayed gradient flow, the criticality "
                    "test lambda < lambda_c = s/theta and the logarithmic lower bound for "
                    "discrete gradient descent; the convergence of tau/log(1/mu) to 1/lambda_c "
                    "and of sqrt(|mu|)*T to pi at four different observation levels; the "
                    "vanishing ratio of the two delays and their empirical log-log slopes; the "
                    "exact grokking window (1/2, 2]; the unbounded grokking ratio; and the "
                    "exactness of the eps/kappa threshold displacement under perturbation."
                ),
                "code": demo_src,
            },
            {
                "name": "The Two Sharp Constants and Blind Mechanism Identification",
                "description": (
                    "A focused study of the headline asymptotics. It tabulates "
                    "tau(lambda)/log(1/mu) converging to theta/s = 1/lambda_c over sixteen "
                    "orders of magnitude in the bifurcation parameter, and tabulates "
                    "sqrt(|mu|) * T(sqrt(|mu|), A) converging to pi at observation levels "
                    "spanning eight orders of magnitude -- exhibiting that the bottleneck "
                    "constant is level-independent. It then generates delay data from each "
                    "mechanism separately and from their sum, hands the raw numbers to a blind "
                    "two-hypothesis least-squares classifier that knows nothing of their origin, "
                    "and verifies that the classifier recovers the correct exponent and returns "
                    "leading constants matching the predicted pi and 1/lambda_c -- including "
                    "the prediction that when both mechanisms are present the bottleneck "
                    "exponent dominates the sum."
                ),
                "code": asset("demo_sharp_constants.py"),
            },
        ],
        "algorithms": [
            {
                "name": "Two-Sided Delay Certificate for a Ramped Rectifier Network",
                "description": (
                    "Certifies the sharp transition time of a two-layer ReLU network probed "
                    "along a ray. The lower bound comes from linear domination: with "
                    "non-positive hidden biases and non-negative signals the network output "
                    "never exceeds its linearization c + tS, where S = sum_j a_j g_j is the "
                    "total signal, so no transition can occur before |c|/S. The upper bound "
                    "comes from a single active hidden unit j0, which by itself forces "
                    "positivity at (|c|/a_j0 - b_j0)/g_j0; minimizing over active units "
                    "sharpens it. When every hidden bias vanishes the lower bound is attained "
                    "and the delay is exactly |c|/S -- 'prejudice divided by evidence' -- which "
                    "immediately yields the exact 1/m width law m*tau(m) = |c|/(A g) for the "
                    "symmetric network. The routine validates the structural sign hypotheses, "
                    "returns both bounds, the total signal, and the exact value when it is "
                    "determined. Complexity: O(m) time and O(1) extra space in the hidden "
                    "width m; every quantity is a closed-form arithmetic expression, so there "
                    "is no iteration and no tolerance to tune."
                ),
                "pseudocode": (
                    "INPUT  signals g[1..m], hidden biases b[1..m], output weights a[1..m],\n"
                    "       output bias c\n"
                    "REQUIRE c < 0;  a_j >= 0, b_j <= 0, g_j >= 0 for all j\n"
                    "\n"
                    "1.  S <- 0\n"
                    "2.  for j <- 1 to m do  S <- S + a_j * g_j\n"
                    "3.  if S <= 0 then FAIL 'no evidence: the network never transitions'\n"
                    "4.  lower <- |c| / S                        // linear-domination bound\n"
                    "5.  upper <- +infinity\n"
                    "6.  for j <- 1 to m do\n"
                    "7.      if a_j > 0 and g_j > 0 then\n"
                    "8.          cand <- (|c| / a_j - b_j) / g_j // single-unit bound\n"
                    "9.          upper <- min(upper, cand)\n"
                    "10. if upper = +infinity then FAIL 'no active unit'\n"
                    "11. zero_bias <- (b_j = 0 for all j)\n"
                    "12. if zero_bias then exact <- lower                 // sandwich attained\n"
                    "13. else if upper = lower then exact <- lower\n"
                    "14. else exact <- UNDETERMINED\n"
                    "15. RETURN (lower, upper, S, exact)"
                ),
                "code": asset("algo_delay_certificate.py"),
            },
            {
                "name": "Criticality Test and Closed-Form Crossing Time for Weight-Decayed Training",
                "description": (
                    "Decides whether weight-decayed training ever activates a downstream "
                    "rectifier, and if so returns the activation time in closed form. Gradient "
                    "flow on the ridge loss L(w) = (lambda/2)w^2 - s w is the linear equation "
                    "w' = s - lambda w, whose solution w(t) = s/lambda + (w0 - s/lambda) "
                    "exp(-lambda t) increases strictly toward the regularized optimum s/lambda "
                    "without ever reaching it. Consequently the activation threshold theta is "
                    "crossed at some forward time if and only if s/lambda > theta -- that is, "
                    "if and only if the bifurcation parameter mu(lambda) = s/lambda - theta is "
                    "positive, equivalently the weight decay is subcritical, lambda < lambda_c "
                    "= s/theta. This is the connection between a regularization hyperparameter "
                    "and the unfolding parameter of a saddle-node normal form. When the "
                    "crossing exists the routine returns the exact time tau(lambda) = "
                    "log((s/lambda - w0)/mu)/lambda together with the leading-order prediction "
                    "lambda_c^{-1} log(1/mu) and the relative error between them, so the sharp "
                    "constant can be checked directly. A companion routine handles discrete "
                    "weight-decayed gradient descent, returning the first step index at which "
                    "the iterate crosses along with the logarithmic lower bound "
                    "log((s/lambda - theta)/(s/lambda - w0)) / log(1 - eta lambda). "
                    "Complexity: O(1) -- everything is closed form."
                ),
                "pseudocode": (
                    "INPUT  weight decay lambda > 0, drive s > 0, initial weight w0,\n"
                    "       activation threshold theta > 0  with  w0 < theta\n"
                    "\n"
                    "1.  lambda_c <- s / theta                   // critical weight decay\n"
                    "2.  mu       <- s / lambda - theta          // bifurcation parameter\n"
                    "3.  if mu <= 0 then\n"
                    "4.      RETURN (lambda_c, mu, subcritical = FALSE, tau = NONE)\n"
                    "                                            // the rectifier never fires\n"
                    "5.  tau  <- log( (s/lambda - w0) / mu ) / lambda      // exact crossing\n"
                    "6.  asym <- log( 1 / mu ) / lambda_c                  // sharp asymptotic\n"
                    "7.  err  <- |tau - asym| / tau\n"
                    "8.  RETURN (lambda_c, mu, subcritical = TRUE, tau, asym, err)\n"
                    "\n"
                    "DISCRETE VARIANT  (learning rate eta with 0 < eta*lambda < 1)\n"
                    "9.  opt   <- s / lambda\n"
                    "10. if opt <= theta then RETURN (NONE, +infinity)\n"
                    "11. bound <- log((opt - theta)/(opt - w0)) / log(1 - eta*lambda)\n"
                    "12. k <- floor(bound)\n"
                    "13. while  opt + (w0 - opt) * (1 - eta*lambda)^k  <=  theta  do k <- k + 1\n"
                    "14. RETURN (k, bound)                       // guaranteed  k > bound"
                ),
                "code": asset("algo_criticality.py"),
            },
            {
                "name": "Calibrated Two-Hypothesis Classifier for the Delay Divergence Exponent",
                "description": (
                    "Decides, from measured delays alone, which of the two slowdown mechanisms "
                    "produced an observed grokking plateau. The theory admits exactly two "
                    "divergence laws as the control parameter mu tends to its critical value: "
                    "threshold relaxation, tau ~ K log(1/mu) with K = 1/lambda_c, which has "
                    "log-log slope zero; and a saddle-node bottleneck, tau ~ C mu^{-1/2} with "
                    "C = pi, which has log-log slope exactly -1/2. The routine estimates the "
                    "log-log slope by ordinary least squares, then fits each one-parameter model "
                    "through the origin (the optimal scale for y ~ k x being <x,y>/<x,x>), "
                    "compares relative RMS residuals, and issues a verdict. Because both "
                    "constants are predicted in advance, the fitted scale is itself a check "
                    "rather than a nuisance parameter: a bottleneck fit should return a constant "
                    "near pi regardless of where the passage was observed, and a relaxation fit "
                    "should return the reciprocal critical weight decay. The method also handles "
                    "the case where both mechanisms contribute, since sqrt(mu) log(1/mu) -> 0 "
                    "guarantees the bottleneck term dominates the sum near criticality. "
                    "Complexity: O(n) time and O(n) space in the number of samples."
                ),
                "pseudocode": (
                    "INPUT  matched samples (mu_i, tau_i), i = 1..n,  all strictly positive,\n"
                    "       with mu_i decreasing toward the critical value 0\n"
                    "REQUIRE n >= 3\n"
                    "\n"
                    "  // (i) estimate the log-log slope\n"
                    "1.  x_i <- log(mu_i);   y_i <- log(tau_i)\n"
                    "2.  slope <- Cov(x, y) / Var(x)\n"
                    "\n"
                    "  // (ii) fit each one-parameter law through the origin\n"
                    "3.  u_i <- log(1 / mu_i)                     // relaxation regressor\n"
                    "4.  K   <- <u, tau> / <u, u>\n"
                    "5.  r_K <- || tau - K u || / || tau ||\n"
                    "6.  v_i <- mu_i^(-1/2)                       // bottleneck regressor\n"
                    "7.  C   <- <v, tau> / <v, v>\n"
                    "8.  r_C <- || tau - C v || / || tau ||\n"
                    "\n"
                    "  // (iii) verdict, calibrated against the predicted constants\n"
                    "9.  if |slope + 1/2| < tol and r_C < r_K then verdict <- BOTTLENECK\n"
                    "10. else if |slope| < tol and r_K < r_C     then verdict <- RELAXATION\n"
                    "11. else verdict <- (r_C < r_K ? BOTTLENECK : RELAXATION)\n"
                    "12.      if |r_C - r_K| tiny then verdict <- INCONCLUSIVE\n"
                    "13. RETURN (verdict, slope, K vs 1/lambda_c, C vs pi, r_K, r_C)"
                ),
                "code": asset("algo_mechanism_classifier.py"),
            },
        ],
        "visualizations": [
            {
                "name": "The Two Delay Laws and Their Sharp Constants",
                "description": (
                    "A four-panel figure making the exponent dichotomy visible. Panel (a) plots "
                    "both delays against the distance mu to criticality on log-log axes: the "
                    "bottleneck passage time is a straight line of slope exactly -1/2, tracking "
                    "the asymptote pi*mu^{-1/2}, while the relaxation crossing time is visibly "
                    "sub-power-law. Panel (b) shows the normalized relaxation delay "
                    "tau/log(1/mu) converging to the predicted constant 1/lambda_c = theta/s. "
                    "Panel (c) shows sqrt(|mu|)*T converging to pi for observation levels "
                    "spanning four orders of magnitude, all landing on the same horizontal line "
                    "-- the level-independence that characterizes a bottleneck. Panel (d) plots "
                    "the ratio of the two delays, which tends to zero: near criticality the "
                    "bottleneck mechanism always wins."
                ),
                "code": asset("viz_delay_laws.py"),
            },
            {
                "name": "The Structure of a Delayed Transition",
                "description": (
                    "A four-panel figure covering the structural side of the theory. Panel (a) "
                    "shows the convex piecewise-linear ramped output of a two-layer ReLU "
                    "network, its unique sharp threshold, its linearization c + tS, and the "
                    "shaded delay sandwich between the total-signal bound |c|/S and the "
                    "single-unit bound. Panel (b) contrasts the hat network, which groks at "
                    "t = 1/2 and un-groks at t = 3/2, with the width-12 comb network, whose "
                    "failure set has five connected components -- the relapse count growing "
                    "linearly in the width once output weights are allowed to change sign. "
                    "Panel (c) draws the saddle-node bifurcation diagram of x' = mu - x^2 with "
                    "its stable and unstable branches and the empty subcritical phase, and "
                    "insets the cubic reduced loss x^3/3 - mu x whose critical points are "
                    "exactly the two branches. Panel (d) plots exact Riccati trajectories "
                    "x(t) = -k tan(kt) for four values of the parameter, showing the plateau "
                    "near the ghost equilibrium lengthening like |mu|^{-1/2}."
                ),
                "code": asset("viz_structure.py"),
            },
        ],
        "interactive_demos": [
            {
                "title": "The Grokking Laboratory: Sweeping Weight Decay Through Criticality",
                "description": (
                    "A live rig for the training-dynamics half of the theory. Four sliders "
                    "control the weight decay lambda, the data drive s, the activation threshold "
                    "theta and the initial weight w0. The upper canvas animates the exact "
                    "gradient-flow trajectory w(t) = s/lambda + (w0 - s/lambda)exp(-lambda t) "
                    "against the regularized optimum s/lambda and the threshold theta, shading "
                    "the silent plateau and marking the exact crossing time; the rectified "
                    "output is drawn alongside so the flat-then-sudden shape is directly "
                    "visible. The lower canvas plots the whole delay curve tau(lambda) together "
                    "with its sharp asymptotic lambda_c^{-1} log(1/mu), with the critical decay "
                    "marked. Push lambda toward lambda_c = s/theta and the delay diverges "
                    "logarithmically while the readout tau/log(1/mu) creeps toward theta/s; push "
                    "past lambda_c and the panel turns red, because the transition no longer "
                    "happens at all -- not late, but never. Two collapsible sections derive the "
                    "closed-form crossing time and explain why the sharp constant is exactly the "
                    "reciprocal critical decay."
                ),
                "html": asset("widget_lab.html"),
            },
            {
                "title": "Ghosts and Bottlenecks: Watching a Delay Appear From an Absence",
                "description": (
                    "An exploration of the second mechanism, where the slowdown is caused by "
                    "equilibria that no longer exist. The left canvas is the live bifurcation "
                    "diagram of x' = mu - x^2, with the stable branch +sqrt(mu), the unstable "
                    "branch -sqrt(mu), and the shaded subcritical region where nothing exists; "
                    "the right canvas shows the corresponding dynamics -- numerically integrated "
                    "orbits converging to the stable branch above threshold, and the exact "
                    "Riccati trajectory x(t) = -k tan(kt) with its long plateau below. Drag mu "
                    "across zero and watch a finite passage time materialize out of an empty "
                    "phase portrait. Drag the observation level A across two orders of magnitude "
                    "and watch the readout sqrt(|mu|)*T barely move, which is the "
                    "level-independence that identifies a genuine bottleneck. A second canvas "
                    "runs the race between the two laws on log-log axes and marks the crossover "
                    "point; crank the logarithmic constant K as high as you like and the "
                    "crossover merely shifts -- the bottleneck still wins. Three collapsible "
                    "sections derive the exact passage time, explain why the constant is pi and "
                    "why A disappears from the limit, and prove that the logarithm loses to "
                    "every inverse power."
                ),
                "html": asset("widget_bottleneck.html"),
            },
            {
                "title": "Tropical Rigidity: Build a Network That Un-Groks",
                "description": (
                    "A hands-on demonstration that permanence of the transition is a theorem "
                    "with a hypothesis, not a law of nature. Six hidden units can be switched on "
                    "and off, each with its own signal, hidden bias and output weight, and the "
                    "output bias is adjustable; the canvas draws the network output along the "
                    "ray, shades the failure set, overlays the linearization c + tS, and marks "
                    "the predicted zero-bias delay |c|/S. With every output weight non-negative "
                    "the output is a maximum-plus, piecewise-linear convex function, so the "
                    "shaded region is always a single block no matter how the sliders are moved "
                    "-- the widget counts the blocks live and confirms it. Push one output "
                    "weight below zero and the guarantee evaporates: the built-in presets load "
                    "the width-three hat network, which groks at t = 1/2 and un-groks at "
                    "t = 3/2, and a comb of tents whose failure set splits into ever more "
                    "components. Setting all hidden biases to zero makes the blue curve snap "
                    "onto the dotted linearization, exhibiting the exact delay |c|/S. Three "
                    "collapsible sections give the three-line convexity proof, the exact failure "
                    "sets of the hat and comb networks, and the reading of the delay formula as "
                    "prejudice divided by evidence."
                ),
                "html": asset("widget_rigidity.html"),
            },
        ],
        "interactive_layout": asset("interactive_layout.md"),
        "lean_proofs": lean_blob,
        "future_directions": FUTURE_DIRECTIONS,
        "modules": {"demo": demo_src},
        "lean_files": LEAN_FILES,
    }

    with open(os.path.join(ROOT, "PACKAGE.json"), "w", encoding="utf-8") as fh:
        json.dump(package, fh, indent=2, ensure_ascii=False)
    print("wrote PACKAGE.json")


if __name__ == "__main__":
    main()


"""
Focused demonstration: the two sharp constants, and identifying the mechanism.
==============================================================================

This demo isolates the headline asymptotics and shows that they are strong
enough to *identify* which slowdown mechanism produced an observed delay.

  * LAW I  (threshold relaxation under weight decay):
        tau(lam) / log(1/mu)  ->  1/lam_c = theta/s      as lam -> lam_c-.
  * LAW II (saddle-node bottleneck):
        sqrt(|mu|) * T(sqrt(|mu|), A)  ->  pi            as mu -> 0-,
    for every observation level A > 0 -- the constant does not depend on A.

It then generates delay data from each mechanism, hands it to a blind
classifier that knows only the numbers, and checks that the recovered leading
constants match the predicted values pi and 1/lam_c.

Standard library only.  Run:  python3 demo_sharp_constants.py
"""

from __future__ import annotations

import math
from typing import List, Sequence, Tuple


# --------------------------------------------------------------------------- #
# The two delay laws                                                            #
# --------------------------------------------------------------------------- #


def relaxation_delay(mu: float, s: float, theta: float, w0: float) -> float:
    """Exact crossing time of weight-decayed gradient flow at bifurcation
    parameter mu = s/lam - theta, i.e. at lam = s/(theta + mu)."""
    lam = s / (theta + mu)
    return math.log((s / lam - w0) / mu) / lam


def bottleneck_delay(mu: float, level: float) -> float:
    """Passage time 2 arctan(A/k)/k of x' = -mu - x^2 (mu > 0 here denotes |mu|)."""
    k = math.sqrt(mu)
    return 2.0 * math.atan(level / k) / k


# --------------------------------------------------------------------------- #
# Blind two-hypothesis classifier                                               #
# --------------------------------------------------------------------------- #


def fit_scale(xs: Sequence[float], ys: Sequence[float]) -> Tuple[float, float]:
    """Least-squares fit y ~ k x through the origin; return (k, relative RMS)."""
    den = sum(x * x for x in xs)
    k = sum(x * y for x, y in zip(xs, ys)) / den
    ss = sum((y - k * x) ** 2 for x, y in zip(xs, ys))
    return k, math.sqrt(ss / sum(y * y for y in ys))


def loglog_slope(mus: Sequence[float], delays: Sequence[float]) -> float:
    lx = [math.log(m) for m in mus]
    ly = [math.log(d) for d in delays]
    n = len(lx)
    mx, my = sum(lx) / n, sum(ly) / n
    return (sum((a - mx) * (b - my) for a, b in zip(lx, ly))
            / sum((a - mx) ** 2 for a in lx))


def classify(mus: Sequence[float], delays: Sequence[float]) -> str:
    slope = loglog_slope(mus, delays)
    k_log, r_log = fit_scale([math.log(1.0 / m) for m in mus], delays)
    c_sqrt, r_sqrt = fit_scale([m ** -0.5 for m in mus], delays)
    verdict = "BOTTLENECK" if r_sqrt < r_log else "RELAXATION"
    return (f"    log-log slope            : {slope:+.5f}\n"
            f"    fit  K log(1/mu)         : K = {k_log:.6f}   rel.resid = {r_log:.3e}\n"
            f"    fit  C mu^(-1/2)         : C = {c_sqrt:.6f}   rel.resid = {r_sqrt:.3e}\n"
            f"    verdict                  : {verdict}")


# --------------------------------------------------------------------------- #
# Demonstrations                                                                #
# --------------------------------------------------------------------------- #


def law_one() -> None:
    print("=" * 78)
    print("LAW I -- RELAXATION.   tau / log(1/mu)  ->  theta/s = 1/lam_c")
    print("=" * 78)
    s, theta, w0 = 1.0, 0.5, 0.0
    lam_c = s / theta
    print(f"  s = {s}, theta = {theta}, w0 = {w0}   =>   lam_c = {lam_c},  1/lam_c = {1/lam_c}")
    print(f"\n  {'mu':>12} {'lam':>12} {'tau':>14} {'tau/log(1/mu)':>18}")
    mu = 1e-2
    for _ in range(9):
        lam = s / (theta + mu)
        tau = relaxation_delay(mu, s, theta, w0)
        print(f"  {mu:>12.2e} {lam:>12.8f} {tau:>14.6f} {tau/math.log(1/mu):>18.10f}")
        mu /= 100.0
    print(f"\n  -> converging to {1/lam_c:.10f}.  The bounded term log(theta - w0) is")
    print("     washed out by the normalization; only the divergent log(1/mu) survives.")


def law_two() -> None:
    print()
    print("=" * 78)
    print("LAW II -- BOTTLENECK.   sqrt(|mu|) * T  ->  pi,  for every level A")
    print("=" * 78)
    print(f"  pi = {math.pi:.12f}")
    levels = (0.01, 1.0, 100.0, 1e6)
    header = "".join(f"{'A=' + f'{A:g}':>18}" for A in levels)
    print(f"\n  {'|mu|':>12}{header}")
    mu = 1e-2
    for _ in range(8):
        row = "".join(f"{math.sqrt(mu) * bottleneck_delay(mu, A):>18.10f}" for A in levels)
        print(f"  {mu:>12.2e}{row}")
        mu /= 100.0
    print("\n  -> every column tends to pi.  The observation level A drops out of the")
    print("     limit: asymptotically all the time is spent inside the bottleneck.")


def identification() -> None:
    print()
    print("=" * 78)
    print("IDENTIFYING THE MECHANISM FROM DELAY DATA ALONE")
    print("=" * 78)
    s, theta, w0 = 1.0, 0.5, 0.0
    lam_c = s / theta
    mus: List[float] = [10.0 ** (-2 - 0.6 * i) for i in range(14)]

    print("\n  (i) data generated by threshold relaxation")
    delays = [relaxation_delay(m, s, theta, w0) for m in mus]
    print(classify(mus, delays))
    print(f"    predicted constant 1/lam_c = {1/lam_c:.6f}")

    print("\n  (ii) data generated by a saddle-node bottleneck, A = 1")
    delays = [bottleneck_delay(m, 1.0) for m in mus]
    print(classify(mus, delays))
    print(f"    predicted constant pi      = {math.pi:.6f}")

    print("\n  (iii) both mechanisms present (delays add)")
    delays = [relaxation_delay(m, s, theta, w0) + bottleneck_delay(m, 1.0) for m in mus]
    print(classify(mus, delays))
    print("    -> the bottleneck exponent dominates the sum, exactly as predicted:")
    print("       sqrt(mu) log(1/mu) -> 0, so the logarithmic part is asymptotically")
    print("       invisible and the fitted constant is again close to pi.")


def main() -> None:
    print()
    law_one()
    law_two()
    identification()
    print()
    print("=" * 78)
    print("Two mechanisms, two exponents, two exact constants: 1/lam_c and pi.")
    print("=" * 78)


if __name__ == "__main__":
    main()


"""
Visualization: the two delay laws and their sharp constants.
============================================================

Produces a four-panel figure.

  (a) Log-log plot of the two delays against the distance mu to criticality.
      The saddle-node bottleneck passage time T(sqrt(mu), A) = 2 arctan(A/sqrt(mu))/sqrt(mu)
      is a straight line of slope -1/2; the relaxation crossing time
      tau(lam) = lam^{-1} log((s/lam - w0)/mu) is visibly sub-power-law.

  (b) Convergence of the normalized relaxation delay tau/log(1/mu) to the sharp
      constant 1/lam_c = theta/s.

  (c) Convergence of sqrt(-mu) * T to the sharp constant pi, for several
      observation levels A, illustrating that the constant does not depend on A.

  (d) The ratio (logarithmic delay) / (bottleneck delay), which tends to zero:
      the bottleneck mechanism always wins near criticality.

Requires numpy and matplotlib.
"""

from __future__ import annotations

import math
from typing import Sequence

import matplotlib.pyplot as plt
import numpy as np


def cross_time(lam: float, s: float, w0: float, theta: float) -> float:
    """Exact crossing time of weight-decayed gradient flow."""
    return math.log((s / lam - w0) / (s / lam - theta)) / lam


def passage_time(k: float, level: float) -> float:
    """Saddle-node bottleneck passage time from +A to -A."""
    return 2.0 * math.atan(level / k) / k


def main() -> None:
    s, theta, w0 = 1.0, 0.5, 0.0
    lam_c = s / theta

    mus = np.logspace(-9, -1, 400)
    # relaxation: mu = s/lam - theta  =>  lam = s/(theta + mu)
    lams = s / (theta + mus)
    relax = np.array([cross_time(l, s, w0, theta) for l in lams])
    level_A = 1.0
    bott = np.array([passage_time(math.sqrt(m), level_A) for m in mus])

    fig, axes = plt.subplots(2, 2, figsize=(13, 9))
    fig.suptitle(
        "Two laws of delayed generalization: exponents and sharp constants",
        fontsize=15, fontweight="bold",
    )

    # ---------------- (a) log-log comparison ----------------
    ax = axes[0, 0]
    ax.loglog(mus, relax, lw=2.2, label=r"relaxation  $\tau(\lambda)$")
    ax.loglog(mus, bott, lw=2.2, label=r"bottleneck  $T(\sqrt{\mu},A)$")
    ax.loglog(mus, math.pi / np.sqrt(mus), "--", lw=1.4, color="grey",
              label=r"$\pi\,\mu^{-1/2}$  (slope $-1/2$)")
    ax.set_xlabel(r"distance to criticality  $\mu$")
    ax.set_ylabel("delay")
    ax.set_title("(a)  the two divergences, log-log")
    ax.invert_xaxis()
    ax.grid(alpha=0.3, which="both")
    ax.legend(fontsize=9)

    # ---------------- (b) sharp constant 1/lam_c ----------------
    ax = axes[0, 1]
    ratio = relax / np.log(1.0 / mus)
    ax.semilogx(mus, ratio, lw=2.2, color="tab:blue")
    ax.axhline(1.0 / lam_c, ls="--", color="crimson", lw=1.6,
               label=fr"$1/\lambda_c = \theta/s = {1/lam_c:.3f}$")
    ax.set_xlabel(r"$\mu$")
    ax.set_ylabel(r"$\tau(\lambda)\,/\,\log(1/\mu)$")
    ax.set_title(r"(b)  relaxation constant:  $\tau \sim \lambda_c^{-1}\log(1/\mu)$")
    ax.invert_xaxis()
    ax.grid(alpha=0.3)
    ax.legend(fontsize=10)

    # ---------------- (c) sharp constant pi, several A ----------------
    ax = axes[1, 0]
    for level in (0.1, 1.0, 10.0, 1000.0):
        vals = [math.sqrt(m) * passage_time(math.sqrt(m), level) for m in mus]
        ax.semilogx(mus, vals, lw=2.0, label=f"$A = {level:g}$")
    ax.axhline(math.pi, ls="--", color="crimson", lw=1.6, label=r"$\pi$")
    ax.set_xlabel(r"$|\mu|$")
    ax.set_ylabel(r"$\sqrt{|\mu|}\;T(\sqrt{|\mu|},A)$")
    ax.set_title(r"(c)  bottleneck constant is $\pi$, independent of the level $A$")
    ax.invert_xaxis()
    ax.set_ylim(0, 3.6)
    ax.grid(alpha=0.3)
    ax.legend(fontsize=9)

    # ---------------- (d) the dichotomy ----------------
    ax = axes[1, 1]
    ax.loglog(mus, relax / bott, lw=2.2, color="tab:purple")
    ax.axhline(1.0, ls=":", color="black", lw=1.2)
    ax.set_xlabel(r"$\mu$")
    ax.set_ylabel("relaxation delay / bottleneck delay")
    ax.set_title("(d)  the ratio tends to 0: the bottleneck wins")
    ax.invert_xaxis()
    ax.grid(alpha=0.3, which="both")

    fig.tight_layout(rect=(0, 0, 1, 0.96))
    fig.savefig("delay_laws.png", dpi=150)
    print("wrote delay_laws.png")


if __name__ == "__main__":
    main()


"""
Visualization: the structural picture behind delayed generalization.
====================================================================

Produces a four-panel figure.

  (a) The ramped output of a two-layer ReLU network with non-negative output
      weights: a convex piecewise-linear curve starting at the output bias c<0,
      with its unique sharp threshold and the delay sandwich
      |c|/S <= tau <= (|c|/a_j0 - b_j0)/g_j0 marked.

  (b) Tropical rigidity broken: the width-3 "hat" network
      H(t) = -1/2 + relu(t) - 2 relu(t-1) + relu(t-2) groks at t = 1/2 and
      un-groks at t = 3/2, and the width-3k comb network relapses k times.

  (c) The saddle-node bifurcation diagram of x' = mu - x^2, with the stable
      branch +sqrt(mu), the unstable branch -sqrt(mu), and the empty
      subcritical phase; the cubic reduced loss x^3/3 - mu x is inset.

  (d) The bottleneck below the saddle node: the exact Riccati trajectories
      x(t) = -k tan(k t) for several k, showing the plateau near x = 0 whose
      length is 2 arctan(A/k)/k ~ pi/sqrt(|mu|).

Requires numpy and matplotlib.
"""

from __future__ import annotations

import math
from typing import List, Sequence, Tuple

import matplotlib.pyplot as plt
import numpy as np


def relu(u: np.ndarray) -> np.ndarray:
    return np.maximum(u, 0.0)


def ramp(signals: Sequence[float], biases: Sequence[float],
         weights: Sequence[float], c: float, t: np.ndarray) -> np.ndarray:
    out = np.full_like(t, c, dtype=float)
    for g, b, a in zip(signals, biases, weights):
        out = out + a * relu(t * g + b)
    return out


def comb(k: int, t: np.ndarray) -> np.ndarray:
    out = np.full_like(t, -0.5, dtype=float)
    for i in range(k):
        out = out + relu(t - 2 * i) - 2 * relu(t - 2 * i - 1) + relu(t - 2 * i - 2)
    return out


def main() -> None:
    fig, axes = plt.subplots(2, 2, figsize=(13, 9))
    fig.suptitle("The structure of a delayed transition", fontsize=15, fontweight="bold")

    # ---------------- (a) sharp threshold and sandwich ----------------
    ax = axes[0, 0]
    signals = [1.0, 0.5, 2.0, 0.25]
    biases = [0.0, -0.3, -1.0, -0.1]
    weights = [0.4, 1.2, 0.7, 2.0]
    c = -3.0
    t = np.linspace(-0.5, 3.5, 2000)
    y = ramp(signals, biases, weights, c, t)
    S = sum(a * g for a, g in zip(weights, signals))
    lower = abs(c) / S
    upper = min((abs(c) / a - b) / g for g, b, a in zip(signals, biases, weights)
                if a > 0 and g > 0)
    tau = t[np.argmax(y > 0)]
    ax.plot(t, y, lw=2.4, color="tab:blue")
    ax.axhline(0, color="black", lw=1)
    ax.axvspan(lower, upper, color="orange", alpha=0.18, label="delay sandwich")
    ax.axvline(tau, color="crimson", ls="--", lw=1.6, label=fr"sharp threshold $\tau\approx{tau:.3f}$")
    ax.plot(t, c + t * S, ":", color="grey", lw=1.4, label=r"linearization $c + tS$")
    ax.set_xlabel("ramp parameter $t$")
    ax.set_ylabel("network output")
    ax.set_title("(a)  convex ramp, unique threshold, sandwich")
    ax.set_ylim(-3.6, 4)
    ax.grid(alpha=0.3)
    ax.legend(fontsize=9, loc="upper left")

    # ---------------- (b) relapses ----------------
    ax = axes[0, 1]
    t = np.linspace(-0.5, 8.5, 4000)
    ax.plot(t, comb(4, t), lw=2.0, color="tab:orange", label="comb network (width 12)")
    ax.plot(t, comb(1, t), lw=2.6, ls="--", color="tab:blue", zorder=3,
            label="hat network (width 3)")
    ax.axhline(0, color="black", lw=1)
    ax.fill_between(t, -1, 0, where=(comb(4, t) <= 0), color="grey", alpha=0.15)
    ax.set_xlabel("ramp parameter $t$")
    ax.set_ylabel("network output")
    ax.set_title("(b)  signed output weights: grok, un-grok, re-grok")
    ax.set_ylim(-0.8, 0.8)
    ax.grid(alpha=0.3)
    ax.legend(fontsize=9)

    # ---------------- (c) bifurcation diagram ----------------
    ax = axes[1, 0]
    mus = np.linspace(0, 2, 400)
    ax.plot(mus, np.sqrt(mus), lw=2.6, color="tab:green", label=r"stable branch $+\sqrt{\mu}$")
    ax.plot(mus, -np.sqrt(mus), lw=2.6, ls="--", color="tab:red",
            label=r"unstable branch $-\sqrt{\mu}$")
    ax.axvline(0, color="black", lw=1)
    ax.axvspan(-1, 0, color="grey", alpha=0.12)
    ax.text(-0.75, 1.1, "no equilibrium\n(bottleneck)", ha="center", fontsize=9)
    ax.set_xlim(-1, 2)
    ax.set_xlabel(r"bifurcation parameter $\mu$")
    ax.set_ylabel(r"equilibrium $x$")
    ax.set_title(r"(c)  saddle node of $\dot x = \mu - x^2$")
    ax.grid(alpha=0.3)
    ax.legend(fontsize=9, loc="lower right")

    inset = ax.inset_axes((0.06, 0.06, 0.34, 0.34))
    xs = np.linspace(-1.6, 1.6, 400)
    for mu, style in ((1.0, "-"), (0.0, ":"), (-0.5, "--")):
        inset.plot(xs, xs ** 3 / 3 - mu * xs, style, lw=1.4, label=fr"$\mu={mu:g}$")
    inset.set_title(r"$V_\mu(x)=\frac{x^3}{3}-\mu x$", fontsize=7)
    inset.tick_params(labelsize=6)
    inset.legend(fontsize=5)

    # ---------------- (d) bottleneck trajectories ----------------
    ax = axes[1, 1]
    level = 2.0
    for k in (0.6, 0.3, 0.15, 0.075):
        half = math.atan(level / k) / k
        ts = np.linspace(-half, half, 2000)
        ax.plot(ts, -k * np.tan(k * ts), lw=2.0,
                label=fr"$\mu=-{k**2:.4f}$,  $T={2*half:.1f}$")
    ax.axhline(0, color="black", lw=1)
    ax.set_xlabel("time $t$")
    ax.set_ylabel("state $x(t)$")
    ax.set_title(r"(d)  the ghost bottleneck: $x(t)=-k\tan(kt)$,  $T\sim\pi|\mu|^{-1/2}$")
    ax.set_ylim(-level * 1.1, level * 1.1)
    ax.grid(alpha=0.3)
    ax.legend(fontsize=8)

    fig.tight_layout(rect=(0, 0, 1, 0.96))
    fig.savefig("delay_structure.png", dpi=150)
    print("wrote delay_structure.png")


if __name__ == "__main__":
    main()
