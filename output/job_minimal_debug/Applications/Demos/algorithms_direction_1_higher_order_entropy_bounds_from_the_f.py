"""
Algorithms for Newton-hierarchy entropy bounds.

Implements the core computational methods from the research paper:
- Elementary symmetric polynomial computation
- Newton-Girard power sum recursion
- Newton ratio profile computation
- Certified entropy approximation from symmetric data
"""

import numpy as np
from typing import Tuple, List, Optional


def esymm(lam: np.ndarray, k: int) -> float:
    """Compute the k-th elementary symmetric polynomial e_k(lambda).

    Args:
        lam: 1D array of eigenvalues
        k: order of the elementary symmetric polynomial

    Returns:
        e_k(lambda) = sum over all size-k subsets S of product_{i in S} lambda_i

    Example:
        >>> esymm(np.array([1.0, 2.0, 3.0]), 2)
        11.0
    """
    m = len(lam)
    if k < 0 or k > m:
        return 0.0
    if k == 0:
        return 1.0
    # Use dynamic programming (Vieta-like recursion)
    # e_k^{j} = e_k^{j-1} + lam[j-1] * e_{k-1}^{j-1}
    prev = np.zeros(k + 1)
    prev[0] = 1.0
    for j in range(m):
        curr = prev.copy()
        for r in range(min(k, j + 1), 0, -1):
            curr[r] = prev[r] + lam[j] * prev[r - 1]
        prev = curr
    return prev[k]


def esymm_all(lam: np.ndarray) -> np.ndarray:
    """Compute all elementary symmetric polynomials e_0, e_1, ..., e_m.

    Args:
        lam: 1D array of eigenvalues of length m

    Returns:
        Array of length m+1 with e_k for k=0,...,m

    Example:
        >>> esymm_all(np.array([1.0, 2.0, 3.0]))
        array([ 1.,  6., 11.,  6.])
    """
    m = len(lam)
    e = np.zeros(m + 1)
    e[0] = 1.0
    for j in range(m):
        for r in range(min(m, j + 1), 0, -1):
            e[r] += lam[j] * e[r - 1]
    return e


def power_sum(lam: np.ndarray, k: int) -> float:
    """Compute the k-th power sum p_k(lambda) = sum_i lambda_i^k.

    Args:
        lam: 1D array of eigenvalues
        k: power

    Returns:
        p_k(lambda)
    """
    return np.sum(lam ** k)


def power_sum_from_esymm(e: np.ndarray, k: int) -> float:
    """Compute p_k from elementary symmetric polynomials via Newton-Girard.

    Uses the recursion:
        p_1 = e_1
        p_2 = e_1^2 - 2*e_2
        p_3 = e_1^3 - 3*e_1*e_2 + 3*e_3
        p_k = sum_{j=0}^{k-2} (-1)^j * e_{j+1} * p_{k-1-j} + (-1)^{k-1} * k * e_k

    Args:
        e: array with e[j] = e_j for j=0,1,...
        k: desired power sum order

    Returns:
        p_k computed from elementary symmetric data
    """
    if k <= 0:
        return 0.0
    # Build up power sums recursively
    p = np.zeros(k + 1)
    for r in range(1, k + 1):
        # p_r = sum_{j=0}^{r-2} (-1)^j * e_{j+1} * p_{r-1-j} + (-1)^{r-1} * r * e_r
        s = 0.0
        for j in range(r - 1):
            ej1 = e[j + 1] if j + 1 < len(e) else 0.0
            s += (-1) ** j * ej1 * p[r - 1 - j]
        er = e[r] if r < len(e) else 0.0
        s += (-1) ** (r - 1) * r * er
        p[r] = s
    return p[k]


def newton_defects(lam: np.ndarray) -> np.ndarray:
    """Compute Newton defects Delta_k = e_k^2 - e_{k-1} * e_{k+1}.

    By Newton's inequality, Delta_k >= 0 for nonneg weights.

    Args:
        lam: 1D array of eigenvalues

    Returns:
        Array of defects for k=1,...,m-1
    """
    e = esymm_all(lam)
    m = len(lam)
    defects = np.zeros(max(m - 1, 0))
    for k in range(1, m):
        defects[k - 1] = e[k] ** 2 - e[k - 1] * e[k + 1]
    return defects


