#!/usr/bin/env python3
"""
applications.py — Real-World Applications of the Tensor-Sorted Rewrite System

Demonstrates the practical impact of certified tensor rewriting for:
  1. Finite Element Method — stiffness matrix assembly and energy computation
  2. Quadratic Optimization — certified preprocessing for QP solvers
  3. Network Science — graph Laplacian spectral analysis
  4. Signal Processing — quadratic filter energy
"""

import numpy as np
from algorithms import (
    ScalVar, ScalAdd, ScalMul, Dot,
    VecVar, VecAdd, SmulVec, MulVec,
    MatVar, MatAdd, SmulMat,
    evaluate, normalize, count_ops, total_cost,
    compute_energy, verify_energy_expansion, verify_symmetric_specialization
)


# ============================================================
# Application 1: Finite Element Method
# ============================================================

def fem_application():
    """
    Finite Element Method: Assembly and simplification of stiffness
    energy expressions for a 1D bar element.

    The element stiffness matrix for a bar with Young's modulus E,
    cross-section area A, and length L is:
        K = (EA/L) * [[1, -1], [-1, 1]]

    For two elements sharing a node, the assembled system involves
    matrix addition K_total = K1 + K2.
    """
    print("=" * 60)
    print("APPLICATION 1: Finite Element Stiffness Energy")
    print("=" * 60)

    # Two-element bar
    E1, A1, L1 = 200e9, 0.01, 1.0  # Steel
    E2, A2, L2 = 70e9, 0.02, 0.5   # Aluminum

    k1 = E1 * A1 / L1
    k2 = E2 * A2 / L2

    # 3-DOF system (3 nodes)
    K1 = np.array([[k1, -k1, 0], [-k1, k1, 0], [0, 0, 0]])
    K2 = np.array([[0, 0, 0], [0, k2, -k2], [0, -k2, k2]])

    # Displacement vector
    u = np.array([0.0, 0.001, 0.002])  # meters

    # Build symbolic expression: ⟨u, (K1 + K2) · u⟩
    expr = Dot(VecVar("u"), MulVec(MatAdd(MatVar("K1"), MatVar("K2")), VecVar("u")))
    env = {"u": u, "K1": K1, "K2": K2}

    # Normalize
    expr_norm = normalize(expr)
    val_orig = evaluate(expr, env)
    val_norm = evaluate(expr_norm, env)

    print(f"  Element 1: EA/L = {k1:.0f} N/m")
    print(f"  Element 2: EA/L = {k2:.0f} N/m")
    print(f"  Displacement: {u}")
    print(f"\n  Original expression:  {expr}")
    print(f"  Normalized:           {expr_norm}")
    print(f"  Strain energy (orig): {val_orig:.6f} J")
    print(f"  Strain energy (norm): {val_norm:.6f} J")
    print(f"  Semantic preservation: {np.isclose(val_orig, val_norm)}")
    print(f"  Ops before: {total_cost(expr)}, after: {total_cost(expr_norm)}")
    print()


# ============================================================
# Application 2: Quadratic Programming Preprocessing
# ============================================================

