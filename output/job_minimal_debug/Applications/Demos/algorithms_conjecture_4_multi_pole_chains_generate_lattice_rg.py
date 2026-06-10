"""
algorithms.py — Core algorithms for multi-pole chain RG systems.

Implements the mathematical objects formalized in Lean:
- PoleRGSystem: compositional transfer systems with cocycle law
- Chain transfer computation and endpoint telescoping
- Block increment (coarse-grained observable) with semigroup law
- Matrix cocycle model with transfer matrix products
- 1D Ising transfer matrix blocking

All algorithms are documented with complexity analysis and correspond
directly to the formally verified theorems.
"""

import numpy as np
from typing import List, Tuple, Callable, Optional
from dataclasses import dataclass


# ============================================================
# Core Abstract Framework
# ============================================================

@dataclass
class PoleRGSystem:
    """A compositional pole-transfer system.

    F(a, b) maps state space to itself, satisfying:
      - Cocycle law: F(b,c) ∘ F(a,b) = F(a,c)
      - Identity law: F(a,a) = id

    In the implementation, F takes two pole values and returns
    a callable (state → state).

    Time complexity: O(1) per transfer map evaluation.
    Space complexity: O(1) per map.
    """
    F: Callable  # (a, b) -> (x -> x')

    def chain_transfer(self, poles: List[float]) -> Callable:
        """Compose transfer maps along a chain of poles.

        For poles [a₀, a₁, ..., aₙ], computes F(aₙ₋₁,aₙ) ∘ ... ∘ F(a₀,a₁).

        By the telescoping theorem (chainTransfer_eq_endpoint), this equals
        F(a₀, aₙ) — all intermediate poles cancel.

        Args:
            poles: List of pole values, length ≥ 2.

        Returns:
            Composed transfer function.

        Time complexity: O(n) where n = len(poles).
        Space complexity: O(1) (function composition is lazy).
        """
        if len(poles) < 2:
            return lambda x: x

        result = lambda x: x
        for i in range(len(poles) - 1):
            a, b = poles[i], poles[i + 1]
            f = self.F(a, b)
            prev = result
            result = lambda x, f=f, prev=prev: f(prev(x))
        return result

    def endpoint_transfer(self, a: float, b: float) -> Callable:
        """Direct endpoint transfer (should equal chain_transfer for any
        intermediate pole sequence by the cocycle law)."""
        return self.F(a, b)


def additive_pole_rg(phi: Callable) -> PoleRGSystem:
    """Construct an additive (affine) pole RG system.

    F(a, b)(x) = x + φ(b) - φ(a)

    This is the simplest nontrivial realization. The cocycle law holds
    because (φ(c) - φ(b)) + (φ(b) - φ(a)) = φ(c) - φ(a).

    Args:
        phi: Potential function α → ℝ.

    Returns:
        PoleRGSystem with additive transfer maps.
    """
    def F(a, b):
        shift = phi(b) - phi(a)
        return lambda x: x + shift
    return PoleRGSystem(F=F)


# ============================================================
# Block Increment Observable
# ============================================================

def block_increment(phi: Callable, poles: List[float]) -> float:
    """Compute the block increment observable.

    blockIncrement(φ, [a₀, ..., aₙ]) = φ(aₙ) - φ(a₀)

    This is the coarse-grained observable that exhibits additive
    semigroup structure under block concatenation.

    Args:
        phi: Potential function.
        poles: List of poles, length ≥ 2.

    Returns:
        φ(last) - φ(first).

    Time complexity: O(1).
    """
    if len(poles) < 2:
        return 0.0
    return phi(poles[-1]) - phi(poles[0])


def verify_semigroup_law(phi: Callable, l1: List[float], l2: List[float]) -> Tuple[float, float, float]:
    """Verify the block increment semigroup law (blockIncrement_append).

    For matching blocks (last of l1 = first of l2):
      blockIncrement(l1 ++ l2.tail) = blockIncrement(l1) + blockIncrement(l2)

    Args:
        phi: Potential function.
        l1: First block (length ≥ 2).
        l2: Second block (length ≥ 2), with l2[0] = l1[-1].

    Returns:
        Tuple of (lhs, rhs, error) where error should be ~0.
    """
    inc1 = block_increment(phi, l1)
    inc2 = block_increment(phi, l2)
    # Concatenate at matching point
    concatenated = l1 + l2[1:]
    inc_total = block_increment(phi, concatenated)
    return inc_total, inc1 + inc2, abs(inc_total - (inc1 + inc2))


# ============================================================
# Matrix Cocycle Model
# ============================================================