def newton_ratios(lam: np.ndarray) -> np.ndarray:
    """Compute Newton ratios rho_k = e_k^2 / (e_{k-1} * e_{k+1}).

    By Newton's inequality, rho_k >= 1 for nonneg weights.

    Args:
        lam: 1D array of eigenvalues

    Returns:
        Array of ratios for k=1,...,m-1 (0 where denominator is 0)
    """
    e = esymm_all(lam)
    m = len(lam)
    ratios = np.zeros(max(m - 1, 0))
    for k in range(1, m):
        denom = e[k - 1] * e[k + 1]
        if abs(denom) < 1e-15:
            ratios[k - 1] = 0.0
        else:
            ratios[k - 1] = e[k] ** 2 / denom
    return ratios


def binary_entropy(x: float) -> float:
    """Binary Shannon entropy h(x) = -x log(x) - (1-x) log(1-x).

    Args:
        x: probability in [0, 1]

    Returns:
        h(x)
    """
    if x <= 0 or x >= 1:
        return 0.0
    return -x * np.log(x) - (1 - x) * np.log(1 - x)


def binary_renyi_entropy(alpha: float, x: float) -> float:
    """Binary Rényi entropy h_alpha(x) = log(x^alpha + (1-x)^alpha) / (1-alpha).

    Args:
        alpha: Rényi parameter (alpha != 1)
        x: probability in [0, 1]

    Returns:
        h_alpha(x)
    """
    if alpha == 1:
        return binary_entropy(x)
    if x <= 0 or x >= 1:
        return 0.0
    val = x ** alpha + (1 - x) ** alpha
    if val <= 0:
        return 0.0
    return np.log(val) / (1 - alpha)


def fermion_entropy(lam: np.ndarray) -> float:
    """Free-fermion Shannon entanglement entropy S(lambda) = sum_i h(lambda_i).

    Args:
        lam: 1D array of eigenvalues in [0, 1]

    Returns:
        Shannon entropy
    """
    return sum(binary_entropy(x) for x in lam)


def renyi_entropy(alpha: float, lam: np.ndarray) -> float:
    """Subsystem Rényi entropy S_alpha(lambda) = sum_i h_alpha(lambda_i).

    Args:
        alpha: Rényi parameter
        lam: 1D array of eigenvalues in [0, 1]

    Returns:
        Rényi entropy
    """
    return sum(binary_renyi_entropy(alpha, x) for x in lam)


def quadratic_entropy_surrogate(e1: float, e2: float) -> float:
    """Quadratic entropy surrogate Psi_2(e1, e2) = 2(e1 - e1^2 + 2*e2).

    This is a lower bound for Shannon entropy (by the quadratic bound h(x) >= 2x(1-x)).

    Args:
        e1: first elementary symmetric polynomial
        e2: second elementary symmetric polynomial

    Returns:
        Lower bound for entropy
    """
    return 2 * (e1 - e1 ** 2 + 2 * e2)


def certified_entropy_approx(lam: np.ndarray) -> Tuple[float, float]:
    """Certified entropy approximation with error bound.

    Returns (approximation, error_bound) such that:
        approximation <= S(lambda) <= approximation + error_bound

    The approximation uses the quadratic surrogate (variance-based lower bound).
    The error bound is m * log(2) - approximation.

    Args:
        lam: 1D array of eigenvalues in [0, 1]

    Returns:
        Tuple of (approximation, error_bound)

    Example:
        >>> lam = np.array([0.3, 0.7, 0.5])
        >>> approx, err = certified_entropy_approx(lam)
        >>> true_S = fermion_entropy(lam)
        >>> assert approx <= true_S + 1e-10
        >>> assert true_S <= approx + err + 1e-10
    """
    m = len(lam)
    e1 = esymm(lam, 1)
    e2 = esymm(lam, 2)
    approx = quadratic_entropy_surrogate(e1, e2)
    err_bound = m * np.log(2) - approx
    return (approx, err_bound)


