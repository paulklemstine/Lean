"""
Numerical demonstrations of the two-sided power-saving estimate for monic
Minkowski polynomials.

For a polynomial f in Z[x] of degree k >= 2 and a nonempty finite set A of
integers, the elementwise image f(A) = { f(a) : a in A } satisfies

        |A| / k  <=  |f(A)|  <=  |A| ** (k - 1/k^2).

  * The lower bound is the FIBER estimate: a degree-k polynomial is at most
    k-to-one, so the image cannot collapse by more than a factor k.
  * The upper bound is the POWER-SAVING estimate with the explicit constant
    c(k) = 1/k^2; it rests on the real inequality  n <= n ** (k - 1/k^2)
    for n >= 1, k >= 2, together with the trivial ceiling |f(A)| <= |A|.

This script is self-contained (standard library only).
"""

from __future__ import annotations

from collections import Counter
from typing import Callable, Dict, List, Sequence, Tuple


# --------------------------------------------------------------------------- #
# Core primitives                                                             #
# --------------------------------------------------------------------------- #

def eval_poly(coeffs: Sequence[int], x: int) -> int:
    """Evaluate a polynomial by Horner's rule.

    ``coeffs`` are ordered from the highest degree term down to the constant,
    i.e. coeffs = [a_k, ..., a_1, a_0] represents a_k x^k + ... + a_0.
    """
    acc = 0
    for c in coeffs:
        acc = acc * x + c
    return acc


def degree(coeffs: Sequence[int]) -> int:
    """Degree of the polynomial given by ``coeffs`` (highest term first)."""
    for i, c in enumerate(coeffs):
        if c != 0:
            return len(coeffs) - 1 - i
    raise ValueError("zero polynomial has no degree")


def minkowski_image(coeffs: Sequence[int], A: Sequence[int]) -> List[int]:
    """The deduplicated elementwise image f(A), returned sorted."""
    return sorted({eval_poly(coeffs, a) for a in A})


def power_saving_constant(k: int) -> float:
    """c(k) = 1 / k^2."""
    return 1.0 / (k * k)


def shifted_exponent(k: int) -> float:
    """k - c(k) = k - 1/k^2, the exponent in the upper bound."""
    return k - power_saving_constant(k)


# --------------------------------------------------------------------------- #
# Corridor verification                                                       #
# --------------------------------------------------------------------------- #

def corridor(coeffs: Sequence[int], A: Sequence[int]) -> Dict[str, float]:
    """Compute the corridor endpoints and the actual image size.

    Returns a dictionary with the lower bound |A|/k, the actual |f(A)|, the
    upper bound |A|^(k - 1/k^2), and a boolean flag confirming the sandwich.
    """
    k = degree(coeffs)
    n = len(set(A))
    m = len(minkowski_image(coeffs, A))
    lower = n / k
    upper = float(n) ** shifted_exponent(k)
    return {
        "n": n,
        "k": k,
        "image_size": m,
        "lower": lower,
        "upper": upper,
        "holds": lower <= m <= upper + 1e-9,
    }


def fiber_histogram(coeffs: Sequence[int], A: Sequence[int]) -> Counter:
    """Map each output value b to the size of its fiber { a in A : f(a) = b }.

    The maximum fiber size never exceeds the degree k -- this is the exact
    mechanism behind the lower bound |A| <= k * |f(A)|.
    """
    return Counter(eval_poly(coeffs, a) for a in set(A))


# --------------------------------------------------------------------------- #
# Demonstrations                                                              #
# --------------------------------------------------------------------------- #

def demo_opening_example() -> None:
    """The x^2 example on {-2,...,2} from the article."""
    print("=" * 68)
    print("Demo 1: squaring the window {-2,...,2}")
    print("=" * 68)
    coeffs = [1, 0, 0]  # x^2
    A = list(range(-2, 3))
    img = minkowski_image(coeffs, A)
    print(f"A           = {A}")
    print(f"f(A)        = {img}")
    info = corridor(coeffs, A)
    print(f"|A|={info['n']}, k={info['k']}, |f(A)|={info['image_size']}")
    print(f"corridor    : {info['lower']:.3f} <= {info['image_size']} "
          f"<= {info['upper']:.3f}   holds={info['holds']}")


def demo_sharp_lower_bound() -> None:
    """The factor-k collapse of squaring approaches |A|/2."""
    print("\n" + "=" * 68)
    print("Demo 2: sharpness of the lower bound (f = x^2 on {-n,...,n})")
    print("=" * 68)
    coeffs = [1, 0, 0]
    print(f"{'n':>5} {'|A|':>6} {'|f(A)|':>8} {'ratio':>10} {'-> 1/k':>8}")
    for n in (5, 10, 50, 200, 1000):
        A = list(range(-n, n + 1))
        m = len(minkowski_image(coeffs, A))
        card = len(A)
        print(f"{n:>5} {card:>6} {m:>8} {m/card:>10.5f} {0.5:>8.3f}")


def demo_injective_progression() -> None:
    """An arithmetic progression on which f is injective: |f(A)| = |A|."""
    print("\n" + "=" * 68)
    print("Demo 3: injective progression pins the exponent to 1")
    print("=" * 68)
    coeffs = [1, 0, 1]  # x^2 + 1, monotone for x >= 0
    A = list(range(0, 12))  # all nonnegative -> strictly increasing images
    info = corridor(coeffs, A)
    print(f"f(x)=x^2+1 on {A}")
    print(f"|A|={info['n']}, |f(A)|={info['image_size']} "
          f"(injective => equal)")
    print(f"upper bound |A|^(k-1/k^2) = {info['upper']:.3f}  "
          f"(loose; exponent cannot drop below 1)")


def demo_fiber_histogram() -> None:
    """Show that every fiber has size at most k."""
    print("\n" + "=" * 68)
    print("Demo 4: fiber histogram, max fiber size <= k")
    print("=" * 68)
    coeffs = [1, 0, -3, 0]  # x^3 - 3x, degree 3
    A = list(range(-4, 5))
    hist = fiber_histogram(coeffs, A)
    k = degree(coeffs)
    print(f"f(x)=x^3-3x, k={k}, A={A}")
    for b in sorted(hist):
        print(f"  fiber over {b:>4}: size {hist[b]}")
    print(f"max fiber size = {max(hist.values())} <= k = {k}")
    print(f"sum of fiber sizes = {sum(hist.values())} = |A| = {len(set(A))}")


def demo_higher_degree_corridor() -> None:
    """Corridor for several degrees on a common window."""
    print("\n" + "=" * 68)
    print("Demo 5: corridor across degrees on {-6,...,6}")
    print("=" * 68)
    A = list(range(-6, 7))
    polys: List[Tuple[str, List[int]]] = [
        ("x^2", [1, 0, 0]),
        ("x^3", [1, 0, 0, 0]),
        ("x^4", [1, 0, 0, 0, 0]),
        ("x^2 + x", [1, 1, 0]),
    ]
    print(f"{'f':>10} {'k':>3} {'|f(A)|':>8} {'lower':>10} {'upper':>12} "
          f"{'holds':>7}")
    for name, coeffs in polys:
        info = corridor(coeffs, A)
        print(f"{name:>10} {info['k']:>3} {info['image_size']:>8} "
              f"{info['lower']:>10.3f} {info['upper']:>12.3f} "
              f"{str(info['holds']):>7}")


def main() -> None:
    demo_opening_example()
    demo_sharp_lower_bound()
    demo_injective_progression()
    demo_fiber_histogram()
    demo_higher_degree_corridor()


if __name__ == "__main__":
    main()