@dataclass
class MatrixCocycle:
    """A matrix cocycle system for transfer matrix models.

    M(a, b) is an n×n matrix satisfying:
      - Cocycle law: M(a,c) = M(b,c) @ M(a,b)
      - Identity: M(a,a) = I

    This models 1D statistical mechanical systems where the partition
    function is computed via transfer matrix products.
    """
    M: Callable  # (a, b) -> np.ndarray

    def chain_matrix(self, poles: List[float]) -> np.ndarray:
        """Compute the chain product of matrices along poles.

        By chainMatrix_eq_endpoint, this equals M(poles[0], poles[-1]).

        Args:
            poles: List of pole values, length ≥ 2.

        Returns:
            Product matrix.

        Time complexity: O(n * d³) where n = len(poles), d = matrix dim.
        Space complexity: O(d²).
        """
        if len(poles) < 2:
            return np.eye(2)

        result = np.eye(self.M(poles[0], poles[1]).shape[0])
        for i in range(len(poles) - 1):
            result = self.M(poles[i], poles[i + 1]) @ result
        # Note: we accumulate left-to-right: M(n-1,n) @ ... @ M(0,1)
        return result

    def endpoint_matrix(self, a: float, b: float) -> np.ndarray:
        """Direct endpoint matrix (should match chain_matrix by cocycle law)."""
        return self.M(a, b)


def additive_matrix_cocycle(phi: Callable) -> MatrixCocycle:
    """Construct an additive matrix cocycle from a potential.

    M(a, b) = [[1, φ(b) - φ(a)], [0, 1]]

    The (0,1) entry records the block increment (additiveMatrixCocycle_01_eq_blockIncrement).

    Args:
        phi: Potential function.

    Returns:
        MatrixCocycle with upper triangular translation matrices.
    """
    def M(a, b):
        d = phi(b) - phi(a)
        return np.array([[1.0, d], [0.0, 1.0]])
    return MatrixCocycle(M=M)


# ============================================================
# 1D Ising Transfer Matrix Model
# ============================================================

def ising_transfer_matrix(J: float, h: float) -> np.ndarray:
    """Compute the 2×2 transfer matrix for the 1D Ising model.

    T(J, h) = [[exp(J + h), exp(-J)],
               [exp(-J),    exp(J - h)]]

    For a chain of N spins with couplings J_i and fields h_i,
    the partition function is Z = Tr(T_N @ ... @ T_1).

    Args:
        J: Coupling constant.
        h: External field.

    Returns:
        2×2 transfer matrix.

    Time complexity: O(1).
    """
    return np.array([
        [np.exp(J + h), np.exp(-J)],
        [np.exp(-J), np.exp(J - h)]
    ])


def ising_partition_function(couplings: List[Tuple[float, float]],
                              periodic: bool = True) -> float:
    """Compute the partition function for a 1D Ising chain.

    Z = Tr(T_N @ ... @ T_1)  for periodic boundary conditions
    Z = sum_{s1,sN} (T_N @ ... @ T_1)_{s1,sN}  for open BC

    Args:
        couplings: List of (J_i, h_i) pairs.
        periodic: Whether to use periodic boundary conditions.

    Returns:
        Partition function value.

    Time complexity: O(n) where n = number of bonds.
    Space complexity: O(1) (just 2×2 matrices).
    """
    if not couplings:
        return 2.0  # Single spin

    product = np.eye(2)
    for J, h in couplings:
        product = ising_transfer_matrix(J, h) @ product

    if periodic:
        return np.trace(product)
    else:
        return np.sum(product)


def ising_block_decimation(couplings: List[Tuple[float, float]],
                            block_size: int) -> List[np.ndarray]:
    """Block-decimate an Ising chain by grouping transfer matrices.

    Groups consecutive transfer matrices into blocks of size `block_size`
    and computes each block product. This is the transfer matrix analog
    of the block increment semigroup law.

    Args:
        couplings: List of (J_i, h_i) pairs.
        block_size: Number of bonds per block.

    Returns:
        List of block product matrices.

    Time complexity: O(n) overall.
    """
    blocks = []
    for i in range(0, len(couplings), block_size):
        chunk = couplings[i:i + block_size]
        product = np.eye(2)
        for J, h in chunk:
            product = ising_transfer_matrix(J, h) @ product
        blocks.append(product)
    return blocks


def effective_coupling_from_matrix(T: np.ndarray) -> Tuple[float, float]:
    """Extract effective Ising coupling (J_eff, h_eff) from a transfer matrix.

    Given a 2×2 positive matrix T, find J_eff, h_eff such that
    T is proportional to the Ising transfer matrix T(J_eff, h_eff).

    This is the renormalization map: blocking induces flow in coupling space.

    Args:
        T: 2×2 transfer matrix (all entries positive).

    Returns:
        (J_eff, h_eff) effective couplings.

    Algorithm:
        From T = c * [[exp(J+h), exp(-J)], [exp(-J), exp(J-h)]]:
        - exp(-2J) = T[0,1]*T[1,0] / (T[0,0]*T[1,1])
        - exp(2h) = T[0,0] / T[1,1]
        - J = -0.5 * ln(T[0,1]*T[1,0]/(T[0,0]*T[1,1]))
        - h = 0.5 * ln(T[0,0]/T[1,1])
    """
    eps = 1e-15
    T = np.abs(T) + eps  # Ensure positivity

    J_eff = -0.5 * np.log(T[0, 1] * T[1, 0] / (T[0, 0] * T[1, 1]))
    h_eff = 0.5 * np.log(T[0, 0] / T[1, 1])

    return J_eff, h_eff


