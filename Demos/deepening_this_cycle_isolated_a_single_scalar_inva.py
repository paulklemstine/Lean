"""
Numerical demonstrations of the Mobius discriminant theory.

This self-contained script illustrates, for first-order multiplicative
recurrences

    (alpha*n + beta) * a(n+1) = (gamma*n + delta) * a(n),

the Mobius discriminant

    Delta = gamma*beta - alpha*delta,

and its control over:
  1. the forward-difference identity of consecutive ratios,
  2. monotonicity of the growth-factor sequence a(n+1)/a(n),
  3. all-order Turan (log-convexity) inequalities a(i+1)a(j) < a(i)a(j+1),
  4. the exact telescoping product a(n) = a(0) * prod_{k<n} (gamma k+delta)/(alpha k+beta),

and, for second-order constant-coefficient recurrences

    p*a(n+2) = q*a(n+1) + r*a(n),

the Hankel law p*D(n+1) = -r*D(n) with D(n) = a(n)a(n+2) - a(n+1)^2,
its geometric closed form p^n D(n) = (-r)^n D(0), and Cassini's identity.

Run:  python3 demo.py
"""

from __future__ import annotations

from typing import Callable, List


# ---------------------------------------------------------------------------
# First-order multiplicative recurrence machinery
# ---------------------------------------------------------------------------

def mobius_discriminant(alpha: float, beta: float, gamma: float, delta: float) -> float:
    """Return the Mobius discriminant Delta = gamma*beta - alpha*delta."""
    return gamma * beta - alpha * delta


def generate_first_order(
    alpha: float, beta: float, gamma: float, delta: float, a0: float, n_terms: int
) -> List[float]:
    """Generate a(0..n_terms-1) from (alpha n+beta)a(n+1) = (gamma n+delta)a(n)."""
    seq: List[float] = [a0]
    for n in range(n_terms - 1):
        num = gamma * n + delta
        den = alpha * n + beta
        seq.append(seq[-1] * num / den)
    return seq


def growth_factors(seq: List[float]) -> List[float]:
    """Return the consecutive-ratio sequence r(n) = a(n+1)/a(n)."""
    return [seq[n + 1] / seq[n] for n in range(len(seq) - 1)]


def forward_difference_check(
    alpha: float, beta: float, gamma: float, delta: float, seq: List[float]
) -> List[tuple[float, float]]:
    """
    For each n, compare the measured forward difference
        r(n+1) - r(n)  =  a(n+2)/a(n+1) - a(n+1)/a(n)
    against the predicted value  Delta / ((alpha n+beta)(alpha(n+1)+beta)).
    Returns a list of (measured, predicted) pairs.
    """
    delta_disc = mobius_discriminant(alpha, beta, gamma, delta)
    r = growth_factors(seq)
    out: List[tuple[float, float]] = []
    for n in range(len(r) - 1):
        measured = r[n + 1] - r[n]
        den = (alpha * n + beta) * (alpha * (n + 1) + beta)
        predicted = delta_disc / den
        out.append((measured, predicted))
    return out


def telescoping_product(
    alpha: float, beta: float, gamma: float, delta: float, a0: float, n: int
) -> float:
    """Closed form a(n) = a0 * prod_{k<n} (gamma k+delta)/(alpha k+beta)."""
    prod = a0
    for k in range(n):
        prod *= (gamma * k + delta) / (alpha * k + beta)
    return prod


def turan_holds(seq: List[float], positive_delta: bool) -> bool:
    """
    Check the all-order Turan inequalities over all i < j within the
    generated range. If positive_delta, expect a(i+1)a(j) < a(i)a(j+1);
    otherwise expect the reverse.
    """
    n = len(seq)
    for i in range(n):
        for j in range(i + 1, n - 1):
            left = seq[i + 1] * seq[j]
            right = seq[i] * seq[j + 1]
            if positive_delta:
                if not (left < right + 1e-12):
                    return False
            else:
                if not (right < left + 1e-12):
                    return False
    return True


# ---------------------------------------------------------------------------
# Second-order constant-coefficient recurrence + Hankel determinant
# ---------------------------------------------------------------------------

def generate_second_order(
    p: float, q: float, r: float, a0: float, a1: float, n_terms: int
) -> List[float]:
    """Generate a(0..n_terms-1) from p a(n+2) = q a(n+1) + r a(n)."""
    seq: List[float] = [a0, a1]
    for n in range(n_terms - 2):
        seq.append((q * seq[-1] + r * seq[-2]) / p)
    return seq


def hankel(seq: List[float], n: int) -> float:
    """Pointwise Hankel determinant D(n) = a(n)a(n+2) - a(n+1)^2."""
    return seq[n] * seq[n + 2] - seq[n + 1] ** 2


def hankel_law_check(
    p: float, q: float, r: float, seq: List[float]
) -> List[tuple[float, float]]:
    """Compare p*D(n+1) against -r*D(n) for each valid n."""
    out: List[tuple[float, float]] = []
    for n in range(len(seq) - 3):
        lhs = p * hankel(seq, n + 1)
        rhs = -r * hankel(seq, n)
        out.append((lhs, rhs))
    return out


