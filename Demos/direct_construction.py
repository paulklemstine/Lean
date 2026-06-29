#!/usr/bin/env python3
"""
Applications of Polynomial Interpolation as a Linear Equivalence

Demonstrates real-world applications in:
  1. Secret sharing (Shamir's scheme)
  2. Signal reconstruction from samples
  3. Symbolic regression on finite domains
  4. Error-correcting codes for data storage
"""

import numpy as np
from algorithms import LagrangeInterpolator, ReedSolomonCode


def app_shamir_secret_sharing():
    """
    Application 1: Shamir's Secret Sharing Scheme
    
    A (t, n)-threshold scheme: distribute n shares such that any t shares
    can reconstruct the secret, but fewer than t reveal nothing.
    
    The secret is the constant term of a random degree-(t-1) polynomial.
    Shares are evaluations at distinct nonzero points.
    Reconstruction uses the inverse of the evaluation map (interpolation).
    """
    print("=" * 60)
    print("APPLICATION 1: Shamir's Secret Sharing")
    print("=" * 60)
    
    secret = 42
    threshold = 3  # minimum shares needed
    num_shares = 5  # total shares distributed
    
    # Create a random polynomial with p(0) = secret
    np.random.seed(2026)
    coeffs = np.zeros(threshold)
    coeffs[0] = secret
    coeffs[1:] = np.random.randint(1, 100, threshold - 1)
    
    print(f"Secret: {secret}")
    print(f"Threshold: {threshold} of {num_shares}")
    print(f"Secret polynomial: p(x) = {coeffs[0]} + {coeffs[1]}x + {coeffs[2]}x²")
    
    # Generate shares as evaluations at x = 1, 2, ..., n
    share_points = np.arange(1, num_shares + 1, dtype=float)
    shares = np.array([sum(coeffs[j] * x**j for j in range(threshold))
                       for x in share_points])
    
    print(f"\nShares distributed:")
    for i in range(num_shares):
        print(f"  Share {i+1}: ({int(share_points[i])}, {shares[i]})")
    
    # Reconstruct from any 3 shares
    for subset in [[0, 1, 2], [0, 2, 4], [1, 3, 4]]:
        nodes = share_points[subset]
        values = shares[subset]
        interp = LagrangeInterpolator(nodes, values)
        recovered = interp.evaluate(0.0)  # p(0) = secret
        print(f"\n  Using shares {[s+1 for s in subset]}: recovered secret = {recovered:.0f} ✓")
    
    # Show that 2 shares are insufficient (underdetermined)
    print(f"\n  With only 2 shares, infinitely many degree-2 polynomials fit.")
    print(f"  The secret could be any value — information-theoretic security.")


def app_signal_reconstruction():
    """
    Application 2: Bandlimited Signal Reconstruction
    
    A bandlimited signal with at most n+1 frequency components can be
    perfectly reconstructed from n+1 uniformly spaced samples.
    This is the polynomial analogue of the Nyquist-Shannon theorem.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Signal Reconstruction from Samples")
    print("=" * 60)
    
    # Define a "signal" as a polynomial of degree 4
    true_coeffs = np.array([1.0, -0.5, 0.3, -0.1, 0.02])
    n = len(true_coeffs) - 1
    
    def signal(x):
        return sum(true_coeffs[k] * x**k for k in range(len(true_coeffs)))
    
    # Sample at n+1 = 5 distinct points
    sample_points = np.array([-2.0, -1.0, 0.0, 1.0, 2.0])
    samples = np.array([signal(x) for x in sample_points])
    
    print(f"True signal: p(x) = {true_coeffs[0]} - 0.5x + 0.3x² - 0.1x³ + 0.02x⁴")
    print(f"Sample points: {sample_points}")
    print(f"Sample values: {np.round(samples, 4)}")
    
    # Reconstruct via interpolation (inverse of evaluation)
    interp = LagrangeInterpolator(sample_points, samples)
    recovered_coeffs = interp.coefficients()
    
    print(f"\nRecovered coefficients: {np.round(recovered_coeffs, 8)}")
    print(f"Original coefficients:  {true_coeffs}")
    print(f"Max error: {np.max(np.abs(recovered_coeffs - true_coeffs)):.2e}")
    
    # Evaluate at intermediate points
    test_points = np.linspace(-2, 2, 9)
    print(f"\nReconstruction at intermediate points:")
    for x in test_points:
        true_val = signal(x)
        recon_val = interp.evaluate(x)
        print(f"  x={x:5.2f}: true={true_val:8.4f}, reconstructed={recon_val:8.4f}, "
              f"error={abs(true_val - recon_val):.2e}")


def app_symbolic_regression():
    """
    Application 3: Exact Symbolic Regression on Finite Domains
    
    Given function values on a finite domain, find the unique polynomial
    of minimal degree that fits the data exactly. The linear equivalence
    guarantees this is always possible and unique for degree ≤ n.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Symbolic Regression")
    print("=" * 60)
    
    # Unknown function sampled at 6 points
    sample_x = np.array([0.0, 1.0, 2.0, 3.0, 4.0, 5.0])
    sample_y = np.array([0.0, 1.0, 8.0, 27.0, 64.0, 125.0])
    
    print(f"Observed data:")
    for x, y in zip(sample_x, sample_y):
        print(f"  f({x:.0f}) = {y:.0f}")
    
    interp = LagrangeInterpolator(sample_x, sample_y)
    coeffs = interp.coefficients()
    
    print(f"\nRecovered polynomial coefficients:")
    for i, c in enumerate(coeffs):
        if abs(c) > 1e-10:
            print(f"  x^{i}: {c:+.6f}")
        else:
            print(f"  x^{i}:  0 (< 1e-10)")
    
    # The function is f(x) = x³
    print(f"\nConclusion: f(x) = x³")
    print(f"Verification: f(6) = {interp.evaluate(6.0):.0f} (expected 216)")
    print(f"\nThe linear equivalence guarantees this is the UNIQUE polynomial")
    print(f"of degree ≤ 5 matching all 6 data points.")


