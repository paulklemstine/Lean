"""Numerical demonstrations for exact Betti-count recovery from noisy barcodes.

This script mirrors the formal results:

  * persistence(b)            = b.death - b.birth
  * bettiCount(tau, B)        = #{ i : tau < persistence(B[i]) }
  * betti_antitone            : tau1 <= tau2  =>  bettiCount(tau2) <= bettiCount(tau1)
  * threshold_iff_of_noise... : |x-y| <= eps, m <= |y-tau|, 2*eps < m  =>  (tau<x <=> tau<y)
  * betti_recovered           : under the margin condition, noisy Betti count
                                equals the true Betti count exactly.

The governing dimensionless quantity is the margin-to-noise ratio R = m / (2*eps);
recovery is guaranteed exactly when R > 1, and the constant 2*eps is tight.

Pure standard library; run with `python3 demo.py`.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Callable, List, Sequence, Tuple
import random


# --------------------------------------------------------------------------- #
# Data model (mirrors Bar / persistence in the Lean development)
# --------------------------------------------------------------------------- #
@dataclass(frozen=True)
class Bar:
    """A persistence bar: a birth time and a death time."""
    birth: float
    death: float


def persistence(b: Bar) -> float:
    """The persistence (lifetime) of a bar: death - birth."""
    return b.death - b.birth


def betti_count(tau: float, barcode: Sequence[Bar]) -> int:
    """Number of bars whose persistence strictly exceeds the threshold tau."""
    return sum(1 for b in barcode if tau < persistence(b))


def threshold_side(tau: float, value: float) -> bool:
    """Returns True iff `value` is strictly above the threshold `tau`."""
    return tau < value


def margin_to_noise_ratio(m: float, eps: float) -> float:
    """The dimensionless control parameter R = m / (2*eps)."""
    return m / (2.0 * eps)


# --------------------------------------------------------------------------- #
# Demo 1: threshold stability for a single bar
# --------------------------------------------------------------------------- #
def demo_threshold_stability() -> None:
    """Verify: if |x-y| <= eps, m <= |y-tau|, and 2*eps < m, then x and y
    lie on the same side of tau (Theorem `threshold_iff_of_noise_margin`)."""
    print("=" * 70)
    print("DEMO 1: Pointwise threshold stability  (R = m / (2*eps) > 1)")
    print("=" * 70)
    tau = 1.0
    eps = 0.2
    m = 0.5  # 2*eps = 0.4 < 0.5 = m, so R = 0.5/0.4 = 1.25 > 1
    R = margin_to_noise_ratio(m, eps)
    print(f"tau={tau}, eps={eps}, m={m}, R = m/(2*eps) = {R:.3f}\n")

    rng = random.Random(0)
    failures = 0
    for _ in range(100_000):
        # true value y separated from tau by at least m
        if rng.random() < 0.5:
            y = tau + m + rng.random() * 3.0      # above
        else:
            y = tau - m - rng.random() * 3.0      # below
        x = y + rng.uniform(-eps, eps)            # noisy observation, |x-y|<=eps
        if threshold_side(tau, x) != threshold_side(tau, y):
            failures += 1
    print(f"random trials: 100000   side-flips (should be 0): {failures}")
    print("PASS" if failures == 0 else "FAIL")
    print()


# --------------------------------------------------------------------------- #
# Demo 2: exact Betti-count recovery
# --------------------------------------------------------------------------- #
def demo_betti_recovery() -> None:
    """Build a true barcode whose persistences are all m-separated from tau,
    corrupt every bar within eps, and check the Betti count is recovered
    exactly (Theorem `betti_recovered`)."""
    print("=" * 70)
    print("DEMO 2: Exact Betti-count recovery from a fully corrupted barcode")
    print("=" * 70)
    tau = 1.0
    eps = 0.15
    m = 0.5
    R = margin_to_noise_ratio(m, eps)
    rng = random.Random(42)

    # True persistences: 6 long (signal, > tau+m) and 9 short (noise, < tau-m).
    true_pers = [tau + m + rng.random() * 2.0 for _ in range(6)] + \
                [max(0.0, tau - m - rng.random() * 0.5) for _ in range(9)]
    true_bars = [Bar(birth=0.0, death=p) for p in true_pers]

    # Noisy barcode: jitter birth and death so |noisy - true| <= eps.
    noisy_bars: List[Bar] = []
    for b in true_bars:
        db = rng.uniform(-eps / 2, eps / 2)
        dd = rng.uniform(-eps / 2, eps / 2)
        noisy_bars.append(Bar(birth=b.birth + db, death=b.death + dd))

    eps_obs = max(abs(persistence(n) - persistence(t))
                  for n, t in zip(noisy_bars, true_bars))
    m_obs = min(abs(persistence(t) - tau) for t in true_bars)
    bt = betti_count(tau, true_bars)
    bn = betti_count(tau, noisy_bars)

    print(f"tau={tau}, eps(budget)={eps}, m(margin)={m}, R = {R:.3f}")
    print(f"observed max noise eps_obs = {eps_obs:.4f}  (<= eps: {eps_obs <= eps})")
    print(f"observed margin   m_obs    = {m_obs:.4f}  (2*eps < m_obs: {2*eps < m_obs})")
    print(f"true  Betti count = {bt}")
    print(f"noisy Betti count = {bn}")
    print("PASS (exact recovery)" if bt == bn else "FAIL")
    print()


# --------------------------------------------------------------------------- #
# Demo 3: monotonicity (antitone Betti curve)
# --------------------------------------------------------------------------- #
def betti_curve(barcode: Sequence[Bar], thresholds: Sequence[float]) -> List[int]:
    """The persistence Betti curve evaluated at each threshold."""
    return [betti_count(t, barcode) for t in thresholds]


def demo_monotonicity() -> None:
    """Check that the Betti count is antitone in the threshold
    (Theorem `betti_antitone`)."""
    print("=" * 70)
    print("DEMO 3: Antitonicity of the Betti count in the threshold")
    print("=" * 70)
    rng = random.Random(7)
    bars = [Bar(0.0, rng.random() * 5.0) for _ in range(40)]
    thresholds = [i * 0.25 for i in range(21)]  # 0.0 .. 5.0
    curve = betti_curve(bars, thresholds)
    antitone = all(curve[i] >= curve[i + 1] for i in range(len(curve) - 1))
    print("threshold : betti")
    for t, c in zip(thresholds, curve):
        print(f"  {t:4.2f}   : {c}")
    print("non-increasing staircase:", "PASS" if antitone else "FAIL")
    print()


# --------------------------------------------------------------------------- #
# Demo 4: tightness of the constant 2*eps  (boundary R = 1)
# --------------------------------------------------------------------------- #
def demo_tightness() -> None:
    """Show that at R = 1 (m = 2*eps) recovery can fail: move birth up and
    death down each by eps so the persistence drops by exactly 2*eps."""
    print("=" * 70)
    print("DEMO 4: Tightness of 2*eps  -- recovery can fail at R = 1")
    print("=" * 70)
    tau = 1.0
    eps = 0.25
    m = 2.0 * eps  # R = 1 exactly: the knife's edge
    R = margin_to_noise_ratio(m, eps)

    # One true bar just above threshold, persistence = tau + m.
    true_bar = Bar(birth=0.0, death=tau + m)
    # Adversarial corruption: birth +eps, death -eps  => persistence drops 2*eps.
    noisy_bar = Bar(birth=true_bar.birth + eps, death=true_bar.death - eps)

    print(f"tau={tau}, eps={eps}, m=2*eps={m}, R = {R:.3f}")
    print(f"true  persistence = {persistence(true_bar):.3f}  -> above tau: "
          f"{threshold_side(tau, persistence(true_bar))}")
    print(f"noisy persistence = {persistence(noisy_bar):.3f}  -> above tau: "
          f"{threshold_side(tau, persistence(noisy_bar))}")
    bt = betti_count(tau, [true_bar])
    bn = betti_count(tau, [noisy_bar])
    print(f"true Betti = {bt}, noisy Betti = {bn}")
    print("recovery FAILS at R = 1 (as expected): 2*eps is tight"
          if bt != bn else "recovered (boundary case)")
    print()


def main() -> None:
    demo_threshold_stability()
    demo_betti_recovery()
    demo_monotonicity()
    demo_tightness()


if __name__ == "__main__":
    main()