def hankel_closed_form(p: float, r: float, d0: float, n: int) -> float:
    """Closed form D(n) = (-r/p)^n * D(0)."""
    return ((-r / p) ** n) * d0


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_catalan() -> None:
    """Catalan numbers: (n+2)C(n+1) = (4n+2)C(n), Delta = 6 > 0 (log-convex)."""
    print("=" * 70)
    print("DEMO 1  Catalan numbers  (alpha,beta,gamma,delta) = (1,2,4,2)")
    print("=" * 70)
    alpha, beta, gamma, delta = 1.0, 2.0, 4.0, 2.0
    disc = mobius_discriminant(alpha, beta, gamma, delta)
    print(f"Mobius discriminant Delta = {disc:g}  ->  log-convex regime\n")

    seq = generate_first_order(alpha, beta, gamma, delta, a0=1.0, n_terms=10)
    print("Catalan terms:", [round(x) for x in seq])
    print("Growth factors a(n+1)/a(n):",
          [round(x, 4) for x in growth_factors(seq)])
    print("  -> strictly increasing toward gamma/alpha = 4, as Theorem 3.1 predicts\n")

    print("Forward-difference identity (measured vs predicted):")
    for n, (m, pr) in enumerate(forward_difference_check(alpha, beta, gamma, delta, seq)):
        print(f"  n={n}: measured={m:+.6f}  predicted={pr:+.6f}  match={abs(m-pr)<1e-9}")

    print("\nTelescoping product matches direct recurrence:")
    for n in range(6):
        print(f"  a({n}) direct={seq[n]:g}  product={telescoping_product(alpha,beta,gamma,delta,1.0,n):g}")

    print(f"\nAll-order Turan inequalities hold: {turan_holds(seq, positive_delta=True)}")


def demo_log_concave() -> None:
    """A log-concave example with Delta < 0: (n+1)a(n+1) = (n+3)a(n)."""
    print("\n" + "=" * 70)
    print("DEMO 2  Log-concave regime  (alpha,beta,gamma,delta) = (1,1,1,3)")
    print("=" * 70)
    alpha, beta, gamma, delta = 1.0, 1.0, 1.0, 3.0
    disc = mobius_discriminant(alpha, beta, gamma, delta)
    print(f"Mobius discriminant Delta = {disc:g}  ->  log-concave regime\n")

    seq = generate_first_order(alpha, beta, gamma, delta, a0=1.0, n_terms=10)
    print("Terms:", [round(x, 5) for x in seq])
    print("Growth factors a(n+1)/a(n):",
          [round(x, 4) for x in growth_factors(seq)])
    print("  -> strictly decreasing, as Theorem 3.1 predicts")
    print(f"\nReversed Turan inequalities hold: {turan_holds(seq, positive_delta=False)}")


def demo_fibonacci_cassini() -> None:
    """Fibonacci: p=q=r=1, Hankel law forces sign alternation (Cassini)."""
    print("\n" + "=" * 70)
    print("DEMO 3  Fibonacci Hankel law  (p,q,r) = (1,1,1)")
    print("=" * 70)
    p, q, r = 1.0, 1.0, 1.0
    seq = generate_second_order(p, q, r, a0=0.0, a1=1.0, n_terms=14)
    print("Fibonacci terms:", [round(x) for x in seq])

    d0 = hankel(seq, 0)
    print(f"\nD(0) = {d0:g}")
    print("Hankel determinants D(n):",
          [round(hankel(seq, n)) for n in range(len(seq) - 2)])
    print("  -> Cassini's identity: D(n) = (-1)^(n+1), sign alternates forever\n")

    print("Hankel recurrence p*D(n+1) = -r*D(n):")
    for n, (lhs, rhs) in enumerate(hankel_law_check(p, q, r, seq)[:6]):
        print(f"  n={n}: p*D(n+1)={lhs:+g}  -r*D(n)={rhs:+g}  match={abs(lhs-rhs)<1e-9}")

    print("\nClosed form D(n) = (-r/p)^n * D(0):")
    for n in range(6):
        print(f"  n={n}: direct={hankel(seq,n):+g}  closed={hankel_closed_form(p,r,d0,n):+g}")


def demo_second_order_signed() -> None:
    """A second-order recurrence with r<0: eventually one-signed Hankel."""
    print("\n" + "=" * 70)
    print("DEMO 4  Second-order with r/p < 0  (p,q,r) = (1,3,-2)")
    print("=" * 70)
    p, q, r = 1.0, 3.0, -2.0
    seq = generate_second_order(p, q, r, a0=1.0, a1=2.0, n_terms=10)
    print("Terms:", [round(x) for x in seq])
    d0 = hankel(seq, 0)
    print("Hankel determinants D(n):",
          [round(hankel(seq, n)) for n in range(len(seq) - 2)])
    print(f"Ratio -r/p = {-r/p:g} > 0 constant, so sign of D(n) stays constant")
    print("Closed form D(n) = (-r/p)^n * D(0):",
          [round(hankel_closed_form(p, r, d0, n)) for n in range(len(seq) - 2)])


def main() -> None:
    demo_catalan()
    demo_log_concave()
    demo_fibonacci_cassini()
    demo_second_order_signed()
    print("\nAll demonstrations complete.")


if __name__ == "__main__":
    main()
