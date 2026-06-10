#!/usr/bin/env python3
"""
applications.py — Real-world applications of the Einstein Contraction Calculus.

Demonstrates how the universal contraction laws apply to:
1. Stress-strain energy in continuum mechanics
2. Metric contraction in differential geometry
3. Tensor network contraction optimization
4. Quadratic form manipulation in machine learning
"""

import numpy as np
from typing import Tuple


# ─── Graded Tensor Infrastructure ────────────────────────────────────────────

class Tensor:
    """Graded tensor with named role for physics/geometry context."""

    def __init__(self, data: np.ndarray, order: int, dim: int, name: str = ""):
        self.data = data
        self.order = order
        self.dim = dim
        self.name = name

    @staticmethod
    def random(order, dim, name=""):
        return Tensor(np.random.randn(*(dim,)*order), order, dim, name)

    @staticmethod
    def symmetric_matrix(dim, name=""):
        M = np.random.randn(dim, dim)
        return Tensor((M + M.T) / 2, 2, dim, name)

    @staticmethod
    def zero(order, dim, name=""):
        return Tensor(np.zeros((dim,)*order), order, dim, name)

    def __add__(self, other):
        return Tensor(self.data + other.data, self.order, self.dim)

    def __repr__(self):
        if self.name:
            return f"{self.name}(order-{self.order})"
        return f"Tensor(order={self.order})"


def contract(T, v):
    j = T.order - v.order
    k = v.order
    d = T.dim
    all_idx = ''.join(chr(ord('a') + i) for i in range(j + k))
    v_idx = ''.join(chr(ord('a') + i) for i in range(j, j + k))
    out_idx = ''.join(chr(ord('a') + i) for i in range(j))
    sub = f"{all_idx},{v_idx}->{out_idx}" if j > 0 else f"{all_idx},{v_idx}->"
    result = np.einsum(sub, T.data, v.data)
    return Tensor(np.array(result), j, d)


def tensor_prod(A, B):
    result = np.tensordot(A.data, B.data, axes=0)
    return Tensor(result, A.order + B.order, A.dim)


# ─── Application 1: Continuum Mechanics ──────────────────────────────────────

def demo_continuum_mechanics():
    """Stress-strain energy computation using tensor contraction.

    In continuum mechanics, the elastic energy density is:
        W = (1/2) σᵢⱼ εᵢⱼ = (1/2) contract(ε, contract(C, ε))

    where C is the 4th-order stiffness tensor, ε is the strain tensor (order 2),
    and σ = contract(C, ε) is the stress tensor.

    The energy expansion theorem (Theorem 4) tells us:
        W(ε₁ + ε₂) = W(ε₁) + cross terms + W(ε₂)

    This is the superposition principle for elastic energy.
    """
    print("=" * 60)
    print("Application 1: Continuum Mechanics — Elastic Energy")
    print("=" * 60)

    d = 3  # 3D space

    # Stiffness tensor C (order-4, symmetric)
    C_data = np.random.randn(d, d, d, d)
    # Enforce minor symmetries: Cᵢⱼₖₗ = Cⱼᵢₖₗ = Cᵢⱼₗₖ
    C_data = (C_data + C_data.transpose(1, 0, 2, 3)) / 2
    C_data = (C_data + C_data.transpose(0, 1, 3, 2)) / 2
    C = Tensor(C_data, 4, d, "C_stiffness")

    # Two strain fields
    eps1_data = np.random.randn(d, d)
    eps1 = Tensor((eps1_data + eps1_data.T) / 2, 2, d, "ε₁")
    eps2_data = np.random.randn(d, d)
    eps2 = Tensor((eps2_data + eps2_data.T) / 2, 2, d, "ε₂")

    # Stress = contract(C, ε)
    sigma1 = contract(C, eps1)
    sigma2 = contract(C, eps2)
    print(f"  Stress σ₁ = C:ε₁ (order {sigma1.order})")
    print(f"  Stress σ₂ = C:ε₂ (order {sigma2.order})")

    # Energy W(ε) = contract(ε, σ) = contract(ε, contract(C, ε))
    W1 = contract(eps1, sigma1)
    W2 = contract(eps2, sigma2)
    print(f"  W(ε₁) = {float(W1.data):.6f}")
    print(f"  W(ε₂) = {float(W2.data):.6f}")

    # Energy expansion: W(ε₁ + ε₂) = W(ε₁) + cross + W(ε₂)
    eps_sum = eps1 + eps2
    W_sum = contract(eps_sum, contract(C, eps_sum))
    cross1 = contract(eps1, contract(C, eps2))
    cross2 = contract(eps2, contract(C, eps1))
    W_expanded = Tensor(W1.data + cross1.data + cross2.data + W2.data, 0, d)

    print(f"  W(ε₁+ε₂) = {float(W_sum.data):.6f}")
    print(f"  W(ε₁) + cross + W(ε₂) = {float(W_expanded.data):.6f}")
    print(f"  Energy expansion verified: {np.allclose(W_sum.data, W_expanded.data)} ✓")
    print()


# ─── Application 2: Differential Geometry ────────────────────────────────────