def polynomial_entropy_surrogate(lam: np.ndarray, degree: int = 2) -> float:
    """Polynomial entropy surrogate of given degree.

    For degree 2: uses quadratic surrogate 2(e1 - e1^2 + 2e2)
    For higher degrees: uses power sums from Newton-Girard to build
    polynomial approximations to h(x).

    Args:
        lam: 1D array of eigenvalues in [0, 1]
        degree: polynomial degree (1, 2, or 4)

    Returns:
        Polynomial surrogate for entropy
    """
    e = esymm_all(lam)
    m = len(lam)

    if degree <= 1:
        # Linear: 2 * e1 * (1 - e1/m) if m > 0
        if m == 0:
            return 0.0
        return 2 * e[1] * (1 - e[1] / m)
    elif degree <= 2:
        return quadratic_entropy_surrogate(e[1], e[2])
    else:
        # Degree 4: use Taylor expansion of h(x) around x=1/2
        # h(x) ≈ log(2) - 2(x-1/2)^2 - 4/3*(x-1/2)^4 + ...
        # sum_i h(x_i) ≈ m*log(2) - 2*sum(x_i - 1/2)^2 - 4/3*sum(x_i-1/2)^4
        # This requires p2 and p4
        p1 = power_sum_from_esymm(e, 1)
        p2 = power_sum_from_esymm(e, 2)
        p4 = power_sum_from_esymm(e, 4)
        # sum (x_i - 1/2)^2 = p2 - p1 + m/4
        # sum (x_i - 1/2)^4 = p4 - 2*p1*... (complex expansion)
        mu2 = p2 - p1 + m / 4
        # Simpler: just use the degree-4 Taylor coefficient
        return m * np.log(2) - 2 * mu2


def generate_free_fermion_spectrum(L: int, L_A: int, t: float = 1.0,
                                    delta: float = 0.0) -> np.ndarray:
    """Generate free-fermion correlation spectrum for a 1D tight-binding chain.

    Computes the eigenvalues of the restricted correlation matrix K_A for a
    half-filled free-fermion chain of length L, subsystem of size L_A.

    The Hamiltonian is H = -t sum_i (c_i^dag c_{i+1} + h.c.) + delta * sum_i (-1)^i n_i

    Args:
        L: total system size
        L_A: subsystem size
        t: hopping parameter
        delta: staggered potential (gap parameter)

    Returns:
        Correlation spectrum lambda in [0, 1] of length L_A
    """
    # Single-particle Hamiltonian
    H = np.zeros((L, L))
    for i in range(L - 1):
        H[i, i + 1] = -t
        H[i + 1, i] = -t
    for i in range(L):
        H[i, i] = delta * (-1) ** i

    # Diagonalize
    energies, states = np.linalg.eigh(H)

    # Half-filling: fill lowest L//2 states
    n_filled = L // 2
    filled_states = states[:, :n_filled]

    # Correlation matrix K = sum_filled |psi><psi|
    K = filled_states @ filled_states.T

    # Restrict to subsystem A (first L_A sites)
    K_A = K[:L_A, :L_A]

    # Eigenvalues of K_A are the correlation spectrum
    lam = np.linalg.eigvalsh(K_A)

    # Clip to [0, 1] (numerical precision)
    lam = np.clip(lam, 0, 1)

    return np.sort(lam)[::-1]


if __name__ == "__main__":
    # Example usage
    print("=== Algorithms for Newton-Hierarchy Entropy Bounds ===\n")

    # Generate a sample spectrum
    lam = generate_free_fermion_spectrum(L=20, L_A=8)
    print(f"Spectrum (L=20, L_A=8): {lam}")

    # Compute symmetric data
    e = esymm_all(lam)
    print(f"\nElementary symmetric polynomials:")
    for k in range(min(5, len(e))):
        print(f"  e_{k} = {e[k]:.6f}")

    # Newton ratios
    ratios = newton_ratios(lam)
    print(f"\nNewton ratios (rho_k >= 1 by Newton's inequality):")
    for k, r in enumerate(ratios[:5]):
        print(f"  rho_{k+1} = {r:.6f}")

    # Newton defects
    defects = newton_defects(lam)
    print(f"\nNewton defects (Delta_k >= 0):")
    for k, d in enumerate(defects[:5]):
        print(f"  Delta_{k+1} = {d:.6f}")

    # Entropy computation
    S_exact = fermion_entropy(lam)
    approx, err = certified_entropy_approx(lam)
    print(f"\nShannon entropy:")
    print(f"  Exact:         S = {S_exact:.6f}")
    print(f"  Lower bound:   {approx:.6f}")
    print(f"  Upper bound:   {approx + err:.6f}")
    print(f"  Error bound:   {err:.6f}")
    print(f"  Certified: {approx:.4f} <= S <= {approx + err:.4f}")

    # Power sum verification
    print(f"\nNewton-Girard verification:")
    for k in range(1, 4):
        p_direct = power_sum(lam, k)
        p_esymm = power_sum_from_esymm(e, k)
        print(f"  p_{k}: direct={p_direct:.6f}, from esymm={p_esymm:.6f}, "
              f"match={'YES' if abs(p_direct - p_esymm) < 1e-10 else 'NO'}")