def qp_preprocessing():
    """
    Quadratic programming: certified simplification of the objective
    function (1/2) x^T Q x + c^T x before passing to a QP solver.

    We demonstrate that distributing matrix-vector products and
    collecting scalar-dot products preserves the objective value.
    """
    print("=" * 60)
    print("APPLICATION 2: Quadratic Programming Preprocessing")
    print("=" * 60)

    n = 4
    # Random positive definite Q
    M = np.random.randn(n, n)
    Q = M.T @ M + np.eye(n)
    c = np.random.randn(n)
    x = np.random.randn(n)

    # Build expression: (1/2) * ⟨x, Q·x⟩ + ⟨c, x⟩
    # Using our term language:
    half = ScalVar("half")
    expr = ScalAdd(
        ScalMul(half, Dot(VecVar("x"), MulVec(MatVar("Q"), VecVar("x")))),
        Dot(VecVar("c"), VecVar("x"))
    )

    # Now test with perturbation: f(x + δ)
    delta = 0.01 * np.random.randn(n)
    expr_perturbed = ScalAdd(
        ScalMul(half, Dot(
            VecAdd(VecVar("x"), VecVar("d")),
            MulVec(MatVar("Q"), VecAdd(VecVar("x"), VecVar("d")))
        )),
        Dot(VecVar("c"), VecAdd(VecVar("x"), VecVar("d")))
    )

    env = {"half": 0.5, "x": x, "d": delta, "Q": Q, "c": c}

    expr_norm = normalize(expr_perturbed)
    val_orig = evaluate(expr_perturbed, env)
    val_norm = evaluate(expr_norm, env)

    print(f"  Problem dimension: {n}")
    print(f"  Q is {n}×{n} positive definite")
    print(f"\n  Perturbed objective expression:")
    print(f"    Original:   {repr(expr_perturbed)[:80]}...")
    print(f"    Normalized: {repr(expr_norm)[:80]}...")
    print(f"\n  Value (original):   {val_orig:.10f}")
    print(f"  Value (normalized): {val_norm:.10f}")
    print(f"  Preserved: {np.isclose(val_orig, val_norm)}")

    # Verify energy expansion
    ok = verify_energy_expansion(Q, x, delta)
    print(f"\n  Energy expansion identity verified: {ok}")
    print()


# ============================================================
# Application 3: Graph Laplacian Spectral Energy
# ============================================================

def graph_laplacian_spectral():
    """
    Network science: compute and simplify graph Laplacian energies
    for signal smoothness analysis on graphs.

    The Laplacian energy E(L, f) = f^T L f measures the total
    variation of signal f across graph edges.
    """
    print("=" * 60)
    print("APPLICATION 3: Graph Laplacian Spectral Energy")
    print("=" * 60)

    # Petersen-like graph (10 nodes, regular)
    n = 6
    # Cycle graph + diagonal connections
    adj = np.zeros((n, n))
    for i in range(n):
        adj[i, (i+1) % n] = 1
        adj[(i+1) % n, i] = 1
    # Add some cross edges
    adj[0, 3] = adj[3, 0] = 1
    adj[1, 4] = adj[4, 1] = 1
    adj[2, 5] = adj[5, 2] = 1

    D = np.diag(adj.sum(axis=1))
    L = D - adj  # Laplacian

    # Two signals
    f1 = np.array([1, 0, -1, 1, 0, -1], dtype=float)  # High variation
    f2 = np.array([1, 1, 1, -1, -1, -1], dtype=float)  # Low variation

    # Build expression: ⟨f1+f2, L·(f1+f2)⟩
    expr = Dot(
        VecAdd(VecVar("f1"), VecVar("f2")),
        MulVec(MatVar("L"), VecAdd(VecVar("f1"), VecVar("f2")))
    )
    env = {"f1": f1, "f2": f2, "L": L}

    expr_norm = normalize(expr)
    val_orig = evaluate(expr, env)
    val_norm = evaluate(expr_norm, env)

    # Individual energies
    E1 = compute_energy(L, f1)
    E2 = compute_energy(L, f2)
    cross = float(f1 @ L @ f2 + f2 @ L @ f1)

    print(f"  Graph: {n}-node graph with {int(adj.sum()//2)} edges")
    print(f"  Laplacian L (symmetric): verified = {np.allclose(L, L.T)}")
    print(f"\n  Signal f1 (high variation): {f1}")
    print(f"  Signal f2 (low variation):  {f2}")
    print(f"\n  E(L, f1) = {E1:.4f}")
    print(f"  E(L, f2) = {E2:.4f}")
    print(f"  Cross terms = {cross:.4f}")
    print(f"  E(L, f1+f2) = {val_orig:.4f}")
    print(f"  Sum check: {E1} + {cross} + {E2} = {E1 + cross + E2:.4f}")
    print(f"  Match: {np.isclose(val_orig, E1 + cross + E2)}")
    print(f"\n  Original expression ops:   {total_cost(expr)}")
    print(f"  Normalized expression ops: {total_cost(expr_norm)}")
    print(f"  Semantic preservation: {np.isclose(val_orig, val_norm)}")

    # Symmetric specialization
    cross1 = float(f1 @ L @ f2)
    cross2 = float(f2 @ L @ f1)
    print(f"\n  Symmetric cross-term test:")
    print(f"    ⟨f1, L·f2⟩ = {cross1:.6f}")
    print(f"    ⟨f2, L·f1⟩ = {cross2:.6f}")
    print(f"    Equal: {np.isclose(cross1, cross2)}")
    print()


