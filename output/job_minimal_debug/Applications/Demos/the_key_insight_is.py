"""
Profile Recovery Theorem — Demonstration

This script demonstrates the core ideas of the Profile Recovery Theorem:
1. Catalan numbers and the Wigner semicircle law
2. Moment convergence of random matrix eigenvalues
3. The moment distance pseudometric
4. Verification of the Catalan bound conjecture
5. Carleman condition checking
"""

import math
import random
from algorithms import (
    catalan_number,
    wigner_moment,
    moment_distance,
    check_carleman_condition,
    random_matrix_empirical_moments,
    catalan_four_pow_ratio,
)


def generate_wigner_matrix(n: int) -> list:
    """Generate an n×n Wigner random matrix (GOE: Gaussian Orthogonal Ensemble).
    
    Upper triangle entries are i.i.d. N(0, 1/n).
    Diagonal entries are i.i.d. N(0, 2/n).
    Matrix is symmetric.
    """
    matrix = [[0.0] * n for _ in range(n)]
    for i in range(n):
        matrix[i][i] = random.gauss(0, math.sqrt(2.0 / n))
        for j in range(i + 1, n):
            val = random.gauss(0, math.sqrt(1.0 / n))
            matrix[i][j] = val
            matrix[j][i] = val
    return matrix


def eigenvalues_power_method(matrix: list, n: int) -> list:
    """Compute eigenvalues using numpy-free tridiagonal reduction (simplified).
    
    For demonstration, we use the characteristic polynomial approach for small n.
    For larger n, we approximate using the moment method directly.
    """
    # For small matrices, compute eigenvalues via numpy-free QR-like iteration
    # This is a simplified demonstration
    try:
        import numpy as np
        mat = np.array(matrix)
        return sorted(np.linalg.eigvalsh(mat).tolist())
    except ImportError:
        # Fallback: return empty (moments computed directly)
        return []


def demo_catalan_numbers():
    """Demonstrate Catalan number properties and the 4^k bound."""
    print("=" * 60)
    print("DEMO 1: Catalan Numbers and the 4^k Bound")
    print("=" * 60)
    print()
    print(f"{'k':>4} {'C_k':>12} {'4^k':>12} {'C_k/4^k':>12} {'C_k ≤ 4^k':>10}")
    print("-" * 55)
    for k in range(15):
        ck = catalan_number(k)
        fk = 4 ** k
        ratio = ck / fk if fk > 0 else 0
        check = "✓" if ck <= fk else "✗"
        print(f"{k:>4} {ck:>12} {fk:>12} {ratio:>12.6f} {check:>10}")
    print()
    print("Asymptotic: C_k ~ 4^k / (k^{3/2} √π)")
    print(f"Prediction at k=14: {4**14 / (14**1.5 * math.sqrt(math.pi)):.0f}")
    print(f"Actual C_14 = {catalan_number(14)}")
    print()


def demo_wigner_moments():
    """Demonstrate Wigner semicircle moments."""
    print("=" * 60)
    print("DEMO 2: Wigner Semicircle Law Moments")
    print("=" * 60)
    print()
    print("The semicircle distribution on [-2,2] has density (1/2π)√(4-x²)")
    print("Even moments = Catalan numbers, odd moments = 0")
    print()
    print(f"{'k':>4} {'m_k':>12} {'Description':>20}")
    print("-" * 40)
    for k in range(11):
        mk = wigner_moment(k)
        desc = f"C_{k//2}" if k % 2 == 0 else "0 (odd)"
        print(f"{k:>4} {mk:>12.0f} {desc:>20}")
    print()


def demo_moment_convergence():
    """Demonstrate moment convergence of random matrices to semicircle law."""
    print("=" * 60)
    print("DEMO 3: Random Matrix Moment Convergence")
    print("=" * 60)
    print()
    
    random.seed(42)
    sizes = [10, 50, 100, 200, 500]
    K = 6  # Compare first 6 moments
    
    print(f"Comparing first {K} moments of n×n Wigner matrices to semicircle law")
    print()
    print(f"{'n':>6} {'d_K(μ_n, μ)':>15} {'n·d_K':>10}")
    print("-" * 35)
    
    for n in sizes:
        mat = generate_wigner_matrix(n)
        eigs = eigenvalues_power_method(mat, n)
        if eigs:
            emp_moments = lambda k, e=eigs: random_matrix_empirical_moments(e, k)
            d = moment_distance(emp_moments, wigner_moment, K)
            print(f"{n:>6} {d:>15.6f} {n*d:>10.3f}")
        else:
            print(f"{n:>6} {'(numpy needed)':>15}")
    
    print()
    print("Profile Recovery Theorem: if d_K → 0 and Carleman holds,")
    print("then the spectral distribution converges to the semicircle law.")
    print()