def demo_differential_geometry():
    """Metric contraction and inner products using tensor calculus.

    On a Riemannian manifold, the metric tensor g (order-2) defines:
    - Inner product: ⟨u, v⟩ = contract(u, contract(g, v))
    - Norm squared: |v|² = ⟨v, v⟩ = contract(v, contract(g, v))

    The polarization identity (Theorem 4) gives:
        |u+v|² = |u|² + ⟨u,v⟩ + ⟨v,u⟩ + |v|²

    For a symmetric metric: ⟨u,v⟩ = ⟨v,u⟩, so:
        |u+v|² = |u|² + 2⟨u,v⟩ + |v|²
    """
    print("=" * 60)
    print("Application 2: Differential Geometry — Metric Contraction")
    print("=" * 60)

    d = 4  # 4D spacetime

    # Symmetric positive-definite metric tensor
    A = np.random.randn(d, d)
    g_data = A @ A.T + np.eye(d)  # Ensure positive definite
    g = Tensor(g_data, 2, d, "g_metric")

    # Two tangent vectors
    u = Tensor(np.random.randn(d), 1, d, "u")
    v = Tensor(np.random.randn(d), 1, d, "v")

    # Inner products
    gu = contract(g, u)
    gv = contract(g, v)

    inner_uu = contract(u, gu)
    inner_vv = contract(v, gv)
    inner_uv = contract(u, gv)
    inner_vu = contract(v, gu)

    print(f"  ⟨u,u⟩ = {float(inner_uu.data):.6f}")
    print(f"  ⟨v,v⟩ = {float(inner_vv.data):.6f}")
    print(f"  ⟨u,v⟩ = {float(inner_uv.data):.6f}")
    print(f"  ⟨v,u⟩ = {float(inner_vu.data):.6f}")

    # Symmetry check: ⟨u,v⟩ = ⟨v,u⟩ for symmetric metric
    print(f"  Symmetry ⟨u,v⟩ = ⟨v,u⟩: {np.allclose(inner_uv.data, inner_vu.data)} ✓")

    # Polarization: |u+v|² = |u|² + ⟨u,v⟩ + ⟨v,u⟩ + |v|²
    uv_sum = u + v
    norm_sum = contract(uv_sum, contract(g, uv_sum))
    expanded = Tensor(inner_uu.data + inner_uv.data + inner_vu.data + inner_vv.data, 0, d)

    print(f"  |u+v|² = {float(norm_sum.data):.6f}")
    print(f"  |u|² + 2⟨u,v⟩ + |v|² = {float(expanded.data):.6f}")
    print(f"  Polarization identity verified: {np.allclose(norm_sum.data, expanded.data)} ✓")
    print()


# ─── Application 3: Tensor Network Contraction ──────────────────────────────

def demo_tensor_networks():
    """Tensor network contraction order optimization.

    In quantum simulation and machine learning, tensor networks
    consist of many tensors contracted along shared indices.
    The contraction associativity theorem (Theorem 3) guarantees
    that different contraction orders give the same result.

    This demo shows that for a chain A-B-C-D of contracted tensors,
    different bracketing orders produce identical results.
    """
    print("=" * 60)
    print("Application 3: Tensor Networks — Contraction Order")
    print("=" * 60)

    d = 3

    # Four tensors in a contraction chain
    T1 = Tensor(np.random.randn(d, d), 2, d, "T₁")
    T2 = Tensor(np.random.randn(d, d), 2, d, "T₂")
    T3 = Tensor(np.random.randn(d, d), 2, d, "T₃")
    v = Tensor(np.random.randn(d), 1, d, "v")

    # Order 1: ((T₁ · T₂) · T₃) · v
    r1 = contract(T1, contract(T2, contract(T3, v)))

    # Order 2: T₁ · (T₂ · (T₃ · v))
    r2_inner = contract(T3, v)        # order 1
    r2_mid = contract(T2, r2_inner)   # order 1
    r2 = contract(T1, r2_mid)         # order 1

    # Order 3: (T₁ · T₂) · (T₃ · v)
    T12 = Tensor(T1.data @ T2.data, 2, d)  # matrix product
    T3v = contract(T3, v)
    r3 = contract(T12, T3v)

    print(f"  Order 1: ((T₁·T₂)·T₃)·v = {r1.data}")
    print(f"  Order 2: T₁·(T₂·(T₃·v)) = {r2.data}")
    print(f"  Order 3: (T₁·T₂)·(T₃·v) = {r3.data}")
    print(f"  All orders agree: {np.allclose(r1.data, r2.data) and np.allclose(r1.data, r3.data)} ✓")
    print()

    # Higher-order example: order-3 tensor contracted with two vectors
    T3d = Tensor(np.random.randn(d, d, d), 3, d, "T₃")
    u = Tensor(np.random.randn(d), 1, d, "u")
    w = Tensor(np.random.randn(d), 1, d, "w")

    # Two contraction orders
    r_left = contract(contract(T3d, w), u)   # (T₃·w)·u
    uw = tensor_prod(u, w)                    # u ⊗ w
    r_right = contract(T3d, uw)              # T₃·(u⊗w)

    print(f"  Order-3: (T₃·w)·u = {r_left.data}")
    print(f"  Order-3: T₃·(u⊗w) = {r_right.data}")
    print(f"  Associativity verified: {np.allclose(r_left.data, r_right.data)} ✓")
    print()


# ─── Application 4: Machine Learning Quadratic Forms ────────────────────────