def free_energy_density(couplings: List[Tuple[float, float]]) -> float:
    """Compute the free energy density f = -(1/N) ln Z.

    This is the intensive observable that has a well-defined thermodynamic
    limit and exhibits scaling under RG blocking.

    Args:
        couplings: List of (J_i, h_i) pairs.

    Returns:
        Free energy density.
    """
    N = len(couplings)
    if N == 0:
        return 0.0
    Z = ising_partition_function(couplings, periodic=True)
    return -np.log(max(Z, 1e-300)) / N


# ============================================================
# Verification Utilities
# ============================================================

def verify_cocycle_law(system: PoleRGSystem, a: float, b: float, c: float,
                       test_points: List[float]) -> float:
    """Verify F(b,c) ∘ F(a,b) = F(a,c) numerically.

    Returns maximum absolute error over test points.
    """
    max_err = 0.0
    for x in test_points:
        lhs = system.F(b, c)(system.F(a, b)(x))
        rhs = system.F(a, c)(x)
        max_err = max(max_err, abs(lhs - rhs))
    return max_err


def verify_chain_telescoping(system: PoleRGSystem, poles: List[float],
                              test_points: List[float]) -> float:
    """Verify chain transfer equals endpoint transfer numerically.

    Returns maximum absolute error over test points.
    """
    chain_fn = system.chain_transfer(poles)
    endpoint_fn = system.endpoint_transfer(poles[0], poles[-1])
    max_err = 0.0
    for x in test_points:
        max_err = max(max_err, abs(chain_fn(x) - endpoint_fn(x)))
    return max_err


def verify_periodic_identity(system: PoleRGSystem, poles: List[float],
                              test_points: List[float]) -> float:
    """Verify periodic chain transfer is identity.

    Poles should satisfy poles[0] == poles[-1].
    Returns maximum |chain(x) - x| over test points.
    """
    chain_fn = system.chain_transfer(poles)
    max_err = 0.0
    for x in test_points:
        max_err = max(max_err, abs(chain_fn(x) - x))
    return max_err


if __name__ == "__main__":
    print("=" * 60)
    print("Algorithm Demonstrations")
    print("=" * 60)

    # 1. Additive pole RG system
    phi = lambda x: x ** 2
    system = additive_pole_rg(phi)

    poles = [1.0, 2.0, 3.0, 4.0, 5.0]
    test_pts = [0.0, 1.0, -1.0, 3.14]

    print("\n--- Additive Pole RG System ---")
    print(f"φ(x) = x², poles = {poles}")
    err = verify_chain_telescoping(system, poles, test_pts)
    print(f"Chain telescoping error: {err:.2e}")
    err = verify_cocycle_law(system, 1.0, 3.0, 5.0, test_pts)
    print(f"Cocycle law error: {err:.2e}")

    periodic_poles = [1.0, 2.0, 3.0, 4.0, 1.0]
    err = verify_periodic_identity(system, periodic_poles, test_pts)
    print(f"Periodic identity error: {err:.2e}")

    # 2. Block increment semigroup law
    print("\n--- Block Increment Semigroup Law ---")
    l1 = [1.0, 2.0, 3.0]
    l2 = [3.0, 4.0, 5.0]
    total, sum_parts, err = verify_semigroup_law(phi, l1, l2)
    print(f"l₁ = {l1}, l₂ = {l2}")
    print(f"blockIncrement(l₁++l₂.tail) = {total:.4f}")
    print(f"blockIncrement(l₁) + blockIncrement(l₂) = {sum_parts:.4f}")
    print(f"Error: {err:.2e}")

    # 3. Ising transfer matrix
    print("\n--- 1D Ising Transfer Matrix ---")
    J, h = 0.5, 0.1
    couplings = [(J, h)] * 10
    Z = ising_partition_function(couplings)
    f = free_energy_density(couplings)
    print(f"N=10, J={J}, h={h}")
    print(f"Partition function Z = {Z:.6f}")
    print(f"Free energy density f = {f:.6f}")

    # Block decimation
    blocks = ising_block_decimation(couplings, block_size=2)
    Z_blocked = np.trace(np.linalg.multi_dot(blocks))
    print(f"Z from block-2 decimation: {Z_blocked:.6f}")
    print(f"Match: {abs(Z - Z_blocked) < 1e-10}")

    # Effective couplings under blocking
    print("\n--- RG Flow of Effective Couplings ---")
    for k in [1, 2, 5, 10]:
        block_mats = ising_block_decimation([(J, h)] * k, block_size=k)
        J_eff, h_eff = effective_coupling_from_matrix(block_mats[0])
        print(f"Block size {k:2d}: J_eff = {J_eff:.4f}, h_eff = {h_eff:.4f}")
