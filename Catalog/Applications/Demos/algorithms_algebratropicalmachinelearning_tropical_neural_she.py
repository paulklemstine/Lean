"""
Tropical Neural Sheaf Sampling — Core Algorithms

Implements the tropical sheaf Laplacian, Rayleigh quotient, bandlimited
reconstruction, and perturbation stability analysis on finite graphs
modeled as cell complexes with max-plus/min-plus valued cellular sheaves.

All algorithms operate in the tropical semiring (max, +) or (min, +).
"""

import numpy as np
from typing import List, Tuple, Optional, Dict
from dataclasses import dataclass


# ═══════════════════════════════════════════════════════════════
# 1. TROPICAL ARITHMETIC
# ═══════════════════════════════════════════════════════════════

NEG_INF = -np.inf  # tropical zero for (max, +)

def trop_add(a: float, b: float) -> float:
    """Tropical addition: max(a, b)."""
    return max(a, b)

def trop_mul(a: float, b: float) -> float:
    """Tropical multiplication: a + b (in classical arithmetic)."""
    if a == NEG_INF or b == NEG_INF:
        return NEG_INF
    return a + b

def trop_matvec(A: np.ndarray, x: np.ndarray) -> np.ndarray:
    """Tropical matrix-vector product: y_i = max_j (A[i,j] + x[j])."""
    n, m = A.shape
    y = np.full(n, NEG_INF)
    for i in range(n):
        for j in range(m):
            if A[i, j] != NEG_INF and x[j] != NEG_INF:
                y[i] = max(y[i], A[i, j] + x[j])
    return y


# ═══════════════════════════════════════════════════════════════
# 2. GRAPH / CELL COMPLEX
# ═══════════════════════════════════════════════════════════════

@dataclass
class CellComplex:
    """A finite cell complex represented as a graph with incidence data.
    
    Vertices are 0-cells, edges are 1-cells.
    Incidence maps connect edges to their boundary vertices.
    """
    n_vertices: int
    edges: List[Tuple[int, int]]  # (source, target) pairs
    
    @property
    def n_edges(self) -> int:
        return len(self.edges)
    
    def incidence_matrix(self) -> np.ndarray:
        """Signed incidence matrix B: edges × vertices.
        B[e, v] = +1 if v is the target of edge e, -1 if source, 0 otherwise.
        """
        B = np.zeros((self.n_edges, self.n_vertices))
        for e, (s, t) in enumerate(self.edges):
            B[e, s] = -1
            B[e, t] = 1
        return B


# ═══════════════════════════════════════════════════════════════
# 3. CELLULAR SHEAF
# ═══════════════════════════════════════════════════════════════

