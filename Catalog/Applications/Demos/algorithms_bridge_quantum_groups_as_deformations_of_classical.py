#!/usr/bin/env python3
"""
Quantum Groups: Core Algorithms

Type-hinted implementations of the key mathematical constructions
from the quantum group U_q(sl₂) formalization.
"""

from typing import List, Tuple, Optional
import numpy as np


# ============================================================
# Algorithm 1: q-Calculus Engine
# ============================================================

def q_integer(q: float, n: int) -> float:
    """
    Compute the q-integer [n]_q.
    
    Algorithm: Direct formula (q^n - 1)/(q - 1) for q ≠ 1.
    Time complexity: O(log n) via fast exponentiation.
    
    Args:
        q: Deformation parameter (nonzero real)
        n: Non-negative integer
    Returns:
        The q-analog of n
    """
    if abs(q - 1.0) < 1e-15:
        return float(n)
    return (q**n - 1.0) / (q - 1.0)


def q_factorial(q: float, n: int) -> float:
    """
    Compute [n]_q! = ∏_{k=1}^{n} [k]_q.
    
    Time complexity: O(n log n) via iterated q-integers.
    """
    result = 1.0
    for k in range(1, n + 1):
        result *= q_integer(q, k)
    return result


def q_binomial(q: float, n: int, k: int) -> float:
    """
    Compute the Gaussian binomial coefficient [n choose k]_q.
    
    Uses the formula [n]_q! / ([k]_q! · [n-k]_q!).
    For numerical stability with large n, use the recurrence instead.
    """
    if k < 0 or k > n:
        return 0.0
    num = q_factorial(q, n)
    den = q_factorial(q, k) * q_factorial(q, n - k)
    if abs(den) < 1e-30:
        return float('inf')
    return num / den


# ============================================================
# Algorithm 2: U_q(sl₂) Representation Engine
# ============================================================

class QuantumSL2Rep:
    """
    A finite-dimensional representation of U_q(sl₂).
    
    For highest weight n, the module has dimension n+1 with basis {v_0, ..., v_n}.
    The generators act as:
        K · v_i = q^{n-2i} · v_i
        E · v_i = [n-i+1]_q · v_{i-1}  (i > 0)
        F · v_i = [i+1]_q · v_{i+1}    (i < n)
    """
    
    def __init__(self, q: float, n: int):
        """
        Args:
            q: Deformation parameter (nonzero)
            n: Highest weight (dimension = n+1)
        """
        assert q != 0, "q must be nonzero"
        assert n >= 0, "highest weight must be non-negative"
        self.q = q
        self.n = n
        self.dim = n + 1
    
    def K_matrix(self) -> np.ndarray:
        """The matrix of K in the weight basis."""
        diag = [self.q ** (self.n - 2*i) for i in range(self.dim)]
        return np.diag(diag)
    
    def E_matrix(self) -> np.ndarray:
        """The matrix of E (raising operator)."""
        mat = np.zeros((self.dim, self.dim))
        for i in range(1, self.dim):
            mat[i-1, i] = q_integer(self.q, self.n - i + 1)
        return mat
    
    def F_matrix(self) -> np.ndarray:
        """The matrix of F (lowering operator)."""
        mat = np.zeros((self.dim, self.dim))
        for i in range(self.dim - 1):
            mat[i+1, i] = q_integer(self.q, i + 1)
        return mat
    
    def verify_serre_relation(self) -> float:
        """
        Verify [E, F] = (K - K⁻¹)/(q - q⁻¹).
        Returns the Frobenius norm of the error.
        """
        E = self.E_matrix()
        F = self.F_matrix()
        K = self.K_matrix()
        
        commutator = E @ F - F @ E
        
        if abs(self.q - 1.0) < 1e-12:
            # Classical limit: [E, F] = H (diagonal with entries n-2i)
            H = np.diag([float(self.n - 2*i) for i in range(self.dim)])
            return np.linalg.norm(commutator - H)
        
        q_inv = 1.0 / self.q
        K_inv = np.diag([self.q ** (-(self.n - 2*i)) for i in range(self.dim)])
        expected = (K - K_inv) / (self.q - q_inv)
        
        return np.linalg.norm(commutator - expected)
    
    def quantum_dimension(self) -> float:
        """The quantum dimension [n+1]_q."""
        return q_integer(self.q, self.n + 1)
    
    def quantum_trace(self, f: np.ndarray) -> float:
        """
        Quantum trace: tr_q(f) = tr(K · f).
        Reduces to ordinary trace when q = 1.
        """
        K = self.K_matrix()
        return np.trace(K @ f)
    
    def casimir_value(self) -> float:
        """
        The value of the quantum Casimir on this representation.
        C_q = FE + (qK - q⁻¹K⁻¹)/(q² - q⁻²)
        Should be a scalar matrix.
        """
        E = self.E_matrix()
        F = self.F_matrix()
        K = self.K_matrix()
        
        FE = F @ E
        
        if abs(self.q - 1.0) < 1e-12:
            K_inv = np.eye(self.dim)
            return FE[0, 0] + float(self.n) / 2
        
        K_inv = np.diag([self.q ** (-(self.n - 2*i)) for i in range(self.dim)])
        q2 = self.q**2
        q2_inv = 1.0 / q2
        
        casimir = FE + (self.q * K - (1/self.q) * K_inv) / (q2 - q2_inv)
        return casimir[0, 0]