# ============================================================
# Application 4: Signal Processing — Quadratic Filter
# ============================================================

def signal_processing():
    """
    Signal processing: quadratic filter energy for a discrete signal
    passed through a linear filter represented as a matrix.
    """
    print("=" * 60)
    print("APPLICATION 4: Quadratic Filter Energy")
    print("=" * 60)

    n = 8
    # Low-pass filter matrix (averaging)
    H = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            if abs(i - j) <= 1:
                H[i, j] = 1.0 / 3.0

    # Signal
    t = np.linspace(0, 2*np.pi, n)
    signal = np.sin(t)
    noise = 0.3 * np.random.randn(n)

    # Build expression: ⟨signal+noise, H·(signal+noise)⟩
    expr = Dot(
        VecAdd(VecVar("s"), VecVar("n")),
        MulVec(MatVar("H"), VecAdd(VecVar("s"), VecVar("n")))
    )
    env = {"s": signal, "n": noise, "H": H}

    expr_norm = normalize(expr)
    val_orig = evaluate(expr, env)
    val_norm = evaluate(expr_norm, env)

    print(f"  Signal dimension: {n}")
    print(f"  Filter: 3-point moving average")
    print(f"\n  E(H, signal+noise) = {val_orig:.6f}")
    print(f"  E(H, signal)       = {compute_energy(H, signal):.6f}")
    print(f"  E(H, noise)        = {compute_energy(H, noise):.6f}")
    print(f"\n  Normalized value: {val_norm:.6f}")
    print(f"  Preservation: {np.isclose(val_orig, val_norm)}")

    # Energy expansion
    ok = verify_energy_expansion(H, signal, noise)
    print(f"  Energy expansion verified: {ok}")
    print()


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    np.random.seed(42)

    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Tensor-Sorted Rewrite System — Applications            ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    fem_application()
    qp_preprocessing()
    graph_laplacian_spectral()
    signal_processing()

    print("All applications demonstrated successfully.")


#!/usr/bin/env python3
"""
Tensor-Sorted Rewrite System — Interactive Demonstration

This demo generates random well-typed tensor expressions, normalizes them
using distributivity-oriented rewrite rules, evaluates both original and
normalized forms, and verifies that:
  1. Semantic values are preserved (soundness)
  2. Energy E(v,A) = v^T A v is invariant
  3. Operation counts decrease (or stay equal) after normalization

Physics-flavored examples include spring energy, graph Laplacian energy,
and quadratic penalty terms.
"""

import random
import numpy as np
from typing import Tuple, List, Any

# ============================================================
# Part 1: Abstract Syntax Tree for the Tensor Language
# ============================================================

class TensorTerm:
    """Base class for tensor terms."""
    pass

# --- Scalar sort ---
class ScalVar(TensorTerm):
    def __init__(self, name: str): self.name = name
    def __repr__(self): return self.name

class ScalAdd(TensorTerm):
    def __init__(self, a: TensorTerm, b: TensorTerm): self.a, self.b = a, b
    def __repr__(self): return f"({self.a} + {self.b})"

class ScalMul(TensorTerm):
    def __init__(self, a: TensorTerm, b: TensorTerm): self.a, self.b = a, b
    def __repr__(self): return f"({self.a} * {self.b})"

class Dot(TensorTerm):
    def __init__(self, v: TensorTerm, w: TensorTerm): self.v, self.w = v, w
    def __repr__(self): return f"⟨{self.v}, {self.w}⟩"

