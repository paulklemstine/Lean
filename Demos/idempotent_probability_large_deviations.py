"""
Idempotent Probability: Large Deviations -- Numerical Demonstrations
===================================================================

Self-contained numerical examples illustrating the idempotent (max-plus)
large-deviation calculus and the idempotent Donsker--Varadhan variational
principle.

Max-plus dictionary
-------------------
    addition        a (+) b = max(a, b)
    multiplication  a (x) b = a + b
    additive zero   -infinity
    multiplicative one  0

A max-plus measure is a weight function w : X -> R.
A *tropical probability* is normalized:  max_x w(x) = 0  and  w(x) <= 0.

Core objects
------------
    max-plus integral   int^+ phi dP   = max_x ( phi(x) + w_P(x) )
    rate function       I_P(x)         = - w_P(x)
    idempotent CGF      Lambda(lam)    = max_x ( lam * val(x) + w_P(x) )
    relative entropy    D(Q || P)      = max_x ( w_Q(x) - w_P(x) )

Run:  python demo.py
"""

from __future__ import annotations

import math
from typing import Callable, Sequence


# ---------------------------------------------------------------------------
# Core max-plus primitives
# ---------------------------------------------------------------------------

def max_plus_integral(phi: Sequence[float], w: Sequence[float]) -> float:
    """Idempotent free energy  int^+ phi dP = max_x ( phi(x) + w(x) )."""
    return max(p + wx for p, wx in zip(phi, w))


def rate_function(w: Sequence[float]) -> list[float]:
    """Idempotent rate function  I_P(x) = - w_P(x)."""
    return [-wx for wx in w]


def idempotent_cgf(val: Sequence[float], w: Sequence[float], lam: float) -> float:
    """Idempotent cumulant generating function  Lambda(lam)."""
    return max(lam * v + wx for v, wx in zip(val, w))


def relative_entropy(wq: Sequence[float], wp: Sequence[float]) -> float:
    """Idempotent relative entropy  D(Q || P) = max_x ( w_Q(x) - w_P(x) )."""
    return max(q - p for q, p in zip(wq, wp))


def normalize(w: Sequence[float]) -> list[float]:
    """Turn an arbitrary weight vector into a tropical probability:
    subtract the peak so that  max_x w(x) = 0  and  w(x) <= 0."""
    peak = max(w)
    return [wx - peak for wx in w]


def is_tropical_probability(w: Sequence[float], tol: float = 1e-12) -> bool:
    """Check normalization:  max_x w(x) = 0  and  w(x) <= 0."""
    return abs(max(w)) <= tol and all(wx <= tol for wx in w)


# ---------------------------------------------------------------------------
# The Laplace bridge (Maslov dequantization)
# ---------------------------------------------------------------------------

def scaled_log_partition(g: Sequence[float], n: float) -> float:
    """(1/n) log sum_x exp(n g(x)), computed stably (subtract the peak)."""
    peak = max(g)
    s = sum(math.exp(n * (gx - peak)) for gx in g)
    return peak + math.log(s) / n


def laplace_gap_bound(num_states: int, n: float) -> float:
    """Uniform, profile-independent error bound  log(#X) / n."""
    return math.log(num_states) / n


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_basic_objects() -> None:
    print("=" * 70)
    print("DEMO 1: Max-plus measure, integral, and rate function")
    print("=" * 70)
    # An (un-normalized) log-likelihood profile over 4 outcomes.
    raw = [-1.0, 0.5, -2.0, -0.3]
    w = normalize(raw)
    print(f"raw weights      : {raw}")
    print(f"normalized w_P   : {[round(x, 3) for x in w]}")
    print(f"is tropical prob : {is_tropical_probability(w)}")
    print(f"rate function I_P: {[round(x, 3) for x in rate_function(w)]}")
    phi = [2.0, 0.0, 1.0, 3.0]
    val = max_plus_integral(phi, w)
    # Varadhan form: int^+ phi dP = max_x ( phi(x) - I_P(x) )
    I = rate_function(w)
    val2 = max(p - ix for p, ix in zip(phi, I))
    print(f"phi              : {phi}")
    print(f"int^+ phi dP     : {round(val, 6)}")
    print(f"max(phi - I_P)   : {round(val2, 6)}   (idempotent Varadhan lemma)")
    assert abs(val - val2) < 1e-12
    print("OK: Varadhan identity holds.\n")


