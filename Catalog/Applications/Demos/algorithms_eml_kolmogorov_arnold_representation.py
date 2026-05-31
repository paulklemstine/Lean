"""
EML-KA (Exponential-Logarithmic Kolmogorov-Arnold) Decomposition Algorithms

Type-hinted implementations of EML chain evaluation, KA decomposition,
and fitting algorithms.
"""

from typing import List, Tuple, Callable, Optional
from dataclasses import dataclass
from enum import Enum
import math


class OpType(Enum):
    EXP = "exp"
    LOG = "log"
    AFFINE = "affine"


@dataclass
class EMLChainOp:
    """A single operation in an EML chain."""
    op_type: OpType
    a: float = 0.0  # affine coefficient
    b: float = 0.0  # affine offset

    def eval(self, x: float) -> float:
        if self.op_type == OpType.EXP:
            return math.exp(min(x, 500))  # clamp to avoid overflow
        elif self.op_type == OpType.LOG:
            return math.log(max(x, 1e-300))
        else:  # AFFINE
            return self.a * x + self.b

    def __repr__(self) -> str:
        if self.op_type == OpType.EXP:
            return "exp"
        elif self.op_type == OpType.LOG:
            return "log"
        else:
            if self.b == 0:
                return f"({self.a}·x)"
            return f"({self.a}·x + {self.b})"


@dataclass
class EMLChain:
    """A finite composition of EML operations."""
    ops: List[EMLChainOp]

    def eval(self, x: float) -> float:
        """Evaluate the chain at x. Operations are applied right-to-left."""
        result = x
        for op in reversed(self.ops):
            result = op.eval(result)
        return result

    @property
    def depth(self) -> int:
        """Count non-affine operations."""
        return sum(1 for op in self.ops if op.op_type != OpType.AFFINE)

    def __repr__(self) -> str:
        return " ∘ ".join(str(op) for op in self.ops)


@dataclass
class EMLKADecomp:
    """EML Kolmogorov-Arnold decomposition with Q terms."""
    phi1: List[EMLChain]  # inner chains for variable 1
    phi2: List[EMLChain]  # inner chains for variable 2
    Phi: List[EMLChain]   # outer chains

    @property
    def Q(self) -> int:
        return len(self.phi1)

    def eval(self, x: float, y: float) -> float:
        """Evaluate the decomposition at (x, y)."""
        result = 0.0
        for q in range(self.Q):
            u = self.phi1[q].eval(x)
            v = self.phi2[q].eval(y)
            result += self.Phi[q].eval(u + v)
        return result

    def max_depth(self) -> int:
        """Maximum depth across all chains."""
        return max(
            self.phi1[q].depth + self.phi2[q].depth + self.Phi[q].depth
            for q in range(self.Q)
        )

    def represents(self, f: Callable[[float, float], float],
                   points: List[Tuple[float, float]],
                   tol: float = 1e-10) -> bool:
        """Check if decomposition represents f at given points."""
        return all(
            abs(self.eval(x, y) - f(x, y)) < tol
            for x, y in points
        )


# ============================================================
# Standard EML-KA Decompositions
# ============================================================

def scaled_log_chain(a: float) -> EMLChain:
    """Chain for x ↦ a · log(x)."""
    return EMLChain([
        EMLChainOp(OpType.AFFINE, a, 0),
        EMLChainOp(OpType.LOG),
    ])


def exp_chain() -> EMLChain:
    """Chain for x ↦ exp(x)."""
    return EMLChain([EMLChainOp(OpType.EXP)])


def log_chain() -> EMLChain:
    """Chain for x ↦ log(x)."""
    return EMLChain([EMLChainOp(OpType.LOG)])


def affine_chain(a: float, b: float) -> EMLChain:
    """Chain for x ↦ a*x + b."""
    return EMLChain([EMLChainOp(OpType.AFFINE, a, b)])


def mul_emlka() -> EMLKADecomp:
    """1-term EML-KA decomposition for multiplication.
    x * y = exp(log(x) + log(y)) for x, y > 0.
    """
    return EMLKADecomp(
        phi1=[log_chain()],
        phi2=[log_chain()],
        Phi=[exp_chain()],
    )


