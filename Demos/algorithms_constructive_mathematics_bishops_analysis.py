#!/usr/bin/env python3
"""
algorithms.py — Core algorithms from the constructive analysis framework.

Implements the mathematical algorithms formalized in Lean 4, including:
- ComputableReal arithmetic (add, neg, multiply)
- Certified bisection with explicit error certificates
- Effective Cauchy completion via diagonal construction
- Modulus-continuous function composition with error propagation

Each algorithm mirrors a formally verified theorem.
"""

from dataclasses import dataclass
from typing import Callable, Optional, Tuple, List
from fractions import Fraction
import math


# =============================================================================
# ComputableReal: Bishop-Style Real Numbers
# =============================================================================

@dataclass
class ComputableReal:
    """
    A Bishop-style computable real number.

    Attributes:
        seq: A function ℕ → ℚ giving rational approximations.
        mod: A Cauchy modulus ℕ → ℕ such that for i, j ≥ mod(n),
             |seq(i) - seq(j)| ≤ 1/2^n.

    Invariant (cauchy'):
        ∀ n i j, mod(n) ≤ i → mod(n) ≤ j → |seq(i) - seq(j)| ≤ 1/2^n

    Corresponds to `ComputableReal` in ConstructiveAnalysis/Basic.lean.
    """
    seq: Callable[[int], Fraction]
    mod: Callable[[int], int]

    def approx_at(self, n: int) -> Fraction:
        """Canonical approximant at precision n: seq(mod(n)).

        Corresponds to `ComputableReal.approxAt` in Lean.
        """
        return self.seq(self.mod(n))

    def evaluate(self, precision: int) -> float:
        """Return a float approximation at the given precision level."""
        return float(self.approx_at(precision))

    @staticmethod
    def of_rat(q: Fraction) -> 'ComputableReal':
        """Construct from a rational constant.

        Corresponds to `ComputableReal.ofRat` in Lean.
        Complexity: O(1) per evaluation.
        """
        return ComputableReal(seq=lambda _: q, mod=lambda _: 0)

    @staticmethod
    def of_float(x: float) -> 'ComputableReal':
        """Construct from a float (as a rational constant)."""
        return ComputableReal.of_rat(Fraction(x).limit_denominator(10**15))


def computable_add(x: ComputableReal, y: ComputableReal) -> ComputableReal:
    """
    Sum of two computable reals.

    Modulus: mod(n) = max(x.mod(n+1), y.mod(n+1))

    The key insight: we need precision n+1 from each summand because
    the triangle inequality loses a factor of 2:
        |sum_i - sum_j| ≤ |x_i - x_j| + |y_i - y_j| ≤ 1/2^(n+1) + 1/2^(n+1) = 1/2^n

    Corresponds to `ComputableReal.add` in Lean.
    Complexity: O(1) per evaluation (plus cost of evaluating x and y).
    """
    return ComputableReal(
        seq=lambda k: x.seq(k) + y.seq(k),
        mod=lambda n: max(x.mod(n + 1), y.mod(n + 1))
    )


def computable_neg(x: ComputableReal) -> 'ComputableReal':
    """
    Negation of a computable real.

    Modulus: same as x (|(-a) - (-b)| = |a - b|).

    Corresponds to `ComputableReal.neg` in Lean.
    Complexity: O(1) per evaluation.
    """
    return ComputableReal(
        seq=lambda k: -x.seq(k),
        mod=x.mod
    )


def computable_sub(x: ComputableReal, y: ComputableReal) -> ComputableReal:
    """Subtraction: x - y = x + (-y)."""
    return computable_add(x, computable_neg(y))


def computable_mul(x: ComputableReal, y: ComputableReal,
                   x_bound: Fraction, y_bound: Fraction) -> ComputableReal:
    """
    Multiplication of computable reals with known bounds.

    Requires |x| ≤ x_bound and |y| ≤ y_bound for all approximants.
    Modulus: mod(n) = max(x.mod(n + ceil(log2(2*y_bound))),
                         y.mod(n + ceil(log2(2*x_bound))))

    Complexity: O(1) per evaluation (plus cost of evaluating x and y).
    """
    # Compute required extra precision
    extra_x = max(1, math.ceil(math.log2(float(2 * y_bound + 1))))
    extra_y = max(1, math.ceil(math.log2(float(2 * x_bound + 1))))

    return ComputableReal(
        seq=lambda k: x.seq(k) * y.seq(k),
        mod=lambda n: max(x.mod(n + extra_x), y.mod(n + extra_y))
    )


# =============================================================================
# Certified Bisection
# =============================================================================