def demo_gibbs_inequality() -> None:
    print("=" * 70)
    print("DEMO 2: Idempotent relative entropy & Gibbs inequality")
    print("=" * 70)
    wp = normalize([-1.0, 0.5, -2.0, -0.3])
    print(f"w_P             : {[round(x, 3) for x in wp]}")
    print(f"D(P || P)       : {round(relative_entropy(wp, wp), 6)}  (should be 0)")
    assert abs(relative_entropy(wp, wp)) < 1e-12

    # Random-ish family of candidate tropical probabilities Q.
    candidates = [
        normalize([0.0, -1.0, -1.0, -0.5]),
        normalize([-3.0, 0.0, -0.2, -1.0]),
        normalize([-0.1, -0.1, 0.0, -0.1]),
        normalize([-2.0, -2.0, -2.0, 0.0]),
    ]
    print("\nGibbs inequality  D(Q || P) >= 0 for tropical probabilities Q:")
    for i, wq in enumerate(candidates):
        d = relative_entropy(wq, wp)
        dominated = all(q <= p + 1e-12 for q, p in zip(wq, wp))
        print(f"  Q{i}: D(Q||P) = {d:7.4f}   "
              f"(=0 iff w_Q <= w_P : {dominated and abs(d) < 1e-9})")
        assert d >= -1e-12
    print("OK: all divergences non-negative.\n")


def demo_donsker_varadhan() -> None:
    print("=" * 70)
    print("DEMO 3: Idempotent Donsker--Varadhan variational principle")
    print("=" * 70)
    print("  int^+ phi dP  =  max_Q ( int^+ phi dQ - D(Q || P) ),  attained at Q=P")
    wp = normalize([-1.0, 0.5, -2.0, -0.3])
    phi = [2.0, 0.0, 1.0, 3.0]
    target = max_plus_integral(phi, wp)
    print(f"\nReference value int^+ phi dP = {round(target, 6)}")

    candidates = [
        ("Q = P", wp),
        ("Q0", normalize([0.0, -1.0, -1.0, -0.5])),
        ("Q1", normalize([-3.0, 0.0, -0.2, -1.0])),
        ("Q2", normalize([-0.1, -0.1, 0.0, -0.1])),
        ("Q3", normalize([-2.0, -2.0, -2.0, 0.0])),
    ]
    best = -math.inf
    print(f"{'candidate':>10} | {'int^+ phi dQ':>13} | {'D(Q||P)':>9} | "
          f"{'objective':>10}")
    print("-" * 54)
    for name, wq in candidates:
        iq = max_plus_integral(phi, wq)
        d = relative_entropy(wq, wp)
        obj = iq - d
        best = max(best, obj)
        flag = "  <- attains max" if abs(obj - target) < 1e-12 else ""
        print(f"{name:>10} | {iq:13.4f} | {d:9.4f} | {obj:10.4f}{flag}")
        # weak duality
        assert obj <= target + 1e-12
    print("-" * 54)
    print(f"max objective = {round(best, 6)}  vs  int^+ phi dP = {round(target, 6)}")
    assert abs(best - target) < 1e-12
    print("OK: weak duality holds and the maximum is attained at Q = P.\n")


