"""
Cybernetic Symbiosis: numerical demonstrations of the co-adaptation convergence law.

This self-contained script demonstrates the main results of the accompanying paper
for the scalar human-decoder mutual-adaptation loop:

    h_{n+1} = (1 - a) * h_n + a * d_n     (human nudges toward decoder)
    d_{n+1} = (1 - b) * d_n + b * h_n     (decoder nudges toward human)

with disagreement e_n = h_n - d_n obeying the exact recursion

    e_{n+1} = (1 - a - b) * e_n,   hence   e_n = (1 - a - b)^n * e_0.

Everything is implemented from scratch using only the Python standard library.
"""

from __future__ import annotations

import math
from typing import List, Tuple


# ---------------------------------------------------------------------------
# Core dynamics
# ---------------------------------------------------------------------------

def step(a: float, b: float, state: Tuple[float, float]) -> Tuple[float, float]:
    """One round of the co-adaptation loop from state (h, d)."""
    h, d = state
    h_next = (1.0 - a) * h + a * d
    d_next = (1.0 - b) * d + b * h
    return (h_next, d_next)


def trajectory(a: float, b: float, p0: Tuple[float, float], n: int
               ) -> List[Tuple[float, float]]:
    """Full trajectory [state_0, ..., state_n] of the loop."""
    states: List[Tuple[float, float]] = [p0]
    for _ in range(n):
        states.append(step(a, b, states[-1]))
    return states


def disagreement(state: Tuple[float, float]) -> float:
    """Tracking error e = h - d."""
    return state[0] - state[1]


# ---------------------------------------------------------------------------
# Closed forms (the theorems)
# ---------------------------------------------------------------------------

def err_closed(a: float, b: float, p0: Tuple[float, float], n: int) -> float:
    """Closed form  e_n = (1 - a - b)^n * (h0 - d0)."""
    q = 1.0 - a - b
    return (q ** n) * (p0[0] - p0[1])


def err_envelope(a: float, b: float, p0: Tuple[float, float], n: int) -> float:
    """Exact envelope  |e_n| = |1 - a - b|^n * |h0 - d0|."""
    q = 1.0 - a - b
    return (abs(q) ** n) * abs(p0[0] - p0[1])


def invariant(a: float, b: float, state: Tuple[float, float]) -> float:
    """Conserved quantity  b*h + a*d."""
    h, d = state
    return b * h + a * d


def consensus_value(a: float, b: float, p0: Tuple[float, float]) -> float:
    """Gain-weighted average  (b*h0 + a*d0) / (a + b)  (the common limit)."""
    return (b * p0[0] + a * p0[1]) / (a + b)


def classify(a: float, b: float) -> str:
    """Classify the loop by its total gain s = a + b."""
    q = abs(1.0 - a - b)
    s = a + b
    if math.isclose(s, 1.0):
        return "critically damped (instant agreement, q = 0)"
    if q < 1.0:
        return "convergent (0 < a+b < 2)"
    if math.isclose(q, 1.0):
        return "marginal / perpetual oscillation (a+b = 0 or 2)"
    return "divergent (a+b < 0 or a+b > 2)"


def rounds_to_tolerance(a: float, b: float, p0: Tuple[float, float],
                        eps: float) -> int:
    """Smallest n with |e_n| <= eps (returns 0 if already within tolerance)."""
    q = abs(1.0 - a - b)
    e0 = abs(p0[0] - p0[1])
    if e0 <= eps:
        return 0
    if math.isclose(q, 0.0):
        return 1
    if q >= 1.0:
        return -1  # never (marginal or divergent)
    return math.ceil(math.log(eps / e0) / math.log(q))


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_convergence() -> None:
    print("=" * 70)
    print("DEMO 1: Convergence and consensus (a = 0.3, b = 0.2, s = 0.5)")
    print("=" * 70)
    a, b, p0 = 0.3, 0.2, (10.0, -4.0)
    traj = trajectory(a, b, p0, 20)
    limit = consensus_value(a, b, p0)
    print(f"contraction factor q = {1 - a - b:.4f}   ({classify(a, b)})")
    print(f"predicted consensus  = {limit:.6f}")
    print(f"{'n':>3} {'h_n':>12} {'d_n':>12} {'e_n':>12} {'invariant':>12}")
    for n in (0, 1, 2, 5, 10, 20):
        h, d = traj[n]
        print(f"{n:>3} {h:>12.6f} {d:>12.6f} {h - d:>12.6f} "
              f"{invariant(a, b, traj[n]):>12.6f}")
    print(f"both channels -> {limit:.6f}; invariant is conserved throughout.\n")


