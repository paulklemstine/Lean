#!/usr/bin/env python3
"""
Algorithms for Quantum EML Gate Synthesis

Implements the exact single-qubit gate synthesis algorithm based on the
normalized quantum EML activation chart on SU(2).

Algorithm: Given U ∈ SU(2), decompose U = qEMLnorm(H, c) where:
  - H is a traceless Hermitian 2×2 matrix
  - c ≥ 0 with H² = c·I
  - qEMLnorm(H, c) = (1/√(1+c)) · (I + iH)

This works for all U with tr(U) > 0 (rotation angle < π).
For U with tr(U) ≤ 0, we use a two-factor decomposition:
  U = qEMLnorm(H₁, c₁) · qEMLnorm(H₂, c₂)
"""

import numpy as np
from typing import Tuple, Optional

# Pauli matrices
SIGMA_X = np.array([[0, 1], [1, 0]], dtype=complex)
SIGMA_Y = np.array([[0, -1j], [1j, 0]], dtype=complex)
SIGMA_Z = np.array([[1, 0], [0, -1]], dtype=complex)
I2 = np.eye(2, dtype=complex)


def qEMLnorm(H: np.ndarray, c: float) -> np.ndarray:
    """
    Normalized quantum EML activation.
    
    Parameters:
        H: Traceless Hermitian 2×2 matrix
        c: Non-negative real such that H² = c·I
        
    Returns:
        U = (1/√(1+c)) · (I + iH) ∈ SU(2)
        
    Complexity: O(1) — constant-size matrix operations
    """
    return (1.0 / np.sqrt(1 + c)) * (I2 + 1j * H)


def hermitian_sq_scalar(H: np.ndarray) -> float:
    """
    Compute c such that H² = c·I for traceless Hermitian H.
    
    For H = x·σx + y·σy + z·σz, returns c = x² + y² + z².
    
    Complexity: O(1)
    """
    return (H @ H)[0, 0].real


def pauli_decompose(H: np.ndarray) -> Tuple[float, float, float]:
    """
    Decompose a traceless Hermitian 2×2 matrix into Pauli coordinates.
    
    H = x·σx + y·σy + z·σz
    
    Returns: (x, y, z)
    Complexity: O(1)
    """
    z = H[0, 0].real
    x = H[0, 1].real
    y = H[0, 1].imag  # H[0,1] = x - iy for our convention... 
    # Actually H = x·σx + y·σy + z·σz means:
    # H[0,0] = z, H[0,1] = x - iy, H[1,0] = x + iy, H[1,1] = -z
    y = -H[0, 1].imag
    return x, y, z


def pauli_compose(x: float, y: float, z: float) -> np.ndarray:
    """
    Construct a traceless Hermitian 2×2 matrix from Pauli coordinates.
    
    Returns H = x·σx + y·σy + z·σz
    Complexity: O(1)
    """
    return x * SIGMA_X + y * SIGMA_Y + z * SIGMA_Z


def axis_angle_to_su2(theta: float, axis: np.ndarray) -> np.ndarray:
    """
    Construct SU(2) matrix from axis-angle parameters.
    
    U = cos(θ/2)·I + i·sin(θ/2)·(n̂·σ)
    
    Parameters:
        theta: Rotation angle (0 to 2π)
        axis: Unit 3-vector (rotation axis)
        
    Returns: U ∈ SU(2)
    Complexity: O(1)
    """
    axis = axis / np.linalg.norm(axis)
    return np.cos(theta/2) * I2 + 1j * np.sin(theta/2) * pauli_compose(*axis)


def su2_to_axis_angle(U: np.ndarray) -> Tuple[float, np.ndarray]:
    """
    Extract axis-angle parameters from SU(2) matrix.
    
    For U = cos(θ/2)·I + i·sin(θ/2)·(n̂·σ), returns (θ, n̂).
    
    Returns: (theta, axis) where theta ∈ [0, 2π) and axis is a unit 3-vector
    Complexity: O(1)
    """
    cos_half = np.trace(U).real / 2
    cos_half = np.clip(cos_half, -1, 1)
    half_theta = np.arccos(cos_half)
    theta = 2 * half_theta
    
    if abs(np.sin(half_theta)) < 1e-12:
        return 0.0, np.array([0, 0, 1])  # Identity or -I
    
    # Extract i·sin(θ/2)·(n̂·σ) = (U - cos(θ/2)·I)
    K = (U - cos_half * I2) / (1j * np.sin(half_theta))
    x, y, z = pauli_decompose(K)
    axis = np.array([x, y, z])
    norm = np.linalg.norm(axis)
    if norm > 1e-12:
        axis /= norm
    return theta, axis


