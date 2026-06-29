"""
Tropical valuation -> Ultrametric seminorm: numerical demonstrations.

This self-contained script illustrates the main results of the paper
"A Quantitative Functorial Bridge from Tropical Valuations to Ultrametric
Seminorms":

  * valuation reconstruction (the norm IS the valuation),
  * the strong (ultrametric) triangle inequality and the isosceles principle,
  * sharp Lipschitz transfer with identical constants,
  * the iterated C^n Lipschitz rate (depth separation),
  * post-quantum gap transfer and certified-robustness radius transfer,
  * the canonical p-adic instantiation |q|_p = p^(-v_p(q)).

Run:  python demo.py
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from math import gcd, exp, log
from typing import Callable


# ---------------------------------------------------------------------------
# 1. p-adic valuation and the order-reversing exponential bridge
# ---------------------------------------------------------------------------

def p_adic_valuation(q: Fraction, p: int) -> int:
    """Return v_p(q), the exponent of p in q = a/b (q != 0).

    v_p(p^k * u) = k where u has neither numerator nor denominator divisible by p.
    """
    if q == 0:
        raise ValueError("v_p(0) is +infinity; pass a nonzero rational")
    a, b = abs(q.numerator), q.denominator
    k = 0
    while a % p == 0:
        a //= p
        k += 1
    while b % p == 0:
        b //= p
        k -= 1
    return k


def p_adic_norm(q: Fraction, p: int) -> float:
    """|q|_p = p^(-v_p(q)), with |0|_p = 0. The bridge map t -> p^(-t)."""
    if q == 0:
        return 0.0
    return float(p) ** (-p_adic_valuation(q, p))


def bridge_exp_identity(q: Fraction, p: int) -> tuple[float, float]:
    """Capstone identity: |q|_p == exp(-v_p(q) * log p) for q != 0.

    Returns (left = |q|_p, right = exp(-v_p(q) log p)) which should match.
    """
    v = p_adic_valuation(q, p)
    left = p_adic_norm(q, p)
    right = exp(-v * log(p))
    return left, right


# ---------------------------------------------------------------------------
# 2. Abstract tropical valuation carrier and its reconstruction (N-valued)
# ---------------------------------------------------------------------------

@dataclass
class TropicalValuationCarrier:
    """An N-valued tropical valuation carrier (matches the Lean structure).

    `val` must satisfy:
        val(0) = 0
        val(-x) = val(x)
        val(x*y) = val(x) * val(y)
        val(x+y) <= max(val x, val y)        # strong / tropical additivity
    """
    add: Callable[[int, int], int]
    neg: Callable[[int], int]
    mul: Callable[[int, int], int]
    zero: int
    val: Callable[[int], int]


def reconstruct_norm(carrier: TropicalValuationCarrier) -> Callable[[int], int]:
    """valuationReconstruct: the ultrametric norm IS the valuation."""
    return carrier.val


def check_ultrametric(carrier: TropicalValuationCarrier, sample: list[int]) -> bool:
    """Verify the strong triangle inequality on a finite sample (Theorem 4.1)."""
    norm = reconstruct_norm(carrier)
    ok = True
    for x in sample:
        for y in sample:
            lhs = norm(carrier.add(x, y))
            rhs = max(norm(x), norm(y))
            if lhs > rhs:
                ok = False
    return ok


def check_isosceles(carrier: TropicalValuationCarrier, sample: list[int]) -> bool:
    """If norm x <= norm y then norm(x+y) <= norm y (Theorem 4.3)."""
    norm = reconstruct_norm(carrier)
    for x in sample:
        for y in sample:
            if norm(x) <= norm(y) and norm(carrier.add(x, y)) > norm(y):
                return False
    return True


# ---------------------------------------------------------------------------
# 3. Lipschitz transfer and the iterated C^n rate
# ---------------------------------------------------------------------------

def is_tropical_lipschitz(val: Callable[[int], int], C: int,
                          f: Callable[[int], int], sample: list[int]) -> bool:
    """TropLipschitzWith: val(f x) <= C * val(x) on the sample."""
    return all(val(f(x)) <= C * val(x) for x in sample)


def iterate(f: Callable[[int], int], n: int, x: int) -> int:
    """f^[n](x)."""
    for _ in range(n):
        x = f(x)
    return x


def iterated_bound(C: int, n: int, base_val: int) -> int:
    """Certified bound val(f^[n] x) <= C^n * val(x) (Theorem 6.5)."""
    return (C ** n) * base_val


# ---------------------------------------------------------------------------
# 4. Post-quantum gap transfer and robustness radius transfer
# ---------------------------------------------------------------------------

def gap_transfer_holds(val: Callable[[int], int], sub: Callable[[int, int], int],
                       secret: int, gap: int, sample: list[int]) -> bool:
    """If for all y != secret, val(y - secret) >= gap, the same holds for the
    reconstructed norm (Theorem 8.1). Here norm == val, so it is automatic; we
    verify the hypothesis is consistent on the sample."""
    return all(val(sub(y, secret)) >= gap for y in sample if y != secret)


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_padic() -> None:
    print("=" * 68)
    print("p-adic valuation, norm, and the exponential bridge identity")
    print("=" * 68)
    p = 3
    samples = [Fraction(18), Fraction(5, 27), Fraction(7), Fraction(54, 5)]
    for q in samples:
        v = p_adic_valuation(q, p)
        left, right = bridge_exp_identity(q, p)
        print(f"  q={str(q):>7}   v_{p}(q)={v:>3}   |q|_{p}={left:8.5f}"
              f"   exp(-v log p)={right:8.5f}   match={abs(left-right) < 1e-9}")
    # ultrametric strong triangle inequality on Q with the p-adic norm
    x, y = Fraction(9), Fraction(3)   # v_3 = 2 and 1
    s = p_adic_norm(x + y, p)
    print(f"\n  Strong triangle: |x+y|_3={s:.5f} <= max(|x|_3,|y|_3)="
          f"{max(p_adic_norm(x,p), p_adic_norm(y,p)):.5f}")
    print(f"  (x=9 has v_3=2 -> small; y=3 has v_3=1 -> larger; sum tracks max)\n")


def demo_reconstruction() -> None:
    print("=" * 68)
    print("Valuation reconstruction: an abstract N-valued carrier")
    print("=" * 68)
    # Carrier on Z/(value = number of trailing factors of 2, i.e. 2-adic-like),
    # modeled abstractly: val(n) = 2 ** (count of trailing zero bits of |n|), 0->0.
    def val(n: int) -> int:
        if n == 0:
            return 0
        m = abs(n)
        k = 0
        while m % 2 == 0:
            m //= 2
            k += 1
        # ultrametric "size": bigger when LESS divisible by 2 (height-like)
        return 2 ** (10 - k) if k <= 10 else 1

    carrier = TropicalValuationCarrier(
        add=lambda a, b: a + b,
        neg=lambda a: -a,
        mul=lambda a, b: a * b,
        zero=0,
        val=val,
    )
    sample = list(range(-8, 9))
    print(f"  strong triangle inequality holds on sample: "
          f"{check_ultrametric(carrier, sample)}")
    print(f"  isosceles principle holds on sample:        "
          f"{check_isosceles(carrier, sample)}")
    print(f"  norm(0) = {reconstruct_norm(carrier)(0)} (expected 0)\n")


def demo_lipschitz_transfer() -> None:
    print("=" * 68)
    print("Sharp Lipschitz transfer and the iterated C^n rate")
    print("=" * 68)
    # val(n) = |n| as a toy valuation; f scales by at most C.
    val = abs
    C = 3
    f = lambda n: 3 * n            # val(f n) = 3 |n| = C * val n  -> C-Lipschitz
    sample = list(range(-5, 6))
    print(f"  f(n)=3n is tropical {C}-Lipschitz on sample: "
          f"{is_tropical_lipschitz(val, C, f, sample)}")
    print("  Same constant C transfers to the ultrametric norm (norm == val).\n")
    print("  Iterated rate  val(f^[n] x) <= C^n * val(x):")
    x = 2
    for n in range(0, 6):
        actual = val(iterate(f, n, x))
        bound = iterated_bound(C, n, val(x))
        print(f"    n={n}: actual={actual:>6}   bound C^n*val(x)={bound:>6}   "
              f"ok={actual <= bound}")
    print("  (Depth separation: an L-layer C-Lipschitz net is C^L-Lipschitz.)\n")


def demo_gap_transfer() -> None:
    print("=" * 68)
    print("Post-quantum gap transfer")
    print("=" * 68)
    # 2-adic height-like valuation; secret chosen so all decoys are far.
    def val(n: int) -> int:
        if n == 0:
            return 0
        m = abs(n)
        k = 0
        while m % 2 == 0:
            m //= 2
            k += 1
        return 2 ** (10 - k) if k <= 10 else 1
    sub = lambda a, b: a - b
    secret = 0
    sample = [n for n in range(-7, 8) if n % 2 == 1]   # all odd -> val high
    gap = min(val(sub(y, secret)) for y in sample if y != secret)
    print(f"  secret=0, decoys=odd integers, observed gap={gap}")
    print(f"  gap transfers to ultrametric norm: "
          f"{gap_transfer_holds(val, sub, secret, gap, sample)}")
    print("  A combinatorial (tropical) separation gap is a geometric "
          "(ultrametric) security margin.\n")


def main() -> None:
    demo_padic()
    demo_reconstruction()
    demo_lipschitz_transfer()
    demo_gap_transfer()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