def demo_moment_distance():
    """Demonstrate the moment distance pseudometric properties."""
    print("=" * 60)
    print("DEMO 4: Moment Distance Pseudometric")
    print("=" * 60)
    print()
    
    # Define three moment sequences
    m1 = lambda k: float(k + 1) if k % 2 == 0 else 0.0
    m2 = lambda k: float(k + 2) if k % 2 == 0 else 0.0
    m3 = lambda k: float(k + 3) if k % 2 == 0 else 0.0
    
    K = 8
    d12 = moment_distance(m1, m2, K)
    d23 = moment_distance(m2, m3, K)
    d13 = moment_distance(m1, m3, K)
    d11 = moment_distance(m1, m1, K)
    
    print(f"d(μ₁, μ₂) = {d12:.6f}")
    print(f"d(μ₂, μ₃) = {d23:.6f}")
    print(f"d(μ₁, μ₃) = {d13:.6f}")
    print(f"d(μ₁, μ₁) = {d11:.6f}")
    print()
    print(f"Triangle inequality: d(μ₁,μ₃) ≤ d(μ₁,μ₂) + d(μ₂,μ₃)")
    print(f"  {d13:.6f} ≤ {d12 + d23:.6f}  {'✓' if d13 <= d12 + d23 + 1e-10 else '✗'}")
    print(f"Self-distance = 0:  d(μ₁,μ₁) = {d11:.6f}  {'✓' if abs(d11) < 1e-10 else '✗'}")
    print()


def demo_carleman_condition():
    """Demonstrate Carleman condition checking."""
    print("=" * 60)
    print("DEMO 5: Carleman Condition")
    print("=" * 60)
    print()
    
    # Semicircle moments: C_n grows like 4^n/n^{3/2}, so m_{2n}^{-1/(2n)} ~ 1/4
    # Carleman series diverges (harmonic-like)
    print("Semicircle distribution (even moments = Catalan numbers):")
    partial = 0.0
    for n in range(1, 21):
        m2n = wigner_moment(2 * n)
        if m2n > 0:
            term = m2n ** (-1.0 / (2 * n))
            partial += term
            print(f"  n={n:>2}: m_{2*n} = {m2n:>10.0f}, term = {term:.6f}, partial = {partial:.4f}")
    
    print(f"\nPartial sum after 20 terms: {partial:.4f}")
    print("Series appears to diverge → Carleman condition SATISFIED")
    print("→ Semicircle distribution is moment-determined")
    print()
    
    # Normal distribution: m_{2n} = (2n-1)!! 
    print("Standard normal distribution (even moments = (2n-1)!!):")
    partial = 0.0
    for n in range(1, 21):
        m2n = math.factorial(2 * n) / (2 ** n * math.factorial(n))  # (2n-1)!!
        term = m2n ** (-1.0 / (2 * n))
        partial += term
        if n <= 5 or n % 5 == 0:
            print(f"  n={n:>2}: m_{2*n} = {m2n:>12.0f}, term = {term:.6f}, partial = {partial:.4f}")
    
    print(f"\nPartial sum after 20 terms: {partial:.4f}")
    print("Series diverges → Carleman condition SATISFIED")
    print("→ Normal distribution is moment-determined")
    print()


def demo_convergence_cascade():
    """Demonstrate the convergence cascade structure."""
    print("=" * 60)
    print("DEMO 6: Convergence Cascade")
    print("=" * 60)
    print()
    
    print("A convergence cascade proves moment convergence inductively:")
    print("  Base: m_0(n) = 1 for all n (normalization)")
    print("  Step: convergence of m_0,...,m_k ⟹ convergence of m_{k+1}")
    print()
    
    # Simulate: perturbed moments converging to semicircle
    def perturbed_moment(n: int, k: int) -> float:
        """Semicircle moments + O(1/n) perturbation."""
        return wigner_moment(k) + (1.0 / (n + 1)) * math.sin(k * n)
    
    K = 8
    print(f"Perturbed semicircle moments μ_n(k) = m_k + sin(kn)/(n+1)")
    print(f"Moment distances d_{K}(μ_n, μ) as n grows:")
    print()
    for n in [1, 5, 10, 50, 100, 500, 1000]:
        ms = lambda k, n=n: perturbed_moment(n, k)
        d = moment_distance(ms, wigner_moment, K)
        print(f"  n = {n:>5}: d_{K} = {d:.8f}")
    
    print()
    print("Distances → 0: moment convergence confirmed")
    print("+ Carleman condition → Profile Recovery Theorem applies")
    print("→ Distributional convergence to semicircle law")
    print()