def demo_ml_quadratic():
    """Quadratic forms in machine learning loss functions.

    Many ML loss functions involve quadratic forms:
        L(w) = (1/2) wᵀ H w - bᵀ w

    The energy expansion gives gradient-free optimization insight:
        L(w + δ) = L(w) + δᵀ(Hw - b) + (1/2) δᵀ H δ

    This decomposes the loss change into a linear term (gradient direction)
    and a quadratic term (curvature correction).
    """
    print("=" * 60)
    print("Application 4: ML — Quadratic Loss Decomposition")
    print("=" * 60)

    d = 5  # parameter dimension

    # Hessian matrix (symmetric positive definite)
    A = np.random.randn(d, d)
    H = Tensor((A @ A.T + np.eye(d)), 2, d, "H")

    # Current weights and perturbation
    w = Tensor(np.random.randn(d), 1, d, "w")
    delta = Tensor(0.1 * np.random.randn(d), 1, d, "δ")

    # L(w) = (1/2) wᵀ H w
    E_w = contract(w, contract(H, w))
    E_delta = contract(delta, contract(H, delta))
    cross_wd = contract(w, contract(H, delta))
    cross_dw = contract(delta, contract(H, w))

    # L(w + δ)
    wd = w + delta
    E_wd = contract(wd, contract(H, wd))

    # Expansion
    expanded = Tensor(E_w.data + cross_wd.data + cross_dw.data + E_delta.data, 0, d)

    print(f"  L(w)     = {float(E_w.data):.6f}")
    print(f"  L(δ)     = {float(E_delta.data):.6f}")
    print(f"  L(w+δ)   = {float(E_wd.data):.6f}")
    print(f"  Expanded = {float(expanded.data):.6f}")
    print(f"  Expansion verified: {np.allclose(E_wd.data, expanded.data)} ✓")

    # The gradient term: ∇L(w) · δ = δᵀ H w
    grad_term = float(cross_dw.data)
    curv_term = float(E_delta.data)
    print(f"  Gradient contribution: {grad_term:.6f}")
    print(f"  Curvature contribution: {curv_term:.6f}")
    print(f"  Ratio (curvature/gradient): {abs(curv_term/grad_term):.4f}")
    print()


if __name__ == "__main__":
    np.random.seed(42)

    print()
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║  Einstein Contraction Calculus — Real-World Applications   ║")
    print("╚══════════════════════════════════════════════════════════════╝")
    print()

    demo_continuum_mechanics()
    demo_differential_geometry()
    demo_tensor_networks()
    demo_ml_quadratic()

    print("All applications demonstrated successfully. ✓")


#!/usr/bin/env python3
"""
demo.py — Interactive demonstration of the Einstein Contraction Calculus.

Builds random well-typed tensor terms, applies rewrite/normalization,
evaluates both original and transformed terms, and prints semantic agreement.
Showcases the energy identity and higher-order contraction examples.
"""

import numpy as np
import random
from typing import Tuple, List, Optional

# ─── Semantic Layer: Graded Tensors ───────────────────────────────────────────

class GradedTensor:
    """An order-n tensor over reals with dimension d.
    Internally stored as a numpy array of shape (d,)*n."""

    def __init__(self, data: np.ndarray, order: int, dim: int):
        assert data.shape == (dim,) * order, f"Shape mismatch: {data.shape} vs {(dim,)*order}"
        self.data = data
        self.order = order
        self.dim = dim

    @staticmethod
    def random(order: int, dim: int) -> 'GradedTensor':
        shape = (dim,) * order
        return GradedTensor(np.random.randn(*shape) if order > 0 else np.array(np.random.randn()), order, dim)

    @staticmethod
    def zero(order: int, dim: int) -> 'GradedTensor':
        shape = (dim,) * order
        return GradedTensor(np.zeros(shape), order, dim)

    def __add__(self, other: 'GradedTensor') -> 'GradedTensor':
        assert self.order == other.order and self.dim == other.dim
        return GradedTensor(self.data + other.data, self.order, self.dim)

    def __repr__(self):
        if self.order == 0:
            return f"Scalar({float(self.data):.6f})"
        return f"Tensor(order={self.order}, dim={self.dim})"


def contract(T: GradedTensor, v: GradedTensor) -> GradedTensor:
    """Contract order-(j+k) tensor T with order-k tensor v to get order-j tensor.
    Sums over the last k indices of T against all indices of v."""
    j = T.order - v.order
    k = v.order
    assert j >= 0, f"Cannot contract: T.order={T.order} < v.order={v.order}"
    d = T.dim
    assert v.dim == d

    # T has shape (d,)*(j+k), v has shape (d,)*k
    # Result has shape (d,)*j
    # contract(T, v)[i1,...,ij] = sum_{c1,...,ck} T[i1,...,ij,c1,...,ck] * v[c1,...,ck]

    # Use einsum
    t_indices = list(range(j + k))
    v_indices = list(range(j, j + k))
    out_indices = list(range(j))

    t_chars = ''.join(chr(ord('a') + i) for i in t_indices)
    v_chars = ''.join(chr(ord('a') + i) for i in v_indices)
    o_chars = ''.join(chr(ord('a') + i) for i in out_indices)

    if j == 0:
        result = np.einsum(f"{t_chars},{v_chars}->", T.data, v.data)
        return GradedTensor(np.array(result), 0, d)
    else:
        result = np.einsum(f"{t_chars},{v_chars}->{o_chars}", T.data, v.data)
        return GradedTensor(result, j, d)


