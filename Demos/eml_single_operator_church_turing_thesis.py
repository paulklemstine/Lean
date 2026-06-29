"""
demo.py -- Numerical demonstrations for the EML Single-Operator Church-Turing Thesis.

The single binary primitive

    eml(x, y) = exp(x) - log(y)

together with the field operations (+, *, neg, inv) and real constants, generates
a class of real functions that:

  * re-derives exp and log on demand (fusion identities),
  * is closed under finite sums and products,
  * contains every multivariate polynomial,
  * contains every standard smooth neural activation
    (sigmoid, softplus, tanh, SiLU/swish).

This file demonstrates each of these facts numerically and self-containedly.
Run with:  python3 demo.py
"""

from __future__ import annotations

import math
from typing import Callable, List, Sequence, Tuple


# ---------------------------------------------------------------------------
# 0. The single primitive and the totalization conventions.
# ---------------------------------------------------------------------------

def safe_log(y: float) -> float:
    """Totalized natural logarithm: log(y) = 0 for y <= 0 (junk value)."""
    return math.log(y) if y > 0.0 else 0.0


def safe_inv(x: float) -> float:
    """Totalized reciprocal: inv(0) = 0 (junk value)."""
    return 1.0 / x if x != 0.0 else 0.0


def eml(x: float, y: float) -> float:
    """The single fused primitive  eml(x, y) = exp(x) - log(y)."""
    return math.exp(x) - safe_log(y)


# ---------------------------------------------------------------------------
# 1. Fusion identities: exp and log are recovered from eml plus constants.
# ---------------------------------------------------------------------------

def exp_via_eml(x: float) -> float:
    """exp(x) = eml(x, 1)   since  log(1) = 0."""
    return eml(x, 1.0)


def log_via_eml(y: float) -> float:
    """log(y) = 1 - eml(0, y)   since  eml(0, y) = 1 - log(y)."""
    return 1.0 - eml(0.0, y)


def subtraction_via_eml(a: float, b: float) -> float:
    """For a > 0:  a - b = eml(log a, exp b)   (subtraction routed through eml)."""
    return eml(math.log(a), math.exp(b))


def demo_fusion() -> None:
    print("=" * 72)
    print("1. FUSION IDENTITIES  (exp, log, subtraction recovered from eml)")
    print("=" * 72)
    print(f"{'x':>8} | {'exp(x)':>14} | {'eml(x,1)':>14} | {'abs error':>12}")
    for x in (-2.0, -0.5, 0.0, 1.0, 2.5):
        print(f"{x:8.3f} | {math.exp(x):14.9f} | {exp_via_eml(x):14.9f} "
              f"| {abs(math.exp(x) - exp_via_eml(x)):12.2e}")
    print()
    print(f"{'y':>8} | {'log(y)':>14} | {'1-eml(0,y)':>14} | {'abs error':>12}")
    for y in (0.25, 0.5, 1.0, 2.0, 7.5):
        print(f"{y:8.3f} | {math.log(y):14.9f} | {log_via_eml(y):14.9f} "
              f"| {abs(math.log(y) - log_via_eml(y)):12.2e}")
    print()
    print("Subtraction via eml(log a, exp b) = a - b  (a > 0):")
    for a, b in ((3.0, 1.0), (10.0, 4.0), (0.5, 2.0)):
        got = subtraction_via_eml(a, b)
        print(f"  a={a:5.2f}, b={b:5.2f}:  a-b={a-b:8.4f}   eml(...)={got:8.4f}"
              f"   err={abs((a - b) - got):.2e}")
    print()


# ---------------------------------------------------------------------------
# 2. Closure under finite sums and products  ->  polynomial completeness.
#
# A polynomial in n variables is represented as a list of monomials, each a
# (coefficient, exponent-tuple) pair.  We evaluate it using ONLY:
#   - constants, variables,
#   - addition and multiplication (closure),
#   - integer powers (repeated multiplication),
# which is precisely the single-operator-representable toolkit (no exp/log
# is even needed -- it comes "for free" from the closure machinery).
# ---------------------------------------------------------------------------

Monomial = Tuple[float, Tuple[int, ...]]


def eval_power(base: float, k: int) -> float:
    """x^k as a finite product of copies of x (closure under products)."""
    acc = 1.0
    for _ in range(k):
        acc = acc * base
    return acc


def eval_polynomial(monomials: Sequence[Monomial], x: Sequence[float]) -> float:
    """Evaluate sum_d coeff_d * prod_i x_i^{d_i}  via finite sum/product closure."""
    total = 0.0  # empty-sum base case
    for coeff, exps in monomials:
        term = 1.0  # empty-product base case
        for i, di in enumerate(exps):
            term = term * eval_power(x[i], di)
        total = total + coeff * term
    return total


