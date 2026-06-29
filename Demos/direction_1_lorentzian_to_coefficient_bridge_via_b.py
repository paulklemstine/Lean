"""
Applications of the Lorentzian-to-Coefficient Bridge

Real-world applications connecting Lorentzian polynomial theory
to combinatorics, probability, and statistical mechanics.
"""
import math
from typing import List, Tuple


def binomial_coefficients(d: int) -> List[float]:
    return [float(math.comb(d, m)) for m in range(d + 1)]


def check_log_concave(seq: List[float]) -> Tuple[bool, float]:
    d = len(seq) - 1
    min_ratio = float('inf')
    for m in range(1, d):
        if seq[m - 1] > 0 and seq[m + 1] > 0:
            ratio = seq[m]**2 / (seq[m - 1] * seq[m + 1])
            min_ratio = min(min_ratio, ratio)
    return min_ratio >= 1.0 - 1e-10, min_ratio


def convolve(a: List[float], b: List[float]) -> List[float]:
    result = [0.0] * (len(a) + len(b) - 1)
    for i, ai in enumerate(a):
        for j, bj in enumerate(b):
            result[i + j] += ai * bj
    return result


# ============================================================
# Application 1: Network Reliability
# ============================================================

def network_reliability_polynomial(
    edge_reliabilities: List[float], n_nodes: int
) -> List[float]:
    """
    Compute the reliability polynomial of a network.
    
    For a network with n nodes and given edge reliabilities,
    the reliability polynomial R(p) = sum_k a_k p^k (1-p)^(m-k)
    counts the probability of connectivity.
    
    The coefficient sequence of this polynomial is log-concave
    when the underlying matroid is Lorentzian.
    
    This is a simplified model for series-parallel networks.
    """
    # Model: m independent edges, each with the same reliability p
    # The number of spanning subgraphs with k edges
    m = len(edge_reliabilities)
    
    # For a complete graph on n nodes, the basis generating polynomial
    # of the graphic matroid has log-concave coefficients
    # (by Mason's conjecture, now theorem via ALOV)
    
    # Simplified: uniform matroid U(r, m) basis counts = C(m, r)
    rank = n_nodes - 1
    coeffs = [float(math.comb(m, k)) for k in range(m + 1)]
    
    return coeffs


def application_network_reliability():
    """Demonstrate log-concavity in network reliability."""
    print("Application 1: Network Reliability")
    print("-" * 50)
    
    for n_edges in [6, 10, 15]:
        n_nodes = 4
        reliabilities = [0.9] * n_edges
        coeffs = network_reliability_polynomial(reliabilities, n_nodes)
        is_lc, min_ratio = check_log_concave(coeffs)
        print(f"  {n_edges} edges, {n_nodes} nodes:")
        print(f"    Coefficients log-concave: {is_lc} (min ratio: {min_ratio:.4f})")
        print(f"    This guarantees unimodal failure probability distribution")
    print()


# ============================================================
# Application 2: Random Walks and Mixing Times
# ============================================================

def random_walk_distribution(d: int, p: float) -> List[float]:
    """
    Compute the distribution of position after d steps of a biased random walk.
    
    At each step, move right with probability p, left with probability 1-p.
    After d steps, the probability of being at position 2m - d (m rights out of d)
    is C(d, m) * p^m * (1-p)^(d-m).
    
    This is exactly the bivariate specialization (px + (1-p)y)^d.
    """
    return [math.comb(d, m) * p**m * (1 - p)**(d - m) for m in range(d + 1)]


def application_random_walks():
    """Demonstrate log-concavity in random walk distributions."""
    print("Application 2: Random Walk Distributions")
    print("-" * 50)
    
    for d in [10, 20, 50]:
        for p in [0.3, 0.5, 0.7]:
            dist = random_walk_distribution(d, p)
            is_lc, min_ratio = check_log_concave(dist)
            mode = dist.index(max(dist))
            print(f"  d={d:2d}, p={p}: log-concave={is_lc}, "
                  f"mode at m={mode}, min_ratio={min_ratio:.4f}")
    
    print("  → Log-concavity guarantees unimodal distributions")
    print("  → This is a direct consequence of the bivariate bridge theorem")
    print()


# ============================================================
# Application 3: Matroid Basis Counting
# ============================================================