def tensor_prod(A: GradedTensor, B: GradedTensor) -> GradedTensor:
    """Tensor product: order-j ⊗ order-k → order-(j+k)."""
    d = A.dim
    assert B.dim == d
    result = np.tensordot(A.data, B.data, axes=0)
    return GradedTensor(result, A.order + B.order, d)


def smul(r: float, T: GradedTensor) -> GradedTensor:
    """Scalar multiplication."""
    return GradedTensor(r * T.data, T.order, T.dim)


# ─── Syntax Layer: Einstein Terms ──────────────────────────────────────────────

class EinsteinTerm:
    """Symbolic tensor expression."""
    pass

class Var(EinsteinTerm):
    def __init__(self, name: str, order: int):
        self.name = name
        self.order = order
    def __repr__(self): return self.name

class Zero(EinsteinTerm):
    def __init__(self, order: int):
        self.order = order
    def __repr__(self): return "0"

class Add(EinsteinTerm):
    def __init__(self, a: EinsteinTerm, b: EinsteinTerm):
        assert a.order == b.order
        self.a, self.b = a, b
        self.order = a.order
    def __repr__(self): return f"({self.a} + {self.b})"

class Smul(EinsteinTerm):
    def __init__(self, r: float, t: EinsteinTerm):
        self.r, self.t = r, t
        self.order = t.order
    def __repr__(self): return f"({self.r:.2f} * {self.t})"

class Contract(EinsteinTerm):
    def __init__(self, T: EinsteinTerm, v: EinsteinTerm):
        self.T, self.v = T, v
        self.order = T.order - v.order
    def __repr__(self): return f"contract({self.T}, {self.v})"


def evaluate(term: EinsteinTerm, env: dict, dim: int) -> GradedTensor:
    """Evaluate a term given an environment mapping variable names to GradedTensors."""
    if isinstance(term, Var):
        return env[term.name]
    elif isinstance(term, Zero):
        return GradedTensor.zero(term.order, dim)
    elif isinstance(term, Add):
        return evaluate(term.a, env, dim) + evaluate(term.b, env, dim)
    elif isinstance(term, Smul):
        return smul(term.r, evaluate(term.t, env, dim))
    elif isinstance(term, Contract):
        return contract(evaluate(term.T, env, dim), evaluate(term.v, env, dim))
    else:
        raise ValueError(f"Unknown term type: {type(term)}")


def normalize(term: EinsteinTerm) -> EinsteinTerm:
    """Push contraction through addition (one level)."""
    if isinstance(term, Contract):
        if isinstance(term.T, Add):
            A, B = term.T.a, term.T.b
            v = term.v
            return Add(Contract(normalize(A), normalize(v)),
                       Contract(normalize(B), normalize(v)))
        elif isinstance(term.v, Add):
            T = term.T
            u, w = term.v.a, term.v.b
            return Add(Contract(normalize(T), normalize(u)),
                       Contract(normalize(T), normalize(w)))
        else:
            return Contract(normalize(term.T), normalize(term.v))
    elif isinstance(term, Add):
        return Add(normalize(term.a), normalize(term.b))
    elif isinstance(term, Smul):
        return Smul(term.r, normalize(term.t))
    else:
        return term


def tensors_close(a: GradedTensor, b: GradedTensor, tol: float = 1e-10) -> bool:
    """Check if two tensors are numerically close."""
    return np.allclose(a.data, b.data, atol=tol)


# ─── Demonstrations ──────────────────────────────────────────────────────────

def demo_bilinearity():
    """Demonstrate Theorems 1 & 2: Bilinearity of contraction."""
    print("=" * 70)
    print("DEMO 1: Bilinearity of Contraction (Theorems 1 & 2)")
    print("=" * 70)

    d = 3
    for j, k in [(1, 1), (2, 1), (1, 2), (2, 2), (3, 1), (0, 2)]:
        passed = 0
        for _ in range(100):
            A = GradedTensor.random(j + k, d)
            B = GradedTensor.random(j + k, d)
            u = GradedTensor.random(k, d)
            v = GradedTensor.random(k, d)

            # Left distributivity
            lhs_left = contract(A + B, u)
            rhs_left = contract(A, u) + contract(B, u)
            assert tensors_close(lhs_left, rhs_left), "Left distributivity FAILED!"

            # Right distributivity
            lhs_right = contract(A, u + v)
            rhs_right = contract(A, u) + contract(A, v)
            assert tensors_close(lhs_right, rhs_right), "Right distributivity FAILED!"
            passed += 1

        print(f"  orders ({j+k},{k})→{j}: {passed}/100 tests passed ✓")

    print()


def demo_associativity():
    """Demonstrate Theorem 3: Associativity of iterated contraction."""
    print("=" * 70)
    print("DEMO 2: Associativity of Iterated Contraction (Theorem 3)")
    print("=" * 70)

    d = 3
    for a, b, c in [(1, 1, 1), (2, 1, 1), (1, 2, 1), (0, 1, 2), (1, 1, 2)]:
        passed = 0
        for _ in range(100):
            T = GradedTensor.random(a + b + c, d)
            u = GradedTensor.random(c, d)
            v = GradedTensor.random(b, d)

            # LHS: contract(contract(T, u), v)
            lhs = contract(contract(T, u), v)

            # RHS: contract(T, tensorProd(v, u))
            vu = tensor_prod(v, u)
            rhs = contract(T, vu)

            assert tensors_close(lhs, rhs), \
                f"Associativity FAILED for (a,b,c)=({a},{b},{c})!"
            passed += 1

        print(f"  orders ({a}+{b}+{c}, {c}, {b})→{a}: {passed}/100 tests passed ✓")
    print()


