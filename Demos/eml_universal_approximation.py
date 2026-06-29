"""
Numerical demonstrations for:

    Density Meets Incompressibility:
    The EML Complexity Price of Universal Approximation

This self-contained script illustrates the key results about the constant-free
EML (Exponential-Multiplicative-Logarithmic) term algebra:

  * the explicit generators  expBasis(k)  computing  x |-> e^{(k+1)x}
    with exact size  2k + 2  (Theorems expBasis_eval, expBasis_size);
  * the linear complexity upper bound  K(e^{(k+1)x}) <= 2k + 2
    (Theorem K_expBasis_le);
  * injectivity of the generator family (Theorem generators_injective);
  * uniform density of finite linear combinations of exponential monomials
    in C([a,b])  (Theorem exp_monomials_span_dense) via least-squares fits;
  * the "escape from finite islands" phenomenon
    (Theorem finitely_many_generators_per_budget).

No third-party libraries are required; everything is inlined with type hints.
"""

from __future__ import annotations

from dataclasses import dataclass
from math import exp, log, cos, pi
from typing import Callable, List, Tuple


# ---------------------------------------------------------------------------
# 1. A minimal constant-free EML term algebra (ETerm)
# ---------------------------------------------------------------------------

@dataclass(frozen=True)
class ETerm:
    """A constant-free EML term.

    kind is one of: 'var', 'add', 'mul', 'exp', 'log'.
    Binary nodes ('add', 'mul') use .left and .right; unary nodes
    ('exp', 'log') use .left only; 'var' is a leaf.
    """
    kind: str
    left: "ETerm | None" = None
    right: "ETerm | None" = None


def var() -> ETerm:
    return ETerm("var")


def add(s: ETerm, t: ETerm) -> ETerm:
    return ETerm("add", s, t)


def mul(s: ETerm, t: ETerm) -> ETerm:
    return ETerm("mul", s, t)


def exp_of(t: ETerm) -> ETerm:
    return ETerm("exp", t)


def log_of(t: ETerm) -> ETerm:
    return ETerm("log", t)


def eval_term(t: ETerm, x: float) -> float:
    """Semantics: eval(t)(x). Mirrors the Lean ETerm.eval."""
    if t.kind == "var":
        return x
    if t.kind == "add":
        return eval_term(t.left, x) + eval_term(t.right, x)
    if t.kind == "mul":
        return eval_term(t.left, x) * eval_term(t.right, x)
    if t.kind == "exp":
        return exp(eval_term(t.left, x))
    if t.kind == "log":
        return log(eval_term(t.left, x))
    raise ValueError(f"unknown term kind: {t.kind}")


def size(t: ETerm) -> int:
    """Size: leaves and operators. Mirrors the Lean ETerm.size."""
    if t.kind == "var":
        return 1
    if t.kind in ("add", "mul"):
        return size(t.left) + size(t.right) + 1
    if t.kind in ("exp", "log"):
        return size(t.left) + 1
    raise ValueError(f"unknown term kind: {t.kind}")


def depth(t: ETerm) -> int:
    """Depth: nesting height of operators."""
    if t.kind == "var":
        return 0
    if t.kind in ("add", "mul"):
        return max(depth(t.left), depth(t.right)) + 1
    if t.kind in ("exp", "log"):
        return depth(t.left) + 1
    raise ValueError(f"unknown term kind: {t.kind}")


# ---------------------------------------------------------------------------
# 2. The explicit generators repAdd and expBasis
# ---------------------------------------------------------------------------

def rep_add(k: int) -> ETerm:
    """repAdd(k) = var + var + ... + var  (k+1 copies).  eval = (k+1)*x."""
    t = var()
    for _ in range(k):
        t = add(var(), t)
    return t


def exp_basis(k: int) -> ETerm:
    """expBasis(k) = exp(repAdd(k)).  eval = e^{(k+1)x},  size = 2k+2."""
    return exp_of(rep_add(k))


def K_upper_bound(k: int) -> int:
    """The proven upper bound K(e^{(k+1)x}) <= 2k+2 = size(expBasis(k))."""
    return 2 * k + 2


# ---------------------------------------------------------------------------
# 3. Verifying the exact eval and size identities numerically
# ---------------------------------------------------------------------------

def verify_eval_and_size(k_max: int = 8) -> None:
    print("=" * 70)
    print("Generators: eval = e^{(k+1)x}, size = 2k+2, K <= 2k+2")
    print("=" * 70)
    print(f"{'k':>3} | {'size':>5} | {'2k+2':>5} | {'eval(0.7)':>12} | "
          f"{'e^{(k+1)0.7}':>14} | match")
    for k in range(k_max + 1):
        t = exp_basis(k)
        s = size(t)
        x = 0.7
        got = eval_term(t, x)
        want = exp((k + 1) * x)
        ok = abs(got - want) < 1e-9 and s == 2 * k + 2 == K_upper_bound(k)
        print(f"{k:>3} | {s:>5} | {2 * k + 2:>5} | {got:>12.6f} | "
              f"{want:>14.6f} | {ok}")
    print()


# ---------------------------------------------------------------------------
# 4. Injectivity of the generator family
# ---------------------------------------------------------------------------