def app_data_storage():
    """
    Application 4: Reliable Data Storage with Reed-Solomon Codes
    
    Store data across multiple drives with redundancy.
    If some drives fail, the data can be recovered exactly.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Reliable Data Storage")
    print("=" * 60)
    
    # Data: 4 values to store reliably across 7 drives
    data = np.array([3.14, 2.72, 1.41, 1.73])
    n_drives = 7
    
    rs = ReedSolomonCode(np.arange(1, n_drives + 1, dtype=float), len(data))
    params = rs.parameters()
    
    print(f"Data to store: {data}")
    print(f"Code parameters: [{params['n']}, {params['k']}, {params['d']}]")
    print(f"Drives used: {n_drives}")
    print(f"Can tolerate up to {params['max_erasures']} drive failures")
    
    # Encode
    codeword = rs.encode(data)
    print(f"\nEncoded across drives:")
    for i in range(n_drives):
        print(f"  Drive {i+1}: {codeword[i]:.4f}")
    
    # Simulate 3 drive failures
    surviving = [0, 1, 3, 5]  # drives 1, 2, 4, 6 survive
    failed = [2, 4, 6]
    print(f"\nDrives {[f+1 for f in failed]} FAILED!")
    print(f"Surviving drives: {[s+1 for s in surviving]}")
    
    # Recover
    received_values = codeword[surviving]
    decoded = rs.decode_erasures(received_values, surviving)
    
    print(f"\nRecovered data: {np.round(decoded, 10)}")
    print(f"Original data:  {data}")
    print(f"Recovery successful: {np.allclose(decoded, data)}")


if __name__ == "__main__":
    app_shamir_secret_sharing()
    app_signal_reconstruction()
    app_symbolic_regression()
    app_data_storage()
    
    print("\n" + "=" * 60)
    print("All applications demonstrated successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Polynomial Interpolation as a Linear Equivalence — Demonstration

This script demonstrates the core theorem: evaluation at n+1 distinct points
gives a linear equivalence between degree-≤n polynomials and function values,
with Lagrange interpolation as the explicit inverse.
"""

import numpy as np
from numpy.polynomial import polynomial as P

def lagrange_basis(nodes, i, x):
    """Compute the i-th Lagrange basis polynomial at x."""
    n = len(nodes)
    result = 1.0
    for j in range(n):
        if j != i:
            result *= (x - nodes[j]) / (nodes[i] - nodes[j])
    return result

def lagrange_interpolate(nodes, values, x):
    """Evaluate the Lagrange interpolant at x."""
    return sum(values[i] * lagrange_basis(nodes, i, x) for i in range(len(nodes)))