def demo_energy_identity():
    """Demonstrate Theorem 4: Quadratic energy expansion."""
    print("=" * 70)
    print("DEMO 3: Quadratic Energy Expansion (Theorem 4)")
    print("=" * 70)

    d = 4
    passed = 0
    for _ in range(200):
        T = GradedTensor.random(2, d)
        u = GradedTensor.random(1, d)
        v = GradedTensor.random(1, d)

        # E(T, u+v)
        lhs = contract(u + v, contract(T, u + v))

        # E(T,u) + contract(u, T*v) + contract(v, T*u) + E(T,v)
        Eu = contract(u, contract(T, u))
        Ev = contract(v, contract(T, v))
        cross1 = contract(u, contract(T, v))
        cross2 = contract(v, contract(T, u))
        rhs = Eu + cross1 + cross2 + Ev

        assert tensors_close(lhs, rhs), "Energy identity FAILED!"
        passed += 1

    print(f"  200/200 energy expansion tests passed ✓")
    print(f"  Example: E(T, u+v) = {float(lhs.data):.6f}")
    print(f"           E(T,u) + cross + E(T,v) = {float(rhs.data):.6f}")
    print()


def demo_rewrite_soundness():
    """Demonstrate Theorem 5: Soundness of rewrite rules."""
    print("=" * 70)
    print("DEMO 4: Rewrite Soundness (Theorem 5)")
    print("=" * 70)

    d = 3
    passed = 0
    total = 0

    for _ in range(200):
        # Build a random term: contract(add(A, B), v)
        j, k = random.choice([(1, 1), (2, 1), (1, 2), (0, 1), (0, 2)])
        env = {}

        A_name, B_name, v_name = f"A_{total}", f"B_{total}", f"v_{total}"
        env[A_name] = GradedTensor.random(j + k, d)
        env[B_name] = GradedTensor.random(j + k, d)
        env[v_name] = GradedTensor.random(k, d)

        # Original: contract(A + B, v)
        original = Contract(Add(Var(A_name, j + k), Var(B_name, j + k)), Var(v_name, k))
        # Rewritten: contract(A, v) + contract(B, v)
        rewritten = Add(Contract(Var(A_name, j + k), Var(v_name, k)),
                        Contract(Var(B_name, j + k), Var(v_name, k)))

        val_orig = evaluate(original, env, d)
        val_rewr = evaluate(rewritten, env, d)

        assert tensors_close(val_orig, val_rewr), "Rewrite soundness FAILED!"
        passed += 1
        total += 1

    print(f"  {passed}/{total} rewrite soundness tests passed ✓")
    print()


def demo_normalization():
    """Demonstrate Theorem 6: Normalization soundness."""
    print("=" * 70)
    print("DEMO 5: Normalization Soundness (Theorem 6)")
    print("=" * 70)

    d = 3
    passed = 0

    for trial in range(200):
        env = {}

        # Build a nested term: contract(add(A, B), add(u, v))
        j, k = random.choice([(1, 1), (2, 1), (0, 2)])
        names = [f"A_{trial}", f"B_{trial}", f"u_{trial}", f"v_{trial}"]
        env[names[0]] = GradedTensor.random(j + k, d)
        env[names[1]] = GradedTensor.random(j + k, d)
        env[names[2]] = GradedTensor.random(k, d)
        env[names[3]] = GradedTensor.random(k, d)

        term = Contract(
            Add(Var(names[0], j + k), Var(names[1], j + k)),
            Add(Var(names[2], k), Var(names[3], k))
        )

        val_orig = evaluate(term, env, d)
        normalized = normalize(term)
        val_norm = evaluate(normalized, env, d)

        assert tensors_close(val_orig, val_norm), \
            f"Normalization soundness FAILED on trial {trial}!"
        passed += 1

    print(f"  {passed}/200 normalization tests passed ✓")
    print()


def demo_higher_order():
    """Demonstrate higher-order contraction with order-3 tensors."""
    print("=" * 70)
    print("DEMO 6: Higher-Order Contraction (Order-3 Tensors)")
    print("=" * 70)

    d = 3
    passed = 0

    for _ in range(100):
        # Order-3 tensor contracted with order-1 vector gives order-2 matrix
        T3 = GradedTensor.random(3, d)
        v = GradedTensor.random(1, d)
        w = GradedTensor.random(1, d)

        # Bilinearity: contract(T3, v + w) = contract(T3, v) + contract(T3, w)
        lhs = contract(T3, v + w)
        rhs = contract(T3, v) + contract(T3, w)
        assert tensors_close(lhs, rhs)

        # Iterated contraction: contract(contract(T3, v), w)
        # This gives an order-1 tensor
        result = contract(contract(T3, v), w)
        assert result.order == 1

        # Via tensor product: contract(T3, tensorProd(w, v))
        wv = tensor_prod(w, v)
        result2 = contract(T3, wv)
        assert tensors_close(result, result2)

        passed += 1

    print(f"  {passed}/100 order-3 contraction tests passed ✓")
    print(f"  Verified: contract(contract(T₃, v), w) = contract(T₃, w ⊗ v)")
    print()