def demo_closed_form_agreement() -> None:
    print("=" * 70)
    print("DEMO 2: Simulation matches the closed form e_n = q^n e_0")
    print("=" * 70)
    a, b, p0 = 0.45, 0.25, (3.0, 8.0)
    traj = trajectory(a, b, p0, 12)
    max_err = 0.0
    for n in range(13):
        sim = disagreement(traj[n])
        cf = err_closed(a, b, p0, n)
        max_err = max(max_err, abs(sim - cf))
    print(f"a = {a}, b = {b}, p0 = {p0}")
    print(f"max |simulated e_n - closed-form e_n| over 12 rounds = {max_err:.2e}")
    print("=> the exact geometric envelope holds to machine precision.\n")


def demo_critical_damping() -> None:
    print("=" * 70)
    print("DEMO 3: Critical damping (a + b = 1) -> agreement in ONE step")
    print("=" * 70)
    for (a, b) in [(0.5, 0.5), (0.8, 0.2), (0.1, 0.9)]:
        p0 = (7.0, -3.0)
        traj = trajectory(a, b, p0, 3)
        e1 = disagreement(traj[1])
        print(f"a={a:.1f}, b={b:.1f} (s=1): e_0={disagreement(traj[0]):+.3f}, "
              f"e_1={e1:+.3e}, e_2={disagreement(traj[2]):+.3e}")
    print("=> regardless of the split, the gap is wiped out after one round.\n")


def demo_divergence_and_oscillation() -> None:
    print("=" * 70)
    print("DEMO 4: Instability outside the window, and the oscillation trap")
    print("=" * 70)
    # Over-aggressive: a + b = 2.5 > 2
    a, b, p0 = 1.5, 1.0, (1.0, 0.0)
    print(f"Over-aggressive a={a}, b={b} (s={a+b}, q={1-a-b:+.1f}): "
          f"{classify(a, b)}")
    for n in (0, 2, 4, 6, 8):
        print(f"   |e_{n}| = {err_envelope(a, b, p0, n):.3e}")
    # Maximal gains a = b = 1: perpetual oscillation, the counterexample
    a, b, p0 = 1.0, 1.0, (1.0, 0.0)
    print(f"\nMaximal gains a=b=1 (s=2, q=-1): {classify(a, b)}")
    traj = trajectory(a, b, p0, 6)
    seq = [round(disagreement(s), 6) for s in traj]
    print(f"   e_n sequence: {seq}")
    print(f"   |e_n| is constant = 1 forever => the naive 'mutual adaptation")
    print(f"   always converges' conjecture is FALSE.\n")


def demo_rate_prediction() -> None:
    print("=" * 70)
    print("DEMO 5: Predicting the number of rounds to a tolerance")
    print("=" * 70)
    p0, eps = (100.0, 0.0), 1e-3
    for (a, b) in [(0.1, 0.1), (0.3, 0.2), (0.4, 0.4), (0.5, 0.5)]:
        n_pred = rounds_to_tolerance(a, b, p0, eps)
        traj = trajectory(a, b, p0, max(n_pred, 1))
        actual = abs(disagreement(traj[n_pred])) if n_pred >= 0 else float("nan")
        print(f"a={a}, b={b} (s={a+b:.1f}): predicted n={n_pred:>3}  "
              f"|e_n|={actual:.2e}  (target {eps})")
    print()


def main() -> None:
    demo_convergence()
    demo_closed_form_agreement()
    demo_critical_damping()
    demo_divergence_and_oscillation()
    demo_rate_prediction()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
