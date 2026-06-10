#!/usr/bin/env python3
"""
Applications of Reflection Positivity and Transfer Matrix Theory
=================================================================

Demonstrates real-world applications of the formalized mathematical framework:
1. Lattice gauge theory mass gap computation
2. Statistical mechanics / Ising model transfer matrices
3. Markov chain mixing time estimation
4. Correlation length computation
"""

import numpy as np
from typing import Tuple, List


# =============================================================================
# Application 1: Ising Model Transfer Matrix
# =============================================================================

def ising_transfer_matrix(beta: float, h: float = 0.0) -> np.ndarray:
    """
    Construct the transfer matrix for the 1D Ising model.

    T[s, s'] = exp(beta * s * s' + h * (s + s') / 2)
    where s, s' ∈ {-1, +1} mapped to indices {0, 1}.

    Parameters
    ----------
    beta : float
        Inverse temperature (coupling strength).
    h : float
        External magnetic field.

    Returns
    -------
    np.ndarray
        2x2 transfer matrix.
    """
    spins = [-1, 1]
    T = np.zeros((2, 2))
    for i, s in enumerate(spins):
        for j, sp in enumerate(spins):
            T[i, j] = np.exp(beta * s * sp + h * (s + sp) / 2)
    return T


def ising_correlation_length(beta: float) -> float:
    """
    Compute the correlation length from the transfer matrix.

    ξ = 1 / log(λ₀ / λ₁)

    This directly uses the spectral gap: a larger gap means shorter correlations.
    """
    T = ising_transfer_matrix(beta)
    eigenvalues = np.sort(np.linalg.eigvalsh(T))[::-1]
    if eigenvalues[1] <= 0:
        return float('inf')
    ratio = eigenvalues[0] / eigenvalues[1]
    if ratio <= 1:
        return float('inf')
    return 1.0 / np.log(ratio)


def ising_free_energy_density(beta: float, n_sites: int = 1) -> float:
    """
    Compute the free energy density f = -T * log(λ₀) / N = -log(λ₀) / beta.
    """
    T = ising_transfer_matrix(beta)
    lam0 = np.max(np.linalg.eigvalsh(T))
    return -np.log(lam0)


# =============================================================================
# Application 2: Lattice Gauge Theory Mass Gap
# =============================================================================

