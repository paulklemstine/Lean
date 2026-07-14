"""
Numerical demonstrations of the Mobius discriminant law.

For a positive sequence obeying the first-order multiplicative recurrence

    (alpha * n + beta) * a(n+1) = (gamma * n + delta) * a(n),

the Mobius discriminant

    Delta = gamma * beta - alpha * delta

governs the log-behaviour of the sequence, both in sign and in exact size:

  * sign(Delta) fixes the log-convex / log-linear / log-concave trichotomy;
  * the pointwise discriminant D(n) = a(n)*a(n+2) - a(n+1)^2 satisfies
        (alpha*n + beta)*(alpha*(n+1) + beta) * D(n) = Delta * a(n) * a(n+1);
  * the ratio a(n+1)/a(n) = (gamma*n + delta)/(alpha*n + beta) is a Mobius
    transform whose forward difference has the constant numerator Delta;
  * the log-curvature log a(n) - 2 log a(n+1) + log a(n+2) equals
        log(1 + Delta / ((gamma*n + delta)*(alpha*(n+1) + beta))),
    which tends to 0 when alpha, gamma > 0.

The boundary result: no coefficient-only second-order discriminant can exist,
because the Fibonacci numbers (constant coefficients p=q=r=1) have
D(n) = F_n*F_{n+2} - F_{n+1}^2 = (-1)^{n+1}, flipping sign forever.

Run with:  python demo.py
"""

from __future__ import annotations

import math
from typing import Callable


# ---------------------------------------------------------------------------
# Core machinery
# ---------------------------------------------------------------------------

def mobius_discriminant(alpha: float, beta: float, gamma: float, delta: float) -> float:
    """Return the Mobius discriminant Delta = gamma*beta - alpha*delta."""
    return gamma * beta - alpha * delta


def classify(alpha: float, beta: float, gamma: float, delta: float) -> str:
    """Classify the log-behaviour of the recurrence from the sign of Delta."""
    delta_val = mobius_discriminant(alpha, beta, gamma, delta)
    if delta_val > 0:
        return "strictly log-convex"
    if delta_val < 0:
        return "strictly log-concave"
    return "log-linear (geometric)"


def generate(alpha: float, beta: float, gamma: float, delta: float,
             a0: float, n_terms: int) -> list[float]:
    """Generate a(0..n_terms-1) via a(n+1) = (gamma*n+delta)/(alpha*n+beta)*a(n)."""
    seq = [a0]
    for n in range(n_terms - 1):
        num = gamma * n + delta
        den = alpha * n + beta
        seq.append(num / den * seq[-1])
    return seq


def pointwise_discriminant(seq: list[float]) -> list[float]:
    """Return D(n) = a(n)*a(n+2) - a(n+1)^2 for all valid n."""
    return [seq[n] * seq[n + 2] - seq[n + 1] ** 2 for n in range(len(seq) - 2)]


# ---------------------------------------------------------------------------
# Demo 1: the exact discriminant identity across the classical zoo
# ---------------------------------------------------------------------------

def demo_exact_identity() -> None:
    print("=" * 72)
    print("DEMO 1  Exact identity  (alpha n+beta)(alpha(n+1)+beta) D(n)"
          " = Delta a(n)a(n+1)")
    print("=" * 72)
    zoo: dict[str, tuple[float, float, float, float, float]] = {
        # name: (alpha, beta, gamma, delta, a0)
        "2^n            ": (0.0, 1.0, 0.0, 2.0, 1.0),
        "1/n!           ": (1.0, 1.0, 0.0, 1.0, 1.0),
        "n!             ": (0.0, 1.0, 1.0, 1.0, 1.0),
        "C(2n,n)        ": (1.0, 1.0, 4.0, 2.0, 1.0),
        "Catalan C_n    ": (1.0, 2.0, 4.0, 2.0, 1.0),
    }
    for name, (al, be, ga, de, a0) in zoo.items():
        seq = generate(al, be, ga, de, a0, 8)
        d_val = mobius_discriminant(al, be, ga, de)
        max_err = 0.0
        for n in range(len(seq) - 2):
            lhs = (al * n + be) * (al * (n + 1) + be) * (
                seq[n] * seq[n + 2] - seq[n + 1] ** 2)
            rhs = d_val * seq[n] * seq[n + 1]
            max_err = max(max_err, abs(lhs - rhs))
        print(f"  {name}  Delta = {d_val:+.0f}   {classify(al, be, ga, de):24s}"
              f"   max identity error = {max_err:.2e}")
    print()