def div_emlka() -> EMLKADecomp:
    """1-term EML-KA decomposition for division.
    x / y = exp(log(x) + (-log(y))) for x, y > 0.
    """
    return EMLKADecomp(
        phi1=[log_chain()],
        phi2=[EMLChain([
            EMLChainOp(OpType.AFFINE, -1, 0),
            EMLChainOp(OpType.LOG),
        ])],
        Phi=[exp_chain()],
    )


def monomial_emlka(a: int, b: int) -> EMLKADecomp:
    """1-term EML-KA decomposition for x^a * y^b.
    x^a * y^b = exp(a*log(x) + b*log(y)) for x, y > 0.
    """
    return EMLKADecomp(
        phi1=[scaled_log_chain(a)],
        phi2=[scaled_log_chain(b)],
        Phi=[exp_chain()],
    )


def polynomial_emlka(
    coeffs: List[float],
    exps_a: List[int],
    exps_b: List[int],
) -> EMLKADecomp:
    """M-term EML-KA decomposition for Σ c_i * x^a_i * y^b_i.

    Args:
        coeffs: coefficients c_i
        exps_a: exponents a_i for x
        exps_b: exponents b_i for y

    Returns:
        EML-KA decomposition with len(coeffs) terms.
    """
    M = len(coeffs)
    assert len(exps_a) == M and len(exps_b) == M

    phi1 = [scaled_log_chain(exps_a[i]) for i in range(M)]
    phi2 = [scaled_log_chain(exps_b[i]) for i in range(M)]
    Phi = [
        EMLChain([
            EMLChainOp(OpType.AFFINE, coeffs[i], 0),
            EMLChainOp(OpType.EXP),
        ])
        for i in range(M)
    ]
    return EMLKADecomp(phi1=phi1, phi2=phi2, Phi=Phi)


# ============================================================
# Fitting Algorithm
# ============================================================

def fit_emlka(
    f: Callable[[float, float], float],
    x_range: Tuple[float, float],
    y_range: Tuple[float, float],
    Q: int = 5,
    n_grid: int = 20,
    n_iter: int = 1000,
    lr: float = 0.01,
) -> Tuple[EMLKADecomp, float]:
    """Fit an EML-KA decomposition to a target function using gradient-free optimization.

    Uses random search with local refinement.

    Args:
        f: Target function
        x_range: (x_min, x_max) for the domain
        y_range: (y_min, y_max) for the domain
        Q: Number of KA terms
        n_grid: Grid points per dimension for evaluation
        n_iter: Number of optimization iterations
        lr: Learning rate for local refinement

    Returns:
        (best_decomp, best_error): Best decomposition found and its max error.
    """
    import random

    # Create evaluation grid
    xs = [x_range[0] + (x_range[1] - x_range[0]) * i / (n_grid - 1)
          for i in range(n_grid)]
    ys = [y_range[0] + (y_range[1] - y_range[0]) * i / (n_grid - 1)
          for i in range(n_grid)]
    targets = {(x, y): f(x, y) for x in xs for y in ys}

    best_error = float('inf')
    best_params: Optional[List[float]] = None

    # Each term has: a1, b1 (affine for phi1), a2, b2 (affine for phi2),
    #                a3, b3 (affine for Phi)
    # phi_i = affine(a_i, b_i) ∘ log
    # Phi = affine(a3, b3) ∘ exp
    n_params = Q * 6

    def params_to_decomp(params: List[float]) -> EMLKADecomp:
        phi1, phi2, Phi_list = [], [], []
        for q in range(Q):
            base = q * 6
            a1, b1 = params[base], params[base + 1]
            a2, b2 = params[base + 2], params[base + 3]
            a3, b3 = params[base + 4], params[base + 5]
            phi1.append(EMLChain([
                EMLChainOp(OpType.AFFINE, a1, b1),
                EMLChainOp(OpType.LOG),
            ]))
            phi2.append(EMLChain([
                EMLChainOp(OpType.AFFINE, a2, b2),
                EMLChainOp(OpType.LOG),
            ]))
            Phi_list.append(EMLChain([
                EMLChainOp(OpType.AFFINE, a3, b3),
                EMLChainOp(OpType.EXP),
            ]))
        return EMLKADecomp(phi1=phi1, phi2=phi2, Phi=Phi_list)

    def compute_error(params: List[float]) -> float:
        try:
            d = params_to_decomp(params)
            return max(abs(d.eval(x, y) - t) for (x, y), t in targets.items())
        except (OverflowError, ValueError):
            return float('inf')

    # Random search
    for _ in range(n_iter):
        params = [random.gauss(0, 1) for _ in range(n_params)]
        error = compute_error(params)
        if error < best_error:
            best_error = error
            best_params = params[:]

    # Local refinement
    if best_params is not None:
        for _ in range(n_iter):
            idx = random.randint(0, n_params - 1)
            delta = random.gauss(0, lr)
            best_params[idx] += delta
            error = compute_error(best_params)
            if error < best_error:
                best_error = error
            else:
                best_params[idx] -= delta

    if best_params is None:
        raise ValueError("Optimization failed to find any valid decomposition")

    return params_to_decomp(best_params), best_error