# --- Vector sort ---
class VecVar(TensorTerm):
    def __init__(self, name: str): self.name = name
    def __repr__(self): return self.name

class VecAdd(TensorTerm):
    def __init__(self, v: TensorTerm, w: TensorTerm): self.v, self.w = v, w
    def __repr__(self): return f"({self.v} + {self.w})"

class SmulVec(TensorTerm):
    def __init__(self, a: TensorTerm, v: TensorTerm): self.a, self.v = a, v
    def __repr__(self): return f"({self.a} • {self.v})"

class MulVec(TensorTerm):
    def __init__(self, A: TensorTerm, v: TensorTerm): self.A, self.v = A, v
    def __repr__(self): return f"({self.A} · {self.v})"

# --- Matrix sort ---
class MatVar(TensorTerm):
    def __init__(self, name: str): self.name = name
    def __repr__(self): return self.name

class MatAdd(TensorTerm):
    def __init__(self, A: TensorTerm, B: TensorTerm): self.A, self.B = A, B
    def __repr__(self): return f"({self.A} + {self.B})"

class SmulMat(TensorTerm):
    def __init__(self, a: TensorTerm, A: TensorTerm): self.a, self.A = a, A
    def __repr__(self): return f"({self.a} • {self.A})"


# ============================================================
# Part 2: Evaluation
# ============================================================

def evaluate(term: TensorTerm, env: dict) -> Any:
    """Evaluate a tensor term in a given environment."""
    if isinstance(term, ScalVar): return env[term.name]
    if isinstance(term, ScalAdd): return evaluate(term.a, env) + evaluate(term.b, env)
    if isinstance(term, ScalMul): return evaluate(term.a, env) * evaluate(term.b, env)
    if isinstance(term, Dot):
        v, w = evaluate(term.v, env), evaluate(term.w, env)
        return np.dot(v, w)
    if isinstance(term, VecVar): return env[term.name]
    if isinstance(term, VecAdd): return evaluate(term.v, env) + evaluate(term.w, env)
    if isinstance(term, SmulVec): return evaluate(term.a, env) * evaluate(term.v, env)
    if isinstance(term, MulVec): return evaluate(term.A, env) @ evaluate(term.v, env)
    if isinstance(term, MatVar): return env[term.name]
    if isinstance(term, MatAdd): return evaluate(term.A, env) + evaluate(term.B, env)
    if isinstance(term, SmulMat): return evaluate(term.a, env) * evaluate(term.A, env)
    raise ValueError(f"Unknown term type: {type(term)}")


# ============================================================
# Part 3: One-Step Normalization (normStep)
# ============================================================

def norm_step(term: TensorTerm) -> TensorTerm:
    """Apply one distributivity rewrite at the top level."""
    # mulVec A (vecAdd v w) → vecAdd (mulVec A v) (mulVec A w)
    if isinstance(term, MulVec) and isinstance(term.v, VecAdd):
        return VecAdd(MulVec(term.A, term.v.v), MulVec(term.A, term.v.w))
    # mulVec (matAdd A B) v → vecAdd (mulVec A v) (mulVec B v)
    if isinstance(term, MulVec) and isinstance(term.A, MatAdd):
        return VecAdd(MulVec(term.A.A, term.v), MulVec(term.A.B, term.v))
    # mulVec (smulMat a A) v → smulVec a (mulVec A v)
    if isinstance(term, MulVec) and isinstance(term.A, SmulMat):
        return SmulVec(term.A.a, MulVec(term.A.A, term.v))
    # smulVec a (vecAdd v w) → vecAdd (smulVec a v) (smulVec a w)
    if isinstance(term, SmulVec) and isinstance(term.v, VecAdd):
        return VecAdd(SmulVec(term.a, term.v.v), SmulVec(term.a, term.v.w))
    # smulMat a (matAdd A B) → matAdd (smulMat a A) (smulMat a B)
    if isinstance(term, SmulMat) and isinstance(term.A, MatAdd):
        return MatAdd(SmulMat(term.a, term.A.A), SmulMat(term.a, term.A.B))
    # dot (vecAdd v w) u → scalAdd (dot v u) (dot w u)
    if isinstance(term, Dot) and isinstance(term.v, VecAdd):
        return ScalAdd(Dot(term.v.v, term.w), Dot(term.v.w, term.w))
    # dot u (vecAdd v w) → scalAdd (dot u v) (dot u w)
    if isinstance(term, Dot) and isinstance(term.w, VecAdd):
        return ScalAdd(Dot(term.v, term.w.v), Dot(term.v, term.w.w))
    # dot (smulVec a v) w → scalMul a (dot v w)
    if isinstance(term, Dot) and isinstance(term.v, SmulVec):
        return ScalMul(term.v.a, Dot(term.v.v, term.w))
    return term