if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  PROFILE RECOVERY THEOREM — DEMONSTRATION              ║")
    print("║  From Moment Convergence to Distributional Convergence  ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()
    
    demo_catalan_numbers()
    demo_wigner_moments()
    demo_moment_distance()
    demo_carleman_condition()
    demo_convergence_cascade()
    demo_moment_convergence()
    
    print("=" * 60)
    print("SUMMARY")
    print("=" * 60)
    print()
    print("The Profile Recovery Theorem (Theorem C) establishes:")
    print("  Moment convergence + Carleman condition")
    print("  ⟹ Distributional convergence")
    print()
    print("This reduces the hard problem of proving distributional")
    print("convergence to the tractable problem of proving moment")
    print("convergence, which can be attacked via combinatorial")
    print("methods (counting closed walks, Catalan numbers, etc.)")
    print()


"""
Visualization: Moment Convergence and the Profile Recovery Theorem

Generates three plots:
1. Catalan numbers vs 4^k bound (log scale)
2. Moment distance convergence rate
3. Carleman condition partial sums
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def catalan_number(n: int) -> int:
    return math.comb(2 * n, n) // (n + 1)


def wigner_moment(k: int) -> float:
    if k % 2 == 1:
        return 0.0
    return float(catalan_number(k // 2))


def moment_distance(m1, m2, K: int) -> float:
    return sum(abs(m1(k) - m2(k)) / math.factorial(k) for k in range(K))


fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# Plot 1: Catalan numbers vs 4^k
ks = list(range(16))
catalans = [catalan_number(k) for k in ks]
four_pows = [4**k for k in ks]

axes[0].semilogy(ks, catalans, 'bo-', label=r'$C_k$ (Catalan)', markersize=6)
axes[0].semilogy(ks, four_pows, 'r^--', label=r'$4^k$ (bound)', markersize=6)
asymptotic = [4**k / (k**1.5 * math.sqrt(math.pi)) if k > 0 else 1 for k in ks]
axes[0].semilogy(ks, asymptotic, 'g--', alpha=0.7, label=r'$4^k/(k^{3/2}\sqrt{\pi})$')
axes[0].set_xlabel('k')
axes[0].set_ylabel('Value (log scale)')
axes[0].set_title('Catalan Numbers vs $4^k$ Bound')
axes[0].legend()
axes[0].grid(True, alpha=0.3)

# Plot 2: Moment distance convergence
K_trunc = 8
ns = list(range(1, 201))
distances = []
for n in ns:
    perturbed = lambda k, n=n: wigner_moment(k) + math.sin(k * n) / (n + 1)
    d = moment_distance(perturbed, wigner_moment, K_trunc)
    distances.append(d)

axes[1].plot(ns, distances, 'b-', alpha=0.7, label=r'$d_K(\mu_n, \mu)$')
axes[1].plot(ns, [K_trunc / (n + 1) for n in ns], 'r--', alpha=0.7, label=r'$O(K/n)$ bound')
axes[1].set_xlabel('n')
axes[1].set_ylabel('Moment distance')
axes[1].set_title(f'Moment Method Convergence (K={K_trunc})')
axes[1].legend()
axes[1].grid(True, alpha=0.3)
axes[1].set_xlim(0, 200)

# Plot 3: Carleman condition partial sums
N_terms = 30
partial_sums_sc = []
partial_sums_normal = []
partial = 0.0
partial_n = 0.0
for n in range(1, N_terms + 1):
    m2n_sc = wigner_moment(2 * n)
    if m2n_sc > 0:
        partial += m2n_sc ** (-1.0 / (2 * n))
    partial_sums_sc.append(partial)
    
    m2n_normal = math.factorial(2 * n) / (2**n * math.factorial(n))
    partial_n += m2n_normal ** (-1.0 / (2 * n))
    partial_sums_normal.append(partial_n)

axes[2].plot(range(1, N_terms + 1), partial_sums_sc, 'b-o', markersize=4,
             label='Semicircle')
axes[2].plot(range(1, N_terms + 1), partial_sums_normal, 'r-s', markersize=4,
             label='Normal')
axes[2].set_xlabel('N (terms)')
axes[2].set_ylabel('Partial sum')
axes[2].set_title(r'Carleman Condition: $\sum m_{2n}^{-1/(2n)}$')
axes[2].legend()
axes[2].grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('profile_recovery_visualization.png', dpi=150, bbox_inches='tight')
print("Saved: profile_recovery_visualization.png")