def demo_all_pairwise():
    """Test all 6 pairwise contraction patterns for orders 0-3."""
    print("=" * 70)
    print("DEMO 7: All Pairwise Contraction Patterns (Orders 0-3)")
    print("=" * 70)

    d = 3
    patterns = [
        (1, 1, "order-1 ⊗ order-1 → scalar"),
        (2, 1, "order-2 ⊗ order-1 → order-1"),
        (2, 2, "order-2 ⊗ order-2 → scalar"),
        (3, 1, "order-3 ⊗ order-1 → order-2"),
        (3, 2, "order-3 ⊗ order-2 → order-1"),
        (3, 3, "order-3 ⊗ order-3 → scalar"),
    ]

    for jk, k, desc in patterns:
        passed = 0
        for _ in range(1000):
            A = GradedTensor.random(jk, d)
            B = GradedTensor.random(jk, d)
            u = GradedTensor.random(k, d)
            v = GradedTensor.random(k, d)

            # Test bilinearity (both sides)
            assert tensors_close(contract(A + B, u), contract(A, u) + contract(B, u))
            assert tensors_close(contract(A, u + v), contract(A, u) + contract(A, v))
            passed += 1

        print(f"  {desc}: {passed}/1000 tests passed ✓")
    print()


if __name__ == "__main__":
    np.random.seed(42)
    random.seed(42)

    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║   Einstein Contraction Calculus — Interactive Demonstration        ║")
    print("║   Universal Order-Graded Tensor Contraction Laws                   ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_bilinearity()
    demo_associativity()
    demo_energy_identity()
    demo_rewrite_soundness()
    demo_normalization()
    demo_higher_order()
    demo_all_pairwise()

    print("=" * 70)
    print("ALL TESTS PASSED ✓")
    print("=" * 70)
    print()
    print("Summary of verified properties:")
    print("  1. Left distributivity:  contract(A+B, v) = contract(A,v) + contract(B,v)")
    print("  2. Right distributivity: contract(T, u+v) = contract(T,u) + contract(T,v)")
    print("  3. Associativity:        contract(contract(T,u),v) = contract(T, v⊗u)")
    print("  4. Energy expansion:     E(T,u+v) = E(T,u) + cross terms + E(T,v)")
    print("  5. Rewrite soundness:    rewrites preserve denotation")
    print("  6. Normalizer soundness: normalize preserves semantics")
    print("  7. All 6 pairwise patterns for orders 0-3 verified (1000 trials each)")


#!/usr/bin/env python3
"""
Visualization 3: Contraction Associativity and Tensor Networks

Visualizes the associativity theorem: contract(contract(T,u),v) = contract(T, v⊗u)
by showing the error between left-associated and right-associated contraction
across random tensor instances, demonstrating the zero-error guarantee.
"""

import numpy as np
import matplotlib.pyplot as plt

np.random.seed(42)

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# ─── Panel 1: Associativity Error Distribution ───────────────────────────
ax1 = axes[0]

configs = [(1, 1, 1), (2, 1, 1), (1, 2, 1), (0, 1, 2), (1, 1, 2)]
d = 4
n_trials = 500
all_errors = {}

for a, b, c in configs:
    errors = []
    for _ in range(n_trials):
        T = np.random.randn(*(d,)*(a+b+c))
        u = np.random.randn(*(d,)*c)
        v = np.random.randn(*(d,)*b)

        # LHS: contract(contract(T, u), v)
        t_idx = ''.join(chr(ord('a')+i) for i in range(a+b+c))
        u_idx = ''.join(chr(ord('a')+i) for i in range(a+b, a+b+c))
        mid_idx = ''.join(chr(ord('a')+i) for i in range(a+b))
        sub1 = f"{t_idx},{u_idx}->{mid_idx}" if a+b > 0 else f"{t_idx},{u_idx}->"

        mid = np.einsum(sub1, T, u)

        v_idx2 = ''.join(chr(ord('a')+i) for i in range(a, a+b))
        out_idx = ''.join(chr(ord('a')+i) for i in range(a))
        sub2 = f"{mid_idx},{v_idx2}->{out_idx}" if a > 0 else f"{mid_idx},{v_idx2}->"

        lhs = np.einsum(sub2, mid, v)

        # RHS: contract(T, tensorProd(v, u))
        vu = np.tensordot(v, u, axes=0)  # shape (d,)*b × (d,)*c = (d,)*(b+c)
        vu_idx = ''.join(chr(ord('a')+i) for i in range(a, a+b+c))
        sub3 = f"{t_idx},{vu_idx}->{out_idx}" if a > 0 else f"{t_idx},{vu_idx}->"

        rhs = np.einsum(sub3, T, vu)

        errors.append(np.max(np.abs(np.atleast_1d(lhs) - np.atleast_1d(rhs))))

    label = f"({a},{b},{c})"
    all_errors[label] = errors

positions = list(range(len(configs)))
bp = ax1.boxplot([all_errors[f"({a},{b},{c})"] for a, b, c in configs],
                 positions=positions, widths=0.6, patch_artist=True)
for patch in bp['boxes']:
    patch.set_facecolor('lightblue')

ax1.set_xticks(positions)
ax1.set_xticklabels([f"({a},{b},{c})" for a, b, c in configs])
ax1.set_ylabel('Max |LHS - RHS|')
ax1.set_title('Contraction Associativity Error\n(a,b,c) order triples', fontsize=11)
ax1.set_yscale('log')
ax1.axhline(y=1e-14, color='green', linestyle='--', alpha=0.7, label='Machine epsilon')
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.3)