# ============================================================
# Verification Utilities
# ============================================================

def verify_monomial_decomp(a: int, b: int,
                           test_points: Optional[List[Tuple[float, float]]] = None,
                           ) -> Tuple[bool, float]:
    """Verify the monomial EML-KA decomposition for x^a * y^b.

    Returns (passed, max_error).
    """
    if test_points is None:
        test_points = [
            (0.5, 0.5), (1.0, 1.0), (1.5, 2.0), (0.1, 10.0),
            (3.0, 0.3), (2.0, 2.0), (0.01, 100.0),
        ]

    d = monomial_emlka(a, b)
    max_error = 0.0
    for x, y in test_points:
        expected = x**a * y**b
        actual = d.eval(x, y)
        error = abs(actual - expected) / max(abs(expected), 1e-15)
        max_error = max(max_error, error)

    return max_error < 1e-10, max_error


def am_gm_check(x: float, y: float) -> Tuple[float, float, bool]:
    """Check AM-GM: exp((log x + log y)/2) ≤ (x + y)/2.

    Returns (geometric_mean, arithmetic_mean, inequality_holds).
    """
    assert x > 0 and y > 0
    gm = math.exp((math.log(x) + math.log(y)) / 2)
    am = (x + y) / 2
    return gm, am, gm <= am + 1e-15


def fenchel_young_check(x: float, s: float) -> Tuple[float, float, bool]:
    """Check Fenchel-Young: x*s ≤ exp(x) + s*log(s) - s.

    Returns (lhs, rhs, inequality_holds).
    """
    assert s > 0
    lhs = x * s
    rhs = math.exp(min(x, 500)) + s * math.log(s) - s
    return lhs, rhs, lhs <= rhs + 1e-15


if __name__ == "__main__":
    print("=== EML-KA Algorithms Module ===")
    print()

    # Verify monomial decompositions
    for a, b in [(1, 1), (2, 3), (5, 0), (0, 4), (10, 10)]:
        passed, err = verify_monomial_decomp(a, b)
        status = "✓" if passed else "✗"
        print(f"  {status} x^{a} * y^{b}: max relative error = {err:.2e}")

    print()

    # Check AM-GM
    for x, y in [(1.0, 4.0), (2.0, 8.0), (0.01, 100.0)]:
        gm, am, ok = am_gm_check(x, y)
        status = "✓" if ok else "✗"
        print(f"  {status} AM-GM({x}, {y}): GM={gm:.6f}, AM={am:.6f}")

    print()

    # Check Fenchel-Young
    for x, s in [(0.0, 1.0), (1.0, 1.0), (2.0, 0.5), (-1.0, 3.0)]:
        lhs, rhs, ok = fenchel_young_check(x, s)
        status = "✓" if ok else "✗"
        print(f"  {status} FY(x={x}, s={s}): {lhs:.6f} ≤ {rhs:.6f}")