def lagrange_coefficients(nodes, values):
    """Return the coefficient vector of the Lagrange interpolant."""
    n = len(nodes)
    coeffs = np.zeros(n)
    for i in range(n):
        # Build basis polynomial i as coefficient vector
        basis = np.array([1.0])
        for j in range(n):
            if j != i:
                # Multiply by (x - nodes[j]) / (nodes[i] - nodes[j])
                factor = np.array([-nodes[j], 1.0]) / (nodes[i] - nodes[j])
                basis = np.convolve(basis, factor)
        coeffs += values[i] * basis
    return coeffs


def vandermonde_matrix(nodes):
    """Build the Vandermonde matrix for the given nodes."""
    n = len(nodes)
    V = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            V[i, j] = nodes[i] ** j
    return V


def demo_basic_interpolation():
    """Demo 1: Basic round-trip verification."""
    print("=" * 60)
    print("DEMO 1: Basic Round-Trip Verification")
    print("=" * 60)
    
    nodes = np.array([1.0, 2.0, 3.0, 4.0])
    n = len(nodes) - 1  # degree bound
    print(f"\nNodes: {nodes}")
    print(f"Degree bound: ≤ {n}")
    
    # Start with a polynomial p(x) = 2 + 3x - x^2 + 0.5x^3
    coeffs_original = np.array([2.0, 3.0, -1.0, 0.5])
    print(f"Original polynomial coefficients: {coeffs_original}")
    print(f"  p(x) = {coeffs_original[0]} + {coeffs_original[1]}x + ({coeffs_original[2]})x² + {coeffs_original[3]}x³")
    
    # Step 1: Evaluate at nodes (forward map)
    values = np.array([np.polyval(coeffs_original[::-1], x) for x in nodes])
    print(f"\nEvaluation (forward map):")
    for i, (node, val) in enumerate(zip(nodes, values)):
        print(f"  p({node}) = {val}")
    
    # Step 2: Interpolate back (inverse map)
    coeffs_recovered = lagrange_coefficients(nodes, values)
    print(f"\nRecovered coefficients via interpolation: {coeffs_recovered}")
    
    # Verify round-trip
    error = np.max(np.abs(coeffs_original - coeffs_recovered))
    print(f"Max coefficient error: {error:.2e}")
    print(f"Round-trip successful: {error < 1e-10}")
    
    # Step 3: Start from values (right inverse)
    print(f"\n--- Right inverse: values → interpolate → evaluate ---")
    random_values = np.array([7.0, -3.0, 11.0, 2.5])
    print(f"Given values: {random_values}")
    
    interp_coeffs = lagrange_coefficients(nodes, random_values)
    print(f"Interpolant coefficients: {np.round(interp_coeffs, 6)}")
    
    recovered_values = np.array([np.polyval(interp_coeffs[::-1], x) for x in nodes])
    print(f"Evaluated back at nodes: {np.round(recovered_values, 10)}")
    
    error2 = np.max(np.abs(random_values - recovered_values))
    print(f"Max value error: {error2:.2e}")
    print(f"Right inverse verified: {error2 < 1e-10}")


def demo_vandermonde():
    """Demo 2: Connection to Vandermonde matrix invertibility."""
    print("\n" + "=" * 60)
    print("DEMO 2: Vandermonde Matrix Invertibility")
    print("=" * 60)
    
    nodes = np.array([0.0, 1.0, 3.0, 7.0])
    n = len(nodes)
    
    V = vandermonde_matrix(nodes)
    print(f"\nNodes: {nodes}")
    print(f"Vandermonde matrix V:")
    for row in V:
        print(f"  {np.round(row, 2)}")
    
    det = np.linalg.det(V)
    print(f"\ndet(V) = {det:.4f}")
    
    # Vandermonde determinant = product of (x_j - x_i) for j > i
    expected_det = 1.0
    for i in range(n):
        for j in range(i + 1, n):
            expected_det *= (nodes[j] - nodes[i])
    print(f"Expected (Vandermonde formula): {expected_det:.4f}")
    print(f"Match: {abs(det - expected_det) < 1e-6}")
    
    # Show that V^{-1} encodes interpolation
    V_inv = np.linalg.inv(V)
    values = np.array([1.0, 2.0, 0.0, -1.0])
    coeffs_from_inv = V_inv @ values
    coeffs_from_lagrange = lagrange_coefficients(nodes, values)
    
    print(f"\nCoefficients from V⁻¹ · values:   {np.round(coeffs_from_inv, 8)}")
    print(f"Coefficients from Lagrange:        {np.round(coeffs_from_lagrange, 8)}")
    error = np.max(np.abs(coeffs_from_inv - coeffs_from_lagrange))
    print(f"Agreement: {error < 1e-10}")