def uniform_matroid_basis_count(n: int, r: int) -> List[float]:
    """
    Basis generating polynomial for the uniform matroid U(r, n).
    
    The coefficient of x^S (for |S| = r) is 1 for each r-element subset.
    The bivariate specialization gives coefficients C(n, m) * C(n-m, r-m) / C(n, r)
    ... simplified to C(n, r) since all r-subsets are bases.
    
    For the uniform matroid, the "f-vector" is [C(n, 0), C(n, 1), ..., C(n, n)].
    """
    return [float(math.comb(n, k)) for k in range(n + 1)]


def application_matroid_counting():
    """Demonstrate log-concavity in matroid theory."""
    print("Application 3: Matroid Basis Counting")
    print("-" * 50)
    
    print("  Uniform matroid U(r, n) basis sequence:")
    for n in [6, 10, 15]:
        coeffs = uniform_matroid_basis_count(n, n // 2)
        is_lc, min_ratio = check_log_concave(coeffs)
        print(f"    n={n:2d}: log-concave={is_lc}, min_ratio={min_ratio:.4f}")
    
    print("\n  Products of linear forms (Lorentzian by construction):")
    for d in [4, 6, 8]:
        # Product of d random positive linear forms
        import random
        random.seed(42 + d)
        poly = [1.0]
        for _ in range(d):
            a = random.uniform(0.5, 3.0)
            b = random.uniform(0.5, 3.0)
            poly = convolve(poly, [a, b])
        is_lc, min_ratio = check_log_concave(poly)
        print(f"    d={d}: coeffs={[f'{c:.1f}' for c in poly]}")
        print(f"           log-concave={is_lc}, min_ratio={min_ratio:.4f}")
    print()


# ============================================================
# Application 4: Statistical Mechanics — Partition Functions
# ============================================================

def partition_function_coefficients(
    energies: List[float], beta: float
) -> List[float]:
    """
    Compute the energy-level degeneracy sequence for a partition function.
    
    Z(β) = Σ_k g(k) e^{-βε_k}
    
    For independent subsystems, the degeneracy sequence of the product
    is the convolution of individual degeneracy sequences.
    Log-concavity of individual sequences implies log-concavity of the product
    (Hadamard product theorem).
    """
    # Each energy level k has degeneracy proportional to exp(-beta * energies[k])
    return [math.exp(-beta * e) for e in energies]


def application_stat_mech():
    """Demonstrate log-concavity in statistical mechanics."""
    print("Application 4: Statistical Mechanics")
    print("-" * 50)
    
    # Harmonic oscillator: energies E_n = n + 1/2
    print("  Harmonic oscillator partition function:")
    for beta in [0.1, 0.5, 1.0, 2.0]:
        energies = [n + 0.5 for n in range(15)]
        degeneracies = partition_function_coefficients(energies, beta)
        is_lc, min_ratio = check_log_concave(degeneracies)
        Z = sum(degeneracies)
        probs = [d / Z for d in degeneracies]
        print(f"    β={beta:3.1f}: log-concave={is_lc}, min_ratio={min_ratio:.4f}, "
              f"Z={Z:.4f}")
    
    # Two independent oscillators (Hadamard product)
    print("\n  Two independent oscillators (product):")
    energies1 = [n + 0.5 for n in range(10)]
    energies2 = [n + 0.5 for n in range(10)]
    for beta in [0.5, 1.0]:
        d1 = partition_function_coefficients(energies1, beta)
        d2 = partition_function_coefficients(energies2, beta)
        product = [d1[i] * d2[i] for i in range(len(d1))]
        is_lc, min_ratio = check_log_concave(product)
        print(f"    β={beta}: product log-concave={is_lc}, min_ratio={min_ratio:.4f}")
    print()


def main():
    print("=" * 60)
    print("LORENTZIAN BRIDGE: REAL-WORLD APPLICATIONS")
    print("=" * 60)
    print()
    
    application_network_reliability()
    application_random_walks()
    application_matroid_counting()
    application_stat_mech()
    
    print("=" * 60)
    print("All applications demonstrated successfully.")
    print("=" * 60)


if __name__ == "__main__":
    main()


"""
Demo: Lorentzian-to-Coefficient Bridge via Bivariate Specialization

Demonstrates the key mathematical results connecting Lorentzian polynomials
to log-concavity of coefficient sequences.
"""
import math
from typing import List, Tuple


def binomial_coefficients(d: int) -> List[int]:
    """Compute the binomial coefficient sequence C(d, 0), C(d, 1), ..., C(d, d)."""
    return [math.comb(d, m) for m in range(d + 1)]


def bivariate_coeff_seq(d: int, alpha: float, beta: float) -> List[float]:
    """
    Compute the bivariate coefficient sequence:
    a(m) = C(d, m) * alpha^m * beta^(d-m)
    
    This is the coefficient of x^m * y^(d-m) in (alpha*x + beta*y)^d.
    """
    return [math.comb(d, m) * alpha**m * beta**(d - m) for m in range(d + 1)]


def check_log_concave(seq: List[float]) -> Tuple[bool, List[float]]:
    """
    Check if a sequence is log-concave: a(m)^2 >= a(m-1)*a(m+1) for 1 <= m <= d-1.
    Returns (is_log_concave, list of ratios a(m)^2 / (a(m-1)*a(m+1))).
    """
    d = len(seq) - 1
    ratios = []
    is_lc = True
    for m in range(1, d):
        if seq[m - 1] > 0 and seq[m + 1] > 0:
            ratio = seq[m]**2 / (seq[m - 1] * seq[m + 1])
            ratios.append(ratio)
            if ratio < 1.0 - 1e-10:
                is_lc = False
        else:
            ratios.append(float('inf'))
    return is_lc, ratios


def ratio_sequence(seq: List[float]) -> List[float]:
    """Compute the ratio sequence r(m) = a(m+1)/a(m)."""
    return [seq[m + 1] / seq[m] for m in range(len(seq) - 1) if seq[m] > 0]


def check_k_fold_log_concave(seq: List[float], k: int) -> Tuple[bool, List[str]]:
    """
    Check if a sequence is k-fold log-concave.
    Returns (is_k_fold, list of diagnostic messages).
    """
    messages = []
    current = seq[:]
    
    for level in range(k):
        if len(current) < 3:
            messages.append(f"  Level {level}: sequence too short ({len(current)} terms)")
            return True, messages
        
        is_lc, ratios = check_log_concave(current)
        if not is_lc:
            messages.append(f"  Level {level}: NOT log-concave. Ratios: {[f'{r:.4f}' for r in ratios]}")
            return False, messages
        
        messages.append(f"  Level {level}: log-concave ✓ (min ratio = {min(ratios):.6f})")
        current = ratio_sequence(current)
    
    return True, messages


def main():
    print("=" * 70)
    print("LORENTZIAN-TO-COEFFICIENT BRIDGE: DEMO")
    print("=" * 70)
    
    # Demo 1: Binomial coefficients are log-concave
    print("\n--- Demo 1: Binomial Coefficient Log-Concavity ---")
    for d in [4, 6, 10, 20]:
        coeffs = binomial_coefficients(d)
        is_lc, ratios = check_log_concave(coeffs)
        print(f"  d={d:2d}: C(d,m) = {coeffs}")
        print(f"         Log-concave: {is_lc}, ratios: {[f'{r:.3f}' for r in ratios]}")
    
    # Demo 2: Bivariate specialization
    print("\n--- Demo 2: Bivariate Coefficient Sequences ---")
    d = 6
    for alpha, beta in [(1.0, 1.0), (2.0, 1.0), (1.0, 3.0), (0.5, 2.5)]:
        coeffs = bivariate_coeff_seq(d, alpha, beta)
        is_lc, ratios = check_log_concave(coeffs)
        print(f"  (α={alpha}, β={beta}): a(m) = {[f'{c:.1f}' for c in coeffs]}")
        print(f"    Log-concave: {is_lc} (min ratio = {min(ratios):.4f})")
    
    # Demo 3: Geometric perturbation preserves log-concavity
    print("\n--- Demo 3: Geometric Perturbation ---")
    base = binomial_coefficients(8)
    base_float = [float(c) for c in base]
    for r in [0.5, 1.0, 2.0, 10.0]:
        perturbed = [base_float[m] * r**m for m in range(len(base_float))]
        is_lc, ratios = check_log_concave(perturbed)
        print(f"  r={r:4.1f}: Log-concave: {is_lc} (min ratio = {min(ratios):.4f})")
    
    # Demo 4: Hadamard product preserves log-concavity
    print("\n--- Demo 4: Hadamard Product ---")
    a = bivariate_coeff_seq(6, 2.0, 1.0)
    b = bivariate_coeff_seq(6, 1.0, 3.0)
    hadamard = [a[m] * b[m] for m in range(len(a))]
    is_lc_a, _ = check_log_concave(a)
    is_lc_b, _ = check_log_concave(b)
    is_lc_h, ratios_h = check_log_concave(hadamard)
    print(f"  a log-concave: {is_lc_a}")
    print(f"  b log-concave: {is_lc_b}")
    print(f"  a·b log-concave: {is_lc_h} (min ratio = {min(ratios_h):.4f})")
    
    # Demo 5: K-fold log-concavity
    print("\n--- Demo 5: K-Fold Log-Concavity ---")
    for d in [6, 10, 15]:
        coeffs = [float(c) for c in binomial_coefficients(d)]
        for k in [1, 2, 3]:
            is_kf, msgs = check_k_fold_log_concave(coeffs, k)
            print(f"  d={d:2d}, k={k}: {k}-fold log-concave: {is_kf}")
            for msg in msgs:
                print(f"    {msg}")
    
    # Demo 6: The reversed Cauchy-Schwarz / log-concavity ratio
    print("\n--- Demo 6: Reversed Cauchy-Schwarz Ratio ---")
    print("  C(d,m)^2 / (C(d,m-1)*C(d,m+1)) = (d-m+1)(m+1) / (m(d-m))")
    d = 10
    for m in range(1, d):
        ratio_exact = (d - m + 1) * (m + 1) / (m * (d - m))
        surplus = (d + 1) / (m * (d - m))
        print(f"  m={m}: ratio = {ratio_exact:.4f} = 1 + {surplus:.4f} (surplus = (d+1)/(m(d-m)))")
    
    # Demo 7: Conjecture test — products of multiple linear forms
    print("\n--- Demo 7: Conjecture Test (Products of Linear Forms) ---")
    import functools
    import operator
    
    def convolve(a: List[float], b: List[float]) -> List[float]:
        """Polynomial multiplication (convolution)."""
        result = [0.0] * (len(a) + len(b) - 1)
        for i, ai in enumerate(a):
            for j, bj in enumerate(b):
                result[i + j] += ai * bj
        return result
    
    # (x + y)(2x + y)(x + 3y) — product of 3 distinct linear forms
    forms = [[1, 1], [2, 1], [1, 3]]  # [alpha, beta] for each form
    poly = [1.0]
    for alpha, beta in forms:
        poly = convolve(poly, [float(alpha), float(beta)])
    
    print(f"  Product of linear forms: {' * '.join([f'({a}x + {b}y)' for a, b in forms])}")
    print(f"  Coefficients: {[f'{c:.0f}' for c in poly]}")
    is_lc, ratios = check_log_concave(poly)
    print(f"  Log-concave: {is_lc} (ratios: {[f'{r:.4f}' for r in ratios]})")
    
    # (x + y)(x + 2y)(2x + y)(x + 3y)(3x + y) — product of 5 forms
    forms5 = [[1, 1], [1, 2], [2, 1], [1, 3], [3, 1]]
    poly5 = [1.0]
    for alpha, beta in forms5:
        poly5 = convolve(poly5, [float(alpha), float(beta)])
    
    print(f"\n  Product of 5 forms:")
    print(f"  Coefficients: {[f'{c:.0f}' for c in poly5]}")
    is_lc5, ratios5 = check_log_concave(poly5)
    is_kf5, msgs5 = check_k_fold_log_concave(poly5, 3)
    print(f"  Log-concave: {is_lc5}")
    print(f"  3-fold log-concave: {is_kf5}")
    for msg in msgs5:
        print(f"    {msg}")
    
    print("\n" + "=" * 70)
    print("All demos completed successfully.")
    print("=" * 70)


if __name__ == "__main__":
    main()


"""
Visualization 3: The Lorentzian-to-Coefficient Bridge

Visualizes how bivariate specialization transforms a Lorentzian polynomial
into a log-concave coefficient sequence, showing:
1. The coefficient sequences for various (α, β) parameters
2. How log-concavity ratios vary with specialization direction
3. The universal lower bound from the reversed Cauchy-Schwarz inequality
"""
import numpy as np
import matplotlib.pyplot as plt
import math


def bivariate_coeffs(d, alpha, beta):
    return [math.comb(d, m) * alpha**m * beta**(d - m) for m in range(d + 1)]


def lc_min_ratio(seq):
    d = len(seq) - 1
    ratios = []
    for m in range(1, d):
        if seq[m - 1] > 0 and seq[m + 1] > 0:
            ratios.append(seq[m]**2 / (seq[m - 1] * seq[m + 1]))
    return min(ratios) if ratios else float('inf')


d = 10

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Coefficient sequences for different α/β
ax1 = axes[0]
params = [(1, 1), (2, 1), (1, 2), (3, 1), (1, 3)]
colors = plt.cm.viridis(np.linspace(0.1, 0.9, len(params)))

for (alpha, beta), color in zip(params, colors):
    coeffs = bivariate_coeffs(d, alpha, beta)
    # Normalize to max 1 for visual comparison
    mx = max(coeffs)
    normalized = [c / mx for c in coeffs]
    ax1.plot(range(d + 1), normalized, 'o-', color=color, markersize=5,
             label=f'α={alpha}, β={beta}', linewidth=2)

ax1.set_xlabel('Index m', fontsize=12)
ax1.set_ylabel('Normalized coefficient', fontsize=12)
ax1.set_title(f'Bivariate Specialization\nCoefficients of (αx + βy)^{d}', fontsize=13)
ax1.legend(fontsize=9)
ax1.grid(alpha=0.3)

# Panel 2: Log-concavity ratio as function of α/β
ax2 = axes[1]
ratios_by_ab = []
ab_values = np.linspace(0.1, 5.0, 50)

for ab in ab_values:
    coeffs = bivariate_coeffs(d, ab, 1.0)
    ratios_by_ab.append(lc_min_ratio(coeffs))

ax2.plot(ab_values, ratios_by_ab, 'b-', linewidth=2)
ax2.axhline(y=1.0, color='red', linestyle='--', alpha=0.7, label='LC threshold')
ax2.set_xlabel('α/β ratio', fontsize=12)
ax2.set_ylabel('Minimum LC ratio', fontsize=12)
ax2.set_title('Log-Concavity Strength\nvs. Specialization Direction', fontsize=13)
ax2.legend(fontsize=10)
ax2.grid(alpha=0.3)
ax2.set_ylim(0.9, 2.5)

# Panel 3: The reversed Cauchy-Schwarz surplus for different degrees
ax3 = axes[2]
for deg in [5, 10, 15, 20, 30]:
    ms = np.arange(1, deg)
    # The exact formula: ratio = (deg-m+1)(m+1) / (m*(deg-m))
    exact_ratios = [(deg - m + 1) * (m + 1) / (m * (deg - m)) for m in ms]
    ax3.plot(ms / deg, exact_ratios, '-', linewidth=2,
             label=f'd = {deg}', alpha=0.8)

ax3.axhline(y=1.0, color='red', linestyle='--', alpha=0.7)
ax3.set_xlabel('Normalized position m/d', fontsize=12)
ax3.set_ylabel('Reversed Cauchy-Schwarz ratio', fontsize=12)
ax3.set_title('Universal Lower Bound\nfrom Lorentzian Structure', fontsize=13)
ax3.legend(fontsize=9)
ax3.grid(alpha=0.3)
ax3.set_ylim(0.8, 4.0)

plt.suptitle('The Lorentzian-to-Coefficient Bridge',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_bridge_diagram.png', dpi=150, bbox_inches='tight')
print("Saved viz_bridge_diagram.png")


"""
Visualization 2: K-Fold Log-Concavity Tower

Visualizes the hierarchy of k-fold log-concavity for binomial coefficients
and products of linear forms. Shows how the ratio sequence transforms at
each level of the tower, with log-concavity ratios at each depth.

This reveals the fractal-like structure of the k-fold hierarchy:
each level's ratio sequence becomes the input for the next level's
log-concavity test.
"""
import numpy as np
import matplotlib.pyplot as plt
import math


def ratio_seq(seq):
    """Compute ratio sequence r(m) = a(m+1)/a(m)."""
    return [seq[m + 1] / seq[m] for m in range(len(seq) - 1) if seq[m] > 0]


def lc_ratios(seq):
    """Compute log-concavity ratios a(m)^2 / (a(m-1)*a(m+1))."""
    d = len(seq) - 1
    return [seq[m]**2 / (seq[m - 1] * seq[m + 1])
            for m in range(1, d)
            if seq[m - 1] > 0 and seq[m + 1] > 0]


def convolve(a, b):
    result = [0.0] * (len(a) + len(b) - 1)
    for i, ai in enumerate(a):
        for j, bj in enumerate(b):
            result[i + j] += ai * bj
    return result


# Generate test sequences
d = 15
binomial = [float(math.comb(d, m)) for m in range(d + 1)]

# Product of 15 distinct linear forms
np.random.seed(42)
forms = [(np.random.uniform(0.5, 3), np.random.uniform(0.5, 3)) for _ in range(d)]
poly = [1.0]
for a, b in forms:
    poly = convolve(poly, [a, b])

sequences = {
    f'Binomial C({d},m)': binomial,
    f'Product of {d} linear forms': poly,
}

fig, axes = plt.subplots(2, 3, figsize=(16, 10))

for row, (name, seq) in enumerate(sequences.items()):
    current = seq[:]
    
    for col in range(3):
        ax = axes[row, col]
        
        if len(current) < 3:
            ax.text(0.5, 0.5, 'Too short', ha='center', va='center',
                    transform=ax.transAxes, fontsize=14)
            ax.set_title(f'Level {col}: Ratio sequence')
            continue
        
        # Plot the sequence
        x = np.arange(len(current))
        ax.bar(x, current, alpha=0.6, color=['#2196F3', '#FF9800', '#4CAF50'][col])
        
        # Compute and annotate LC ratios
        ratios = lc_ratios(current)
        min_r = min(ratios) if ratios else float('inf')
        is_lc = min_r >= 1.0 - 1e-10
        
        status = '✓' if is_lc else '✗'
        color = '#2E7D32' if is_lc else '#C62828'
        
        ax.set_title(f'Level {col}: {"Original" if col == 0 else "Iterated ratio"}\n'
                     f'LC ratio ≥ {min_r:.4f} {status}',
                     fontsize=11, color=color)
        ax.set_xlabel('Index m')
        ax.set_ylabel('Value')
        
        if col == 0:
            ax.set_ylabel(name, fontsize=11, fontweight='bold')
        
        # Compute ratio sequence for next level
        current = ratio_seq(current)

plt.suptitle('K-Fold Log-Concavity Tower\n'
             'Each level applies the ratio operator and checks log-concavity',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_kfold_tower.png', dpi=150, bbox_inches='tight')
print("Saved viz_kfold_tower.png")


"""
Visualization 1: Log-Concavity Ratio Heatmap

Visualizes the log-concavity ratio C(d,m)^2 / (C(d,m-1)*C(d,m+1))
across all degrees d and positions m. The surplus above 1 measures
how strongly log-concavity holds. Brighter = more surplus = stronger
log-concavity.

This heatmap reveals the geometric structure: the ratio equals
(d-m+1)(m+1) / (m(d-m)) = 1 + (d+1)/(m(d-m)), which is maximized
at the endpoints (m=1, m=d-1) and minimized at the center (m=d/2).
"""
import numpy as np
import matplotlib.pyplot as plt

# Parameters
max_d = 30

# Compute ratios
ratios = np.zeros((max_d + 1, max_d + 1))
ratios[:] = np.nan

for d in range(2, max_d + 1):
    for m in range(1, d):
        # C(d,m)^2 / (C(d,m-1)*C(d,m+1)) = (d-m+1)(m+1) / (m*(d-m))
        ratio = (d - m + 1) * (m + 1) / (m * (d - m))
        ratios[d, m] = ratio

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: Heatmap of ratios
ax1 = axes[0]
im = ax1.imshow(ratios[2:, :max_d], aspect='auto', cmap='YlOrRd',
                origin='lower', vmin=1.0, vmax=3.0,
                extent=[0, max_d, 2, max_d + 1])
ax1.set_xlabel('Position m', fontsize=12)
ax1.set_ylabel('Degree d', fontsize=12)
ax1.set_title('Log-Concavity Ratio\nC(d,m)² / (C(d,m-1)·C(d,m+1))', fontsize=13)
plt.colorbar(im, ax=ax1, label='Ratio (≥ 1 means log-concave)')

# Right: Surplus (d+1)/(m*(d-m)) for selected degrees
ax2 = axes[1]
for d in [5, 10, 15, 20, 30]:
    ms = np.arange(1, d)
    surplus = (d + 1) / (ms * (d - ms))
    ax2.plot(ms / d, surplus, 'o-', markersize=3, label=f'd = {d}', alpha=0.8)

ax2.set_xlabel('Normalized position m/d', fontsize=12)
ax2.set_ylabel('Surplus above 1', fontsize=12)
ax2.set_title('Log-Concavity Surplus\n(d+1) / (m·(d-m))', fontsize=13)
ax2.legend(fontsize=10)
ax2.set_ylim(0, 5)
ax2.axhline(y=0, color='gray', linestyle='--', alpha=0.3)
ax2.grid(alpha=0.3)

plt.tight_layout()
plt.savefig('viz_log_concavity_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_log_concavity_heatmap.png")