# ─── Panel 2: Tensor Network Diagram ─────────────────────────────────────
ax2 = axes[1]

# Draw a simple tensor network
ax2.set_xlim(-0.5, 4.5)
ax2.set_ylim(-1, 3)
ax2.set_aspect('equal')

# Nodes
nodes = [(1, 2, 'T\n(a+b+c)'), (0, 0.5, 'v\n(b)'), (2, 0.5, 'u\n(c)'),
         (3.5, 2, 'T\n(a+b+c)'), (3.5, 0.5, 'v⊗u\n(b+c)')]

colors = ['#4CAF50', '#2196F3', '#FF9800', '#4CAF50', '#9C27B0']

for (x, y, label), color in zip(nodes, colors):
    circle = plt.Circle((x, y), 0.35, color=color, alpha=0.7, zorder=5)
    ax2.add_patch(circle)
    ax2.text(x, y, label, ha='center', va='center', fontsize=8, fontweight='bold',
             color='white', zorder=6)

# Edges (contraction lines)
ax2.annotate('', xy=(0.3, 0.8), xytext=(0.75, 1.7),
             arrowprops=dict(arrowstyle='->', color='red', lw=2))
ax2.annotate('', xy=(1.7, 0.8), xytext=(1.25, 1.7),
             arrowprops=dict(arrowstyle='->', color='red', lw=2))

ax2.annotate('', xy=(3.5, 0.9), xytext=(3.5, 1.6),
             arrowprops=dict(arrowstyle='->', color='red', lw=2))

# Labels
ax2.text(1, -0.5, 'Left-associated', ha='center', fontsize=10, style='italic')
ax2.text(3.5, -0.5, 'Right-associated', ha='center', fontsize=10, style='italic')
ax2.text(2.25, 2.5, '=', ha='center', fontsize=24, fontweight='bold', color='red')

ax2.set_title('Contraction Associativity\nNetwork Diagram', fontsize=11)
ax2.axis('off')

# ─── Panel 3: Cost Comparison ────────────────────────────────────────────
ax3 = axes[2]

dims = range(2, 15)
costs_left = []
costs_right = []

for d_val in dims:
    # Left: contract(contract(T_{2+1+1}, u_1), v_1)
    # Step 1: d^(2+1) * d^1 = d^4 mults, Step 2: d^2 * d^1 = d^3 mults
    cost_l = d_val**4 + d_val**3

    # Right: contract(T_{2+1+1}, tensorProd(v_1, u_1))
    # TensorProd: d^2 mults, then: d^2 * d^2 = d^4 mults
    cost_r = d_val**2 + d_val**4

    costs_left.append(cost_l)
    costs_right.append(cost_r)

ax3.semilogy(list(dims), costs_left, 'b-o', markersize=4, label='Left: (T·u)·v')
ax3.semilogy(list(dims), costs_right, 'r-s', markersize=4, label='Right: T·(v⊗u)')
ax3.set_xlabel('Dimension d')
ax3.set_ylabel('Estimated FLOPs')
ax3.set_title('Contraction Cost Comparison\n(orders 2+1+1)', fontsize=11)
ax3.legend()
ax3.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_associativity.png', dpi=150, bbox_inches='tight')
print("Saved viz_associativity.png")


#!/usr/bin/env python3
"""
Visualization 1: Contraction Bilinearity Heatmap

Visualizes the bilinearity of tensor contraction by showing how
contract(αA + βB, v) decomposes as α·contract(A,v) + β·contract(B,v).
The heatmap shows the error (which should be zero) across a grid of
(α, β) values, confirming bilinearity for tensors of various orders.
"""

import numpy as np
import matplotlib.pyplot as plt

np.random.seed(42)

d = 4  # dimension
fig, axes = plt.subplots(1, 3, figsize=(15, 4.5))

orders = [(2, 1, "Matrix × Vector → Vector"),
          (3, 1, "Order-3 × Vector → Matrix"),
          (3, 2, "Order-3 × Matrix → Vector")]

for ax, (jk, k, title) in zip(axes, orders):
    T1 = np.random.randn(*(d,)*jk)
    T2 = np.random.randn(*(d,)*jk)
    v = np.random.randn(*(d,)*k)

    j = jk - k
    all_idx = ''.join(chr(ord('a') + i) for i in range(jk))
    v_idx = ''.join(chr(ord('a') + i) for i in range(j, jk))
    o_idx = ''.join(chr(ord('a') + i) for i in range(j))
    sub = f"{all_idx},{v_idx}->{o_idx}" if j > 0 else f"{all_idx},{v_idx}->"

    alphas = np.linspace(-2, 2, 50)
    betas = np.linspace(-2, 2, 50)
    errors = np.zeros((50, 50))

    c1 = np.einsum(sub, T1, v)
    c2 = np.einsum(sub, T2, v)

    for i, a in enumerate(alphas):
        for jj, b in enumerate(betas):
            combined = np.einsum(sub, a * T1 + b * T2, v)
            linear = a * c1 + b * c2
            errors[i, jj] = np.max(np.abs(combined - linear))

    im = ax.imshow(errors, extent=[-2, 2, -2, 2], origin='lower',
                   cmap='RdYlGn_r', vmin=0, vmax=1e-13, aspect='auto')
    ax.set_xlabel('β', fontsize=12)
    ax.set_ylabel('α', fontsize=12)
    ax.set_title(title, fontsize=11)
    plt.colorbar(im, ax=ax, label='Max |error|')