def demo_linearity():
    """Demo 3: Linearity of both maps."""
    print("\n" + "=" * 60)
    print("DEMO 3: Linearity Verification")
    print("=" * 60)
    
    nodes = np.array([-1.0, 0.0, 1.0, 2.0])
    
    # Linearity of evaluation: eval(a*p + b*q) = a*eval(p) + b*eval(q)
    p_coeffs = np.array([1.0, 2.0, -1.0, 0.3])
    q_coeffs = np.array([0.5, -1.0, 3.0, -0.7])
    a, b = 2.5, -1.3
    
    eval_p = np.array([np.polyval(p_coeffs[::-1], x) for x in nodes])
    eval_q = np.array([np.polyval(q_coeffs[::-1], x) for x in nodes])
    
    combined_coeffs = a * p_coeffs + b * q_coeffs
    eval_combined = np.array([np.polyval(combined_coeffs[::-1], x) for x in nodes])
    
    linear_combination = a * eval_p + b * eval_q
    
    print(f"eval(a·p + b·q) = {np.round(eval_combined, 8)}")
    print(f"a·eval(p) + b·eval(q) = {np.round(linear_combination, 8)}")
    print(f"Evaluation linearity: {np.max(np.abs(eval_combined - linear_combination)) < 1e-10}")
    
    # Linearity of interpolation: interp(a*f + b*g) = a*interp(f) + b*interp(g)
    f_vals = np.array([3.0, -1.0, 5.0, 2.0])
    g_vals = np.array([0.0, 4.0, -2.0, 1.0])
    
    interp_f = lagrange_coefficients(nodes, f_vals)
    interp_g = lagrange_coefficients(nodes, g_vals)
    interp_combined = lagrange_coefficients(nodes, a * f_vals + b * g_vals)
    
    linear_interp = a * interp_f + b * interp_g
    
    print(f"\ninterp(a·f + b·g) coeffs = {np.round(interp_combined, 8)}")
    print(f"a·interp(f) + b·interp(g) = {np.round(linear_interp, 8)}")
    print(f"Interpolation linearity: {np.max(np.abs(interp_combined - linear_interp)) < 1e-10}")


def demo_reed_solomon():
    """Demo 4: Reed-Solomon encoding/decoding."""
    print("\n" + "=" * 60)
    print("DEMO 4: Reed-Solomon Encoding/Decoding")
    print("=" * 60)
    
    # Message as polynomial coefficients (degree ≤ 2, so 3 symbols)
    message = np.array([5.0, 3.0, 7.0])  # p(x) = 5 + 3x + 7x²
    print(f"Message polynomial: p(x) = {message[0]} + {message[1]}x + {message[2]}x²")
    
    # Evaluate at 5 distinct points (add redundancy)
    eval_points = np.array([1.0, 2.0, 3.0, 4.0, 5.0])
    codeword = np.array([np.polyval(message[::-1], x) for x in eval_points])
    print(f"Evaluation points: {eval_points}")
    print(f"Codeword (encoded): {codeword}")
    
    # Receive any 3 of the 5 evaluations (simulating erasure channel)
    received_indices = [0, 2, 4]  # positions 0, 2, 4
    received_nodes = eval_points[received_indices]
    received_values = codeword[received_indices]
    print(f"\nReceived {len(received_indices)} of 5 symbols at positions {received_indices}")
    print(f"Received nodes: {received_nodes}")
    print(f"Received values: {received_values}")
    
    # Decode via interpolation
    decoded = lagrange_coefficients(received_nodes, received_values)
    print(f"\nDecoded message: {np.round(decoded, 8)}")
    print(f"Original message: {message}")
    print(f"Decoding successful: {np.max(np.abs(decoded - message)) < 1e-10}")
    
    # Minimum distance
    n_eval = len(eval_points)
    k_msg = len(message)
    print(f"\nCode parameters: [{n_eval}, {k_msg}, {n_eval - k_msg + 1}] Reed-Solomon code")
    print(f"Minimum distance d = {n_eval - k_msg + 1}")
    print(f"Can correct up to {(n_eval - k_msg) // 2} errors or {n_eval - k_msg} erasures")