def demo_walk_cgf() -> None:
    print("=" * 70)
    print("DEMO 4: Exact CGF scaling of the max-plus random walk")
    print("=" * 70)
    print("  Lambda_walk(lam) = n * Lambda(lam)   (exact, no asymptotics)")
    w = normalize([-1.0, 0.5, -2.0, -0.3])
    val = [1.0, -0.5, 2.0, 0.0]
    lam = 0.8
    single = idempotent_cgf(val, w, lam)
    print(f"\nSingle-step Lambda({lam}) = {round(single, 6)}")
    # Brute-force the walk CGF over all paths for small n.
    from itertools import product
    states = range(len(w))
    for n in range(1, 5):
        best = -math.inf
        for path in product(states, repeat=n):
            ww = sum(w[i] for i in path)
            sn = sum(val[i] for i in path)
            best = max(best, lam * sn + ww)
        print(f"  n={n}: Lambda_walk = {best:9.4f}   n*Lambda = "
              f"{n * single:9.4f}")
        assert abs(best - n * single) < 1e-9
    print("OK: walk CGF equals n * single-step CGF, exactly.\n")


def demo_laplace_principle() -> None:
    print("=" * 70)
    print("DEMO 5: Finite Laplace principle (Maslov dequantization)")
    print("=" * 70)
    print("  (1/n) log sum_x exp(n g(x)) -> max_x g(x),  gap <= log(#X)/n")
    g = [1.0, -0.5, 2.0, 0.3, -2.0]
    target = max(g)
    print(f"\nProfile g       : {g}")
    print(f"max_x g(x)      : {target}")
    print(f"{'n':>6} | {'(1/n)log-sum-exp':>17} | {'gap':>9} | {'bound log(#X)/n':>16}")
    print("-" * 56)
    for n in (1, 2, 5, 10, 50, 200, 1000):
        approx = scaled_log_partition(g, n)
        gap = approx - target
        bound = laplace_gap_bound(len(g), n)
        print(f"{n:>6} | {approx:17.6f} | {gap:9.6f} | {bound:16.6f}")
        assert -1e-12 <= gap <= bound + 1e-12
    print("OK: convergence to the max-plus value within the uniform bound.\n")


def demo_chernoff_and_sharp_ldp() -> None:
    print("=" * 70)
    print("DEMO 6: Idempotent Chernoff bound and the sharp LDP")
    print("=" * 70)
    w = normalize([-1.0, 0.5, -2.0, -0.3])
    val = [1.0, -0.5, 2.0, 0.0]
    I = rate_function(w)
    a = 1.5  # upper-tail threshold:  event { val >= a }
    event = [x for x in range(len(w)) if val[x] >= a]
    print(f"val             : {val}")
    print(f"threshold a     : {a}   ->  event {{val >= a}} = states {event}")

    # Chernoff:  w(x) <= Lambda(lam) - lam*a  for lam >= 0, x in event.
    print("\nChernoff bound  w(x) <= Lambda(lam) - lam*a   (lam >= 0):")
    for lam in (0.0, 0.5, 1.0, 2.0):
        rhs = idempotent_cgf(val, w, lam) - lam * a
        ok = all(w[x] <= rhs + 1e-12 for x in event)
        print(f"  lam={lam:>3}: RHS = {rhs:8.4f}   holds for all x in event: {ok}")
        assert ok

    # Sharp LDP:  cost(A) = -max_{x in A} w(x) = min_{x in A} I(x).
    cost = -max(w[x] for x in event)
    inf_rate = min(I[x] for x in event)
    print(f"\nSharp LDP   cost(A) = {round(cost, 6)}   "
          f"min_A I = {round(inf_rate, 6)}")
    assert abs(cost - inf_rate) < 1e-12
    print("OK: deviation cost equals the infimum of the rate function (exact).\n")


def main() -> None:
    demo_basic_objects()
    demo_gibbs_inequality()
    demo_donsker_varadhan()
    demo_walk_cgf()
    demo_laplace_principle()
    demo_chernoff_and_sharp_ldp()
    print("All demonstrations passed.")


if __name__ == "__main__":
    main()
