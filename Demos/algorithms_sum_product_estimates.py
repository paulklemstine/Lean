"""
Algorithms for Berggren Semigroup Product Growth and Spectral Analysis

Implements the core algorithms from the research paper:
- Berggren tree generation
- K₃ spectral contraction
- L² flattening computation
- Multiplicative energy estimation
- Mixing time computation
"""

import numpy as np
from typing import List, Tuple, Optional

# ======================================================================
# Core Data Structures
# ======================================================================

# Berggren generator matrices
B1 = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]], dtype=int)
B2 = np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]], dtype=int)
B3 = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]], dtype=int)
GENERATORS = [B1, B2, B3]

# Lorentz form Q = diag(1,1,-1)
Q_LORENTZ = np.diag([1, 1, -1])

# K₃ transition matrix
T_K3 = np.array([[0, 0.5, 0.5],
                  [0.5, 0, 0.5],
                  [0.5, 0.5, 0]], dtype=float)


def lorentz_form(v: np.ndarray) -> int:
    """Compute the Lorentz form Q(v) = v₀² + v₁² - v₂²."""
    return int(v[0]**2 + v[1]**2 - v[2]**2)


def generate_berggren_tree(depth: int) -> List[np.ndarray]:
    """
    Generate all primitive Pythagorean triples up to given depth.

    Args:
        depth: Maximum depth in the Berggren tree

    Returns:
        List of integer vectors (a, b, c) with a² + b² = c²

    Time complexity: O(3^depth)
    Space complexity: O(3^depth)
    """
    triples = [np.array([3, 4, 5])]
    current = [np.array([3, 4, 5])]
    for _ in range(depth):
        next_level = []
        for v in current:
            for B in GENERATORS:
                child = B @ v
                next_level.append(child)
                triples.append(child)
        current = next_level
    return triples


def berggren_mod_q(q: int) -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
    """
    Compute Berggren generators modulo q.

    Args:
        q: Modulus (positive integer ≥ 2)

    Returns:
        Tuple of (B₁ mod q, B₂ mod q, B₃ mod q)
    """
    return B1 % q, B2 % q, B3 % q


def verify_lorentz_preservation(B: np.ndarray, q: Optional[int] = None) -> bool:
    """
    Verify that matrix B preserves the Lorentz form (mod q if given).

    Args:
        B: 3×3 integer matrix
        q: Optional modulus

    Returns:
        True if BᵀQB = Q (mod q)
    """
    result = B.T @ Q_LORENTZ @ B
    if q is not None:
        return np.allclose(result % q, Q_LORENTZ % q)
    return np.allclose(result, Q_LORENTZ)


# ======================================================================
# Spectral Analysis
# ======================================================================

def l2_norm_sq(f: np.ndarray) -> float:
    """Compute ‖f‖₂² = ∑ f(x)²."""
    return float(np.sum(f**2))


def spectral_contraction(f: np.ndarray, k: int) -> float:
    """
    Compute ‖T^k f‖₂² for the K₃ transition operator.

    Args:
        f: Function on {0,1,2} (3-vector)
        k: Number of iterations

    Returns:
        L² norm squared after k iterations

    Time complexity: O(k) (using eigenvalue decomposition)
    """
    # For mean-zero f, T^k f = (-1/2)^k f
    mean = np.mean(f)
    f_centered = f - mean
    return l2_norm_sq((-0.5)**k * f_centered) + l2_norm_sq(np.full(3, mean))


def mixing_time(B: float, epsilon: float) -> int:
    """
    Compute the mixing time: smallest t such that ‖T^t(f-μ)‖₂² < ε.

    Args:
        B: Bound on |f(x)|
        epsilon: Target accuracy

    Returns:
        Number of steps needed

    The bound is: (1/4)^t · 12B² < ε, so t > log(12B²/ε) / log(4)
    """
    if epsilon <= 0 or B <= 0:
        raise ValueError("B and epsilon must be positive")
    import math
    return int(math.ceil(math.log(12 * B**2 / epsilon) / math.log(4)))


def multiplicative_energy_estimate(elements: List, group_op) -> int:
    """
    Estimate the multiplicative energy E(A) of a finite set A.

    E(A) = |{(a₁,a₂,b₁,b₂) ∈ A⁴ : a₁·b₁ = a₂·b₂}|

    Args:
        elements: List of group elements
        group_op: Binary operation (a, b) -> a*b

    Returns:
        Multiplicative energy

    Time complexity: O(|A|⁴) in the worst case
    """
    n = len(elements)
    products = {}
    for a in elements:
        for b in elements:
            prod = group_op(a, b)
            key = tuple(prod) if hasattr(prod, '__iter__') else prod
            products[key] = products.get(key, 0) + 1

    # E(A) = ∑_g r(g)² where r(g) = |{(a,b) : a·b = g}|
    energy = sum(count**2 for count in products.values())
    return energy


def collision_probability(distribution: np.ndarray) -> float:
    """
    Compute the collision probability (Rényi-2 entropy measure).

    Args:
        distribution: Probability mass function

    Returns:
        ∑ p(x)² (the collision probability)
    """
    return float(np.sum(distribution**2))


# ======================================================================
# Fiber Operator
# ======================================================================

def fiber_operator(f: np.ndarray, alpha_size: int) -> np.ndarray:
    """
    Apply the fiber sibling operator on α × Fin 3.

    Args:
        f: Function on α × {0,1,2}, shape (alpha_size, 3)
        alpha_size: Size of the base space α

    Returns:
        Result of applying the fiber operator
    """
    result = np.zeros_like(f)
    for a in range(alpha_size):
        for j in range(3):
            result[a, j] = sum(T_K3[j, k] * f[a, k] for k in range(3))
    return result


def fiber_iterate(f: np.ndarray, alpha_size: int, k: int) -> np.ndarray:
    """Apply the fiber operator k times."""
    result = f.copy()
    for _ in range(k):
        result = fiber_operator(result, alpha_size)
    return result


# ======================================================================
# Example Usage
# ======================================================================

if __name__ == "__main__":
    print("=== Berggren Semigroup Algorithms ===\n")

    # Generate triples
    triples = generate_berggren_tree(3)
    print(f"Generated {len(triples)} primitive Pythagorean triples (depth ≤ 3)")

    # Verify Lorentz preservation
    for name, B in [("B₁", B1), ("B₂", B2), ("B₃", B3)]:
        print(f"{name} preserves Lorentz form: {verify_lorentz_preservation(B)}")

    # Mixing time
    for eps in [0.01, 0.001, 0.0001]:
        t = mixing_time(1.0, eps)
        print(f"Mixing time for ε={eps}: t = {t} steps")

    # Fiber operator demo
    alpha_size = 4
    f = np.random.randn(alpha_size, 3)
    # Center fiberwise
    f -= f.mean(axis=1, keepdims=True)
    print(f"\nFiber operator contraction (α-size={alpha_size}):")
    for k in range(6):
        fk = fiber_iterate(f, alpha_size, k)
        ratio = l2_norm_sq(fk.flatten()) / l2_norm_sq(f.flatten())
        print(f"  k={k}: ‖T^k f‖₂² / ‖f‖₂² = {ratio:.8f}, "
              f"expected (1/4)^{k} = {0.25**k:.8f}")