def normalize_recursive(term: TensorTerm, depth: int = 0) -> TensorTerm:
    """Bottom-up normalization: normalize children first, then top-level."""
    if depth > 50: return term
    # Normalize children
    if isinstance(term, ScalAdd):
        term = ScalAdd(normalize_recursive(term.a, depth+1), normalize_recursive(term.b, depth+1))
    elif isinstance(term, ScalMul):
        term = ScalMul(normalize_recursive(term.a, depth+1), normalize_recursive(term.b, depth+1))
    elif isinstance(term, Dot):
        term = Dot(normalize_recursive(term.v, depth+1), normalize_recursive(term.w, depth+1))
    elif isinstance(term, VecAdd):
        term = VecAdd(normalize_recursive(term.v, depth+1), normalize_recursive(term.w, depth+1))
    elif isinstance(term, SmulVec):
        term = SmulVec(normalize_recursive(term.a, depth+1), normalize_recursive(term.v, depth+1))
    elif isinstance(term, MulVec):
        term = MulVec(normalize_recursive(term.A, depth+1), normalize_recursive(term.v, depth+1))
    elif isinstance(term, MatAdd):
        term = MatAdd(normalize_recursive(term.A, depth+1), normalize_recursive(term.B, depth+1))
    elif isinstance(term, SmulMat):
        term = SmulMat(normalize_recursive(term.a, depth+1), normalize_recursive(term.A, depth+1))
    # Apply top-level normalization
    result = norm_step(term)
    if repr(result) != repr(term):
        return normalize_recursive(result, depth+1)
    return result


# ============================================================
# Part 4: Operation Count
# ============================================================

def op_count(term: TensorTerm) -> dict:
    """Count operations in a term."""
    counts = {"scalar_ops": 0, "matvec": 0, "dot": 0}
    if isinstance(term, (ScalAdd, ScalMul)):
        counts["scalar_ops"] += 1
        for c in [op_count(term.a), op_count(term.b)]:
            for k in counts: counts[k] += c[k]
    elif isinstance(term, Dot):
        counts["dot"] += 1
        for c in [op_count(term.v), op_count(term.w)]:
            for k in counts: counts[k] += c[k]
    elif isinstance(term, (VecAdd, SmulVec)):
        counts["scalar_ops"] += 1
        children = [term.v, term.w] if isinstance(term, VecAdd) else [term.a, term.v]
        for child in children:
            for c_key, c_val in op_count(child).items(): counts[c_key] += c_val
    elif isinstance(term, MulVec):
        counts["matvec"] += 1
        for c in [op_count(term.A), op_count(term.v)]:
            for k in counts: counts[k] += c[k]
    elif isinstance(term, (MatAdd, SmulMat)):
        counts["scalar_ops"] += 1
        children = [term.A, term.B] if isinstance(term, MatAdd) else [term.a, term.A]
        for child in children:
            for c_key, c_val in op_count(child).items(): counts[c_key] += c_val
    return counts


# ============================================================
# Part 5: Random Term Generation
# ============================================================