def demo_polynomial() -> None:
    print("=" * 72)
    print("2. ALGEBRAIC COMPLETENESS  (every polynomial is representable)")
    print("=" * 72)
    # p(x, y) = 3 x^2 y - 7 x y^4 + 5
    poly: List[Monomial] = [(3.0, (2, 1)), (-7.0, (1, 4)), (5.0, (0, 0))]
    print("p(x, y) = 3 x^2 y - 7 x y^4 + 5")
    print(f"{'(x, y)':>16} | {'closure eval':>16} | {'direct eval':>16} | {'err':>10}")
    for x, y in ((1.0, 1.0), (2.0, -1.0), (-1.5, 0.5), (0.0, 3.0)):
        got = eval_polynomial(poly, (x, y))
        direct = 3.0 * x**2 * y - 7.0 * x * y**4 + 5.0
        print(f"  ({x:5.2f},{y:5.2f})   | {got:16.6f} | {direct:16.6f} "
              f"| {abs(got - direct):10.2e}")
    print()


# ---------------------------------------------------------------------------
# 3. Applications completeness: neural activations as eml composites.
#
# Each activation is built ONLY from eml (for exp/log) plus field operations.
# ---------------------------------------------------------------------------

def sigmoid_eml(x: float) -> float:
    """sigma(x) = (1 + exp(-x))^{-1}  = inv(1 + eml(-x, 1))."""
    return safe_inv(1.0 + exp_via_eml(-x))


def softplus_eml(x: float) -> float:
    """softplus(x) = log(1 + exp(x))  = 1 - eml(0, 1 + eml(x, 1))."""
    return log_via_eml(1.0 + exp_via_eml(x))


def tanh_eml(x: float) -> float:
    """tanh(x) = sinh(x) * cosh(x)^{-1}, with sinh/cosh built from eml."""
    sinh = (exp_via_eml(x) - exp_via_eml(-x)) * 0.5
    cosh = (exp_via_eml(x) + exp_via_eml(-x)) * 0.5
    return sinh * safe_inv(cosh)


def silu_eml(x: float) -> float:
    """SiLU / swish:  x * sigma(x)  = proj_0 * sigmoid."""
    return x * sigmoid_eml(x)


def demo_activations() -> None:
    print("=" * 72)
    print("3. APPLICATIONS COMPLETENESS  (neural activations via eml only)")
    print("=" * 72)
    activations: List[Tuple[str, Callable[[float], float], Callable[[float], float]]] = [
        ("sigmoid", sigmoid_eml, lambda x: 1.0 / (1.0 + math.exp(-x))),
        ("softplus", softplus_eml, lambda x: math.log1p(math.exp(x))),
        ("tanh", tanh_eml, math.tanh),
        ("silu", silu_eml, lambda x: x / (1.0 + math.exp(-x))),
    ]
    xs = (-3.0, -1.0, 0.0, 1.0, 3.0)
    for name, f_eml, f_ref in activations:
        print(f"\n  {name}:")
        print(f"{'x':>8} | {'eml-built':>16} | {'reference':>16} | {'abs error':>12}")
        max_err = 0.0
        for x in xs:
            a, b = f_eml(x), f_ref(x)
            max_err = max(max_err, abs(a - b))
            print(f"{x:8.3f} | {a:16.9f} | {b:16.9f} | {abs(a - b):12.2e}")
        print(f"    max abs error over sample: {max_err:.2e}")
    print()


# ---------------------------------------------------------------------------
# 4. A tiny feed-forward network: affine pre-activation (polynomial) + eml
#    activation -- every piece lives in the single-operator class.
# ---------------------------------------------------------------------------

def mlp_layer_eml(
    weights: Sequence[Sequence[float]],
    biases: Sequence[float],
    activation: Callable[[float], float],
    x: Sequence[float],
) -> List[float]:
    """One feed-forward layer: y_j = activation( sum_i W_ji x_i + b_j ).

    The affine pre-activation is a degree-one polynomial (representable),
    and the activation is eml-representable; hence the whole layer is.
    """
    outputs: List[float] = []
    for w_row, b in zip(weights, biases):
        pre = b
        for wij, xi in zip(w_row, x):
            pre = pre + wij * xi
        outputs.append(activation(pre))
    return outputs


def demo_network() -> None:
    print("=" * 72)
    print("4. A FEED-FORWARD NETWORK ENTIRELY IN THE SINGLE-OPERATOR CLASS")
    print("=" * 72)
    W1 = [[1.0, -2.0], [0.5, 0.5], [-1.0, 1.0]]
    b1 = [0.1, -0.2, 0.3]
    W2 = [[1.0, -1.0, 2.0]]
    b2 = [0.0]
    x = [0.7, -0.4]
    h = mlp_layer_eml(W1, b1, silu_eml, x)         # hidden layer with SiLU
    y = mlp_layer_eml(W2, b2, sigmoid_eml, h)      # output layer with sigmoid
    print(f"  input    x = {x}")
    print(f"  hidden   h = {[round(v, 6) for v in h]}   (SiLU activation)")
    print(f"  output   y = {[round(v, 6) for v in y]}   (sigmoid activation)")
    print("  Every linear map is a polynomial; every activation is an eml")
    print("  composite -- so the whole network is single-operator representable.")
    print()


def main() -> None:
    demo_fusion()
    demo_polynomial()
    demo_activations()
    demo_network()
    print("All demonstrations completed: one operator computes them all.")


if __name__ == "__main__":
    main()