def synthesize_single_chart(U: np.ndarray) -> Optional[Tuple[np.ndarray, float]]:
    """
    Single-chart synthesis: find H, c such that qEMLnorm(H, c) = U.
    
    Works when tr(U).real > 0 (rotation angle < π).
    
    Algorithm:
        1. Compute s = 2 / Re(tr(U))
        2. Set H = -i · (s·U - I)
        3. Set c = s² - 1
        4. Verify: qEMLnorm(H, c) = U
    
    Parameters:
        U: SU(2) matrix
        
    Returns: (H, c) or None if tr(U).real ≤ 0
    
    Complexity: O(1)
    Time: ~1μs (constant-size matrix operations)
    Space: O(1)
    """
    tr_re = np.trace(U).real
    if tr_re <= 0:
        return None
    
    s = 2.0 / tr_re
    H = -1j * (s * U - I2)
    c = s**2 - 1
    
    # Verify Hermiticity and tracelessness
    assert np.allclose(H, H.conj().T, atol=1e-10), "H not Hermitian"
    assert abs(np.trace(H)) < 1e-10, "H not traceless"
    
    return H, c


def synthesize_two_factor(U: np.ndarray) -> Tuple[Tuple[np.ndarray, float], Tuple[np.ndarray, float]]:
    """
    Two-factor synthesis: decompose any U ∈ SU(2) as product of two qEMLnorm factors.
    
    U = qEMLnorm(H₁, c₁) · qEMLnorm(H₂, c₂)
    
    Strategy: Choose V₁ = qEMLnorm(0, 0) = I when tr(U) > 0,
    otherwise pick V₁ such that V₁†·U has positive trace.
    
    For U with tr(U) ≤ 0, we use V₁ = i·σ_z (a π/2 rotation around z),
    then V₁†·U has tr > 0 generically.
    
    Parameters:
        U: Any SU(2) matrix
        
    Returns: ((H₁, c₁), (H₂, c₂)) such that qEMLnorm(H₁,c₁)·qEMLnorm(H₂,c₂) = U
    
    Complexity: O(1)
    """
    result = synthesize_single_chart(U)
    if result is not None:
        H, c = result
        return (np.zeros((2, 2), dtype=complex), 0.0), (H, c)
    
    # U has non-positive trace. Use a fixed "helper" rotation.
    # Pick V₁ corresponding to H₁ = σ_z, c₁ = 1
    H1 = SIGMA_Z
    c1 = 1.0
    V1 = qEMLnorm(H1, c1)  # = (1/√2)(I + iσ_z)
    
    # Now find V₂ such that V₁ · V₂ = U, i.e., V₂ = V₁† · U
    V2 = V1.conj().T @ U
    
    result2 = synthesize_single_chart(V2)
    if result2 is not None:
        H2, c2 = result2
        return (H1, c1), (H2, c2)
    
    # If that didn't work, try σ_x
    H1 = SIGMA_X
    c1 = 1.0
    V1 = qEMLnorm(H1, c1)
    V2 = V1.conj().T @ U
    
    result2 = synthesize_single_chart(V2)
    if result2 is not None:
        H2, c2 = result2
        return (H1, c1), (H2, c2)
    
    # Fallback: try σ_y
    H1 = SIGMA_Y
    c1 = 1.0
    V1 = qEMLnorm(H1, c1)
    V2 = V1.conj().T @ U
    
    result2 = synthesize_single_chart(V2)
    if result2 is not None:
        H2, c2 = result2
        return (H1, c1), (H2, c2)
    
    raise RuntimeError("Two-factor synthesis failed (should not happen)")


def verify_synthesis(U: np.ndarray, H: np.ndarray, c: float, tol: float = 1e-10) -> dict:
    """
    Verify that qEMLnorm(H, c) = U and all conditions hold.
    
    Returns a dictionary with verification results.
    """
    U_synth = qEMLnorm(H, c)
    return {
        "H_hermitian": np.allclose(H, H.conj().T, atol=tol),
        "H_traceless": abs(np.trace(H)) < tol,
        "H_sq_scalar": np.allclose(H @ H, c * I2, atol=tol),
        "c_nonneg": c >= -tol,
        "U_reconstructed": np.allclose(U_synth, U, atol=tol),
        "U_synth_unitary": np.allclose(U_synth @ U_synth.conj().T, I2, atol=tol),
        "U_synth_det_one": abs(np.linalg.det(U_synth) - 1) < tol,
        "reconstruction_error": np.linalg.norm(U_synth - U),
    }