def random_scal_term(depth: int = 0, max_depth: int = 3) -> TensorTerm:
    if depth >= max_depth:
        return ScalVar(random.choice(["α", "β", "γ"]))
    r = random.random()
    if r < 0.3: return ScalVar(random.choice(["α", "β", "γ"]))
    if r < 0.5: return ScalAdd(random_scal_term(depth+1, max_depth), random_scal_term(depth+1, max_depth))
    if r < 0.7: return ScalMul(random_scal_term(depth+1, max_depth), random_scal_term(depth+1, max_depth))
    return Dot(random_vec_term(depth+1, max_depth), random_vec_term(depth+1, max_depth))

def random_vec_term(depth: int = 0, max_depth: int = 3) -> TensorTerm:
    if depth >= max_depth:
        return VecVar(random.choice(["v", "w", "x"]))
    r = random.random()
    if r < 0.3: return VecVar(random.choice(["v", "w", "x"]))
    if r < 0.5: return VecAdd(random_vec_term(depth+1, max_depth), random_vec_term(depth+1, max_depth))
    if r < 0.7: return SmulVec(random_scal_term(depth+1, max_depth), random_vec_term(depth+1, max_depth))
    return MulVec(random_mat_term(depth+1, max_depth), random_vec_term(depth+1, max_depth))

def random_mat_term(depth: int = 0, max_depth: int = 3) -> TensorTerm:
    if depth >= max_depth:
        return MatVar(random.choice(["A", "B", "K"]))
    r = random.random()
    if r < 0.4: return MatVar(random.choice(["A", "B", "K"]))
    if r < 0.7: return MatAdd(random_mat_term(depth+1, max_depth), random_mat_term(depth+1, max_depth))
    return SmulMat(random_scal_term(depth+1, max_depth), random_mat_term(depth+1, max_depth))


# ============================================================
# Part 6: Physics Examples
# ============================================================

def spring_energy_example(n: int = 3):
    """Spring energy: E = v^T K v where K is the stiffness matrix."""
    print("\n" + "="*60)
    print("PHYSICS EXAMPLE 1: Spring / Elastic Energy")
    print("="*60)
    K = np.array([[2, -1, 0], [-1, 2, -1], [0, -1, 2]], dtype=float)
    v = np.array([1.0, 2.0, 0.5])
    energy = v @ K @ v
    print(f"  Stiffness matrix K = \n{K}")
    print(f"  Displacement v = {v}")
    print(f"  Elastic energy E = v^T K v = {energy}")

    # Build term: dot(v, mulVec(K, v))
    term = Dot(VecVar("v"), MulVec(MatVar("K"), VecVar("v")))
    env = {"v": v, "K": K}
    val = evaluate(term, env)
    print(f"  Term evaluation: {val}")
    print(f"  Match: {np.isclose(energy, val)}")

def graph_laplacian_example():
    """Graph Laplacian energy: E = v^T L v."""
    print("\n" + "="*60)
    print("PHYSICS EXAMPLE 2: Graph Laplacian Energy")
    print("="*60)
    # Triangle graph Laplacian
    L = np.array([[2, -1, -1], [-1, 2, -1], [-1, -1, 2]], dtype=float)
    v = np.array([1.0, 0.0, -1.0])
    energy = v @ L @ v
    print(f"  Laplacian L = \n{L}")
    print(f"  Signal v = {v}")
    print(f"  Laplacian energy E = v^T L v = {energy}")
    print(f"  (Measures total variation of signal across graph edges)")

def quadratic_penalty_example():
    """Quadratic penalty: E = v^T (A + λI) v."""
    print("\n" + "="*60)
    print("PHYSICS EXAMPLE 3: Quadratic Penalty / Regularization")
    print("="*60)
    n = 3
    A = np.array([[4, 1, 0], [1, 3, 1], [0, 1, 2]], dtype=float)
    lam = 2.0
    I = np.eye(n)
    v = np.array([1.0, -1.0, 0.5])

    # Build term: dot(v, mulVec(matAdd(A, smulMat(λ, I)), v))
    term = Dot(VecVar("v"), MulVec(MatAdd(MatVar("A"), SmulMat(ScalVar("λ"), MatVar("I"))), VecVar("v")))
    env = {"v": v, "A": A, "λ": lam, "I": I}

    val_orig = evaluate(term, env)
    term_norm = normalize_recursive(term)
    val_norm = evaluate(term_norm, env)

    print(f"  A = \n{A}")
    print(f"  λ = {lam}")
    print(f"  v = {v}")
    print(f"  Original term: {term}")
    print(f"  Normalized:    {term_norm}")
    print(f"  Original value:   {val_orig}")
    print(f"  Normalized value: {val_norm}")
    print(f"  Preserved: {np.isclose(val_orig, val_norm)}")