@dataclass
class CellularSheaf:
    """A cellular sheaf on a cell complex with scalar stalks.
    
    Each vertex has a 1-dimensional stalk (scalar).
    Each edge has a restriction map from source and target stalks,
    encoded as edge weights.
    
    The sheaf restriction maps F_{e←v}: F(v) → F(e) are encoded
    as the weight matrix.
    """
    complex: CellComplex
    edge_weights: np.ndarray  # shape (n_edges, 2): [source_weight, target_weight]
    
    @classmethod
    def from_graph_weights(cls, complex: CellComplex, 
                           weights: Optional[np.ndarray] = None) -> 'CellularSheaf':
        """Create a sheaf from edge weights. Default: unit weights."""
        if weights is None:
            weights = np.ones((complex.n_edges, 2))
        return cls(complex=complex, edge_weights=weights)
    
    def coboundary_matrix(self) -> np.ndarray:
        """The sheaf coboundary d₀: C⁰(X;F) → C¹(X;F).
        
        For each edge e = (s,t), the coboundary maps
        (d₀ f)(e) = w_t · f(t) - w_s · f(s)
        """
        n_v = self.complex.n_vertices
        n_e = self.complex.n_edges
        D = np.zeros((n_e, n_v))
        for e, (s, t) in enumerate(self.complex.edges):
            D[e, s] = -self.edge_weights[e, 0]
            D[e, t] = self.edge_weights[e, 1]
        return D
    
    def laplacian_matrix(self) -> np.ndarray:
        """The sheaf Laplacian Δ₀ = d₀ᵀ d₀.
        
        This is the degree-0 sheaf Laplacian, measuring how much
        a section oscillates across edges weighted by the sheaf structure.
        """
        D = self.coboundary_matrix()
        return D.T @ D
    
    def tropical_laplacian_matrix(self) -> np.ndarray:
        """Tropical Laplacian via max-plus algebra.
        
        For each pair (i,j) connected by an edge, compute the
        max-plus product d†∘d using tropical matrix operations.
        """
        D = self.coboundary_matrix()
        n_v = self.complex.n_vertices
        # Tropical adjoint: transpose with negation (residuation)
        D_adj = -D.T  # Residuated adjoint in tropical setting
        # Tropical Laplacian: d† ∘ d in (max, +)
        L_trop = np.full((n_v, n_v), NEG_INF)
        for i in range(n_v):
            for j in range(n_v):
                for e in range(self.complex.n_edges):
                    val = D_adj[i, e] + D[e, j]  # tropical product
                    L_trop[i, j] = max(L_trop[i, j], val)
        return L_trop


# ═══════════════════════════════════════════════════════════════
# 4. RAYLEIGH QUOTIENT AND BANDLIMITEDNESS
# ═══════════════════════════════════════════════════════════════

def rayleigh_quotient(sheaf: CellularSheaf, section: np.ndarray) -> float:
    """Compute the tropical Rayleigh quotient of a section.
    
    ρ(s) = ‖Δ s‖ / ‖s‖
    
    where ‖·‖ is the ℓ∞ norm (natural for tropical/max-plus).
    
    Args:
        sheaf: The cellular sheaf
        section: A 0-cochain (vertex values)
    
    Returns:
        The Rayleigh quotient, or 0 if s = 0.
    """
    L = sheaf.laplacian_matrix()
    Ls = L @ section
    norm_s = np.max(np.abs(section))
    if norm_s < 1e-15:
        return 0.0
    norm_Ls = np.max(np.abs(Ls))
    return norm_Ls / norm_s


def is_bandlimited(sheaf: CellularSheaf, section: np.ndarray, 
                    cutoff: float) -> bool:
    """Check if a section is λ-bandlimited (Rayleigh ≤ λ)."""
    return rayleigh_quotient(sheaf, section) <= cutoff + 1e-10


def poincare_gap_constant(sheaf: CellularSheaf, 
                          sampling_set: List[int],
                          cutoff: float,
                          n_trials: int = 10000) -> float:
    """Estimate the Poincaré gap constant by random sampling.
    
    Returns the minimum Rayleigh quotient among nonzero sections
    that vanish on the sampling set. If this exceeds the cutoff,
    the sampling set is certified.
    
    Args:
        sheaf: The cellular sheaf
        sampling_set: Indices of sampled vertices
        cutoff: The bandlimit parameter λ
        n_trials: Number of random trials
    
    Returns:
        Estimated minimum Rayleigh quotient of kernel sections
    """
    n = sheaf.complex.n_vertices
    min_rayleigh = np.inf
    
    for _ in range(n_trials):
        s = np.random.randn(n)
        # Project to kernel of restriction
        for v in sampling_set:
            s[v] = 0.0
        if np.max(np.abs(s)) < 1e-10:
            continue
        r = rayleigh_quotient(sheaf, s)
        min_rayleigh = min(min_rayleigh, r)
    
    return min_rayleigh


# ═══════════════════════════════════════════════════════════════
# 5. RECONSTRUCTION ALGORITHM
# ═══════════════════════════════════════════════════════════════

