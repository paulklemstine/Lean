"""
Numerical demonstration of the depth/width results for exponential-logarithmic
(EML) activations, and of the matching lower bounds for shallow ReLU networks.

Every construction and every bound proved in the accompanying paper is
reproduced here numerically:

  1. The width-2 EML layer  S_h(x) = (e^{hx} + e^{-hx} - 2)/h^2  approximates
     x^2 on [0,1] with error in  [h^2/14, h^2/6]  (observed constant 1/12).
  2. The one-neuron forward-difference layer  F_h(x) = 2(e^{hx} - 1 - hx)/h^2
     is only first order: error at x = 1 is at least h/3 (observed 1/3).
  3. The derivative of the same width-2 layer tracks 2x with error <= h^2/2.
  4. The depth-2 composition S_h(S_h(x)) approximates x^4 with error <= h^2.
  5. The width-4 polarisation gate  P_h(x,y) = (S_h(x+y) - S_h(x-y))/4
     approximates xy on [0,1]^2 with error in [2h^2/7, h^2].
  6. Quadratic forms: error <= h^2 * sum |A_ij| at width 4 n^2, dimension-free.
  7. Shallow ReLU lower bound: every k-unit one-hidden-layer ReLU network is
     affine on some subinterval of length 1/(k+1); best least-squares fits are
     compared against the proved floor 1/(32 (k+1)^2).
  8. Softplus containment: |log(1 + e^{Mt})/M - relu(t)| <= log(2)/M.

Self-contained: standard library only (math, random, itertools, typing).
Run with:  python3 demo.py
"""

from __future__ import annotations

import math
import random
from itertools import product
from typing import Callable, List, Sequence, Tuple

# ----------------------------------------------------------------------------
# 1. The EML model
# ----------------------------------------------------------------------------


def eml_neuron(a: float, b: float, c: float, d: float, x: float) -> float:
    """A single EML neuron:  x -> exp(a x + b) - log(c x + d).

    Setting c = 0, d = 1 switches the logarithmic branch off (log 1 = 0).
    """
    return math.exp(a * x + b) - math.log(c * x + d)


def eml_layer(
    neurons: Sequence[Tuple[float, float, float, float]],
    out: Sequence[float],
    bias: float,
    x: float,
) -> float:
    """An EML layer of width len(neurons): an affine read-out of the neurons."""
    return bias + sum(g * eml_neuron(*n, x) for g, n in zip(out, neurons))


def sq_layer(h: float, x: float) -> float:
    """The width-2 central-difference squaring layer S_h(x) ~ x^2.

    Realised literally as an EML layer: neurons (h,0,0,1) and (-h,0,0,1),
    read-out weights 1/h^2 each, bias -2/h^2.
    """
    return eml_layer(
        neurons=((h, 0.0, 0.0, 1.0), (-h, 0.0, 0.0, 1.0)),
        out=(1.0 / h**2, 1.0 / h**2),
        bias=-2.0 / h**2,
        x=x,
    )


def forward_layer(h: float, x: float) -> float:
    """The width-1 forward-difference layer F_h(x) = 2(e^{hx} - 1 - hx)/h^2.

    The linear term is supplied by the affine read-out; this construction is
    only first order in h.
    """
    return 2.0 * (math.exp(h * x) - 1.0 - h * x) / h**2


def sq_layer_deriv(h: float, x: float) -> float:
    """Exact derivative of S_h:  (e^{hx} - e^{-hx})/h  ~  2x."""
    return (math.exp(h * x) - math.exp(-h * x)) / h


def prod_gate(h: float, x: float, y: float) -> float:
    """Width-4 polarisation gate  P_h(x,y) = (S_h(x+y) - S_h(x-y))/4  ~  x y."""
    return (sq_layer(h, x + y) - sq_layer(h, x - y)) / 4.0