# ============================================================
# Part 7: Random Expression Soundness Test
# ============================================================

def random_soundness_test(num_trials: int = 200, n: int = 4):
    """Test that normalization preserves semantics on random expressions."""
    print("\n" + "="*60)
    print(f"SOUNDNESS TEST: {num_trials} random tensor expressions")
    print("="*60)

    passed = 0
    cost_reduced = 0

    for i in range(num_trials):
        # Random environment
        env = {
            "α": random.uniform(-5, 5),
            "β": random.uniform(-5, 5),
            "γ": random.uniform(-5, 5),
            "v": np.random.randn(n),
            "w": np.random.randn(n),
            "x": np.random.randn(n),
            "A": np.random.randn(n, n),
            "B": np.random.randn(n, n),
            "K": np.random.randn(n, n),
        }

        # Random term (scalar sort for easy comparison)
        term = random_scal_term(max_depth=3)
        try:
            val_orig = evaluate(term, env)
            term_norm = normalize_recursive(term)
            val_norm = evaluate(term_norm, env)

            if np.isclose(val_orig, val_norm, rtol=1e-10):
                passed += 1

            ops_orig = sum(op_count(term).values())
            ops_norm = sum(op_count(term_norm).values())
            if ops_norm <= ops_orig:
                cost_reduced += 1
        except Exception:
            pass

    print(f"  Semantic preservation: {passed}/{num_trials} passed")
    print(f"  Cost non-increase:    {cost_reduced}/{num_trials}")


# ============================================================
# Part 8: Energy Preservation Test
# ============================================================

def energy_preservation_test(num_trials: int = 100, n: int = 4):
    """Test that rewriting preserves v^T A v."""
    print("\n" + "="*60)
    print(f"ENERGY PRESERVATION: {num_trials} trials")
    print("="*60)

    passed = 0
    for _ in range(num_trials):
        A = np.random.randn(n, n)
        v = np.random.randn(n)
        w = np.random.randn(n)

        # Test energy_add identity:
        # E(A, v+w) = E(A,v) + v^T A w + w^T A v + E(A,w)
        E_sum = (v + w) @ A @ (v + w)
        E_v = v @ A @ v
        E_w = w @ A @ w
        cross1 = v @ A @ w
        cross2 = w @ A @ v
        rhs = E_v + cross1 + cross2 + E_w

        if np.isclose(E_sum, rhs, rtol=1e-10):
            passed += 1

    print(f"  Energy expansion identity: {passed}/{num_trials} verified")

    # Test symmetric specialization
    sym_passed = 0
    for _ in range(num_trials):
        M = np.random.randn(n, n)
        A = (M + M.T) / 2  # Make symmetric
        v, w = np.random.randn(n), np.random.randn(n)

        cross1 = v @ A @ w
        cross2 = w @ A @ v
        if np.isclose(cross1, cross2, rtol=1e-10):
            sym_passed += 1

    print(f"  Symmetric cross-term equality: {sym_passed}/{num_trials} verified")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    random.seed(42)
    np.random.seed(42)

    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Tensor-Sorted Rewrite System — Demonstration           ║")
    print("║  Certified symbolic simplification preserving energy     ║")
    print("╚══════════════════════════════════════════════════════════╝")

    # Physics examples
    spring_energy_example()
    graph_laplacian_example()
    quadratic_penalty_example()

    # Random tests
    random_soundness_test(num_trials=500)
    energy_preservation_test(num_trials=500)

    print("\n" + "="*60)
    print("All demonstrations complete.")
    print("="*60)