def verify_injectivity(k_max: int = 6) -> None:
    print("=" * 70)
    print("Injectivity: distinct k give distinct functions e^{(k+1)x}")
    print("=" * 70)
    sample_xs = [-1.0, 0.3, 1.0, 2.0]
    sigs: List[Tuple[float, ...]] = []
    for k in range(k_max + 1):
        sig = tuple(round(exp((k + 1) * x), 9) for x in sample_xs)
        sigs.append(sig)
    distinct = len(set(sigs)) == len(sigs)
    print(f"generators k=0..{k_max}: all distinct = {distinct}")
    # Demonstrate the proof idea: evaluate at x = 1, recover k+1 via log.
    print("recovering frequency by log of value at x=1:")
    for k in range(k_max + 1):
        v = exp((k + 1) * 1.0)
        recovered = round(log(v)) - 1
        print(f"  k={k}: e^{{(k+1)}} = {v:>12.4f} -> log -> k = {recovered}")
    print()


# ---------------------------------------------------------------------------
# 5. Density: least-squares approximation by exponential monomials
# ---------------------------------------------------------------------------

def design_matrix(xs: List[float], k_max: int) -> List[List[float]]:
    """Rows are [e^{0 x}, e^{1 x}, ..., e^{k_max x}] for each sample x."""
    return [[exp(k * x) for k in range(k_max + 1)] for x in xs]


def solve_normal_equations(A: List[List[float]],
                           y: List[float]) -> List[float]:
    """Least squares via normal equations (A^T A) c = A^T y, Gaussian elim."""
    n = len(A[0])
    # Build A^T A (n x n) and A^T y (n).
    ata = [[sum(A[r][i] * A[r][j] for r in range(len(A)))
            for j in range(n)] for i in range(n)]
    aty = [sum(A[r][i] * y[r] for r in range(len(A))) for i in range(n)]
    # Gaussian elimination with partial pivoting.
    M = [row[:] + [aty[i]] for i, row in enumerate(ata)]
    for col in range(n):
        piv = max(range(col, n), key=lambda r: abs(M[r][col]))
        M[col], M[piv] = M[piv], M[col]
        pivot = M[col][col]
        if abs(pivot) < 1e-15:
            continue
        for r in range(n):
            if r != col:
                factor = M[r][col] / pivot
                for c in range(col, n + 1):
                    M[r][c] -= factor * M[col][c]
    return [M[i][n] / M[i][i] if abs(M[i][i]) > 1e-15 else 0.0
            for i in range(n)]


def approximate(target: Callable[[float], float],
                a: float, b: float, k_max: int,
                n_samples: int = 200) -> Tuple[List[float], float]:
    """Fit sum_k c_k e^{k x} to target on [a,b]; return coeffs and max error."""
    xs = [a + (b - a) * i / (n_samples - 1) for i in range(n_samples)]
    ys = [target(x) for x in xs]
    A = design_matrix(xs, k_max)
    coeffs = solve_normal_equations(A, ys)
    max_err = max(abs(sum(coeffs[k] * exp(k * x) for k in range(k_max + 1))
                      - target(x)) for x in xs)
    return coeffs, max_err


def verify_density(a: float = 0.0, b: float = 1.0) -> None:
    print("=" * 70)
    print("Density: uniform approximation by exponential monomials on [a,b]")
    print("=" * 70)
    targets: List[Tuple[str, Callable[[float], float]]] = [
        ("cos(3 pi x)", lambda x: cos(3 * pi * x)),
        ("|x - 0.5|", lambda x: abs(x - 0.5)),
        ("x^2 - x", lambda x: x * x - x),
    ]
    for name, f in targets:
        print(f"target f(x) = {name} on [{a},{b}]")
        print(f"  {'k_max':>6} | {'#monomials':>10} | {'max error':>12}")
        for k_max in (2, 4, 6, 8, 10):
            _, err = approximate(f, a, b, k_max)
            print(f"  {k_max:>6} | {k_max + 1:>10} | {err:>12.3e}")
        print()


# ---------------------------------------------------------------------------
# 6. Escape from finite islands
# ---------------------------------------------------------------------------

def verify_escape(n_max: int = 12) -> None:
    print("=" * 70)
    print("Escape from finite islands: #generators with size <= n is finite")
    print("=" * 70)
    print(f"{'budget n':>9} | {'generators k with 2k+2 <= n':>30} | count")
    for n in range(2, n_max + 1, 2):
        ks = [k for k in range(0, n) if K_upper_bound(k) <= n]
        shown = ", ".join(str(k) for k in ks) if ks else "(none)"
        print(f"{n:>9} | {shown:>30} | {len(ks)}")
    print("\nFor every fixed budget n only finitely many generators fit,")
    print("yet the family k = 0, 1, 2, ... is infinite: it escapes every")
    print("finite complexity island, so sup_k K(e^{(k+1)x}) = infinity.\n")


# ---------------------------------------------------------------------------
# 7. The missing constant boundary
# ---------------------------------------------------------------------------

def discuss_missing_constant() -> None:
    print("=" * 70)
    print("Boundary: the constant 1 = e^{0 x} is the unique missing generator")
    print("=" * 70)
    print("expBasis(k) computes e^{(k+1)x}, beginning at e^{x} (k=0).")
    print("The density family uses e^{k x} from k=0, i.e. e^{0 x} = 1.")
    print("No constant-free ETerm evaluates to the constant 1, because every")
    print("term propagates the input x through total operations. Adding a")
    print("single leaf 'one' (eval = 1) would close the one-object gap.\n")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> None:
    verify_eval_and_size()
    verify_injectivity()
    verify_density()
    verify_escape()
    discuss_missing_constant()


if __name__ == "__main__":
    main()
