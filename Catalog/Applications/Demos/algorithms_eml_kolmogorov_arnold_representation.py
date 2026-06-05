#!/usr/bin/env python3
"""
EML Spectral Algebra — Core Algorithms
=======================================

Type-hinted implementations of the EML-KA decomposition algorithms.
"""

from typing import List, Tuple, Callable, Optional
import math


# ── EML Chain Types ──────────────────────────────────────────────────

class EMLOp:
    """Base class for EML chain operations."""
    def eval(self, x: float) -> float:
        raise NotImplementedError

class ExpOp(EMLOp):
    def eval(self, x: float) -> float:
        return math.exp(x)
    def __repr__(self) -> str:
        return "exp"

class LogOp(EMLOp):
    def eval(self, x: float) -> float:
        return math.log(x)
    def __repr__(self) -> str:
        return "log"

class AffineOp(EMLOp):
    def __init__(self, a: float, b: float):
        self.a = a
        self.b = b
    def eval(self, x: float) -> float:
        return self.a * x + self.b
    def __repr__(self) -> str:
        return f"affine({self.a}, {self.b})"


EMLChain = List[EMLOp]


def eval_chain(chain: EMLChain, x: float) -> float:
    """Evaluate an EML chain at x. Head is outermost operation."""
    result = x
    for op in reversed(chain):
        result = op.eval(result)
    return result


def chain_depth(chain: EMLChain) -> int:
    """Count non-affine (transcendental) operations in a chain."""
    return sum(1 for op in chain if not isinstance(op, AffineOp))


# ── EML-KA Decomposition ────────────────────────────────────────────

class EMLKADecomp:
    """EML-KA decomposition for bivariate functions with Q terms.

    f(x, y) ≈ Σ_q Φ_q(φ₁_q(x) + φ₂_q(y))
    """

    def __init__(self, phi1: List[EMLChain], phi2: List[EMLChain],
                 Phi: List[EMLChain]):
        assert len(phi1) == len(phi2) == len(Phi)
        self.phi1 = phi1
        self.phi2 = phi2
        self.Phi = Phi
        self.Q = len(phi1)

    def eval(self, x: float, y: float) -> float:
        """Evaluate the decomposition at (x, y)."""
        total = 0.0
        for q in range(self.Q):
            inner = eval_chain(self.phi1[q], x) + eval_chain(self.phi2[q], y)
            total += eval_chain(self.Phi[q], inner)
        return total

    def max_depth(self) -> int:
        """Maximum total depth across all terms."""
        return max(
            chain_depth(self.phi1[q]) + chain_depth(self.phi2[q]) + chain_depth(self.Phi[q])
            for q in range(self.Q)
        )

    def complexity(self) -> int:
        """The number of terms Q."""
        return self.Q

    @staticmethod
    def multiplication() -> 'EMLKADecomp':
        """1-term decomposition for x · y."""
        return EMLKADecomp(
            phi1=[[LogOp()]],
            phi2=[[LogOp()]],
            Phi=[[ExpOp()]]
        )

    @staticmethod
    def division() -> 'EMLKADecomp':
        """1-term decomposition for x / y."""
        return EMLKADecomp(
            phi1=[[LogOp()]],
            phi2=[[AffineOp(-1, 0), LogOp()]],
            Phi=[[ExpOp()]]
        )

    @staticmethod
    def monomial(a: int, b: int) -> 'EMLKADecomp':
        """1-term decomposition for x^a · y^b."""
        return EMLKADecomp(
            phi1=[[AffineOp(a, 0), LogOp()]],
            phi2=[[AffineOp(b, 0), LogOp()]],
            Phi=[[ExpOp()]]
        )

    @staticmethod
    def weighted_monomial(c: float, a: int, b: int) -> 'EMLKADecomp':
        """1-term decomposition for c · x^a · y^b."""
        return EMLKADecomp(
            phi1=[[AffineOp(a, 0), LogOp()]],
            phi2=[[AffineOp(b, 0), LogOp()]],
            Phi=[[AffineOp(c, 0), ExpOp()]]
        )

    @staticmethod
    def geometric_mean() -> 'EMLKADecomp':
        """1-term decomposition for √(xy)."""
        return EMLKADecomp(
            phi1=[[AffineOp(0.5, 0), LogOp()]],
            phi2=[[AffineOp(0.5, 0), LogOp()]],
            Phi=[[ExpOp()]]
        )

    @staticmethod
    def addition() -> 'EMLKADecomp':
        """2-term decomposition for x + y."""
        return EMLKADecomp(
            phi1=[[], [AffineOp(0, 0)]],
            phi2=[[AffineOp(0, 0)], []],
            Phi=[[], []]
        )

    @staticmethod
    def polynomial(coeffs: List[float], exps_a: List[int],
                   exps_b: List[int]) -> 'EMLKADecomp':
        """M-term decomposition for Σ cᵢ · x^{aᵢ} · y^{bᵢ}."""
        M = len(coeffs)
        assert len(exps_a) == M and len(exps_b) == M
        phi1 = [[AffineOp(exps_a[i], 0), LogOp()] for i in range(M)]
        phi2 = [[AffineOp(exps_b[i], 0), LogOp()] for i in range(M)]
        Phi = [[AffineOp(coeffs[i], 0), ExpOp()] for i in range(M)]
        return EMLKADecomp(phi1=phi1, phi2=phi2, Phi=Phi)

    def scale(self, alpha: float) -> 'EMLKADecomp':
        """Scale decomposition by α: f → α·f."""
        new_Phi = [[AffineOp(alpha, 0)] + chain for chain in self.Phi]
        return EMLKADecomp(self.phi1, self.phi2, new_Phi)

    def add(self, other: 'EMLKADecomp') -> 'EMLKADecomp':
        """Add two decompositions: f + g."""
        return EMLKADecomp(
            phi1=self.phi1 + other.phi1,
            phi2=self.phi2 + other.phi2,
            Phi=self.Phi + other.Phi
        )