@dataclass
class SignedBisectionState:
    """
    Certified bisection state maintaining a sign-change interval.

    Invariants:
        - l ≤ r
        - f(l) ≤ 0 ≤ f(r)

    Corresponds to `SignedBisectionState` in ConstructiveAnalysis/Basic.lean.
    """
    l: float
    r: float
    f_l: float  # f(l) ≤ 0
    f_r: float  # 0 ≤ f(r)

    @property
    def width(self) -> float:
        return self.r - self.l

    @property
    def midpoint(self) -> float:
        return (self.l + self.r) / 2

    def verify(self) -> bool:
        """Check the invariants."""
        return self.l <= self.r and self.f_l <= 0 <= self.f_r


def bisection_step(
    f: Callable[[float], float],
    state: SignedBisectionState
) -> SignedBisectionState:
    """
    One step of certified bisection.

    Corresponds to `bisection_step` in ConstructiveAnalysis/Bisection.lean.

    Theorem: The returned state satisfies:
        - state.l ≤ new.l ≤ new.r ≤ state.r
        - new.width = state.width / 2
        - f(new.l) ≤ 0 ≤ f(new.r)

    Complexity: O(1) (one function evaluation).
    """
    mid = state.midpoint
    f_mid = f(mid)

    if f_mid <= 0:
        return SignedBisectionState(l=mid, r=state.r, f_l=f_mid, f_r=state.f_r)
    else:
        return SignedBisectionState(l=state.l, r=mid, f_l=state.f_l, f_r=f_mid)


def iterated_bisection(
    f: Callable[[float], float],
    a: float,
    b: float,
    n: int
) -> SignedBisectionState:
    """
    n iterations of certified bisection.

    Corresponds to `iterated_bisection` in ConstructiveAnalysis/Bisection.lean.

    Theorem: Returns state with:
        - a ≤ state.l ≤ state.r ≤ b
        - state.width = (b - a) / 2^n
        - f(state.l) ≤ 0 ≤ f(state.r)

    Complexity: O(n) function evaluations.
    Space: O(1).
    """
    state = SignedBisectionState(l=a, r=b, f_l=f(a), f_r=f(b))
    assert state.verify(), "Initial sign change required"

    for _ in range(n):
        state = bisection_step(f, state)

    return state


# =============================================================================
# Modulus-Continuous Functions
# =============================================================================

@dataclass
class ModulusContinuousFunction:
    """
    A function with an explicit modulus of uniform continuity.

    The modulus μ guarantees: if |x - y| ≤ 1/2^μ(n) for x, y in [a, b],
    then |f(x) - f(y)| ≤ 1/2^n.

    Corresponds to `ModulusContinuousOn` in ConstructiveAnalysis/Basic.lean.
    """
    f: Callable[[float], float]
    mu: Callable[[int], int]  # Modulus of continuity
    a: float  # Domain left endpoint
    b: float  # Domain right endpoint

    def error_propagation(self, x: float, y: float, n: int) -> dict:
        """
        Certified error propagation: given |x - y| ≤ 1/2^μ(n),
        certify |f(x) - f(y)| ≤ 1/2^n.

        Corresponds to `error_propagation` in ConstructiveAnalysis/Bisection.lean.
        """
        input_threshold = 1.0 / 2 ** self.mu(n)
        input_diff = abs(x - y)
        output_diff = abs(self.f(x) - self.f(y))
        output_bound = 1.0 / 2 ** n

        return {
            "input_difference": input_diff,
            "input_threshold": input_threshold,
            "input_within_threshold": input_diff <= input_threshold,
            "output_difference": output_diff,
            "output_bound": output_bound,
            "output_within_bound": output_diff <= output_bound,
        }


def compose_modulus(
    f_mcf: ModulusContinuousFunction,
    g_mcf: ModulusContinuousFunction
) -> Callable[[int], int]:
    """
    Compose moduli of continuity: μ_{g∘f}(n) = μ_f(μ_g(n)).

    Corresponds to `error_propagation_compose` in ConstructiveAnalysis/Bisection.lean.
    """
    return lambda n: f_mcf.mu(g_mcf.mu(n))


# =============================================================================
# Effective Cauchy Completion
# =============================================================================