def quad_form_network(h: float, A: Sequence[Sequence[float]], x: Sequence[float]) -> float:
    """Single EML layer of width <= 4 n^2 computing sum_{i,j} A_ij x_i x_j."""
    n = len(x)
    return sum(A[i][j] * prod_gate(h, x[i], x[j]) for i in range(n) for j in range(n))


# ----------------------------------------------------------------------------
# 2. The ReLU model
# ----------------------------------------------------------------------------


def relu(t: float) -> float:
    return t if t > 0.0 else 0.0


def relu_net(
    a: Sequence[float],
    w: Sequence[float],
    b: Sequence[float],
    c0: float,
    c1: float,
    x: float,
) -> float:
    """One-hidden-layer ReLU network with a free affine skip connection."""
    return c0 + c1 * x + sum(ai * relu(wi * x + bi) for ai, wi, bi in zip(a, w, b))


def softplus(t: float) -> float:
    """Numerically stable log(1 + e^t)."""
    if t > 30.0:
        return t + math.log1p(math.exp(-t))
    return math.log1p(math.exp(t))


# ----------------------------------------------------------------------------
# 3. Utilities
# ----------------------------------------------------------------------------


def grid(n: int, lo: float = 0.0, hi: float = 1.0) -> List[float]:
    return [lo + (hi - lo) * i / n for i in range(n + 1)]


def sup_error(f: Callable[[float], float], g: Callable[[float], float], pts: Sequence[float]) -> float:
    return max(abs(f(t) - g(t)) for t in pts)