def lattice_gauge_transfer_matrix(
    n_group: int,
    beta: float,
    n_spatial: int = 1
) -> np.ndarray:
    """
    Construct the transfer matrix for a 2D lattice gauge theory.

    For a single spatial link with gauge group discretized to Z_n,
    the transfer matrix is:
    T[g1, g2] = exp(beta * Re(chi(g1 * g2^{-1})))
    where chi is the character (trace) in the fundamental representation.

    Parameters
    ----------
    n_group : int
        Order of the discrete gauge group (approximating SU(2)).
    beta : float
        Coupling constant.
    n_spatial : int
        Number of spatial links (for multi-link models).

    Returns
    -------
    np.ndarray
        Transfer matrix.
    """
    if n_spatial == 1:
        T = np.zeros((n_group, n_group))
        for i in range(n_group):
            for j in range(n_group):
                angle = 2 * np.pi * ((i - j) % n_group) / n_group
                T[i, j] = np.exp(beta * np.cos(angle))
        return T
    else:
        # Multi-link: tensor product structure
        size = n_group ** n_spatial
        T = np.zeros((size, size))
        for I in range(size):
            for J in range(size):
                # Decode multi-indices
                energy = 0.0
                for link in range(n_spatial):
                    gi = (I // (n_group ** link)) % n_group
                    gj = (J // (n_group ** link)) % n_group
                    angle = 2 * np.pi * ((gi - gj) % n_group) / n_group
                    energy += np.cos(angle)
                T[I, J] = np.exp(beta * energy)
        return T


def compute_mass_gap(n_group: int, beta: float) -> dict:
    """
    Compute the mass gap for a lattice gauge model.

    The mass gap m = -log(λ₁/λ₀) = log(λ₀) - log(λ₁).
    """
    T = lattice_gauge_transfer_matrix(n_group, beta)
    eigenvalues = np.sort(np.linalg.eigvalsh(T))[::-1]

    result = {
        'n_group': n_group,
        'beta': beta,
        'top_eigenvalue': eigenvalues[0],
        'all_eigenvalues': eigenvalues,
        'mass_gap': None,
        'correlation_length': None,
    }

    if len(eigenvalues) > 1 and eigenvalues[1] > 0:
        ratio = eigenvalues[0] / eigenvalues[1]
        result['mass_gap'] = np.log(ratio)
        result['correlation_length'] = 1.0 / np.log(ratio)

    return result


# =============================================================================
# Application 3: Markov Chain Mixing
# =============================================================================

def transfer_to_markov(T: np.ndarray) -> np.ndarray:
    """
    Normalize a positive transfer matrix to a stochastic (Markov) matrix.

    P[i,j] = T[i,j] / sum_j T[i,j]
    """
    row_sums = T.sum(axis=1, keepdims=True)
    return T / row_sums


def mixing_time_estimate(T: np.ndarray) -> float:
    """
    Estimate the mixing time from the spectral gap.

    t_mix ≈ 1 / (1 - λ₁/λ₀) for the normalized Markov chain.
    """
    P = transfer_to_markov(T)
    eigenvalues = np.sort(np.abs(np.linalg.eigvals(P)))[::-1]
    if len(eigenvalues) > 1 and eigenvalues[0] > 0:
        spectral_gap = 1 - eigenvalues[1] / eigenvalues[0]
        if spectral_gap > 0:
            return 1.0 / spectral_gap
    return float('inf')


# =============================================================================
# Main demonstration
# =============================================================================

if __name__ == "__main__":
    print("=" * 70)
    print("APPLICATIONS OF REFLECTION POSITIVITY & TRANSFER MATRICES")
    print("=" * 70)

    # Application 1: Ising model
    print("\n" + "─" * 70)
    print("APPLICATION 1: 1D Ising Model")
    print("─" * 70)
    print(f"\n{'β':>8s}  {'λ₀':>10s}  {'λ₁':>10s}  {'ξ':>10s}  {'f':>12s}")
    print("─" * 55)
    for beta in [0.1, 0.5, 1.0, 2.0, 5.0]:
        T = ising_transfer_matrix(beta)
        eigs = np.sort(np.linalg.eigvalsh(T))[::-1]
        xi = ising_correlation_length(beta)
        f = ising_free_energy_density(beta)
        print(f"  {beta:6.1f}  {eigs[0]:10.4f}  {eigs[1]:10.4f}  {xi:10.4f}  {f:12.6f}")

    # Application 2: Lattice gauge theory
    print("\n" + "─" * 70)
    print("APPLICATION 2: Lattice Gauge Theory Mass Gap")
    print("─" * 70)
    print(f"\n{'n':>4s}  {'β':>6s}  {'λ₀':>12s}  {'mass gap':>12s}  {'ξ':>10s}")
    print("─" * 50)
    for n_group in [4, 8, 16]:
        for beta in [0.5, 1.0, 2.0]:
            result = compute_mass_gap(n_group, beta)
            mg = result['mass_gap']
            xi = result['correlation_length']
            print(f"  {n_group:3d}  {beta:5.1f}  {result['top_eigenvalue']:12.4f}  "
                  f"{mg:12.6f}  {xi:10.4f}")

    # Application 3: Mixing times
    print("\n" + "─" * 70)
    print("APPLICATION 3: Markov Chain Mixing Times")
    print("─" * 70)
    print(f"\n{'n':>4s}  {'β':>6s}  {'t_mix':>12s}")
    print("─" * 28)
    for n_group in [4, 8]:
        for beta in [0.5, 1.0, 2.0]:
            T = lattice_gauge_transfer_matrix(n_group, beta)
            tmix = mixing_time_estimate(T)
            print(f"  {n_group:3d}  {beta:5.1f}  {tmix:12.4f}")

    print("\n" + "=" * 70)
    print("All applications demonstrated successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Reflection Positivity and Transfer Matrix Spectral Gap Demo
============================================================

This script demonstrates the core mathematical concepts from the formalized
theory of reflection positivity and Perron-Frobenius spectral gaps for
transfer matrices in lattice gauge theory.

It constructs explicit transfer matrices for finite models, computes
eigenvalues, and demonstrates the spectral gap as a function of coupling β.
"""

import numpy as np
from typing import Tuple, List

# =============================================================================
# Section 1: Transfer Matrix Construction
# =============================================================================

def wilson_transfer_matrix_2point(beta: float) -> np.ndarray:
    """
    Construct the 2-point Wilson transfer matrix.

    T[i,j] = exp(beta * w(i,j)) where w(i,j) = 1 if i==j, -1 otherwise.
    This is the simplest nontrivial model of a lattice gauge transfer matrix.

    Parameters
    ----------
    beta : float
        Coupling constant (inverse temperature). Must be > 0.

    Returns
    -------
    np.ndarray
        2x2 symmetric positive matrix with all positive entries.
    """
    T = np.array([
        [np.exp(beta), np.exp(-beta)],
        [np.exp(-beta), np.exp(beta)]
    ])
    return T


def wilson_transfer_matrix_npoint(n: int, beta: float) -> np.ndarray:
    """
    Construct an n-point Wilson transfer matrix.

    T[i,j] = exp(beta * cos(2*pi*(i-j)/n)) which models a discretized
    SU(2)-like plaquette interaction on a cyclic configuration space.

    Parameters
    ----------
    n : int
        Number of discrete configurations (approximating the gauge group).
    beta : float
        Coupling constant.

    Returns
    -------
    np.ndarray
        nxn symmetric positive matrix.
    """
    T = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            T[i, j] = np.exp(beta * np.cos(2 * np.pi * (i - j) / n))
    return T


# =============================================================================
# Section 2: Spectral Analysis
# =============================================================================

def compute_spectral_gap(T: np.ndarray) -> Tuple[float, float, float]:
    """
    Compute the spectral gap of a symmetric matrix.

    Returns the top eigenvalue, second eigenvalue, and their difference.

    Parameters
    ----------
    T : np.ndarray
        A symmetric matrix.

    Returns
    -------
    Tuple[float, float, float]
        (lambda_0, lambda_1, gap) where gap = lambda_0 - lambda_1.
    """
    eigenvalues = np.sort(np.linalg.eigvalsh(T))[::-1]
    lambda_0 = eigenvalues[0]
    lambda_1 = eigenvalues[1] if len(eigenvalues) > 1 else 0.0
    gap = lambda_0 - lambda_1
    return lambda_0, lambda_1, gap


def verify_positivity_improving(T: np.ndarray) -> bool:
    """
    Check that T is positivity improving: all entries are strictly positive.

    Parameters
    ----------
    T : np.ndarray
        Matrix to check.

    Returns
    -------
    bool
        True if all entries are > 0.
    """
    return np.all(T > 0)


def verify_symmetry(T: np.ndarray, tol: float = 1e-12) -> bool:
    """
    Check that T is symmetric.
    """
    return np.allclose(T, T.T, atol=tol)


def verify_os_positivity(K: np.ndarray, theta: np.ndarray) -> bool:
    """
    Verify reflection positivity of kernel K with involution theta.

    Checks that the transfer matrix T[i,j] = K[theta[i], j] is positive
    semidefinite by checking all eigenvalues are >= -epsilon.

    Parameters
    ----------
    K : np.ndarray
        Kernel matrix.
    theta : np.ndarray
        Involution as a permutation array.

    Returns
    -------
    bool
        True if the OS quadratic form is nonneg (T is PSD).
    """
    n = K.shape[0]
    T = np.array([[K[theta[i], j] for j in range(n)] for i in range(n)])
    eigenvalues = np.linalg.eigvalsh(T)
    return np.all(eigenvalues >= -1e-10)


# =============================================================================
# Section 3: Main Demo
# =============================================================================

def main():
    print("=" * 70)
    print("REFLECTION POSITIVITY & TRANSFER MATRIX SPECTRAL GAP DEMO")
    print("=" * 70)
    print()

    # --- Demo 1: 2-point model ---
    print("─" * 70)
    print("DEMO 1: Two-Point Wilson Transfer Matrix")
    print("─" * 70)
    beta = 1.0
    T2 = wilson_transfer_matrix_2point(beta)
    print(f"\nCoupling β = {beta}")
    print(f"Transfer matrix T =")
    print(f"  [{T2[0,0]:.6f}  {T2[0,1]:.6f}]")
    print(f"  [{T2[1,0]:.6f}  {T2[1,1]:.6f}]")

    lam0, lam1, gap = compute_spectral_gap(T2)
    print(f"\nTop eigenvalue λ₀ = {lam0:.6f}")
    print(f"Second eigenvalue λ₁ = {lam1:.6f}")
    print(f"Spectral gap Δ = λ₀ - λ₁ = {gap:.6f}")
    print(f"Symmetric: {verify_symmetry(T2)}")
    print(f"Positivity improving: {verify_positivity_improving(T2)}")
    print(f"For the 2-point model: Δ = 2·sinh(β) = {2*np.sinh(beta):.6f}")

    # --- Demo 2: n-point model ---
    print()
    print("─" * 70)
    print("DEMO 2: N-Point Wilson Transfer Matrix (Discretized SU(2))")
    print("─" * 70)
    for n in [4, 8, 16]:
        T = wilson_transfer_matrix_npoint(n, beta)
        lam0, lam1, gap = compute_spectral_gap(T)
        print(f"\n  n = {n:3d}: λ₀ = {lam0:.6f}, λ₁ = {lam1:.6f}, "
              f"Δ = {gap:.6f}, PI = {verify_positivity_improving(T)}")

    # --- Demo 3: Gap vs β ---
    print()
    print("─" * 70)
    print("DEMO 3: Spectral Gap as a Function of Coupling β")
    print("─" * 70)
    print(f"\n{'β':>8s}  {'λ₀':>12s}  {'λ₁':>12s}  {'Δ':>12s}  {'Δ/λ₀':>8s}")
    print("─" * 58)

    betas = np.linspace(0.1, 5.0, 20)
    gaps = []
    normalized_gaps = []
    for b in betas:
        T = wilson_transfer_matrix_npoint(8, b)
        lam0, lam1, gap = compute_spectral_gap(T)
        gaps.append(gap)
        ng = gap / lam0 if lam0 > 0 else 0
        normalized_gaps.append(ng)
        print(f"  {b:6.2f}  {lam0:12.6f}  {lam1:12.6f}  {gap:12.6f}  {ng:8.4f}")

    # --- Demo 4: Monotonicity conjecture test ---
    print()
    print("─" * 70)
    print("DEMO 4: Testing Monotonicity Conjecture")
    print("─" * 70)
    print("\nConjecture: The normalized gap Δ/λ₀ is monotonically decreasing in β")
    print("(stronger coupling → smaller relative excitation gap)")

    monotone = True
    violations = []
    for i in range(1, len(normalized_gaps)):
        if normalized_gaps[i] > normalized_gaps[i-1] + 1e-10:
            monotone = False
            violations.append((betas[i-1], betas[i],
                              normalized_gaps[i-1], normalized_gaps[i]))

    if monotone:
        print("✓ Conjecture holds for all tested β values (n=8 model)")
    else:
        print("✗ Conjecture VIOLATED at:")
        for b1, b2, g1, g2 in violations:
            print(f"  β = {b1:.2f} → {b2:.2f}: Δ/λ₀ = {g1:.6f} → {g2:.6f}")

    # --- Demo 5: Reflection positivity verification ---
    print()
    print("─" * 70)
    print("DEMO 5: Reflection Positivity Verification")
    print("─" * 70)
    n = 4
    T = wilson_transfer_matrix_npoint(n, 1.5)
    # For a symmetric matrix, any involution works - use identity
    theta_id = np.arange(n)
    # Use reversal as a nontrivial involution
    theta_rev = np.arange(n)[::-1]

    print(f"\n4-point model at β = 1.5:")
    print(f"  OS positive (θ = identity): {verify_os_positivity(T, theta_id)}")
    print(f"  OS positive (θ = reversal): {verify_os_positivity(T, theta_rev)}")
    print(f"  All entries positive: {verify_positivity_improving(T)}")

    eigenvalues = np.sort(np.linalg.eigvalsh(T))[::-1]
    print(f"  Eigenvalues: {eigenvalues}")
    print(f"  Gap: {eigenvalues[0] - eigenvalues[1]:.6f}")

    # --- Demo 6: Log-convexity test ---
    print()
    print("─" * 70)
    print("DEMO 6: Log-Convexity of Top Eigenvalue")
    print("─" * 70)
    betas_fine = np.linspace(0.1, 5.0, 100)
    log_tops = []
    for b in betas_fine:
        T = wilson_transfer_matrix_npoint(8, b)
        lam0 = np.max(np.linalg.eigvalsh(T))
        log_tops.append(np.log(lam0))

    # Check convexity by second differences
    log_tops = np.array(log_tops)
    second_diffs = log_tops[2:] - 2 * log_tops[1:-1] + log_tops[:-2]
    is_convex = np.all(second_diffs >= -1e-8)
    print(f"\nLog-convexity of top eigenvalue (n=8):")
    print(f"  Convex: {is_convex}")
    print(f"  Min second difference: {np.min(second_diffs):.2e}")
    print(f"  Max second difference: {np.max(second_diffs):.2e}")

    print()
    print("=" * 70)
    print("DEMO COMPLETE")
    print("=" * 70)
    print()
    print("Summary of verified properties:")
    print("  1. Wilson transfer matrices have all positive entries (proved in Lean)")
    print("  2. Positive entries ⟹ positivity improving (proved in Lean)")
    print("  3. Reflection positivity ⟹ PSD transfer matrix (proved in Lean)")
    print("  4. Simple top eigenvalue ⟹ positive spectral gap (proved in Lean)")
    print("  5. Factored kernels are reflection positive (proved in Lean)")
    print()
    print("Key insight: The chain")
    print("  Reflection Positivity → Transfer Matrix PSD → Perron-Frobenius")
    print("  → Simple Top Eigenvalue → Mass Gap")
    print("is the finite-volume doorway to the Yang-Mills mass gap problem.")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""Generate PACKAGE.json from all deliverables."""
import json

# Read all files
with open('ARTICLE.md') as f: article = f.read()
with open('RESEARCH_PAPER.md') as f: research_paper = f.read()
with open('FUTURE_DIRECTIONS.md') as f: future_directions = f.read()
with open('demo.py') as f: demo_code = f.read()
with open('algorithms.py') as f: algo_code = f.read()
with open('applications.py') as f: app_code = f.read()
with open('visualize_spectral_gap.py') as f: viz1 = f.read()
with open('visualize_transfer_matrix.py') as f: viz2 = f.read()
with open('visualize_os_bridge.py') as f: viz3 = f.read()
with open('Pythagorean/ReflectionPositivity.lean') as f: lean_code = f.read()

interactive_html = """<div style="font-family: Arial, sans-serif; max-width: 700px; margin: 0 auto; padding: 20px;">
  <h3 style="color: #1565C0;">Transfer Matrix Spectral Gap Explorer</h3>
  <p>Adjust the coupling strength &beta; and configuration space size n to see how the spectral gap changes.</p>
  <div style="margin: 15px 0;">
    <label>&beta; (coupling): <span id="beta-val">1.0</span></label><br>
    <input type="range" id="beta-slider" min="0.1" max="5.0" step="0.1" value="1.0" style="width:100%">
  </div>
  <div style="margin: 15px 0;">
    <label>n (size): <span id="n-val">4</span></label><br>
    <input type="range" id="n-slider" min="2" max="8" step="1" value="4" style="width:100%">
  </div>
  <canvas id="matrix-canvas" width="300" height="300" style="border:1px solid #ccc; display:block; margin:10px auto;"></canvas>
  <div id="results" style="background:#f5f5f5; padding:15px; border-radius:8px; margin-top:10px;">
    <p><strong>&lambda;<sub>0</sub></strong> = <span id="lam0">-</span></p>
    <p><strong>&lambda;<sub>1</sub></strong> = <span id="lam1">-</span></p>
    <p><strong>Gap &Delta;</strong> = <span id="gap" style="color:#C62828; font-weight:bold;">-</span></p>
    <p><strong>All entries &gt; 0:</strong> <span id="pos" style="color:#2E7D32;">-</span></p>
  </div>
  <script>
    function buildMatrix(n, beta) {
      let T = [];
      for (let i = 0; i < n; i++) {
        T[i] = [];
        for (let j = 0; j < n; j++) {
          T[i][j] = Math.exp(beta * Math.cos(2 * Math.PI * (i - j) / n));
        }
      }
      return T;
    }
    function deflatedPower(T, n, lam0, v0) {
      let T2 = T.map(row => [...row]);
      for (let i = 0; i < n; i++)
        for (let j = 0; j < n; j++)
          T2[i][j] -= lam0 * v0[i] * v0[j];
      let v = new Array(n).fill(0);
      v[0] = 1; if(n>1) v[1] = -1;
      let lam = 0;
      for (let iter = 0; iter < 200; iter++) {
        let w = new Array(n).fill(0);
        for (let i = 0; i < n; i++)
          for (let j = 0; j < n; j++)
            w[i] += T2[i][j] * v[j];
        let norm = Math.sqrt(w.reduce((s,x) => s+x*x, 0));
        if (norm < 1e-10) break;
        lam = norm;
        v = w.map(x => x/norm);
      }
      return lam;
    }
    function update() {
      let beta = parseFloat(document.getElementById("beta-slider").value);
      let n = parseInt(document.getElementById("n-slider").value);
      document.getElementById("beta-val").textContent = beta.toFixed(1);
      document.getElementById("n-val").textContent = n;
      let T = buildMatrix(n, beta);
      let canvas = document.getElementById("matrix-canvas");
      let ctx = canvas.getContext("2d");
      let maxVal = 0;
      for (let i = 0; i < n; i++)
        for (let j = 0; j < n; j++)
          maxVal = Math.max(maxVal, T[i][j]);
      let cellW = canvas.width / n;
      let cellH = canvas.height / n;
      for (let i = 0; i < n; i++) {
        for (let j = 0; j < n; j++) {
          let intensity = Math.floor(255 * (1 - T[i][j] / maxVal));
          ctx.fillStyle = "rgb(255, " + intensity + ", " + Math.floor(intensity*0.6) + ")";
          ctx.fillRect(j * cellW, i * cellH, cellW, cellH);
          ctx.strokeStyle = "#fff";
          ctx.strokeRect(j * cellW, i * cellH, cellW, cellH);
        }
      }
      let v0 = new Array(n).fill(1/Math.sqrt(n));
      let lam0 = 0;
      for (let iter = 0; iter < 300; iter++) {
        let w = new Array(n).fill(0);
        for (let i = 0; i < n; i++)
          for (let j = 0; j < n; j++)
            w[i] += T[i][j] * v0[j];
        let norm = Math.sqrt(w.reduce((s,x) => s+x*x, 0));
        lam0 = norm;
        v0 = w.map(x => x/norm);
      }
      let lam1 = deflatedPower(T, n, lam0, v0);
      document.getElementById("lam0").textContent = lam0.toFixed(4);
      document.getElementById("lam1").textContent = lam1.toFixed(4);
      document.getElementById("gap").textContent = (lam0 - lam1).toFixed(4);
      document.getElementById("pos").textContent = "Yes (exp always > 0)";
    }
    document.getElementById("beta-slider").addEventListener("input", update);
    document.getElementById("n-slider").addEventListener("input", update);
    update();
  </script>
</div>"""

package = {
    'title': 'Reflection Positivity and Perron-Frobenius for the Transfer Matrix',
    'domain': 'Mathematical Physics / Spectral Theory / Lattice Gauge Theory',
    'article': article,
    'research_paper': research_paper,
    'future_directions': future_directions,
    'demos': [
        {
            'name': 'Transfer Matrix Spectral Gap Demo',
            'code': demo_code
        },
        {
            'name': 'Applications: Ising Model, Gauge Theory, Mixing Times',
            'code': app_code
        }
    ],
    'algorithms': [
        {
            'name': 'Wilson Transfer Matrix Construction & Certified Gap',
            'pseudocode': (
                'Algorithm 1: Build Transfer Matrix\n'
                'Input: n (group size), beta (coupling), w (weight)\n'
                'Output: T in R^{n x n}\n'
                'for i,j: T[i,j] = exp(beta * w(i,j))\n'
                'Complexity: O(n^2)\n\n'
                'Algorithm 2: Certified Spectral Gap\n'
                'Input: T symmetric positive matrix\n'
                '1. Verify symmetry, positivity\n'
                '2. Compute eigenvalues via eigh\n'
                '3. gap = lambda_0 - lambda_1\n'
                '4. Certify Perron vector positivity\n'
                'Complexity: O(n^3)'
            ),
            'code': algo_code
        }
    ],
    'visualizations': [
        {
            'name': 'Spectral Gap vs Coupling Strength',
            'code': viz1,
            'description': 'Four-panel plot showing eigenvalues, spectral gap, normalized gap, and log-top-eigenvalue as functions of coupling beta for different discretization sizes.'
        },
        {
            'name': 'Transfer Matrix Structure and Perron Vector',
            'code': viz2,
            'description': 'Transfer matrix heatmaps, eigenvalue spectra, and Perron-Frobenius eigenvectors for different coupling strengths.'
        },
        {
            'name': 'OS Positivity to Mass Gap Bridge',
            'code': viz3,
            'description': 'OS quadratic form values (all nonneg), Gram factorization, and the logical chain from reflection positivity to mass gap.'
        }
    ],
    'interactive_demos': [
        {
            'name': 'Transfer Matrix Explorer',
            'html': interactive_html,
            'description': 'Interactive explorer: adjust coupling beta and size n to visualize the transfer matrix and compute spectral gap in real-time.'
        }
    ],
    'lean_proofs': lean_code
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print('PACKAGE.json written successfully')
print(f'File size: {len(json.dumps(package))} chars')


#!/usr/bin/env python3
"""
Visualization: The OS Positivity → Mass Gap Bridge
====================================================

Illustrates the logical chain proven in Lean:
  Reflection Positivity → PSD Transfer Matrix → Positivity Improving
  → Perron-Frobenius → Simple Top Eigenvalue → Mass Gap

Shows:
1. The OS quadratic form as a function of test functions
2. The factored kernel "sum of squares" structure
3. How the chain produces the mass gap
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches


def build_wilson_transfer_matrix(n: int, beta: float) -> np.ndarray:
    T = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            T[i, j] = np.exp(beta * np.cos(2 * np.pi * (i - j) / n))
    return T


def evaluate_os_form(K, theta, f):
    n = len(f)
    result = 0.0
    for x in range(n):
        for y in range(n):
            result += f[x] * K[theta[x], y] * f[y]
    return result


fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Panel 1: OS form values for random test functions
ax = axes[0]
n = 8
beta = 1.5
T = build_wilson_transfer_matrix(n, beta)
theta = np.arange(n)  # identity involution

os_values = []
for _ in range(500):
    f = np.random.randn(n)
    val = evaluate_os_form(T, theta, f)
    os_values.append(val)

ax.hist(os_values, bins=50, color='#2196F3', alpha=0.7, edgecolor='navy')
ax.axvline(x=0, color='red', linewidth=2, linestyle='--', label='Zero threshold')
min_val = min(os_values)
ax.axvline(x=min_val, color='orange', linewidth=1.5, linestyle=':',
           label=f'Minimum = {min_val:.2f}')
ax.set_xlabel('OS Quadratic Form Q(f)', fontsize=12)
ax.set_ylabel('Count', fontsize=12)
ax.set_title('OS Form Values (500 random f)\nAll ≥ 0 ⟹ Reflection Positive', fontsize=12)
ax.legend(fontsize=10)

# Panel 2: Gram factorization visualization
ax = axes[1]
# Show that T = L @ L^T for the transfer matrix
eigenvalues, eigenvectors = np.linalg.eigh(T)
eigenvalues_pos = np.maximum(eigenvalues, 0)
L = eigenvectors @ np.diag(np.sqrt(eigenvalues_pos))
reconstruction = L @ L.T
error = np.max(np.abs(T - reconstruction))

im = ax.imshow(L, cmap='RdBu_r', aspect='auto')
ax.set_xlabel('Factor index k', fontsize=12)
ax.set_ylabel('Configuration x', fontsize=12)
ax.set_title(f'Gram Factor L: T = LLᵀ\n(reconstruction error: {error:.1e})', fontsize=12)
plt.colorbar(im, ax=ax, shrink=0.8)

# Panel 3: The logical chain as a flow diagram
ax = axes[2]
ax.set_xlim(0, 10)
ax.set_ylim(0, 10)
ax.axis('off')

steps = [
    (5, 9.0, 'Reflection\nPositivity', '#E3F2FD', '#1565C0'),
    (5, 7.2, 'PSD Transfer\nMatrix', '#E8F5E9', '#2E7D32'),
    (5, 5.4, 'Positivity\nImproving', '#FFF3E0', '#E65100'),
    (5, 3.6, 'Perron-Frobenius\n(Simple Top λ)', '#FCE4EC', '#C62828'),
    (5, 1.8, 'MASS GAP\nΔ > 0', '#F3E5F5', '#6A1B9A'),
]

for x, y, text, facecolor, edgecolor in steps:
    box = mpatches.FancyBboxPatch((x-2.3, y-0.65), 4.6, 1.3,
                                   boxstyle="round,pad=0.15",
                                   facecolor=facecolor,
                                   edgecolor=edgecolor,
                                   linewidth=2)
    ax.add_patch(box)
    ax.text(x, y, text, ha='center', va='center',
            fontsize=11, fontweight='bold', color=edgecolor)

# Arrows
for i in range(len(steps) - 1):
    ax.annotate('', xy=(5, steps[i+1][1] + 0.7),
                xytext=(5, steps[i][1] - 0.7),
                arrowprops=dict(arrowstyle='->', color='#424242',
                              lw=2.5, connectionstyle='arc3'))

# Side annotations
annotations = [
    (9.5, 8.1, 'Gram factorization\n(sum of squares)', '#1565C0'),
    (9.5, 6.3, 'Quadratic form\n≥ 0', '#2E7D32'),
    (9.5, 4.5, 'All entries > 0\n(Wilson kernel)', '#E65100'),
    (9.5, 2.7, 'Unique vacuum\nstate', '#C62828'),
]

for x, y, text, color in annotations:
    ax.text(x, y, text, ha='center', va='center',
            fontsize=8, color=color, style='italic')

ax.set_title('The OS → Mass Gap Bridge\n(Each step proved in Lean 4)', fontsize=13,
             fontweight='bold')

plt.suptitle('Reflection Positivity: From Euclidean Symmetry to Mass Gap',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('os_bridge_visualization.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: os_bridge_visualization.png")


#!/usr/bin/env python3
"""
Visualization: Spectral Gap vs Coupling Strength
=================================================

Visualizes the key result: how the spectral gap of the Wilson transfer matrix
depends on the coupling constant β, for various discretization sizes.
This illustrates the finite-volume mass gap that was formally proved to exist.

The plot shows:
- Top eigenvalue λ₀ and second eigenvalue λ₁ vs β
- The spectral gap Δ = λ₀ - λ₁ vs β
- The normalized gap Δ/λ₀ vs β (monotonically decreasing - the conjecture)
"""

import numpy as np
import matplotlib.pyplot as plt


def build_wilson_transfer_matrix(n: int, beta: float) -> np.ndarray:
    """Build Wilson transfer matrix with cyclic cosine weight."""
    T = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            T[i, j] = np.exp(beta * np.cos(2 * np.pi * (i - j) / n))
    return T


def compute_spectral_data(n: int, betas: np.ndarray):
    """Compute eigenvalue data for a range of β values."""
    lam0s, lam1s, gaps, norm_gaps = [], [], [], []
    for beta in betas:
        T = build_wilson_transfer_matrix(n, beta)
        eigs = np.sort(np.linalg.eigvalsh(T))[::-1]
        lam0s.append(eigs[0])
        lam1s.append(eigs[1])
        gaps.append(eigs[0] - eigs[1])
        norm_gaps.append((eigs[0] - eigs[1]) / eigs[0])
    return np.array(lam0s), np.array(lam1s), np.array(gaps), np.array(norm_gaps)


# Generate data
betas = np.linspace(0.05, 5.0, 200)
sizes = [4, 8, 16]
colors = ['#2196F3', '#FF5722', '#4CAF50']

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Panel 1: Eigenvalues vs β
ax = axes[0, 0]
for n, color in zip(sizes, colors):
    lam0, lam1, _, _ = compute_spectral_data(n, betas)
    ax.plot(betas, lam0, '-', color=color, linewidth=2, label=f'λ₀ (n={n})')
    ax.plot(betas, lam1, '--', color=color, linewidth=1.5, label=f'λ₁ (n={n})')
ax.set_xlabel('Coupling β', fontsize=12)
ax.set_ylabel('Eigenvalue', fontsize=12)
ax.set_title('Top Two Eigenvalues of Transfer Matrix', fontsize=13)
ax.legend(fontsize=9, ncol=2)
ax.set_yscale('log')
ax.grid(True, alpha=0.3)

# Panel 2: Spectral gap vs β
ax = axes[0, 1]
for n, color in zip(sizes, colors):
    _, _, gaps, _ = compute_spectral_data(n, betas)
    ax.plot(betas, gaps, '-', color=color, linewidth=2, label=f'n={n}')
ax.set_xlabel('Coupling β', fontsize=12)
ax.set_ylabel('Spectral Gap Δ = λ₀ - λ₁', fontsize=12)
ax.set_title('Spectral Gap (Mass Gap) vs Coupling', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 3: Normalized gap vs β (monotonicity test)
ax = axes[1, 0]
for n, color in zip(sizes, colors):
    _, _, _, norm_gaps = compute_spectral_data(n, betas)
    ax.plot(betas, norm_gaps, '-', color=color, linewidth=2, label=f'n={n}')
ax.set_xlabel('Coupling β', fontsize=12)
ax.set_ylabel('Normalized Gap Δ/λ₀', fontsize=12)
ax.set_title('Normalized Gap (Monotonicity Conjecture)', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_ylim(0, 1)

# Panel 4: Log of top eigenvalue (convexity test)
ax = axes[1, 1]
for n, color in zip(sizes, colors):
    lam0, _, _, _ = compute_spectral_data(n, betas)
    ax.plot(betas, np.log(lam0), '-', color=color, linewidth=2, label=f'n={n}')
ax.set_xlabel('Coupling β', fontsize=12)
ax.set_ylabel('log(λ₀)', fontsize=12)
ax.set_title('Log Top Eigenvalue (Convexity = Free Energy)', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.suptitle('Reflection Positivity → Spectral Gap: The OS-to-Operator Bridge',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('spectral_gap_visualization.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: spectral_gap_visualization.png")


#!/usr/bin/env python3
"""
Visualization: Transfer Matrix Structure and Perron-Frobenius Eigenvector
=========================================================================

Visualizes the structure of Wilson transfer matrices and their Perron-Frobenius
eigenvectors. Shows how positive entries guarantee a unique positive ground state.

The heatmaps show:
- Transfer matrix entries (all positive, confirming positivity-improving)
- Perron-Frobenius eigenvector (all positive entries - the unique vacuum state)
- Eigenvalue spectrum
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec


def build_wilson_transfer_matrix(n: int, beta: float) -> np.ndarray:
    """Build Wilson transfer matrix with cyclic cosine weight."""
    T = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            T[i, j] = np.exp(beta * np.cos(2 * np.pi * (i - j) / n))
    return T


fig = plt.figure(figsize=(16, 12))
gs = gridspec.GridSpec(3, 4, hspace=0.4, wspace=0.4)

betas = [0.5, 1.0, 2.0, 4.0]
n = 8

for col, beta in enumerate(betas):
    T = build_wilson_transfer_matrix(n, beta)
    eigenvalues, eigenvectors = np.linalg.eigh(T)
    idx = np.argsort(eigenvalues)[::-1]
    eigenvalues = eigenvalues[idx]
    eigenvectors = eigenvectors[:, idx]

    # Ensure Perron vector is positive
    perron = eigenvectors[:, 0]
    if perron[0] < 0:
        perron = -perron

    # Row 1: Transfer matrix heatmap
    ax = fig.add_subplot(gs[0, col])
    im = ax.imshow(T, cmap='YlOrRd', aspect='equal')
    ax.set_title(f'β = {beta}', fontsize=13, fontweight='bold')
    if col == 0:
        ax.set_ylabel('Transfer Matrix T', fontsize=11)
    ax.set_xticks([])
    ax.set_yticks([])
    plt.colorbar(im, ax=ax, shrink=0.8)

    # Row 2: Eigenvalue spectrum
    ax = fig.add_subplot(gs[1, col])
    colors_eig = ['#FF5722' if i == 0 else '#2196F3' for i in range(len(eigenvalues))]
    ax.bar(range(len(eigenvalues)), eigenvalues, color=colors_eig, alpha=0.8)
    ax.set_xlabel('Eigenvalue index', fontsize=10)
    if col == 0:
        ax.set_ylabel('Eigenvalue', fontsize=11)
    gap = eigenvalues[0] - eigenvalues[1]
    ax.annotate(f'Gap = {gap:.2f}', xy=(0.5, eigenvalues[0]),
                fontsize=8, ha='center', va='bottom',
                color='#FF5722', fontweight='bold')

    # Row 3: Perron vector
    ax = fig.add_subplot(gs[2, col])
    ax.bar(range(n), perron, color='#4CAF50', alpha=0.8)
    ax.axhline(y=0, color='black', linewidth=0.5)
    ax.set_xlabel('Configuration index', fontsize=10)
    if col == 0:
        ax.set_ylabel('Perron Vector', fontsize=11)
    all_pos = np.all(perron > 0)
    ax.set_title(f'All positive: {all_pos}', fontsize=10,
                color='green' if all_pos else 'red')

fig.suptitle('Wilson Transfer Matrix: Structure, Spectrum & Perron Vector\n'
             '(n=8 discretized gauge model)',
             fontsize=15, fontweight='bold', y=1.02)

plt.savefig('transfer_matrix_structure.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: transfer_matrix_structure.png")