@dataclass
class EffectiveCauchySequence:
    """
    An effective Cauchy sequence of computable reals.

    Attributes:
        seq: ℕ → ComputableReal, the sequence elements
        mod: ℕ → ℕ, the Cauchy modulus

    Invariant: For i, j ≥ mod(n),
        |seq(i).approxAt(n+2) - seq(j).approxAt(n+2)| ≤ 1/2^n

    Corresponds to `EffCauchySeq` in ConstructiveAnalysis/Completeness.lean.
    """
    seq: Callable[[int], ComputableReal]
    mod: Callable[[int], int]

    def diag_approx(self, n: int) -> Fraction:
        """
        Diagonal approximation: at stage n, use seq(mod(n+2)).approxAt(n+2).

        Corresponds to `EffCauchySeq.diagApprox` in Lean.
        """
        return self.seq(self.mod(n + 2)).approx_at(n + 2)

    def effective_limit(self) -> ComputableReal:
        """
        Construct the effective limit via diagonal construction.

        The resulting ComputableReal has:
            seq(n) = diagApprox(n)
            mod(n) = n + 2

        Cauchy modulus: 3/2^(n+2) ≤ 1/2^n ✓

        Corresponds to `EffCauchySeq.effectiveLimit` in Lean.

        Complexity: O(1) per evaluation of the limit, plus the cost
        of evaluating the appropriate sequence element.
        """
        return ComputableReal(
            seq=lambda n: self.diag_approx(n),
            mod=lambda n: n + 2
        )


# =============================================================================
# Example constructions
# =============================================================================

def sqrt_computable(a: int) -> ComputableReal:
    """
    Construct √a as a computable real via Newton's method.
    Requires a ≥ 0.
    """
    assert a >= 0
    if a == 0:
        return ComputableReal.of_rat(Fraction(0))

    def seq(n: int) -> Fraction:
        x = Fraction(a)
        for _ in range(n + 5):
            x = (x + Fraction(a) / x) / 2
        return x

    return ComputableReal(seq=seq, mod=lambda n: n + 10)


def exp_computable(x_rat: Fraction, num_terms: int = 50) -> ComputableReal:
    """
    Construct e^x as a computable real via Taylor series.
    """
    def seq(n: int) -> Fraction:
        terms = max(n + 10, num_terms)
        result = Fraction(0)
        power = Fraction(1)
        factorial = 1
        for k in range(terms):
            result += power / factorial
            power *= x_rat
            factorial *= (k + 1)
        return result

    return ComputableReal(seq=seq, mod=lambda n: n + 20)


# =============================================================================
# Main: Algorithm Demonstrations
# =============================================================================

if __name__ == "__main__":
    print("=" * 70)
    print("Algorithm Demonstrations")
    print("=" * 70)

    # 1. Certified bisection
    print("\n--- Certified Bisection: x² - 2 = 0 ---")
    f = lambda x: x**2 - 2
    state = iterated_bisection(f, 0, 2, 50)
    print(f"After 50 bisection steps:")
    print(f"  Interval: [{state.l}, {state.r}]")
    print(f"  Width: {state.width:.2e}")
    print(f"  Midpoint: {state.midpoint:.15f}")
    print(f"  √2 actual: {math.sqrt(2):.15f}")
    print(f"  Error: {abs(state.midpoint - math.sqrt(2)):.2e}")
    print(f"  Invariant verified: {state.verify()}")

    # 2. Modulus composition
    print("\n--- Modulus Composition: Error Propagation ---")
    f_mcf = ModulusContinuousFunction(
        f=lambda x: x**2,
        mu=lambda n: n + 2,  # Lipschitz constant ~ 4 on [0,2]
        a=0, b=2
    )
    g_mcf = ModulusContinuousFunction(
        f=lambda x: math.sin(x),
        mu=lambda n: n,  # sin is 1-Lipschitz
        a=0, b=4
    )
    composed_mu = compose_modulus(f_mcf, g_mcf)
    print(f"f(x) = x², μ_f(n) = n+2")
    print(f"g(x) = sin(x), μ_g(n) = n")
    print(f"μ_{{g∘f}}(n) = μ_f(μ_g(n)) = μ_f(n) = n+2")
    for n in [5, 10, 15, 20]:
        print(f"  μ_{{g∘f}}({n}) = {composed_mu(n)}")

    # 3. Effective Cauchy completion
    print("\n--- Effective Completion: Partial sums → e ---")
    def partial_exp(n: int) -> ComputableReal:
        val = sum(Fraction(1, math.factorial(k)) for k in range(n + 1))
        return ComputableReal.of_rat(val)

    ecs = EffectiveCauchySequence(seq=partial_exp, mod=lambda n: n + 5)
    limit = ecs.effective_limit()
    for n in [5, 10, 15]:
        approx = float(limit.approx_at(n))
        err = abs(approx - math.e)
        print(f"  Precision {n}: {approx:.15f} (error: {err:.2e})")