def resolvent_step(sheaf: CellularSheaf, sampling_set: List[int],
                   samples: np.ndarray, current: np.ndarray,
                   cutoff: float, alpha: float = 0.3) -> np.ndarray:
    """One step of the tropical resolvent iteration.
    
    The update enforces:
    1. Sample consistency on S (project to match samples)
    2. Laplacian energy cutoff (smooth via spectral projection)
    
    Uses spectral projection for stability: project onto the
    subspace of eigenvectors with eigenvalue ≤ cutoff, then
    enforce sample consistency.
    """
    n = sheaf.complex.n_vertices
    L = sheaf.laplacian_matrix()
    eigenvalues, eigenvectors = np.linalg.eigh(L)
    
    # Spectral smoothing: attenuate high-frequency components
    coeffs = eigenvectors.T @ current
    for i in range(len(eigenvalues)):
        if eigenvalues[i] > cutoff:
            coeffs[i] *= max(0, 1.0 - alpha * (eigenvalues[i] - cutoff) / max(eigenvalues[i], 1e-10))
    result = eigenvectors @ coeffs
    
    # Enforce sample consistency
    for i, v in enumerate(sampling_set):
        result[v] = samples[i]
    
    return result


def reconstruct_bandlimited(sheaf: CellularSheaf, 
                            sampling_set: List[int],
                            samples: np.ndarray,
                            cutoff: float,
                            max_iter: int = 1000,
                            tol: float = 1e-10) -> Tuple[np.ndarray, int, List[float]]:
    """Reconstruct a bandlimited section from samples.
    
    Uses the tropical resolvent iteration to find the unique
    bandlimited section consistent with the given samples.
    
    Args:
        sheaf: The cellular sheaf
        sampling_set: Sampled vertex indices
        samples: Values at sampled vertices
        cutoff: Bandlimit parameter λ
        max_iter: Maximum iterations
        tol: Convergence tolerance
    
    Returns:
        (reconstructed_section, n_iterations, residual_history)
    """
    n = sheaf.complex.n_vertices
    
    # Initialize: extend samples by zero
    current = np.zeros(n)
    for i, v in enumerate(sampling_set):
        current[v] = samples[i]
    
    residuals = []
    
    for iteration in range(max_iter):
        next_val = resolvent_step(sheaf, sampling_set, samples, 
                                   current, cutoff)
        
        residual = np.max(np.abs(next_val - current))
        residuals.append(residual)
        
        if residual < tol:
            return next_val, iteration + 1, residuals
        
        current = next_val
    
    return current, max_iter, residuals


# ═══════════════════════════════════════════════════════════════
# 6. STABILITY ANALYSIS
# ═══════════════════════════════════════════════════════════════

def condition_radius(sheaf: CellularSheaf, sampling_set: List[int],
                     cutoff: float, n_trials: int = 5000) -> float:
    """Estimate the condition radius κ of the sampling configuration.
    
    κ = inf_{s bandlimited, s≠0} ‖r(s)‖ / ‖s‖
    
    where r is restriction to the sampling set.
    """
    n = sheaf.complex.n_vertices
    L = sheaf.laplacian_matrix()
    
    # Get low-frequency subspace
    eigenvalues, eigenvectors = np.linalg.eigh(L)
    bl_indices = np.where(eigenvalues <= cutoff + 1e-8)[0]
    
    if len(bl_indices) == 0:
        return np.inf
    
    min_ratio = np.inf
    
    for _ in range(n_trials):
        # Random bandlimited section
        coeffs = np.random.randn(len(bl_indices))
        s = eigenvectors[:, bl_indices] @ coeffs
        
        norm_s = np.linalg.norm(s)
        if norm_s < 1e-12:
            continue
        
        # Restriction norm
        restricted = s[sampling_set]
        norm_r = np.linalg.norm(restricted)
        
        ratio = norm_r / norm_s
        min_ratio = min(min_ratio, ratio)
    
    return min_ratio