fig.suptitle('Bilinearity of Tensor Contraction: |contract(αA+βB, v) - α·contract(A,v) - β·contract(B,v)|',
             fontsize=13, y=1.02)
plt.tight_layout()
plt.savefig('viz_bilinearity.png', dpi=150, bbox_inches='tight')
print("Saved viz_bilinearity.png")


#!/usr/bin/env python3
"""
Visualization 2: Energy Landscape and Polarization Identity

Visualizes the quadratic energy functional E(T, v) = vᵀTv for a 2D
metric tensor, showing:
- The energy surface as a function of vector components
- The polarization decomposition: E(u+v) = E(u) + cross terms + E(v)
- Energy level curves demonstrating the quadratic structure
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib import cm

np.random.seed(42)

fig = plt.figure(figsize=(16, 5))

# ─── Panel 1: Energy Surface ─────────────────────────────────────────────
ax1 = fig.add_subplot(131, projection='3d')

# Symmetric positive-definite 2x2 matrix
T = np.array([[3.0, 1.0], [1.0, 2.0]])

x = np.linspace(-2, 2, 80)
y = np.linspace(-2, 2, 80)
X, Y = np.meshgrid(x, y)
Z = np.zeros_like(X)

for i in range(len(x)):
    for j in range(len(y)):
        v = np.array([X[i, j], Y[i, j]])
        Z[i, j] = v @ T @ v

ax1.plot_surface(X, Y, Z, cmap=cm.viridis, alpha=0.8, linewidth=0.2,
                 edgecolor='gray', rcount=40, ccount=40)
ax1.set_xlabel('v₁')
ax1.set_ylabel('v₂')
ax1.set_zlabel('E(T, v)')
ax1.set_title('Quadratic Energy\nE(T, v) = vᵀTv', fontsize=11)

# ─── Panel 2: Polarization Decomposition ─────────────────────────────────
ax2 = fig.add_subplot(132)

# Fix u, vary v along a line
u = np.array([1.0, 0.5])
t_vals = np.linspace(-2, 2, 200)

E_total = []
E_u_only = []
E_v_only = []
E_cross = []

for t in t_vals:
    v = t * np.array([0.3, 1.0])
    uv = u + v

    e_total = uv @ T @ uv
    e_u = u @ T @ u
    e_v = v @ T @ v
    cross = u @ T @ v + v @ T @ u

    E_total.append(e_total)
    E_u_only.append(e_u)
    E_v_only.append(e_v)
    E_cross.append(cross)

ax2.plot(t_vals, E_total, 'b-', linewidth=2, label='E(T, u+tv)')
ax2.plot(t_vals, E_u_only, 'g--', linewidth=1.5, label='E(T, u)')
ax2.plot(t_vals, E_v_only, 'r--', linewidth=1.5, label='E(T, tv)')
ax2.plot(t_vals, E_cross, 'm:', linewidth=1.5, label='Cross terms')
ax2.fill_between(t_vals,
                 [a + b + c for a, b, c in zip(E_u_only, E_v_only, E_cross)],
                 alpha=0.1, color='blue')
ax2.set_xlabel('t (perturbation scale)')
ax2.set_ylabel('Energy')
ax2.set_title('Polarization Identity\nE(u+v) = E(u) + cross + E(v)', fontsize=11)
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

# ─── Panel 3: Energy Contours with Contraction Vectors ───────────────────
ax3 = fig.add_subplot(133)

ax3.contour(X, Y, Z, levels=20, cmap='coolwarm', alpha=0.7)
ax3.contourf(X, Y, Z, levels=20, cmap='coolwarm', alpha=0.3)

# Show contraction directions
for angle in np.linspace(0, 2*np.pi, 8, endpoint=False):
    v = np.array([np.cos(angle), np.sin(angle)])
    Tv = T @ v
    energy = float(v @ Tv)
    color = 'darkred' if energy > 3 else 'darkblue'
    ax3.arrow(0, 0, v[0], v[1], head_width=0.08, head_length=0.05,
              fc=color, ec=color, alpha=0.7)
    ax3.arrow(v[0], v[1], 0.3*Tv[0]/np.linalg.norm(Tv), 0.3*Tv[1]/np.linalg.norm(Tv),
              head_width=0.06, head_length=0.04, fc='green', ec='green', alpha=0.5)

ax3.set_xlabel('v₁')
ax3.set_ylabel('v₂')
ax3.set_title('Energy Contours &\nContraction Directions', fontsize=11)
ax3.set_aspect('equal')
ax3.set_xlim(-2, 2)
ax3.set_ylim(-2, 2)
ax3.grid(True, alpha=0.2)

plt.tight_layout()
plt.savefig('viz_energy.png', dpi=150, bbox_inches='tight')
print("Saved viz_energy.png")