def demo_finite_field():
    """Demo 5: Interpolation over a finite field (GF(11))."""
    print("\n" + "=" * 60)
    print("DEMO 5: Interpolation over GF(11)")
    print("=" * 60)
    
    p = 11  # prime modulus
    
    def gf_lagrange_interpolate(nodes, values, p):
        """Lagrange interpolation in GF(p)."""
        n = len(nodes)
        coeffs = [0] * n
        for i in range(n):
            # Build basis polynomial
            basis = [1]
            for j in range(n):
                if j != i:
                    denom = pow(int(nodes[i] - nodes[j]) % p, p - 2, p)  # Fermat inverse
                    new_basis = [0] * (len(basis) + 1)
                    for k in range(len(basis)):
                        new_basis[k] = (new_basis[k] + basis[k] * ((-nodes[j]) % p)) % p
                        new_basis[k + 1] = (new_basis[k + 1] + basis[k]) % p
                    basis = [(c * denom) % p for c in new_basis]
            for k in range(len(basis)):
                if k < n:
                    coeffs[k] = (coeffs[k] + values[i] * basis[k]) % p
        return coeffs
    
    nodes = [1, 3, 5, 7]
    values = [2, 8, 4, 10]
    n = len(nodes)
    
    print(f"Working in GF({p})")
    print(f"Nodes: {nodes}")
    print(f"Values: {values}")
    
    coeffs = gf_lagrange_interpolate(nodes, values, p)
    print(f"Interpolant coefficients (mod {p}): {coeffs}")
    
    # Verify
    print("Verification:")
    for i in range(n):
        val = sum(coeffs[k] * pow(nodes[i], k, p) for k in range(n)) % p
        print(f"  p({nodes[i]}) = {val} (expected {values[i]}): {'✓' if val == values[i] else '✗'}")


