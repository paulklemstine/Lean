"""Numerical demonstrations for
"Social Credit Scores as Topological Invariants".

This self-contained script illustrates the three pillars of the theory:

1. The affine credit-update dynamics  x -> c + k*x  and its global attractor
   x* = c / (1 - k)  for damping  0 <= k < 1.
2. The ternary verdict encoding  Phi(a) = sum_n (2*[a_n]) / 3^(n+1),  whose
   range is the middle-thirds Cantor set: bounds in [0,1], the
   iterated-function-system self-similarity  C = C/3 U (C/3 + 2/3),  and
   injectivity of the encoding.
3. The threshold tier classifier and the inevitability of a phase transition
   at the cutoff.

Run:  python demo.py
"""

from __future__ import annotations

from typing import Callable, List, Sequence


# ---------------------------------------------------------------------------
# 1. Affine credit-update dynamics and its attractor
# ---------------------------------------------------------------------------

def credit_step(c: float, k: float, x: float) -> float:
    """One round of credit revision: reward c plus damped memory k*x."""
    return c + k * x


def credit_iterate(c: float, k: float, x0: float, n: int) -> float:
    """Score after n rounds of revision starting from x0."""
    x = x0
    for _ in range(n):
        x = credit_step(c, k, x)
    return x


def credit_equilibrium(c: float, k: float) -> float:
    """The long-run equilibrium score c / (1 - k)  (requires k != 1)."""
    return c / (1.0 - k)


def demo_attractor() -> None:
    print("=" * 68)
    print("1. AFFINE ATTRACTOR:  x_{n+1} = c + k*x_n  ->  c/(1-k)")
    print("=" * 68)
    c, k = 0.4, 0.7
    star = credit_equilibrium(c, k)
    print(f"reward c = {c}, damping k = {k},  equilibrium c/(1-k) = {star:.6f}")
    for x0 in (0.0, 1.0, 5.0, -3.0):
        seq = [credit_iterate(c, k, x0, n) for n in range(0, 40, 8)]
        traj = ", ".join(f"{v:.5f}" for v in seq)
        final = credit_iterate(c, k, x0, 200)
        print(f"  x0={x0:6.2f}: [{traj}] ... -> {final:.6f}  "
              f"(|err|={abs(final-star):.2e})")
    print("  All initial conditions forget x0 and converge to the same point.\n")


# ---------------------------------------------------------------------------
# 2. Ternary verdict encoding and the Cantor-set attractor
# ---------------------------------------------------------------------------

def cantor_encode(verdicts: Sequence[bool]) -> float:
    """Phi(a) = sum_n (2 if a_n else 0) / 3^(n+1) over a finite prefix."""
    total = 0.0
    for n, a in enumerate(verdicts):
        total += (2.0 if a else 0.0) / (3.0 ** (n + 1))
    return total


def cantor_encode_bounds(verdicts: Sequence[bool]) -> tuple[float, float]:
    """Truncated score and rigorous [lo, hi] bracket using tail bound 3^-N."""
    lo = cantor_encode(verdicts)
    hi = lo + 3.0 ** (-len(verdicts))
    return lo, hi


def cantor_decode(x: float, depth: int) -> List[bool]:
    """Recover verdicts from a score by inverting the IFS.

    Emits False and maps x -> 3x when x < 1/3; emits True and maps
    x -> 3x - 2 when x >= 2/3.  A value in the open middle third means
    x is NOT in the Cantor set.
    """
    out: List[bool] = []
    for _ in range(depth):
        if x < 1.0 / 3.0:
            out.append(False)
            x = 3.0 * x
        elif x >= 2.0 / 3.0:
            out.append(True)
            x = 3.0 * x - 2.0
        else:
            raise ValueError(f"value {x:.6f} lies in a gap: not in the Cantor set")
    return out


def demo_cantor() -> None:
    print("=" * 68)
    print("2. CANTOR-SET REPUTATION SPACE")
    print("=" * 68)

    histories = {
        "all flagged     ": [False] * 12,
        "all commended   ": [True] * 12,
        "alternating     ": [i % 2 == 0 for i in range(12)],
        "one early flag  ": [False] + [True] * 11,
        "one early comm. ": [True] + [False] * 11,
    }
    print("Scores lie in [0,1] (Theorem: 0 <= Phi(a) <= 1):")
    for name, h in histories.items():
        lo, hi = cantor_encode_bounds(h)
        print(f"  {name}: Phi in [{lo:.6f}, {hi:.6f}]")

    print("\nSelf-similarity  Phi(false . a) = Phi(a)/3,  "
          "Phi(true . a) = Phi(a)/3 + 2/3:")
    a = [True, False, True, False, True]
    base = cantor_encode(a)
    left = cantor_encode([False] + a)
    right = cantor_encode([True] + a)
    print(f"  Phi(a)          = {base:.6f}")
    print(f"  Phi(false . a)  = {left:.6f}   vs  Phi(a)/3       = {base/3:.6f}")
    print(f"  Phi(true  . a)  = {right:.6f}   vs  Phi(a)/3 + 2/3 = {base/3 + 2/3:.6f}")

    print("\nInjectivity: distinct histories -> distinct scores; decoding recovers them:")
    a = [True, True, False, True, False, False, True]
    x = cantor_encode(a)
    recovered = cantor_decode(x, len(a))
    print(f"  history  = {[int(v) for v in a]}")
    print(f"  score    = {x:.9f}")
    print(f"  decoded  = {[int(v) for v in recovered]}  (match: {recovered == a})")

    print("\nGap-jump: flipping the FIRST verdict teleports across the middle third:")
    lo_hist = [False] + [True] * 10
    hi_hist = [True] + [True] * 10
    print(f"  first = flagged  -> {cantor_encode(lo_hist):.6f}  (in [0, 1/3])")
    print(f"  first = commended-> {cantor_encode(hi_hist):.6f}  (in [2/3, 1])")
    print("  The score never lands in the open interval (1/3, 2/3).\n")


# ---------------------------------------------------------------------------
# 3. Tier classifier and phase transition
# ---------------------------------------------------------------------------

def tier(t: float, x: float) -> bool:
    """Tier of score x at threshold t: True (trusted) iff t <= x."""
    return t <= x


def find_sensitive_point(t: float, delta: float) -> float:
    """A score within delta of the cutoff whose tier differs from tier(t,t)."""
    return t - delta / 2.0


def demo_phase_transition() -> None:
    print("=" * 68)
    print("3. PHASE TRANSITION AT THE CUTOFF")
    print("=" * 68)
    t = 0.5
    print(f"threshold t = {t}: tier(t, t) = {tier(t, t)}")
    print("Sensitivity: arbitrarily small perturbations flip the tier at t:")
    for delta in (1e-1, 1e-3, 1e-6, 1e-9):
        x = find_sensitive_point(t, delta)
        print(f"  delta={delta:.0e}: x={x:.10f}, tier={tier(t, x)} "
              f"(flipped: {tier(t, x) != tier(t, t)})")

    print("\nInevitability: a continuous binary classifier of the connected line")
    print("must be constant, so any separating classifier is discontinuous.")
    classifier: Callable[[float], bool] = lambda x: tier(t, x)
    samples = [0.0, 0.25, 0.49, 0.5, 0.51, 0.75, 1.0]
    labels = [int(classifier(x)) for x in samples]
    print(f"  scores  = {samples}")
    print(f"  tiers   = {labels}  ->  separates members, hence has a jump\n")


if __name__ == "__main__":
    demo_attractor()
    demo_cantor()
    demo_phase_transition()
    print("All demonstrations completed.")