# ============================================================
# Algorithm 3: R-matrix and Yang-Baxter
# ============================================================

def r_matrix_fundamental(q: float) -> np.ndarray:
    """
    Compute the R-matrix for U_q(sl₂) on V₁ ⊗ V₁.
    
    R = q(E₀₀⊗E₀₀ + E₁₁⊗E₁₁) + E₀₁⊗E₁₀ + E₁₀⊗E₀₁ + (q-q⁻¹)E₀₀⊗E₁₁
    
    Returns: 4×4 numpy array
    """
    R = np.zeros((4, 4))
    R[0, 0] = q          # |00⟩ → q|00⟩
    R[3, 3] = q          # |11⟩ → q|11⟩
    R[1, 2] = 1          # |01⟩ → |10⟩
    R[2, 1] = 1          # |10⟩ → |01⟩
    R[2, 2] = q - 1/q    # |10⟩ → (q-q⁻¹)|10⟩
    return R


def verify_yang_baxter(q: float) -> Tuple[float, bool]:
    """
    Verify the Yang-Baxter equation R₁₂R₁₃R₂₃ = R₂₃R₁₃R₁₂.
    
    Returns: (error_norm, is_satisfied)
    """
    R = r_matrix_fundamental(q)
    I2 = np.eye(2)
    
    R12 = np.kron(R, I2)
    R23 = np.kron(I2, R)
    
    # R₁₃ via permutation
    P = np.zeros((8, 8))
    for a in range(2):
        for b in range(2):
            for c in range(2):
                P[a*4 + b*2 + c, a*4 + c*2 + b] = 1
    R13 = P @ R23 @ P
    
    LHS = R12 @ R13 @ R23
    RHS = R23 @ R13 @ R12
    
    err = np.linalg.norm(LHS - RHS)
    return err, err < 1e-10


# ============================================================
# Algorithm 4: Tensor Product Decomposition
# ============================================================

def tensor_decomposition(m: int, n: int) -> List[Tuple[int, int]]:
    """
    Decompose V_m ⊗ V_n into irreducibles.
    
    By the Clebsch-Gordan theorem (quantum or classical):
    V_m ⊗ V_n ≅ ⊕_{k=|m-n|, step 2}^{m+n} V_k
    
    Returns: List of (highest_weight, multiplicity) pairs
    """
    result = []
    k_min = abs(m - n)
    for k in range(k_min, m + n + 1, 2):
        result.append((k, 1))
    return result


def verify_clebsch_gordan_dimension(m: int, n: int, q: float) -> Tuple[float, float]:
    """
    Verify dim_q(V_m ⊗ V_n) = ∑ mult · dim_q(V_k).
    
    Returns: (lhs, rhs) which should be equal
    """
    decomp = tensor_decomposition(m, n)
    lhs = q_integer(q, m + 1) * q_integer(q, n + 1)
    rhs = sum(mult * q_integer(q, k + 1) for k, mult in decomp)
    return lhs, rhs


# ============================================================
# Algorithm 5: Jones Polynomial via Quantum Trace
# ============================================================

def jones_polynomial_unknot(q: float, n: int) -> float:
    """
    The Jones polynomial of the unknot colored by V_n.
    This equals the quantum dimension [n+1]_q.
    """
    return q_integer(q, n + 1)


def jones_polynomial_trefoil_fundamental(q: float) -> float:
    """
    Jones polynomial of the trefoil knot in the fundamental representation.
    J(trefoil; q) = -q^{-4} + q^{-3} + q^{-1}
    (using the variable convention where q = t^{1/2})
    """
    t = q**2  # standard variable
    return -t**(-4) + t**(-3) + t**(-1)


if __name__ == "__main__":
    print("=== Quantum SL₂ Representation Test ===\n")
    
    for q in [0.5, 1.0, 2.0]:
        rep = QuantumSL2Rep(q, 3)
        err = rep.verify_serre_relation()
        qdim = rep.quantum_dimension()
        print(f"q={q}: V_3, dim_q = {qdim:.4f}, Serre error = {err:.2e}")
    
    print("\n=== Yang-Baxter Verification ===\n")
    for q in [0.5, 1.0, 1.5, 2.0, 3.0]:
        err, ok = verify_yang_baxter(q)
        print(f"q={q}: error = {err:.2e} {'✓' if ok else '✗'}")
    
    print("\n=== Tensor Decomposition ===\n")
    for m, n in [(1, 1), (2, 1), (2, 2), (3, 2)]:
        decomp = tensor_decomposition(m, n)
        parts = " ⊕ ".join(f"V_{k}" for k, _ in decomp)
        print(f"V_{m} ⊗ V_{n} = {parts}")
        
        for q in [1.0, 2.0]:
            lhs, rhs = verify_clebsch_gordan_dimension(m, n, q)
            print(f"  q={q}: dim_q = {lhs:.4f} = {rhs:.4f} {'✓' if abs(lhs-rhs)<1e-10 else '✗'}")