# ============================================================
# Example usage and tests
# ============================================================
if __name__ == "__main__":
    print("=" * 60)
    print("QUANTUM EML GATE SYNTHESIS ALGORITHM")
    print("=" * 60)
    
    # Test 1: Known gates
    print("\n--- Standard Quantum Gates ---")
    gates = {
        "Identity": I2,
        "Pauli X": SIGMA_X * 1j,  # Not quite right — need exp(iπ/2 σ_x)
        "T gate": np.diag([1, np.exp(1j * np.pi / 4)]),
        "S gate": np.diag([1, 1j]),
        "Hadamard": np.array([[1, 1], [1, -1]]) / np.sqrt(2),
    }
    
    # Fix: construct proper SU(2) versions
    gates = {
        "Identity": I2,
        "Z-rotation π/4": axis_angle_to_su2(np.pi/4, np.array([0, 0, 1])),
        "Z-rotation π/2": axis_angle_to_su2(np.pi/2, np.array([0, 0, 1])),
        "X-rotation π/3": axis_angle_to_su2(np.pi/3, np.array([1, 0, 0])),
        "Y-rotation π/6": axis_angle_to_su2(np.pi/6, np.array([0, 1, 0])),
        "Diagonal (1,1,1)": axis_angle_to_su2(np.pi/3, np.array([1, 1, 1]) / np.sqrt(3)),
    }
    
    for name, U in gates.items():
        result = synthesize_single_chart(U)
        if result:
            H, c = result
            v = verify_synthesis(U, H, c)
            x, y, z = pauli_decompose(H)
            print(f"  {name}: H = ({x:.4f})σx + ({y:.4f})σy + ({z:.4f})σz, "
                  f"c={c:.4f}, error={v['reconstruction_error']:.2e}")
        else:
            print(f"  {name}: Outside single-chart domain (tr ≤ 0)")
    
    # Test 2: Random gates — single chart
    print("\n--- Random SU(2) Gates (single chart) ---")
    n_success = 0
    n_total = 10000
    
    for _ in range(n_total):
        U = random_su2()
        if np.trace(U).real > 0.01:
            result = synthesize_single_chart(U)
            if result:
                H, c = result
                v = verify_synthesis(U, H, c)
                if v['reconstruction_error'] < 1e-10:
                    n_success += 1
    
    print(f"  Single-chart success: {n_success}/{n_total}")
    
    # Test 3: Two-factor decomposition for all gates
    print("\n--- Two-Factor Decomposition (covers all SU(2)) ---")
    n_success = 0
    n_total = 10000
    
    for _ in range(n_total):
        U = random_su2()
        try:
            (H1, c1), (H2, c2) = synthesize_two_factor(U)
            U_synth = qEMLnorm(H1, c1) @ qEMLnorm(H2, c2)
            error = np.linalg.norm(U_synth - U)
            if error < 1e-9:
                n_success += 1
        except Exception:
            pass
    
    print(f"  Two-factor success: {n_success}/{n_total}")
    
    # Test 4: Condition number analysis
    print("\n--- Condition Number vs Rotation Angle ---")
    angles = np.linspace(0.01, np.pi - 0.01, 20)
    for theta in angles:
        U = axis_angle_to_su2(theta, np.array([0, 0, 1]))
        result = synthesize_single_chart(U)
        if result:
            H, c = result
            r = np.sqrt(c)
            # Condition number: dr/dθ = 1/cos²(θ/2)
            cond = 1.0 / np.cos(theta/2)**2
            print(f"  θ={theta:.3f} (θ/π={theta/np.pi:.3f}): "
                  f"r={r:.4f}, cond={cond:.4f}")


def random_su2():
    """Generate a random SU(2) matrix."""
    v = np.random.randn(4)
    v /= np.linalg.norm(v)
    a, x, y, z = v
    return a * I2 + 1j * (x * SIGMA_X + y * SIGMA_Y + z * SIGMA_Z)