# ---------------------------------------------------------------------------
# Demo 2: ratio forward difference has constant numerator Delta
# ---------------------------------------------------------------------------

def demo_forward_difference() -> None:
    print("=" * 72)
    print("DEMO 2  Forward difference of ratio has index-independent numerator Delta")
    print("=" * 72)
    al, be, ga, de, a0 = 1.0, 2.0, 4.0, 2.0, 1.0  # Catalan, Delta = 6
    seq = generate(al, be, ga, de, a0, 10)
    d_val = mobius_discriminant(al, be, ga, de)
    print(f"  Catalan numbers, Delta = {d_val:+.0f}")
    print("   n    (ratio diff) * (alpha n+beta)(alpha(n+1)+beta)   recovered Delta")
    for n in range(len(seq) - 2):
        diff = seq[n + 2] / seq[n + 1] - seq[n + 1] / seq[n]
        recovered = diff * (al * n + be) * (al * (n + 1) + be)
        print(f"  {n:2d}                                                  {recovered:+.6f}")
    print()


# ---------------------------------------------------------------------------
# Demo 3: log-curvature and its decay to zero
# ---------------------------------------------------------------------------

def demo_log_curvature() -> None:
    print("=" * 72)
    print("DEMO 3  Log-curvature = log(1 + Delta/((gamma n+delta)(alpha(n+1)+beta)))"
          " -> 0")
    print("=" * 72)
    al, be, ga, de, a0 = 1.0, 2.0, 4.0, 2.0, 1.0  # Catalan
    seq = generate(al, be, ga, de, a0, 22)
    d_val = mobius_discriminant(al, be, ga, de)
    print("   n     measured curvature     closed-form curvature")
    for n in [0, 1, 2, 4, 8, 16]:
        measured = math.log(seq[n]) - 2 * math.log(seq[n + 1]) + math.log(seq[n + 2])
        closed = math.log(1 + d_val / ((ga * n + de) * (al * (n + 1) + be)))
        print(f"  {n:2d}      {measured:+.8f}         {closed:+.8f}")
    print("  (both positive since Delta = +6, and both decaying toward 0)")
    print()


# ---------------------------------------------------------------------------
# Demo 4: the Cassini obstruction (no coefficient-only Delta_2)
# ---------------------------------------------------------------------------

def demo_cassini_obstruction() -> None:
    print("=" * 72)
    print("DEMO 4  Fibonacci: constant coefficients p=q=r=1 but D(n) = (-1)^(n+1)")
    print("=" * 72)
    fib: list[int] = [0, 1]
    for _ in range(12):
        fib.append(fib[-1] + fib[-2])
    print("   n    F_n*F_{n+2} - F_{n+1}^2    predicted (-1)^(n+1)")
    for n in range(len(fib) - 2):
        d_val = fib[n] * fib[n + 2] - fib[n + 1] ** 2
        print(f"  {n:2d}          {d_val:+d}                    {(-1) ** (n + 1):+d}")
    print("  The sign flips forever => no constant (coefficient-only) discriminant"
          " can match it.")
    print()


def main() -> None:
    demo_exact_identity()
    demo_forward_difference()
    demo_log_curvature()
    demo_cassini_obstruction()


if __name__ == "__main__":
    main()