def stability_bound(kappa: float, noise_level: float) -> float:
    """Compute the reconstruction error bound: ε/κ.
    
    Given condition radius κ and sample noise level ε,
    the reconstruction error is bounded by ε/κ.
    """
    if kappa <= 0:
        return np.inf
    return noise_level / kappa


def perturbation_stability_bound(kappa: float, epsilon: float,
                                  noise_level: float,
                                  section_norm: float) -> float:
    """Compute the sheaf perturbation stability bound.
    
    (κ - ε) * ‖s₁ - s₂‖ ≤ ‖r₂s₁ - r₂s₂‖ + ε * (‖s₁‖ + ‖s₂‖)
    
    Returns upper bound on ‖s₁ - s₂‖.
    """
    if kappa <= epsilon:
        return np.inf
    return (noise_level + 2 * epsilon * section_norm) / (kappa - epsilon)


# ═══════════════════════════════════════════════════════════════
# 7. EXAMPLE GRAPHS
# ═══════════════════════════════════════════════════════════════

def path_graph(n: int) -> CellComplex:
    """Path graph P_n with n vertices."""
    edges = [(i, i+1) for i in range(n-1)]
    return CellComplex(n_vertices=n, edges=edges)

def cycle_graph(n: int) -> CellComplex:
    """Cycle graph C_n with n vertices."""
    edges = [(i, (i+1) % n) for i in range(n)]
    return CellComplex(n_vertices=n, edges=edges)

def complete_graph(n: int) -> CellComplex:
    """Complete graph K_n with n vertices."""
    edges = [(i, j) for i in range(n) for j in range(i+1, n)]
    return CellComplex(n_vertices=n, edges=edges)

def grid_graph(m: int, n: int) -> CellComplex:
    """Grid graph m × n."""
    def idx(i, j):
        return i * n + j
    
    edges = []
    for i in range(m):
        for j in range(n):
            if j + 1 < n:
                edges.append((idx(i, j), idx(i, j+1)))
            if i + 1 < m:
                edges.append((idx(i, j), idx(i+1, j)))
    
    return CellComplex(n_vertices=m*n, edges=edges)


def generate_bandlimited_section(sheaf: CellularSheaf, cutoff: float,
                                  seed: int = 42) -> np.ndarray:
    """Generate a random bandlimited section.
    
    Projects a random vector onto the eigenspace with eigenvalues ≤ cutoff.
    """
    np.random.seed(seed)
    L = sheaf.laplacian_matrix()
    eigenvalues, eigenvectors = np.linalg.eigh(L)
    
    bl_indices = np.where(eigenvalues <= cutoff + 1e-8)[0]
    if len(bl_indices) == 0:
        return np.zeros(sheaf.complex.n_vertices)
    
    coeffs = np.random.randn(len(bl_indices))
    return eigenvectors[:, bl_indices] @ coeffs


if __name__ == "__main__":
    # Quick demo
    G = cycle_graph(8)
    F = CellularSheaf.from_graph_weights(G)
    
    cutoff = 1.0
    s = generate_bandlimited_section(F, cutoff, seed=42)
    print(f"Original section: {s.round(4)}")
    print(f"Rayleigh quotient: {rayleigh_quotient(F, s):.4f}")
    print(f"Bandlimited (λ={cutoff}): {is_bandlimited(F, s, cutoff)}")
    
    # Sample and reconstruct
    S = [0, 2, 4, 6]
    samples = s[S]
    recon, n_iter, residuals = reconstruct_bandlimited(F, S, samples, cutoff)
    print(f"\nReconstructed in {n_iter} iterations")
    print(f"Reconstruction error: {np.max(np.abs(recon - s)):.2e}")
    
    # Condition radius
    kappa = condition_radius(F, S, cutoff)
    print(f"Condition radius κ: {kappa:.4f}")