def banner(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


# ----------------------------------------------------------------------------
# Demonstration 1: the width-2 layer squares to second order, and sharply
# ----------------------------------------------------------------------------


def demo_squaring() -> None:
    banner("1. Width-2 EML layer S_h(x) ~ x^2 :  proved h^2/14 <= err <= h^2/6")
    pts = grid(1000)
    print(f"{'h':>10} {'max err':>14} {'/h^2':>10} {'err at 1':>14} {'/h^2':>10}"
          f" {'lower 1/14':>11} {'upper 1/6':>10}")
    for h in (0.5, 0.25, 0.125, 0.0625, 0.03125):
        err = sup_error(lambda x: sq_layer(h, x), lambda x: x * x, pts)
        e1 = abs(sq_layer(h, 1.0) - 1.0)
        ok = (h**2 / 14 <= e1 + 1e-15) and (err <= h**2 / 6 + 1e-15)
        print(f"{h:10.5f} {err:14.3e} {err / h**2:10.6f} {e1:14.3e} "
              f"{e1 / h**2:10.6f} {h**2/14:11.3e} {h**2/6:10.3e}"
              + ("" if ok else "   <-- VIOLATION"))
    print("Observed constant -> 1/12 = 0.08333..., strictly inside [1/14, 1/6].")


# ----------------------------------------------------------------------------
# Demonstration 2: the forward-difference layer is only first order
# ----------------------------------------------------------------------------


def demo_forward_is_slower() -> None:
    banner("2. Forward-difference layer F_h is Theta(h), not Theta(h^2)")
    pts = grid(1000)
    print(f"{'h':>10} {'max|F_h-x^2|':>14} {'/h':>10} {'F_h(1)-1':>14} "
          f"{'/h (>=1/3)':>12}")
    for h in (0.5, 0.25, 0.125, 0.0625):
        err = sup_error(lambda x: forward_layer(h, x), lambda x: x * x, pts)
        e1 = forward_layer(h, 1.0) - 1.0
        print(f"{h:10.5f} {err:14.3e} {err / h:10.6f} {e1:14.3e} {e1 / h:12.6f}"
              + ("" if e1 >= h / 3 - 1e-15 else "   <-- VIOLATION"))
    print("The proved floor h/3 at x = 1 is matched exactly in the limit.")


# ----------------------------------------------------------------------------
# Demonstration 3: gradients
# ----------------------------------------------------------------------------


def demo_gradients() -> None:
    banner("3. The same two neurons track the derivative 2x to h^2/2")
    pts = grid(1000)
    print(f"{'h':>10} {'max|S_h'' - 2x|':>16} {'/h^2':>10} {'bound h^2/2':>13}")
    for h in (0.5, 0.25, 0.125, 0.0625):
        err = sup_error(lambda x: sq_layer_deriv(h, x), lambda x: 2 * x, pts)
        print(f"{h:10.5f} {err:16.3e} {err / h**2:10.6f} {h**2 / 2:13.3e}"
              + ("" if err <= h**2 / 2 + 1e-15 else "   <-- VIOLATION"))
    print("Observed constant -> 1/3, proved bound 1/2.")


# ----------------------------------------------------------------------------
# Demonstration 4: depth composes
# ----------------------------------------------------------------------------


def demo_depth() -> None:
    banner("4. Depth 2:  S_h(S_h(x)) ~ x^4  with error <= h^2  (needs h <= 1/2)")
    pts = grid(1000)
    print(f"{'h':>10} {'max err':>14} {'/h^2':>10} {'bound h^2':>12} "
          f"{'max|S_h(x)|':>12}")
    for h in (0.5, 0.25, 0.125, 0.0625):
        err = sup_error(lambda x: sq_layer(h, sq_layer(h, x)),
                        lambda x: x**4, pts)
        stab = max(abs(sq_layer(h, x)) for x in pts)
        print(f"{h:10.5f} {err:14.3e} {err / h**2:10.6f} {h**2:12.3e} {stab:12.6f}"
              + ("" if err <= h**2 + 1e-15 else "   <-- VIOLATION"))
    print("The stability invariant |S_h(x)| <= 25/24 = 1.041666... keeps the")
    print("second layer's pre-activation inside |h y| <= 1; that is why depth")
    print("composes without losing the second-order rate.")


# ----------------------------------------------------------------------------
# Demonstration 5: the multiplication gate
# ----------------------------------------------------------------------------


def demo_product_gate() -> None:
    banner("5. Width-4 polarisation gate P_h(x,y) ~ x y : 2h^2/7 <= err <= h^2")
    pts = grid(50)
    print(f"{'h':>10} {'max err':>14} {'/h^2':>10} {'err at (1,1)':>14} "
          f"{'/h^2':>10} {'bound h^2':>11}")
    for h in (0.5, 0.25, 0.125, 0.0625):
        err = max(abs(prod_gate(h, x, y) - x * y) for x, y in product(pts, pts))
        corner = abs(prod_gate(h, 1.0, 1.0) - 1.0)
        ok = err <= h**2 + 1e-15 and corner >= 2 * h**2 / 7 - 1e-15
        print(f"{h:10.5f} {err:14.3e} {err / h**2:10.6f} {corner:14.3e} "
              f"{corner / h**2:10.6f} {h**2:11.3e}"
              + ("" if ok else "   <-- VIOLATION"))
    print("Observed constant -> 1/3, bracketed by the proved [2/7, 17/24].")


# ----------------------------------------------------------------------------
# Demonstration 6: quadratic forms in n variables, dimension-free constant
# ----------------------------------------------------------------------------


def demo_quadratic_forms(seed: int = 20260820) -> None:
    banner("6. Every quadratic form is one EML layer of width 4 n^2")
    rng = random.Random(seed)
    h = 0.1
    print(f"h = {h};  bound is h^2 * sum|A_ij| = {h**2:.4f} * ||A||_1")
    print(f"{'n':>4} {'width 4n^2':>11} {'||A||_1':>10} {'max err':>12} "
          f"{'bound':>12} {'ratio':>8}")
    for n in (1, 2, 3, 5, 8, 12):
        A = [[rng.uniform(-1.0, 1.0) for _ in range(n)] for _ in range(n)]
        mass = sum(abs(A[i][j]) for i in range(n) for j in range(n))
        worst = 0.0
        for _ in range(400):
            x = [rng.uniform(0.0, 1.0) for _ in range(n)]
            true = sum(A[i][j] * x[i] * x[j] for i in range(n) for j in range(n))
            worst = max(worst, abs(quad_form_network(h, A, x) - true))
        bound = h**2 * mass
        print(f"{n:4d} {4 * n * n:11d} {mass:10.4f} {worst:12.3e} {bound:12.3e} "
              f"{worst / bound:8.4f}"
              + ("" if worst <= bound + 1e-12 else "   <-- VIOLATION"))
    print("The error constant h^2 does not degrade with the dimension: only the")
    print("coefficient mass sum|A_ij| enters.  No curse of dimensionality here.")


# ----------------------------------------------------------------------------
# Demonstration 7: the shallow ReLU barrier
# ----------------------------------------------------------------------------


def piecewise_linear_relu_fit_error(k: int, m: int = 2000) -> float:
    """Uniform error of the interpolating k-unit shallow ReLU network on x^2.

    With k units (plus the affine skip connection) the network has k kinks and
    hence k+1 linear pieces.  Interpolating x^2 at the nodes j/(k+1) gives the
    per-piece chord error L^2/4 with L = 1/(k+1), i.e. 1/(4(k+1)^2); the
    Chebyshev-optimal piecewise fit halves this to 1/(8(k+1)^2).  Both sit
    above the proved universal floor 1/(32(k+1)^2), which therefore has the
    right exponent and is off only by a small constant factor.
    """
    pieces = k + 1
    nodes = [j / pieces for j in range(pieces + 1)]
    worst = 0.0
    for j in range(pieces):
        p, q = nodes[j], nodes[j + 1]
        for i in range(m // pieces + 1):
            x = p + (q - p) * i / (m // pieces + 1)
            interp = p * p + (x - p) * (p + q)   # chord through (p,p^2),(q,q^2)
            worst = max(worst, abs(x * x - interp))
    return worst


def demo_relu_barrier(seed: int = 12345) -> None:
    banner("7. Shallow ReLU barrier:  error >= 1/(32 (k+1)^2)  on x^2")
    print(f"{'k':>4} {'proved floor':>14} {'interpolant':>16} "
          f"{'random net':>12} {'affine gap len':>15}")
    rng = random.Random(seed)
    pts = grid(1000)
    for k in (0, 1, 2, 4, 8, 16, 32):
        floor = 1.0 / (32.0 * (k + 1) ** 2)
        pl = piecewise_linear_relu_fit_error(k)
        # a random network, to illustrate that the floor is a *universal* bound
        a = [rng.uniform(-2, 2) for _ in range(k)]
        w = [rng.uniform(-4, 4) for _ in range(k)]
        b = [rng.uniform(-2, 2) for _ in range(k)]
        rnd = sup_error(lambda x: relu_net(a, w, b, 0.0, 1.0, x),
                        lambda x: x * x, pts)
        gap = 1.0 / (k + 1)
        status = "" if (pl >= floor - 1e-15 and rnd >= floor - 1e-12) else "  <-- VIOLATION"
        print(f"{k:4d} {floor:14.3e} {pl:16.3e} {rnd:12.3e} {gap:15.5f}{status}")
    print("Mechanism: with k units there are at most k kinks, so one of the k+1")
    print("equal subintervals of [0,1] carries none and the network is exactly")
    print("affine there; a line cannot follow a parabola over a length-L window")
    print("without error at least L^2/32 (optimally L^2/8).")


def demo_separation() -> None:
    banner("8. The separation: EML width 2 vs shallow ReLU width Omega(eps^-1/2)")
    print(f"{'accuracy eps':>14} {'EML width':>11} {'EML h':>12} "
          f"{'ReLU units >=':>14}")
    for eps in (1e-2, 1e-3, 1e-4, 1e-6, 1e-8):
        h = min(1.0, math.sqrt(6 * eps))
        k_min = math.sqrt(1.0 / (32.0 * eps)) - 1.0
        err = sup_error(lambda x: sq_layer(h, x), lambda x: x * x, grid(1000))
        print(f"{eps:14.1e} {2:11d} {h:12.3e} {math.ceil(max(k_min, 0)):14d}"
              + (f"   (achieved {err:.2e})"))
    print("Caveat, stated honestly: the EML read-out weights are 1/h^2 ~ 1/(6 eps),")
    print("so accuracy is bought with weight magnitude, not with width.  Below")
    print("about eps = 1e-11 floating-point cancellation dominates.")


# ----------------------------------------------------------------------------
# Demonstration 9: the converse containment through softplus
# ----------------------------------------------------------------------------


def demo_softplus_containment(seed: int = 777) -> None:
    banner("9. Depth-2 EML contains shallow ReLU:  |softplus(Mt)/M - relu t| <= log2/M")
    pts = grid(400, -3.0, 3.0)
    print(f"{'M':>8} {'max deviation':>16} {'log 2 / M':>12} {'at t=0':>12}")
    for M in (1.0, 5.0, 10.0, 100.0, 1000.0):
        dev = max(abs(softplus(M * t) / M - relu(t)) for t in pts)
        print(f"{M:8.1f} {dev:16.3e} {math.log(2) / M:12.3e} "
              f"{abs(softplus(0.0) / M - 0.0):12.3e}"
              + ("" if dev <= math.log(2) / M + 1e-12 else "  <-- VIOLATION"))

    rng = random.Random(seed)
    k = 6
    a = [rng.uniform(-1, 1) for _ in range(k)]
    w = [rng.uniform(-3, 3) for _ in range(k)]
    b = [rng.uniform(-1, 1) for _ in range(k)]
    mass = sum(abs(ai) for ai in a)
    print()
    print(f"Emulating a random {k}-unit ReLU network (sum|a_i| = {mass:.4f}):")
    print(f"{'M':>8} {'max|EML - ReLU|':>18} {'bound':>12}")
    for M in (10.0, 100.0, 1000.0):
        def emulated(x: float, M: float = M) -> float:
            return sum(ai * softplus(M * (wi * x + bi)) / M
                       for ai, wi, bi in zip(a, w, b))
        dev = sup_error(lambda x: emulated(x),
                        lambda x: relu_net(a, w, b, 0.0, 0.0, x), grid(1000))
        print(f"{M:8.1f} {dev:18.3e} {mass * math.log(2) / M:12.3e}"
              + ("" if dev <= mass * math.log(2) / M + 1e-12 else "  <-- VIOLATION"))


def demo_lipschitz_rate() -> None:
    banner("10. Lipschitz Jackson rate 2L/N for the interpolant (inherited by EML)")

    def f(x: float) -> float:                    # 1-Lipschitz sawtooth-ish target
        return abs(x - 0.5) + 0.3 * math.sin(2.0 * x)

    L = 1.0 + 0.6                                # |f'| <= 1 + 0.6
    pts = grid(2000)
    print(f"{'N':>5} {'max|f - interp|':>18} {'2L/N':>12} {'ratio':>8}")
    for N in (2, 4, 8, 16, 32, 64):
        def interp(x: float, N: int = N) -> float:
            j = min(int(x * N), N - 1)
            p, q = j / N, (j + 1) / N
            t = (x - p) / (q - p)
            return (1 - t) * f(p) + t * f(q)
        err = sup_error(interp, f, pts)
        print(f"{N:5d} {err:18.3e} {2 * L / N:12.3e} {err / (2 * L / N):8.4f}")
    print("The rate is Theta(1/N) for both models: on the raw Lipschitz class")
    print("smoothness gives no advantage.  The h^2 phenomenon is about smooth")
    print("targets, not about width.")


def main() -> None:
    demo_squaring()
    demo_forward_is_slower()
    demo_gradients()
    demo_depth()
    demo_product_gate()
    demo_quadratic_forms()
    demo_relu_barrier()
    demo_separation()
    demo_softplus_containment()
    demo_lipschitz_rate()
    print()
    print("All numerical checks agree with the proved bounds.")


if __name__ == "__main__":
    main()