# ── n-Variable EML-KA ───────────────────────────────────────────────

class EMLKADecompN:
    """n-variable EML-KA decomposition with Q terms.

    f(x₁,...,xₙ) = Σ_q Φ_q(Σᵢ φ_{q,i}(xᵢ))
    """

    def __init__(self, n: int, phi: List[List[EMLChain]], Phi: List[EMLChain]):
        self.n = n
        self.phi = phi  # phi[q][i] is the chain for term q, variable i
        self.Phi = Phi
        self.Q = len(Phi)

    def eval(self, xs: List[float]) -> float:
        total = 0.0
        for q in range(self.Q):
            inner = sum(eval_chain(self.phi[q][i], xs[i]) for i in range(self.n))
            total += eval_chain(self.Phi[q], inner)
        return total

    @staticmethod
    def monomial(exps: List[int]) -> 'EMLKADecompN':
        """1-term decomposition for ∏ xᵢ^{aᵢ}."""
        n = len(exps)
        phi = [[[AffineOp(exps[i], 0), LogOp()] for i in range(n)]]
        Phi = [[ExpOp()]]
        return EMLKADecompN(n=n, phi=phi, Phi=Phi)


# ── Spectral Grade Analysis ─────────────────────────────────────────

def analyze_spectral_grade(name: str, decomp: EMLKADecomp,
                           test_fn: Callable[[float, float], float],
                           test_points: List[Tuple[float, float]]) -> dict:
    """Analyze the spectral grade of a function given its EML-KA decomposition."""
    errors = []
    for x, y in test_points:
        try:
            result = decomp.eval(x, y)
            exact = test_fn(x, y)
            errors.append(abs(result - exact))
        except (ValueError, OverflowError):
            errors.append(float('inf'))

    return {
        'name': name,
        'complexity': decomp.complexity(),
        'max_depth': decomp.max_depth(),
        'max_error': max(errors),
        'mean_error': sum(errors) / len(errors),
    }


# ── Fenchel-Young Bound ─────────────────────────────────────────────

def fenchel_young_gap(x: float, s: float) -> float:
    """Compute the Fenchel-Young gap: exp(x) + s·log(s) - s - x·s ≥ 0."""
    return math.exp(x) + s * math.log(s) - s - x * s


# ── LogSumExp ────────────────────────────────────────────────────────

def log_sum_exp(x: float, y: float) -> float:
    """Numerically stable LogSumExp."""
    m = max(x, y)
    return m + math.log(math.exp(x - m) + math.exp(y - m))


if __name__ == "__main__":
    # Quick self-test
    mul_d = EMLKADecomp.multiplication()
    assert abs(mul_d.eval(2, 3) - 6.0) < 1e-10

    div_d = EMLKADecomp.division()
    assert abs(div_d.eval(6, 3) - 2.0) < 1e-10

    mono_d = EMLKADecomp.monomial(2, 3)
    assert abs(mono_d.eval(2, 3) - 108.0) < 1e-10

    gm_d = EMLKADecomp.geometric_mean()
    assert abs(gm_d.eval(4, 9) - 6.0) < 1e-10

    poly_d = EMLKADecomp.polynomial([3, 2, -1], [2, 1, 1], [1, 2, 1])
    assert abs(poly_d.eval(2, 3) - (3*4*3 + 2*2*9 - 2*3)) < 1e-8

    print("All self-tests passed.")