if __name__ == "__main__":
    demo_basic_interpolation()
    demo_vandermonde()
    demo_linearity()
    demo_reed_solomon()
    demo_finite_field()
    
    print("\n" + "=" * 60)
    print("All demonstrations completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualizations for Polynomial Interpolation Linear Equivalence

Generates publication-quality figures illustrating:
  1. The interpolation/evaluation round-trip
  2. Lagrange basis polynomials
  3. Vandermonde matrix structure
  4. Reed-Solomon code geometry
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
import base64
from io import BytesIO


def fig_to_base64(fig):
    """Convert a matplotlib figure to base64 PNG string."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    return base64.b64encode(buf.read()).decode('utf-8')


def viz_interpolation_roundtrip():
    """Visualize the evaluation → interpolation round-trip."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    # Original polynomial
    coeffs = np.array([1.0, -2.0, 0.5, 0.3])
    nodes = np.array([-1.0, 0.0, 1.0, 2.0])
    x = np.linspace(-1.5, 2.5, 200)
    y = sum(coeffs[k] * x**k for k in range(len(coeffs)))
    values = sum(coeffs[k] * nodes**k for k in range(len(coeffs)))
    
    # Panel 1: Original polynomial
    ax = axes[0]
    ax.plot(x, y, 'b-', linewidth=2, label='p(x)')
    ax.plot(nodes, values, 'ro', markersize=10, zorder=5)
    ax.set_title('Step 1: Polynomial p(x)\n(degree ≤ 3)', fontsize=13)
    ax.set_xlabel('x')
    ax.set_ylabel('p(x)')
    ax.legend()
    ax.grid(True, alpha=0.3)
    ax.set_ylim(-3, 6)
    
    # Panel 2: Sampled values
    ax = axes[1]
    ax.bar(range(4), values, color=['#e74c3c', '#3498db', '#2ecc71', '#f39c12'],
           edgecolor='black', linewidth=1.5)
    ax.set_xticks(range(4))
    ax.set_xticklabels([f'f({n:.0f})' for n in nodes])
    ax.set_title('Step 2: Evaluate at nodes\n(forward map)', fontsize=13)
    ax.set_ylabel('Value')
    ax.grid(True, alpha=0.3, axis='y')
    
    # Panel 3: Reconstructed polynomial
    # Lagrange interpolation
    def lagrange_eval(nodes, values, x_eval):
        n = len(nodes)
        result = np.zeros_like(x_eval)
        for i in range(n):
            basis = np.ones_like(x_eval)
            for j in range(n):
                if j != i:
                    basis *= (x_eval - nodes[j]) / (nodes[i] - nodes[j])
            result += values[i] * basis
        return result
    
    y_recon = lagrange_eval(nodes, values, x)
    
    ax = axes[2]
    ax.plot(x, y_recon, 'g-', linewidth=2, label='Reconstructed')
    ax.plot(x, y, 'b--', linewidth=1, alpha=0.5, label='Original')
    ax.plot(nodes, values, 'ro', markersize=10, zorder=5)
    ax.set_title('Step 3: Interpolate back\n(inverse map)', fontsize=13)
    ax.set_xlabel('x')
    ax.legend()
    ax.grid(True, alpha=0.3)
    ax.set_ylim(-3, 6)
    
    fig.suptitle('The Evaluation–Interpolation Linear Equivalence', fontsize=15, fontweight='bold', y=1.02)
    plt.tight_layout()
    
    fig.savefig('viz_roundtrip.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


def viz_lagrange_basis():
    """Visualize the Lagrange basis polynomials."""
    nodes = np.array([0.0, 1.0, 2.5, 4.0])
    n = len(nodes)
    x = np.linspace(-0.5, 4.5, 300)
    
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))
    colors = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12']
    
    for idx in range(n):
        ax = axes[idx // 2][idx % 2]
        
        # Compute basis polynomial
        basis = np.ones_like(x)
        for j in range(n):
            if j != idx:
                basis *= (x - nodes[j]) / (nodes[idx] - nodes[j])
        
        ax.plot(x, basis, color=colors[idx], linewidth=2.5)
        ax.axhline(y=0, color='black', linewidth=0.5)
        ax.axhline(y=1, color='gray', linewidth=0.5, linestyle='--')
        
        # Mark nodes
        for j in range(n):
            val = 1.0 if j == idx else 0.0
            marker = 'o' if j == idx else 'x'
            ax.plot(nodes[j], val, marker, color='black', markersize=10, zorder=5)
        
        ax.set_title(f'ℓ_{idx}(x): equals 1 at x={nodes[idx]}, 0 at others',
                     fontsize=12)
        ax.set_xlabel('x')
        ax.set_ylabel(f'ℓ_{idx}(x)')
        ax.grid(True, alpha=0.3)
        ax.set_ylim(-0.8, 1.5)
    
    fig.suptitle('Lagrange Basis Polynomials\nThe building blocks of interpolation',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    
    fig.savefig('viz_lagrange_basis.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


def viz_vandermonde():
    """Visualize the Vandermonde matrix and its structure."""
    nodes = np.array([1.0, 2.0, 3.0, 5.0])
    n = len(nodes)
    
    V = np.array([[x**j for j in range(n)] for x in nodes])
    
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    # Panel 1: Vandermonde matrix heatmap
    ax = axes[0]
    im = ax.imshow(V, cmap='YlOrRd', aspect='auto')
    ax.set_title('Vandermonde Matrix V', fontsize=13)
    ax.set_xlabel('Power j')
    ax.set_ylabel('Node index i')
    ax.set_xticks(range(n))
    ax.set_xticklabels([f'x^{j}' for j in range(n)])
    ax.set_yticks(range(n))
    ax.set_yticklabels([f'x={int(x)}' for x in nodes])
    for i in range(n):
        for j in range(n):
            ax.text(j, i, f'{V[i,j]:.0f}', ha='center', va='center', fontsize=11)
    plt.colorbar(im, ax=ax, shrink=0.8)
    
    # Panel 2: V inverse
    V_inv = np.linalg.inv(V)
    ax = axes[1]
    im2 = ax.imshow(V_inv, cmap='RdBu', aspect='auto',
                    vmin=-np.max(np.abs(V_inv)), vmax=np.max(np.abs(V_inv)))
    ax.set_title('V⁻¹ (Interpolation Matrix)', fontsize=13)
    ax.set_xlabel('Node index i')
    ax.set_ylabel('Coefficient j')
    ax.set_xticks(range(n))
    ax.set_xticklabels([f'x={int(x)}' for x in nodes])
    ax.set_yticks(range(n))
    ax.set_yticklabels([f'a_{j}' for j in range(n)])
    for i in range(n):
        for j in range(n):
            ax.text(j, i, f'{V_inv[i,j]:.3f}', ha='center', va='center', fontsize=9)
    plt.colorbar(im2, ax=ax, shrink=0.8)
    
    # Panel 3: V * V^{-1} = I
    product = V @ V_inv
    ax = axes[2]
    im3 = ax.imshow(np.abs(product), cmap='Blues', aspect='auto', vmin=0, vmax=1.1)
    ax.set_title('V · V⁻¹ = I (verification)', fontsize=13)
    ax.set_xticks(range(n))
    ax.set_yticks(range(n))
    for i in range(n):
        for j in range(n):
            ax.text(j, i, f'{product[i,j]:.1f}', ha='center', va='center', fontsize=11)
    plt.colorbar(im3, ax=ax, shrink=0.8)
    
    fig.suptitle('Vandermonde Matrix: Evaluation as Linear Algebra',
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    
    fig.savefig('viz_vandermonde.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


def viz_reed_solomon():
    """Visualize Reed-Solomon encoding and erasure recovery."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    # Message polynomial
    msg_coeffs = np.array([2.0, -1.0, 0.5])
    eval_points = np.array([1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0])
    k = len(msg_coeffs)
    n = len(eval_points)
    
    x = np.linspace(0, 8, 200)
    y = sum(msg_coeffs[j] * x**j for j in range(k))
    codeword = np.array([sum(msg_coeffs[j] * ep**j for j in range(k)) for ep in eval_points])
    
    # Panel 1: Message polynomial and full codeword
    ax = axes[0]
    ax.plot(x, y, 'b-', linewidth=2, label='Message poly')
    ax.plot(eval_points, codeword, 'go', markersize=10, zorder=5, label='Codeword')
    ax.set_title(f'[{n},{k},{n-k+1}] RS Code\nEncoding', fontsize=13)
    ax.set_xlabel('x')
    ax.set_ylabel('p(x)')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    # Panel 2: Erasure channel — some symbols lost
    ax = axes[1]
    surviving = [0, 2, 5]  # minimum k=3 symbols
    erased = [i for i in range(n) if i not in surviving]
    
    ax.plot(x, y, 'b-', linewidth=1, alpha=0.3)
    ax.plot(eval_points[surviving], codeword[surviving], 'go', markersize=12,
            zorder=5, label='Received')
    ax.plot(eval_points[erased], codeword[erased], 'rx', markersize=12,
            markeredgewidth=2, zorder=5, label='Erased')
    ax.set_title(f'{len(erased)} symbols erased\n(out of {n})', fontsize=13)
    ax.set_xlabel('x')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    # Panel 3: Reconstruction
    ax = axes[2]
    rec_nodes = eval_points[surviving]
    rec_vals = codeword[surviving]
    
    def lagrange_eval_vec(nodes, values, x_eval):
        result = np.zeros_like(x_eval)
        for i in range(len(nodes)):
            basis = np.ones_like(x_eval)
            for j in range(len(nodes)):
                if j != i:
                    basis *= (x_eval - nodes[j]) / (nodes[i] - nodes[j])
            result += values[i] * basis
        return result
    
    y_recon = lagrange_eval_vec(rec_nodes, rec_vals, x)
    
    ax.plot(x, y, 'b--', linewidth=1, alpha=0.5, label='Original')
    ax.plot(x, y_recon, 'g-', linewidth=2, label='Reconstructed')
    ax.plot(rec_nodes, rec_vals, 'go', markersize=10, zorder=5)
    ax.plot(eval_points[erased], codeword[erased], 'g^', markersize=8,
            zorder=5, label='Recovered values')
    ax.set_title('Exact Recovery\nvia interpolation', fontsize=13)
    ax.set_xlabel('x')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    fig.suptitle('Reed–Solomon Code: Encoding, Erasure, and Decoding',
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    
    fig.savefig('viz_reed_solomon.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


if __name__ == "__main__":
    print("Generating visualizations...")
    
    b64_roundtrip = viz_interpolation_roundtrip()
    print(f"  viz_roundtrip.png generated ({len(b64_roundtrip)} chars base64)")
    
    b64_basis = viz_lagrange_basis()
    print(f"  viz_lagrange_basis.png generated ({len(b64_basis)} chars base64)")
    
    b64_vander = viz_vandermonde()
    print(f"  viz_vandermonde.png generated ({len(b64_vander)} chars base64)")
    
    b64_rs = viz_reed_solomon()
    print(f"  viz_reed_solomon.png generated ({len(b64_rs)} chars base64)")
    
    print("All visualizations generated successfully!")
